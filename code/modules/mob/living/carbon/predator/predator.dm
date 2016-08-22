/mob/living/carbon/human/predator
	name = "predator"
	voice_name = "predator"
	verb_say = "clicks"
	base_icon_state = "pred_s"
	icon_state = "pred_s"
	languages_spoken = PREDATOR
	languages_understood = HUMAN | PREDATOR
	gender = NEUTER
	maxHealth = 125
	health = 125

/mob/living/carbon/human/predator/New()
	..()
	set_species(/datum/species/predator)
	name = text("predator ([rand(1, 1000)])")
	real_name = name
	hair_color = "000"
	hair_style = "Bald"
	facial_hair_color = "000"
	facial_hair_style = "Shaved"
	update_icons()
	equip_to_slot_if_possible(new /obj/item/clothing/suit/space/hardsuit/predator, slot_wear_suit)
	equip_to_slot_if_possible(new /obj/item/clothing/under/predator, slot_w_uniform)
	equip_to_slot_if_possible(new /obj/item/weapon/shuriken, slot_l_store)
	equip_to_slot_if_possible(new /obj/item/weapon/twohanded/spear/combistick, slot_r_store)
	equip_to_slot_if_possible(new /obj/item/clothing/shoes/predator, slot_shoes)
	equip_to_slot_if_possible(new /obj/item/weapon/storage/belt/mining/yautija, slot_belt)


/mob/living/carbon/human/predator/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", a_intent))
	stat(null, text("Move Mode: []", m_intent))
	return

/mob/living/carbon/human/predator/IsAdvancedToolUser()
	return 1

/mob/living/carbon/human/predator/canBeHandcuffed()
	return 1

/mob/living/carbon/human/predator/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)

/mob/living/carbon/human/predator/say(message, bubble_type)
	playsound(src.loc, 'sound/predators/predator_clicking.ogg', 100, 1)
	return ..(message, bubble_type)

/mob/living/carbon/human/predator/say_quote(var/text)
	return "[verb_say], \"[text]\"";

/datum/species/predator
	name = "Predator"
	id = "pred"
	say_mod = "clicks"
	default_color = "59CE00"
	sexes = 0
	specflags = list(VIRUSIMMUNE)
	skinned_type = /obj/item/stack/sheet/animalhide/human