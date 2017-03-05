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

	baisc_unlocked = TRUE
	vampire.AddAbility(new /obj/effect/proc_holder/vampire/bite)
	vampire.AddAbility(new /obj/effect/proc_holder/vampire/gaze)
	vampire.AddAbility(new /obj/effect/proc_holder/vampire/bloodtracking)

	vampire.dna.species.update_life = FALSE
	vampire.dna.species.brutemod = 1
	vampire.dna.species.burnmod = 2
	vampire.dna.species.coldmod = 0
	vampire.dna.species.heatmod = 2

	vampire.dna.species.specflags |= NOBLOOD
	vampire.dna.species.specflags |= NOBREATH

/datum/vampire/proc/Hundred()

/datum/vampire/proc/TwoHundred()

/datum/vampire/proc/ThreeHundred()

/datum/vampire/proc/FourHundred()

/datum/vampire/proc/SixHundred()

/datum/vampire/proc/EightHundred()

/datum/vampire/proc/Thousand()

/datum/vampire/proc/ForgetAbilities()
	//vampire.RemoveAbility()
