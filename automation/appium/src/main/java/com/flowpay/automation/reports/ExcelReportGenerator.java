package com.flowpay.automation.reports;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * FlowPay Appium — Excel Report Generator
 * Generates formatted Excel workbooks from TestNG execution data.
 */
public class ExcelReportGenerator {

    private static final Logger log = LogManager.getLogger(ExcelReportGenerator.class);
    private static final String OUTPUT_DIR = "../../Appium_Results/Excel";
    private static final DateTimeFormatter DTF =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    // Style constants
    private XSSFCellStyle headerStyle;
    private XSSFCellStyle passStyle;
    private XSSFCellStyle failStyle;
    private XSSFCellStyle skipStyle;
    private XSSFCellStyle titleStyle;

    /**
     * Generate all Excel reports from test results.
     *
     * @param results List of test result maps with keys: testName, module, status, duration, reason
     */
    public void generateReports(List<Map<String, String>> results) {
        try {
            Files.createDirectories(Paths.get(OUTPUT_DIR));
        } catch (IOException e) {
            log.warn("Could not create output directory: {}", e.getMessage());
        }

        generateMainReport(results);
        generatePassedReport(results);
        generateFailedReport(results);
        generateSummaryReport(results);
    }

    private void generateMainReport(List<Map<String, String>> results) {
        XSSFWorkbook wb = new XSSFWorkbook();
        initStyles(wb);

        // Sheet 1: All Tests
        XSSFSheet ws = wb.createSheet("All Test Cases");
        writeTitle(ws, "FlowPay Appium E2E Test Results");
        writeHeaders(ws, 2, "Test ID", "Module", "Test Name", "Status",
                     "Duration", "Execution Date", "Failure Reason");

        int rowNum = 3;
        for (int i = 0; i < results.size(); i++) {
            Map<String, String> r = results.get(i);
            XSSFRow row = ws.createRow(rowNum++);
            row.createCell(0).setCellValue(String.format("TC_MOB_%03d", i + 1));
            row.createCell(1).setCellValue(r.getOrDefault("module", "—"));
            row.createCell(2).setCellValue(r.getOrDefault("testName", "—"));

            XSSFCell statusCell = row.createCell(3);
            String status = r.getOrDefault("status", "UNKNOWN");
            statusCell.setCellValue(status);
            statusCell.setCellStyle("PASS".equals(status) ? passStyle :
                                   "FAIL".equals(status) ? failStyle : skipStyle);

            row.createCell(4).setCellValue(r.getOrDefault("duration", "0s"));
            row.createCell(5).setCellValue(LocalDateTime.now().format(DTF));
            row.createCell(6).setCellValue(r.getOrDefault("reason", ""));
        }

        autoWidth(ws, 7);

        // Sheet 2: Summary
        XSSFSheet summary = wb.createSheet("Execution Metrics");
        writeTitle(summary, "Appium Execution Metrics");

        long passed  = results.stream().filter(r -> "PASS".equals(r.get("status"))).count();
        long failed  = results.stream().filter(r -> "FAIL".equals(r.get("status"))).count();
        long skipped = results.stream().filter(r -> "SKIP".equals(r.get("status"))).count();
        double rate  = results.isEmpty() ? 0 : (passed * 100.0 / results.size());

        writeMetric(summary, 2, "Total Test Cases", String.valueOf(results.size()));
        writeMetric(summary, 3, "Passed",           String.valueOf(passed));
        writeMetric(summary, 4, "Failed",           String.valueOf(failed));
        writeMetric(summary, 5, "Skipped",          String.valueOf(skipped));
        writeMetric(summary, 6, "Pass Rate",        String.format("%.1f%%", rate));
        writeMetric(summary, 7, "Platform",         "Android 13 (Emulator)");
        writeMetric(summary, 8, "Framework",        "Appium 8.x + TestNG 7.9");
        writeMetric(summary, 9, "App Package",      "com.example.flowpay_app");
        writeMetric(summary, 10, "Execution Date",  LocalDateTime.now().format(DTF));

        summary.setColumnWidth(0, 30 * 256);
        summary.setColumnWidth(1, 45 * 256);

        saveWorkbook(wb, "Appium_Test_Report.xlsx");
    }

    private void generatePassedReport(List<Map<String, String>> results) {
        XSSFWorkbook wb = new XSSFWorkbook();
        initStyles(wb);
        XSSFSheet ws = wb.createSheet("Passed Tests");
        writeTitle(ws, "Passed Test Cases");
        writeHeaders(ws, 2, "Test ID", "Module", "Test Name", "Duration");

        int rowNum = 3;
        int id = 1;
        for (Map<String, String> r : results) {
            if ("PASS".equals(r.get("status"))) {
                XSSFRow row = ws.createRow(rowNum++);
                row.createCell(0).setCellValue(String.format("TC_MOB_%03d", id));
                row.createCell(1).setCellValue(r.getOrDefault("module", ""));
                row.createCell(2).setCellValue(r.getOrDefault("testName", ""));
                row.createCell(3).setCellValue(r.getOrDefault("duration", "0s"));
            }
            id++;
        }
        autoWidth(ws, 4);
        saveWorkbook(wb, "Appium_Passed_Tests.xlsx");
    }

