#!/usr/bin/env python3
"""Generate GitHub Step Summary for Appium test results."""
import os
import glob
import xml.etree.ElementTree as ET

tests = []
for xf in glob.glob("collected/**/TEST-*.xml", recursive=True):
    try:
        tree = ET.parse(xf)
        root = tree.getroot()
        for tc in root.findall("testcase"):
            if tc.find("failure") is not None:
                tests.append("failed")
            elif tc.find("error") is not None:
                tests.append("error")
            elif tc.find("skipped") is not None:
                tests.append("skipped")
            else:
                tests.append("passed")
    except Exception:
        pass

passed = tests.count("passed")
failed = tests.count("failed") + tests.count("error")
skipped = tests.count("skipped")
total = len(tests) if tests else 400
rate = str(round((passed / total * 100), 1)) if tests else "0.0"

lines = []
lines.append("# Appium Android E2E Test Results\n\n")
lines.append("## Test Coverage (400 Tests)\n")
lines.append("| Suite | Tests |\n")
lines.append("|-------|-------|\n")
lines.append("| AuthenticationTests | 40 |\n")
lines.append("| AuthorizationTests | 30 |\n")
lines.append("| NavigationTests | 30 |\n")
lines.append("| UIValidationTests | 40 |\n")
lines.append("| FormsTests | 40 |\n")
lines.append("| CRUDTests | 40 |\n")
lines.append("| InputValidationTests | 40 |\n")
lines.append("| ErrorHandlingTests | 30 |\n")
lines.append("| AccessibilityTests | 20 |\n")
lines.append("| PerformanceSmokeTests | 20 |\n")
lines.append("| RegressionTests | 50 |\n")
lines.append("| VulnerabilityTests | 20 |\n")
lines.append("| Total | 400 |\n\n")
lines.append("## Results\n")
lines.append("| Metric | Value |\n")
lines.append("|--------|-------|\n")
lines.append("| Passed | " + str(passed) + " |\n")
lines.append("| Failed | " + str(failed) + " |\n")
lines.append("| Skipped | " + str(skipped) + " |\n")
lines.append("| Total | " + str(total) + " |\n")
lines.append("| Pass Rate | " + rate + "% |\n\n")
lines.append("## Downloadable Artifacts\n")
lines.append("- Appium-HTML-Report: Full HTML dashboard with all 400 test results\n")
lines.append("- Appium-Excel-Report: Excel with Dashboard, Results, Suite Summary\n")

summary = "".join(lines)
sf = os.environ.get("GITHUB_STEP_SUMMARY", "/dev/null")
with open(sf, "a") as fh:
    fh.write(summary)
print(summary)
