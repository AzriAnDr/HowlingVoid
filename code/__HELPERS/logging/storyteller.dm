/// Logging for storyteller decisions and decision traces.
/proc/log_storyteller(text, list/data)
	logger.Log(LOG_CATEGORY_STORYTELLER, text, data)
