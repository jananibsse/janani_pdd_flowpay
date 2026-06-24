---

## 🌐 SELENIUM E2E TEST CASES (480 Tests)

### 🔐 Authentication Tests (40)
<details><summary>Click to view 40 authentication test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_AUTH_001 | Welcome page loads successfully |
| 2 | TC_AUTH_002 | Page title contains FlowPay |
| 3 | TC_AUTH_003 | Page loads within 3-second threshold |
| 4 | TC_AUTH_004 | Site is served over HTTPS |
| 5 | TC_AUTH_005 | Homepage returns valid content (no 404) |
| 6 | TC_AUTH_006 | Flutter web app initializes successfully |
| 7 | TC_AUTH_007 | No critical JS console errors on page load |
| 8 | TC_AUTH_008 | Page includes meta tags for SEO |
| 9 | TC_AUTH_009 | Website has a favicon |
| 10 | TC_AUTH_010 | Page has viewport meta tag for mobile |
| 11 | TC_AUTH_011 | Login page is accessible |
| 12 | TC_AUTH_012 | Login fails with empty email and password |
| 13 | TC_AUTH_013 | Login fails with invalid email format |
| 14 | TC_AUTH_014 | Login fails with valid email but wrong password |
| 15 | TC_AUTH_015 | Login fails with non-existent email |
| 16 | TC_AUTH_016 | Email field handles case variations |
| 17 | TC_AUTH_017 | Password field type is masked |
| 18 | TC_AUTH_018 | SQL injection payload rejected in email field |
| 19 | TC_AUTH_019 | XSS payload sanitized in email field |
| 20 | TC_AUTH_020 | Remember me functionality exists |
| 21 | TC_AUTH_021 | Registration page/screen is accessible |
| 22 | TC_AUTH_022 | Registration rejects existing email |
| 23 | TC_AUTH_023 | Weak password rejected during registration |
| 24 | TC_AUTH_024 | Password confirmation field mismatch rejected |
| 25 | TC_AUTH_025 | Registration validates email format |
| 26 | TC_AUTH_026 | Required fields cannot be empty |
| 27 | TC_AUTH_027 | Name field has proper length limits |
| 28 | TC_AUTH_028 | Phone number format validated |
| 29 | TC_AUTH_029 | Successful registration redirects to home |
| 30 | TC_AUTH_030 | Registration triggers confirmation email |
| 31 | TC_AUTH_031 | Logout properly clears user session |
| 32 | TC_AUTH_032 | Authenticated session persists on page refresh |
| 33 | TC_AUTH_033 | Unauthenticated users redirected from protected routes |
| 34 | TC_AUTH_034 | Firebase auth token is validated on each request |
| 35 | TC_AUTH_035 | Multiple failed login attempts handled gracefully |
| 36 | TC_AUTH_036 | Auth state management on browser session end |
| 37 | TC_AUTH_037 | Concurrent sessions handled correctly |
| 38 | TC_AUTH_038 | Firebase connection established on app load |
| 39 | TC_AUTH_039 | Password reset functionality is accessible |
| 40 | TC_AUTH_040 | Authentication error messages are user-friendly |
</details>

### 🛡️ Authorization Tests (30)
<details><summary>Click to view 30 authorization test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_AUTHZ_001 | Public pages accessible without login |
| 2 | TC_AUTHZ_002 | Dashboard requires authentication |
| 3 | TC_AUTHZ_003 | Wallet page requires authentication |
| 4 | TC_AUTHZ_004 | Profile page requires authentication |
| 5 | TC_AUTHZ_005 | Admin dashboard restricted to admin role |
| 6 | TC_AUTHZ_006 | Non-admin cannot access admin dashboard |
| 7 | TC_AUTHZ_007 | User cannot access other user's wallet |
| 8 | TC_AUTHZ_008 | Wallet PIN required for send money |
| 9 | TC_AUTHZ_009 | Wallet PIN required for bank transfer |
| 10 | TC_AUTHZ_010 | Session token required for API calls |
| 11 | TC_AUTHZ_011 | Expired session redirects to login |
| 12 | TC_AUTHZ_012 | Role-based navigation visibility |
| 13 | TC_AUTHZ_013 | IDOR protection on user profiles |
| 14 | TC_AUTHZ_014 | IDOR protection on transaction history |
| 15 | TC_AUTHZ_015 | Firebase rules enforce read permissions |
| 16 | TC_AUTHZ_016 | Firebase rules enforce write permissions |
| 17 | TC_AUTHZ_017 | Cross-user data isolation verified |
| 18 | TC_AUTHZ_018 | Admin can view all users |
| 19 | TC_AUTHZ_019 | Admin can view all transactions |
| 20 | TC_AUTHZ_020 | Admin can approve withdrawals |
| 21 | TC_AUTHZ_021 | Regular user cannot approve withdrawals |
| 22 | TC_AUTHZ_022 | QR code scan restricted to authenticated users |
| 23 | TC_AUTHZ_023 | Notification access scoped to own user |
| 24 | TC_AUTHZ_024 | Bank account linking restricted to owner |
| 25 | TC_AUTHZ_025 | Transaction details only visible to participants |
| 26 | TC_AUTHZ_026 | Logout invalidates all active tokens |
| 27 | TC_AUTHZ_027 | URL manipulation does not bypass auth |
| 28 | TC_AUTHZ_028 | Direct URL access to protected route redirects |
| 29 | TC_AUTHZ_029 | API response does not leak other users data |
| 30 | TC_AUTHZ_030 | Permission check on wallet withdrawal |
</details>

