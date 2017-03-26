/////////////////////////////////////////////////////
///////////////	BASIC ABILITIES /////////////////////
/////////////////////////////////////////////////////


/////////////////////
////	BITE 	/////
/////////////////////

/obj/effect/proc_holder/vampire/bite
	name = "Bite"
	desc = "Sink your teeth into an adjacent target."
	human_req = TRUE

/obj/effect/proc_holder/vampire/bite/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/vampire = H.mind.vampire
	if(!H.pulling)
		H << "<span class='alertvampire'>To use this technique you will need to grab your victim!</span>"
		return
	if(!ishuman(H.pulling))
		H << "<span class='alertvampire'>This technique can only be used on human life forms!</span>"
		return

	var/mob/living/carbon/human/target = H.pulling

	if(NOBLOOD in target.dna.species.specflags || !target.blood_volume)
		H << "<span class='alertvampire'>They have no blood!</span>"
		return

	var/drainrate = 55
	var/drainpayoff = 10

	if(target.stat == DEAD)
		drainrate = 70
		drainpayoff = 3
		H << "<span class='alertvampire'>This one has a strange odor.</span>"

	playsound(H.loc,'sound/magic/Demon_consume.ogg', rand(10,30), 1)
	H << "<span class='noticevampire'>You sink your fangs into [target]!</span>"
	vampire.isDraining = TRUE
	while(vampire.isDraining)
		if(check_status(H, vampire, target))
			H << "<span class='noticevampire'>You have gained [drainrate] units of blood from [target]. They have [target.blood_volume] units remaining. You now have [vampire.bloodcount] units.</span>"
			target.blood_volume -= drainrate
			vampire.add_blood(drainpayoff)
			playsound(H.loc,'sound/items/drink.ogg', rand(10,50), 1)
		if(!target.blood_volume || target.blood_volume < drainrate)
			H << "<span class='noticevampire'>[target] has ran out of blood.</span>"
			vampire.isDraining = FALSE
		if(target.job == "Chaplain")
			H << "<span class='userdanger'>This one's blood is holy! It burns!</span>"
			H.reagents.add_reagent("sacid", 10)
		if(target.stat == DEAD)
			drainrate = 3
			drainpayoff = 3

		vampire.check_for_new_ability()
		sleep(20)

	H << "<span class='noticevampire'>You have finished draining [target]</span>"


/obj/effect/proc_holder/vampire/bite/proc/check_status(mob/living/L, datum/vampire/V, mob/living/T)
	if(L.weakened || L.stunned || L.sleeping || L.stat == DEAD || L.stat == UNCONSCIOUS || get_dist(L, T) > 1 || !L.pulling)
		V.isDraining = FALSE
		L << "<span class='alertvampire'>You've been interrupted!</span>"
		return 0
	return 1


/////////////////////
////	GAZE 	/////
/////////////////////

/obj/effect/proc_holder/vampire/gaze
	name = "Vampiric Gaze"
	desc = "Paralyze your target with fear. (Use the middle mouse button after activating)"
	cooldownlen = 300
	pay_blood_immediately = FALSE
	cooldown_immediately = FALSE

/obj/effect/proc_holder/vampire/gaze/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/V = H.mind.vampire

	if(!checkout_click_attack(H, V))
		return

	V.chosen_click_attack = src
	H << "<span class='alertvampire'>[src] is now active. (Use your middle mouse button on anyone to activate.)"
	return 1

/obj/effect/proc_holder/vampire/gaze/action_on_click(mob/living/carbon/human/H, datum/vampire/V, atom/target)
	if(!..())
		return

	if(target)
		if(!(ishuman(target)))
			return
	else
		return

	var/mob/living/carbon/human/T = target

	if(T.stat == DEAD)
		H << "<span class='alertvampire'>You cannot gaze at corpses... \
			or maybe you could if you really wanted to.</span>"
		return

	H.visible_message("<span class='warning'>[H]'s eyes flash red.</span>",\
					"<span class='warning'>[H]'s eyes flash red.</span>")
	if(ishuman(target))
		var/obj/item/clothing/glasses/G = T.glasses
		if(G)
			if(G.flash_protect)
				H << "<span class='alertvampire'>[T] has protective sunglasses on!</span>"
				target << "<span class='warning'>[H]'s paralyzing gaze is blocked by your [G]!</span>"
				return
		var/obj/item/clothing/mask/M = T.wear_mask
		if(M)
			if(M.flags_cover & MASKCOVERSEYES)
				H << "<span class='alertvampire'>[T]'s mask is covering their eyes!</span>"
				target << "<span class='warning'>[H]'s paralyzing gaze is blocked by your [M]!</span>"
				return

		T << "<span class='warning'>You are paralyzed with fear!</span>"
		T.Stun(5)


