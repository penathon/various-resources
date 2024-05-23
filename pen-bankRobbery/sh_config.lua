config = {}


config.electricityBoxes = {
    vespucciBeach2 = {
        coords = {
            { 
                x = -2231.72,
                y = -326.69, 
                z = 36.4,
                exploded = false,
            }
        }
    },
    vespucciBeach3 = {
        coords = {
            { 
                x = -1231.72,
                y = -326.69, 
                z = 36.4,
                exploded = false,
            }
        }
    }
}

config.banks = {
    pacificBank = {
        data = {
            { 
                active = false,
                bankDoorModel = `v_ilev_gb_vauldr`,
                bankDoorCoords = { x = -1211.26, y = -334.56, z = 37.92},
                closedDoorHeading = 10,
                openDoorHeading = 10,
                -- safeCoords = {},
                electricityBoxes = { 'vespucciBeach3', 'vespucciBeach2'},
                ready = false,
                rewards = {},
                doorOpen = false,
                cooldownTime = 15
            }
        }
    }
}
