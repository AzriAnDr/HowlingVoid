# Corporate Economy / Корпоративная экономика

## English

Corporate Economy is a satirical macroeconomic layer for HowlingVoid. It tracks station productivity, crew consumption, wage payouts, purchasing power, poverty, and Nanotrasen corporate surplus.

The station can produce record value while ordinary crew remain poor. GSP measures value created by the station; wages and player-to-player transfers are not GSP. Corporate surplus is stored only on `SSeconomy` and is not a bank account, budget card, ID account, or player-spendable balance.

The satire is in the reporting language and corporate framing. The numbers are real gameplay data; Nanotrasen interprets low purchasing power and low wage share as operational efficiency.

### Mechanics

- Cargo exports count as Gross Station Product.
- Bounty cubes exported through cargo count as bounty GSP.
- Most export value is remitted to corporate surplus before cargo receives its allocation.
- Export reports show gross value, corporate remittance, station allocation, and the final cargo budget share.
- Payment-component card purchases and ordinary vending purchases count as crew consumption.
- Retail purchases siphon a capped margin from the receiver account into the corporate ledger after the original purchase succeeds.
- Ordinary vending purchases add a ledger-only corporate retail margin without charging the buyer twice or reducing vending cash storage.
- Successful payday payouts add to the employee wage pool.
- Crew paychecks and starting funds do not scale with productivity or corporate surplus.
- Vending prices follow a soft station price index based on crew money pressure. Market crash events are temporary shocks above that baseline.
- Cargo and company import prices are explicit `cost = ...` values on supply packs. There is no permanent hidden corporate economy cargo price multiplier.
- Cargo starts with a 2500 credit operations budget. Further cargo funding comes from exports, bounties, and active gameplay rather than passive grants.
- Small cargo/company items can be bought through cargo, department, or private accounts.
- Sensitive weapon/restricted orders are allowed even without the normal department access, but suspicious orders announce to supply radio and are written to economy/cargo logs.
- Department budgets no longer receive passive timer grants. Cargo and station budgets rely on starting funds, exports, bounties, and active gameplay sources.
- Payroll Adjustment includes a read-only department budget tab for station, cargo, and department balances.
- Food, drink, and other crew-facing vending prices use explicit `custom_price` values where item value differs inside one machine. Survival basics stay affordable, work supplies are moderate purchases, and luxury, restricted, or weapon-adjacent goods are priced as deliberate expenses.
- Major money events are classified as production, consumption, department income, import cost, grants, fines, transfers, or wages.
- Cargo Economic Monitor is an NTOS supply program that shows cargo budget flow, GSP, corporate surplus, retail consumption, price pressure, and round-local trend graphs.
- Soft inflation reports a pressure reason: crew liquidity, retail spending, market shock, or stable.

### Economic Shocks

Temporary shock vars live on `SSeconomy` and reset with the subsystem. They are intended for events, VV, or admin-driven round pressure.

- `apply_corporate_audit()`: increases corporate export and bounty take rates.
- `apply_supply_subsidy()`: adds a temporary station export allocation bonus.
- `apply_labor_unrest_report()`: changes reports only; it never raises wages.
- `apply_black_market_glut()`: lowers company/import supply pack prices through an explicit event modifier and marks sensitive orders with enhanced logging.
- `clear_economic_shock()`: restores normal modifiers.

Manual `cost = ...` values remain the source of truth. The import price event modifier is a temporary market event, not a balancing replacement.

### Changed Files