### 🧭 Navigation Tests (30)
<details><summary>Click to view 30 navigation test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_NAV_001 | Bottom navigation bar visible on home |
| 2 | TC_NAV_002 | Navigate to Dashboard screen |
| 3 | TC_NAV_003 | Navigate to Wallet screen |
| 4 | TC_NAV_004 | Navigate to Send Money screen |
| 5 | TC_NAV_005 | Navigate to Scan QR screen |
| 6 | TC_NAV_006 | Navigate to Profile screen |
| 7 | TC_NAV_007 | Navigate to Transaction History |
| 8 | TC_NAV_008 | Navigate to Notifications screen |
| 9 | TC_NAV_009 | Navigate to Personal QR screen |
| 10 | TC_NAV_010 | Navigate to Bank Account screen |
| 11 | TC_NAV_011 | Back button returns to previous screen |
| 12 | TC_NAV_012 | App logo navigates to home |
| 13 | TC_NAV_013 | Deep link to wallet screen |
| 14 | TC_NAV_014 | Deep link to transaction detail |
| 15 | TC_NAV_015 | Page refresh maintains current route |
| 16 | TC_NAV_016 | Bottom nav highlights active tab |
| 17 | TC_NAV_017 | Navigation transition animations smooth |
| 18 | TC_NAV_018 | Navigate to Add Money screen |
| 19 | TC_NAV_019 | Navigate to Withdraw screen |
| 20 | TC_NAV_020 | Navigate to Settings screen |
| 21 | TC_NAV_021 | Navigate to Help/Support screen |
| 22 | TC_NAV_022 | Navigate to Set Wallet PIN screen |
| 23 | TC_NAV_023 | Breadcrumb navigation works |
| 24 | TC_NAV_024 | Navigation state preserved on tab switch |
| 25 | TC_NAV_025 | Scroll position maintained on back |
| 26 | TC_NAV_026 | 404 page shown for invalid routes |
| 27 | TC_NAV_027 | Drawer/sidebar menu items functional |
| 28 | TC_NAV_028 | AuthGate redirects based on auth state |
| 29 | TC_NAV_029 | External link opens in new tab |
| 30 | TC_NAV_030 | Navigation loading indicators visible |
</details>

### 🎨 UI Validation Tests (40)
<details><summary>Click to view 40 UI validation test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_UI_001 | App renders Flutter canvas element |
| 2 | TC_UI_002 | Color scheme matches design spec |
| 3 | TC_UI_003 | Typography is consistent across pages |
| 4 | TC_UI_004 | Icons load correctly |
| 5 | TC_UI_005 | Loading spinner displayed during data fetch |
| 6 | TC_UI_006 | Empty state message shown when no data |
| 7 | TC_UI_007 | Currency values formatted with ₹ symbol |
| 8 | TC_UI_008 | Date/time values formatted correctly |
| 9 | TC_UI_009 | Wallet balance displayed prominently |
| 10 | TC_UI_010 | Transaction list renders correctly |
| 11 | TC_UI_011 | Credit transactions shown in green |
| 12 | TC_UI_012 | Debit transactions shown in red |
| 13 | TC_UI_013 | QR code renders correctly |
| 14 | TC_UI_014 | Profile avatar renders |
| 15 | TC_UI_015 | Notification badge shows unread count |
| 16 | TC_UI_016 | Buttons have proper hover states |
| 17 | TC_UI_017 | Input fields have labels and placeholders |
| 18 | TC_UI_018 | Error messages styled in red/warning color |
| 19 | TC_UI_019 | Success messages styled in green |
| 20 | TC_UI_020 | Modal/dialog overlays render correctly |
| 21 | TC_UI_021 | Card components have consistent styling |
| 22 | TC_UI_022 | Charts/graphs render on analytics page |
| 23 | TC_UI_023 | Footer content visible on scroll |
| 24 | TC_UI_024 | Image assets load without broken links |
| 25 | TC_UI_025 | Gradient backgrounds render properly |
| 26 | TC_UI_026 | Shadow/elevation effects visible |
| 27 | TC_UI_027 | Scrollable lists handle long content |
| 28 | TC_UI_028 | Pagination controls displayed when needed |
| 29 | TC_UI_029 | Snackbar/toast notifications appear |
| 30 | TC_UI_030 | Confirmation dialogs have Cancel/OK buttons |
| 31 | TC_UI_031 | Bank linked indicator visible on profile |
| 32 | TC_UI_032 | Transaction status chips styled correctly |
| 33 | TC_UI_033 | Withdrawal status badges render |
| 34 | TC_UI_034 | PIN entry screen masks digits |
| 35 | TC_UI_035 | Amount entry field shows numeric keyboard |
| 36 | TC_UI_036 | Search results highlight matched terms |
| 37 | TC_UI_037 | Form validation error positions correct |
| 38 | TC_UI_038 | Disabled buttons visually distinguished |
| 39 | TC_UI_039 | Pull-to-refresh indicator on mobile view |
| 40 | TC_UI_040 | Dark/light mode elements contrast correct |
</details>

