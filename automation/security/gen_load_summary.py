#!/usr/bin/env python3
"""Generate GitHub Step Summary for load test results."""
import json
import os

# Try new handleSummary format first, fall back to old summary-export
k6_data = {}
k6_files = [
    "LoadTest_Results/k6/k6-metrics.json",
    "LoadTest_Results/k6/baseline-summary.json",
]
for k6f in k6_files:
    if os.path.exists(k6f):
        with open(k6f) as fh:
            raw = json.load(fh)
        if "metrics" in raw and "response_time" in raw.get("metrics", {}):
            k6_data = raw["metrics"]
        elif "metrics" in raw:
            m = raw["metrics"]
            d = m.get("http_req_duration", {})
            r = m.get("http_reqs", {})
            f = m.get("http_req_failed", {})
            def gv(obj, key):
                return obj.get(key, obj.get("values", {}).get(key, None))
            k6_data = {
                "rps": gv(r, "rate"),
                "total_requests": gv(r, "count"),
                "response_time": {
                    "avg_ms": gv(d, "avg"),
                    "min_ms": gv(d, "min"),
                    "med_ms": gv(d, "med"),
                    "max_ms": gv(d, "max"),
                    "p90_ms": gv(d, "p(90)"),
                    "p95_ms": gv(d, "p(95)"),
                    "p99_ms": gv(d, "p(99)"),
                },
                "error_rate_pct": (gv(f, "rate") or 0) * 100,
            }
        break

def fmt(val, suffix="ms", precision=1):
    if val is None or val == 0:
        return "N/A"
    return str(round(val, precision)) + " " + suffix

rt = k6_data.get("response_time", {})
rps = k6_data.get("rps", None)
total_reqs = k6_data.get("total_requests", 0)
err_pct = k6_data.get("error_rate_pct", None)

# Pytest results
rf = "LoadTest_Results/json/loadtest_results.json"
passed = 0
failed = 0
total_tests = 0
if os.path.exists(rf):
    with open(rf) as fh:
        data = json.load(fh)
    for t in data.get("tests", []):
        total_tests += 1
        if t.get("outcome") == "passed":
            passed += 1
        else:
            failed += 1

rate = str(round((passed / total_tests * 100), 1)) if total_tests > 0 else "0.0"

lines = []
lines.append("# Load and Performance Testing Results\n\n")
lines.append("## k6 Baseline Load Test (100 VUs x 1 min)\n")
lines.append("| Metric | Value |\n")
lines.append("|--------|-------|\n")
lines.append("| Requests per sec | " + fmt(rps, "req/sec") + " |\n")
lines.append("| Total Requests | " + str(int(total_reqs or 0)) + " |\n")
lines.append("| Avg Response Time | " + fmt(rt.get("avg_ms")) + " |\n")
lines.append("| Median Response Time | " + fmt(rt.get("med_ms")) + " |\n")
lines.append("| P90 Response Time | " + fmt(rt.get("p90_ms")) + " |\n")
lines.append("| P95 Response Time | " + fmt(rt.get("p95_ms")) + " |\n")
lines.append("| P99 Response Time | " + fmt(rt.get("p99_ms")) + " |\n")
lines.append("| Min Response Time | " + fmt(rt.get("min_ms")) + " (CDN cache hit) |\n")
lines.append("| Max Response Time | " + fmt(rt.get("max_ms")) + " |\n")
lines.append("| Error Rate | " + fmt(err_pct, "%", 2) + " |\n\n")
lines.append("> **Note:** Min reflects HTTP/2 CDN cache hits. Focus on Avg, P95, P99 for SLA assessment.\n\n")
lines.append("## 400 Performance Assertion Tests\n")
lines.append("| Metric | Value |\n")
lines.append("|--------|-------|\n")
lines.append("| Total Assertions | " + str(total_tests) + " |\n")
lines.append("| Passed | " + str(passed) + " |\n")
lines.append("| Failed | " + str(failed) + " |\n")
lines.append("| Pass Rate | " + rate + "% |\n\n")
lines.append("## Test Categories (50 tests each)\n")
lines.append("| Category | Tests |\n")
lines.append("|----------|-------|\n")
lines.append("| Response Time Validation | 50 |\n")
lines.append("| Throughput Analysis | 50 |\n")
lines.append("| Error Rate Validation | 50 |\n")
lines.append("| Concurrency Testing | 50 |\n")
lines.append("| Endpoint Performance | 50 |\n")
lines.append("| Resource and Efficiency | 50 |\n")
lines.append("| Scalability Checks | 50 |\n")
lines.append("| Reliability and Stability | 50 |\n")
lines.append("| **Total** | **400** |\n\n")
lines.append("## Downloadable Artifacts\n")
lines.append("- **LoadTest-HTML-Report**: Self-contained HTML pytest report\n")
lines.append("- **LoadTest-Excel-Report**: Excel with 3 sheets — Dashboard, 400 Test Results, k6 Metrics Detail\n")

summary = "".join(lines)
sf = os.environ.get("GITHUB_STEP_SUMMARY", "/dev/null")
with open(sf, "a") as fh:
    fh.write(summary)
print(summary)
