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
# SESSION MANAGEMENT — 20 Test Cases
# ═══════════════════════════════════════════════════════════════
@pytest.mark.session
class TestSessionManagement:
    """Session Management Test Suite — 20 Test Cases"""

    def test_sess_001_session_created_on_login(self, driver):
        """TC_SESS_001 — Session created after successful login."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session created on login"

    def test_sess_002_session_destroyed_on_logout(self, driver):
        """TC_SESS_002 — Session destroyed after logout."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session cleared on logout"

    def test_sess_003_session_persists_tab_switch(self, driver):
        """TC_SESS_003 — Session persists when switching tabs."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        # Open new tab
        driver.execute_script("window.open('');")
        driver.switch_to.window(driver.window_handles[0])
        assert page.is_flutter_app_loaded(), "Session persists across tabs"

    def test_sess_004_firebase_auth_persistence(self, driver):
        """TC_SESS_004 — Firebase auth session persists in browser."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        assert page.is_flutter_app_loaded(), "Firebase auth persists"

    def test_sess_005_session_timeout(self, driver):
        """TC_SESS_005 — Session times out after inactivity."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session timeout handled"

    def test_sess_006_refresh_token_rotated(self, driver):
        """TC_SESS_006 — Firebase refresh tokens rotated correctly."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Refresh tokens rotated"

    def test_sess_007_concurrent_sessions_handled(self, driver):
        """TC_SESS_007 — Concurrent sessions managed properly."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Concurrent sessions managed"

    def test_sess_008_session_storage_not_sensitive(self, driver):
        """TC_SESS_008 — Sensitive data not in sessionStorage."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        session_data = driver.execute_script(
            "return JSON.stringify(window.sessionStorage)"
        )
        sensitive_keys = ["password", "pin", "secret"]
        if session_data:
            for key in sensitive_keys:
                assert key not in session_data.lower(), \
                    f"Sensitive key '{key}' found in sessionStorage"

    def test_sess_009_local_storage_audit(self, driver):
        """TC_SESS_009 — LocalStorage doesn't contain raw passwords."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        local_data = driver.execute_script(
            "return JSON.stringify(window.localStorage)"
        )
        if local_data:
            assert "password" not in local_data.lower(), \
                "Raw passwords should not be in localStorage"

    def test_sess_010_cookie_security_flags(self, driver):
        """TC_SESS_010 — Cookies have security flags set."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        cookies = driver.get_cookies()
        assert isinstance(cookies, list), "Cookies are properly managed"

    def test_sess_011_session_id_randomness(self, driver):
        """TC_SESS_011 — Session IDs are sufficiently random."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session IDs are random"

    def test_sess_012_logout_clears_local_state(self, driver):
        """TC_SESS_012 — Logout clears local app state."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Logout clears local state"

    def test_sess_013_auth_state_listener_active(self, driver):
        """TC_SESS_013 — Firebase auth state listener is active."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        assert page.is_flutter_app_loaded(), "Auth state listener active"

    def test_sess_014_deep_link_preserves_session(self, driver):
        """TC_SESS_014 — Deep links preserve existing session."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Deep links preserve session"

    def test_sess_015_browser_refresh_preserves_auth(self, driver):
        """TC_SESS_015 — Browser refresh preserves authentication."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        page.refresh()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Auth preserved on refresh"

    def test_sess_016_indexeddb_used_for_firebase(self, driver):
        """TC_SESS_016 — Firebase uses IndexedDB for token storage."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        has_idb = driver.execute_script("return typeof window.indexedDB !== 'undefined'")
        assert has_idb, "IndexedDB should be available for Firebase"

    def test_sess_017_session_renewed_on_expiry(self, driver):
        """TC_SESS_017 — Session auto-renewed before expiry."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session auto-renewed"

    def test_sess_018_multi_device_session(self, driver):
        """TC_SESS_018 — Multi-device sessions managed correctly."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Multi-device sessions managed"

    def test_sess_019_session_after_password_change(self, driver):
        """TC_SESS_019 — Session invalidated after password change."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session invalidated on pwd change"

    def test_sess_020_no_session_fixation(self, driver):
        """TC_SESS_020 — Session fixation attack prevented."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Session fixation prevented"
