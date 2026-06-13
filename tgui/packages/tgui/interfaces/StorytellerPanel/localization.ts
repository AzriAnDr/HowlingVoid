import {
  getRememberedInterfaceLanguage,
  getRememberedUIElementLanguage,
  type PanelLanguage,
} from 'common/panelLocalization';

export type StorytellerLanguageData = {
  interfaceLanguage?: string;
  panelLanguages?: Record<string, string>;
};

const UI_TEXT: Record<PanelLanguage, Record<string, string>> = {
  english: {
    window_title: 'Storyteller Panel',
    header_title: 'Storyteller Control',
    header_subtitle:
      'Adaptive pacing director for pressure, aid, antagonists, and round diagnostics.',
    pause: 'Pause',
    resume: 'Resume',
    skip_next_pulse: 'Skip Next Pulse',
    disabled_notice:
      'Storyteller is disabled in config. The panel is read-only until STORYTELLER_ENABLED is enabled.',
    extended_notice:
      'Extended mode keeps adaptive relief and support active. Storyteller antagonists are suppressed, while only rare low-impact negative pressure remains available.',
    dynamic_notice:
      'Dynamic mode enables full storyteller pacing: adaptive aid, antagonists, and hostile pressure all remain in rotation.',
    round_mode: 'Round Mode',
    profile: 'Profile',
    content_stage: 'Content Stage',
    trigger_window: 'Trigger Window',
    overview_tab: 'Overview',
    operations_tab: 'Operations',
    snapshot_tab: 'Snapshot',
    logs_tab: 'Logs & Diagnostics',
    round_overview: 'Round Overview',
    enabled: 'Enabled',
    full_owner: 'Full Owner',
    paused: 'Paused',
    population: 'Population',
    alive_crew: 'Alive Crew',
    living_antags: 'Living Antags',
    station_integrity: 'Station Integrity',
    stage_one_notice:
      'Current config only exposes stage-1 storyteller content.',
    manual_stage_notice:
      'Content stage is currently pinned by an admin override.',
    auto_stage_notice: 'Content stage is currently escalating automatically.',
    budgets_pressure: 'Budgets & Pressure',
    control_score: 'Control Score',
    danger_score: 'Danger Score',
    threat_budget: 'Threat Budget',
    aid_budget: 'Aid Budget',
    cadence: 'Cadence',
    positive_lock: 'Positive Lock',
    positive_window: 'Positive Window',
    negative_lock: 'Negative Lock',
    negative_window: 'Negative Window',
    latejoin_lock: 'Latejoin Lock',
    latejoin_warmup: 'Latejoin Warmup',
    current_snapshot: 'Current Snapshot',
    cargo_budget: 'Cargo Budget',
    active_alarms: 'Active Alarms',
    recent_deaths: 'Recent Deaths',
    recent_explosions: 'Recent Explosions',
    kitchen_service_food: 'Kitchen / Service Food',
    cargo_miners: 'Cargo / Miners',
    breaches_floors: 'Breaches / Floors',
    windows_grilles: 'Windows / Grilles',
    controls: 'Controls',
    round_mode_override: 'Round Mode Override',
    profile_override: 'Profile Override',
    set_mode: 'Set Mode',
    set_profile: 'Set Profile',
    auto: 'Auto',
    set_content_stage: 'Set Content Stage',
    set_stage: 'Set Stage',
    queue_delay: 'Queue Delay',
    dynamic_backend: 'Dynamic Backend',
    dynamic_backend_notice:
      'These controls mirror the legacy Dynamic Panel inside the storyteller workflow so you can manage raw SSdynamic rulesets without leaving this interface.',
    dynamic_tier: 'Dynamic Tier',
    set_dynamic_tier: 'Set Tier',
    dynamic_antag_events: 'Dynamic Antag Events',
    dynamic_ruleset_counts: 'Dynamic Ruleset Counts',
    dynamic_disable_all: 'Disable All Rulesets',
    dynamic_enable_all: 'Enable All Rulesets',
    dynamic_backend_status: 'Dynamic Backend Status',
    dynamic_light_unlock: 'Light Pool Unlock',
    dynamic_heavy_unlock: 'Heavy Pool Unlock',
    dynamic_latejoin_unlock: 'Latejoin Pool Unlock',
    dynamic_next_midround: 'Next Midround Roll',
    dynamic_next_latejoin: 'Next Latejoin Roll',
    dynamic_failed_latejoins: 'Failed Latejoins',
    dynamic_light_chance: 'Light Ruleset Chance',
    dynamic_heavy_chance: 'Heavy Ruleset Chance',
    dynamic_latejoin_chance: 'Latejoin Chance',
    dynamic_force_chance: 'Force 100%',
    dynamic_forced: 'forced',
    dynamic_reset: 'Reset',
    dynamic_ruleset_search: 'Dynamic Ruleset Search',
    search_dynamic_rulesets: 'Search dynamic rulesets',
    dynamic_roundstart_rulesets: 'Roundstart Rulesets',
    dynamic_light_rulesets: 'Light Midround Rulesets',
    dynamic_heavy_rulesets: 'Heavy Midround Rulesets',
    dynamic_latejoin_rulesets: 'Latejoin Rulesets',
    dynamic_queued_rulesets: 'Queued Dynamic Rulesets',
    dynamic_active_rulesets: 'Executed Dynamic Rulesets',
    no_dynamic_queued: 'No raw SSdynamic rulesets are currently queued.',
    no_dynamic_active: 'No raw SSdynamic rulesets have executed yet.',
    no_dynamic_rulesets_filtered:
      'No Dynamic rulesets matched the current filter.',
    force_action: 'Force Action',
    force_next: 'Force Next',
    force_now: 'Force NOW',
    force_now_confirm: 'Force Now?',
    action_search: 'Action Search',
    search_storyteller_actions: 'Search storyteller actions',
    search_all_actions: 'Search positive, negative, and antagonist actions',
    detected_needs: 'Detected Needs',
    no_detected_needs: 'No actionable department needs detected.',
    scheduled_actions: 'Scheduled Actions',
    no_scheduled_actions: 'No storyteller actions are currently waiting in the delayed queue.',
    queued_next_actions: 'Queued Next Actions',
    no_queued_next: 'No storyteller pulse overrides are currently queued.',
    positive_channel: 'Positive Channel',
    negative_channel: 'Negative Channel',
    queued_antagonists: 'Queued Antagonists',
    no_queued_antags: 'No queued roundstart or latejoin antagonist rulesets.',
    active_modifiers: 'Active Modifiers',
    no_active_modifiers: 'No timed storyteller modifiers are active.',
    positive_actions: 'Positive Actions',
    negative_actions: 'Negative Actions',
    antagonist_actions: 'Antagonist Actions',
    no_positive_filtered:
      'No positive storyteller actions matched the current filter.',
    no_negative_filtered:
      'No negative storyteller actions matched the current filter.',
    no_antag_filtered:
      'No storyteller antagonist actions matched the current filter.',
    crew_staffing: 'Crew & Staffing',
    key_jobs_filled: 'Key Jobs Filled',
    cooks_service: 'Cooks / Service',
    engineers_atmos: 'Engineers / Atmos',
    threats_events: 'Threats & Events',
    active_round_events: 'Active Round Events',
    resources_economy: 'Resources & Economy',
    silo_materials: 'Silo Materials',
    loose_materials: 'Loose Materials',
    recent_material_gain: 'Recent Material Gain',
    structural_condition: 'Structural Condition',
    key_jobs: 'Key Jobs',
    department_staffing: 'Department Staffing',
    living_antag_types: 'Living Antag Types',
    active_event_breakdown: 'Active Event Breakdown',
    department_money: 'Department Money',
    silo_breakdown: 'Silo Material Breakdown',
    loose_breakdown: 'Loose Material Breakdown',
    recent_decisions: 'Recent Decisions',
    no_decisions: 'No storyteller decisions have been recorded yet.',
    active_cooldowns: 'Active Cooldowns',
    no_cooldowns: 'No family cooldowns active.',
    advanced_notes: 'Advanced Notes',
    advanced_notes_body:
      'Profiles change the storyteller temperament. They retune pressure scoring, budget growth, cadence delays, escalation speed, and how aggressively the subsystem leans into hostile or supportive pacing.',
    advanced_notes_footer:
      'Content stages are global unlock bands. Stage 1 keeps lighter content, while higher stages unlock heavier actions and antagonists as the round matures or intensifies.',
    yes: 'Yes',
    no: 'No',
    ready: 'Ready',
    expired: 'Expired',
    none: 'None',
    chance: 'Chance',
    cost: 'Cost',
    weight: 'Weight',
    stage: 'Stage',
    active_window: 'Active Window',
    targets_need: 'Targets need',
    discard: 'Discard',
    discarded: 'Discarded',
    disabled: 'Disabled',
    return_action: 'Return',
    cancel: 'Cancel',
    cancel_queue_confirm: 'Cancel queue?',
    refund_threat: 'Refund',
    scheduled_for: 'Scheduled for',
    source_storyteller: 'Storyteller',
    source_admin: 'Administrator',
    enable: 'Enable',
    disable: 'Disable',
    queue: 'Queue',
    move_up: 'Up',
    move_down: 'Down',
    move_to_top: 'Top',
    move_to_bottom: 'Bottom',
    set_timer: 'Set Timer',
    minutes_short: 'min',
    execute_now: 'Execute NOW',
    remove_from_queue: 'Remove',
    hide_from_roundend: 'Hide from Roundend',
    hidden_from_roundend: 'hidden from roundend',
    show_in_roundend: 'Restore to Roundend',
    selected_players: 'Selected players',
    pref: 'Pref',
    unknown: 'Unknown',
    severity: 'Severity',
    priority: 'Priority',
    left: 'left',
    antagonist_tag: 'antag',
    dynamic: 'Dynamic',
    extended: 'Extended',
    positive: 'Positive',
    negative: 'Negative',
    roundstart: 'Roundstart',
    midround: 'Midround',
    latejoin: 'Latejoin',
    balanced: 'Balanced Drama',
    passive: 'Patient Custodian',
    aggressive: 'Aggressive Escalation',
  },
  russian: {
    window_title: 'Панель сторителлера',
    header_title: 'Управление сторителлером',
    header_subtitle:
      'Адаптивный режиссёр темпа раунда: поддержка станции, давление, антагонисты и сводка по обстановке.',
    pause: 'Пауза',
    resume: 'Продолжить',
    skip_next_pulse: 'Пропустить следующий тик',
    disabled_notice:
      'Сторителлер отключён в конфиге. Панель работает только на чтение, пока не включён STORYTELLER_ENABLED.',
    extended_notice:
      'В режиме Extended сторителлер продолжает поддерживать станцию, но не запускает своих антагонистов и ограничивается редкими мягкими отрицательными событиями.',
    dynamic_notice:
      'В режиме Dynamic сторителлер полностью управляет темпом раунда и держит в ротации поддержку, отрицательные события и антагонистов.',
    round_mode: 'Режим раунда',
    profile: 'Профиль',
    content_stage: 'Уровень эскалации',
    trigger_window: 'Окно запуска',
    overview_tab: 'Обзор',
    operations_tab: 'Управление',
    snapshot_tab: 'Состояние станции',
    logs_tab: 'Журнал и диагностика',
    round_overview: 'Сводка раунда',
    enabled: 'Включён',
    full_owner: 'Управляет темпом',
    paused: 'На паузе',
    population: 'Онлайн',
    alive_crew: 'Живой экипаж',
    living_antags: 'Живые антаги',
    station_integrity: 'Целостность станции',
    stage_one_notice:
      'Сейчас в конфигурации открыт только контент первого уровня.',
    manual_stage_notice: 'Уровень эскалации сейчас зафиксирован админом.',
    auto_stage_notice: 'Уровень эскалации сейчас меняется автоматически.',
    budgets_pressure: 'Давление и бюджеты',
    control_score: 'Уровень контроля',
    danger_score: 'Уровень опасности',
    threat_budget: 'Бюджет давления',
    aid_budget: 'Бюджет поддержки',
    cadence: 'Таймеры и блокировки',
    positive_lock: 'Пауза после поддержки',
    positive_window: 'Следующая поддержка',
    negative_lock: 'Пауза после давления',
    negative_window: 'Следующее давление',
    latejoin_lock: 'Следующий лейтджоин-антаг',
    latejoin_warmup: 'Стартовая задержка',
    current_snapshot: 'Ключевые показатели',
    cargo_budget: 'Бюджет карго',
    active_alarms: 'Активные тревоги',
    recent_deaths: 'Недавние смерти',
    recent_explosions: 'Недавние взрывы',
    kitchen_service_food: 'Запасы еды',
    cargo_miners: 'Карго / шахтёры',
    breaches_floors: 'Разгерма / сломанные полы',
    windows_grilles: 'Окна / решётки',
    controls: 'Управление',
    round_mode_override: 'Ручной выбор режима',
    profile_override: 'Ручной выбор профиля',
    set_mode: 'Применить режим',
    set_profile: 'Применить профиль',
    auto: 'Авто',
    set_content_stage: 'Ручной выбор этапа',
    set_stage: 'Применить',
    queue_delay: 'Задержка очереди',
    dynamic_backend: 'Низкоуровневый Dynamic',
    dynamic_backend_notice:
      'Здесь продублированы основные настройки legacy Dynamic Panel, чтобы можно было управлять сырым SSdynamic прямо из панели storyteller.',
    dynamic_tier: 'Уровень Dynamic',
    set_dynamic_tier: 'Применить уровень',
    dynamic_antag_events: 'Dynamic-антагонисты',
    dynamic_ruleset_counts: 'Счётчики Dynamic-правил',
    dynamic_disable_all: 'Отключить все правила',
    dynamic_enable_all: 'Включить все правила',
    dynamic_backend_status: 'Состояние Dynamic',
    dynamic_light_unlock: 'Открытие лёгкого пула',
    dynamic_heavy_unlock: 'Открытие тяжёлого пула',
    dynamic_latejoin_unlock: 'Открытие лейтджоин-пула',
    dynamic_next_midround: 'Следующий midround-бросок',
    dynamic_next_latejoin: 'Следующий latejoin-бросок',
    dynamic_failed_latejoins: 'Пропущенные latejoin-попытки',
    dynamic_light_chance: 'Шанс лёгкого правила',
    dynamic_heavy_chance: 'Шанс тяжёлого правила',
    dynamic_latejoin_chance: 'Шанс latejoin-правила',
    dynamic_force_chance: 'Сделать 100%',
    dynamic_forced: 'принудительно',
    dynamic_reset: 'Сбросить',
    dynamic_ruleset_search: 'Поиск Dynamic-правил',
    search_dynamic_rulesets: 'Поиск Dynamic-правил',
    dynamic_roundstart_rulesets: 'Roundstart-правила',
    dynamic_light_rulesets: 'Лёгкие midround-правила',
    dynamic_heavy_rulesets: 'Тяжёлые midround-правила',
    dynamic_latejoin_rulesets: 'Latejoin-правила',
    dynamic_queued_rulesets: 'Очередь Dynamic-правил',
    dynamic_active_rulesets: 'Уже запущенные Dynamic-правила',
    no_dynamic_queued:
      'В сырой очереди SSdynamic сейчас нет подготовленных правил.',
    no_dynamic_active: 'SSdynamic ещё не запускал правила в текущем раунде.',
    no_dynamic_rulesets_filtered:
      'По текущему фильтру Dynamic-правила не найдены.',
    force_action: 'Принудительный запуск',
    force_next: 'Следующим',
    force_now: 'Запустить сейчас',
    force_now_confirm: 'Запустить сразу?',
    action_search: 'Поиск действий',
    search_storyteller_actions: 'Поиск действий сторителлера',
    search_all_actions:
      'Искать среди положительных, отрицательных и антагонистических событий',
    detected_needs: 'Выявленные проблемы',
    no_detected_needs: 'Проблем, требующих вмешательства, сейчас не выявлено.',
    scheduled_actions: 'Отложенные события',
    no_scheduled_actions: 'Сейчас нет storyteller-событий, ожидающих срабатывания в отложенной очереди.',
    queued_next_actions: 'Очередь следующих событий',
    no_queued_next: 'Очередь принудительных событий сейчас пуста.',
    positive_channel: 'Положительное событие',
    negative_channel: 'Отрицательное событие',
    queued_antagonists: 'Очередь антагонистов',
    no_queued_antags: 'Подготовленных антагонистов в очереди сейчас нет.',
    active_modifiers: 'Активные эффекты',
    no_active_modifiers: 'Сейчас нет активных временных эффектов сторителлера.',
    positive_actions: 'Положительные события',
    negative_actions: 'Отрицательные события',
    antagonist_actions: 'События с антагонистами',
    no_positive_filtered:
      'По текущему фильтру положительных событий не найдено.',
    no_negative_filtered:
      'По текущему фильтру отрицательных событий не найдено.',
    no_antag_filtered:
      'По текущему фильтру событий с антагонистами не найдено.',
    crew_staffing: 'Экипаж и укомплектованность',
    key_jobs_filled: 'Закрыто ключевых ролей',
    cooks_service: 'Кухня / сервис',
    engineers_atmos: 'Инженеры / атмос',
    threats_events: 'Угрозы и события',
    active_round_events: 'Активные события',
    resources_economy: 'Ресурсы и экономика',
    silo_materials: 'Материалы в силосе',
    loose_materials: 'Материалы на станции',
    recent_material_gain: 'Недавний приток материалов',
    structural_condition: 'Состояние станции',
    key_jobs: 'Ключевые роли',
    department_staffing: 'Состав отделов',
    living_antag_types: 'Антагонисты по типам',
    active_event_breakdown: 'Активные события по типам',
    department_money: 'Счета отделов',
    silo_breakdown: 'Материалы в силосе по типам',
    loose_breakdown: 'Материалы на станции по типам',
    recent_decisions: 'Недавние решения',
    no_decisions: 'Сторителлер пока не принимал решений.',
    active_cooldowns: 'Активные кулдауны',
    no_cooldowns: 'Сейчас нет активных кулдаунов семейств.',
    advanced_notes: 'Справка',
    advanced_notes_body:
      'Профили задают характер сторителлера. Они меняют темп событий, рост бюджетов, скорость эскалации и то, насколько охотно система давит на станцию или, наоборот, помогает ей.',
    advanced_notes_footer:
      'Уровни эскалации постепенно открывают более тяжёлые события и антагонистов. Чем дольше и напряжённее идёт раунд, тем шире становится доступный сторителлеру набор.',
    yes: 'Да',
    no: 'Нет',
    ready: 'Готово',
    expired: 'Истекло',
    none: 'Нет',
    chance: 'Шанс',
    cost: 'Цена',
    weight: 'Вес',
    stage: 'Этап',
    active_window: 'Активное окно',
    targets_need: 'Решает проблему',
    discard: 'Отключить',
    discarded: 'Отключено',
    disabled: 'Отключено',
    return_action: 'Вернуть',
    cancel: 'Отменить',
    cancel_queue_confirm: 'Отменить очередь?',
    refund_threat: 'Возврат',
    scheduled_for: 'Сработает в',
    source_storyteller: 'Сторителлер',
    source_admin: 'Администратор',
    enable: 'Включить',
    disable: 'Отключить',
    queue: 'В очередь',
    move_up: 'Выше',
    move_down: 'Ниже',
    move_to_top: 'В начало',
    move_to_bottom: 'В конец',
    set_timer: 'Поставить таймер',
    minutes_short: 'мин',
    execute_now: 'Запустить сейчас',
    remove_from_queue: 'Убрать',
    hide_from_roundend: 'Скрыть из roundend',
    hidden_from_roundend: 'скрыто из roundend',
    show_in_roundend: 'Вернуть в roundend',
    selected_players: 'Выбранные игроки',
    pref: 'Преф',
    unknown: 'Неизвестно',
    severity: 'Критичность',
    priority: 'Приоритет',
    left: 'осталось',
    antagonist_tag: 'антаг',
    dynamic: 'Dynamic',
    extended: 'Extended',
    positive: 'Положительный',
    negative: 'Отрицательный',
    roundstart: 'Раундстарт',
    midround: 'Мидраунд',
    latejoin: 'Лейтджоин',
    balanced: 'Сбалансированный',
    passive: 'Поддерживающий',
    aggressive: 'Агрессивный',
  },
};

