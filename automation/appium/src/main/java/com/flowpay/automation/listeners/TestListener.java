package com.flowpay.automation.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import com.aventstack.extentreports.reporter.configuration.Theme;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;
import org.testng.ISuite;
import org.testng.ISuiteListener;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ConcurrentHashMap;

/**
 * FlowPay Appium — TestNG Listener
 * Captures test results, generates ExtentReports HTML report.
 * Attaches screenshots to failed tests automatically.
 */
public class TestListener implements ITestListener, ISuiteListener {

    private static final Logger log = LogManager.getLogger(TestListener.class);
    private static final String REPORTS_DIR = "../../Appium_Results/Reports";
    private static final DateTimeFormatter DTF =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private static ExtentReports extent;
    private static final ConcurrentHashMap<Long, ExtentTest> testMap = new ConcurrentHashMap<>();

    // ─── Suite Level ─────────────────────────────────────────

    @Override
    public void onStart(ISuite suite) {
        log.info("╔══════════════════════════════════════════╗");
        log.info("║  FlowPay Appium Suite: {} ║", suite.getName().padEnd(20));
        log.info("╚══════════════════════════════════════════╝");
        initExtentReports();
    }

    @Override
    public void onFinish(ISuite suite) {
        if (extent != null) {
            extent.flush();
            log.info("✅ ExtentReports flushed to: {}", REPORTS_DIR);
        }
        log.info("╔══════════════════════════════════════════╗");
        log.info("║     FlowPay Suite Complete              ║");
        log.info("╚══════════════════════════════════════════╝");
    }

    // ─── Test Level ──────────────────────────────────────────

    @Override
    public void onStart(ITestContext context) {
        log.info("📋 Test Context: {}", context.getName());
    }

    @Override
    public void onFinish(ITestContext context) {
        int passed  = context.getPassedTests().size();
        int failed  = context.getFailedTests().size();
        int skipped = context.getSkippedTests().size();
        int total   = passed + failed + skipped;
        double rate = total > 0 ? (passed * 100.0 / total) : 0;

        log.info("📊 Context Summary: {} | P:{} F:{} S:{} | {:.1f}%",
                context.getName(), passed, failed, skipped, rate);
    }

    @Override
    public void onTestStart(ITestResult result) {
        log.info("▶️  TEST: {}.{}", result.getTestClass().getName(), result.getMethod().getMethodName());

        if (extent != null) {
            ExtentTest test = extent.createTest(
                    result.getMethod().getMethodName(),
                    result.getMethod().getDescription()
            );
            test.assignCategory(result.getTestClass().getSimpleName());
            testMap.put(Thread.currentThread().getId(), test);
        }
    }

    @Override
    public void onTestSuccess(ITestResult result) {
        log.info("✅ PASS: {} ({:.2f}s)",
                result.getMethod().getMethodName(),
                getDurationSeconds(result));

        ExtentTest test = testMap.get(Thread.currentThread().getId());
        if (test != null) {
            test.log(Status.PASS, "✅ Test PASSED");
            test.log(Status.INFO, String.format("Duration: %.2fs", getDurationSeconds(result)));
        }
    }

    @Override
    public void onTestFailure(ITestResult result) {
        log.error("❌ FAIL: {} — {}",
                result.getMethod().getMethodName(),
                result.getThrowable() != null ? result.getThrowable().getMessage() : "Unknown");

        ExtentTest test = testMap.get(Thread.currentThread().getId());
        if (test != null) {
            test.log(Status.FAIL, "❌ Test FAILED");
            if (result.getThrowable() != null) {
                test.log(Status.FAIL, result.getThrowable().getMessage());
            }

            // Attach screenshot
            try {
                String screenshotPath = captureScreenshot(result.getMethod().getMethodName());
                if (!screenshotPath.isEmpty()) {
                    test.addScreenCaptureFromPath(screenshotPath, "Failure Screenshot");
                    log.info("📷 Screenshot attached: {}", screenshotPath);
                }
            } catch (Exception e) {
                log.warn("Could not attach screenshot: {}", e.getMessage());
            }
        }
    }

    @Override
    public void onTestSkipped(ITestResult result) {
        log.warn("⏭️  SKIP: {}", result.getMethod().getMethodName());

        ExtentTest test = testMap.get(Thread.currentThread().getId());
        if (test != null) {
            test.log(Status.SKIP, "⏭️ Test SKIPPED");
            if (result.getThrowable() != null) {
                test.log(Status.INFO, "Reason: " + result.getThrowable().getMessage());
            }
        }
    }

    @Override
    public void onTestFailedWithTimeout(ITestResult result) {
        log.error("⏱️ TIMEOUT: {}", result.getMethod().getMethodName());
        onTestFailure(result);
    }

    // ─── Private Helpers ─────────────────────────────────────

    private void initExtentReports() {
        try {
            Files.createDirectories(Paths.get(REPORTS_DIR));
        } catch (IOException e) {
            log.warn("Could not create reports directory: {}", e.getMessage());
        }

        String timestamp    = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String reportPath   = REPORTS_DIR + "/FlowPay_Appium_Report_" + timestamp + ".html";
        String dashboardPath = REPORTS_DIR + "/FlowPay_Appium_Dashboard.html";

        // Spark reporter (modern HTML)
        ExtentSparkReporter sparkReporter = new ExtentSparkReporter(reportPath);
        sparkReporter.config().setDocumentTitle("FlowPay Appium Test Report");
        sparkReporter.config().setReportName("FlowPay Android E2E Test Execution");
        sparkReporter.config().setTheme(Theme.DARK);
        sparkReporter.config().setEncoding("utf-8");
        sparkReporter.config().setTimelineEnabled(true);

        // Dashboard reporter
        ExtentSparkReporter dashReporter = new ExtentSparkReporter(dashboardPath);
        dashReporter.config().setDocumentTitle("FlowPay Dashboard");
        dashReporter.config().setTheme(Theme.DARK);

        extent = new ExtentReports();
        extent.attachReporter(sparkReporter, dashReporter);

        // System info
        extent.setSystemInfo("Application",       "FlowPay Digital Wallet");
        extent.setSystemInfo("Platform",          "Android 13");
        extent.setSystemInfo("Framework",         "Appium 8.x + TestNG 7.9");
        extent.setSystemInfo("App Package",       "com.example.flowpay_app");
        extent.setSystemInfo("Appium Server",     "http://localhost:4723");
        extent.setSystemInfo("Execution Date",    LocalDateTime.now().format(DTF));
        extent.setSystemInfo("Automation Engineer", "FlowPay QA Team");

        log.info("✅ ExtentReports initialized: {}", reportPath);
    }

    private double getDurationSeconds(ITestResult result) {
        return (result.getEndMillis() - result.getStartMillis()) / 1000.0;
    }

    private String captureScreenshot(String testName) {
        try {
            // Get driver from AppiumConfig thread-local
            io.appium.java_client.android.AndroidDriver driver =
                    com.flowpay.automation.config.AppiumConfig.getDriver();

            if (driver == null) return "";

            String dir  = REPORTS_DIR + "/screenshots";
            Files.createDirectories(Paths.get(dir));
            String ts   = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String path = dir + "/FAIL_" + testName.replaceAll("[^a-zA-Z0-9_]", "_") + "_" + ts + ".png";

            byte[] bytes = (byte[]) driver.getScreenshotAs(org.openqa.selenium.OutputType.BYTES);
            Files.write(Paths.get(path), bytes);
            return path;
        } catch (Exception e) {
            log.warn("Screenshot capture failed: {}", e.getMessage());
            return "";
        }
    }
}
