"""
FlowPay Selenium Framework — conftest.py
Shared pytest fixtures for all Selenium tests.
"""
import os
import sys
import json
import pytest
from datetime import datetime

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from config.config import Config
from utils.driver_factory import DriverFactory
from utils.screenshot_utils import ScreenshotUtils
from utils.logger_utils import get_logger

logger = get_logger("conftest")


def pytest_configure(config):
    """Configure pytest settings."""
    Config.ensure_directories()
    logger.info(f"🚀 FlowPay Selenium Test Suite Starting")
    logger.info(f"🌐 BASE_URL: {Config.BASE_URL}")
    logger.info(f"🖥️  HEADLESS: {Config.HEADLESS}")


def pytest_collection_modifyitems(items):
    """Add ordering and markers to test items."""
    for item in items:
        # Add module markers based on file names
        if "authentication" in item.nodeid:
            item.add_marker(pytest.mark.authentication)
        elif "navigation" in item.nodeid:
            item.add_marker(pytest.mark.navigation)
        elif "ui_validation" in item.nodeid:
            item.add_marker(pytest.mark.ui)


@pytest.fixture(scope="session")
def test_data():
    """Load test data from JSON file."""
    data_file = os.path.join(os.path.dirname(__file__), "data", "test_data.json")
    with open(data_file, "r") as f:
        return json.load(f)


@pytest.fixture(scope="function")
def driver():
    """
    Create and yield a WebDriver instance for each test.
    Automatically quits after each test.
    """
    drv = DriverFactory.create_driver()
    drv.get(Config.BASE_URL)
    logger.info(f"✅ Driver created. Navigated to: {Config.BASE_URL}")
    
    yield drv
    
    logger.info("🔄 Closing driver...")
    DriverFactory.quit_driver(drv)


@pytest.fixture(scope="function")
def screenshot_utils(driver):
    """Provide ScreenshotUtils instance."""
    return ScreenshotUtils(driver)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """Hook to capture screenshots on test failures."""
    outcome = yield
    report = outcome.get_result()
    
    if report.when == "call" and report.failed:
        try:
            driver = item.funcargs.get("driver")
            if driver and Config.SCREENSHOT_ON_FAILURE:
                screenshot_util = ScreenshotUtils(driver)
                screenshot_path = screenshot_util.capture_failure_screenshot(item.name)
                
                if screenshot_path:
                    # Embed screenshot in HTML report
                    try:
                        import pytest_html
                        extras = getattr(report, "extras", [])
                        extras.append(pytest_html.extras.image(screenshot_path))
                        report.extras = extras
                    except ImportError:
                        pass
                
                # Capture browser logs
                browser_logs = screenshot_util.get_browser_logs()
                if browser_logs:
                    log_path = os.path.join(
                        Config.LOGS_DIR,
                        f"browser_log_{item.name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
                    )
                    with open(log_path, "w") as f:
                        json.dump(browser_logs, f, indent=2)
        except Exception as e:
            logger.warning(f"Could not capture failure evidence: {e}")


def pytest_html_report_title(report):
    """Customize HTML report title."""
    report.title = "FlowPay E2E Selenium Test Report"


def pytest_terminal_summary(terminalreporter, exitstatus, config):
    """Print summary at end of test run."""
    passed = len(terminalreporter.stats.get("passed", []))
    failed = len(terminalreporter.stats.get("failed", []))
    error = len(terminalreporter.stats.get("error", []))
    skipped = len(terminalreporter.stats.get("skipped", []))
    total = passed + failed + error + skipped
    
    if total > 0:
        pass_rate = (passed / total) * 100
        logger.info(f"\n{'='*60}")
        logger.info(f"📊 FLOWPAY SELENIUM TEST SUMMARY")
        logger.info(f"{'='*60}")
        logger.info(f"  Total:   {total}")
        logger.info(f"  ✅ Passed:  {passed}")
        logger.info(f"  ❌ Failed:  {failed}")
        logger.info(f"  ⏭️  Skipped: {skipped}")
        logger.info(f"  🎯 Pass Rate: {pass_rate:.1f}%")
        logger.info(f"{'='*60}\n")
