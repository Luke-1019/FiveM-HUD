fx_version 'bodacious'
game 'gta5'

client_scripts {
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/*.css',
  'html/images/*.svg',
  'html/images/*.png',
  'html/*.js'
}

dependencies {
	'es_extended'
}