### 📝 Forms Tests (40)
<details><summary>Click to view 40 forms test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_FORM_001 | Login form has email field |
| 2 | TC_FORM_002 | Login form has password field |
| 3 | TC_FORM_003 | Login form has submit button |
| 4 | TC_FORM_004 | Registration form has name field |
| 5 | TC_FORM_005 | Registration form has phone field |
| 6 | TC_FORM_006 | Send Money form has amount field |
| 7 | TC_FORM_007 | Send Money form has recipient field |
| 8 | TC_FORM_008 | Send Money form validates minimum amount |
| 9 | TC_FORM_009 | Send Money form validates maximum amount |
| 10 | TC_FORM_010 | Add Money form has amount input |
| 11 | TC_FORM_011 | Bank linking form has account holder name |
| 12 | TC_FORM_012 | Bank linking form has IFSC code field |
| 13 | TC_FORM_013 | Bank linking form has account number field |
| 14 | TC_FORM_014 | Bank linking form has UPI ID field |
| 15 | TC_FORM_015 | Profile edit form pre-populates data |
| 16 | TC_FORM_016 | Withdrawal form has amount field |
| 17 | TC_FORM_017 | Withdrawal form validates bank linked |
| 18 | TC_FORM_018 | PIN setup form accepts 4-6 digit PIN |
| 19 | TC_FORM_019 | PIN setup form has confirm PIN field |
| 20 | TC_FORM_020 | PIN verification form masks input |
| 21 | TC_FORM_021 | Form clears on successful submission |
| 22 | TC_FORM_022 | Form retains data on validation failure |
| 23 | TC_FORM_023 | Tab key moves between form fields |
| 24 | TC_FORM_024 | Enter key submits focused form |
| 25 | TC_FORM_025 | Required field asterisk indicator shown |
| 26 | TC_FORM_026 | Dropdown selector renders options |
| 27 | TC_FORM_027 | Date picker widget functional |
| 28 | TC_FORM_028 | Radio button selection works |
| 29 | TC_FORM_029 | Checkbox toggle works |
| 30 | TC_FORM_030 | File upload field renders (if applicable) |
| 31 | TC_FORM_031 | Auto-complete suggestions appear |
| 32 | TC_FORM_032 | Form cancel button discards changes |
| 33 | TC_FORM_033 | Multi-step form wizard navigable |
| 34 | TC_FORM_034 | Form loading state on submit |
| 35 | TC_FORM_035 | Duplicate form submission prevented |
| 36 | TC_FORM_036 | Form validation runs on blur |
| 37 | TC_FORM_037 | Form validation runs on submit |
| 38 | TC_FORM_038 | Inline validation messages displayed |
| 39 | TC_FORM_039 | Character counter on limited fields |
| 40 | TC_FORM_040 | Form accessible via keyboard-only navigation |
</details>

### 🗄️ CRUD Tests (40)
<details><summary>Click to view 40 CRUD test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_CRUD_001 | Create wallet for new user |
| 2 | TC_CRUD_002 | Read wallet balance |
| 3 | TC_CRUD_003 | Update profile information |
| 4 | TC_CRUD_004 | Delete notification |
| 5 | TC_CRUD_005 | Create wallet transaction (add money) |
| 6 | TC_CRUD_006 | Read transaction history list |
| 7 | TC_CRUD_007 | Read single transaction detail |
| 8 | TC_CRUD_008 | Create payment transaction (send money) |
| 9 | TC_CRUD_009 | Read payment transaction status |
| 10 | TC_CRUD_010 | Create bank account link |
| 11 | TC_CRUD_011 | Read linked bank account details |
| 12 | TC_CRUD_012 | Update bank account details |
| 13 | TC_CRUD_013 | Delete/unlink bank account |
| 14 | TC_CRUD_014 | Create withdrawal request |
| 15 | TC_CRUD_015 | Read withdrawal request status |
| 16 | TC_CRUD_016 | Update withdrawal request (admin approve) |
| 17 | TC_CRUD_017 | Read user profile data |
| 18 | TC_CRUD_018 | Update display name |
| 19 | TC_CRUD_019 | Update phone number |
| 20 | TC_CRUD_020 | Create notification on money received |
| 21 | TC_CRUD_021 | Read notifications list |
| 22 | TC_CRUD_022 | Update notification read status |
| 23 | TC_CRUD_023 | Create QR payment payload |
| 24 | TC_CRUD_024 | Read QR payment payload (scan) |
| 25 | TC_CRUD_025 | Transfer wallet to bank (create transfer) |
| 26 | TC_CRUD_026 | Transfer bank to wallet (create transfer) |
| 27 | TC_CRUD_027 | Read bank balance |
| 28 | TC_CRUD_028 | Create Razorpay add money transaction |
| 29 | TC_CRUD_029 | Read Razorpay transaction status |
| 30 | TC_CRUD_030 | Create offline pending transaction |
| 31 | TC_CRUD_031 | Read pending offline transactions |
| 32 | TC_CRUD_032 | Delete synced offline transaction |
| 33 | TC_CRUD_033 | Create wallet PIN |
| 34 | TC_CRUD_034 | Update wallet PIN |
| 35 | TC_CRUD_035 | Read wallet PIN hash (verification) |
| 36 | TC_CRUD_036 | List all users (admin) |
| 37 | TC_CRUD_037 | Search user by email |
| 38 | TC_CRUD_038 | Search user by phone number |
| 39 | TC_CRUD_039 | Read analytics summary |
| 40 | TC_CRUD_040 | Read weekly spending chart data |
</details>

