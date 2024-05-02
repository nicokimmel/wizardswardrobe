WizardsWardrobe = WizardsWardrobe or {}
local WW = WizardsWardrobe

WW.LINK_TYPES = {
	PREVIEW = "wwp",
	URL = "wwu",
}

WW.LOGTYPES = {
	NORMAL = "FFFFFF",
	ERROR = "FF7070",
	INFO = "F8FF70",
	CRITICAL = "FF0000"
}

WW.GEARSLOTS = {
	EQUIP_SLOT_HEAD,
	EQUIP_SLOT_SHOULDERS,
	EQUIP_SLOT_CHEST,
	EQUIP_SLOT_HAND,
	EQUIP_SLOT_WAIST,
	EQUIP_SLOT_LEGS,
	EQUIP_SLOT_FEET,
	EQUIP_SLOT_NECK,
	EQUIP_SLOT_RING1,
	EQUIP_SLOT_RING2,
	EQUIP_SLOT_COSTUME,
	EQUIP_SLOT_MAIN_HAND,
	EQUIP_SLOT_OFF_HAND,
	EQUIP_SLOT_POISON,
	EQUIP_SLOT_BACKUP_MAIN,
	EQUIP_SLOT_BACKUP_OFF,
	EQUIP_SLOT_BACKUP_POISON,
}

WW.GEARICONS = {
	[ EQUIP_SLOT_HEAD ] = "/esoui/art/characterwindow/gearslot_head.dds",
	[ EQUIP_SLOT_SHOULDERS ] = "/esoui/art/characterwindow/gearslot_shoulders.dds",
	[ EQUIP_SLOT_CHEST ] = "/esoui/art/characterwindow/gearslot_chest.dds",
	[ EQUIP_SLOT_HAND ] = "/esoui/art/characterwindow/gearslot_hands.dds",
	[ EQUIP_SLOT_WAIST ] = "/esoui/art/characterwindow/gearslot_belt.dds",
	[ EQUIP_SLOT_LEGS ] = "/esoui/art/characterwindow/gearslot_legs.dds",
	[ EQUIP_SLOT_FEET ] = "/esoui/art/characterwindow/gearslot_feet.dds",
	[ EQUIP_SLOT_NECK ] = "/esoui/art/characterwindow/gearslot_neck.dds",
	[ EQUIP_SLOT_RING1 ] = "/esoui/art/characterwindow/gearslot_ring.dds",
	[ EQUIP_SLOT_RING2 ] = "/esoui/art/characterwindow/gearslot_ring.dds",
	[ EQUIP_SLOT_COSTUME ] = "/esoui/art/characterwindow/gearslot_costume.dds",
	[ EQUIP_SLOT_MAIN_HAND ] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
	[ EQUIP_SLOT_OFF_HAND ] = "/esoui/art/characterwindow/gearslot_offhand.dds",
	[ EQUIP_SLOT_POISON ] = "/esoui/art/characterwindow/gearslot_poison.dds",
	[ EQUIP_SLOT_BACKUP_MAIN ] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
	[ EQUIP_SLOT_BACKUP_OFF ] = "/esoui/art/characterwindow/gearslot_offhand.dds",
	[ EQUIP_SLOT_BACKUP_POISON ] = "/esoui/art/characterwindow/gearslot_poison.dds",
}

WW.GEARTYPE = {
	[ EQUIP_TYPE_HEAD ] = EQUIP_SLOT_HEAD,
	[ EQUIP_TYPE_SHOULDERS ] = EQUIP_SLOT_SHOULDERS,
	[ EQUIP_TYPE_CHEST ] = EQUIP_SLOT_CHEST,
	[ EQUIP_TYPE_HAND ] = EQUIP_SLOT_HAND,
	[ EQUIP_TYPE_WAIST ] = EQUIP_SLOT_WAIST,
	[ EQUIP_TYPE_LEGS ] = EQUIP_SLOT_LEGS,
	[ EQUIP_TYPE_FEET ] = EQUIP_SLOT_FEET,
	[ EQUIP_TYPE_NECK ] = EQUIP_SLOT_NECK,
	[ EQUIP_TYPE_RING ] = EQUIP_SLOT_RING1,
	[ EQUIP_TYPE_COSTUME ] = EQUIP_SLOT_COSTUME,
	[ EQUIP_TYPE_MAIN_HAND ] = EQUIP_SLOT_MAIN_HAND,
	[ EQUIP_TYPE_TWO_HAND ] = EQUIP_SLOT_MAIN_HAND,
	[ EQUIP_TYPE_ONE_HAND ] = EQUIP_SLOT_MAIN_HAND,
	[ EQUIP_TYPE_OFF_HAND ] = EQUIP_SLOT_MAIN_HAND,
	[ EQUIP_TYPE_POISON ] = EQUIP_SLOT_POISON,
}

