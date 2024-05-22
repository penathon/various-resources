fx_version 'adamant'
lua54 'yes'

game 'gta5'

description 'dui projectors'

version '1.4.0'

shared_scripts {
    '@ox_lib/init.lua'
}


server_scripts {
	'dui_server.lua'
}

client_scripts {
	'@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
	'dui_client.lua'
}