- `code/modules/corporate_economy/corporate_economy.dm`: subsystem vars, ledger procs, basket metrics, poverty metrics, export summaries, economic shock helpers, sensitive cargo order logging, and TGUI source breakdown helpers.
- `code/modules/economy/account.dm`: records successful wage payouts.
- `code/modules/shuttle/mobile_port/variants/supply.dm`: splits cargo export proceeds between corporate surplus and station allocation, then reports the split.
- `code/modules/cargo/exports.dm`: records gross export value before pricetag payouts.
- `code/modules/cargo/packs/_packs.dm`: applies only the normal pack modifier plus explicit temporary import-market event modifiers.
- `code/datums/components/payment.dm`: records retail consumption and corporate retail margin.
- `code/modules/vending/vendor/inventory.dm`: records ordinary vending consumption, applies explicit vending prices, and keeps stable brand/item price variation.
- `code/modules/modular_computers/file_system/programs/cargo_analytics.dm` and `tgui/packages/tgui/interfaces/NtosCargoAnalytics.tsx`: add the Cargo Economic Monitor program with round-local economy graphs.
- `code/game/machinery/computer/accounting.dm`: exposes macroeconomic report data and hardship/shock fields.
- `code/controllers/subsystem/economy.dm`: removes passive department budget grants, updates soft price index, and adds corporate performance text to newscaster economy reports.
- `code/modules/modular_computers/file_system/programs/payroll_adjustment.dm` and `tgui/packages/tgui/interfaces/NtosPayrollAdjustment.tsx`: expose read-only department budget visibility in payroll tools.
- `former_nova_module_tree/modules/imported_vendors/code/`: assigns explicit food and drink prices for imported vending products.
- `code/modules/cargo/orderconsole.dm`: allows small cargo purchases with cargo/department budgets and reports sensitive orders.
- `code/modules/modular_computers/file_system/programs/budgetordering.dm`: mirrors cargo purchase behavior for the NT Shopping Network app.
- `code/modules/company_imports/objects/cargo_console_and_case.dm`: allows restricted company imports and reports sensitive orders.
- `tgui/packages/tgui/interfaces/AccountingConsole/`: adds the NT Economic Performance screen and crew hardship block.

### Metrics

- Gross Station Product: total recorded production value.
- Real GSP: `gross_station_product / max(price_index, 0.1)`.
- Corporate Surplus: extracted non-player corporate value.
- Employee Wage Pool: successful wage payouts.
- Wage Share: `employee_wage_pool / max(gross_station_product, 1)`.
- Crew Consumption: successful retail spending through payment machines and ordinary vending machines.
- Economic Activity: classified totals for production, consumption, department income, import costs, grants, fines, transfers, and wages.
- Economy History: last 30 economy ticks, held in round memory for Cargo Economic Monitor graphs.
- Reference Basket: `2 * snack + cola + coffee + medical + tool`.
- Current Basket Price: reference basket adjusted by the current effective vending price index.
- Price Index: `current_basket_price / reference_basket_price`.
- Paycheck Purchasing Power: `average_paycheck / current_basket_price`.
- Poverty Count: manifest crew accounts below `current_basket_price * poverty_basket_multiplier`.

### Tuning

Tuning vars live on `/datum/controller/subsystem/economy` in `corporate_economy.dm`:

- `corporate_export_take_rate = 0.70`
- `station_export_share = 0.30`
- `corporate_retail_take_rate = 0.25`
- `corporate_bounty_take_rate = 0.50`
- `employee_bounty_share = 0.50`
- `poverty_basket_multiplier = 1`
- `economic_price_index = 1`
- `maximum_economic_price_index = 2.5`
- `economic_price_smoothing = 0.25`
- `economic_price_deflation_smoothing = 0.10`
- `vending_price_update_threshold = 0.05`

Supply pack balance is intentionally explicit. Edit individual `cost = ...` values on supply packs rather than adding a hidden multiplier.

## Русский

Corporate Economy - сатирический макроэкономический слой для HowlingVoid. Он отслеживает производительность станции, потребление экипажа, выплаты зарплат, покупательную способность, бедность и корпоративный излишек Nanotrasen.

Станция может показывать рекордную производительность, пока обычные члены экипажа остаются бедными. GSP измеряет созданную станцией стоимость; зарплаты и переводы между игроками не являются GSP. Corporate surplus хранится только в `SSeconomy` и не является банковским счётом, бюджетной картой, ID-счётом или балансом, который игроки могут потратить.

Сатира живёт в языке отчётов и корпоративной интерпретации. Цифры являются настоящими игровыми данными; Nanotrasen называет низкую покупательную способность и низкую долю зарплат операционной эффективностью.

### Механики

- Экспорт cargo считается Gross Station Product.
- Bounty cubes, вывезенные через cargo, считаются bounty GSP.
- Большая часть экспортной стоимости уходит в corporate surplus до того, как cargo получает свою долю.
- Отчёты экспорта показывают gross value, corporate remittance, station allocation и итоговую долю cargo.
- Покупки через payment component считаются потреблением экипажа.
- Retail purchases после успешной покупки списывают ограниченную маржу со счёта получателя в corporate ledger.
- Успешные payday-выплаты добавляются в employee wage pool.
- Зарплаты и стартовые деньги экипажа не растут от продуктивности или corporate surplus.
- Цены vending следуют мягкому station price index, основанному на денежном давлении экипажа. Market crash остаётся временным шоком поверх этого индекса.
- Цены cargo и company imports задаются явно через `cost = ...` в supply packs. Постоянного скрытого cargo-множителя от Corporate Economy нет.
- Малые cargo/company items можно покупать через cargo budget, department budget или private account.
- Оружейные и restricted orders разрешены даже без обычного department access, но подозрительные заказы объявляются в supply radio и пишутся в economy/cargo logs.
- Department budgets больше не получают пассивные timer grants. Cargo и station budgets зависят от стартовых средств, экспорта, bounty и активных игровых источников.