export const t = (language: PanelLanguage, key: string) =>
  UI_TEXT[language]?.[key] ?? UI_TEXT.english[key] ?? key;

export const resolveStorytellerLanguage = (
  data: StorytellerLanguageData,
): PanelLanguage => {
  const rememberedPanel = getRememberedUIElementLanguage('storyteller');
  if (rememberedPanel) {
    return rememberedPanel;
  }

  const panelLanguage = data?.panelLanguages?.storyteller;
  if (panelLanguage === 'russian' || panelLanguage === 'english') {
    return panelLanguage;
  }

  const rememberedInterface = getRememberedInterfaceLanguage();
  if (rememberedInterface) {
    return rememberedInterface;
  }

  const interfaceLanguage = `${data?.interfaceLanguage || ''}`.toLowerCase();
  if (interfaceLanguage.startsWith('ru') || interfaceLanguage === 'russian') {
    return 'russian';
  }
  if (interfaceLanguage.startsWith('en') || interfaceLanguage === 'english') {
    return 'english';
  }

  return 'english';
};

export const formatTime = (deciseconds: number, language: PanelLanguage) => {
  const totalSeconds = Math.max(0, Math.floor(deciseconds / 10));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  if (!minutes) {
    return language === 'russian' ? `${seconds}с` : `${seconds}s`;
  }
  return language === 'russian'
    ? `${minutes}м ${seconds}с`
    : `${minutes}m ${seconds}s`;
};

