# Payroll Adjustment

Документация описывает NTOS-приложение **Payroll Adjustment** и связанные изменения экономики.

## Назначение

Payroll Adjustment позволяет командованию точечно изменять зарплату конкретного члена экипажа. Изменение применяется к будущим payday-выплатам и хранится на банковском аккаунте сотрудника как flat-корректировка.

Приложение предназначено для ситуаций, когда зарплату нужно повысить или понизить по IC-причине: эффективность, стаж, особое достижение или отдельное вручную указанное основание.

## Доступ

Приложение проверяет доступ по ID-карте, вставленной или привязанной к модульному компьютеру/PDA.

Для запуска и изменения зарплат требуется один из доступов:

- `ACCESS_CAPTAIN`
- `ACCESS_HOP`

Доступ проверяется дважды:

- стандартной NTOS-проверкой `run_access`;
- внутренней проверкой `can_adjust_payroll()` перед выполнением действия.

Это означает, что доступ зависит от карты, а не от фактической профессии моба. Если резервная или чужая ID-карта имеет `ACCESS_CAPTAIN` или `ACCESS_HOP`, приложение сможет работать с ней.

## Где доступно приложение

Payroll Adjustment добавлено в стартовые программы:

- ID console;
- Captain PDA;
- Head of Personnel PDA;
- Nanotrasen Consultant PDA;
- Captain command disk;
- Head of Personnel command disk.

## Интерфейс

Интерфейс находится в `tgui/packages/tgui/interfaces/NtosPayrollAdjustment.tsx`.

Основные вкладки:

- **Payroll Adjustment** - форма изменения зарплаты.
- **Change History** - последние изменения зарплат за текущий раунд.
- **Overview** - read-only список сотрудников, базовых зарплат, корректировок и текущих зарплат.

Текст интерфейса вынесен в систему локализации:

- `tgui/packages/tgui/interfaces/locales/ui.common.en.json`
- `tgui/packages/tgui/interfaces/locales/ui.common.ru.json`

Ключи используют префикс `ui.ntos_payroll_adjustment.*`.

## Изменение зарплаты

Пользователь выбирает сотрудника, направление изменения и способ расчета:

- **Amount** - прямая сумма корректировки за payday.
- **Percent** - процент от базовой зарплаты, который сервер пересчитывает в flat-корректировку.

В аккаунте хранится только итоговая flat-корректировка:

- `paycheck_adjustment`
- `paycheck_adjustment_reason`
- `paycheck_adjustment_basis`
- `paycheck_adjustment_authorized_by`

Корректировка ограничивается сервером:

- не ниже `-base_paycheck`, чтобы итоговая зарплата не ушла ниже нуля;
- не выше `MAX_PAYROLL_ADJUSTMENT`.

Чтобы полностью забрать зарплату, нужно выбрать понижение и ввести сумму, равную базовой зарплате. Итоговая зарплата станет `0 cr`.

## Основание и причина

Поле `basis` обязательно. Доступные варианты:

- `Performance`
- `Seniority`
- `Special Achievement`
- `Other`

Для первых трех вариантов причина автоматически совпадает с выбранным основанием. Поле ручного ввода активно только при выборе `Other`.

История изменений показывает:

- время;
- сотрудника;
- должность;
- дельту;
- новую зарплату;
- основание;
- причину;
- автора изменения.

Лог хранится в `SSeconomy.payroll_adjustment_log` и ограничен последними `PAYROLL_LOG_LIMIT` записями.

## Экономика выплат

Базовая зарплата по-прежнему выплачивается из departmental budget.

Положительная надбавка берется из бюджета станции:

- station budget account: `ACCOUNT_CIV`
- причина перевода: `Nanotrasen: Payroll Adjustment`

Отрицательная корректировка просто уменьшает выплату сотруднику и не создает дополнительный доход.

Если бюджета станции не хватает на положительную надбавку, выплачивается только доступная часть через обычный `transfer_money()`. Деньги не создаются из воздуха.

## Пассивные бюджеты

Пассивное начисление денег в бюджеты карго и станции отключено. Станция должна зарабатывать деньги активными игровыми способами, а экипаж продолжает получать зарплаты через payday-систему.

## Основные файлы

- `code/modules/modular_computers/file_system/programs/payroll_adjustment.dm` - серверная логика приложения.
- `tgui/packages/tgui/interfaces/NtosPayrollAdjustment.tsx` - TGUI-интерфейс.
- `code/modules/economy/account.dm` - хранение payroll metadata и payday-выплаты.
- `code/controllers/subsystem/economy.dm` - economy subsystem и payroll log.
- `code/modules/modular_computers/computers/machinery/console_presets.dm` - стартовая программа ID console.
- `code/modules/modular_computers/computers/item/role_tablet_presets.dm` - стартовые программы PDA ролей.
- `code/modules/modular_computers/computers/item/disks/role_disks.dm` - command disks.
- `code/modules/nanotrasen_rep/nanotrasen_consultant.dm` - Nanotrasen Consultant PDA.

## Проверка

Минимальная проверка после изменений:

1. Запустить `.\BUILD.cmd`.
2. Запустить DreamDaemon на собранном `tgstation.dmb`.
3. Проверить в игре:
   - без нужного ID приложение не дает работать;
   - с Captain/HoP/NTR ID приложение открывается;
   - Amount меняет итоговую зарплату корректно;
   - Percent пересчитывается в flat-корректировку;
   - зарплату можно снизить до `0 cr`;
   - ручная причина активна только для `Other`;
   - история показывает basis, reason и автора;
   - положительная надбавка списывается из бюджета станции на payday.
