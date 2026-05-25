# Payroll Adjustment

This document describes the **Payroll Adjustment** NTOS application and the related economy changes.

## Purpose

Payroll Adjustment lets command staff adjust an individual crew member's salary. The adjustment applies to future payday payouts and is stored on the employee's bank account as a flat paycheck modifier.

The application is intended for IC payroll changes based on performance, seniority, special achievement, or a manually entered reason.

## Access

The application checks access through the ID card inserted into, or linked to, the modular computer/PDA.

Running the application and changing salaries requires one of these accesses:

- `ACCESS_CAPTAIN`
- `ACCESS_HOP`

Access is checked twice:

- by the standard NTOS `run_access` check;
- by the internal `can_adjust_payroll()` check before any payroll action is applied.

This means access is card-based, not job-datum-based. If a spare or borrowed ID card has `ACCESS_CAPTAIN` or `ACCESS_HOP`, the application can be used with it.

## Standard Availability

Payroll Adjustment is installed by default on:

- ID console;
- Captain PDA;
- Head of Personnel PDA;
- Nanotrasen Consultant PDA;
- Captain command disk;
- Head of Personnel command disk.

## Interface

The interface lives in `tgui/packages/tgui/interfaces/NtosPayrollAdjustment.tsx`.

Main tabs:

- **Payroll Adjustment** - the salary adjustment form.
- **Change History** - recent payroll changes for the current round.
- **Overview** - a read-only crew list with base salaries, active adjustments, and current salaries.

Interface text is localized through:

- `tgui/packages/tgui/interfaces/locales/ui.common.en.json`
- `tgui/packages/tgui/interfaces/locales/ui.common.ru.json`

Localization keys use the `ui.ntos_payroll_adjustment.*` prefix.

## Salary Changes

The user selects an employee, an adjustment direction, and a calculation mode:

- **Amount** - a direct flat paycheck modifier per payday.
- **Percent** - a percentage of the base paycheck, recalculated server-side into a flat modifier.

Only the final flat modifier and its metadata are stored on the account:

- `paycheck_adjustment`
- `paycheck_adjustment_reason`
- `paycheck_adjustment_basis`
- `paycheck_adjustment_authorized_by`

The server clamps the adjustment:

- not below `-base_paycheck`, so the final paycheck cannot become negative;
- not above `MAX_PAYROLL_ADJUSTMENT`.

To remove a salary completely, choose a decrease and enter an amount equal to the base paycheck. The final paycheck becomes `0 cr`.

## Basis and Reason

The `basis` field is required. Valid options:

- `Performance`
- `Seniority`
- `Special Achievement`
- `Other`

For the first three options, the reason is automatically set to the selected basis. Manual reason input is enabled only when `Other` is selected.

The change history shows:

- time;
- employee;
- job;
- delta;
- new paycheck;
- basis;
- reason;
- author.

The log is stored in `SSeconomy.payroll_adjustment_log` and is limited to the latest `PAYROLL_LOG_LIMIT` entries.

## Payday Economy

Base salary is still paid from the employee's departmental budget.

Positive payroll adjustments are paid from the station budget:

- station budget account: `ACCOUNT_CIV`
- transfer reason: `Nanotrasen: Payroll Adjustment`

Negative adjustments simply reduce the employee's payout and do not create extra income.

If the station budget cannot cover a positive adjustment, only the available amount is transferred through the normal `transfer_money()` flow. No money is created from nothing.

## Passive Budgets

Passive money injection into cargo and station budgets is disabled. The station must earn money through active gameplay, while crew still receive salaries through the payday system.

## Main Files

- `code/modules/modular_computers/file_system/programs/payroll_adjustment.dm` - server-side application logic.
- `tgui/packages/tgui/interfaces/NtosPayrollAdjustment.tsx` - TGUI interface.
- `code/modules/economy/account.dm` - payroll metadata storage and payday payout logic.
- `code/controllers/subsystem/economy.dm` - economy subsystem and payroll log.
- `code/modules/modular_computers/computers/machinery/console_presets.dm` - ID console starting program.
- `code/modules/modular_computers/computers/item/role_tablet_presets.dm` - role PDA starting programs.
- `code/modules/modular_computers/computers/item/disks/role_disks.dm` - command disks.
- `code/modules/nanotrasen_rep/nanotrasen_consultant.dm` - Nanotrasen Consultant PDA.

## Verification

Minimum verification after changes:

1. Run `.\BUILD.cmd`.
2. Start DreamDaemon with the built `tgstation.dmb`.
3. Check in-game:
   - without a valid ID, the application cannot be used;
   - with a Captain/HoP/NTR ID, the application opens;
   - Amount mode updates the final paycheck correctly;
   - Percent mode recalculates into a flat modifier correctly;
   - salary can be reduced to `0 cr`;
   - manual reason input is enabled only for `Other`;
   - history shows basis, reason, and author;
   - positive adjustments are charged to the station budget on payday.
