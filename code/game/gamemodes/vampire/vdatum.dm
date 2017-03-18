/datum/vampire
	var/mob/living/carbon/human/vampire
	var/bloodcount
	var/isDraining
	var/obj/effect/proc_holder/vampire/chosen_click_attack
	var/mob/living/carbon/human/tracking
	var/basic_unlocked
	var/hundred_unlocked
	var/twohundred_unlocked
	var/threehundred_unlocked
	var/fourhundred_unlocked
	var/sixhundred_unlocked
	var/eighthundred_unlocked
	var/thousand_unlocked

/datum/vampire/proc/add_blood(amount, amthigh, amtlow)
	var/amt = amount
	if(amthigh && amtlow)
		amt = rand(amthigh, amtlow)

	bloodcount += amt
	return 1

/datum/vampire/proc/remove_blood(amount, amthigh, amtlow)
	var/amt = amount
	if(amthigh && amtlow)
		amt = rand(amthigh, amtlow)

	bloodcount -= amt
	if(bloodcount < 0)
		bloodcount = 0
	return 1

/datum/vampire/proc/Basic()
	if(basic_unlocked)
		return

	basic_unlocked = TRUE
	vampire.AddVampireSpell(new /obj/effect/proc_holder/vampire/bite(null))
	vampire.AddVampireSpell(new /obj/effect/proc_holder/vampire/gaze(null))
	vampire.AddVampireSpell(new /obj/effect/proc_holder/vampire/bloodtracking(null))

	vampire.dna.species.update_life = FALSE
	vampire.dna.species.brutemod = 1
	vampire.dna.species.burnmod = 2
	vampire.dna.species.coldmod = 0
	vampire.dna.species.heatmod = 2

	vampire.dna.species.specflags |= NOBLOOD
	vampire.dna.species.specflags |= NOBREATH

/datum/vampire/proc/Hundred()
	hundred_unlocked = TRUE
	vampire.dna.species.toxmod = 0
	vampire.AddVampireSpell(new /obj/effect/proc_holder/vampire/clearstuns(null))

/datum/vampire/proc/TwoHundred()
	twohundred_unlocked = TRUE
	var/obj/item/organ/cyberimp/eyes/E = vampire.getorgan(/obj/item/organ/cyberimp/eyes)
	if(E)
		vampire << "<span class='noticevampire'>[E] is swallowed.</span>"
		qdel(E)

	var/obj/item/organ/cyberimp/eyes/vampire/weak/V = new(get_turf(vampire))
	V.Insert(vampire)

/datum/vampire/proc/ThreeHundred()
	threehundred_unlocked = TRUE

/datum/vampire/proc/FourHundred()
	fourhundred_unlocked = TRUE

/datum/vampire/proc/SixHundred()
	sixhundred_unlocked = TRUE

/datum/vampire/proc/EightHundred()
	eighthundred_unlocked = TRUE

/datum/vampire/proc/Thousand()
	thousand_unlocked = TRUE

/datum/vampire/proc/ForgetAbilities()
	//vampire.RemoveAbility()

/datum/vampire/process() // called in carbon life.
	if(!vampire)
		return
	check_bright_turf()
	check_burning_status()

/datum/vampire/proc/check_bright_turf()
	if(!vampire.stat)
		return

	var/turf/T = get_turf(vampire)
	if(T.get_lumcount() > 2)
		if((vampire.wear_suit && (vampire.wear_suit.flags & THICKMATERIAL)) && (vampire.head && (vampire.head.flags & THICKMATERIAL)))
			return
		vampire << 'sound/weapons/sear.ogg'
		vampire.apply_damage(5, BURN)
		vampire << "<span class='genesisred'>THE LIGHT </span><span class='alertvampire'> IT BURNS!!!</span>"

/datum/vampire/proc/check_burning_status()
	if(!vampire.stat)
		if(vampire.on_fire)
			var/str = FALSE
			if(twohundred_unlocked)
				str = TRUE
			for(var/obj/item/I in vampire) // You're not going in there looking like THAT!
				vampire.unEquip(I)
			var/obj/effect/decal/cleanable/ash/vampiric/V = new(get_turf(vampire), strong = str)
			vampire.forceMove(V)
			V.storedmob = vampire

#define FREEZE_TOUCH_TEMP	50

/datum/vampire/proc/freeze_touch(mob/living/carbon/human/H) // called in species.dm
	if(!prob(25))
		return

	H.bodytemperature = FREEZE_TOUCH_TEMP
	H << "<span class='warning'>Your body begins to</span> <span class='alertvampire'>freeze up...</span>"

#undef FREEZE_TOUCH_TEMP

/datum/vampire/proc/check_for_new_ability()
	if(bloodcount >= 100)
		if(!hundred_unlocked)
			Hundred()
	if(bloodcount >= 200)
		if(!twohundred_unlocked)
			TwoHundred()
	if(bloodcount >= 300)
		if(!threehundred_unlocked)
			ThreeHundred()
	if(bloodcount >= 400)
		if(!fourhundred_unlocked)
			FourHundred()
	if(bloodcount >= 600)
		if(!sixhundred_unlocked)
			SixHundred()
	if(bloodcount >= 800)
		if(!eighthundred_unlocked)
			EightHundred()
	if(bloodcount >= 1000)
		if(!thousand_unlocked)
			Thousand()

// TESTING ONLY:

/mob/proc/makevampire()
	mind.vampire = new(mind)
	mind.vampire.vampire = mind.current
	mind.vampire.Basic()
	world << "turned [key] into a vampire"
	if(mind.vampire)
		return TRUE