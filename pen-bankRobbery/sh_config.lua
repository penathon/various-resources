config = {}

config.electricityBoxes = {
    vespucciBeach2 = {
        coords = {
            { 
                x = -2231.72,
                y = -326.69, 
                z = 36.4,
                rotation =  29.4,
                zoneSize = vec3(1.5, 1, 1.75)
            }
        }
    },
    vespucciBeach3 = {
        coords = {
            { 
                x = -1231.72,
                y = -326.69, 
                z = 36.4,
                rotation =  29.4,
                zoneSize = vec3(1.5, 1, 1.75)
            }
        }
    }
}

config.banks = {
    fleecaVespucci = {
        data = {
            { 
                bankDoorData = { model = `v_ilev_gb_vauldr`, x = -1211.26, y = -334.56, z = 37.92, closedDoorHeading = 296.86, openDoorHeading = 10},

                panelData = { x = -1210.48, y = -336.43, z = 38.03, rotation = 10, zoneSize = vec3(1.5, 1, 1.75) },
                -- safeCoords = {},
                electricityBoxes = { 'vespucciBeach3'},
                rewards = {},
                cooldownTime = 15,
                type = 'fleeca'
            }
        }
    }
}
