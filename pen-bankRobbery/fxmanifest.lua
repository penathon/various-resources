fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

author 'pen'
description 'bank robbery'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'sh_*.lua'
}
client_script  'cl_*.lua'
server_script  'sv_*.lua'