#!/usr/bin/env python3
"""Generate GitHub Step Summary for load test results."""
import json
import os

k6f = "LoadTest_Results/k6/baseline-summary.json"
rps = "N/A"
total_reqs = "N/A"
avg = "N/A"
mn = "N/A"
mx = "N/A"
p95 = "N/A"
p99 = "N/A"
err = "N/A"

if os.path.exists(k6f):
    with open(k6f) as fh:
        k6data = json.load(fh)
    m = k6data.get("metrics", {})
    d = m.get("http_req_duration", {})
    r = m.get("http_reqs", {})
    rps = str(round(r.get("rate", 0), 1))
    total_reqs = str(r.get("count", 0))
    avg = str(round(d.get("avg", 0), 1))
    mn = str(round(d.get("min", 0), 1))
    mx = str(round(d.get("max", 0), 1))
    p95 = str(round(d.get("p(95)", 0), 1))
    p99 = str(round(d.get("p(99)", 0), 1))
    err = str(round(m.get("http_req_failed", {}).get("rate", 0) * 100, 2))

rf = "LoadTest_Results/json/loadtest_results.json"
passed = 0
failed = 0
if os.path.exists(rf):
    with open(rf) as fh:
        data = json.load(fh)
    for t in data.get("tests", []):
        if t.get("outcome") == "passed":
            passed += 1
        else:
            failed += 1

total = passed + failed
rate = str(round((passed / total * 100), 1)) if total > 0 else "0.0"

lines = []
lines.append("# Load and Performance Testing Results\n\n")
lines.append("## k6 Baseline Load Test (100 VUs x 1 min)\n")
lines.append("| Metric | Value |\n")
lines.append("|--------|-------|\n")
lines.append("| Requests per sec | " + rps + " req/sec |\n")
lines.append("| Total Requests | " + total_reqs + " |\n")
lines.append("| Avg Response | " + avg + " ms |\n")
lines.append("| Min Response | " + mn + " ms |\n")
lines.append("| Max Response | " + mx + " ms |\n")
lines.append("| P95 Response | " + p95 + " ms |\n")
lines.append("| P99 Response | " + p99 + " ms |\n")
lines.append("| Error Rate | " + err + "% |\n\n")
lines.append("## Performance Assertions (" + str(total) + " tests)\n")
lines.append("| Metric | Value |\n")
lines.append("|--------|-------|\n")
lines.append("| Total Assertions | " + str(total) + " |\n")
lines.append("| Passed | " + str(passed) + " |\n")
lines.append("| Failed | " + str(failed) + " |\n")
lines.append("| Pass Rate | " + rate + "% |\n\n")
lines.append("## Downloadable Artifacts\n")
lines.append("- LoadTest-HTML-Report: Self-contained HTML report\n")
lines.append("- LoadTest-Excel-Report: Excel with k6 metrics and assertion results\n")

summary = "".join(lines)
sf = os.environ.get("GITHUB_STEP_SUMMARY", "/dev/null")
with open(sf, "a") as fh:
    fh.write(summary)
print(summary)
