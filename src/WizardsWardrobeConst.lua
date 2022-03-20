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
	[EQUIP_SLOT_HEAD] = "/esoui/art/characterwindow/gearslot_head.dds",
    [EQUIP_SLOT_SHOULDERS] = "/esoui/art/characterwindow/gearslot_shoulders.dds",
    [EQUIP_SLOT_CHEST] = "/esoui/art/characterwindow/gearslot_chest.dds",
    [EQUIP_SLOT_HAND] = "/esoui/art/characterwindow/gearslot_hands.dds",
    [EQUIP_SLOT_WAIST] = "/esoui/art/characterwindow/gearslot_belt.dds",
    [EQUIP_SLOT_LEGS] = "/esoui/art/characterwindow/gearslot_legs.dds",
    [EQUIP_SLOT_FEET] = "/esoui/art/characterwindow/gearslot_feet.dds",
    [EQUIP_SLOT_NECK] = "/esoui/art/characterwindow/gearslot_neck.dds",
    [EQUIP_SLOT_RING1] = "/esoui/art/characterwindow/gearslot_ring.dds",
    [EQUIP_SLOT_RING2] = "/esoui/art/characterwindow/gearslot_ring.dds",
	[EQUIP_SLOT_COSTUME] = "/esoui/art/characterwindow/gearslot_costume.dds",
	[EQUIP_SLOT_MAIN_HAND] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
    [EQUIP_SLOT_OFF_HAND] = "/esoui/art/characterwindow/gearslot_offhand.dds",
	[EQUIP_SLOT_POISON] = "/esoui/art/characterwindow/gearslot_poison.dds",
	[EQUIP_SLOT_BACKUP_MAIN] = "/esoui/art/characterwindow/gearslot_mainhand.dds",
    [EQUIP_SLOT_BACKUP_OFF] = "/esoui/art/characterwindow/gearslot_offhand.dds",
    [EQUIP_SLOT_BACKUP_POISON] = "/esoui/art/characterwindow/gearslot_poison.dds",
}

WW.GEARTYPE = {
	[EQUIP_TYPE_HEAD] = EQUIP_SLOT_HEAD,
	[EQUIP_TYPE_SHOULDERS] = EQUIP_SLOT_SHOULDERS,
	[EQUIP_TYPE_CHEST] = EQUIP_SLOT_CHEST,
	[EQUIP_TYPE_HAND] = EQUIP_SLOT_HAND,
	[EQUIP_TYPE_WAIST] = EQUIP_SLOT_WAIST,
	[EQUIP_TYPE_LEGS] = EQUIP_SLOT_LEGS,
	[EQUIP_TYPE_FEET] = EQUIP_SLOT_FEET,
	[EQUIP_TYPE_NECK] = EQUIP_SLOT_NECK,
	[EQUIP_TYPE_RING] = EQUIP_SLOT_RING1,
	[EQUIP_TYPE_COSTUME] = EQUIP_SLOT_COSTUME,
	[EQUIP_TYPE_MAIN_HAND] = EQUIP_SLOT_MAIN_HAND,
	[EQUIP_TYPE_TWO_HAND] = EQUIP_SLOT_MAIN_HAND,
	[EQUIP_TYPE_ONE_HAND] = EQUIP_SLOT_MAIN_HAND,
	[EQUIP_TYPE_OFF_HAND] = EQUIP_SLOT_MAIN_HAND,
	[EQUIP_TYPE_POISON] = EQUIP_SLOT_POISON,
}

WW.CPCOLOR = {
	[1] = "A5DB52",
	[2] = "A5DB52",
	[3] = "A5DB52",
	[4] = "A5DB52",
	[5] = "5ABAE7",
	[6] = "5ABAE7",
	[7] = "5ABAE7",
	[8] = "5ABAE7",
	[9] = "E76931",
	[10] = "E76931",
	[11] = "E76931",
	[12] = "E76931",
}

WW.CPICONS = {
	[1] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[2] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[3] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[4] = "/esoui/art/champion/champion_points_stamina_icon.dds",
	[5] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[6] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[7] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[8] = "/esoui/art/champion/champion_points_magicka_icon.dds",
	[9] = "/esoui/art/champion/champion_points_health_icon.dds",
	[10] = "/esoui/art/champion/champion_points_health_icon.dds",
	[11] = "/esoui/art/champion/champion_points_health_icon.dds",
	[12] = "/esoui/art/champion/champion_points_health_icon.dds",
}

