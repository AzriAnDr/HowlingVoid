/datum/admins/proc/player_panel_new()//The new one
	if(!check_rights())
		return
	log_admin("[key_name(usr)] checked the player panel.")
	var/dat = "<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge' charset='UTF-8'/><title>Player Panel</title></head>"

	var/ui_scale = owner.prefs.read_preference(/datum/preference/toggle/ui_scale)

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			[!ui_scale && owner.window_scaling ? "<style>body {zoom: [100 / owner.window_scaling]%;}</style>" : ""]

			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByClassName("filter_data");
								var search = lsearch\[0\];
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									tr.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();
				}

				function expand(data_id,target_id){

					job = document.getElementById(data_id+"_job").textContent
					name = document.getElementById(data_id+"_name").textContent
					real_name = document.getElementById(data_id+"_rname").textContent
					old_names = document.getElementById(data_id+"_prevnames").textContent
					key = document.getElementById(data_id+"_key").textContent
					ip = document.getElementById(data_id+"_lastip").textContent
					antagonist = document.getElementById(data_id+"_isantag").textContent
					ref = document.getElementById(data_id+"_ref").textContent

					clearAll();

					var span = document.getElementById(target_id);
					var ckey = key.toLowerCase().replace(/\[^a-z@0-9\]+/g,"");

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b><br><b>Old names: "+old_names+"</b></font>";

					body += "</td><td align='center'>";

					body += "<a href='byond://?_src_=holder;[HrefToken()];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='byond://?_src_=holder;[HrefToken()];showmessageckey="+ckey+"'>N</a> - "
					body += "<a href='byond://?_src_=vars;[HrefToken()];Vars="+ref+"'>VV</a> - "
					body += "<a href='byond://?_src_=vars;[HrefToken()];skill="+ref+"'>SP</a> - "
					body += "<a href='byond://?_src_=holder;[HrefToken()];traitor="+ref+"'>TP</a> - "
					if (job == "Cyborg")
						body += "<a href='byond://?_src_=holder;[HrefToken()];borgpanel="+ref+"'>BP</a> - "
					body += "<a href='byond://?priv_msg="+ckey+"'>PM</a> - "
					body += "<a href='byond://?_src_=holder;[HrefToken()];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow="+ref+"'>FLW</a> - "
					body += "<a href='byond://?_src_=holder;[HrefToken()];individuallog="+ref+"'>LOGS</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='byond://?_src_=holder;[HrefToken()];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!id || !(id.indexOf("item") == 0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\] == id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\] == id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\] == id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='byond://?_src_=holder;[HrefToken()];check_antagonist=1'>Check antagonists</a> - Kick <a href='byond://?_src_=holder;[HrefToken()];kick_all_from_lobby=1;afkonly=0'>everyone</a>/<a href='byond://?_src_=holder;[HrefToken()];kick_all_from_lobby=1;afkonly=1'>AFKers</a> in lobby
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sort_mobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = M.is_antag(NONE)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M) && M.job)
						M_job = M.job
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isalien(M)) //aliens
						if(islarva(M))
							M_job = "Alien larva"
						else
							M_job = ROLE_ALIEN
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "AI"
					else if(ispAI(M))
						M_job = ROLE_PAI
					else if(iscyborg(M))
						M_job = "Cyborg"
					else
						M_job = "Silicon-based"

				else if(isanimal_or_basicmob(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else if(isslime(M))
						M_job = "slime"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(isnewplayer(M))
				M_job = "New player"

			else if(isobserver(M))
				var/mob/dead/observer/O = M
				if(O.started_as_observer)//Did they get BTFO or are they just not trying?
					M_job = "Observer"
				else
					M_job = "Ghost"

			var/M_key = html_encode(M.key)
			var/M_ip_address = isnull(M.lastKnownIP) ? "+localhost+" : M.lastKnownIP
			var/M_name = html_encode(M.name)
			var/M_rname = html_encode(M.real_name)
			var/M_rname_as_key = html_encode(ckey(M.real_name)) // so you can ignore punctuation
			if(M_rname == M_rname_as_key)
				M_rname_as_key = null

			var/previous_names_string = ""
			if(M.persistent_client)
				previous_names_string = M.persistent_client.get_played_names()

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("data[i]","item[i]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						<span hidden class='filter_data'>[M_name] [M_rname] [M_rname_as_key] [M_key] [M_job] [previous_names_string]</span>
						<span hidden id="data[i]_name">[M_name]</span>
						<span hidden id="data[i]_job">[M_job]</span>
						<span hidden id="data[i]_rname">[M_rname]</span>
						<span hidden id="data[i]_rname_as_key">[M_rname_as_key]</span>
						<span hidden id="data[i]_prevnames">[previous_names_string]</span>
						<span hidden id="data[i]_key">[M_key]</span>
						<span hidden id="data[i]_lastip">[M_ip_address]</span>
						<span hidden id="data[i]_isantag">[is_antagonist]</span>
						<span hidden id="data[i]_ref">[REF(M)]</span>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	var/window_size = "size=600x480"
	if(owner.window_scaling && ui_scale)
		window_size = "size=[600 * owner.window_scaling]x[400 * owner.window_scaling]"

	usr << browse(dat, "window=players;[window_size]")


// BEGIN NOVA CORE MIGRATION: code/modules/admin/player_panel.dm
GLOBAL_LIST_INIT(mute_bits, list(
	list(name = "IC", bitflag = MUTE_IC),
	list(name = "OOC", bitflag = MUTE_OOC),
	list(name = "LOOC", bitflag = MUTE_LOOC),
	list(name = "Pray", bitflag = MUTE_PRAY),
	list(name = "Ahelp", bitflag = MUTE_ADMINHELP),
	list(name = "Deadchat", bitflag = MUTE_DEADCHAT)
))

GLOBAL_DATUM_INIT(admin_state, /datum/ui_state/admin_state, new)

/datum/ui_state/admin_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_ADMIN))
		return UI_INTERACTIVE
	return UI_CLOSE

GLOBAL_LIST_INIT(pp_limbs, list(
	"Head" 		= BODY_ZONE_HEAD,
	"Left leg" 	= BODY_ZONE_L_LEG,
	"Right leg" = BODY_ZONE_R_LEG,
	"Left arm" 	= BODY_ZONE_L_ARM,
	"Right arm" = BODY_ZONE_R_ARM
))

/datum/player_panel
	var/mob/targetMob
	var/client/targetClient

/datum/player_panel/New(mob/target)
	. = ..()
	targetMob = target

/datum/player_panel/Destroy(force, ...)
	targetMob = null
	targetClient = null

	SStgui.close_uis(src)
	return ..()

/datum/player_panel/ui_interact(mob/user, datum/tgui/ui)
	if(!targetMob)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PlayerPanel", "[targetMob.real_name] Player Panel")
		ui.open()

/datum/player_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/player_panel/ui_data(mob/user)
	. = list()
	.["mob_name"] = targetMob.real_name
	.["mob_type"] = targetMob.type
	.["admin_mob_type"] = user.client?.mob.type
	.["godmode"] = HAS_TRAIT(user, TRAIT_GODMODE)

	var/mob/living/L = targetMob
	if (istype(L))
		.["is_frozen"] = L.admin_frozen
		.["is_slept"] = L.admin_sleeping
		.["mob_scale"] = L.current_size

	if(targetMob.client)
		targetClient = targetMob.client
		.["client_ckey"] = targetClient.ckey
		.["client_muted"] = targetClient.prefs.muted
		.["client_rank"] = targetClient.holder ? targetClient.holder.ranks : "Player"
	else
		targetClient = null
		.["client_ckey"] = null

		if (targetMob.ckey)
			.["last_ckey"] = copytext(targetMob.ckey, 2)

/datum/player_panel/ui_static_data()
	. = list()

	.["transformables"] = GLOB.pp_transformables
	.["glob_limbs"] = GLOB.pp_limbs
	.["glob_mute_bits"] = GLOB.mute_bits
	.["current_time"] = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")

	if(targetClient)
		var/byond_version = "Unknown"
		if(targetClient.byond_version)
			byond_version = "[targetClient.byond_version].[targetClient.byond_build ? targetClient.byond_build : "xxx"]"
		.["data_byond_version"] = byond_version
		.["data_player_join_date"] = targetClient.player_join_date
		.["data_account_join_date"] = targetClient.account_join_date
		.["data_related_cid"] = targetClient.related_accounts_cid
		.["data_related_ip"] = targetClient.related_accounts_ip
		/* // Find relevant PR maybe?
		var/datum/player_details/deets = GLOB.player_details[targetClient.ckey]
		.["data_old_names"] = deets.get_played_names() || null
		*/
		var/list/player_ranks = list()
		if(SSplayer_ranks.is_donator(targetClient, admin_bypass = FALSE))
			player_ranks += "Donator"
		if(SSplayer_ranks.is_mentor(targetClient, admin_bypass = FALSE))
			player_ranks += "Mentor"
		if(SSplayer_ranks.is_nova_star(targetClient, admin_bypass = FALSE))
			player_ranks += "Nova Star"
		.["ranks"] = length(player_ranks) ? player_ranks.Join(", ") : null

		if(CONFIG_GET(flag/use_exp_tracking))
			.["playtimes_enabled"] = TRUE
			.["playtime"] = targetMob.client.get_exp_living()

/datum/player_panel/ui_act(action, params, datum/tgui/ui)
	. = ..()

	var/mob/adminMob = ui.user
	var/client/adminClient = adminMob.client

	if(. || !check_rights_for(adminClient, R_ADMIN))
		message_admins(span_adminhelp("WARNING: NON-ADMIN [ADMIN_LOOKUPFLW(adminMob)] ATTEMPTED TO ACCESS ADMIN PANEL. NOTIFY Casper3044."))
		to_chat(adminClient, "Error: you are not an admin!")
		return

	switch(action)
		// If this mob used to be player controlled but isn't anymore, this action will open the player panel for the mob that player is now controlling.
		if ("open_latest_panel")
			if (targetMob.client || !targetMob.ckey)
				return

			// Remove '@' from the start of the ckey.
			var/ckey = copytext(targetMob.ckey, 2)
			var/mob/latestMob = get_mob_by_ckey(ckey)

			if(!latestMob)
				to_chat(adminClient, span_warning("That ckey is not controlling a mob."))
				return

			if(targetMob == latestMob)
				return

			to_chat(adminClient, span_notice("New mob found for player: [targetMob.ckey] ([latestMob])."))
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/show_player_panel, latestMob)

		/// Edits player Rank
		if ("edit_rank")
			if (!targetMob.client?.ckey)
				return

			var/list/context = list()

			context["key"] = targetMob.client.ckey

			if (GLOB.admin_datums[targetMob.client.ckey] || GLOB.deadmins[targetMob.client.ckey])
				context["editrights"] = "rank"
			else
				context["editrights"] = "add"

			adminClient.holder.edit_rights_topic(context)

		/// Opens the view variables list
		if ("access_variables")
			adminClient.debug_variables(targetMob)

		/// Sees selected player/client playtime
		if ("access_playtimes")
			if (targetMob.client)
				adminClient.holder.cmd_show_exp_panel(targetMob.client)

		/// Privately messages player
		if ("private_message")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/cmd_admin_pm_context, targetMob)

		/// Subtly messages selected mob (requires target to have a headset)
		if ("subtle_message")
			var/list/subtle_message_options = list("Voice in head", RADIO_CHANNEL_CENTCOM, RADIO_CHANNEL_SYNDICATE)
			var/sender = tgui_input_list(adminClient, "Choose the method of subtle messaging", "Subtle Message", subtle_message_options)
			if (!sender)
				return

			var/msg = input("Contents of the message", text("Subtle PM to [targetMob.key]")) as text
			if (!msg)
				return

			if (sender == "Voice in head")
				to_chat(targetMob, "<i>You hear a voice in your head... <b>[msg]</i></b>")
			else
				var/mob/living/carbon/human/selected_mob = targetMob

				if(!istype(selected_mob))
					to_chat(adminClient, "The person you are trying to contact is not human. Unsent message: [msg]")
					return

				if(!istype(selected_mob.ears, /obj/item/radio/headset))
					to_chat(adminClient, "The person you are trying to contact is not wearing a headset. Unsent message: [msg]")
					return

				to_chat(selected_mob, "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from [sender == RADIO_CHANNEL_SYNDICATE ? "your benefactor" : "Central Command"].  Message as follows[sender == RADIO_CHANNEL_SYNDICATE ? ", agent." : ":"] <span class='bold'>[msg].</span> Message ends.\"")


			log_admin("SubtlePM ([sender]): [key_name(adminClient)] -> [key_name(targetMob)] : [msg]")
			msg = span_adminnotice("<b> SubtleMessage ([sender]): [key_name_admin(adminClient)] -> [key_name_admin(targetMob)] :</b> [msg]")
			message_admins(msg)
			admin_ticket_log(targetMob, msg)

		/// Forces a name change on selected player
		if ("set_name")
			targetMob.vv_auto_rename(params["name"])

		/// Admin heals
		if ("heal")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/cmd_admin_rejuvenate, targetMob)

		/// Forces selected player/client into ghost, disconnecting them from mob.
		if ("ghost")
			if(targetMob.client)
				log_admin("[key_name(adminClient)] ejected [key_name(targetMob)] from their body.")
				message_admins("[key_name_admin(adminClient)] ejected [key_name_admin(targetMob)] from their body.")
				to_chat(targetMob, span_danger("An admin has ejected you from your body."))
				targetMob.ghostize(FALSE)

		/// offers control to ghosts for selected mob/body
		if ("offer_control")
			offer_control(targetMob)

		/// Steals control from selected client's body
		if ("take_control")
			// Disassociates observer mind from the body mind
			if(targetMob.client)
				targetMob.ghostize(FALSE)
			else
				for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
					if(targetMob.mind == ghost.mind)
						ghost.mind = null

			targetMob.ckey = adminMob.ckey
			qdel(adminMob)

			message_admins(span_adminnotice("[key_name_admin(adminClient)] took control of [targetMob]."))
			log_admin("[key_name(adminClient)] took control of [targetMob].")
			addtimer(CALLBACK(targetMob.mob_panel, TYPE_PROC_REF(/datum, ui_interact), targetMob), 0.1 SECONDS)

		/// Smites selected Client/Target
		if ("smite")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/admin_smite, targetMob)

		/// Brings selected Client/target
		if ("bring")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/get_mob, targetMob)

		/// Orbits arround selected Target
		if ("orbit")
			if(!isobserver(adminMob))
				SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/admin_ghost)
			var/mob/dead/observer/satellite = adminClient.mob
			satellite.ManualFollow(targetMob)

		/// Jumps to selected mob
		if ("jump_to")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/jump_to_mob, targetMob)

		/// Forces the selected mob/client to stop moving
		if ("freeze")
			var/mob/living/living_mob = targetMob
			if (istype(living_mob))
				living_mob.toggle_admin_freeze(adminClient)

		/// Forces slected mob/client to sleep
		if ("sleep")
			var/mob/living/living_mob = targetMob
			if (istype(living_mob))
				living_mob.toggle_admin_sleep(adminClient)

		/// Yeets target client to the lobby (only works on ghosts)
		if ("lobby")
			if(!isobserver(targetMob))
				to_chat(adminClient, span_notice("You can only send ghost players back to the Lobby."))
				return

			if(!targetMob.client)
				to_chat(adminClient, span_warning("[targetMob] doesn't seem to have an active client."))
				return

			log_admin("[key_name(adminClient)] has sent [key_name(targetMob)] back to the Lobby.")
			message_admins("[key_name(adminClient)] has sent [key_name(targetMob)] back to the Lobby.")

			var/mob/dead/new_player/new_connected_player = new()
			new_connected_player.ckey = targetMob.ckey
			qdel(targetMob)

		/// Selects admin equipmeent via Equipment UI on the selected player/mob
		if ("select_equipment")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/select_equipment, targetMob)

		/// Forces selecteed client to drop all their stuff (SPREAD YOUR SHIT)
		if ("strip")
			for(var/obj/item/begone_items in targetMob)
				targetMob.dropItemToGround(begone_items, TRUE) //The TRUE forces all items to drop, since this is an admin undress.

		/// Forces selected client into cryo storage
		if ("cryo")
			targetMob.vv_send_cryo()

		/// Forces selected client to say things against their will
		if ("force_say")
			targetMob.say(params["to_say"], forced="admin")

		/// Forces selected client to emote against their will
		if ("force_emote")
			if (params["to_emote"])
				QUEUE_OR_CALL_VERB_FOR(VERB_CALLBACK(targetMob, TYPE_PROC_REF(/mob, emote), "me", EMOTE_VISIBLE|EMOTE_AUDIBLE, params["to_emote"], TRUE), SSspeech_controller)

		/// Sends the offender to SUPERJAIL known as SPACE PRISON (admin prison)
		if ("prison")
			if(isAI(targetMob))
				to_chat(adminClient, "This cannot be used on instances of type /mob/living/silicon/ai.")
				return

			targetMob.forceMove(pick(GLOB.prisonwarp))
			to_chat(targetMob, span_userdanger("You have been sent to Prison!"))

			log_admin("[key_name(adminClient)] has sent [key_name(targetMob)] to Prison!")
			message_admins("[key_name_admin(adminClient)] has sent [key_name_admin(targetMob)] to Prison!")

		/// Boots the offending client from the server
		if ("kick")
			if(!check_if_greater_rights_than(targetClient))
				to_chat(adminClient, span_danger("Error: They have more rights than you do."), confidential = TRUE)
				return
			if(tgui_alert(adminMob, "Kick [key_name(targetMob)]?", "Confirm", list("Yes", "No")) != "Yes")
				return
			if(!targetMob)
				to_chat(adminClient, span_danger("Error: [targetMob] no longer exists!"), confidential = TRUE)
				return
			if(!targetClient)
				to_chat(adminClient, span_danger("Error: [targetMob] no longer has a client!"), confidential = TRUE)
				return
			to_chat(targetMob, span_danger("You have been kicked from the server by [adminClient.holder.fakekey ? "an Administrator" : "[adminClient.key]"]."), confidential = TRUE)
			log_admin("[key_name(adminClient)] kicked [key_name(targetMob)].")
			message_admins(span_adminnotice("[key_name_admin(adminClient)] kicked [key_name_admin(targetMob)]."))
			qdel(targetClient)

		/// Bans target
		if ("ban")
			var/player_key = targetMob.key
			var/player_ip = targetMob.client.address
			var/player_cid = targetMob.client.computer_id
			adminClient.holder.ban_panel(player_key, player_ip, player_cid)

		/// Stickbans target
		if ("sticky_ban")
			var/list/ban_settings = list()
			if(targetMob.client)
				ban_settings["ckey"] = targetMob.ckey
			adminClient.holder.stickyban("add", ban_settings)

		/// Opens selected target's Notes
		if ("notes")
			if (targetMob.client)
				browse_messages(target_ckey = ckey(targetMob.ckey))

		/// Opens selected target's logs
		if ("logs")
			var/source = targetMob.client ? LOGSRC_CKEY : LOGSRC_MOB
			show_individual_logging_panel(targetMob, source)

		/// Just mutes
		if ("mute")
			if(!targetMob.client)
				return

			targetMob.client.prefs.muted = text2num(params["mute_flag"])
			log_admin("[key_name(adminClient)] set the mute flags for [key_name(targetMob)] to [targetMob.client.prefs.muted].")

		/// MUTES EVERYBODY (NO ONE GETS TALKING STICK!!!)
		if ("mute_all")
			if(!targetMob.client)
				return

			for(var/bit in GLOB.mute_bits)
				targetMob.client.prefs.muted |= bit["bitflag"]

			log_admin("[key_name(adminClient)] mass-muted [key_name(targetMob)].")

		/// Unmutes EVERYBODY
		if ("unmute_all")
			if(!targetMob.client)
				return

			for(var/bit in GLOB.mute_bits)
				targetMob.client.prefs.muted &= ~bit["bitflag"]

			log_admin("[key_name(adminClient)] mass-unmuted [key_name(targetMob)].")

		/// Looks for related account data to the selected mob
		if ("related_accounts")
			if(targetMob.client)
				var/related_accounts
				if (params["related_thing"] == "CID")
					related_accounts = targetMob.client.related_accounts_cid
				else
					related_accounts = targetMob.client.related_accounts_ip

				related_accounts = splittext(related_accounts, ", ")

				var/list/dat = list("Related accounts by [params["related_thing"]]:")
				dat += related_accounts
				adminClient << browse(dat.Join("<br>"), "window=related_[targetMob.client];size=420x300")

		/// Transforms the selected mob
		if ("transform")
			var/choice = params["newType"]
			if (choice == "/mob/living")
				choice = tgui_input_list(adminClient, "What should this mob transform into", "Mob Transform", subtypesof(choice))
				if (!choice)
					return

			adminClient.holder.transformMob(targetMob, adminMob, choice, params["newTypeName"])

		/// Gives targeted mob GOD (its only invulnerability)
		if ("toggle_godmode")
			adminClient.cmd_admin_godmode(targetMob)

		/// Gives targeted mob spells (shadow wizard money gang)
		if ("spell")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/give_spell, targetMob)

		/// Gives targeted mob quirks
		if ("martial_art")
			adminClient.teach_martial_art(targetMob)

		/// Sets targeted mob's quirks
		if ("quirk")
			adminClient.toggle_quirk(targetMob)

		/// Sets targeted mob's species
		if ("species")
			adminClient.set_species(targetMob)

		/// Delimbs targeted mob (SNAAAAAAAAAAKE!!!!)
		if ("limb")
			if(!params["limbs"] || !ishuman(targetMob))
				return

			var/mob/living/carbon/human/punished_mob = targetMob

			for(var/limb in params["limbs"])
				if (!limb)
					continue

				if (params["delimb_mode"])
					var/obj/item/bodypart/targeted_limb = punished_mob.get_bodypart(limb)
					if (!targeted_limb)
						continue
					targeted_limb.dismember()
					playsound(punished_mob, 'sound/effects/bamf.ogg', 70)
				else
					punished_mob.regenerate_limb(limb)

		/// Assigns selected olayer/client's scale
		if ("scale")
			var/mob/living/local_mob_data = targetMob
			if(!isnull(params["new_scale"]) && istype(local_mob_data))
				local_mob_data.vv_edit_var("current_size", params["new_scale"])

		/// Explodes the selected player with assigned power and blasts (for the funny of course!)
		if ("explode")
			var/power = text2num(params["power"])
			var/empMode = text2num(params["emp_mode"])


			var/turf/target_turf = get_turf(adminMob)
			message_admins("[ADMIN_LOOKUPFLW(adminClient)] created an admin [empMode ? "EMP" : "explosion"] at [ADMIN_VERBOSEJMP(target_turf)].")
			log_admin("[key_name(adminClient)] created an admin [empMode ? "EMP" : "explosion"] at [adminMob.loc].")

			if (empMode)
				empulse(adminMob, power, power / 2, TRUE)
			else
				explosion(adminMob, power / 3, power / 2, power, power, ignorecap = TRUE)

		/// Narrates typed texxt to the selected client's chatboxx
		if ("narrate")
			var/list/stylesRaw = params["classes"]

			var/styles = ""
			for(var/style in stylesRaw)
				styles += "[style]:[stylesRaw[style]];"

			if (params["mode_global"])
				to_chat(world, "<span style='[styles]'>[params["message"]]</span>")
				log_admin("GlobalNarrate: [key_name(adminClient)] : [params["message"]]")
				message_admins(span_adminnotice("[key_name_admin(adminClient)] Sent a global narrate"))
			else
				for(var/mob/Mob_individual in view(params["range"], adminMob))
					to_chat(Mob_individual, "<span style='[styles]'>[params["message"]]</span>")

				log_admin("LocalNarrate: [key_name(adminClient)] at [AREACOORD(adminMob)]: [params["message"]]")
				message_admins(span_adminnotice("<b> LocalNarrate: [key_name_admin(adminClient)] at [ADMIN_VERBOSEJMP(adminMob)]:</b> [params["message"]]<BR>"))

		/// Opens languages panel for the selected player/client
		if ("languages")
			var/datum/language_holder/selected_character = targetMob.get_language_holder()
			selected_character.open_language_menu(adminMob)

		/// Opens the Traitor Panel for the selected player/client
		if ("traitor_panel")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/show_traitor_panel, targetMob)

		/// Opens the selected player/client's skills panel
		if ("skill_panel")
			SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/show_skill_panel, targetMob)

		/// Forces a commendation to selected client/player
		if ("commend")
			if(!targetMob.ckey)
				to_chat(adminClient, span_warning("This mob either no longer exists or no longer is being controlled by someone!"))
				return

			switch(tgui_alert(adminMob, "Would you like the effects to apply immediately or at the end of the round? Applying them now will make it clear it was an admin commendation.", "<3?", list("Apply now", "Apply at round end", "Cancel")))
				if("Apply now")
					targetMob.receive_heart(adminMob, instant = TRUE)
				if("Apply at round end")
					targetMob.receive_heart(adminMob)

		/// Plays a selected sound to target client
		if ("play_sound_to")
			var/soundFile = input("", "Select a sound file",) as null|sound

			if(soundFile && targetMob)
				SSadmin_verbs.dynamic_invoke_verb(adminClient, /datum/admin_verb/play_direct_mob_sound, soundFile, targetMob)

		/// Applies selected client's quirks
		if ("apply_client_quirks")
			var/mob/living/carbon/human/specified_humanoid = targetMob
			if(!istype(specified_humanoid))
				to_chat(adminClient, "this can only be used on instances of type /mob/living/carbon/human.", confidential = TRUE)
				return
			if(!specified_humanoid.client)
				to_chat(adminClient, "[specified_humanoid] has no client!", confidential = TRUE)
				return
			SSquirks.AssignQuirks(specified_humanoid, specified_humanoid.client)
			log_admin("[key_name(adminClient)] applied client quirks to [key_name(specified_humanoid)].")
			message_admins(span_adminnotice("[key_name_admin(adminClient)] applied client quirks to [key_name_admin(specified_humanoid)]."))
// END NOVA CORE MIGRATION: code/modules/admin/player_panel.dm