WW.CPCOLOR = {
	[ 1 ] = "A5DB52",
	[ 2 ] = "A5DB52",
	[ 3 ] = "A5DB52",
	[ 4 ] = "A5DB52",
	[ 5 ] = "5ABAE7",
	[ 6 ] = "5ABAE7",
	[ 7 ] = "5ABAE7",
	[ 8 ] = "5ABAE7",
	[ 9 ] = "E76931",
	[ 10 ] = "E76931",
	[ 11 ] = "E76931",
	[ 12 ] = "E76931",
}

WW.CPICONS = {
	[ 1 ] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[ 2 ] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[ 3 ] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[ 4 ] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[ 5 ] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[ 6 ] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[ 7 ] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[ 8 ] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[ 9 ] = "/esoui/art/champion/champion_points_health_icon.dds",
	[ 10 ] = "/esoui/art/champion/champion_points_health_icon.dds",
	[ 11 ] = "/esoui/art/champion/champion_points_health_icon.dds",
	[ 12 ] = "/esoui/art/champion/champion_points_health_icon.dds",
}

WW.BUFFFOOD = {


	[ 64711 ] = 68411, -- Crown Fortifying Meal
	[ 64712 ] = 68416, -- Crown Refreshing Drink
	[ 68233 ] = 61259, -- Garlic-and-Pepper Venison Steak
	[ 68234 ] = 61259, -- Millet and Beef Stuffed Peppers
	[ 68235 ] = 61259, -- Lilmoth Garlic Hagfish
	[ 68236 ] = 61260, -- Firsthold Fruit and Cheese Plate
	[ 68237 ] = 61260, -- Thrice-Baked Gorapple Pie
	[ 68238 ] = 61260, -- Tomato Garlic Chutney
	[ 68239 ] = 61261, -- Hearty Garlic Corn Chowder
	[ 68240 ] = 61261, -- Bravil's Best Beet Risotto
	[ 68241 ] = 61261, -- Tenmar Millet-Carrot Couscous
	[ 68242 ] = 61257, -- Mistral Banana-Bunny Hash
	[ 68243 ] = 61257, -- Melon-Baked Parmesan Pork
	[ 68244 ] = 61257, -- Solitude Salmon-Millet Soup
	[ 68245 ] = 61255, -- Sticky Pork and Radish Noodles
	[ 68246 ] = 61255, -- Garlic Cod with Potato Crust
	[ 68247 ] = 61255, -- Braised Rabbit with Spring Vegetables
	[ 68248 ] = 61294, -- Chevre-Radish Salad with Pumpkin Seeds
	[ 68249 ] = 61294, -- Grapes and Ash Yam Falafel
	[ 68250 ] = 61294, -- Late Hearthfire Vegetable Tart
	[ 68251 ] = 61218, -- Capon Tomato-Beet Casserole
	[ 68252 ] = 61218, -- Jugged Rabbit in Preserves
	[ 68253 ] = 61218, -- Longfin Pasty with Melon Sauce
	[ 68254 ] = 61218, -- Withered Tree Inn Venison Pot Roast
	[ 68255 ] = 61322, -- Kragenmoor Zinger Mazte
	[ 68256 ] = 61322, -- Colovian Ginger Beer
	[ 68257 ] = 61322, -- Markarth Mead
	[ 68258 ] = 61325, -- Heart's Day Rose Tea
	[ 68259 ] = 61325, -- Soothing Bard's-Throat Tea
	[ 68260 ] = 61325, -- Muthsera's Remorse
	[ 68261 ] = 61328, -- Fredas Night Infusion
	[ 68262 ] = 61328, -- Old Hegathe Lemon Kaveh
	[ 68263 ] = 61328, -- Hagraven's Tonic
	[ 68264 ] = 61335, -- Port Hunding Pinot Noir
	[ 68265 ] = 61335, -- Dragontail Blended Whisky
	[ 68266 ] = 61335, -- Bravil Bitter Barley Beer
	[ 68267 ] = 61340, -- Wide-Eye Double Rye
	[ 68268 ] = 61340, -- Camlorn Sweet Brown Ale
	[ 68269 ] = 61340, -- Flowing Bowl Green Port
	[ 68270 ] = 61345, -- Honest Lassie Honey Tea
	[ 68271 ] = 61345, -- Rosy Disposition Tonic
	[ 68272 ] = 61345, -- Cloudrest Clarified Coffee
	[ 68273 ] = 61350, -- Senche-Tiger Single Malt
	[ 68274 ] = 61350, -- Velothi View Vintage Malbec
	[ 68275 ] = 61350, -- Orcrest Agony Pale Ale
	[ 68276 ] = 61350, -- Lusty Argonian Maid Mazte
	[ 71056 ] = 72816, -- Orzorga's Red Frothgar
	[ 71057 ] = 72819, -- Orzorga's Tripe Trifle Pocket
	[ 71058 ] = 72822, -- Orzorga's Blood Price Pie
	[ 71059 ] = 72824, -- Orzorga's Smoked Bear Haunch
	[ 87685 ] = 84678, -- Sweet Sanguine Apples
	[ 87686 ] = 84681, -- Crisp and Crunchy Pumpkin Snack Skewer
	[ 87687 ] = 84700, -- Bowl of "Peeled Eyeballs"
	[ 87690 ] = 84704, -- Witchmother's Party Punch
	[ 87691 ] = 84709, -- Crunchy Spider Skewer
	[ 87695 ] = 84720, -- Ghastly Eye Bowl
	[ 87696 ] = 84725, -- Frosted Brains
	[ 87697 ] = 84731, -- Witchmother's Potent Brew
	[ 87699 ] = 84735, -- Purifying Bloody Mara
	[ 94437 ] = 85484, -- Crown Crate Fortifying Meal
	[ 94438 ] = 85497, -- Crown Crate Refreshing Drink
	[ 101879 ] = 86559, -- Hissmir Fish-Eye Rye
	[ 112425 ] = 86673, -- Lava Foot Soup-and-Saltrice
	[ 112426 ] = 86677, -- Bergama Warning Fire
	[ 112433 ] = 86746, -- Betnikh Twice-Spiked Ale
	[ 112434 ] = 86749, -- Jagga-Drenched "Mud Ball"
	[ 112435 ] = 84678, -- Old Aldmeri Orphan Gruel
	[ 112438 ] = 86787, -- Rajhin's Sugar Claws
	[ 112439 ] = 86789, -- Alcaire Festival Sword-Pie
	[ 112440 ] = 86791, -- Snow Bear Glow-Wine
	[ 120436 ] = 84678, -- Princess's Delight
	[ 120762 ] = 89955, -- Candied Jester's Coins
	[ 120763 ] = 89957, -- Dubious Camoran Throne
	[ 120764 ] = 89971, -- Jewels of Misrule
	[ 133554 ] = 100502, -- Deregulated Mushroom Stew
	[ 133555 ] = 100488, -- Spring-Loaded Infusion
	[ 133556 ] = 100498, -- Clockwork Citrus Filet
	[ 139016 ] = 107748, -- Artaeum Pickled Fish Bowl
	[ 139018 ] = 107789, -- Artaeum Takeaway Broth
	[ 153625 ] = 127531, -- Corrupting Bloody Mara
	[ 153627 ] = 127572, -- Pack Leader's Bone Broth
	[ 153629 ] = 127596, -- Bewitched Sugar Skulls
	[ 171322 ] = 148633, -- Sparkling Mudcrab Apple Cider
}

