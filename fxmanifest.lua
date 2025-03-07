fx_version 'cerulean'

game 'gta5'

version '1.0.0'
lua54 'yes'
client_scripts {
    'client/*.lua',
    'client/src/image/*.png',
    'client/src/*.html',
    'client/src/*.css',
    'config.lua'
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua'
}

escrow_ignore {
    'config.lua',
    'ReadME.txt'
  }

ui_page 'client/src/index.html'

files {
	'client/src/*.html',
	'client/src/*.css',
	'client/src/*.js',
	'client/src/image/*.png',
    "stream/x99_policebadge_bcso.ydr",
    "stream/x99_policebadge_lspd.ydr",
    "stream/x99_policebadge_sasp.ydr",
    "stream/x99_policebadge.ytyp"
}

data_file "DLC_ITYP_REQUEST" "stream/x99_policebadge.ytyp"