### ✏️ Input Validation Tests (40)
<details><summary>Click to view 40 input validation test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_INP_001 | Email field rejects empty input |
| 2 | TC_INP_002 | Email field rejects no @ symbol |
| 3 | TC_INP_003 | Email field rejects no domain |
| 4 | TC_INP_004 | Email field accepts valid format |
| 5 | TC_INP_005 | Password field rejects < 6 characters |
| 6 | TC_INP_006 | Password field accepts ≥ 6 characters |
| 7 | TC_INP_007 | Phone field rejects non-numeric input |
| 8 | TC_INP_008 | Phone field rejects < 10 digits |
| 9 | TC_INP_009 | Phone field accepts valid 10-digit number |
| 10 | TC_INP_010 | Amount field rejects zero |
| 11 | TC_INP_011 | Amount field rejects negative values |
| 12 | TC_INP_012 | Amount field rejects alphabetic input |
| 13 | TC_INP_013 | Amount field accepts decimal values |
| 14 | TC_INP_014 | Amount field enforces maximum limit |
| 15 | TC_INP_015 | Name field rejects empty input |
| 16 | TC_INP_016 | Name field rejects > 255 characters |
| 17 | TC_INP_017 | IFSC code validates 11-character format |
| 18 | TC_INP_018 | UPI ID validates user@bank format |
| 19 | TC_INP_019 | Account number rejects special characters |
| 20 | TC_INP_020 | PIN field rejects < 4 digits |
| 21 | TC_INP_021 | PIN field rejects > 6 digits |
| 22 | TC_INP_022 | PIN field rejects alphabetic input |
| 23 | TC_INP_023 | PIN confirm must match PIN |
| 24 | TC_INP_024 | SQL injection payload in search field |
| 25 | TC_INP_025 | XSS payload in name field |
| 26 | TC_INP_026 | Script injection in message field |
| 27 | TC_INP_027 | Unicode characters in name field |
| 28 | TC_INP_028 | Emoji characters in input fields |
| 29 | TC_INP_029 | Leading/trailing whitespace trimmed |
| 30 | TC_INP_030 | Very long input handled gracefully |
| 31 | TC_INP_031 | Copy-paste into fields works |
| 32 | TC_INP_032 | Number-only keyboard for phone fields |
| 33 | TC_INP_033 | Decimal keyboard for amount fields |
| 34 | TC_INP_034 | Auto-format phone number display |
| 35 | TC_INP_035 | Real-time validation feedback |
| 36 | TC_INP_036 | Null byte injection handled |
| 37 | TC_INP_037 | HTML tags stripped from inputs |
| 38 | TC_INP_038 | Maximum file size enforced (uploads) |
| 39 | TC_INP_039 | MIME type validation on uploads |
| 40 | TC_INP_040 | Double submit prevention |
</details>

### ⚠️ Error Handling Tests (30)
<details><summary>Click to view 30 error handling test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_ERR_001 | Network timeout shows friendly error |
| 2 | TC_ERR_002 | Server 500 error shows retry option |
| 3 | TC_ERR_003 | Firebase unavailable shows offline message |
| 4 | TC_ERR_004 | Insufficient balance shows clear message |
| 5 | TC_ERR_005 | Invalid recipient shows error |
| 6 | TC_ERR_006 | Self-transfer prevented with message |
| 7 | TC_ERR_007 | Bank not linked error on transfer |
| 8 | TC_ERR_008 | PIN not set error on verify attempt |
| 9 | TC_ERR_009 | Wrong PIN shows retry message |
| 10 | TC_ERR_010 | Razorpay failure shows error description |
| 11 | TC_ERR_011 | Duplicate transaction prevented |
| 12 | TC_ERR_012 | Session expired shows re-login prompt |
| 13 | TC_ERR_013 | Invalid QR code data handled |
| 14 | TC_ERR_014 | Camera permission denied handled |
| 15 | TC_ERR_015 | Empty transaction list shows empty state |
| 16 | TC_ERR_016 | 404 page renders for unknown routes |
| 17 | TC_ERR_017 | Form validation errors displayed inline |
| 18 | TC_ERR_018 | Concurrent modification conflict handled |
| 19 | TC_ERR_019 | Rate limiting message displayed |
| 20 | TC_ERR_020 | Connection restored notification shown |
| 21 | TC_ERR_021 | Graceful degradation offline mode |
| 22 | TC_ERR_022 | Auth error messages are user-friendly |
| 23 | TC_ERR_023 | Stack trace not exposed to user |
| 24 | TC_ERR_024 | Error boundary catches widget crashes |
| 25 | TC_ERR_025 | API error response codes handled |
| 26 | TC_ERR_026 | Withdrawal rejection shows reason |
| 27 | TC_ERR_027 | Bank transfer failure rollback message |
| 28 | TC_ERR_028 | Notification fetch failure silent |
| 29 | TC_ERR_029 | Image load failure shows placeholder |
| 30 | TC_ERR_030 | Malformed JSON response handled |
</details>

