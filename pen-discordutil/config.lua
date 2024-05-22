Config = {
    DiscordToken = "",
	GuildId = "",

	Roles = {

        ["Member"] = "917912577768566842",
        ["AOP"] = "917912578087338039",
	    ["Cooldown"] = "917912578087338038",

	    ["LEO"] = "917912578146074634",
        ["LEO Reserve"] = "917912578120904729",
        ["LEO Command"] = "917912578146074640",

	    ["Fire"] = "917912578120904732",
        ["Fire Reserve"] = "917912578120904727",
        ["Fire Command"] = "917912578146074637",

	    ["Civ"] = "917912578120904731",
        ["Civ Command"] = "917912578146074638",

        ["Developer"] = "917912578238316554",
        ["Management"] = "917912578213154911",
        ["Assistant"] = "1137911476590481488",
        ["Dept. Director"] = "1166530879665999933",
        ["Staff"] = "1063322875043516476",

        ["Admin"] = "917912578146074642",
        ["Superadmin"] = "923825977535107112",
        ["Moderator"] = "917912578146074641",

        ["Benny's"] = "1214091417824002118",

        ["Server Booster"] = "923451568592936981",
        ["Bronze Supporter"] = "1173057683327287386", 
        ["Silver Supporter"] = "1173057722783113266", 
        ["Gold Supporter"] = "1173057752210346066", 
        ["Platinum Supporter"] = "1173057780417044521",
        ["Diamond Supporter"] = "1185715418195820544",
        ["Titanium Supporter"] = "1185715465566290021",
        ["Emerald Supporter"] = "1206449480589901864",



    },

    RolesToAce = {
        ["Management"] = "group.management",
        ["Developer"] = "group.management",
        ["Superadmin"] = "group.superadmin",
        ["Admin"] = "group.admin",
        ["Moderator"] = "group.moderator"
    },

    CopRoles = {
        ["Fire"] = true,
        ["Fire Command"] = true,
        ["Fire Reserve"] = true,
        ["Superadmin"] = true
    },

    FireRoles = {
        ["LEO"] = true,
        ["LEO Command"] = true,
        ["LEO Reserve"] = true,
        ["Superadmin"] = true
    },

    CivRoles = {
        ["Civ"] = true,
        ["Civ Command"] = true,
        ["Superadmin"] = true
    },

    StaffRoles = {
        ["Admin"] = true,
        ["Moderator"] = true,
        ["Superadmin"] = true
    },

    Webhooks = {
        ["Clock-in Leo"] = "",
        ["Clock-in Fire"] = "",
        ["911 Calls"] = "",
        ["Jail / Hospital Logs"] = "",
    },

    Webhook = "",
}

Config.Splash = {
	Header_IMG = '',
	Enabled = false,
	Wait = 10, -- How many seconds should splash page be shown for? (Max is 12)
	Heading1 = "",
	Heading2 = "Make sure to join our Discord and check out our website!",
	Discord_Link = '',
	Website_Link = '',
}
