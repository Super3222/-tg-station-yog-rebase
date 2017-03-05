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

	if(NOBLOOD in target.dna.species.specflags)
		H << "<span class='alertvampire'>They don't have any blood!</span>"
		return

	var/drainrate = 20
	var/drainpayoff = 10

	if(target.stat == DEAD)
		drainrate = 3
		drainpayoff = 3

	H << "<span class='noticevampire'>You sink your fangs into [target]!</span>"
	vampire.isDraining = TRUE
	while(vampire.isDraining)
		target.drip(1)
		target.blood_volume -= drainrate
		vampire.add_blood(drainpayoff)
		playsound(H.loc,'sound/items/drink.ogg', rand(10,50), 1)
		if(check_status(user, vampire, target))
			H << "<span class='noticevampire'>You have gained [drainrate] units of blood from [target].</span>"
		if(!target.blood_volume || target.blood_volume < drainrate)
			H << "<span class='noticevampire'>[target] has ran out of blood.</span>"
			vampire.isDraining = FALSE
		if(target.job == "Chaplain")
			H << "<span class='noticevampire'>This one's blood is not pure!</span>"
			H.reagents.add_reagent("sacid", 10)
		sleep(20)

	H << "<span class='noticevampire'>You have finished draining [target]</span>"


/obj/effect/proc_holder/vampire/bite/proc/check_status(mob/living/L, var/datum/vampire/V, var/mob/living/T)
	if(L.weakened || L.stunned || L.sleeping || L.stat == DEAD || L.stat == UNCONCIOUS || get_dist(L, T) > 1)
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

/obj/effect/proc_holder/vampire/gaze/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/V = H.mind.vampire

	if(!checkout_click_attack())
		return

	V.chosen_click_attack = src
	H << "<span class='vampirewarning'>[src] is now active. (Use your middle mouse button on anyone to activate.)"
	return 1

/obj/effect/proc_holder/vampire/gaze/action_on_click(/mob/living/carbon/human/H, /datum/vampire/V, atom/target)
	. = ..()
	if(!.)
		return

	if(!isliving(target))
		return

	H.visible_message("<span class='warning'>[H]'s eyes flash red.</span>",\
					"<span class='warning'>[H]'s eyes flash red.</span>")
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/T = target
		var/obj/item/clothing/glasses/G = T.glasses
		if(G.flashprotect)
			H << "<span class='vampirewarning'>[T] has protective sunglasses on!</span>"
			target << "<span class='warning'>[H]'s paralyzing gaze is blocked by [G]!</span>"
			return
		var/obj/item/clothing/mask/wear_mask/M = T.wear_mask
		if(M.flags_cover & MASKCOVERSEYES)
			H << "<span class='vampirewarning'>[T]'s mask is covering their eyes!</span>"
			target << "<span class='warning'>[H]'s paralyzing gaze is blocked by [M]!</span>"
			return

	target << "<span class='warning'>You are paralyzed with fear!</span>"
	target.Stun(5)


/////////////////////////////
////	BLOOD TRACKING	/////
/////////////////////////////

/obj/effect/proc_holder/vampire/bloodtracking
	name = "Blood Tracking"
	desc = "Track the blood responsible (Use the middle mouse button on blood)"
	pay_blood_immediately = FALSE

/obj/effect/proc_holder/vampire/bloodtracking/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/V = H.mind.vampire

	if(!checkout_click_attack())
		if(V.tracking)
			H << "<span class='vampirewarning'>You stop tracking.</span>"
			V.tracking.RemoveBloodTracking()
			V.tracking = null
		return

	V.chosen_click_attack = src

	H << "<span class='noticevampire'>[src] is active. (Use your middle mouse button on blood)</span>"
	return 1

/obj/effect/proc_holder/vampire/bloodtracking/action_on_click(/mob/living/carbon/human/H, /datum/vampire/V, atom/target)
	. = ..()
	if(!.)
		return

	if(V)
		if(V.tracking)
			H << "<span class='vampirenotice'>You stop tracking [V.tracking.name].</span>"
			V.tracking.RemoveBloodTracking()
			V.tracking = null

	if(istype(target, /obj/effect/decal/cleanable/blood))
		var/obj/effect/decal/cleanable/blood/B = target
		var/mob/living/carbon/human/chosentarget
		if(B.blood_dna.len)
			for(var/mob/living/carbon/human/L in mob_list)
				if(chosentarget)
					break
				for(var/DNA in L.blood_DNA)
					if(chosentarget)
						break
					if(DNA in B.blood_dna)
						chosentarget = L
						H << "<span class='vampirewarning'>You feel the presence of [L.real_name] rise from the blood. They have been marked with a red outline for you.</span>"
						if(V)
							V.tracking = chosentarget
							V.tracking.UpdateBloodTracking()


/obj/effect/proc_holder/vampire/clearstuns
	name = "Clear Stuns"
	desc = "Remove all stuns and stamina damage from yourself."
	blood_cost = 25
	cooldownlen = 150
	pay_blood_immediately = FALSE

/obj/effect/proc_holder/vampire/clearstuns/fire(mob/living/carbon/human/H)
	H << "<span class='vampirenotice'>You feel a rush of energy overcome you.</span>"
	H.SetSleeping(0)
	H.SetParalysis(0)
	H.SetStunned(0)
	H.SetWeakened(0)
	H.AdjustStaminaLoss(-(user.getStaminaLoss()))