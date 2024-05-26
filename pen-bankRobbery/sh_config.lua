config = {}


config.electricityBoxes = {
    vespucciBeach2 = {
        coords = {
            { 
                x = -2231.72,
                y = -326.69, 
                z = 36.4,
            }
        }
    },
    vespucciBeach3 = {
        coords = {
            { 
                x = -1231.72,
                y = -326.69, 
                z = 36.4,
            }
        }
    }
}

config.banks = {
    pacificBank = {
        data = {
            { 
                bankDoorModel = `v_ilev_gb_vauldr`,
                bankDoorCoords = { x = -1211.26, y = -334.56, z = 37.92},
                closedDoorHeading = 296.86,
                openDoorHeading = 10,
                -- safeCoords = {},
                electricityBoxes = { 'vespucciBeach3'},
                rewards = {},
                cooldownTime = 15
            }
        }
    }
}