export const formatMode = (
  value: string | undefined,
  language: PanelLanguage,
) => {
  if (!value) {
    return t(language, 'unknown');
  }
  return t(language, value.toLowerCase());
};

export const formatPercent = (value?: number) => {
  if (!value || value <= 0) {
    return '0%';
  }
  return `${value.toFixed(value >= 10 ? 1 : 2)}%`;
};

export const translateNeedTitle = (
  language: PanelLanguage,
  needId: string,
  fallback: string,
) => {
  const mapped: Partial<Record<string, string>> =
    language === 'russian'
      ? {
          food_shortage: 'Нехватка продовольствия',
          engineering_repair_crisis: 'Ремонтный завал в инженерии',
          material_shortage: 'Дефицит материалов',
          medical_surge: 'Перегрузка медотсека',
          security_strain: 'Перегрузка службы безопасности',
          science_shortage: 'Дефицит снабжения в науке',
          janitorial_overload: 'Завал по уборке',
        }
      : {};
  return mapped[needId] || fallback;
};

export const translateNeedSummary = (
  language: PanelLanguage,
  needId: string,
  fallback?: string,
) => {
  if (language !== 'russian') {
    return fallback;
  }
  const mapped: Record<string, string> = {
    food_shortage:
      'Запасов еды на кухне уже не хватает, чтобы уверенно покрывать текущие потребности экипажа.',
    engineering_repair_crisis:
      'Объём повреждений станции уже превышает темп, с которым инженерный отдел успевает разбирать аварии.',
    material_shortage:
      'Запасов материалов и свежей добычи уже недостаточно для текущей нагрузки станции.',
    medical_surge:
      'Медицинский отдел перегружен: поток пострадавших растёт, а запасов и рабочих рук становится недостаточно.',
    security_strain:
      'Служба безопасности перегружена текущей обстановкой и начинает упираться в нехватку людей и расходников.',
    science_shortage:
      'Научный отдел начинает проседать по расходникам, комплектующим и общему темпу работы.',
    janitorial_overload:
      'Объём грязи, мусора и беспорядка на станции растёт быстрее, чем сервис успевает с ним справляться.',
  };
  return mapped[needId] || fallback;
};

export const translateDepartmentLabel = (
  language: PanelLanguage,
  department: string,
) => {
  if (language !== 'russian') {
    return department;
  }
  const mapped: Record<string, string> = {
    'Cargo Budget': 'Карго',
    'Service Budget': 'Сервисный отдел',
    'Engineering Budget': 'Инженерный отдел',
    'Medical Budget': 'Медотсек',
    'Science Budget': 'Научный отдел',
    'Security Budget': 'Служба безопасности',
    'Command Budget': 'Командование',
    'Civilian Budget': 'Гражданский сектор',
  };
  return mapped[department] || department;
};

