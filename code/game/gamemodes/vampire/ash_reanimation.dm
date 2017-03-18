/obj/effect/decal/cleanable/ash/vampiric
	var/mob/living/storedmob

/obj/effect/decal/cleanable/ash/vampiric/New(var/strong)
	. = ..()
	if(strong) // 200 blood
		START_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/ash/vampiric/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/decal/cleanable/ash/vampiric/process()
	if(!storedmob)
		return
	var/turf/T = get_turf(src)
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(B)
		var/mob/living/carbon/human/H = new(T)
		H.real_name = storedmob.real_name
		H.name = storedmob.real_name
		H.key = storedmob.key
		H.mind.vampire = new(H.mind)
		H.mind.vampire.vampire = H
		H.mind.vampire.Basic()
		H << "<span class='vampirenotice'>Your body has successfully regenerated into it's pure state. However,\
			you have lost all of your former traits and abilities in the process.</span>"
		qdel(src)