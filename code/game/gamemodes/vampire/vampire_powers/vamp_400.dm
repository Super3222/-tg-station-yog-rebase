
////////////////////////////
////////////400/////////////
////////////////////////////

/obj/effect/proc_holder/vampire/shriek
	name = "Agonizing Shriek"
	desc = "Scream at incredibly high levels causing confusion and chaos. \
		At close range, will briefly stun someone."
	human_req = TRUE
	blood_cost = 25
	cooldownlen = 150

/obj/effect/proc_holder/vampire/shriek/fire(mob/living/carbon/human/H)
	if(!..())
		return

	playsound(get_turf(H), 'sound/effects/creepyshriek.ogg', 100, extrarange = 14)
	H.visible_message("<span class='warning'>[H] releases a horrifying screech!</span>",\
		"<span class='warning'>[H] releases a horrifying screech!</span>")

	for(var/turf/T in view(7,H))
		if(istype(T, /obj/structure/window))
			var/obj/structure/window/W = T
			W.take_damage(100)
		for(var/mob/living/L in T)
			if(L == H)
				continue
			L.confused += 20
			if(get_dist(L, H) == (rand(1,2)))
				L.Stun(1)
				L.Weaken(1)
			if(ishuman(L))
				var/mob/living/carbon/human/human = L
				human.setEarDamage(human.ear_damage + (10 / min(get_dist(L, H), 5)))
			if(issilicon(L))
				L.Weaken(4)
				playsound(L, 'sound/machines/warning-buzzer.ogg', 50, 1)

/obj/effect/proc_holder/vampire/batswarm
	name = "Bat Swarm"
	desc = "Summon a swarm of hostile bats to delay pursuers or cause chaos."
	human_req = TRUE
	blood_cost = 150
	cooldownlen = 400

/obj/effect/proc_holder/vampire/batswarm/fire(mob/living/carbon/human/H)
	if(!..())
		return
	H.visible_message("<span class='warning'>[H] summons a swarm of bats!</span>")
	playsound(get_turf(H), 'sound/magic/Ethereal_Enter.ogg', 50, 1, -1)
	for(var/i = 1, i <= amount_to_spawn, i++)
		var/mob/living/simple_animal/hostile/bat/B
		B = new /mob/living/simple_animal/hostile/bat(get_turf(holder.my_atom))
		B.faction |= "Vampire"
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))