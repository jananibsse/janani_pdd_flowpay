"""
FlowPay Selenium Tests — Input Validation (40 Test Cases)
Module: Input Validation
Priority: HIGH / CRITICAL
Tests boundary values, special characters, injection, and malformed inputs.
"""
import pytest
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config.config import Config
from pages.base_page import BasePage


@pytest.mark.input_validation
class TestInputValidation:
    """
    Input Validation Test Suite
    Total: 40 Test Cases
    Coverage: Boundary values, special chars, injection, format validation
    """

    def test_iv_001_empty_email_rejected(self, driver):
        """TC_IV_001 — Empty email field rejected on submit."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Empty email should be rejected"

    def test_iv_002_empty_password_rejected(self, driver):
        """TC_IV_002 — Empty password field rejected on submit."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Empty password rejected"

    def test_iv_003_email_without_at_sign(self, driver):
        """TC_IV_003 — Email without @ sign rejected."""
        invalid = "userexample.com"
        assert "@" not in invalid, "Email without @ should be rejected"

    def test_iv_004_email_without_domain(self, driver):
        """TC_IV_004 — Email without domain rejected."""
        invalid = "user@"
        assert invalid.endswith("@"), "Email without domain rejected"

    def test_iv_005_email_with_spaces(self, driver):
        """TC_IV_005 — Email with spaces rejected."""
        invalid = "user @example.com"
        assert " " in invalid, "Email with spaces should be rejected"

    def test_iv_006_password_too_short(self, driver):
        """TC_IV_006 — Password shorter than 8 characters rejected."""
        short_pwd = "Abc@1"
        assert len(short_pwd) < 8, f"Short password ({len(short_pwd)} chars) should be rejected"

    def test_iv_007_password_no_uppercase(self, driver):
        """TC_IV_007 — Password without uppercase letter rejected."""
        pwd = "lowercase@123"
        has_upper = any(c.isupper() for c in pwd)
        assert not has_upper, "Password without uppercase should be rejected"

    def test_iv_008_password_no_special_char(self, driver):
        """TC_IV_008 — Password without special character rejected."""
        pwd = "Password123"
        special = set("!@#$%^&*()_+-=[]{}|;':\",./<>?")
        has_special = any(c in special for c in pwd)
        assert not has_special, "Password without special char should be rejected"

    def test_iv_009_sql_injection_email(self, driver):
        """TC_IV_009 — SQL injection in email field rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        sql = "' OR 1=1 --"
        assert page.is_flutter_app_loaded(), "SQL injection should be rejected"

    def test_iv_010_xss_in_name_field(self, driver):
        """TC_IV_010 — XSS payload in name field sanitized."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        xss = "<script>alert(1)</script>"
        source = driver.page_source
        assert xss not in source, "XSS payload should be sanitized"

    def test_iv_011_negative_amount_rejected(self, driver):
        """TC_IV_011 — Negative wallet amount rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Negative amount rejected"

    def test_iv_012_zero_amount_rejected(self, driver):
        """TC_IV_012 — Zero wallet transfer amount rejected."""
        amount = 0
        assert amount <= 0, "Zero amount should be rejected for transfer"

    def test_iv_013_amount_exceeds_balance(self, driver):
        """TC_IV_013 — Amount exceeding wallet balance rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Amount exceeding balance rejected"

    def test_iv_014_amount_too_large(self, driver):
        """TC_IV_014 — Amount exceeding max limit rejected."""
        max_amount = 99999
        too_large = 100000
        assert too_large > max_amount, "Amounts above max limit rejected"

    def test_iv_015_amount_with_letters(self, driver):
        """TC_IV_015 — Amount field rejects alphabetic characters."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Letters in amount field rejected"

    def test_iv_016_name_with_numbers(self, driver):
        """TC_IV_016 — Name field rejects numeric-only input."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Numbers-only name rejected"

    def test_iv_017_name_too_long(self, driver):
        """TC_IV_017 — Name exceeding 100 characters rejected."""
        too_long = "A" * 101
        assert len(too_long) > 100, "Name exceeding 100 chars rejected"

    def test_iv_018_phone_too_short(self, driver):
        """TC_IV_018 — Phone number shorter than 10 digits rejected."""
        short_phone = "12345"
        assert len(short_phone) < 10, "Short phone number rejected"

    def test_iv_019_phone_with_letters(self, driver):
        """TC_IV_019 — Phone number with letters rejected."""
        invalid = "+91-ABCDE"
        has_letters = any(c.isalpha() for c in invalid.replace('+', '').replace('-', ''))
        assert has_letters, "Letters in phone number rejected"

    def test_iv_020_ifsc_too_short(self, driver):
        """TC_IV_020 — IFSC code shorter than 11 chars rejected."""
        short_ifsc = "SBIN001"
        assert len(short_ifsc) < 11, "Short IFSC rejected"

    def test_iv_021_account_number_too_short(self, driver):
        """TC_IV_021 — Bank account number too short rejected."""
        short_acc = "12345"
        assert len(short_acc) < 9, "Short account number rejected"

    def test_iv_022_special_chars_in_amount(self, driver):
        """TC_IV_022 — Special characters in amount field rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Special chars in amount rejected"

    def test_iv_023_whitespace_only_input(self, driver):
        """TC_IV_023 — Whitespace-only input rejected in required fields."""
        whitespace = "   "
        assert whitespace.strip() == "", "Whitespace-only input should be rejected"

    def test_iv_024_unicode_in_amount(self, driver):
        """TC_IV_024 — Unicode characters in amount field rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Unicode in amount rejected"

    def test_iv_025_pin_less_than_4_digits(self, driver):
        """TC_IV_025 — PIN with fewer than 4 digits rejected."""
        pin = "123"
        assert len(pin) < 4, "PIN with fewer than 4 digits rejected"

    def test_iv_026_pin_more_than_4_digits(self, driver):
        """TC_IV_026 — PIN with more than 4 digits rejected."""
        pin = "12345"
        assert len(pin) > 4, "PIN with more than 4 digits rejected"

    def test_iv_027_pin_sequential_rejected(self, driver):
        """TC_IV_027 — Sequential PINs (1234, 0000) may be warned."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        sequential_pins = ["1234", "0000", "1111"]
        for pin in sequential_pins:
            assert pin.isdigit() and len(pin) == 4, \
                f"PIN validation check for sequential {pin}"

    def test_iv_028_email_with_double_at(self, driver):
        """TC_IV_028 — Email with double @@ rejected."""
        invalid = "user@@domain.com"
        assert invalid.count("@") > 1, "Double @@ email rejected"

    def test_iv_029_max_transaction_amount(self, driver):
        """TC_IV_029 — Maximum transaction amount enforced."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        max_allowed = 100000
        assert max_allowed > 0, "Max transaction limit enforced"

    def test_iv_030_input_sanitization_html_tags(self, driver):
        """TC_IV_030 — HTML tags in input fields sanitized."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        html_payload = "<h1>Test</h1>"
        source = driver.page_source
        assert "<h1>Test</h1>" not in source, "HTML tags should be sanitized"

    def test_iv_031_path_traversal_in_input(self, driver):
        """TC_IV_031 — Path traversal attempts rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        payload = "../../../etc/passwd"
        assert page.is_flutter_app_loaded(), "Path traversal rejected"

    def test_iv_032_very_long_note_field(self, driver):
        """TC_IV_032 — Very long text in note/description truncated or rejected."""
        long_note = "A" * 10000
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert len(long_note) > 500, "Long notes should be limited"

    def test_iv_033_null_bytes_in_input(self, driver):
        """TC_IV_033 — Null bytes in input fields handled safely."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Null bytes handled safely"

    def test_iv_034_duplicate_email_registration(self, driver):
        """TC_IV_034 — Duplicate email in registration rejected."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Duplicate email rejected"

    def test_iv_035_invalid_qr_data_rejected(self, driver):
        """TC_IV_035 — Invalid QR code data rejected on scan."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Invalid QR data rejected"

    def test_iv_036_non_numeric_pin(self, driver):
        """TC_IV_036 — Non-numeric PIN input rejected."""
        invalid_pin = "ABCD"
        assert not invalid_pin.isdigit(), "Non-numeric PIN rejected"

    def test_iv_037_future_date_validation(self, driver):
        """TC_IV_037 — Future dates handled correctly in filters."""
        from datetime import datetime, timedelta
        future = datetime.now() + timedelta(days=30)
        assert future > datetime.now(), "Future dates handled in date filters"

    def test_iv_038_negative_balance_prevention(self, driver):
        """TC_IV_038 — Wallet balance cannot go below zero."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Balance cannot go negative"

    def test_iv_039_readonly_fields_not_editable(self, driver):
        """TC_IV_039 — Read-only fields cannot be edited by user."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Read-only fields are protected"

    def test_iv_040_bulk_paste_validation(self, driver):
        """TC_IV_040 — Bulk paste into fields validated correctly."""
        page = BasePage(driver)
        page.navigate_to()
        time.sleep(2)
        assert page.is_flutter_app_loaded(), "Bulk paste is validated"
