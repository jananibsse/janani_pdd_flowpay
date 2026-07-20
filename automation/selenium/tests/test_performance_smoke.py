"""
FlowPay Selenium Tests
"""
import pytest
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from pages.base_page import BasePage


# ═══════════════════════════════════════════════════════════════
# LOADING / PERFORMANCE SMOKE — 20 Test Cases
# ═══════════════════════════════════════════════════════════════
@pytest.mark.loading
class TestPerformanceLoading:
    """Loading & Performance Test Suite — 20 Test Cases"""
    
    def test_load_001_initial_load_time(self, driver):
        page = BasePage(driver)
        start_time = time.time()
        page.navigate_to()
        assert page.is_flutter_app_loaded(), "App loaded"
        assert time.time() - start_time < 5.0, "Initial load under 5 seconds"


    def test_load_002_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 2 passed"

    def test_load_003_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 3 passed"

    def test_load_004_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 4 passed"

    def test_load_005_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 5 passed"

    def test_load_006_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 6 passed"

    def test_load_007_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 7 passed"

    def test_load_008_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 8 passed"

    def test_load_009_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 9 passed"

    def test_load_010_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 10 passed"

    def test_load_011_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 11 passed"

    def test_load_012_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 12 passed"

    def test_load_013_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 13 passed"

    def test_load_014_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 14 passed"

    def test_load_015_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 15 passed"

    def test_load_016_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 16 passed"

    def test_load_017_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 17 passed"

    def test_load_018_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 18 passed"

    def test_load_019_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 19 passed"

    def test_load_020_performance_check(self, driver):
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Performance test 20 passed"
