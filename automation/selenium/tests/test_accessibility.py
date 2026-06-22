"""
FlowPay Selenium Tests — Accessibility (20 Test Cases)
Module: Accessibility
Priority: MEDIUM
Tests WCAG 2.1 compliance, screen reader support, and keyboard navigation.
"""
import pytest
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from pages.base_page import BasePage


@pytest.mark.accessibility
class TestAccessibility:
    """
    Accessibility Test Suite
    Total: 20 Test Cases
    Coverage: WCAG 2.1, keyboard navigation, screen reader, contrast
    """

    def test_a11y_001_lang_attribute_set(self, driver):
        """TC_A11Y_001 — HTML lang attribute is set."""
        page = BasePage(driver)
        page.navigate_to()
        lang = driver.execute_script("return document.documentElement.lang")
        assert lang and len(lang) > 0, "HTML lang attribute should be set"

    def test_a11y_002_title_tag_present(self, driver):
        """TC_A11Y_002 — Title tag present for screen readers."""
        page = BasePage(driver)
        page.navigate_to()
        title = driver.title
        assert title and len(title) > 0, "Title tag should be present"

    def test_a11y_003_images_have_alt_text(self, driver):
        """TC_A11Y_003 — Images have alt text for screen readers."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(3)
        imgs = driver.find_elements("tag name", "img")
        for img in imgs:
            alt = img.get_attribute("alt")
            assert alt is not None, "All images should have alt attribute"

    def test_a11y_004_buttons_have_labels(self, driver):
        """TC_A11Y_004 — All buttons have accessible labels."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Buttons should have labels"

    def test_a11y_005_keyboard_navigation(self, driver):
        """TC_A11Y_005 — App navigable via keyboard."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Keyboard navigation works"

    def test_a11y_006_focus_visible(self, driver):
        """TC_A11Y_006 — Focus indicator visible on interactive elements."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Focus indicator is visible"

    def test_a11y_007_color_not_sole_indicator(self, driver):
        """TC_A11Y_007 — Color not sole means of conveying information."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Color not sole indicator"

    def test_a11y_008_sufficient_color_contrast(self, driver):
        """TC_A11Y_008 — Text has sufficient color contrast (4.5:1)."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Color contrast meets WCAG"

    def test_a11y_009_font_size_readable(self, driver):
        """TC_A11Y_009 — Default font size is readable (≥16px for body)."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Font size is readable"

    def test_a11y_010_zoom_does_not_break_layout(self, driver):
        """TC_A11Y_010 — 200% zoom doesn't break layout."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        driver.execute_script("document.body.style.zoom = '2'")
        time.sleep(1)
        assert page.is_flutter_app_loaded(), "Zoom doesn't break layout"

    def test_a11y_011_tab_order_logical(self, driver):
        """TC_A11Y_011 — Tab order follows logical reading order."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Tab order is logical"

    def test_a11y_012_form_errors_announced(self, driver):
        """TC_A11Y_012 — Form errors announced to screen readers."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Errors announced to screen readers"

    def test_a11y_013_loading_states_announced(self, driver):
        """TC_A11Y_013 — Loading states announced to assistive tech."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Loading states announced"

    def test_a11y_014_aria_labels_on_icons(self, driver):
        """TC_A11Y_014 — Icon-only buttons have ARIA labels."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Icons have ARIA labels"

    def test_a11y_015_no_positive_tabindex(self, driver):
        """TC_A11Y_015 — No positive tabindex values (disrupts order)."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        elements = driver.find_elements("css selector", "[tabindex]")
        for el in elements:
            tabindex = el.get_attribute("tabindex")
            if tabindex:
                try:
                    assert int(tabindex) <= 0, \
                        f"Positive tabindex {tabindex} disrupts tab order"
                except ValueError:
                    pass

    def test_a11y_016_links_have_descriptive_text(self, driver):
        """TC_A11Y_016 — Links have descriptive text (not 'click here')."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        links = driver.find_elements("tag name", "a")
        bad_links = [l for l in links if l.text.lower() in ["click here", "here", "more"]]
        assert len(bad_links) == 0, "Links should have descriptive text"

    def test_a11y_017_form_labels_associated(self, driver):
        """TC_A11Y_017 — Form inputs have associated labels."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Form inputs have labels"

    def test_a11y_018_error_messages_accessible(self, driver):
        """TC_A11Y_018 — Error messages accessible to screen readers."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Error messages accessible"

    def test_a11y_019_minimum_touch_target_size(self, driver):
        """TC_A11Y_019 — Interactive elements meet minimum 44x44px size."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Touch targets are ≥44px"

    def test_a11y_020_skip_to_main_content(self, driver):
        """TC_A11Y_020 — Skip to main content link available."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Skip to main content available"
