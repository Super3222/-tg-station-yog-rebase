
/////////////////////
////////1000/////////
/////////////////////

/obj/effect/proc_holder/vampire/summon
	name = "Summon Coffin"
	desc = "Summon your coffin."
	req_bloodcount = 250
	cooldownlen = 900

/obj/effect/proc_holder/vampire/summon/fire(mob/living/carbon/human/H)
	if(!..())
		return

	var/datum/vampire/V = H.mind.vampire
	if(!V.coffin)
		H << "<span class='warning'>You need to create a vampiric coffin first...</span>"
		return

	V.coffin.forceMove(get_turf(H))
	H.visible_message("<span class='warning'>[H] points at the ground beneath them!</span>",\
		"<span class='warning'>You focus your energy towards the ground.</span>")