WW.BUFFFOOD = {
	[87695] = 84720, 	-- Ghastly Eye Bowl
	[87697] = 84731, 	-- Witchmother's Potent Brew
	[133556] = 100498, 	-- Clockwork Citrus Filet
	[68242] = 61257, 	-- Mistral Banana-Bunny Hash
	[68243] = 61257, 	-- Melon-Baked Parmesan Pork
	[68244] = 61257, 	-- Solitude Salmon-Millet Soup
	[139016] = 107748, 	-- Artaeum Pickled Fish Bowl
	[68236] = 61260,    -- Firsthold Fruit and Cheese Plate
	[68237] = 61260,    -- Thrice-Baked Gorapple Pie
	[68238] = 61260,    -- Tomato Garlic Chutney
	
	[112425] = 86673, 	-- Lava Foot Soup-and-Saltrice
	[120763] = 89957,	-- Dubious Camoran Throne
	[68245] = 61255, 	-- Sticky Pork and Radish Noodles
	[68246] = 61255, 	-- Garlic Cod with Potato Crust
	[68247] = 61255, 	-- Braised Rabbit with Spring Vegetables
	[139018] = 107789, 	-- Artaeum Takeaway Broth
	[68239] = 61261,	-- Hearty Garlic Corn Chowder
	[68240] = 61261,	-- Bravil's Best Beet Risotto
	[68241] = 61261,	-- Tenmar Millet-Carrot Couscous
	
	[68249] = 61294, 	-- Grapes and Ash Yam Falafel
	[87686] = 84681,	-- Crisp and Crunchy Pumpkin Snack Skewer
	
	[71059] = 72824, 	-- Orzorga's Smoked Bear Haunch
	[68251] = 61218, 	-- Capon Tomato-Beet Casserole
	[68252] = 61218, 	-- Jugged Rabbit in Preserves
	[68253] = 61218, 	-- Longfin Pasty with Melon Sauce
	[68254] = 61218, 	-- Withered Tree Inn Venison Pot Roast
	[153629] = 127596, 	-- Bewitched Sugar Sculls
	
	[120762] = 89955,	-- Candied Jester's Coins
	[87691] = 84709,	-- Crunchy Spider Skewer
}

WW.CONDITIONS = {
	NONE = 0,
	EVERYWHERE = -1,
}

WW.MARKINVENTORIES = {
	ZO_PlayerInventoryBackpack,
    ZO_PlayerBankBackpack,
    ZO_GuildBankBackpack,
    ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
}

WW.PREVIEWTABLE = {
	TRAITS = {
		[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "a",
		[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "b",
		[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "c",
		[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = "d",
		[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "e",
		[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = "f",
		[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "g",
		[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "h",
		[ITEM_TRAIT_TYPE_ARMOR_STURDY] = "i",
		[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "j",
		[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "k",
		[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = "l",
		[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = "m",
		[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = "n",
		[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = "o",
		[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = "c",
		[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = "d",
		[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = "f",
		[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = "p",
		[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = "q",
		[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = "r",
		[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = "s",
		[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "t",
		[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "u",
		[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "v",
		[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "c",
		[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = "d",
		[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "e",
		[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = "f",
		[ITEM_TRAIT_TYPE_WEAPON_POWERED] = "w",
		[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "x",
		[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "y",
		[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "j",
		["a"] = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
		["b"] = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
		["c"] = ITEM_TRAIT_TYPE_ARMOR_INFUSED,
		["d"] = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
		["e"] = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED,
		["f"] = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
		["g"] = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS,
		["h"] = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
		["i"] = ITEM_TRAIT_TYPE_ARMOR_STURDY,
		["j"] = ITEM_TRAIT_TYPE_ARMOR_TRAINING,
		["k"] = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
		["l"] = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
		["m"] = ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
		["n"] = ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
		["o"] = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
		["p"] = ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE,
		["q"] = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
		["r"] = ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
		["s"] = ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
		["t"] = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
		["u"] = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
		["v"] = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
		["w"] = ITEM_TRAIT_TYPE_WEAPON_POWERED,
		["x"] = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
		["y"] = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
		[0] = 0,
	},
	FOOD = {
		[87695] = "a",
		[87697] = "b",
		[133556] = "c",
		[68242] = "d",
		[68243] = "e",
		[68244] = "f",
		[139016] = "g",
		[68236] = "h",
		[68237] = "i",
		[68238] = "j",
		[112425] = "k",
		[120763] = "l",
		[68245] = "m",
		[68246] = "n",
		[68247] = "o",
		[139018] = "p",
		[68239] = "q",
		[68240] = "r",
		[68241] = "s",
		[68249] = "t",
		[87686] = "u",
		[71059] = "v",
		[68251] = "w",
		[68252] = "x",
		[68253] = "y",
		[68254] = "z",
		[153629] = "1",
		[120762] = "2",
		[87691] = "3",
		["a"] = 87695,
		["b"] = 87697,
		["c"] = 133556,
		["d"] = 68242,
		["e"] = 68243,
		["f"] = 68244,
		["g"] = 139016,
		["h"] = 68236,
		["i"] = 68237,
		["j"] = 68238,
		["k"] = 112425,
		["l"] = 120763,
		["m"] = 68245,
		["n"] = 68246,
		["o"] = 68247,
		["p"] = 139018,
		["q"] = 68239,
		["r"] = 68240,
		["s"] = 68241,
		["t"] = 68249,
		["u"] = 87686,
		["v"] = 71059,
		["w"] = 68251,
		["x"] = 68252,
		["y"] = 68253,
		["z"] = 68254,
		["1"] = 153629,
		["2"] = 120762,
		["3"] = 87691,
		[0] = 0,
		["0"] = 0,
	},
}