### Экономические шоки

Временные shock-переменные живут на `SSeconomy` и сбрасываются вместе с подсистемой. Они предназначены для ивентов, VV или админского давления на раунд.

- `apply_corporate_audit()`: повышает корпоративную долю с экспорта и bounty.
- `apply_supply_subsidy()`: добавляет временный бонус к station export allocation.
- `apply_labor_unrest_report()`: меняет только отчёты; зарплаты не повышаются.
- `apply_black_market_glut()`: снижает цены company/import supply packs через явный event modifier и помечает sensitive orders усиленным логированием.
- `clear_economic_shock()`: возвращает обычные модификаторы.

Ручные `cost = ...` остаются источником истины. Import price event modifier - это временное рыночное событие, а не замена ручного баланса.

### Изменённые файлы

- `code/modules/corporate_economy/corporate_economy.dm`: переменные подсистемы, ledger procs, basket metrics, poverty metrics, export summaries, economic shock helpers, sensitive cargo logging и TGUI source breakdown helpers.
- `code/modules/economy/account.dm`: записывает успешные выплаты зарплат.
- `code/modules/shuttle/mobile_port/variants/supply.dm`: делит экспортную выручку между corporate surplus и station allocation, затем показывает split в отчёте.
- `code/modules/cargo/exports.dm`: записывает gross export value до pricetag payouts.
- `code/modules/cargo/packs/_packs.dm`: применяет только обычный pack modifier и явные временные import-market event modifiers.
- `code/datums/components/payment.dm`: записывает retail consumption и corporate retail margin.
- `code/game/machinery/computer/accounting.dm`: отдаёт macroeconomic report data и hardship/shock fields.
- `code/controllers/subsystem/economy.dm`: убирает пассивные department budget grants, обновляет soft price index и добавляет corporate performance text в newscaster economy reports.
- `code/modules/cargo/orderconsole.dm`: разрешает малые cargo purchases через cargo/department budgets и репортит sensitive orders.
- `code/modules/modular_computers/file_system/programs/budgetordering.dm`: повторяет cargo purchase behavior для NT Shopping Network app.
- `code/modules/company_imports/objects/cargo_console_and_case.dm`: разрешает restricted company imports и репортит sensitive orders.
- `tgui/packages/tgui/interfaces/AccountingConsole/`: добавляет NT Economic Performance screen и блок crew hardship.

### Метрики

- Gross Station Product: вся записанная производственная стоимость.
- Real GSP: `gross_station_product / max(price_index, 0.1)`.
- Corporate Surplus: извлечённая корпоративная стоимость, недоступная игрокам.
- Employee Wage Pool: успешные выплаты зарплат.
- Wage Share: `employee_wage_pool / max(gross_station_product, 1)`.
- Crew Consumption: успешные retail purchases.
- Reference Basket: `2 * snack + cola + coffee + medical + tool`.
- Current Basket Price: reference basket, умноженная на текущий effective vending price index.
- Price Index: `current_basket_price / reference_basket_price`.
- Paycheck Purchasing Power: `average_paycheck / current_basket_price`.
- Poverty Count: manifest crew accounts ниже `current_basket_price * poverty_basket_multiplier`.

### Настройка

Настраиваемые переменные находятся на `/datum/controller/subsystem/economy` в `corporate_economy.dm`:

- `corporate_export_take_rate = 0.70`
- `station_export_share = 0.30`
- `corporate_retail_take_rate = 0.25`
- `corporate_bounty_take_rate = 0.50`
- `employee_bounty_share = 0.50`
- `poverty_basket_multiplier = 1`
- `economic_price_index = 1`
- `maximum_economic_price_index = 2.5`
- `economic_price_smoothing = 0.25`
- `vending_price_update_threshold = 0.05`

Баланс supply packs намеренно явный. Для правки цены меняйте конкретные `cost = ...` значения на supply packs, а не добавляйте скрытый multiplier.
