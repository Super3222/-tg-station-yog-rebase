/obj/item/organ/cyberimp/eyes/vampire
	name = "vampire eyes"
	desc = "Don't look too closely. You will become lost."

/obj/item/organ/cyberimp/eyes/vampire/weak
	aug_message = "The darkness begins to creep into every corner. Your power amongst the night becomes stronger."
	sight_flags = SEE_TURFS
	dark_view = 4

/obj/item/organ/cyberimp/eyes/vampire/strong
	aug_message = "Your eyes are now purely adjusted to the night."
	sight_flags = SEE_TURFS | SEE_MOBS
	see_invisible = SEE_INVISIBLE_MINIMUM
	dark_view = 8
	flash_protect = 1

/obj/item/weapon/reagent_containers/glass/bottle/vampire
	name = "vampire serum"
	desc = "Most men reek of fear. In you, I smell hope."
	volume = 1
	possible_transfer_amounts = list(1)
	list_reagents = list("vamp" = 1)