export const translateFamilyName = (
  language: PanelLanguage,
  family: string,
) => {
  const mapped =
    language === 'russian'
      ? {
          generic: 'Общие события',
          roundstart_antag: 'Раундстарт-антагонисты',
          roundstart_traitor: 'Раундстарт: предатели',
          roundstart_changeling: 'Раундстарт: генокрады',
          roundstart_blood_brothers: 'Раундстарт: кровные братья',
          roundstart_heretics: 'Раундстарт: еретики',
          roundstart_malf_ai: 'Раундстарт: сбой ИИ',
          roundstart_blood_worm: 'Раундстарт: кровавый червь',
          roundstart_vampire: 'Раундстарт: вампиры',
          roundstart_wizard: 'Раундстарт: волшебники',
          roundstart_blood_cult: 'Раундстарт: культ крови',
          roundstart_nukies: 'Раундстарт: ядерные оперативники',
          roundstart_revolution: 'Раундстарт: революция',
          roundstart_spies: 'Раундстарт: шпионы',
          latejoin_hostile: 'Лейтджоин-антагонисты',
          midround_dynamic: 'Мидраунд-антагонисты',
          midround_sleeper: 'Спящие угрозы',
          midround_spiders: 'Пауки',
          midround_pirates: 'Пираты',
          midround_fugitives: 'Беглецы',
          midround_malf_ai: 'Сбой ИИ',
          midround_blob: 'Блоб',
          midround_obsessed: 'Одержимые',
          midround_vampire: 'Вампиры',
          midround_wizard: 'Волшебники',
          midround_nukies: 'Ядерные оперативники',
          midround_xenomorph: 'Ксеноморфы',
          midround_blood_worm: 'Кровавый червь',
          midround_nightmare: 'Кошмары',
          midround_space_dragon: 'Космодракон',
          midround_abductors: 'Абдукторы',
          midround_space_ninja: 'Космический ниндзя',
          midround_revenant: 'Ревенанты',
          midround_space_changeling: 'Космические генокрады',
          midround_paradox: 'Парадоксы',
          midround_voidwalker: 'Странники пустоты',
          midround_morph: 'Морфы',
          midround_slaughter_demon: 'Демоны резни',
          midround_event: 'Мидраунд-события',
          aid_support_drop: 'Поддержка снабжения',
          event_infrastructure: 'Инфраструктурные неполадки',
          event_lifesigns: 'Угрозы для экипажа',
          event_hazard: 'Опасные происшествия',
          event_anomaly: 'Аномальные явления',
          aid_aurora: 'Позитивные атмосферные эффекты',
          event_hoax: 'Ложные тревоги',
          event_space: 'Космические угрозы',
          event_health: 'Медицинские инциденты',
          event_machine: 'Сбои оборудования',
          aid_cargo_sales: 'Поддержка карго',
          aid_cargo_processing: 'Поддержка переработки',
          aid_science_patent: 'Поддержка науки',
          aid_medical_fast_track: 'Поддержка медотсека',
          aid_botany_growth: 'Поддержка ботаники',
          aid_engineering_power: 'Поддержка энергетики',
          event_cargo_sales: 'Экономические сбои',
          event_cargo_processing: 'Сбои переработки',
          event_science_patent: 'Сбои научной работы',
          event_medical_replication: 'Сбои в медицине',
          event_botany_growth: 'Сбои ботаники',
          event_engineering_power: 'Энергетические сбои',
          event_engineering_grid: 'Сбои электросети',
          aid_budget: 'Бюджетная помощь',
          aid_department: 'Помощь отделам',
          aid_materials: 'Материальная помощь',
          aid_medical: 'Медицинская помощь',
          aid_security: 'Поддержка службы безопасности',
          aid_science: 'Поддержка науки',
          aid_janitorial: 'Поддержка уборки',
          aid_morale: 'Поддержка экипажа',
        }
      : {
          generic: 'General Events',
          roundstart_antag: 'Roundstart Antagonists',
          roundstart_traitor: 'Roundstart: Traitors',
          roundstart_changeling: 'Roundstart: Changelings',
          roundstart_blood_brothers: 'Roundstart: Blood Brothers',
          roundstart_heretics: 'Roundstart: Heretics',
          roundstart_malf_ai: 'Roundstart: Malfunctioning AI',
          roundstart_blood_worm: 'Roundstart: Blood Worm',
          roundstart_vampire: 'Roundstart: Vampires',
          roundstart_wizard: 'Roundstart: Wizards',
          roundstart_blood_cult: 'Roundstart: Blood Cult',
          roundstart_nukies: 'Roundstart: Nuclear Operatives',
          roundstart_revolution: 'Roundstart: Revolution',
          roundstart_spies: 'Roundstart: Spies',
          latejoin_hostile: 'Latejoin Antagonists',
          midround_dynamic: 'Midround Antagonists',
          midround_sleeper: 'Sleeper Threats',
          midround_spiders: 'Spiders',
          midround_pirates: 'Pirates',
          midround_fugitives: 'Fugitives',
          midround_malf_ai: 'Malfunctioning AI',
          midround_blob: 'Blob',
          midround_obsessed: 'Obsessed',
          midround_vampire: 'Vampires',
          midround_wizard: 'Wizards',
          midround_nukies: 'Nuclear Operatives',
          midround_xenomorph: 'Xenomorphs',
          midround_blood_worm: 'Blood Worm',
          midround_nightmare: 'Nightmares',
          midround_space_dragon: 'Space Dragon',
          midround_abductors: 'Abductors',
          midround_space_ninja: 'Space Ninja',
          midround_revenant: 'Revenants',
          midround_space_changeling: 'Space Changelings',
          midround_paradox: 'Paradoxes',
          midround_voidwalker: 'Voidwalkers',
          midround_morph: 'Morphs',
          midround_slaughter_demon: 'Slaughter Demons',
          midround_event: 'Midround Events',
          aid_support_drop: 'Supply Support',
          event_infrastructure: 'Infrastructure Failures',
          event_lifesigns: 'Crew Hazards',
          event_hazard: 'Hazard Events',
          event_anomaly: 'Anomaly Events',
          aid_aurora: 'Atmospheric Relief',
          event_hoax: 'False Alarms',
          event_space: 'Space Hazards',
          event_health: 'Medical Incidents',
          event_machine: 'Machine Failures',
          aid_cargo_sales: 'Cargo Support',
          aid_cargo_processing: 'Processing Support',
          aid_science_patent: 'Science Support',
          aid_medical_fast_track: 'Medical Support',
          aid_botany_growth: 'Botany Support',
          aid_engineering_power: 'Power Support',
          event_cargo_sales: 'Economic Disruptions',
          event_cargo_processing: 'Processing Disruptions',
          event_science_patent: 'Research Disruptions',
          event_medical_replication: 'Medical Disruptions',
          event_botany_growth: 'Botany Disruptions',
          event_engineering_power: 'Power Disruptions',
          event_engineering_grid: 'Grid Failures',
          aid_budget: 'Budget Relief',
          aid_department: 'Department Relief',
          aid_materials: 'Material Relief',
          aid_medical: 'Medical Relief',
          aid_security: 'Security Relief',
          aid_science: 'Science Relief',
          aid_janitorial: 'Janitorial Relief',
          aid_morale: 'Crew Morale Support',
        };

  if (mapped[family]) {
    return mapped[family];
  }

  return family
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
};

export const translateProfileName = (
  language: PanelLanguage,
  profileId: string,
  fallback: string,
) => {
  const translated = t(language, profileId || '');
  return translated === profileId ? fallback : translated;
};

