"""
FlowPay Selenium Framework — Logger Utilities
Provides structured logging for the automation framework.
"""
import os
import sys
import logging
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def get_logger(name: str) -> logging.Logger:
    """
    Get a configured logger instance.
    
    Args:
        name: Logger name (usually __name__).
    
    Returns:
        Configured Logger instance.
    """
    logger = logging.getLogger(name)
    
    if not logger.handlers:
        logger.setLevel(logging.DEBUG)
        
        # Console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        console_format = logging.Formatter(
            "%(asctime)s | %(levelname)-8s | %(name)-30s | %(message)s",
            datefmt="%H:%M:%S"
        )
        console_handler.setFormatter(console_format)
        logger.addHandler(console_handler)
        
        # File handler
        logs_dir = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "logs"
        )
        os.makedirs(logs_dir, exist_ok=True)
        
        log_file = os.path.join(
            logs_dir,
            f"selenium_{datetime.now().strftime('%Y%m%d')}.log"
        )
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setLevel(logging.DEBUG)
        file_format = logging.Formatter(
            "%(asctime)s | %(levelname)-8s | %(name)-30s | %(funcName)s:%(lineno)d | %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S"
        )
        file_handler.setFormatter(file_format)
        logger.addHandler(file_handler)
    
    return logger


class TestLogger:
    """Structured test step logger for test case documentation."""
    
    def __init__(self, test_name: str):
        self.test_name = test_name
        self.logger = get_logger(f"TEST.{test_name}")
        self.steps = []
        self.start_time = datetime.now()
    
    def step(self, step_num: int, description: str) -> None:
        """Log a test step."""
        msg = f"[STEP {step_num}] {description}"
        self.logger.info(msg)
        self.steps.append({"step": step_num, "description": description, "time": datetime.now().isoformat()})
    
    def pass_step(self, message: str) -> None:
        """Log a passing assertion."""
        self.logger.info(f"✅ PASS: {message}")
    
    def fail_step(self, message: str) -> None:
        """Log a failing assertion."""
        self.logger.error(f"❌ FAIL: {message}")
    
    def info(self, message: str) -> None:
        """Log informational message."""
        self.logger.info(message)
    
    def warning(self, message: str) -> None:
        """Log warning."""
        self.logger.warning(f"⚠️ WARNING: {message}")
    
    def error(self, message: str) -> None:
        """Log error."""
        self.logger.error(f"🔴 ERROR: {message}")
    
    def get_duration(self) -> float:
        """Get test duration in seconds."""
        return (datetime.now() - self.start_time).total_seconds()