### 🔄 Session Management Tests (20)
<details><summary>Click to view 20 session management test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_SESS_001 | Session created on login |
| 2 | TC_SESS_002 | Session persists across page refresh |
| 3 | TC_SESS_003 | Session expires after timeout |
| 4 | TC_SESS_004 | Logout destroys session |
| 5 | TC_SESS_005 | Multiple tabs share session |
| 6 | TC_SESS_006 | Session restored from localStorage |
| 7 | TC_SESS_007 | Firebase auth token auto-refresh |
| 8 | TC_SESS_008 | Concurrent session on different devices |
| 9 | TC_SESS_009 | Session data not in URL parameters |
| 10 | TC_SESS_010 | Cookie flags set correctly (HttpOnly, Secure) |
| 11 | TC_SESS_011 | AuthGate redirects unauthenticated users |
| 12 | TC_SESS_012 | AuthGate allows authenticated users |
| 13 | TC_SESS_013 | Token not stored in plain text |
| 14 | TC_SESS_014 | Auth state listener fires on changes |
| 15 | TC_SESS_015 | Login updates user context globally |
| 16 | TC_SESS_016 | Logout clears cached user data |
| 17 | TC_SESS_017 | Re-login after session expiry works |
| 18 | TC_SESS_018 | Cross-tab logout synchronization |
| 19 | TC_SESS_019 | Session resilient to clock skew |
| 20 | TC_SESS_020 | Invalid token triggers re-authentication |
</details>

### ♿ Accessibility Tests (20)
<details><summary>Click to view 20 accessibility test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_A11Y_001 | Page has proper heading hierarchy |
| 2 | TC_A11Y_002 | Images have alt text |
| 3 | TC_A11Y_003 | Form fields have associated labels |
| 4 | TC_A11Y_004 | Color contrast meets WCAG AA |
| 5 | TC_A11Y_005 | Focus indicators visible on tab |
| 6 | TC_A11Y_006 | Keyboard navigation functional |
| 7 | TC_A11Y_007 | Screen reader aria-labels present |
| 8 | TC_A11Y_008 | Skip to content link present |
| 9 | TC_A11Y_009 | Language attribute set on HTML |
| 10 | TC_A11Y_010 | Error messages announced to screen readers |
| 11 | TC_A11Y_011 | No auto-playing media |
| 12 | TC_A11Y_012 | Touch targets minimum 44×44px |
| 13 | TC_A11Y_013 | Text resizable up to 200% |
| 14 | TC_A11Y_014 | Semantic HTML elements used |
| 15 | TC_A11Y_015 | ARIA roles properly assigned |
| 16 | TC_A11Y_016 | Focus trap in modal dialogs |
| 17 | TC_A11Y_017 | Reduced motion preference respected |
| 18 | TC_A11Y_018 | Content readable without CSS |
| 19 | TC_A11Y_019 | Links distinguishable from text |
| 20 | TC_A11Y_020 | Tab order follows visual layout |
</details>

### 📱 Responsive Design Tests (40)
<details><summary>Click to view 40 responsive design test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_RES_001 | Layout correct at 1920×1080 (Desktop) |
| 2 | TC_RES_002 | Layout correct at 1366×768 (Laptop) |
| 3 | TC_RES_003 | Layout correct at 768×1024 (Tablet Portrait) |
| 4 | TC_RES_004 | Layout correct at 1024×768 (Tablet Landscape) |
| 5 | TC_RES_005 | Layout correct at 375×812 (iPhone X) |
| 6 | TC_RES_006 | Layout correct at 360×640 (Android) |
| 7 | TC_RES_007 | Layout correct at 414×896 (iPhone XR) |
| 8 | TC_RES_008 | Layout correct at 320×568 (iPhone SE) |
| 9 | TC_RES_009 | No horizontal scroll on mobile |
| 10 | TC_RES_010 | Navigation collapses on small screens |
| 11 | TC_RES_011 | Text readable without zoom on mobile |
| 12 | TC_RES_012 | Buttons large enough to tap on mobile |
| 13 | TC_RES_013 | Images scale proportionally |
| 14 | TC_RES_014 | Forms usable on small screens |
| 15 | TC_RES_015 | Cards stack vertically on mobile |
| 16 | TC_RES_016 | Tables scroll horizontally if needed |
| 17 | TC_RES_017 | Modal dialogs fit small screens |
| 18 | TC_RES_018 | Orientation change handled (portrait ↔ landscape) |
| 19 | TC_RES_019 | Font sizes scale with viewport |
| 20 | TC_RES_020 | Touch targets meet minimum 48px |
| 21 | TC_RES_021 | Charts/graphs responsive |
| 22 | TC_RES_022 | QR code visible and scannable on mobile |
| 23 | TC_RES_023 | Login form centered on all viewports |
| 24 | TC_RES_024 | Wallet balance card responsive |
| 25 | TC_RES_025 | Transaction list readable on mobile |
| 26 | TC_RES_026 | Profile page responsive layout |
| 27 | TC_RES_027 | Admin dashboard responsive grid |
| 28 | TC_RES_028 | Notification panel responsive |
| 29 | TC_RES_029 | Footer responsive on all sizes |
| 30 | TC_RES_030 | Sidebar/drawer responsive behavior |
| 31 | TC_RES_031 | Viewport meta tag prevents zoom issues |
| 32 | TC_RES_032 | Flexbox/Grid layout no overflow |
| 33 | TC_RES_033 | Analytics charts resize on window change |
| 34 | TC_RES_034 | PIN entry pad fits mobile screens |
| 35 | TC_RES_035 | Camera/QR scanner fullscreen on mobile |
| 36 | TC_RES_036 | Bottom sheet usable on small screens |
| 37 | TC_RES_037 | Keyboard doesn't obscure form fields |
| 38 | TC_RES_038 | Spacing consistent across breakpoints |
| 39 | TC_RES_039 | Icon sizes appropriate per viewport |
| 40 | TC_RES_040 | Print layout clean and readable |
</details>

