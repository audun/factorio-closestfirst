local d = require("defines")

feature("Settings", function()
    
    before_scenario(function()
          -- Give roboport
    end)

    after_scenario(function()

    end)
    
    scenario("limit_area_setting", function()
        faketorio.log.info("limit_area_setting")

        local player_settings = settings.get_player_settings(game.player)
        faketorio.log.info("got player_settings!")
        
        local limit_range = d.range_setting_table[player_settings[d.limit_area_setting].value] / 2
        faketorio.log.info("got limit_range!")

        settings.global[d.limit_area_setting].value = "10x10"
        script.raise_event(defines.events.on_runtime_mod_setting_changed, {})
        
    end)
    
    scenario("Deconstruction of tiles", function()
        faketorio.log.info("Deconstruction of tiles")

    end)
    
end)

feature("Entities", function()
    
    before_scenario(function()
          
    end)

    after_scenario(function()

    end)
    
    scenario("Construction of entities", function()
        faketorio.log.info("Construction of entities")
    end)
    
    scenario("Upgrade planner", function()
        faketorio.log.info("Upgrade planner")
    end)
    
    scenario("Deconstruction of entities", function()
        faketorio.log.info("Deconstruction of entities")
    end)
    
end)

feature("Tiles", function()
    
    before_scenario(function()
          
    end)

    after_scenario(function()

    end)
    
    scenario("Construction of tiles", function()
        faketorio.log.info("Construction of tiles")
    end)
    
    scenario("Deconstruction of tiles", function()
        faketorio.log.info("Deconstruction of tiles")
    end)
    
end)

