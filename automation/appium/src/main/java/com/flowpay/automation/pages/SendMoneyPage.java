package com.flowpay.automation.pages;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.By;

/**
 * FlowPay Appium — Send Money Page Object
 * Encapsulates all send money / payment screen interactions.
 */
public class SendMoneyPage extends BasePage {

    private static final By RECIPIENT_FIELD =
            By.xpath("//*[@content-desc='recipient_field' or contains(@hint,'Recipient') "
                   + "or contains(@text,'Email') or contains(@text,'Phone')]");
    private static final By AMOUNT_FIELD =
            By.xpath("//*[@content-desc='amount_field' or contains(@hint,'Amount') "
                   + "or contains(@resource-id,'amount')]");
    private static final By NOTE_FIELD =
            By.xpath("//*[@content-desc='note_field' or contains(@hint,'Note') "
                   + "or contains(@hint,'Description')]");
    private static final By SEND_BUTTON =
            By.xpath("//*[@content-desc='send_button' or @text='Send' "
                   + "or @text='SEND' or @text='Pay']");
    private static final By CONFIRM_BUTTON =
            By.xpath("//*[@content-desc='confirm_button' or @text='Confirm' "
                   + "or @text='CONFIRM']");
    private static final By CANCEL_BUTTON =
            By.xpath("//*[@content-desc='cancel_button' or @text='Cancel']");
    private static final By SUCCESS_MESSAGE =
            By.xpath("//*[contains(@text,'Success') or contains(@text,'success') "
                   + "or contains(@text,'sent')]");
    private static final By ERROR_MESSAGE =
            By.xpath("//*[contains(@text,'error') or contains(@text,'Error') "
                   + "or contains(@text,'insufficient') or contains(@text,'failed')]");
    private static final By BALANCE_DISPLAY =
            By.xpath("//*[contains(@text,'Balance') or contains(@text,'₹')]");
    private static final By PIN_INPUT =
            By.xpath("//*[@content-desc='pin_input' or contains(@resource-id,'pin')]");

    public SendMoneyPage(AndroidDriver driver) {
        super(driver);
        log.info("SendMoneyPage initialised");
    }

    // ─── Actions ──────────────────────────────────────────────

    public SendMoneyPage enterRecipient(String recipient) {
        log.info("Entering recipient: {}", recipient);
        typeText(RECIPIENT_FIELD, recipient);
        return this;
    }

    public SendMoneyPage enterAmount(String amount) {
        log.info("Entering amount: {}", amount);
        typeText(AMOUNT_FIELD, amount);
        return this;
    }

    public SendMoneyPage enterNote(String note) {
        log.info("Entering note: {}", note);
        typeText(NOTE_FIELD, note);
        return this;
    }

    public void tapSend() {
        log.info("Tapping Send");
        hideKeyboard();
        tap(SEND_BUTTON);
    }

    public void tapConfirm() {
        log.info("Tapping Confirm");
        tap(CONFIRM_BUTTON);
    }

    public void tapCancel() {
        log.info("Tapping Cancel");
        tap(CANCEL_BUTTON);
    }

    public void enterPin(String pin) {
        log.info("Entering PIN");
        typeText(PIN_INPUT, pin);
    }

    /** Full send money flow. */
    public void sendMoney(String recipient, String amount, String note) {
        enterRecipient(recipient).enterAmount(amount).enterNote(note);
        hideKeyboard();
        tapSend();
    }

    // ─── Queries ──────────────────────────────────────────────

    public boolean isRecipientFieldVisible() { return isDisplayed(RECIPIENT_FIELD); }
    public boolean isAmountFieldVisible()    { return isDisplayed(AMOUNT_FIELD); }
    public boolean isSendButtonVisible()     { return isDisplayed(SEND_BUTTON); }
    public boolean isSuccessMessageVisible() { return isDisplayed(SUCCESS_MESSAGE); }
    public boolean isErrorMessageVisible()   { return isDisplayed(ERROR_MESSAGE); }
    public String  getErrorMessage()         { return getText(ERROR_MESSAGE); }
    public String  getSuccessMessage()       { return getText(SUCCESS_MESSAGE); }
    public boolean isBalanceVisible()        { return isDisplayed(BALANCE_DISPLAY); }
    public String  getBalanceText()          { return getText(BALANCE_DISPLAY); }

    public boolean isSendMoneyPageLoaded() {
        sleep(3000);
        return getPageSource() != null && getPageSource().length() > 200;
    }
}
