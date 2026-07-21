#!/usr/bin/env python3
"""Generate GitHub Step Summary for Selenium test results."""
import json
import os

rf = "reports/json/selenium_results.json"
passed = failed = errors = skipped = 0
if os.path.exists(rf):
    with open(rf) as fh:
        data = json.load(fh)
    for t in data.get("tests", []):
        o = t.get("outcome", "")
        if o == "passed":
            passed += 1
        elif o == "failed":
            failed += 1
        elif o == "error":
            errors += 1
        else:
            skipped += 1

total = passed + failed + errors + skipped
rate = (passed / total * 100) if total > 0 else 0

lines = [
    "# 🌐 Selenium Web E2E — Test Results\n",
    "## 📊 Test Metrics\n",
    "| Metric | Value |\n",
    "|--------|-------|\n",
    f"| Total Tests | {total} |\n",
    f"| Passed | {passed} |\n",
    f"| Failed | {failed} |\n",
    f"| Errors | {errors} |\n",
    f"| Skipped | {skipped} |\n",
    f"| Pass Rate | {rate:.1f}% |\n",
    "\n## 📁 Downloadable Artifacts\n",
    "- **Selenium-HTML-Report** — Self-contained HTML test report\n",
    "- **Selenium-Excel-Report** — Excel workbook with Dashboard, Results, Module Summary\n",
    "- **Selenium-Screenshots** — Screenshots captured on failure\n",
]

summary = "".join(lines)
sf = os.environ.get("GITHUB_STEP_SUMMARY", "/dev/null")
with open(sf, "a") as fh:
    fh.write(summary)
print(summary)
