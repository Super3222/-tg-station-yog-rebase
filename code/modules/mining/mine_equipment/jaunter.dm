
/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = SLOT_BELT

/obj/item/device/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
	feedback_add_details("jaunter", "U") // user activated
	activate(user)

/obj/item/device/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==2||device_turf.z>=7)
		user << "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>"
		return FALSE
	return TRUE

/obj/item/device/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	if(isgolem(user))
		for(var/obj/item/device/radio/beacon/B in world)
			var/turf/T = get_turf(B)
			if(istype(T.loc, /area/ruin/powered/golem_ship))
				destinations += B

	// In the event golem beacon is destroyed, send to station instead
	if(destinations.len)
		return destinations

	for(var/obj/item/device/radio/beacon/B in world)
		var/turf/T = get_turf(B)
		if(T.z == ZLEVEL_STATION)
			destinations += B

	return destinations

/obj/item/device/wormhole_jaunter/proc/activate(mob/user)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		user << "<span class='notice'>The [src.name] found no beacons in the world to anchor a wormhole to.</span>"
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/wormhole/jaunt_tunnel/J = new /obj/effect/portal/wormhole/jaunt_tunnel(get_turf(src), chosen_beacon, lifespan=100)
	J.target = chosen_beacon
	try_move_adjacent(J)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/device/wormhole_jaunter/emp_act(power)
	var/triggered = FALSE

	if(usr.get_item_by_slot(slot_belt) == src)
		if(power == 1)
			triggered = TRUE
		else if(power == 2 && prob(50))
			triggered = TRUE

	if(triggered)
		usr.visible_message("<span class='warning'>The [src] overloads and activates!</span>")
		feedback_add_details("jaunter","E") // EMP accidental activation
		activate(usr)

/obj/item/device/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
		user << "Your [src] activates, saving you from the chasm!</span>"
		feedback_add_details("jaunter","C") // chasm automatic activation
		activate(user)
	else
		user << "The [src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>"


/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return

	if(istype(M, /atom/movable))
		if(do_teleport(M, target, 6))
			// KERPLUNK
			playsound(M,'sound/weapons/resonator_blast.ogg',50,1)
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				L.Weaken(3)
				if(ishuman(L))
					shake_camera(L, 20, 1)
					spawn(20)
						if(L)
							L.vomit(20)