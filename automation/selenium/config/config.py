"""
FlowPay Selenium Automation Framework
Configuration Module
"""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # ─── URLs ──────────────────────────────────────────────────
    BASE_URL = os.environ.get("BASE_URL", "https://jananibsse.github.io/janani_pdd_flowpay/")
    
    # ─── Browser Settings ──────────────────────────────────────
    HEADLESS = os.environ.get("HEADLESS", "true").lower() == "true"
    BROWSER = os.environ.get("BROWSER", "chrome")
    IMPLICIT_WAIT = int(os.environ.get("IMPLICIT_WAIT", "10"))
    EXPLICIT_WAIT = int(os.environ.get("EXPLICIT_WAIT", "30"))
    PAGE_LOAD_TIMEOUT = int(os.environ.get("PAGE_LOAD_TIMEOUT", "60"))
    SCRIPT_TIMEOUT = int(os.environ.get("SCRIPT_TIMEOUT", "30"))
    
    # ─── Window Settings ──────────────────────────────────────
    WINDOW_WIDTH = int(os.environ.get("WINDOW_WIDTH", "1920"))
    WINDOW_HEIGHT = int(os.environ.get("WINDOW_HEIGHT", "1080"))
    
    # ─── Test Settings ─────────────────────────────────────────
    SCREENSHOT_ON_FAILURE = os.environ.get("SCREENSHOT_ON_FAILURE", "true").lower() == "true"
    RETRY_COUNT = int(os.environ.get("RETRY_COUNT", "2"))
    
    # ─── Paths ────────────────────────────────────────────────
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots")
    LOGS_DIR = os.path.join(BASE_DIR, "logs")
    REPORTS_DIR = os.path.join(BASE_DIR, "reports")
    DATA_DIR = os.path.join(BASE_DIR, "data")
    
    # ─── Test Credentials ─────────────────────────────────────
    TEST_USER_EMAIL = os.environ.get("TEST_USER_EMAIL", "testuser@flowpay.com")
    TEST_USER_PASSWORD = os.environ.get("TEST_USER_PASSWORD", "TestPass@123")
    ADMIN_EMAIL = os.environ.get("ADMIN_EMAIL", "admin@flowpay.com")
    ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "AdminPass@123")
    
    # ─── Performance Thresholds ───────────────────────────────
    MAX_PAGE_LOAD_MS = 3000
    MAX_INTERACTION_MS = 1000
    
    @classmethod
    def ensure_directories(cls):
        """Create required directories if they don't exist."""
        for directory in [cls.SCREENSHOTS_DIR, cls.LOGS_DIR, 
                          cls.REPORTS_DIR, cls.DATA_DIR]:
            os.makedirs(directory, exist_ok=True)
        # Sub-directories for reports
        for sub in ["html", "json", "excel"]:
            os.makedirs(os.path.join(cls.REPORTS_DIR, sub), exist_ok=True)