### ⚡ Performance Smoke Tests (30)
<details><summary>Click to view 30 performance test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_PERF_001 | Homepage loads within 3 seconds |
| 2 | TC_PERF_002 | Time to First Byte < 1.5 seconds |
| 3 | TC_PERF_003 | Flutter engine initializes < 5 seconds |
| 4 | TC_PERF_004 | Dashboard data loads < 2 seconds |
| 5 | TC_PERF_005 | Wallet balance fetch < 1 second |
| 6 | TC_PERF_006 | Transaction list renders < 2 seconds |
| 7 | TC_PERF_007 | Page size under 5 MB total |
| 8 | TC_PERF_008 | No render-blocking resources |
| 9 | TC_PERF_009 | Images optimized and compressed |
| 10 | TC_PERF_010 | JavaScript bundle size reasonable |
| 11 | TC_PERF_011 | CSS bundle size reasonable |
| 12 | TC_PERF_012 | No memory leaks on navigation |
| 13 | TC_PERF_013 | Smooth scroll at 60fps |
| 14 | TC_PERF_014 | Animation jank-free on transitions |
| 15 | TC_PERF_015 | Search results return < 1 second |
| 16 | TC_PERF_016 | QR code generation < 500ms |
| 17 | TC_PERF_017 | Notification fetch < 1 second |
| 18 | TC_PERF_018 | Profile page load < 2 seconds |
| 19 | TC_PERF_019 | Concurrent API calls handled |
| 20 | TC_PERF_020 | Cache headers set correctly |
| 21 | TC_PERF_021 | Gzip compression enabled |
| 22 | TC_PERF_022 | Static assets CDN-delivered |
| 23 | TC_PERF_023 | Font loading does not block render |
| 24 | TC_PERF_024 | Lazy loading for off-screen images |
| 25 | TC_PERF_025 | Service worker caches static assets |
| 26 | TC_PERF_026 | API responses under 500ms average |
| 27 | TC_PERF_027 | No excessive DOM nodes (< 1500) |
| 28 | TC_PERF_028 | Third-party scripts do not block |
| 29 | TC_PERF_029 | Lighthouse performance score > 60 |
| 30 | TC_PERF_030 | No layout shifts during load (CLS < 0.1) |
</details>

