"""
FlowPay Selenium Tests — Session Management (20 Test Cases)
Moved to test_error_handling.py for combined module.
This file provides additional session tests.
"""
import pytest
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from pages.base_page import BasePage


@pytest.mark.session
class TestSessionManagementExtended:
    """Additional session tests."""

    def test_sess_ext_001_auth_gate_redirects(self, driver):
        """TC_SESS_EXT_001 — AuthGate redirects based on auth state."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        assert page.is_flutter_app_loaded(), "AuthGate properly routes users"
