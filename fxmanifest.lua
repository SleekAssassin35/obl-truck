fx_version 'cerulean'
game 'gta5'

author 'Psytion'
lua54 'yes'

escrow_ignore {
	"client/*.lua",
    "server/*.lua",
	"config.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config.lua",
    "server/server.lua"
};

client_scripts {
    "config.lua",
    "client/client.lua"
};

ui_page "nui/index.html"

files {
    "nui/index.html",
    "nui/app.js",
    "nui/assets/**/*",
    "nui/style.css",
}

dependency '/assetpacks'