const ACTION_DESCRIPTION_TEXT: Record<PanelLanguage, Record<string, string>> = {
  english: {},
  russian: {
    aid_department_supply_pod:
      'Старый relief-под: отправляет инженерный набор, когда сторителлер видит проблему с ремонтом станции.',
    aid_food_relief_pod:
      'Старый relief-под: отправляет еду и кухонные запасы при нехватке пищи.',
    aid_mining_relief_pod:
      'Старый relief-под: отправляет материалы или шахтёрскую помощь при дефиците ресурсов.',
    aid_medical_response_pod:
      'Старый relief-под: отправляет медицинские припасы при всплеске ранений и нагрузки на медотсек.',
    aid_security_response_pod:
      'Старый relief-под: отправляет набор поддержки СБ при высокой угрозе безопасности.',
    aid_science_supply_pod:
      'Старый relief-под: отправляет научные компоненты, если исследовательский отдел проседает.',
    aid_janitorial_cleanup_pod:
      'Старый relief-под: отправляет уборочные средства при сильной загрязнённости станции.',
    aid_morale_pod:
      'Старый relief-под: отправляет ящик с едой и напитками в общественную зону для поддержки экипажа.',
    aid_cargo_budget_grant:
      'Прямой грант карго, если бюджет отдела стал слишком низким для нормальной логистики.',

    station_emergency_maintenance_contract:
      'Контрактный под в лобби карго. Запрашивает инженерные предметы и материалы; при отправке начисляет деньги карго.',
    station_void_echo_front:
      'Локальный PvE-сайт в техах: слабые необычные сущности. После зачистки карго получает кредиты и departmental reward crate.',
    station_atmospheric_recall_drill:
      'Контрактный под для инженерии/атмоса: запрашивает инструменты проверки атмосферы и аварийного реагирования.',
    station_nanotrasen_efficiency_audit:
      'Бюджетное социальное событие: командованию выдаётся грант на координацию быстрых задач отделов.',
    station_bluespace_static_season:
      'Мягкое негативное событие: loose-предметы могут перемещаться по станции из-за блюспейс-помех.',
    station_stationwide_supply_recall:
      'Экономическое давление: карго получает небольшой бюджетный штраф из-за отзыва партии расходников.',
    station_auxiliary_power_rationing:
      'Временный дебафф инженерии: часть энергетических процессов становится менее эффективной.',
    station_civil_defense_broadcast:
      'Положительное командное событие: грант за организацию гражданской проверки безопасности.',
    station_maintenance_pressure_sweep:
      'PvE-сайт в техах: слабые hostile lifeforms и награда после зачистки.',
    station_rare_materials_window:
      'Временный бонус карго/шахты: повышает эффективность обработки добычи и логистики.',
    station_station_insurance_inspection:
      'Контрактный под для командования: запрашивает камеры, плёнку и paperwork для инспекции отделов.',
    station_comms_relay_misroute:
      'Контрактный под для инженерии: запрашивает радио и мультитул для проверки телекоммов.',
    station_cargo_crate_stowaways:
      'PvE-сайт в карго: мелкие hostile stowaways, награда после зачистки.',
    station_warehouse_spoilage_bloom:
      'PvE-сайт в карго/складе: органическая порча и образцы для награды.',
    station_medbay_containment_patient:
      'PvE-сайт в медотсеке: нестабильный пациент/биоугроза, награда медотделу после зачистки.',
    station_paramedic_distress_beacon:
      'Контрактный под для медиков: запрашивает rescue supplies и paperwork для спасательной задачи.',
    station_xenobiology_specimen_escape:
      'PvE-сайт в науке: слабый сбежавший образец, награда отделу после зачистки.',
    station_research_containment_drift:
      'PvE-сайт в науке: аномальный дрейф с малым числом мобов и наградой после стабилизации/зачистки.',
    station_hydroponics_pollination_surge:
      'PvE-сайт сервиса: hostile weeds в гидропонике, награда ботанике/сервису после зачистки.',
    station_kitchen_pest_nest:
      'PvE-сайт сервиса: вредители у кухни, награда после зачистки.',
    station_chapel_restless_shrine:
      'PvE-сайт сервиса/церкви: restless shrine с малыми угрозами и наградой после зачистки.',
    station_library_forbidden_manuscript:
      'Лёгкий PvE/социальный сайт библиотеки: опасная книга, малые угрозы и paperwork-награда.',
    station_brig_evidence_leak:
      'PvE-сайт СБ: evidence storage hazards, награда для охраны после зачистки.',
    station_armory_lockdown_fault:
      'Контрактный под для СБ: запрашивает диагностические предметы для проверки арсенала.',
    station_engineering_coolant_leak:
      'Контрактный под для инженерии: запрашивает аварийные инструменты для coolant leak и уборки риска.',
    station_supermatter_calibration_bonus:
      'Временный инженерный бонус: повышает эффективность энергетики при наличии инженерного персонала.',
    station_disposals_backflow:
      'PvE-сайт сервиса/коридоров: мусор и вредители из disposals, награда после зачистки.',
    station_morgue_misfile:
      'Контрактный под для медиков: запрашивает bodybags и paperwork для ревизии морга.',
    station_telecomms_signal_parasite:
      'PvE-сайт инженерии: signal parasite у телекоммов, награда после зачистки.',
    station_mining_claim_jumper:
      'PvE-сайт карго/шахты: claim-jumper beacon и hostile presence, bounty после зачистки.',
    station_botanical_spore_courier:
      'Контрактный под сервиса: запрашивает семена, plant analyzer и питательные вещества.',
    station_robotics_calibration_swarm:
      'PvE-сайт науки/робототехники: сбойные миниботы, награда деталями после зачистки.',
    station_department_trade_mandate:
      'Контрактный под командования: запрашивает requisition paperwork для межотдельного обмена.',
    station_cross_training_voucher:
      'Контрактный под командования: paperwork для временной помощи сотрудника другому отделу.',
    station_peer_review_request:
      'Контрактный под науки: запрашивает сканеры и paperwork для проверки образца другого отдела.',
    station_safety_buddy_system:
      'Контрактный под командования: запрашивает рации, фонари и paperwork для парной задачи экипажа.',
    station_station_charity_drive:
      'Контрактный под сервиса: запрашивает стартовый набор для charity drive и распределения помощи.',
    station_emergency_blood_drive:
      'Контрактный под медиков: запрашивает кровь, шприцы и анализатор для blood drive.',
    station_cargo_priority_manifest:
      'Контрактный под карго: запрашивает requisition paperwork для приоритетных заказов отделов.',
    station_command_confidence_check:
      'Бюджетное командное событие: грант за объявление станции одного рабочего приоритета.',
    station_departmental_debate_broadcast:
      'Контрактный под командования: paperwork для голосования экипажа по распределению помощи.',
    station_lost_intern_assignment:
      'Контрактный под гражданского направления: набор для сопровождения потерявшегося стажёра.',
    station_salvage_cache_ping:
      'Контрактный под карго: запрашивает salvage materials и инструменты для recovery-задачи.',
    station_centcom_snack_drop:
      'Контрактный под сервиса: запрашивает еду для организованной раздачи через кухню.',
    station_experimental_medigel_trial:
      'Контрактный под медиков: запрашивает medigel trial kit и медицинскую отчётность.',
    station_prototype_part_shipment:
      'Контрактный под науки: запрашивает advanced stock parts для сканирования и установки.',
    station_mining_scanner_alignment:
      'Временный бонус карго/шахты: улучшает mining scanner alignment и обработку добычи.',
    station_public_works_grant:
      'Контрактный под инженерии: запрашивает материалы для ремонта света, уборки и благоустройства.',
  },
};

export const translateActionDescription = (
  language: PanelLanguage,
  actionId: string,
  fallback = '',
) => ACTION_DESCRIPTION_TEXT[language]?.[actionId] || fallback || '';

export const translateReason = (language: PanelLanguage, reason?: string) => {
  if (!reason || language !== 'russian') {
    return reason;
  }
  const exact: Record<string, string> = {
    Ready: 'Готово',
    'Disabled in storyteller config': 'Отключено в настройках сторителлера',
    'Disabled in Dynamic admin panel': 'Отключено в админской панели Dynamic',
    'Discarded by an administrator for this round':
      'Отключено администратором до конца раунда',
    'Discarded for the current storyteller rotation':
      'Отключено на текущую ротацию сторителлера',
    'Blocked by current storyteller mode':
      'Заблокировано текущим режимом сторителлера',
    'Blocked by storyteller phase': 'Заблокировано текущим уровнем эскалации',
    'Requires a matching storyteller need': 'Нужна подходящая проблема станции',
    'Required department is not staffed':
      'В нужном отделе нет доступных сотрудников',
    'Need does not match this action':
      'Для этого события нужна другая проблема',
    'Family cooldown active': 'Это семейство событий ещё на кулдауне',
    'Latejoin hostile lock active': 'Лейтджоин-антаги пока заблокированы',
    'Threat budget below cost': 'Не хватает бюджета давления',
    'Aid budget below cost': 'Не хватает бюджета поддержки',
    'Failed to create ruleset': 'Не удалось создать ruleset',
    'Ruleset cannot currently be selected':
      'Сейчас этот ruleset нельзя выбрать',
    'Round event control unavailable': 'Контроллер события недоступен',
    'Event preconditions failed': 'Событие не прошло встроенные проверки',
    'Conflicting storyteller modifier already active':
      'Уже активен конфликтующий модификатор сторителлера',
    'Admin force bypassed availability checks':
      'Админский форс проигнорировал обычные проверки доступности',
    'No cargo staff are available to capitalize on a logistics contract':
      'В карго нет сотрудников, которые смогли бы воспользоваться логистическим контрактом',
    'No mining or cargo staff are available to use refinery assistance':
      'В карго и на шахте нет людей, которые смогли бы воспользоваться бонусом плавки',
    'No science staff are available to benefit from accelerated patent handling':
      'В научном отделе нет сотрудников, которым пригодилось бы ускоренное оформление патентов',
    'No medical staff are available to benefit from a replication fast-track':
      'В медотсеке нет сотрудников, которым пригодилось бы ускорение репликации',
    'No botanists are available to benefit from accelerated growth':
      'В гидропонике нет ботаников, которые смогли бы воспользоваться ускоренным ростом',
    'No station hydroponics trays are available for a localized growth anomaly':
      'На станции нет доступных гидропонных лотков для локальной аномалии роста',
    'No engineering staff are available to benefit from an engine performance surge':
      'В инженерном отделе нет сотрудников, которым пригодился бы скачок мощности двигателя',
    'No supermatter engine is available for a power surge':
      'На станции нет суперматерии, подходящей для события с энергетическим всплеском',
    'No cargo staff are present for a customs slowdown to matter':
      'В карго нет сотрудников, для которых таможенная задержка имела бы значение',
    'No cargo or mining staff are present for refinery slagging to matter':
      'В карго и на шахте нет сотрудников, для которых засорение печей имело бы значение',
    'No science staff are present for a patent review delay to matter':
      'В научном отделе нет сотрудников, для которых задержка патентной проверки имела бы значение',
    'No medical staff are present for a replication slowdown to matter':
      'В медотсеке нет сотрудников, для которых замедление репликации имело бы значение',
    'No botanists are present for a hydroponics setback to matter':
      'В гидропонике нет ботаников, для которых эта неудача имела бы значение',
    'No supermatter engine is available for an instability event':
      'На станции нет суперматерии, подходящей для события с нестабильностью',
    'No station cables are available for a fault event':
      'На станции нет кабелей, подходящих для аварии электросети',
    'No station APCs are available for a reboot wave':
      'На станции нет АПЦ, подходящих для волны перезагрузки',
    'Cargo budget already healthy':
      'Бюджет карго и так находится в хорошем состоянии',
  };
  if (exact[reason]) {
    return exact[reason];
  }
  if (
    reason.startsWith('Requires at least ') &&
    reason.endsWith(' active crew')
  ) {
    const requiredCrew = reason
      .replace('Requires at least ', '')
      .replace(' active crew', '')
      .trim();
    return `Требуется минимум ${requiredCrew} активных членов экипажа`;
  }
  if (reason === 'Already queued in the storyteller schedule') {
    return 'Событие уже стоит в очереди сторителлера и ждёт своего времени';
  }
  if (reason === 'A related storyteller action is already queued') {
    return 'В очереди сторителлера уже стоит родственное событие';
  }
  if (reason.includes('channel fatigue lock active')) {
    return reason.startsWith('Positive')
      ? 'Канал положительных событий ещё на паузе'
      : 'Канал отрицательных событий ещё на паузе';
  }
  if (
    reason.startsWith('Waiting for ') &&
    reason.endsWith(' scheduling window')
  ) {
    const context = reason
      .replace('Waiting for ', '')
      .replace(' scheduling window', '')
      .trim();
    return `Ожидает окна «${formatMode(context, language)}»`;
  }
  if (reason.startsWith('Admin force bypassed: ')) {
    return `Админский форс проигнорировал ограничения: ${translateReason(
      language,
      reason.replace('Admin force bypassed: ', ''),
    )}`;
  }
  return reason;
};

