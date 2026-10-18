# FinTrack — Test Plan

## Purpose

Verify the main account and transaction persistence flows before publishing FinTrack as a finished project.

## Automated repository tests

| ID | Scenario | Expected result |
|---|---|---|
| ACC-01 | Create account with an initial balance | Account is persisted with the requested name, icon, initial balance, current balance, and creation date |
| TX-01 | Create an expense | Transaction is persisted and the account balance decreases by the expense amount |
| TX-02 | Create an income | Transaction is persisted and the account balance increases by the income amount |
| TX-03 | Update a transaction | Previous balance effect is reverted and the updated effect is applied exactly once |
| TX-04 | Delete a transaction | Transaction is removed and its balance effect is reverted |
| CAT-01 | Run the category seeder twice | Expected English categories exist once each |

## Manual acceptance tests

| ID | Steps | Expected result | Result |
|---|---|---|---|
| MAN-01 | Launch the app with no accounts | No sample accounts are created; user can create their own account | positive |
| MAN-02 | Try to create a transaction without an account | The form prevents saving and explains that an account is required | positive |
| MAN-03 | Create an account with an initial balance | Account appears in Accounts and dashboard totals update | positive |
| MAN-04 | Create an income transaction | Transaction appears and account balance increases | positive |
| MAN-05 | Create an expense transaction | Transaction appears and account balance decreases | positive |
| MAN-06 | Enter amount zero or a negative amount | Form prevents saving and shows validation feedback | positive |
| MAN-07 | Choose a date before the selected account's creation date | Form prevents saving and explains the date restriction | positive |
| MAN-08 | Edit a transaction's amount, type, or account | Transaction details and account balances are correct afterwards | positive |
| MAN-09 | Delete a transaction | Transaction disappears and the account balance is recalculated | positive |
| MAN-10 | Create, edit, and delete a budget | Budget list reflects each operation | positive |
| MAN-11 | Close and relaunch the app | Saved accounts, transactions, and budgets persist | positive |
| MAN-12 | Run the category seeder more than once | No duplicate English categories appear | positive |
| MAN-13 | Inspect analytics after adding transactions | Totals and chart data reflect the selected period | positive |

## Execution record

Complete this section only after running the tests.

- Date: 16 october 2026
- Xcode version: Version 27.0 
- Simulator/device: Phisical iphone 12 - IOS 26.1
- Automated tests passed: 6
- Automated tests failed: 0
- Manual tests passed: 13
- Known issues: You can create more than one budget with the same category

## Release checklist

- [x] `⌘U` completes with all automated tests passing.
- [x] Manual acceptance tests are executed on a clean device.
- [x] No personal financial data or secrets are included in screenshots or repository files.
- [x] README feature descriptions match the actual app.