    private void generateFailedReport(List<Map<String, String>> results) {
        XSSFWorkbook wb = new XSSFWorkbook();
        initStyles(wb);
        XSSFSheet ws = wb.createSheet("Failed Tests");
        writeTitle(ws, "Failed Test Cases");
        writeHeaders(ws, 2, "Test ID", "Module", "Test Name", "Failure Reason", "Duration");

        int rowNum = 3;
        int id = 1;
        for (Map<String, String> r : results) {
            if ("FAIL".equals(r.get("status"))) {
                XSSFRow row = ws.createRow(rowNum++);
                row.createCell(0).setCellValue(String.format("TC_MOB_%03d", id));
                row.createCell(1).setCellValue(r.getOrDefault("module", ""));
                row.createCell(2).setCellValue(r.getOrDefault("testName", ""));
                row.createCell(3).setCellValue(r.getOrDefault("reason", "Unknown"));
                row.createCell(4).setCellValue(r.getOrDefault("duration", "0s"));
            }
            id++;
        }
        autoWidth(ws, 5);
        saveWorkbook(wb, "Appium_Failed_Tests.xlsx");
    }

    private void generateSummaryReport(List<Map<String, String>> results) {
        XSSFWorkbook wb = new XSSFWorkbook();
        initStyles(wb);
        XSSFSheet ws = wb.createSheet("Summary");
        writeTitle(ws, "FlowPay Appium E2E — Executive Summary");

        long passed = results.stream().filter(r -> "PASS".equals(r.get("status"))).count();
        double rate = results.isEmpty() ? 0 : (passed * 100.0 / results.size());

        writeMetric(ws, 2, "Build",        System.getProperty("BUILD_NUMBER", "local"));
        writeMetric(ws, 3, "Date",         LocalDateTime.now().format(DTF));
        writeMetric(ws, 4, "Total Tests",  String.valueOf(results.size()));
        writeMetric(ws, 5, "Passed",       String.valueOf(passed));
        writeMetric(ws, 6, "Failed",       String.valueOf(results.size() - passed));
        writeMetric(ws, 7, "Pass Rate",    String.format("%.1f%%", rate));
        writeMetric(ws, 8, "Platform",     "Android 13 / Pixel 5 API 33");
        writeMetric(ws, 9, "Status",       rate >= 95 ? "✅ PASSED" : "⚠️ REVIEW");

        ws.setColumnWidth(0, 25 * 256);
        ws.setColumnWidth(1, 45 * 256);
        saveWorkbook(wb, "Appium_Summary.xlsx");
    }

    // ─── Helpers ─────────────────────────────────────────────

    private void initStyles(XSSFWorkbook wb) {
        // Title
        titleStyle = wb.createCellStyle();
        XSSFFont titleFont = wb.createFont();
        titleFont.setBold(true);
        titleFont.setFontHeightInPoints((short) 16);
        titleFont.setColor(new XSSFColor(new byte[] {88, (byte)166, (byte)255}, null));
        titleStyle.setFont(titleFont);

        // Header
        headerStyle = wb.createCellStyle();
        headerStyle.setFillForegroundColor(new XSSFColor(new byte[] {30, 32, 48}, null));
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        XSSFFont hFont = wb.createFont();
        hFont.setBold(true);
        hFont.setColor(new XSSFColor(new byte[] {(byte)203, (byte)166, (byte)247}, null));
        headerStyle.setFont(hFont);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);

        // Pass
        passStyle = wb.createCellStyle();
        passStyle.setFillForegroundColor(new XSSFColor(new byte[] {0, (byte)184, (byte)148}, null));
        passStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        XSSFFont wFont = wb.createFont();
        wFont.setBold(true);
        wFont.setColor(IndexedColors.WHITE.getIndex());
        passStyle.setFont(wFont);
        passStyle.setAlignment(HorizontalAlignment.CENTER);

        // Fail
        failStyle = wb.createCellStyle();
        failStyle.setFillForegroundColor(new XSSFColor(new byte[] {(byte)214, 48, 49}, null));
        failStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        failStyle.setFont(wFont);
        failStyle.setAlignment(HorizontalAlignment.CENTER);

        // Skip
        skipStyle = wb.createCellStyle();
        skipStyle.setFillForegroundColor(new XSSFColor(new byte[] {(byte)210, (byte)153, 34}, null));
        skipStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        skipStyle.setFont(wFont);
        skipStyle.setAlignment(HorizontalAlignment.CENTER);
    }

    private void writeTitle(XSSFSheet ws, String title) {
        XSSFRow row = ws.createRow(0);
        XSSFCell cell = row.createCell(0);
        cell.setCellValue(title);
        cell.setCellStyle(titleStyle);
    }

    private void writeHeaders(XSSFSheet ws, int rowIdx, String... headers) {
        XSSFRow row = ws.createRow(rowIdx);
        for (int i = 0; i < headers.length; i++) {
            XSSFCell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }
    }

    private void writeMetric(XSSFSheet ws, int rowIdx, String key, String value) {
        XSSFRow row = ws.createRow(rowIdx);
        row.createCell(0).setCellValue(key);
        row.createCell(1).setCellValue(value);
    }

    private void autoWidth(XSSFSheet ws, int numCols) {
        for (int i = 0; i < numCols; i++) {
            ws.autoSizeColumn(i);
            if (ws.getColumnWidth(i) < 3000) ws.setColumnWidth(i, 3000);
        }
    }

    private void saveWorkbook(XSSFWorkbook wb, String filename) {
        String path = OUTPUT_DIR + "/" + filename;
        try (FileOutputStream fos = new FileOutputStream(path)) {
            wb.write(fos);
            wb.close();
            log.info("✅ {} saved", filename);
        } catch (IOException e) {
            log.error("❌ Failed to save {}: {}", filename, e.getMessage());
        }
    }
}
