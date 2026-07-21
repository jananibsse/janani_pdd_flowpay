#!/usr/bin/env python3
"""Generate Excel report for load test results."""
import json
import os
from datetime import datetime

import openpyxl
from openpyxl.styles import PatternFill, Font

wb = openpyxl.Workbook()
hf = PatternFill(start_color="1e1e2e", end_color="1e1e2e", fill_type="solid")
hfont = Font(color="a855f7", bold=True, size=12)
pfill = PatternFill(start_color="238636", end_color="238636", fill_type="solid")
ffill = PatternFill(start_color="da3633", end_color="da3633", fill_type="solid")
wfont = Font(color="ffffff", size=11)

ws = wb.active
ws.title = "Dashboard"
ws.sheet_properties.tabColor = "a855f7"
ws.append(["FlowPay Load and Performance Test Report"])
ws["A1"].font = Font(bold=True, size=16, color="a855f7")
ws.append(["Generated: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S")])
ws.append(["Target: " + os.environ.get("BASE_URL", "N/A")])
ws.append([])

k6f = "LoadTest_Results/k6/baseline-summary.json"
if os.path.exists(k6f):
    with open(k6f) as fh:
        k6data = json.load(fh)
    m = k6data.get("metrics", {})
    d = m.get("http_req_duration", {})
    r = m.get("http_reqs", {})
    ws.append(["k6 Load Test Metrics", ""])
    for cell in ws[ws.max_row]:
        cell.fill = hf
        cell.font = hfont
    ws.append(["Requests Per Second", str(round(r.get("rate", 0), 1)) + " req/sec"])
    ws.append(["Total Requests", r.get("count", 0)])
    ws.append(["Avg Response Time", str(round(d.get("avg", 0), 1)) + " ms"])
    ws.append(["Min Response Time", str(round(d.get("min", 0), 1)) + " ms"])
    ws.append(["Max Response Time", str(round(d.get("max", 0), 1)) + " ms"])
    ws.append(["P95 Response Time", str(round(d.get("p(95)", 0), 1)) + " ms"])
    ws.append(["P99 Response Time", str(round(d.get("p(99)", 0), 1)) + " ms"])
    fr = m.get("http_req_failed", {}).get("rate", 0)
    ws.append(["Error Rate", str(round(fr * 100, 2)) + "%"])

ws.append([])

rf = "LoadTest_Results/json/loadtest_results.json"
tests = []
passed = 0
failed = 0
if os.path.exists(rf):
    with open(rf) as fh:
        data = json.load(fh)
    for t in data.get("tests", []):
        name = t.get("nodeid", "")
        outcome = t.get("outcome", "")
        dur = t.get("duration", 0)
        tests.append((name, outcome, dur))
        if outcome == "passed":
            passed += 1
        else:
            failed += 1

total = passed + failed
rate = (passed / total * 100) if total > 0 else 0
ws.append(["Assertion Results", ""])
for cell in ws[ws.max_row]:
    cell.fill = hf
    cell.font = hfont
ws.append(["Total Assertions", total])
ws.append(["Passed", passed])
ws.append(["Failed", failed])
ws.append(["Pass Rate", str(round(rate, 1)) + "%"])
ws.column_dimensions["A"].width = 30
ws.column_dimensions["B"].width = 25

ws2 = wb.create_sheet("Test Results")
ws2.append(["Num", "Test Case", "Category", "Status", "Duration (s)"])
for cell in ws2[1]:
    cell.fill = hf
    cell.font = hfont

for i, (name, outcome, dur) in enumerate(tests, 1):
    parts = name.split("::")
    tname = parts[-1] if len(parts) > 1 else name
    cat = "General"
    if len(parts) >= 2:
        cls = parts[-2] if len(parts) >= 3 else ""
        if "Response" in cls:
            cat = "Response Time"
        elif "Throughput" in cls:
            cat = "Throughput"
        elif "Error" in cls:
            cat = "Error Rate"
        elif "Concur" in cls:
            cat = "Concurrency"
        elif "Endpoint" in cls:
            cat = "Endpoint"
        elif "Resource" in cls:
            cat = "Resource"
        elif "Scala" in cls:
            cat = "Scalability"
        elif "Reliab" in cls:
            cat = "Reliability"
    ws2.append([i, tname, cat, outcome.upper(), str(round(dur, 2))])
    row = ws2.max_row
    sc = ws2.cell(row, 4)
    if outcome == "passed":
        sc.fill = pfill
        sc.font = wfont
    else:
        sc.fill = ffill
        sc.font = wfont

for c in ["A", "B", "C", "D", "E"]:
    ws2.column_dimensions[c].width = 20
ws2.column_dimensions["B"].width = 60

os.makedirs("LoadTest_Results/excel", exist_ok=True)
wb.save("LoadTest_Results/excel/LoadTest_Report.xlsx")
print("Load test Excel saved: total=" + str(total) + " passed=" + str(passed) + " failed=" + str(failed))
