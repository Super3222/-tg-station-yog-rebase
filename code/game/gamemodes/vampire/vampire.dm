/datum/game_mode/
	var/list/vampires = list()

/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	antag_flag = ROLE_VAMPIRE
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	required_players = 15
	required_enemies = 3
	recommended_enemies = 5
	reroll_friendly = 1

/datum/game_mode/vampire/announce()
	world << "<b>The current game mode is Vampire!</b>"
	world << "<b>There are ominous vampires lurking within the shadows of the station! Stay on your toes!</b>"

/datum/game_mode/vampire/pre_setup()
	var/playerbase = num_players()
	var/vampireknights = min(round(playerbase / 15), 3)

	var/list/datum/mind/court_of_vamps = pick_candidate(amount = vampireknights)
	update_not_chosen_candidates()

	for(var/v in court_of_vamps)
		var/datum/mind/chosenvamp = v
		vampires += chosenvamp
		chosenvamp.assigned_role = "Vampire"
		chosenvamp.special_role = "Vampire"
		log_game("[chosenvamp.key] (ckey) has been selected as a vampire")

	return 1

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vamps in vampires)
		transform_vampire(vamp)
		forge_objectives(vamp)
	return 1

/datum/game_mode/vampire/proc/forge_objectives(var/datum/mind/M)
	return 0 // to be continued. no, not a jojo reference!

/datum/game_mode/proc/transform_vampire(var/datum/mind/M)
	M.vampire = new(src)
	M.vampire.vampire = M.current
	M.vampire.Basic()

/datum/game_mode/proc/devampire(var/datum/mind/M)
	M.vampire.ForgetAbilities()
	M.vampire = null
	M.current << "<span class='alertvampire'>Your grip on the night is slipping away!</span>"