WW.CONDITIONS = {
	NONE = 0,
	EVERYWHERE = -1,
}

WW.DISABLEDBAGS = {
	[ BAG_GUILDBANK ] = true,
	[ BAG_BUYBACK ] = true,
	[ BAG_DELETE ] = true,
	[ BAG_VIRTUAL ] = true,
}

WW.MARKINVENTORIES = {
	ZO_PlayerInventoryBackpack,
	ZO_PlayerBankBackpack,
	ZO_GuildBankBackpack,
	ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
	ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
}

WW.TRAITS = {
	ITEM_TRAIT_TYPE_ARMOR_DIVINES,
	ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
	ITEM_TRAIT_TYPE_ARMOR_INFUSED,
	ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
	ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
	ITEM_TRAIT_TYPE_ARMOR_ORNATE,
	ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
	ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
	ITEM_TRAIT_TYPE_ARMOR_STURDY,
	ITEM_TRAIT_TYPE_ARMOR_TRAINING,
	ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
	ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
	ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
	ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
	ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
	ITEM_TRAIT_TYPE_JEWELRY_INFUSED,
	ITEM_TRAIT_TYPE_JEWELRY_INTRICATE,
	ITEM_TRAIT_TYPE_JEWELRY_ORNATE,
	ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
	ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
	ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
	ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
	ITEM_TRAIT_TYPE_WEAPON_CHARGED,
	ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
	ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
	ITEM_TRAIT_TYPE_WEAPON_INFUSED,
	ITEM_TRAIT_TYPE_WEAPON_INTRICATE,
	ITEM_TRAIT_TYPE_WEAPON_NIRNHONED,
	ITEM_TRAIT_TYPE_WEAPON_ORNATE,
	ITEM_TRAIT_TYPE_WEAPON_POWERED,
	ITEM_TRAIT_TYPE_WEAPON_PRECISE,
	ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
	ITEM_TRAIT_TYPE_WEAPON_TRAINING,
}

WW.PREVIEW = {
	CHARACTERS = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		"g",
		"h",
		"i",
		"j",
		"k",
		"l",
		"m",
		"n",
		"o",
		"p",
		"q",
		"r",
		"s",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
	},
	TRAITS = {
		[ 0 ] = 0,
	},
	FOOD = {
		[ 0 ] = 0,
		[ "0" ] = 0,
	},
}
WW.WARNING = {
	INVENTORY = 1,
	FOOD = 2,
	CP = 3,
}
