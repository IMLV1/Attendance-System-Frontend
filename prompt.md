# Bug Fixes 1: Checkin Page

## 1. Replace unreliable time source
The Checkin page currently fetches the current time from an external API before allowing check-in. This API is sometimes slow, causing timeouts — when this happens, the UI shows a "refresh" button and blocks the user.

**Fix:** Remove the dependency on this external time API. Use the server's own timestamp (generated when the backend receives the check-in request) instead of round-tripping to a third-party time API. If a client-side timestamp is needed for display purposes only, use the device's local clock, but the authoritative time used for the actual check-in record must come from the backend.

## 2. Fix mobile layout overflow
On mobile screens, the Checkin page content overflows the viewport height, forcing the user to scroll down to reach the "View History" button.

**Fix:** Adjust the mobile layout (spacing, font sizes, component heights) so all key elements — including the "View History" button — are visible within the initial viewport without scrolling.

## 3. Move success/error feedback inline
Currently, clicking "Check In" triggers a toast/popup message at the bottom of the screen to indicate success or failure.

**Fix:** Remove the popup. Instead, show inline text directly below the "Check In" button:
- Success → green text with the success message
- Failure → red text with the error message

## 4. Show accurate backend errors and prevent false-success UI updates
Two related issues:
- When the backend returns an error, the frontend does not display the actual backend error message (it shows a generic or incorrect message instead, per item #3's fix, this should now render as red inline text).
- More critically, when the backend responds with an error, the frontend still updates the UI as if the check-in succeeded (e.g., updates check-in status/state) when it should not.

**Fix:**
- Parse the backend response and display the exact error message returned by the backend as the red inline error text.
- Only update frontend state (check-in status, history, etc.) when the backend response indicates success. On error, leave the UI/state unchanged and show only the error message.

# Bug Fixes 2: Configuration Page

## 1. Save flow via back button is broken
On all configuration pages, the save action is only triggered by clicking the back button in the upper-left corner, which opens a confirmation popup asking "Do you want to save?" However, after confirming:
- The changes are not actually saved.
- The user is not returned to the previous page.
- The only way to navigate away afterward is by using the bottom navigation bar (the back button itself no longer works for navigation).

**Fix:**
- Ensure clicking "Save" in the confirmation popup actually persists the changes to the backend.
- After a successful save, navigate the user back to the previous page automatically.
- Ensure the upper-left back button reliably returns the user to the previous page in all cases (whether or not there were changes to save).

## 2. Attendance/clock-in settings page UI inconsistency
On most configuration pages, each selected field is displayed using a scrollable picker/wheel (one field expands at a time for selection). On the attendance/clock-in settings page, this pattern is broken — all fields/options are displayed simultaneously instead of using the scrolling wheel component.

**Fix:** Update the attendance/clock-in settings page to use the same scrollable picker component used on other configuration pages, so the UI is consistent across all settings pages.

## 3. Save confirmation popup on bottom bar navigation is inconsistent
When a user has unsaved changes and clicks an item in the bottom navigation bar, a popup should appear asking whether to save changes before leaving. This currently happens inconsistently — sometimes the popup appears, sometimes it doesn't, with no clear pattern.

**Fix:** Identify why the "unsaved changes" detection is unreliable (e.g., race condition, inconsistent state tracking, event not firing on all navigation paths) and ensure the confirmation popup appears every time there are unsaved changes, regardless of which bottom bar item is clicked.