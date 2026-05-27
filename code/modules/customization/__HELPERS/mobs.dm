/proc/accessory_list_of_key_for_species(key, datum/species/species, mismatched, ckey)
	var/list/accessory_list = list()
	for(var/name in SSaccessories.sprite_accessories[key])
		var/datum/sprite_accessory/sprite_accessory = SSaccessories.sprite_accessories[key][name]
		if(sprite_accessory.locked)
			continue
		if(!mismatched && sprite_accessory.recommended_species && isnull(sprite_accessory.recommended_species[species.id]))
			continue
		accessory_list += sprite_accessory.name
	return accessory_list


/proc/random_accessory_of_key_for_species(key, datum/species/species, mismatched = FALSE, ckey)
	var/list/accessory_list = accessory_list_of_key_for_species(key, species, mismatched, ckey)
	var/datum/sprite_accessory/sprite_accessory = SSaccessories.sprite_accessories[key][pick(accessory_list)]
	if(isnull(sprite_accessory))
		CRASH("Cant find random accessory of [key] key, for species [species.id]")
	return sprite_accessory

/proc/assemble_body_markings_from_set(datum/body_marking_set/marking_set, list/features, datum/species/species)
	var/list/body_markings = list()
	for(var/set_name in marking_set.body_marking_list)
		var/marking_name = get_marking_base_name(set_name)
		var/datum/body_marking/body_marking = GLOB.body_markings[set_name] || GLOB.body_markings[marking_name]
		if(!body_marking)
			continue
		for(var/zone, markings in GLOB.body_markings_per_limb)
			var/list/marking_list = markings
			if(marking_name in marking_list)
				if(isnull(body_markings[zone]))
					body_markings[zone] = list()
				var/layer = length(body_markings[zone]) + MARKING_LAYER_MIN
				var/key = compose_marking_key(marking_name, layer, null, body_markings[zone])
				body_markings[zone][key] = list(body_marking.get_default_color(features, species), FALSE, layer)
	return body_markings

/proc/sanitize_marking_layer(layer)
	return sanitize_integer(layer, MARKING_LAYER_MIN, MARKING_LAYER_MAX, MARKING_LAYER_MIN)

/proc/ensure_marking_entry_length(list/entry, required_length = MARKING_INDEX_LAYER)
	if(!islist(entry))
		return list()
	while(length(entry) < required_length)
		entry += null
	return entry

/proc/get_marking_base_name(marking_key)
	if(!istext(marking_key))
		return marking_key

	var/delim_index = findtext(marking_key, MARKING_KEY_LAYER_DELIM)
	if(delim_index)
		return trimtext(copytext(marking_key, 1, delim_index))

	return trimtext(marking_key)

/proc/get_marking_sequence(marking_key)
	if(!istext(marking_key))
		return 1

	var/sequence_index = findtext(marking_key, MARKING_KEY_SEQUENCE_DELIM)
	if(sequence_index)
		var/sequence_text = trimtext(copytext(marking_key, sequence_index + length(MARKING_KEY_SEQUENCE_DELIM)))
		var/sequence_value = text2num(sequence_text)
		if(sequence_value)
			return sequence_value
	return 1

/proc/get_marking_layer(marking_key, list/marking_data, default_layer = MARKING_LAYER_MIN)
	if(islist(marking_data) && length(marking_data) >= MARKING_INDEX_LAYER && !isnull(marking_data[MARKING_INDEX_LAYER]))
		return sanitize_marking_layer(marking_data[MARKING_INDEX_LAYER])

	if(istext(marking_key))
		var/delim_index = findtext(marking_key, MARKING_KEY_LAYER_DELIM)
		if(delim_index)
			var/layer_start = delim_index + length(MARKING_KEY_LAYER_DELIM)
			var/sequence_index = findtext(marking_key, MARKING_KEY_SEQUENCE_DELIM, layer_start)
			var/layer_text = sequence_index ? copytext(marking_key, layer_start, sequence_index) : copytext(marking_key, layer_start)
			var/parsed_layer = text2num(trimtext(layer_text))
			if(parsed_layer)
				return sanitize_marking_layer(parsed_layer)

	return sanitize_marking_layer(default_layer)

/proc/compose_marking_key(marking_name, layer, sequence, list/existing_keys)
	var/sanitized_name = trimtext(marking_name)
	if(!length(sanitized_name))
		sanitized_name = marking_name
	var/sanitized_layer = sanitize_marking_layer(layer)
	var/final_sequence = isnull(sequence) ? 1 : sequence
	var/key = "[sanitized_name][MARKING_KEY_LAYER_DELIM][sanitized_layer]"
	var/final_key = "[key][MARKING_KEY_SEQUENCE_DELIM][final_sequence]"
	while(existing_keys && existing_keys[final_key])
		final_sequence++
		final_key = "[key][MARKING_KEY_SEQUENCE_DELIM][final_sequence]"
	return final_key

/proc/sanitize_body_marking_entry(marking_key, marking_data, default_layer = MARKING_LAYER_MIN, list/features, datum/species/species)
	var/list/entry
	if(islist(marking_data))
		var/list/list_value = marking_data
		entry = list_value.Copy()
	else
		entry = list(marking_data)

	entry = ensure_marking_entry_length(entry)
	var/base_name = get_marking_base_name(marking_key)
	var/datum/body_marking/body_marking = GLOB.body_markings[base_name]

	var/default_color
	if(body_marking && islist(features))
		default_color = body_marking.get_default_color(features, species)
	if(!default_color)
		default_color = "#ffffff"

	entry[MARKING_INDEX_COLOR] = sanitize_hexcolor(entry[MARKING_INDEX_COLOR], default = default_color)
	entry[MARKING_INDEX_EMISSIVE] = sanitize_integer(entry[MARKING_INDEX_EMISSIVE], FALSE, TRUE, FALSE)
	entry[MARKING_INDEX_LAYER] = get_marking_layer(marking_key, entry, default_layer)
	return entry

/proc/sanitize_marking_map(list/body_markings_by_zone, list/features, datum/species/species)
	var/list/sanitized = list()
	if(!islist(body_markings_by_zone))
		return sanitized

	for(var/zone in body_markings_by_zone)
		if(!istext(zone) || !islist(GLOB.body_markings_per_limb[zone]))
			continue

		var/list/zone_markings = body_markings_by_zone[zone]
		if(!islist(zone_markings) || !length(zone_markings))
			continue

		var/list/sanitized_zone = list()
		var/marking_count = 0
		for(var/marking_key in zone_markings)
			marking_count++
			var/base_name = get_marking_base_name(marking_key)
			if(!GLOB.body_markings[base_name])
				continue
			var/list/entry = sanitize_body_marking_entry(marking_key, zone_markings[marking_key], marking_count, features, species)
			var/key = compose_marking_key(base_name, entry[MARKING_INDEX_LAYER], get_marking_sequence(marking_key), sanitized_zone)
			sanitized_zone[key] = entry

		if(length(sanitized_zone))
			sanitized[zone] = sanitized_zone

	return sanitized

/proc/random_bra(gender)
	switch(gender)
		if(MALE)
			return pick(SSaccessories.bra_m)
		if(FEMALE)
			return pick(SSaccessories.bra_f)
		else
			return pick(SSaccessories.bra_list)
