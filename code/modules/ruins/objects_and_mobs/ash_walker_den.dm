#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	faction = list("ashwalker")
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		consume()
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Serrated tendrils eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			if(istype(H,/mob/living/simple_animal/hostile/megafauna/dragon))
				meat_counter += 20
			else
				meat_counter ++
			for(var/obj/item/W in H)
				H.unEquip(W)
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(src.loc, SOUTH))
		visible_message("<span class='danger'>One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!</span>")
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD

/obj/structure/ashwalkerforge
	name = "strange forge"
	desc = "A pecuilar forge crafted out of sweet mythril."
	var/list/inventory = list()
	var/list/blacklist = list()
	var/list/craftables = list("Talisman" = /datum/crafting_recipe/bonetalisman,
							"Bone Bracers" = /datum/crafting_recipe/bracers,
							"Bone Spear" = /datum/crafting_recipe/bonespear,
							"Bone Axe" = /datum/crafting_recipe/boneaxe,
							"Sinew Tent" = /datum/crafting_recipe/sinew_tent,
							"Pathfinders Shoes" = /datum/crafting_recipe/pathfindertreads,
							"Pathfinders Cloak" =  /datum/crafting_recipe/pathfindercloak,
							"Pathfinders Hood" = /datum/crafting_recipe/pathfinderkasa,
							"Chintin Boots" = /datum/crafting_recipe/chitintreads,
							"Chintin Armor" = /datum/crafting_recipe/chitinarmor,
							"Chintin Gauntlets" = /datum/crafting_recipe/chitinhands,
							"Heart Protector" = /datum/crafting_recipe/heartprotector)
	var/datum/crafting_recipe/crafted
	var/datum/personal_crafting/pc


	var/inventorylimit = 20

/obj/structure/ashwalkerforge/examine(mob/user)
	..()
	if(isashwalker(user))
		if(inventory.len)
			user << "<span class='ashwalker'>Inside of the forge there is...</span>"
		for(var/I in inventory)
			if(istype(I, /obj/item))
				var/obj/item/item = I
				user << "<span class='ashwalker'>[item]. [item.desc]</span>"

/obj/structure/ashwalkerforge/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == HARM && I.force >= 10)
		visible_message("<span class='danger'>[user] upsets the forge spilling it over!</span>")
		log_game("[user] spilt over an ashwalker forge.")
		var/turf/T = get_turf(src)
		for(var/obj/O in inventory)
			O.loc = T.loc
			visible_message("<span class='danger'>[O] spits out of the forge!</span>")
			inventory -= O
		return ..()

	for(var/obj/object in blacklist)
		if(object == I)
			src << "<span class='warning'>The [src] refuses to accept [I]!</span>"
			return

	if(inventory.len < 20)
		visible_message("<span class='warning'>[src] grabs [I] from [user]'s hand, and swallows it whole!</span>")
		var/obj/eaten_object = I
		eaten_object = new I(src)
		inventory += eaten_object
		qdel(I)
	else
		user << "<span class='warning'>The [src] is too full!</span>"



/obj/structure/ashwalkerforge/attack_hand(mob/user)
	if(!isashwalker(user))
		user << "<span class='warning'>[src] hisses!</span>"
		return

	switch(alert("Create Something","Ashwalker Forge", "Craft", "Cancel"))
		if("Craft")
			var/craft = input("CRAFT!", "Ashwalker Forging", src) in craftables
			if(craft)
				var/datum/crafting_recipe/craftcycle = craftables[craft]
				activate_craft_cycle(user, craftcycle)

/obj/structure/ashwalkerforge/proc/activate_craft_cycle(mob/user, var/datum/crafting_recipe/CR)
	if(!CR)
		return
	if(!pc)
		pc = new(src)

	var/turf/T = get_turf(src)
	for(var/obj/O in inventory)
		O.loc = T

	var/datum/crafting_recipe/craft = new CR(src)
	message_admins("THIS IS CR -> [CR]")
	pc.construct_item(user, craft)
