/datum/computer_file/program/cargo_analytics
	filename = "cargoanalytics"
	filedesc = "Cargo Economic Monitor"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Tracks cargo budget flow, station productivity, corporate remittance, retail consumption, and vendor price pressure."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 8
	tgui_id = "NtosCargoAnalytics"
	program_icon = FA_ICON_CHART_LINE

/datum/computer_file/program/cargo_analytics/ui_data(mob/user)
	return SSeconomy.get_cargo_analytics_data()
