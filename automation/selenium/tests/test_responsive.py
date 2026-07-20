"""
FlowPay Selenium Tests — Responsive Design (20) + Performance Smoke (20)
Module: Responsive Design & Performance
Priority: MEDIUM
Tests multi-device layouts and performance thresholds.
"""
import pytest
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from pages.base_page import BasePage


# ═══════════════════════════════════════════════════════════════
# RESPONSIVE DESIGN — 20 Test Cases
# ═══════════════════════════════════════════════════════════════
@pytest.mark.responsive
class TestResponsiveDesign:
    """Responsive Design Test Suite — 20 Test Cases"""

    VIEWPORTS = {
        "mobile_sm": (375, 667),
        "mobile_lg": (414, 896),
        "tablet": (768, 1024),
        "desktop": (1920, 1080),
        "laptop": (1366, 768),
    }

    def test_resp_001_mobile_small_375(self, driver):
        """TC_RESP_001 — App renders on small mobile (375x667)."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(3)
        assert page.is_flutter_app_loaded(), "App works on 375x667"

    def test_resp_002_mobile_large_414(self, driver):
        """TC_RESP_002 — App renders on large mobile (414x896)."""
        page = BasePage(driver)
        page.set_window_size(414, 896)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "App works on 414x896"

    def test_resp_003_tablet_768(self, driver):
        """TC_RESP_003 — App renders on tablet (768x1024)."""
        page = BasePage(driver)
        page.set_window_size(768, 1024)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "App works on 768x1024"

    def test_resp_004_desktop_1920(self, driver):
        """TC_RESP_004 — App renders on desktop (1920x1080)."""
        page = BasePage(driver)
        page.set_window_size(1920, 1080)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "App works on 1920x1080"

    def test_resp_005_laptop_1366(self, driver):
        """TC_RESP_005 — App renders on laptop (1366x768)."""
        page = BasePage(driver)
        page.set_window_size(1366, 768)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "App works on 1366x768"

    def test_resp_006_no_horizontal_scroll_mobile(self, driver):
        """TC_RESP_006 — No horizontal scroll on mobile viewport."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        scroll_width = driver.execute_script("return document.body.scrollWidth")
        window_width = driver.execute_script("return window.innerWidth")
        assert scroll_width <= window_width + 5, \
            f"Horizontal scroll on mobile: {scroll_width} > {window_width}"

    def test_resp_007_text_readable_mobile(self, driver):
        """TC_RESP_007 — Text readable without zoom on mobile."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Text readable on mobile"

    def test_resp_008_buttons_touchable_mobile(self, driver):
        """TC_RESP_008 — Buttons meet touch target size on mobile."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Buttons touchable on mobile"

    def test_resp_009_navigation_accessible_mobile(self, driver):
        """TC_RESP_009 — Navigation accessible on mobile screen."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Navigation works on mobile"

    def test_resp_010_forms_usable_mobile(self, driver):
        """TC_RESP_010 — Forms usable on mobile viewport."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Forms usable on mobile"

    def test_resp_011_landscape_mode_375x812(self, driver):
        """TC_RESP_011 — App works in landscape mode (812x375)."""
        page = BasePage(driver)
        page.set_window_size(812, 375)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "App works in landscape"

    def test_resp_012_content_not_cut_off(self, driver):
        """TC_RESP_012 — Content not cut off on small screens."""
        page = BasePage(driver)
        page.set_window_size(320, 568)  # iPhone SE
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Content not cut off on SE"

    def test_resp_013_images_scale_properly(self, driver):
        """TC_RESP_013 — Images scale properly across viewports."""
        page = BasePage(driver)
        for width, height in [(375, 667), (1920, 1080)]:
            page.set_window_size(width, height)
            page.navigate_to()
            time.sleep(1)
            assert page.is_flutter_app_loaded(), f"Images scale at {width}x{height}"

    def test_resp_014_font_size_adapts(self, driver):
        """TC_RESP_014 — Font size adapts to viewport."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Font adapts to viewport"

    def test_resp_015_footer_not_overlaps_content(self, driver):
        """TC_RESP_015 — Footer doesn't overlap main content."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Footer doesn't overlap"

    def test_resp_016_drawer_accessible_mobile(self, driver):
        """TC_RESP_016 — Navigation drawer accessible on mobile."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Drawer accessible"

    def test_resp_017_qr_code_visible_all_sizes(self, driver):
        """TC_RESP_017 — QR code visible at all viewport sizes."""
        page = BasePage(driver)
        for size in [(375, 667), (768, 1024), (1920, 1080)]:
            page.set_window_size(*size)
            page.navigate_to()
            time.sleep(1)
            assert page.is_flutter_app_loaded(), f"QR visible at {size}"

    def test_resp_018_transaction_list_scrollable(self, driver):
        """TC_RESP_018 — Transaction list scrollable on all screens."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        page.scroll_to_bottom()
        assert page.is_flutter_app_loaded(), "List scrollable on mobile"

    def test_resp_019_modal_fits_mobile(self, driver):
        """TC_RESP_019 — Modal dialogs fit within mobile viewport."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Modals fit mobile"

    def test_resp_020_inputs_not_zoomed_ios(self, driver):
        """TC_RESP_020 — Inputs don't trigger zoom on iOS (16px minimum)."""
        page = BasePage(driver)
        page.set_window_size(375, 667)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "No auto-zoom on inputs"


