fx_version 'adamant'
this_is_a_map 'yes'

game 'gta5'

description 'Master-MinerJob'

server_scripts {
	'server/main.lua',
	'config.lua',
	"@mysql-async/lib/MySQL.lua"
}

client_scripts {
	'config.lua',
	'client/main.lua'
}

ui_page "html/index.html"
files({
    'html/index.html',
    'html/index.js',
    'html/index.css',
})