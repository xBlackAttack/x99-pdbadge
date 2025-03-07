config = {}

-- "police" = LSPD  |  "sheriff" = BCSO  |  "trooper" = SASP  |  "ranger" = SAPR padge model
-- Badge create client event name: x99_badge:create (this is client event)

config.badgecommand = 'pdbadge' -- command to create badge (only police job)
config.usecreatecommand = true -- use /newbadge command (only police job)
config.photocommand = "changebadgephoto" -- command to change badge photo
config.usephotocommand = true -- use /changebadgephoto command
config.badgedistance = 3.5 -- distance from player to badge
config.closeKey = 194 -- badge close key (default: backspace)
config.coreData = {
    eventPrefix = "QBCore",
    scriptName = "qb-core",
    smallEventPrefix = "qb" 
}

config.authorizedJobs = {
    "police", 
    "ambulance"
}


config.Notifys = {
    ["nocallsign"] = "Callsign not found!",
    ["permissionerror"] = "You don't have permission to do this!",
    ["reloadPdData"] = "Data loaded!",
}

-- You can change the badge model here
config.grades = {
    [1] = {
        "police",
        "sheriff",
        "trooper",
    },
    [2] = {
        "police",
        "sheriff",
        "trooper",
    }
}



config.reloadcmmnd = true -- true: activate reloads data command
config.refreshcmnnd = 'reloadpddata' -- reload player data command name 