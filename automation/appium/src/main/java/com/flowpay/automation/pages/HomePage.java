package com.flowpay.automation.pages;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;

/**
 * FlowPay Appium — Home Page Object
 * Encapsulates all home screen / wallet dashboard interactions.
 */
public class HomePage extends BasePage {

    // ─── Locators ─────────────────────────────────────────────
    private static final By WALLET_BALANCE =
            By.xpath("//*[@content-desc='wallet_balance' or contains(@text,'₹') "
                   + "or contains(@text,'Balance')]");
    private static final By SEND_MONEY_BTN =
            By.xpath("//*[@content-desc='send_money' or @text='Send Money' "
                   + "or @text='Send']");
    private static final By SCAN_QR_BTN =
            By.xpath("//*[@content-desc='scan_qr' or @text='Scan QR' "
                   + "or @text='Scan']");
    private static final By PERSONAL_QR_BTN =
            By.xpath("//*[@content-desc='my_qr' or @text='My QR' "
                   + "or @text='Personal QR']");
    private static final By TRANSACTIONS_LIST =
            By.xpath("//*[@content-desc='transactions_list' or contains(@text,'Transaction')]");
    private static final By NOTIFICATIONS_ICON =
            By.xpath("//*[@content-desc='notifications' or contains(@resource-id,'notification')]");
    private static final By PROFILE_ICON =
            By.xpath("//*[@content-desc='profile' or @text='Profile']");
    private static final By SETTINGS_ICON =
            By.xpath("//*[@content-desc='settings' or @text='Settings']");
    private static final By ADD_MONEY_BTN =
            By.xpath("//*[@content-desc='add_money' or @text='Add Money' "
                   + "or @text='Top Up']");
    private static final By WITHDRAW_BTN =
            By.xpath("//*[@content-desc='withdraw' or @text='Withdraw' "
                   + "or @text='Withdraw to Bank']");
    private static final By GREETING_TEXT =
            By.xpath("//*[contains(@text,'Hello') or contains(@text,'Welcome') "
                   + "or contains(@text,'Good')]");
    private static final By BOTTOM_NAV_HOME =
            By.xpath("//*[@content-desc='Home' or @text='Home']");
    private static final By BOTTOM_NAV_HISTORY =
            By.xpath("//*[@content-desc='History' or @text='History' "
                   + "or @text='Transactions']");
    private static final By BOTTOM_NAV_PROFILE =
            By.xpath("//*[@content-desc='Profile' or @text='Profile' "
                   + "or @text='Account']");

    public HomePage(AndroidDriver driver) {
        super(driver);
        log.info("HomePage initialised");
    }

    // ─── Actions ──────────────────────────────────────────────

    /** Navigate to Send Money screen. */
    public void tapSendMoney() {
        log.info("Tapping Send Money");
        tap(SEND_MONEY_BTN);
    }

    /** Navigate to Scan QR screen. */
    public void tapScanQR() {
        log.info("Tapping Scan QR");
        tap(SCAN_QR_BTN);
    }

    /** Navigate to Personal QR screen. */
    public void tapPersonalQR() {
        log.info("Tapping Personal QR");
        tap(PERSONAL_QR_BTN);
    }

    /** Navigate to Notifications screen. */
    public void tapNotifications() {
        log.info("Tapping Notifications");
        tap(NOTIFICATIONS_ICON);
    }

    /** Navigate to Profile screen. */
    public void tapProfile() {
        log.info("Tapping Profile");
        tap(PROFILE_ICON);
    }

    /** Navigate to Settings screen. */
    public void tapSettings() {
        log.info("Tapping Settings");
        tap(SETTINGS_ICON);
    }

    /** Navigate to Add Money (Razorpay). */
    public void tapAddMoney() {
        log.info("Tapping Add Money");
        tap(ADD_MONEY_BTN);
    }

    /** Navigate to Withdraw to Bank. */
    public void tapWithdraw() {
        log.info("Tapping Withdraw");
        tap(WITHDRAW_BTN);
    }

    /** Tap bottom nav: Home */
    public void tapBottomNavHome() {
        tap(BOTTOM_NAV_HOME);
    }

    /** Tap bottom nav: History */
    public void tapBottomNavHistory() {
        tap(BOTTOM_NAV_HISTORY);
    }

    /** Tap bottom nav: Profile */
    public void tapBottomNavProfile() {
        tap(BOTTOM_NAV_PROFILE);
    }

    // ─── Queries ──────────────────────────────────────────────

    /** Check if home screen is fully loaded. */
    public boolean isHomeScreenLoaded() {
        sleep(3000);
        String source = getPageSource();
        return source != null && source.length() > 200;
    }

    /** Check if wallet balance is displayed. */
    public boolean isWalletBalanceVisible() {
        return isDisplayed(WALLET_BALANCE);
    }

    /** Get wallet balance text. */
    public String getWalletBalance() {
        return getText(WALLET_BALANCE);
    }

    /** Check if Send Money button is visible. */
    public boolean isSendMoneyVisible() {
        return isDisplayed(SEND_MONEY_BTN);
    }

    /** Check if Scan QR button is visible. */
    public boolean isScanQRVisible() {
        return isDisplayed(SCAN_QR_BTN);
    }

    /** Check if transactions list is visible. */
    public boolean isTransactionsListVisible() {
        return isDisplayed(TRANSACTIONS_LIST);
    }

    /** Check if greeting text is visible. */
    public boolean isGreetingVisible() {
        return isDisplayed(GREETING_TEXT);
    }

    /** Get greeting text. */
    public String getGreetingText() {
        return getText(GREETING_TEXT);
    }

    /** Check if Add Money button is visible. */
    public boolean isAddMoneyVisible() {
        return isDisplayed(ADD_MONEY_BTN);
    }

    /** Check if Withdraw button is visible. */
    public boolean isWithdrawVisible() {
        return isDisplayed(WITHDRAW_BTN);
    }

    /** Scroll down the transaction list. */
    public void scrollTransactions() {
        scrollDown();
    }

    /** Pull to refresh (scroll up from top). */
    public void pullToRefresh() {
        scrollUp();
        sleep(2000);
    }
}
