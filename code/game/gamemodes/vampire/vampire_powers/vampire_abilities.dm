/*
This is practically custom spell code like alien or changeling.

	REMEMBER - IF YOU'RE ADDING A NEW VAMPIRE SPELL ADD IT TO ForgetAbilities in vdatum.dm

	ALSO - USE THIS FOR ACTION BUTTONS:
	/datum/action/spell_action/vampire
*/

/obj/effect/proc_holder/vampire
	panel = "Vampire"
	name = "generic vampire"
	desc = "TALK TO A CODER IF YOU SEE THIS!"
	var/blood_cost = 0
	var/pay_blood_immediately = TRUE // will we take blood from the spell immediately?
	var/human_req = FALSE // does this spell require you to be human?
	var/onCD
	var/cooldownlen

/obj/effect/proc_holder/vampire/proc/force_drainage(amt, var/datum/vampire/V)
	if(!amt)
		return
	if(!V)
		return
	V.bloodcount -= amt

/obj/effect/proc_holder/vampire/proc/fire(var/mob/living/carbon/human/H)
	if(ishuman(H))
		if(!checkbloodcost(H))
			return FALSE
	else
		if(human_req)
			return FALSE
	turnonCD()
	addtimer(src, "turnOffCD", cooldownlen)
	if(action)
		action.UpdateButtonIcon()
	return TRUE

/obj/effect/proc_holder/vampire/proc/checkbloodcost(var/mob/living/carbon/human/H)
	if(blood_cost)
		if(H.mind.vampire)
			if(H.mind.vampire.bloodcount - blood_cost < 0)
				H << "<span class='alien'>You lack the blood to perform this technique...</span>"
				return FALSE
			else
				return TRUE
		else
			return FALSE
	else
		return TRUE

/obj/effect/proc_holder/vampire/Click()
	if(!ishuman(usr))
		return TRUE

	var/mob/living/carbon/human/H = usr

	if(!H.mind.vampire)
		qdel(src)
		return 1

	if(!pay_blood_immediately)
		return 1

	if(H.mind.vampire.isDraining)
		return 1

	if(fire(H))
		force_drainage(blood_cost, H.mind.vampire)

/obj/effect/proc_holder/vampire/proc/turnOnCD()
	onCD = TRUE

/obj/effect/proc_holder/vampire/proc/turnOffCD()
	onCD = FALSE
	if(action)
		action.UpdateButtonIcon()

// we are clicking the target during this. check click.dm for more. middle mouse button
/obj/effect/proc_holder/vampire/proc/action_on_click(var/mob/living/carbon/human/H, var/datum/vampire/V, var/atom/target)
	if(onCD)
		return 0
	return 1

/obj/effect/proc_holder/vampire/proc/checkout_click_attack(var/mob/M, var/datum/vampire/V)
	if(!V)
		return FALSE

	if(V.chosen_click_attack)
		if(src == V.chosen_click_attack)
			V.chosen_click_attack = null
			M << "<span class='vampirenotice'>[src] has been deactivated.</span>"
			return FALSE
		else
			M << "<span class='vampirewarning'>You already have another click-attack technique active ([V.chosen_click_attack.name])</span>"
			return FALSE
	else
		return TRUE