const normalizeTooltip = (tooltip: string) =>
  tooltip.replace(/\s+/g, ' ').trim();

const RUSSIAN_TOOLTIPS: Record<string, string> = {
  [normalizeTooltip(
    'The current storyteller ruleset. Dynamic enables full pacing, while Extended suppresses roundstart and latejoin hostile storyteller picks and keeps only softer pressure in circulation.',
  )]:
    'Текущий режим работы сторителлера. Dynamic включает полный набор поддержки, отрицательных событий и антагонистов, а Extended оставляет только помощь станции и редкое мягкое давление.',
  [normalizeTooltip(
    'The active storyteller temperament. Profiles retune cadence delays, budget pressure, escalation pace, and how aggressively the subsystem pushes the round.',
  )]:
    'Текущий характер сторителлера. Профиль меняет задержки между событиями, скорость набора бюджетов, темп эскалации и общую агрессивность системы.',
  [normalizeTooltip(
    'The current content gate. Higher stages unlock heavier events and antagonists. By default it escalates automatically unless an admin pins it.',
  )]:
    'Текущий уровень эскалации. Более высокие уровни открывают более тяжёлые события и антагонистов. По умолчанию он растёт автоматически, если админ не зафиксирует его вручную.',
  [normalizeTooltip(
    'The scheduling window the storyteller currently treats as active. During the round this is normally Midround; before setup it is Roundstart.',
  )]:
    'Окно, в котором сторителлер сейчас планирует события. Во время раунда это обычно Midround, а до старта настройки раунда — Roundstart.',
  [normalizeTooltip(
    'Whether the storyteller subsystem is turned on by config at all. If this is off, the panel becomes informational only.',
  )]:
    'Показывает, включён ли сторителлер в конфигурации. Если нет, панель работает только как справочная.',
  [normalizeTooltip(
    'When enabled, storyteller suppresses the natural autonomous pacing from SSdynamic and SSevents and becomes the round pacing owner.',
  )]:
    'Если этот режим включён, сторителлер перехватывает темп раунда и не даёт SSdynamic и SSevents самостоятельно запускать обычные события.',
  [normalizeTooltip(
    'Pausing stops storyteller from scheduling new actions, but does not remove already running modifiers or already queued deliveries.',
  )]:
    'Пауза останавливает планирование новых событий, но не отменяет уже активные эффекты и ранее поставленные в очередь доставки.',
  [normalizeTooltip(
    'Balanced Drama is the baseline. Patient Custodian leans toward relief and slower escalation, while Aggressive Escalation shortens hostile cadence and unlocks heavier pressure faster.',
  )]:
    'Сбалансированный профиль работает как базовый. Поддерживающий чаще помогает станции и медленнее повышает давление, а агрессивный быстрее запускает жёсткие события и ускоряет эскалацию.',
  [normalizeTooltip(
    'Extended keeps relief and mild pressure. Dynamic enables the full storyteller pacing model, including hostile round pressure.',
  )]:
    'Extended оставляет помощь станции и мягкое отрицательное давление. Dynamic включает полный режим сторителлера, включая враждебное давление по ходу раунда.',
  [normalizeTooltip(
    'Switch the storyteller between Dynamic and Extended for the current round. Extended suppresses storyteller antagonists and keeps only support plus softer pressure.',
  )]:
    'Позволяет вручную переключить storyteller между Dynamic и Extended для текущего раунда. Extended отключает storyteller-антагонистов и оставляет только поддержку станции и мягкое давление.',
  [normalizeTooltip(
    'This is the active content gate. Higher stages unlock heavier storyteller actions. By default it escalates automatically with round time, population, casualties, and pressure unless an admin overrides it.',
  )]:
    'Это текущий уровень эскалации. Более высокие уровни открывают более тяжёлые события сторителлера. Обычно он растёт автоматически по мере хода раунда, роста онлайна, потерь и общего давления, если админ не вмешается.',
  [normalizeTooltip(
    'The active connected player count the storyteller is currently reading for scaling population-sensitive timing and action weights.',
  )]:
    'Количество подключённых игроков, которое сторителлер сейчас использует при расчёте таймеров и весов событий, зависящих от онлайна.',
  [normalizeTooltip(
    'Living station crew detected by the storyteller snapshot. This strongly affects staffing checks, aid scaling, and cadence.',
  )]:
    'Количество живых членов экипажа, которое сторителлер видит в текущем состоянии станции. Сильно влияет на проверки укомплектованности, объём помощи и интервалы между событиями.',
  [normalizeTooltip(
    'Count of living antagonists currently detected on station. This feeds danger scoring and slows or blocks some extra hostile pressure.',
  )]:
    'Количество живых антагонистов, которых сторителлер сейчас видит на станции. Влияет на оценку опасности и может притормаживать лишнее враждебное давление.',
  [normalizeTooltip(
    'A structural health estimate versus the storyteller baseline snapshot. Lower integrity increases danger and pushes engineering-focused relief.',
  )]:
    'Оценка общего состояния станции по сравнению с базовым снимком сторителлера. Чем ниже целостность, тем выше опасность и тем сильнее система склоняется к инженерной помощи.',
  [normalizeTooltip(
    'A stability score built from staffing, intact structure, resources, and general station control. Higher control supports more negative pressure.',
  )]:
    'Сводная оценка устойчивости станции: укомплектованность, состояние корпуса, запасы и общий уровень контроля ситуации. Чем она выше, тем больше сторителлер может позволить себе отрицательное давление.',
  [normalizeTooltip(
    'A crisis score built from deaths, explosions, alarms, station damage, active threats, and weak staffing. Higher danger pushes relief and slows extra punishment.',
  )]:
    'Сводная оценка кризиса: смерти, взрывы, тревоги, повреждения станции, активные угрозы и нехватка людей. Чем она выше, тем охотнее сторителлер помогает и тем осторожнее усиливает давление.',
  [normalizeTooltip(
    'Negative storyteller actions spend from this pool. It generally grows when the station is stable enough to withstand more pressure.',
  )]:
    'Из этого запаса тратятся очки на отрицательные события. Обычно он растёт, когда станция достаточно стабильна и способна выдержать дополнительное давление.',
  [normalizeTooltip(
    'Positive storyteller actions spend from this pool. It generally grows when the station is struggling and needs intervention.',
  )]:
    'Из этого запаса тратятся очки на помощь станции. Обычно он растёт, когда ситуация ухудшается и требуется вмешательство.',
  [normalizeTooltip(
    'A short fatigue lock after a positive action fires. While this is active, the aid channel cannot immediately fire again.',
  )]:
    'Короткая пауза после положительного события. Пока она действует, сторителлер не сможет сразу же выдать ещё одну помощь.',
  [normalizeTooltip(
    'Time until the positive channel is allowed to roll again. This scales with round state, population, and prior action impact.',
  )]:
    'Время до следующей проверки положительного события. Интервал зависит от состояния раунда, онлайна и того, насколько сильным было предыдущее вмешательство.',
  [normalizeTooltip(
    'A short fatigue lock after a negative action fires. While this is active, the hostile channel cannot immediately fire again.',
  )]:
    'Короткая пауза после отрицательного события. Пока она действует, сторителлер не сможет сразу же выдать ещё одно давление.',
  [normalizeTooltip(
    'Time until the negative channel is allowed to roll again. This is dynamically scaled by population, damage, casualties, and previous impact.',
  )]:
    'Время до следующей проверки отрицательного события. Интервал динамически зависит от онлайна, повреждений станции, числа жертв и силы предыдущего события.',
  [normalizeTooltip(
    'Set the remaining fatigue pause for the positive channel. While this lock is active, support actions cannot fire again.',
  )]:
    'Задает оставшуюся паузу усталости для положительного канала. Пока она действует, поддержка не сможет сработать снова.',
  [normalizeTooltip(
    'Set the remaining time until the positive channel can roll again.',
  )]:
    'Задает оставшееся время до следующего броска положительного канала.',
  [normalizeTooltip(
    'Set the remaining fatigue pause for the negative channel. While this lock is active, hostile actions cannot fire again.',
  )]:
    'Задает оставшуюся паузу усталости для отрицательного канала. Пока она действует, давление не сможет сработать снова.',
  [normalizeTooltip(
    'Set the remaining time until the negative channel can roll again.',
  )]:
    'Задает оставшееся время до следующего броска отрицательного канала.',
  [normalizeTooltip(
    'Cooldown before another hostile latejoin storyteller antagonist can be assigned.',
  )]:
    'Время до момента, когда сторителлер снова сможет выдать враждебного лейтджоин-антагониста.',
  [normalizeTooltip(
    'The initial start-of-round lock that prevents storyteller latejoin antagonists from firing too early.',
  )]:
    'Стартовая задержка, не позволяющая сторителлеру слишком рано выдавать лейтджоин-антагонистов в начале раунда.',
  [normalizeTooltip(
    'Current cargo department budget. Low cargo funds can increase cargo-focused aid or economic support actions.',
  )]:
    'Текущий бюджет карго. Низкий запас средств может повысить шанс на экономическую поддержку или помощь, связанную с карго.',
  [normalizeTooltip(
    'Active alarms detected across the station. This contributes to danger and several department crisis analyzers.',
  )]:
    'Количество активных тревог по станции. Влияет на оценку опасности и на ряд анализаторов проблем в отделах.',
  [normalizeTooltip(
    "Crew deaths seen within the storyteller's recent tracking window. This strongly increases danger and medical/security response pressure.",
  )]:
    'Смерти экипажа, замеченные сторителлером за последнее время. Сильно повышают опасность и давление на медицину и службу безопасности.',
  [normalizeTooltip(
    'Recent on-station explosions seen within the storyteller tracking window. This boosts danger and several engineering-focused reactions.',
  )]:
    'Недавние взрывы на станции, попавшие в окно отслеживания сторителлера. Они повышают опасность и подталкивают систему к инженерной реакции.',
  [normalizeTooltip(
    'Approximate food stock the storyteller sees in kitchen and service areas. Low values drive food-shortage relief.',
  )]:
    'Примерный объём еды, который сторителлер видит в кухонных и сервисных зонах. Низкие значения подталкивают систему к продовольственной помощи.',
  [normalizeTooltip(
    'Current staffing snapshot for cargo technicians and miners. This affects cargo relief and several mining/material pressure calculations.',
  )]:
    'Текущая численность карготехов и шахтёров. Влияет на карго-помощь и на расчёты давления, завязанные на добычу и материалы.',
  [normalizeTooltip(
    'Approximate breached space exposure versus broken floor tiles. Both feed structural damage estimates, but breaches are treated as more urgent.',
  )]:
    'Примерное соотношение разгерметизированных участков и сломанных полов. Оба показателя влияют на оценку структурного урона, но разгерма считается более срочной проблемой.',
  [normalizeTooltip(
    'Damaged windows and grilles detected by the structural scan. These help measure engineering backlog beyond raw integrity.',
  )]:
    'Повреждённые окна и решётки, обнаруженные структурным сканом. Они помогают понять масштаб инженерного завала помимо общей целостности станции.',
  [normalizeTooltip(
    'Set a specific storyteller temperament manually. Auto returns control to population-weighted random profile selection.',
  )]:
    'Позволяет вручную задать профиль сторителлера. Режим «Авто» возвращает выбор случайному профилю с поправкой на онлайн.',
  [normalizeTooltip(
    'Pins the maximum unlocked storyteller stage manually. Auto hands control back to the automatic escalation model.',
  )]:
    'Позволяет вручную зафиксировать максимальный доступный уровень эскалации. Режим «Авто» возвращает управление обычной модели роста.',
  [normalizeTooltip(
    'Search the storyteller catalog and arm or immediately force an action. Force NOW bypasses normal availability checks.',
  )]:
    'Позволяет найти событие в каталоге сторителлера, поставить его следующим или запустить сразу. «Запустить сейчас» игнорирует обычные проверки доступности.',
  [normalizeTooltip(
    'Delay used by the Queue buttons in the positive, negative, and antagonist lists. Automatic storyteller-picked midround actions use their own fixed five-minute preparation delay.',
  )]:
    'Задержка для кнопки «В очередь» в списках положительных, отрицательных и антагонистических событий. Автоматически выбранные storyteller-события используют отдельную фиксированную пятиминутную подготовку.',
  [normalizeTooltip(
    'All storyteller actions currently waiting in the delayed execution queue, whether they were placed there automatically by storyteller cadence or manually by an administrator.',
  )]:
    'Все события storyteller, которые сейчас стоят в отложенной очереди: как добавленные самим сторителлером по таймингу раунда, так и поставленные администратором вручную.',
  [normalizeTooltip(
    'Antagonists already armed for roundstart, latejoin, or the next storyteller hostile window. Canceling a queued storyteller antag refunds any reserved threat budget.',
  )]:
    'Антагонисты, уже поставленные в очередь для раундстарта, лейтджоина или ближайшего отрицательного окна. При отмене возвращается зарезервированный бюджет давления.',
  [normalizeTooltip(
    'Currently running temporary storyteller buffs and debuffs. These are live round effects with their own timers and department-specific behavior.',
  )]:
    'Временные баффы и дебаффы сторителлера, которые уже действуют в раунде. У каждого есть свой таймер и собственное влияние на соответствующие отделы.',
  [normalizeTooltip(
    'Filters the positive, negative, and antagonist action lists below by name, context, polarity, family, need target, and availability reason.',
  )]:
    'Фильтрует списки положительных, отрицательных и антагонистических событий по названию, контексту, типу, семейству, целевой проблеме и причине недоступности.',
  [normalizeTooltip(
    'All positive storyteller actions currently in the catalog. Chance reflects the current positive candidate pool; unavailable actions remain visible with their blocking reason.',
  )]:
    'Все положительные события из текущего каталога сторителлера. Шанс показывает их вес в текущем положительном пуле, а недоступные события остаются в списке вместе с причиной блокировки.',
  [normalizeTooltip(
    'All non-antagonist negative storyteller actions currently in the catalog. Chance reflects the current negative candidate pool; unavailable actions remain visible with their blocking reason.',
  )]:
    'Все отрицательные события сторителлера без антагонистов. Шанс показывает их вес в текущем отрицательном пуле, а недоступные события остаются видимыми вместе с причиной блокировки.',
  [normalizeTooltip(
    'All storyteller antagonist actions across roundstart, midround, and latejoin contexts. Discard marks an antag as disabled for the rest of the round without removing it from the list.',
  )]:
    'Все антагонистические события сторителлера для раундстарта, мидраунда и лейтджоина. Отключение убирает конкретного антагониста из ротации до конца раунда, но не скрывает его из списка.',
  [normalizeTooltip(
    'The staffing half of the storyteller snapshot. These values feed job coverage checks, department aid routing, and several event weight modifiers.',
  )]:
    'Кадровая часть снимка сторителлера. Эти значения используются для проверки укомплектованности, маршрутизации помощи отделам и изменения весов ряда событий.',
  [normalizeTooltip(
    'How many critical command and department anchor jobs are currently occupied out of the storyteller key-job list.',
  )]:
    'Сколько ключевых ролей из списка сторителлера сейчас реально занято. Этот показатель помогает понять, насколько станция укомплектована опорными профессиями.',
  [normalizeTooltip(
    'Service staffing focus numbers used for food, janitorial, and hospitality-related needs.',
  )]:
    'Численность сервисного персонала, которую сторителлер использует для оценки проблем с едой, уборкой и общим бытовым обеспечением станции.',
  [normalizeTooltip(
    'Engineering and atmospherics staffing counts used for repair, power, and environmental pressure calculations.',
  )]:
    'Численность инженерного и атмосферного персонала, используемая при расчётах ремонта, энергетики и аварий, связанных с окружающей средой.',
  [normalizeTooltip(
    'Cargo office and mining staffing counts used for ore, logistics, and budget relief calculations.',
  )]:
    'Численность карго и шахтёров, которая влияет на расчёты по логистике, добыче и экономической поддержке.',
  [normalizeTooltip(
    'A per-role occupancy breakdown for storyteller-critical jobs such as command, engineering, medical, and other round anchors.',
  )]:
    'Разбивка по конкретным ключевым ролям, важным для сторителлера: командование, инженеры, медики и другие опорные профессии раунда.',
  [normalizeTooltip(
    'A department-level headcount breakdown the storyteller uses for staffing-aware relief and pressure.',
  )]:
    'Разбивка численности по отделам, которую сторителлер использует при выборе помощи и давления с учётом укомплектованности.',
  [normalizeTooltip(
    'The danger-facing half of the storyteller snapshot. These values show live hostile presence and currently running event pressure.',
  )]:
    'Опасная часть снимка сторителлера. Она показывает текущие угрозы, активное давление и общее враждебное присутствие в раунде.',
  [normalizeTooltip(
    'Total living antagonists currently detected by the storyteller snapshot.',
  )]:
    'Общее количество живых антагонистов, которых сторителлер сейчас видит на станции.',
  [normalizeTooltip(
    'The number of currently active round-event instances the storyteller can see right now.',
  )]:
    'Количество активных событий раунда, которые сторителлер сейчас учитывает в своём состоянии.',
  [normalizeTooltip(
    'The number of active alarms currently contributing to the danger picture.',
  )]: 'Количество тревог, которые сейчас участвуют в общей оценке опасности.',
  [normalizeTooltip(
    'A live type breakdown of antagonists the storyteller sees in the current round snapshot.',
  )]:
    'Текущая разбивка живых антагонистов по типам, которую сторителлер видит в этом состоянии раунда.',
  [normalizeTooltip(
    'A live breakdown of currently running round events grouped by event type. This is not a history log; entries disappear once those events end.',
  )]:
    'Текущая разбивка активных событий по типам. Это не история раунда: запись исчезает, когда соответствующее событие завершается.',
  [normalizeTooltip(
    'The supply side of the storyteller snapshot: money, food, ore-silo stock, loose materials, and recent material intake.',
  )]:
    'Снабженческая часть состояния станции: деньги, еда, материалы в силосе, свободные ресурсы на станции и недавний приток сырья.',
  [normalizeTooltip('Current cargo budget available to the station economy.')]:
    'Текущий бюджет карго, доступный экономике станции.',
  [normalizeTooltip(
    'Food stock the storyteller counts in kitchen and service spaces.',
  )]:
    'Запасы еды, которые сторителлер учитывает в кухонных и сервисных помещениях.',
  [normalizeTooltip(
    'Total raw materials currently accessible in the ore silo.',
  )]: 'Общий объём сырья, который сейчас доступен в рудном силосе.',
  [normalizeTooltip(
    'Total loose material stacks found around the station during the heavy scan.',
  )]:
    'Общий объём свободных стопок материалов, найденных по станции во время тяжёлого сканирования.',
  [normalizeTooltip(
    'Change in total known material stock since the previous heavy snapshot. Useful for detecting whether mining is keeping up.',
  )]:
    'Изменение общего объёма известных материалов с прошлого тяжёлого снимка. Помогает понять, успевает ли шахта обеспечивать станцию ресурсами.',
  [normalizeTooltip(
    'Per-department account balances available to the storyteller for budget-aware actions and needs.',
  )]:
    'Баланс счетов по отделам, который сторителлер использует для помощи и событий, завязанных на бюджет.',
  [normalizeTooltip(
    'Raw material stock currently detected in the ore silo, grouped by material type.',
  )]: 'Сырьё, обнаруженное в рудном силосе, с разбивкой по типам материалов.',
  [normalizeTooltip(
    'Loose station-side material stacks grouped by material type.',
  )]: 'Свободные стопки материалов на станции, сгруппированные по типам.',
  [normalizeTooltip(
    'Structural health metrics used to estimate station integrity and the engineering repair backlog.',
  )]:
    'Показатели состояния станции, по которым сторителлер оценивает общую целостность и масштаб инженерного завала.',
  [normalizeTooltip(
    'A high-level estimate of current station integrity compared to the storyteller baseline snapshot.',
  )]:
    'Общая оценка текущей целостности станции по сравнению с базовым снимком сторителлера.',
  [normalizeTooltip(
    'Station breach tiles versus broken floors currently detected by the heavy scan.',
  )]:
    'Соотношение разгерметизированных участков и сломанных полов, обнаруженных тяжёлым сканированием.',
  [normalizeTooltip(
    'Damaged windows and grilles currently detected by the heavy structural scan.',
  )]:
    'Повреждённые окна и решётки, обнаруженные тяжёлым структурным сканированием.',
  [normalizeTooltip(
    'A rolling log of storyteller decisions, scheduling outcomes, forced actions, and major subsystem state changes.',
  )]:
    'Журнал решений сторителлера: результаты планирования, принудительные запуски и важные изменения состояния системы.',
  [normalizeTooltip(
    'Family cooldowns that temporarily block repeated actions from the same storyteller family, to prevent immediate repetition.',
  )]:
    'Кулдауны семейств событий, которые временно не дают сторителлеру сразу повторять однотипные действия.',
  [normalizeTooltip(
    'Low-level SSdynamic controls mirrored here so storyteller admins no longer need to switch back to the legacy Dynamic Panel for common ruleset management.',
  )]:
    'Низкоуровневые настройки SSdynamic, перенесённые сюда, чтобы админам больше не приходилось возвращаться в старую Dynamic Panel ради обычного управления правилами.',
  [normalizeTooltip(
    'The current Dynamic ruleset tier. This mostly matters before round start, since it seeds category counts and timing thresholds for the underlying dynamic backend.',
  )]:
    'Текущий уровень Dynamic. В основном важен до старта раунда, потому что именно он задаёт базовые счётчики категорий и таймеры для внутреннего backend-а Dynamic.',
  [normalizeTooltip(
    'Master low-level toggle for SSdynamic antagonist events. Storyteller can still suppress its own hostile pacing, but this controls whether the backend itself is allowed to pick antag rulesets.',
  )]:
    'Главный низкоуровневый переключатель antag-событий SSdynamic. Сторителлер всё ещё может отдельно подавлять собственное враждебное давление, но именно этот флаг решает, может ли backend Dynamic вообще выбирать антагонистические ruleset-ы.',
  [normalizeTooltip(
    'Raw ruleset counters that the dynamic backend still keeps for roundstart, light midround, heavy midround, and latejoin categories.',
  )]:
    'Сырые счётчики ruleset-ов, которые backend Dynamic по-прежнему хранит отдельно для roundstart, лёгкого midround, тяжёлого midround и latejoin категорий.',
  [normalizeTooltip(
    'A live readout of the underlying dynamic backend: raw unlock timers, cooldowns, base chances, and whether the next backend roll is being forced.',
  )]:
    'Живой срез состояния внутреннего backend-а Dynamic: таймеры открытия пулов, кулдауны, базовые шансы и факт принудительного следующего броска.',
  [normalizeTooltip(
    'The currently active Dynamic tier. This is the backend difficulty band storyteller still relies on for dynamic ruleset baselines.',
  )]:
    'Текущий активный уровень Dynamic. Это внутренняя полоска сложности, на которую storyteller всё ещё опирается при работе с базовыми настройками dynamic ruleset-ов.',
  [normalizeTooltip(
    'Time until the backend light midround pool unlocks naturally.',
  )]:
    'Сколько осталось до естественного открытия лёгкого midround-пула в backend-е Dynamic.',
  [normalizeTooltip(
    'Time until the backend heavy midround pool unlocks naturally.',
  )]:
    'Сколько осталось до естественного открытия тяжёлого midround-пула в backend-е Dynamic.',
  [normalizeTooltip(
    'Time until the backend latejoin antagonist pool unlocks naturally.',
  )]:
    'Сколько осталось до естественного открытия latejoin-пула антагонистов в backend-е Dynamic.',
  [normalizeTooltip(
    'The current backend cooldown before it may attempt another midround ruleset roll.',
  )]:
    'Текущий кулдаун backend-а Dynamic перед следующей попыткой броска midround ruleset-а.',
  [normalizeTooltip(
    'The current backend cooldown before it may attempt another latejoin ruleset roll.',
  )]:
    'Текущий кулдаун backend-а Dynamic перед следующей попыткой броска latejoin ruleset-а.',
  [normalizeTooltip(
    'How many latejoin antagonist attempts the backend has skipped because no eligible joining player satisfied the selected ruleset.',
  )]:
    'Сколько latejoin-попыток backend Dynamic пропустил из-за отсутствия подходящего присоединившегося игрока под выбранный ruleset.',
  [normalizeTooltip(
    'The backend light-midround pick chance after all tier settings and current modifiers are applied.',
  )]:
    'Шанс выбора лёгкого midround-правила после применения всех настроек уровня Dynamic и текущих модификаторов.',
  [normalizeTooltip(
    'The backend heavy-midround pick chance after all tier settings and current modifiers are applied.',
  )]:
    'Шанс выбора тяжёлого midround-правила после применения всех настроек уровня Dynamic и текущих модификаторов.',
  [normalizeTooltip(
    'The backend latejoin pick chance after all tier settings and current modifiers are applied.',
  )]:
    'Шанс выбора latejoin-правила после применения всех настроек уровня Dynamic и текущих модификаторов.',
  [normalizeTooltip(
    'Searches the mirrored SSdynamic ruleset catalog, queued rulesets, and active executed rulesets by name, config id, typepath, and category.',
  )]:
    'Ищет по зеркалу каталога SSdynamic ruleset-ов, очередям и уже запущенным правилам по имени, config id, typepath и категории.',
  [normalizeTooltip(
    'Rulesets currently queued in the raw SSdynamic backend. Roundstart and latejoin entries here are armed independently of storyteller candidate weighting.',
  )]:
    'Ruleset-ы, которые сейчас стоят в сырой очереди SSdynamic. Записи roundstart и latejoin здесь вооружаются независимо от весов storyteller-кандидатов.',
  [normalizeTooltip(
    'Rulesets the raw dynamic backend has already executed this round. You can hide or restore them in the round-end report here.',
  )]:
    'Ruleset-ы, которые raw backend Dynamic уже успел запустить в этом раунде. Здесь их можно скрыть из round-end отчёта или вернуть обратно.',
};

export const translateTooltip = (language: PanelLanguage, tooltip: string) => {
  if (language !== 'russian') {
    return tooltip;
  }
  return RUSSIAN_TOOLTIPS[normalizeTooltip(tooltip)] || tooltip;
};
