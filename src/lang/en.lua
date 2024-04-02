local language = {

	-- MESSAGES
	WW_MSG_FIRSTSTART =
	"If you are using Wizard's Wardrobe for the first time please be sure to check out the FAQ and feature list on the %s page. Most questions are already answered there.",
	WW_MSG_ENOENT = "There is no such entry.",
	WW_MSG_ERROR = "ERROR!",
	WW_MSG_LOADSETUP = "Loading setup [%s] from [%s].",
	WW_MSG_LOADINFIGHT = "Loading setup [%s] from [%s] after combat.",
	WW_MSG_SAVESETUP = "Saving setup [%s].",
	WW_MSG_DELETESETUP = "Deleting setup [%s].",
	WW_MSG_EMPTYSETUP = "Setup is empty.",
	WW_MSG_FOODENOENT = "Could not find matching buff food in your inventory!",
	WW_MSG_NOFOODRUNNING = "No food running. Eat food and try again or drag & drop food onto food button.",
	WW_MSG_NOTFOOD = "This item is no buff food or is currently not supported.",
	WW_MSG_LOADSKILLS = "Loading skills %s from [%s].",
	WW_MSG_SAVESKILLS = "Saving skills to setup %s.",
	WW_MSG_SKILLENOENT = "Could not slot [%s]. Skill not unlocked.",
	WW_MSG_SKILLSTUCK = "Could not slot skill [%s].",
	WW_MSG_LOADGEAR = "Loading gear %s from [%s].",
	WW_MSG_SAVEGEAR = "Saving gear to setup %s.",
	WW_MSG_GEARENOENT = "Could not find %s in your inventory!",
	WW_MSG_GEARSTUCK = "Could not move item %s.",
	WW_MSG_FULLINV = "Your inventory is full. Gear may have not been moved properly.",
	WW_MSG_LOADCP = "Loading CP %s from [%s].",
	WW_MSG_SAVECP = "Saving CP to setup %s.",
	WW_MSG_CPENOENT = "Could not slot [%s]. Star is not unlocked.",
	WW_MSG_CPCOOLDOWN = "Champion points will be changed in %ss.",
	WW_MSG_CPCOOLDOWNOVER = "Champion points changed.",
	WW_MSG_TELEPORT_PLAYER = "Teleporting to %s.",
	WW_MSG_TELEPORT_WAYSHRINE = "Teleporting to wayshrine.",
	WW_MSG_TELEPORT_WAYSHRINE_ERROR = "Wayshrine not unlocked.",
	WW_MSG_TELEPORT_HOUSE = "Teleporting into primary residence.",
	WW_MSG_TOGGLEAUTOEQUIP = "%s auto-equip.",
	WW_MSG_TOGGLEAUTOEQUIP_ON = "Enabled",
	WW_MSG_TOGGLEAUTOEQUIP_OFF = "Disabled",
	WW_MSG_CLEARQUEUE = "Cleared %d queue entries.",
	WW_MSG_NOREPKITS = "Could not find any repair kits in your inventory!",
	WW_MSG_NOTENOUGHREPKITS = "Could not find enough repair kits in your inventory!",
	WW_MSG_NOSOULGEMS = "Could not find any soul gems in your inventory!",
	WW_MSG_NOTENOUGHSOULGEMS = "Could not find enough soul gems in your inventory!",
	WW_MSG_NOPOISONS = "Could not find any poisons in your inventory!",
	WW_MSG_IMPORTSUCCESS = "All items imported successfully.",
	WW_MSG_IMPORTGEARENOENT =
	"Not all items could be imported. Make sure you have all of the items in your inventory or in your bank. Traits don't matter.",
	WW_MSG_WITHDRAW_SETUP = "Withdrawing setup [%s] from bank.",
	WW_MSG_WITHDRAW_PAGE = "Withdrawing all setups of [%s] from bank.",
	WW_MSG_WITHDRAW_FULL = "Could not move items. Be sure there is enough space in your inventory.",
	WW_MSG_WITHDRAW_ENOENT = "Not all items could be found in the bank.",
	WW_MSG_DEPOSIT_SETUP = "Depositing setup [%s] to bank.",
	WW_MSG_DEPOSIT_PAGE = "Depositing all setups of [%s] from bank.",
	WW_MSG_DEPOSIT_FULL = "Could not deposit items to bank. Be sure there is enough space.",
	WW_MSG_TRANSFER_FINISHED = "All items were moved successfully.",
	WW_MSG_TRANSFER_TIMEOUT = "At least one item is stuck. Please try again.",
	WW_MSG_FOOD_FADED = "Your buff food ran out. Enjoy your %s!",
	WW_MSG_FOOD_COMBAT =
	"Your buff food just ran out mid combat. The wizard will provide you with %s after the combat if still needed.",
	WW_MSG_NOFOOD = "Could not find any matching buff food in your inventory!",
	WW_MSG_SWAPFAIL = "%s in your Setup failed to swap, attempting workaround, please wait a few seconds",
	WW_MSG_SWAPFAIL_DISABLED = "%s in your Setup failed to swap",
	WW_MSG_SWAPSUCCESS = "Setup successfully loaded",
	WW_MSG_SWAP_FIX_FAIL = "All workarounds have failed, please try to manually unequip the stuck piece",


	-- ADDON MENU
	WW_MENU_GENERAL = "General",
	WW_MENU_PRINTCHAT = "Print messages",
	WW_MENU_PRINTCHAT_TT =
	"Prints messages about loaded setups into the chat, the alert notifications or the center screen announcements",
	WW_MENU_PRINTCHAT_OFF = "Disabled",
	WW_MENU_PRINTCHAT_CHAT = "Chat",
	WW_MENU_PRINTCHAT_ALERT = "Alert",
	WW_MENU_PRINTCHAT_ANNOUNCEMENT = "Announcement",
	WW_MENU_OVERWRITEWARNING = "Show warning on overwrite",
	WW_MENU_OVERWRITEWARNING_TT = "Shows a warning if an already saved setup is overwritten.",
	WW_MENU_INVENTORYMARKER = "Inventory marker",
	WW_MENU_INVENTORYMARKER_TT = "Shows a small icon over items in the inventory that are saved in setups.",
	WW_MENU_UNEQUIPEMPTY = "Unequip empty slots",
	WW_MENU_UNEQUIPEMPTY_TT =
	"If something is saved as empty in the setup, the item/champion point/skill will be unequipped.",
	WW_MENU_IGNORE_TABARDS = "Ignore empty tabard slots",
	WW_MENU_IGNORE_TABARDS_TT = "If an outfit is saved with no tabard, don't remove any currently equipped tabard",
	WW_MENU_RESETUI = "Reset UI",
	WW_MENU_RESETUI_TT =
	"|cFF0000This resets the window and all its positions on the scenes.|r\nIt must then be opened again with /wizard or the hotkey.",
	WW_MENU_AUTOEQUIP = "Auto-Equip",
	WW_MENU_AUTOEQUIP_DESC = "These settings control what exactly is loaded/saved from the setup.",
	WW_MENU_AUTOEQUIP_GEAR = "Gear",
	WW_MENU_AUTOEQUIP_SKILLS = "Skills",
	WW_MENU_AUTOEQUIP_CP = "Champion points",
	WW_MENU_AUTOEQUIP_BUFFFOOD = "Buff food",
	WW_MENU_SUBSTITUTE = "Substitute setups",
	WW_MENU_SUBSTITUTE_OVERLAND = "Overland",
	WW_MENU_SUBSTITUTE_OVERLAND_TT = "Also includes delves and public dungeons.",
	WW_MENU_SUBSTITUTE_DUNGEONS = "Dungeons",
	WW_MENU_SUBSTITUTE_WARNING =
	"These options enable loading of substitute setups outside the supported zones. It is |cFF0000experimental|r and will not work on all bosses. New dungeons usually work better than old ones.",
	WW_MENU_PANEL = "Info panel",
	WW_MENU_PANEL_ENABLE = "Enable panel",
	WW_MENU_PANEL_ENABLE_TT =
	"Shows the set and page name as well as the current zone.\nA |cF8FF70yellow|r set name indicates a delayed loading of the setup. A |cFF7070red|r set name means that the current setup no longer matches the saved one.",
	WW_MENU_PANEL_MINI = "Lite mode",
	WW_MENU_PANEL_MINI_TT = "Hides icon and reduces the size of the panel.",
	WW_MENU_PANEL_LOCK = "Lock ui",
	WW_MENU_MODULES = "Modules",
	WW_MENU_CHARGEWEAPONS = "Automatically charge weapons",
	WW_MENU_REPAIRARMOR = "Automatically repair armor",
	WW_MENU_REPAIRARMOR_TT = "Repairing at vendor and using repair kits.",
	WW_MENU_FILLPOISONS = "Automatically refill poisons",
	WW_MENU_FILLPOISONS_TT =
	"Automatically tries to refill poisons from the inventory.\n|H1:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:138240|h|h is also exchanged with |H1:item:79690:6:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h (and vice versa) if otherwise not available.",
	WW_MENU_BUFFFOOD = "Automatically renew buff food",
	WW_MENU_BUFFFOOD_TT =
	"Automatically eats the matching food again when it runs out. Only works in trials and dungeons.\nLook into \"WizardsWardrobeConst.lua\" to see which foods are supported. More to come.",
	WW_MENU_FIXES_FIXSURFINGWEAPONS = "Fix surfing on weapons",
	WW_MENU_FIXES_FIXSURFINGWEAPONS_TT =
	"This will toggle \"Hide Your Helm\" twice every zone swap in order to fix the weapon surf bug.",
	WW_MENU_WEAPON_GEAR_FIX = "Fix failed gear swaps.",
	WW_MENU_WEAPON_GEAR_FIX_TT = "Automates the steps we take to fix failed gear swaps",
	WW_MENU_VALIDATION_DELAY = "Validation delay",
	WW_MENU_VALIDATION_DELAY_TT = "Chose here the amount of MS after which the setup validation takes place",
	WW_MENU_VALIDATION_DELAY_WARN =
	"The longer the delay the lower the chance to have false positives. If its too low, it might cause unintended behavior.",
	WW_MENU_COMPARISON_DEPTH = "Comparison depth",
	WW_MENU_COMPARISON_DEPTH_EASY = "Easy",
	WW_MENU_COMPARISON_DEPTH_DETAILED = "Detailed",
	WW_MENU_COMPARISON_DEPTH_THOROUGH = "Thorough",
	WW_MENU_COMPARISON_DEPTH_STRICT = "Strict",
	WW_MENU_COMPARISON_DEPTH_EASY_TT = "Will only check the trait, the weapon type and the set.",
	WW_MENU_COMPARISON_DEPTH_DETAILED_TT = "Will check the trait, the weapon type the set and quality.",
	WW_MENU_COMPARISON_DEPTH_THOROUGH_TT = "Will check the trait, the weapon type the set, quality and enchantment.",
	WW_MENU_COMPARISON_DEPTH_STRICT_TT =
	"Will check if its the exact same piece of gear that was saved. Will fail if you change anything.",


	-- USER INTERFACE
	WW_CHANGELOG =
	"Attention! This update contains some major changes. Please read the current changelog as some things may now work differently from what they used to.",
	WW_BUTTON_HELP = "|cFFFFFF[Click]|r to open wiki",
	WW_BUTTON_SETTINGS = "Settings",
	WW_BUTTON_CLEARQUEUE = "Reset queue\n(Can be used if too many set changes have been queued.)",
	WW_BUTTON_UNDRESS = "Undress",
	WW_BUTTON_PREBUFF = "Prebuff",
	WW_BUTTON_LABEL = "|cFFFFFF[Click]|r to load setup",
	WW_BUTTON_BANKING = "|cFFFFFF[Click]|r to withdraw gear,\n|cFFFFFF[Shift + Click]|r to deposit",
	WW_BUTTON_PREVIEW = "Preview",
	WW_BUTTON_SAVE = "Save",
	WW_BUTTON_MODIFY = "Modify",
	WW_BUTTON_RENAME = "Rename",
	WW_BUTTON_REARRANGE = "Rearrange",
	WW_BUTTON_TELEPORT = "Teleport",
	WW_BUTTON_TOGGLEAUTOEQUIP = "Toggle auto-equip",
	WW_BUTTON_ADDPAGE = "Add page",
	WW_BUTTON_ADDSETUP = "Add setup",
	WW_BUTTON_GEAR =
	"No gear saved!\nPress |cFFFFFF[Shift + Click]|r to save current gear or drag & drop items onto this button.",
	WW_BUTTON_SKILLS =
	"No skills saved!\nPress |cFFFFFF[Shift + Click]|r to save current hotbars or drag & drop spells onto this button.",
	WW_BUTTON_CP = "No CPs saved!\nPress |cFFFFFF[Shift + Click]|r to save current slottables.",
	WW_BUTTON_BUFFFOOD =
	"No buff food saved!\nPress |cFFFFFF[Shift + Click]|r to save current food or drag & drop food onto this button.",
	WW_RENAME_PAGE = "Enter new name for page:",
	WW_DELETEPAGE_WARNING = "Really delete page [%s]?",
	WW_OVERWRITESETUP_WARNING = "Really overwrite setup [%s]?",
	WW_DELETE = "Delete",
	WW_ENABLE = "Enable",
	WW_DISABLE = "Disable",
	WW_MISSING_GEAR_TT = "Following items are missing:\n\n%s\n\n|cFFFFFF[Click]|r to refresh",
	WW_SUBSTITUTE_EXPLAIN =
	"These setups are loaded if there is no setup stored on the selected trial page.\nIf you don't want to use this feature, just leave it empty.",
	WW_CONDITION_NAME = "Name",
	WW_CONDITION_BOSS = "Boss",
	WW_CONDITION_AFTER = "After",
	WW_CONDITION_NONE = "None",
	WW_CONDITION_EVERYWHERE = "Everywhere",
	WW_IMPORT = "Import",
	WW_IMPORT_HELP =
	"Paste |cFFFFFF[CTRL + V]|r the exported text here. Make sure that the text is not manipulated, otherwise the import may fail.\nYou need all items in the inventory. The traits of the exported setup will be prioritized, but if the item in the inventory does not have the correct trait, items with a \"wrong\" trait will also be used.",
	WW_IMPORT_TT = "|cFF0000Attention! This will overwrite the selected setup.|r",
	WW_EXPORT = "Export",
	WW_EXPORT_HELP =
	"Copy the selected text with |cFFFFFF[CTRL + C]|r and share it with others.\nIt contains gear, skills and champion points in a compact format to import it elsewhere.",
	WW_CUSTOMCODE = "Lua Code",
	WW_CUSTOMCODE_HELP = "This code is executed after the setup is loaded.",
	WW_DUPLICATE = "Duplicate",
	WW_DUPLICATE_NAME = "Copy of %s",
	WW_LINK_IMPORT = "Add to Wardrobe",
	WW_PREBUFF_HELP =
	"Drag and drop spells onto the prebuff bars.\nIf toggle is checked it will keep the prebuff spells on your hotbar until you press that hotbar again. Otherwise it will be unslotted after casting.\nDelay for \"normal\" spells is ~500ms, channeled abilities need more.",


	-- BOSS & TRIAL NAMES
	WW_PAGE                    = "Page %s",
	WW_EMPTY                   = "Empty",
	WW_UNNAMED                 = "Unnamed",
	WW_TRASH                   = "Trash",

	WW_GENERAL                 = "General",

	WW_SUB_NAME                = "Substitute Setups",
	WW_SUB_BOSS                = "Substitute Boss",
	WW_SUB_TRASH               = "Substitute Trash",

	WW_PVP_NAME                = "Player versus Player",

	WW_AA_NAME                 = "Aetherian Archive",
	WW_AA_STORMATRO            = "Lightning Storm Atronach",
	WW_AA_STONEATRO            = "Foundation Stone Atronach",
	WW_AA_VARLARIEL            = "Varlariel",
	WW_AA_MAGE                 = "The Mage",

	WW_SO_NAME                 = "Sanctum Ophidia",
	WW_SO_MANTIKORA            = "Possessed Mantikora",
	WW_SO_TROLL                = "Stonebreaker",
	WW_SO_OZARA                = "Ozara",
	WW_SO_SERPENT              = "The Serpent",

	WW_HRC_NAME                = "Hel Ra Citadel",
	WW_HRC_RAKOTU              = "Ra Kotu",
	WW_HRC_LOWER               = "Yokeda Rok'dun",
	WW_HRC_UPPER               = "Yokeda Kai",
	WW_HRC_WARRIOR             = "The Warrior",

	WW_MOL_NAME                = "Maw of Lokhaj",
	WW_MOL_ZHAJHASSA           = "Zhaj'hassa the Forgotten",
	WW_MOL_TWINS               = "Twins",
	WW_MOL_RAKKHAT             = "Rakkhat",

	WW_HOF_NAME                = "Halls of Fabrication",
	WW_HOF_HUNTERKILLER        = "Hunter-Killer Negatrix",
	WW_HOF_HUNTERKILLER_DN     = "Hunter-Killer",
	WW_HOF_FACTOTUM            = "Pinnacle Factotum",
	WW_HOF_SPIDER              = "Archcustodian",
	WW_HOF_COMMITEE            = "Reactor",
	WW_HOF_COMMITEE_DN         = "Commitee",
	WW_HOF_GENERAL             = "Assembly General",

	WW_AS_NAME                 = "Asylum Sanctorium",
	WW_AS_OLMS                 = "Saint Olms the Just",
	WW_AS_FELMS                = "Saint Felms the Bold",
	WW_AS_LLOTHIS              = "Saint Llothis the Pious",

	WW_CR_NAME                 = "Cloudrest",
	WW_CR_GALENWE              = "Shade of Galenwe",
	WW_CR_RELEQUEN             = "Shade of Relequen",
	WW_CR_SIRORIA              = "Shade of Siroria",
	WW_CR_ZMAJA                = "Z'Maja",

	WW_SS_NAME                 = "Sunspire",
	WW_SS_LOKKESTIIZ           = "Lokkestiiz",
	WW_SS_YOLNAHKRIIN          = "Yolnahkriin",
	WW_SS_NAHVIINTAAS          = "Nahviintaas",

	WW_KA_NAME                 = "Kyne's Aegis",
	WW_KA_YANDIR               = "Yandir the Butcher",
	WW_KA_VROL                 = "Captain Vrol",
	WW_KA_FALGRAVN             = "Lord Falgravn",

	WW_RG_NAME                 = "Rockgrove",
	WW_RG_OAXILTSO             = "Oaxiltso",
	WW_RG_BAHSEI               = "Flame-Herald Bahsei",
	WW_RG_XALVAKKA             = "Xalvakka",
	WW_RG_SNAKE                = "Basks-In-Snakes",
	WW_RG_ASHTITAN             = "Ash Titan",

	WW_DSR_NAME                = "Dreadsail Reef",
	WW_DSR_LYLANARTURLASSIL    = "Lylanar",
	WW_DSR_LYLANARTURLASSIL_DN = "Lylanar and Turlassil",
	WW_DSR_GUARDIAN            = "Reef Guardian",
	WW_DSR_TALERIA             = "Tideborn Taleria",
	WW_DSR_SAILRIPPER          = "Sail Ripper",
	WW_DSR_BOWBREAKER          = "Bow Breaker",

	WW_SE_NAME                 = "Sanity's Edge",
	WW_SE_DESCENDER            = "Spiral Descender",
	WW_SE_YASEYLA              = "Exarchanic Yaseyla",
	WW_SE_TWELVANE             = "Archwizard Twelvane",
	WW_SE_ANSUUL               = "Ansuul the Tormentor",

	-- Arena

	WW_MA_NAME                = "Maelstrom Arena",

	WW_VH_NAME                 = "Vateshran Hollows",

	WW_DSA_NAME                = "Dragonstar Arena",

	WW_BRP_NAME                = "Blackrose Prison",
	WW_BRP_FIRST               = "Battlemage Ennodius",
	WW_BRP_SECOND              = "Tames-The-Beast",
	WW_BRP_THIRD               = "Lady Minara",
	WW_BRP_FOURTH              = "All of them",
	WW_BRP_FIFTH               = "Drakeeh the Unchained",
	WW_BRP_FINALROUND          = "Final Round",

	-- DUNGEONS
	WW_WGT_NAME = "White Gold Tower",
	WW_WGT_THE_ADJUDICATOR  = "The Adjudicator",
	WW_WGT_THE_PLANAR_INHIBITOR  = "The Planar Inhibitor",
	WW_WGT_MOLAG_KENA = "Molag Kena",

	WW_ICP_NAME = "Imperial City Prison",
	WW_ICP_IBOMEZ_THE_FLESH_SCULPTOR = "Ibomez the Flesh Sculptor",
	WW_ICP_FLESH_ABOMINATION = "Flesh Abomination",
	WW_ICP_LORD_WARDEN_DUSK = "Lord Warden Dusk",

	WW_ROM_NAME = "Ruins of Mazzatun",
	WW_ROM_MIGHTY_CHUDAN = "Mighty Chudan",
	WW_ROM_XAL_NUR_THE_SLAVER = "Xal-Nur the Slaver",
	WW_ROM_TREE_MINDER_NA_KESH = "Tree-Minder Na-Kesh",

	WW_COS_NAME = "Cradle of Shadows",
	WW_COS_KHEPHIDAEN = "Khephidaen",
	WW_COS_DRANOS_VELEADOR = "Dranos Velador",
	WW_COS_VELIDRETH = "Velidreth",

	WW_FH_NAME = "Falkreath Hold",
	WW_FH_MORRIGH_BULLBLOOD = "Morrigh Bullblood",
	WW_FH_SIEGE_MAMMOTH = "Siege Mammoth",
	WW_FH_CERNUNNON = "Cernunnon",
	WW_FH_DEATHLORD_BJARFRUD_SKJORALMOR = "Deathlord Bjarfrud Skjoralmor",
	WW_FH_DOMIHAUS_THE_BLOODY_HORNED = "Domihaus the Bloody-Horned",

	WW_BF_NAME = "Bloodroot Forge",
	WW_BF_MATHGAMAIN = "Mathgamain",
	WW_BF_CAILLAOIFE = "Caillaoife",
	WW_BF_STONEHEARTH = "Stoneheart",
	WW_BF_GALCHOBHAR = "Galchobhar",
	WW_BF_GHERIG_BULLBLOOD = "Gherig Bullblood",
	WW_BF_EARTHGORE_AMALGAM = "Earthgore Amalgam",

	WW_FL_NAME = "Fang Lair",
	WW_FL_LIZABET_CHARNIS = "Lizabet Charnis",
	WW_FL_CADAVEROUS_BEAR = "Cadaverous Bear",
	WW_FL_CALUURION = "Caluurion",
	WW_FL_ULFNOR = "Ulfnor",
	WW_FL_THURVOKUN = "Thurvokun",

	WW_SCP_NAME = "Scalescaller Peak",
	WW_SCP_ORZUN_THE_FOUL_SMELLING = "Orzun the Foul-Smelling",
	WW_SCP_DOYLEMISH_IRONHEARTH = "Doylemish Ironheart",
	WW_SCP_MATRIACH_ALDIS = "Matriarch Aldis",
	WW_SCP_PLAGUE_CONCOCTER_MORTIEU = "Plague Concocter Mortieu",
	WW_SCP_ZAAN_THE_SCALECALLER = "Zaan the Scalecaller",

	WW_MHK_NAME = "Moon Hunter Keep",
	WW_MHK_JAILER_MELITUS = "Jailer Melitus",
	WW_MHK_HEDGE_MAZE_GUARDIAN = "Hedge Maze Guardian",
	WW_MHK_MYLENNE_MOON_CALLER = "Mylenne Moon-Caller",
	WW_MHK_ARCHIVIST_ERNADE = "Archivist Ernarde",
	WW_MHK_VYKOSA_THE_ASCENDANT = "Vykosa the Ascendant",

	WW_MOS_NAME = "March of Sacrifices",
	WW_MOS_WYRESS_RANGIFER = "Wyress Strigidae",
	WW_MOS_AGHAEDH_OF_THE_SOLSTICE = "Aghaedh of the Solstice",
	WW_MOS_DAGRUND_THE_BULKY = "Dagrund the Bulky",
	WW_MOS_TARCYR = "Tarcyr",
	WW_MOS_BALORGH = "Balorgh",

	WW_FV_NAME = "Frostvault",
	WW_FV_ICESTALKER = "Icestalker",
	WW_FV_WARLORD_TZOGVIN = "Warlord Tzogvin",
	WW_FV_VAULT_PROTECTOR = "Vault Protector",
	WW_FV_RIZZUK_BONECHILL = "Rizzuk Bonechill",
	WW_FV_THE_STONEKEEPER = "The Stonekeeper",

	WW_DOM_NAME = "Depths of Malatar",
	WW_DOM_THE_SCAVENGING_MAW = "The Scavenging Maw",
	WW_DOM_THE_WEEPING_WOMAN = "The Weeping Woman",
	WW_DOM_DARK_ORB = "Dark Orb",
	WW_DOM_KING_NARILMOR = "King Narilmor",
	WW_DOM_SYMPHONY_OF_BLADE = "Symphony of Blades",

	WW_LOM_NAME = "Lair of Maarselok",
	WW_LOM_SELENE = "Selene",
	WW_LOM_AZUREBLIGHT_LURCHER = "Azureblight Lurcher",
	WW_LOM_AZUREBLIGHT_CANCROID = "Azureblight Cancroid",
	WW_LOM_MAARSELOK = "Maarselok",
	WW_LOM_MAARSELOK_BOSS = "Maarselok (Boss)",

	WW_MGF_NAME = "Moongrave Fane",
	WW_MGF_RISEN_RUINS = "Risen Ruins",
	WW_MGF_DRO_ZAKAR = "Dro'zakar",
	WW_MGF_KUJO_KETHBA = "Kujo Kethba",
	WW_MGF_NISAAZDA = "Nisaazda",
	WW_MGF_GRUNDWULF = "Grundwulf",

	WW_IR_NAME = "Icereach",
	WW_IR_KJARG_THE_TUSKSCRAPER = "Kjarg the Tuskscraper",
	WW_IR_SISTER_SKELGA = "Sister Skelga",
	WW_IR_VEAROGH_THE_SHAMBLER = "Vearogh the Shambler",
	WW_IR_STORMBOND_REVENANT = "Stormborn Revenant",
	WW_IR_ICEREACH_COVEN = "Icereach Coven",

	WW_UHG_NAME = "Unhallowed Grave",
	WW_UHG_HAKGRYM_THE_HOWLER = "Hakgrym the Howler",
	WW_UHG_KEEPER_OF_THE_KILN = "Keeper of the Kiln",
	WW_UHG_ETERNAL_AEGIS = "Eternal Aegis",
	WW_UHG_ONDAGORE_THE_MAD = "Ondagore the Mad",
	WW_UHG_KJALNAR_TOMBSKALD = "Kjalnar Tombskald",
	WW_UHG_NABOR_THE_FORGOTTEN = "Nabor the Forgotten",
	WW_UHG_VORIA_THE_HEARTH_THIEF = "Voria the Heart-Thief",
	WW_UHG_VORIAS_MASTERPIECE = "Voria's Masterpiece",

	WW_SG_NAME = "Stone Garden",
	WW_SG_EXARCH_KRAGLEN = "Exarch Kraglen",
	WW_SG_STONE_BEHEMOTH = "Stone Behemoth",
	WW_SG_ARKASIS_THE_MAD_ALCHEMIST = "Arkasis the Mad Alchemist",

	WW_CT_NAME = "Castle Thorn",
	WW_CT_DREAD_TINDULRA = "Dread Tindulra",
	WW_CT_BLOOD_TWILIGHT = "Blood Twilight",
	WW_CT_VADUROTH = "Vaduroth",
	WW_CT_TALFYG = "Talfyg",
	WW_CT_LADY_THORN = "Lady Thorn",

	WW_BDV_NAME = "Black Drake Villa",
	WW_BDV_KINRAS_IRONEYE = "Kinras Ironeye",
	WW_BDV_CAPTAIN_GEMINUS = "Captain Geminus",
	WW_BDV_PYROTURGE_ENCRATIS = "Pyroturge Encratis",
	WW_BDV_AVATAR_OF_ZEAL = "Avatar of Zeal",
	WW_BDV_AVATAR_OF_VIGOR = "Avatar of Vigor",
	WW_BDV_AVATAR_OF_FORTITUDE = "Avatar of Fortitude",
	WW_BDV_SENTINEL_AKSALAZ = "Sentinel Aksalaz",

	WW_TC_NAME = "The Cauldron",
	WW_TC_OXBLOOD_THE_DEPRAVED = "Oxblood the Depraved",
	WW_TC_TASKMASTER_VICCIA = "Taskmaster Viccia",
	WW_TC_MOLTEN_GUARDIAN = "Molten Guardian",
	WW_TC_DAEDRIC_SHIELD = "Daedric Shield",
	WW_TC_BARON_ZAULDRUS = "Baron Zaudrus",

	WW_RPB_NAME = "Red Petal Bastion",
	WW_RPB_ROGERAIN_THE_SLY = "Rogerain the Sly",
	WW_RPB_ELIAM_MERICK = "Eliam Merick",
	WW_RPB_PRIOR_THIERRIC_SARAZEN = "Prior Thierric Sarazen",
	WW_RPB_WRAITH_OF_CROWS = "Wraith of Crows",
	WW_RPB_SPIDER_DEADRA = "Spider Daedra",
	WW_RPB_GRIEVIOUS_TWILIGHT = "Grievous Twilight",

	WW_DC_NAME = "Dread Cellar",
	WW_DC_SCORION_BROODLORD = "Scorion Broodlord",
	WW_DC_CYRONIN_ARTELLIAN = "Cyronin Artellian",
	WW_DC_MAGMA_INCARNATE = "Magma Incarnate",
	WW_DC_PURGATOR = "Purgator",
	WW_DC_UNDERTAKER = "Undertaker",
	WW_DC_GRIM_WARDEN = "Grim Warden",

	WW_CA_NAME ="Coral Arie",
	WW_CA_B1 ="Magligalig",
	WW_CA_B2 ="Sarydil",
	WW_CA_B3 ="Varallion",
	WW_CA_SCB1 ="Sword Guardian",
	WW_CA_SCB2 ="Staff Guardian",
	WW_CA_SCB3 ="Shield Guardian",
	WW_CA_SCB4 ="Z’baza",

	WW_SR_NAME = "Shipwright’s Regret",
	WW_SR_B1="Foreman Bradiggan",
	WW_SR_B2="Nazaray",
	WW_SR_B3="Captain Numirril",
	WW_SR_SCB1="Lost Maiden",
	WW_SR_SCB2="Shrouded Axeman",
	WW_SR_SCB3="Storm-Cursed Sailor",

	WW_ERE_NAME="Earthen Root Enclave",
	WW_ERE_B1="Corruption of Stone",
	WW_ERE_B2="Corruption of Root",
	WW_ERE_B3="Archdruid Devyric",
	WW_ERE_SCB1="Scaled Roots",
	WW_ERE_SCB2="Lutea",
	WW_ERE_SCB3="Jodoro",

	WW_GD_NAME="Graven Deep",
	WW_GD_B1="The Euphotic Gatekeeper",
	WW_GD_B2="Varzunon",
	WW_GD_B3="Zelvraak the Unbreathing",
	WW_GD_SCB1="Mzugru",
	WW_GD_SCB2="Xzyviian",
	WW_GD_SCB3="Chralzak",

	WW_BS_NAME="Bal Sunnar",
	WW_BS_B1="Kovan Giryon",
	WW_BS_B2="Roksa the Warped",
	WW_BS_B3="Matriarch Lladi Telvanni",
	WW_BS_SCB="Urvel Drath",

	WW_SH_NAME="Scrivener's Hall",
	WW_SH_B1="Ritemaster Maqri",
	WW_SH_B2="Ozezan the Inferno",
	WW_SH_B3="Valinna",

	WW_BV_NAME="Bedlam Veil",
	WW_BV_B1="Shattered Champion",
	WW_BV_B2="Darkshard",
	WW_BV_B3="The Blind",

	WW_OP_NAME="Oathsworn Pit",
	WW_OP_B1="Packmaster Rethelros & Malthil",
	WW_OP_B2="Anthelmir’s Construct",
	WW_OP_B3="Aradros the Awakened",
	WW_OP_MB1="Sluthrug the Bloodied",
	WW_OP_MB2="Bolg of Wicked Barbs",
	WW_OP_MB3="Grubduthag Many-Fates",


	-- KEYBINDS
	SI_BINDING_NAME_WW_HOTKEY_SHOW_UI = "Open Wizard's Wardrobe",
	SI_BINDING_NAME_WW_HOTKEY_FIXES_FLIP_SHOULDERS = "Fix Shoulder",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_1 = "Setup 1 (Trash)",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_2 = "Setup 2",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_3 = "Setup 3",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_4 = "Setup 4",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_5 = "Setup 5",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_6 = "Setup 6",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_7 = "Setup 7",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_8 = "Setup 8",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_9 = "Setup 9",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_10 = "Setup 10",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_11 = "Setup 11",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_12 = "Setup 12",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_13 = "Setup 13",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_14 = "Setup 14",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_15 = "Setup 15",
	SI_BINDING_NAME_WW_HOTKEY_PREBUFF_1 = "Prebuff 1",
	SI_BINDING_NAME_WW_HOTKEY_PREBUFF_2 = "Prebuff 2",
	SI_BINDING_NAME_WW_HOTKEY_PREBUFF_3 = "Prebuff 3",
	SI_BINDING_NAME_WW_HOTKEY_PREBUFF_4 = "Prebuff 4",
	SI_BINDING_NAME_WW_HOTKEY_PREBUFF_5 = "Prebuff 5",

	SI_BINDING_NAME_WW_HOTKEY_UNDRESS = "Undress",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_PREVIOUS = "Equip previous setup",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_CURRENT = "Reload current setup",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_NEXT = "Equip next setup",
	SI_BINDING_NAME_WW_HOTKEY_SETUP_FIX = "Try to fix failed setup swap"
}

for key, value in pairs( language ) do
	SafeAddVersion( key, 1 )
	ZO_CreateStringId( key, value )
end