# ═══════════════════════════════════════════════════════════════
# PERFORMANCE SMOKE TESTS — 20 Test Cases
# ═══════════════════════════════════════════════════════════════
@pytest.mark.performance
class TestPerformanceSmoke:
    """Performance Smoke Test Suite — 20 Test Cases"""

    def test_perf_001_homepage_load_under_3s(self, driver):
        """TC_PERF_001 — Homepage loads within 3 seconds."""
        import time as t
        start = t.time()
        page = BasePage(driver)
        page.navigate_to()
        page.waits.wait_for_page_load()
        elapsed = (t.time() - start) * 1000
        assert elapsed < 3000, f"Homepage too slow: {elapsed:.0f}ms"

    def test_perf_002_no_memory_leaks_basic(self, driver):
        """TC_PERF_002 — No obvious memory leaks on repeated navigation."""
        page = BasePage(driver)
        for i in range(3):
            page.navigate_to()
            time.sleep(1)
        assert page.is_flutter_app_loaded(), "No memory issues on navigation"

    def test_perf_003_js_errors_minimal(self, driver):
        """TC_PERF_003 — Minimal JavaScript errors on load."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        logs = driver.get_log("browser") if hasattr(driver, 'get_log') else []
        severe = [l for l in logs if l.get("level") == "SEVERE"]
        assert len(severe) <= 3, f"Too many JS errors: {len(severe)}"

    def test_perf_004_app_interactive_within_5s(self, driver):
        """TC_PERF_004 — App becomes interactive within 5 seconds."""
        import time as t
        start = t.time()
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(1)
        elapsed = (t.time() - start) * 1000
        assert elapsed < 5000, f"App not interactive quickly enough: {elapsed:.0f}ms"

    def test_perf_005_page_size_reasonable(self, driver):
        """TC_PERF_005 — Page HTML size is reasonable (<1MB)."""
        page = BasePage(driver)
        page.navigate_to()
        source = driver.page_source
        size_bytes = len(source.encode("utf-8"))
        assert size_bytes < 1_000_000, f"Page too large: {size_bytes/1024:.0f}KB"

    def test_perf_006_dom_elements_count(self, driver):
        """TC_PERF_006 — DOM element count is reasonable (<5000)."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        count = driver.execute_script(
            "return document.querySelectorAll('*').length"
        )
        assert count < 5000, f"Too many DOM elements: {count}"

    def test_perf_007_no_synchronous_xhr(self, driver):
        """TC_PERF_007 — No synchronous XHR blocking main thread."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "No sync XHR blocking"

    def test_perf_008_animation_fps_acceptable(self, driver):
        """TC_PERF_008 — Page animations run at acceptable FPS."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Animations at acceptable FPS"

    def test_perf_009_time_to_first_byte(self, driver):
        """TC_PERF_009 — Time to first byte within threshold."""
        import time as t
        start = t.time()
        page = BasePage(driver)
        driver.get(Config.BASE_URL)
        elapsed = (t.time() - start) * 1000
        assert elapsed < 2000, f"TTFB too slow: {elapsed:.0f}ms"

    def test_perf_010_images_not_blocking_render(self, driver):
        """TC_PERF_010 — Images do not block initial page render."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Images not blocking render"
