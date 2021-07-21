fx_version 'adamant'
this_is_a_map 'yes'

game 'gta5'

description 'Master-MinerJob'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	'server/main.lua',
	'config.lua',
	'server/masterking32_loader.lua'
}

client_scripts {
	'config.lua',
	'client/*.lua'
}

ui_page "html/index.html"
files({
    'html/index.html',
    'html/index.js',
    'html/index.css',
})