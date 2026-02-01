# RRT SOS App Smoke Test Checklist

## What is a smoke test?
A smoke test is a short, repeatable set of checks that verifies the
core flows still work after a change. It is not exhaustive; it is a
quick signal that the build is likely safe to share or continue testing.

## When to run
- After any code change that touches location, SOS, alerts, or push
- Before sharing a build with testers

## Setup
- Device A and Device B (preferred), or a single device plus curl
- Location services enabled on test device(s)
- Push notifications enabled on test device(s)

## Core regression checks (keep these every time)
1. Tap the location refresh button and verify location fetch succeeds.
2. Send SOS from Device A and confirm Device B receives it (foreground).
3. Repeat when Device B is backgrounded and terminated.
4. Tap the push notification and verify the app opens correctly.
5. Verify no duplicate SOS alerts appear in Alerts screen.
6. Verify no self alerts appear in Alerts screen.

## Single-device push trigger (when no second device)
Use this to trigger a test push on one device:

```
curl -X POST https://us-central1-rrt-sos.cloudfunctions.net/api/test-push \
  -H "Content-Type: application/json" \
  -d '{"district": "udupi"}'
```

## High-value quick checks (recommended)
7. Deny location permission and verify a graceful error (no crash).
8. Grant permission after denial and verify refresh works without restart.
9. Disable notifications at OS level and verify app still runs cleanly.
10. Fresh install flow: onboarding completes and profile persists.
11. Reopen app after onboarding and confirm it skips onboarding.
12. Alerts list ordering is newest-first and timestamps look right.
13. Airplane mode during alert fetch shows error and recovers on retry.
14. Receive alert while app is open and verify it appears immediately.
15. Cold-start from push after force-kill opens the right screen.
16. Turn location off and confirm no crash and usable fallback state.

## Notes
- Keep the checklist short enough to run in 10-15 minutes.
- If a failure is found, capture steps and device state (foreground,
  background, terminated) so it can be reproduced.
