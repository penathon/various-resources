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
                bankDoorCoords = vector3(-1211.26, -334.56, 37.92),
                -- safeCoords = {},
                electricityBoxes = { 'vespucciBeach3', 'vespucciBeach2'},
                ready = false,
                rewards = {}
            }
        }
    }
}