### 🔁 Regression Tests (50)
<details><summary>Click to view 50 regression test cases</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_REG_001 | Login → Dashboard → Wallet flow works |
| 2 | TC_REG_002 | Register → Auto-login → Dashboard flow |
| 3 | TC_REG_003 | Add money → Check balance updated |
| 4 | TC_REG_004 | Send money → Sender balance reduced |
| 5 | TC_REG_005 | Send money → Receiver balance increased |
| 6 | TC_REG_006 | Send money → Transaction history updated |
| 7 | TC_REG_007 | Send money → Notification received by both |
| 8 | TC_REG_008 | Link bank → Verify bank details shown |
| 9 | TC_REG_009 | Transfer wallet→bank → Both balances updated |
| 10 | TC_REG_010 | Transfer bank→wallet → Both balances updated |
| 11 | TC_REG_011 | Set PIN → Verify PIN works |
| 12 | TC_REG_012 | Change PIN → Old PIN rejected |
| 13 | TC_REG_013 | Withdraw → Pending status shown |
| 14 | TC_REG_014 | Admin approve withdrawal → Status updated |
| 15 | TC_REG_015 | Generate QR → Scan QR → Payment flow |
| 16 | TC_REG_016 | Logout → Protected routes inaccessible |
| 17 | TC_REG_017 | Password reset → Login with new password |
| 18 | TC_REG_018 | Update profile → Changes reflected |
| 19 | TC_REG_019 | Notifications mark as read → Badge updated |
| 20 | TC_REG_020 | Offline transaction → Sync on reconnect |
| 21 | TC_REG_021 | Multiple sends → Correct running balance |
| 22 | TC_REG_022 | Razorpay success → Balance incremented |
| 23 | TC_REG_023 | Razorpay failure → Balance unchanged |
| 24 | TC_REG_024 | Analytics reflect real transaction data |
| 25 | TC_REG_025 | Weekly chart data matches transactions |
| 26 | TC_REG_026 | Login after app update → Data preserved |
| 27 | TC_REG_027 | Browser back button → Expected behavior |
| 28 | TC_REG_028 | Page refresh → State maintained |
| 29 | TC_REG_029 | Concurrent users → No data corruption |
| 30 | TC_REG_030 | Edge case: Send exact balance (zero remaining) |
| 31 | TC_REG_031 | Edge case: Very small amount (₹0.01) |
| 32 | TC_REG_032 | Edge case: Very large amount (₹99,999) |
| 33 | TC_REG_033 | Edge case: Rapid consecutive sends |
| 34 | TC_REG_034 | Edge case: Unicode in transaction description |
| 35 | TC_REG_035 | Edge case: Multiple browser tabs |
| 36 | TC_REG_036 | Cross-browser: Chrome functionality |
| 37 | TC_REG_037 | Cross-browser: Firefox functionality |
| 38 | TC_REG_038 | Cross-browser: Safari functionality |
| 39 | TC_REG_039 | Cross-browser: Edge functionality |
| 40 | TC_REG_040 | Mobile browser: Chrome Android |
| 41 | TC_REG_041 | Mobile browser: Safari iOS |
| 42 | TC_REG_042 | Wallet creation on first login |
| 43 | TC_REG_043 | Transaction filtering by date works |
| 44 | TC_REG_044 | Transaction filtering by type works |
| 45 | TC_REG_045 | Search by phone number returns user |
| 46 | TC_REG_046 | Search by email returns user |
| 47 | TC_REG_047 | Unlink bank → Bank features disabled |
| 48 | TC_REG_048 | Re-link different bank → Updated details |
| 49 | TC_REG_049 | Email notifications sent on key actions |
| 50 | TC_REG_050 | End-to-end: Full payment lifecycle |
</details>

---

## 🧪 FLUTTER UNIT TEST CASES (311 Tests)

### 🔐 AuthService Tests (50)
<details><summary>Click to expand 50 auth tests</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_AUTH_001 | Initial user is null when not signed in |
| 2 | TC_AUTH_002 | Sign in with valid email and password returns user |
| 3 | TC_AUTH_003 | Sign in trims email whitespace |
| 4 | TC_AUTH_004 | Sign in returns UserCredential with correct uid |
| 5 | TC_AUTH_005 | Sign in updates currentFirebaseUser |
| 6 | TC_AUTH_006 | Sign in with empty email still calls Firebase |
| 7 | TC_AUTH_007 | Sign in with empty password still calls Firebase |
| 8 | TC_AUTH_008 | Multiple sign-in calls do not throw |
| 9 | TC_AUTH_009 | currentUser returns AppUser with correct email |
| 10 | TC_AUTH_010 | currentUser returns AppUser with correct displayName |
| 11 | TC_AUTH_011 | Register with valid credentials creates user |
| 12 | TC_AUTH_012 | Register trims email whitespace |
| 13 | TC_AUTH_013 | Register returns UserCredential |
| 14 | TC_AUTH_014 | Register then currentUser is not null |
| 15 | TC_AUTH_015 | Register with special characters in email |
| 16 | TC_AUTH_016 | Sign out clears the current user |
| 17 | TC_AUTH_017 | Sign out clears currentFirebaseUser to null |
| 18 | TC_AUTH_018 | Sign out when already signed out does not throw |
| 19 | TC_AUTH_019 | Sign out then currentUser returns null |
| 20 | TC_AUTH_020 | Double sign-out does not throw |
| 21 | TC_AUTH_021 | invalid-email returns friendly message |
| 22 | TC_AUTH_022 | user-disabled returns friendly message |
| 23 | TC_AUTH_023 | user-not-found returns friendly message |
| 24 | TC_AUTH_024 | wrong-password returns friendly message |
| 25 | TC_AUTH_025 | email-already-in-use returns friendly message |
| 26 | TC_AUTH_026 | weak-password returns friendly message |
| 27 | TC_AUTH_027 | invalid-credential returns friendly message |
| 28 | TC_AUTH_028 | operation-not-allowed returns friendly message |
| 29 | TC_AUTH_029 | unknown code with message uses that message |
| 30 | TC_AUTH_030 | unknown code without message uses default |
| 31 | TC_AUTH_031 | AppUser.fromFirebaseUser maps uid correctly |
| 32 | TC_AUTH_032 | AppUser.fromFirebaseUser maps email correctly |
| 33 | TC_AUTH_033 | AppUser.fromFirebaseUser maps displayName correctly |
| 34 | TC_AUTH_034 | AppUser handles null displayName |
| 35 | TC_AUTH_035 | AppUser constructor works with named params |
| 36 | TC_AUTH_036 | AppUser with null email |
| 37 | TC_AUTH_037 | AppUser with null displayName |
| 38 | TC_AUTH_038 | authStateChanges emits null when not signed in |
| 39 | TC_AUTH_039 | authStateChanges emits user when signed in |
| 40 | TC_AUTH_040 | Login then logout then login works |
| 41 | TC_AUTH_041 | AuthService can be created with no params |
| 42 | TC_AUTH_042 | AuthService with explicit FirebaseAuth instance |
| 43 | TC_AUTH_043 | currentFirebaseUser returns User type |
| 44 | TC_AUTH_044 | currentUser returns AppUser type |
| 45 | TC_AUTH_045 | Register then sign out then sign in |
| 46 | TC_AUTH_046 | Very long email is accepted |
| 47 | TC_AUTH_047 | Very long password is accepted |
| 48 | TC_AUTH_048 | Unicode email characters handled |
| 49 | TC_AUTH_049 | Unicode password characters handled |
| 50 | TC_AUTH_050 | Multiple AuthService instances share FirebaseAuth |
</details>

