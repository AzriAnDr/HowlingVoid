/// Tests that [/datum/job/proc/get_default_roundstart_spawn_point] returns a landmark from all joinable jobs.
/datum/unit_test/maptest_job_roundstart_spawnpoints

/datum/unit_test/maptest_job_roundstart_spawnpoints/Run()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.spawn_positions <= 0)
			// Zero spawn positions means we don't need to care if they don't have a roundstart landmark
			continue
		if(job.get_default_roundstart_spawn_point())
			continue

		TEST_FAIL("Job [job.title] ([job.type]) has no default roundstart spawn landmark.")

/datum/unit_test/ai_spawnpoints_station_only
	var/list/original_start_landmarks
	var/list/original_landmarks
	var/list/original_latejoin_ai_cores

/datum/unit_test/ai_spawnpoints_station_only/Destroy()
	if(!isnull(original_start_landmarks))
		GLOB.start_landmarks_list = original_start_landmarks
	if(!isnull(original_landmarks))
		GLOB.landmarks_list = original_landmarks
	if(!isnull(original_latejoin_ai_cores))
		GLOB.latejoin_ai_cores = original_latejoin_ai_cores
	return ..()

/datum/unit_test/ai_spawnpoints_station_only/Run()
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	TEST_ASSERT(length(station_levels), "No station z-levels were available for AI spawn testing.")

	var/station_z = station_levels[1]
	var/off_station_z
	for(var/z in 1 to world.maxz)
		if(!is_station_level(z))
			off_station_z = z
			break
	TEST_ASSERT_NOTNULL(off_station_z, "No off-station z-level was available for AI spawn testing.")

	var/turf/station_turf = locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y, station_z)
	var/turf/off_station_turf = locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y, off_station_z)
	TEST_ASSERT_NOTNULL(station_turf, "Failed to locate a station turf for AI spawn testing.")
	TEST_ASSERT_NOTNULL(off_station_turf, "Failed to locate an off-station turf for AI spawn testing.")

	original_start_landmarks = GLOB.start_landmarks_list.Copy()
	original_landmarks = GLOB.landmarks_list.Copy()
	original_latejoin_ai_cores = GLOB.latejoin_ai_cores.Copy()

	var/obj/effect/landmark/start/ai/off_station_primary = allocate(/obj/effect/landmark/start/ai, off_station_turf)
	var/obj/effect/landmark/start/ai/station_primary = allocate(/obj/effect/landmark/start/ai, station_turf)
	var/obj/effect/landmark/start/ai/secondary/station_secondary = allocate(/obj/effect/landmark/start/ai/secondary, station_turf)
	var/datum/job/test_job = allocate(/datum/job)

	GLOB.start_landmarks_list = list(off_station_primary, station_secondary, station_primary)
	var/obj/effect/landmark/start/ai/chosen_spawn = test_job.get_station_ai_landmark_spawn_point()
	TEST_ASSERT_EQUAL(chosen_spawn, station_primary, "AI spawn selection should ignore off-station primary landmarks and prefer station primary landmarks.")
	TEST_ASSERT(station_primary.used, "Selected AI spawn landmark was not marked used.")

	station_primary.used = TRUE
	station_secondary.used = FALSE
	GLOB.start_landmarks_list = list(off_station_primary, station_secondary, station_primary)
	chosen_spawn = test_job.get_station_ai_landmark_spawn_point()
	TEST_ASSERT_EQUAL(chosen_spawn, station_secondary, "AI spawn selection should prefer unused station secondary landmarks over used station landmarks.")

	station_secondary.used = TRUE
	GLOB.start_landmarks_list = list(off_station_primary, station_primary)
	chosen_spawn = test_job.get_station_ai_landmark_spawn_point()
	TEST_ASSERT_EQUAL(chosen_spawn, station_primary, "AI spawn selection should fall back to used station landmarks when no unused station landmarks remain.")

	var/obj/structure/ai_core/latejoin_inactive/off_station_core = allocate(/obj/structure/ai_core/latejoin_inactive, off_station_turf)
	off_station_core.safety_checks = FALSE
	var/obj/structure/ai_core/latejoin_inactive/station_core = allocate(/obj/structure/ai_core/latejoin_inactive, station_turf)
	station_core.safety_checks = FALSE

	GLOB.latejoin_ai_cores = list(off_station_core)
	TEST_ASSERT(!test_job.has_station_ai_latejoin_core(), "Off-station latejoin AI cores should not pass the station AI core check.")
	TEST_ASSERT_NULL(test_job.get_station_ai_latejoin_core_spawn_point(), "Off-station latejoin AI cores should not be selected as AI spawn points.")

	GLOB.latejoin_ai_cores = list(off_station_core, station_core)
	TEST_ASSERT(test_job.has_station_ai_latejoin_core(), "Station latejoin AI cores should pass the station AI core check.")
	TEST_ASSERT_EQUAL(test_job.get_station_ai_latejoin_core_spawn_point(), station_turf, "Station latejoin AI cores should be selected as AI spawn points.")

	GLOB.start_landmarks_list = original_start_landmarks
	GLOB.landmarks_list = original_landmarks
	GLOB.latejoin_ai_cores = original_latejoin_ai_cores