/////////////////////////////
////	BLOOD TRACKING	/////
/////////////////////////////

/obj/effect/proc_holder/vampire/bloodtracking
	name = "Blood Tracking"
	desc = "Use this by clicking on blood drips or splatters, and track who it belongs too. (Use the middle mouse button on blood)"
	pay_blood_immediately = FALSE
	cooldown_immediately = FALSE

/obj/effect/proc_holder/vampire/bloodtracking/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/V = H.mind.vampire

	if(!checkout_click_attack(H, V)) // good thing there's not an I inbetween those letters, am i right? up top
		if(V.tracking)
			H << "<span class='alertvampire'>You stop tracking.</span>"
			V.tracking.RemoveBloodTracking()
			V.tracking = null
		return

	V.chosen_click_attack = src

	H << "<span class='noticevampire'>[src] is active. (Use your middle mouse button on blood)</span>"
	return 1

/obj/effect/proc_holder/vampire/bloodtracking/action_on_click(mob/living/carbon/human/H, datum/vampire/V, atom/target)
	if(!..())
		return

	if(V)
		if(V.tracking)
			H << "<span class='noticevampire'>You stop tracking [V.tracking.name].</span>"
			V.tracking.RemoveBloodTracking()
			V.tracking = null

	if(istype(target, /obj/effect/decal/cleanable/blood))
		var/obj/effect/decal/cleanable/blood/B = target
		var/mob/living/carbon/human/chosentarget
		if(B.blood_DNA.len)
			for(var/mob/living/carbon/human/L in mob_list)
				if(chosentarget)
					break
				for(var/DNA in L.blood_DNA)
					if(chosentarget)
						break
					if(DNA in B.blood_DNA)
						chosentarget = L
						H << "<span class='alertvampire'>You feel the presence of [L.real_name] rise from the blood. They have been marked with a red outline for you.</span>"
						if(V)
							V.tracking = chosentarget
							V.tracking.UpdateBloodTracking()


//////////////////////////////////////////////////
///////////////	100 ABILITIES ////////////////////
//////////////////////////////////////////////////


/obj/effect/proc_holder/vampire/clearstuns
	name = "Clear Stuns"
	desc = "Remove all stuns and stamina damage from yourself."
	blood_cost = 25
	cooldownlen = 150

/obj/effect/proc_holder/vampire/clearstuns/fire(mob/living/carbon/human/H)
	H << "<span class='noticevampire'>You feel a rush of energy overcome you.</span>"
	H.SetSleeping(0)
	H.SetParalysis(0)
	H.SetStunned(0)
	H.SetWeakened(0)
	H.adjustStaminaLoss(-(H.getStaminaLoss()))

/obj/effect/proc_holder/vampire/battrans
	name = "Bat Transformation"
	desc = "Become a bat, able to slip under doors "
	pay_blood_immediately = FALSE
	cooldown_immediately = FALSE
	cooldownlen = 0
	var/mob/living/simple_animal/hostile/retaliate/bat/vampire/vbat = null
	var/transformed = FALSE

/obj/effect/proc_holder/vampire/battrans/fire(mob/living/carbon/human/H, datum/vampire/V)
	if(transformed)
		return
	else
		H << "<span class='noticevampire'>You take the form of a bat.</span>"
		if(V)
			force_drainage(25, V)
		if(!vbat)
			vbat = new /mob/living/simple_animal/hostile/retaliate/bat/vampire(H.loc)
			vbat.vamp = H
			vbat.S = src
		H.forceMove(vbat)
		H.status_flags |= GODMODE
		vbat.verbs += /mob/living/simple_animal/hostile/retaliate/bat/vampire/verb/humanform
		H.mind.transfer_to(vbat)
		vbat.adjustBruteLoss(H.maxHealth - H.health)