### 💰 WalletService Tests (100)
<details><summary>Click to expand 100 wallet tests</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_WAL_001 | createUserWallet creates doc with initial balance 1000 |
| 2 | TC_WAL_002 | createUserWallet stores email |
| 3 | TC_WAL_003 | createUserWallet stores phone |
| 4 | TC_WAL_004 | createUserWallet trims email |
| 5 | TC_WAL_005 | createUserWallet trims phone |
| 6 | TC_WAL_006 | createUserWallet stores uid field |
| 7 | TC_WAL_007 | ensureWalletExists creates wallet if not exist |
| 8 | TC_WAL_008 | ensureWalletExists does not overwrite existing |
| 9 | TC_WAL_009 | getUserIdByEmail returns uid for existing email |
| 10 | TC_WAL_010 | getUserIdByEmail returns null for non-existent |
| 11–20 | TC_WAL_011–020 | Wallet creation edge cases (trim, unicode, defaults) |
| 21–35 | TC_WAL_021–035 | Add money: balance increment, transactions, notifications, edge cases |
| 36–60 | TC_WAL_036–060 | Send money: deduction, credit, self-transfer block, insufficient balance |
| 61–75 | TC_WAL_061–075 | PIN hashing: SHA-256, deterministic, set/verify, edge cases |
| 76–90 | TC_WAL_076–090 | Bank transfers: wallet→bank, bank→wallet, linked check, notifications |
| 91–100 | TC_WAL_091–100 | Razorpay: success/failure balance, transactions, notifications |
</details>

### 🔔 NotificationService Tests (50)
<details><summary>Click to expand 50 notification tests</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1 | TC_NOTIF_001 | notifyMoneyAdded creates notification |
| 2 | TC_NOTIF_002 | notifyMoneyAdded has type add_money |
| 3 | TC_NOTIF_003 | notifyMoneyAdded title is Money Added |
| 4 | TC_NOTIF_004 | notifyMoneyAdded message contains formatted amount |
| 5 | TC_NOTIF_005 | notifyMoneyAdded read defaults to false |
| 6–10 | TC_NOTIF_006–010 | Payment Sent notifications (type, title, amount, phone) |
| 11–15 | TC_NOTIF_011–015 | Payment Received notifications |
| 16–21 | TC_NOTIF_016–021 | Bank Linked & Updated notifications |
| 22–27 | TC_NOTIF_022–027 | Transfer to/from bank notifications |
| 28–33 | TC_NOTIF_028–033 | Withdrawal notifications (submitted, approved, rejected) |
| 34–37 | TC_NOTIF_034–037 | Razorpay success/failure notifications |
| 38–39 | TC_NOTIF_038–039 | Offline sync notifications |
| 40–50 | TC_NOTIF_040–050 | Read/unread, streams, isolation, formatting |
</details>

### 📴 OfflineTransactionService Tests (50)
<details><summary>Click to expand 50 offline tests</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1–15 | TC_OFL_001–015 | Queue management: save, get, remove, ordering, uniqueness |
| 16–30 | TC_OFL_016–030 | Sync: empty queue, wallet-to-wallet, receiver not found, exceptions |
| 31–50 | TC_OFL_031–050 | Model: create, toJson, fromJson, round-trip, constants, edge cases |
</details>

### 📦 Data Models Tests (60)
<details><summary>Click to expand 60 model tests</summary>

| # | Test ID | Test Name |
|---|---------|-----------|
| 1–5 | TC_MDL_001–005 | BankAccount: fromFirestore, defaults, toMap, timestamps |
| 6–15 | TC_MDL_006–015 | WalletUser: fromFirestore, defaults, bank fields, PIN, balance |
| 16–30 | TC_MDL_016–030 | WalletTransaction: amount, type, isCredit, typeLabel, direction |
| 31–35 | TC_MDL_031–035 | PaymentTransaction: fromFirestore, isSentBy, isReceivedBy |
| 36–50 | TC_MDL_036–050 | QrPaymentPayload: fromJson, toJson, encode, tryParse, round-trip |
| 51–60 | TC_MDL_051–060 | WalletAnalyticsSummary: hasData, totalSent, totalReceived, netFlow |
</details>
