local d = require("defines")

-- Getters
local function get_orig_name(eq)
   return eq.prototype.take_result.place_as_equipment_result.name
end
local function get_orig_range(eq)
   return eq.prototype.take_result.place_as_equipment_result.logistic_parameters.construction_radius
end
local function get_curr_range(eq)
   return eq.prototype.logistic_parameters.construction_radius
end
local function get_curr_limit(eq)
   return eq.prototype.logistic_parameters.robot_limit
end
local function get_player_range(player)
   return player.character.logistic_network.cells[1].construction_radius
end

local function replace_roboport(grid, old, new_name)
   local pos = old.position
   local energy = old.energy
   grid.take{ position = old.position }
   local new = grid.put{ name = new_name, position = pos }
   new.energy = energy
end

-- Copied and adapted from folk-stopthat
-- License: CC-BY-NC 4.0
local function restore(g)
   for _, eq in next, g.equipment do
      if eq.type == "roboport-equipment" and eq.prototype.order == d._ORDER then
         replace_roboport(g, eq, eq.prototype.take_result.name)
      end
   end
end
-- /copied

-- Range calculations
local function get_original_range(g)
   local original_range = 0
   for _, eq in next, g.equipment do
      if eq.type == "roboport-equipment" then
         original_range = original_range + get_orig_range(eq)
      end
   end
   return original_range
end

local function get_grid_range2(grid)
   local total = 0
   for _, eq in next, grid.equipment do
      if eq.type == "roboport-equipment" then
         local r = get_curr_range(eq)
         total = total + r*r
      end
   end
   return total
end

local function get_grid_robot_limit(grid)
   local total = 0
   for _, eq in next, grid.equipment do
      if eq.type == "roboport-equipment" then
         total = total + get_curr_limit(eq)
      end
   end
   return total
end

local function get_grid_range(grid)
   return math.sqrt(get_grid_range2(grid))
end

local function set_to_desired_range(grid, desired)
   local current_range = get_grid_range(grid)

   -- game.print("current_range: " .. current_range)
   -- game.print("desired: " .. desired)

   if current_range < desired then
      -- In many situations this will be inefficient, but it seems reliable
      restore(grid)
      current_range = get_grid_range(grid)
   end

   if current_range > desired then
      for _, eq in next, grid.equipment do
         if eq.type == "roboport-equipment" and current_range > desired then
            local eq_range = get_curr_range(eq)
            if eq_range > 0 then
               -- Probably some closed formula for this, but I'm not aware of it and this is not a bottleneck
               local current_range2_without_this = get_grid_range2(grid) - (eq_range * eq_range)
               while eq_range > 0 and current_range > desired do
                  eq_range = eq_range - 1
                  current_range = math.sqrt((eq_range * eq_range) + current_range2_without_this)
               end
               local new_name = get_orig_name(eq) .. "-reduced-" .. eq_range
               -- game.print("swapping in : " .. new_name)
               replace_roboport(grid, eq, new_name)
            end
         end
      end
   end
end

local function adjust_all_players_to_their_limit()
   for index,player in pairs(game.connected_players) do
      c = player.character  
      if c and c.grid then
         local limit_range = d.range_setting_table[settings.get_player_settings(player)[d.limit_area_setting].value] / 2
         if limit_range > 0 then
            set_to_desired_range(c.grid, limit_range)
         else
            restore(c.grid)
         end
      end
   end      
end

-- require 'stdlib/log/logger'
-- LOGGER = Logger.new("ClosestFirstDev", "fancylog", true, {log_ticks=true} )

local function find_close_entities(player)
   local logistic = player.character.logistic_network
   local grid = player.character.grid
   if logistic and logistic.all_construction_robots > 0 and logistic.robot_limit > 0 and grid then
      local limit_area = d.range_setting_table[settings.get_player_settings(player)[d.limit_area_setting].value]
      local original_range = 2 * get_original_range(grid)
      if limit_area > 0 then
         original_range = math.min(original_range, limit_area)
      end
      original_range = original_range / 2
      if original_range <= 0 then return nil end
      local search_area_radius = d.range_setting_table[settings.global[d.search_area_setting].value] / 2;
      if search_area_radius <= 0 then search_area_radius = original_range end

      -- Search the smallest of the original range and the setting
      local radius = math.min(original_range, search_area_radius)
      local pos = player.position;
      local px = pos.x
      local py = pos.y -- I'm just unrolling everything now...
      local area = {
         {px-radius, py-radius},
         {px+radius, py+radius}}
      return player.surface.find_entities_filtered{area = area, force = {player.force, "neutral"}}
   end
   return nil
end

local function inventory_has_items_that_can_revive_ghost(inventory, ghost_entity)

    local placeable_items = ghost_entity.ghost_prototype.items_to_place_this
    
    if placeable_items == nil then return false end
    
    for _, item in pairs(placeable_items) do
        if inventory[item.name] ~= nil then return true end
    end

    return false
end

local function adjust_player_range(player, entities)
   local logistic = player.character.logistic_network
   -- game.print("available: " .. logistic.available_construction_robots)
   -- game.print("range: " .. logistic.cells[1].construction_radius)

   local grid = player.character.grid
   if logistic and logistic.all_construction_robots > 0 and logistic.robot_limit > 0 and grid then

      local limit_area = d.range_setting_table[settings.get_player_settings(player)[d.limit_area_setting].value]
      local original_range = 2 * get_original_range(grid)
      if limit_area > 0 then
         original_range = math.min(original_range, limit_area)
      end
      original_range = original_range / 2
      -- game.print(original_range)
      if original_range <= 0 then return end

      local pos = player.position;
      local px = pos.x
      local py = pos.y -- I'm just unrolling everything now...

      -- LOGGER.log("done finding " .. #entities .. " entities")
      -- ghosts = player.surface.find_entities_filtered{area = area, type = "entity-ghost"}
      if next(entities) == nil then
         -- game.print("no entities?")
         set_to_desired_range(grid, original_range)
      else
         -- game.print("entities: " .. #entities)
         
         -- Not sure if it's faster to get all or to query individually
         -- Profiling shows that these two queries are extremely fast at least
         -- LOGGER.log("getting inventories")
         local items_main = player.get_main_inventory().get_contents()
         -- LOGGER.log("done getting inventories")

         local buckets = {}
         local maxn = 0
         -- LOGGER.log("filtering and calculating buckets")
         local force = player.force
         local targets = {}
         
         -- Bot capacity modifier is the amount by which to reduce the contribution of each entity
         -- to its total count in order to attempt to account for batching that can be done by the game.
         local bot_capacity = 1 + force.worker_robots_storage_bonus
         local bot_capacity_modifier = 1
         if bot_capacity > 1 then
            bot_capacity_modifier = bot_capacity * 0.75
         end
         
         for index,entity in pairs(entities) do
            if entity.valid then
               if entity.to_be_deconstructed(force) or entity.to_be_upgraded() then
                  -- Copypaste begin
                     local epos = entity.position
                     local x = epos.x - px
                     local y = epos.y - py
                     local d = x*x + y*y
                     local bucket = math.ceil(d)
                     if buckets[bucket] == nil then
                        buckets[bucket] = 0
                     end
                     buckets[bucket] = buckets[bucket] + 1
                     if bucket > maxn then
                        maxn = bucket
                     end
                  -- Copypaste end
               elseif entity.type == "entity-ghost" or entity.type == "tile-ghost" then
                  if inventory_has_items_that_can_revive_ghost(items_main, entity) then
                     -- Copypaste begin
                     local epos = entity.position
                     local x = epos.x - px
                     local y = epos.y - py
                     local d = x*x + y*y
                     local bucket = math.ceil(d)
                     if buckets[bucket] == nil then
                        buckets[bucket] = 0
                     end
                     -- Decrease the increment to allow the range to be bigger, if bots can batch build tasks.
                     -- Currently batching is only done when placing tiles.
                     local increment = 1
                     if entity.type == "tile-ghost" and bot_capacity > 1 then
                        increment = increment / bot_capacity_modifier
                     end
                     buckets[bucket] = buckets[bucket] + increment
                     if bucket > maxn then
                        maxn = bucket
                     end
                     -- Copypaste end
                  end
               end
            end
         end
         -- LOGGER.log("done filtering and calculating buckets")

         -- This can return more bots than can be used by the roboports
         local bots = logistic.available_construction_robots
         local robot_limit = logistic.robot_limit
         -- game.print("robot_limit: " .. robot_limit)
         local cell = logistic.cells[1]
         local charging = cell.charging_robot_count + cell.to_charge_robot_count
         -- game.print("charging: " .. charging)
         -- local inventory_bots = (items_main["construction-robot"] or 0)
         -- game.print("inventory_bots: " .. inventory_bots)

         -- The construction bots are holding on to tasks while waiting for charging
         bots = math.min(logistic.available_construction_robots, robot_limit - charging)
--         bots = math.min(logistic.available_construction_robots, robot_limit)
         bots = math.max(bots, 1)
         -- game.print("bots: " .. bots)
         
         -- Possible optimization opportunity is to use a partial sort, but I guess table.sort is natively implemented
         -- table.sort(targets, function(a,b) return dists[a] < dists[b] end)

         -- LOGGER.log("looping buckets")
         local assigned = 0
         local desired = original_range
         for i=1, maxn do
            if buckets[i] ~= nil then
               assigned = assigned + math.ceil(buckets[i])
               if assigned >= bots then
                  desired = math.ceil(math.sqrt(i)) + 1
                  -- game.print("assigned: " .. assigned .. " i: " .. i .. " desired: " .. desired)
                  break
               end
            end
         end

         desired = math.min(desired, original_range)
         -- game.print("desired: " .. desired)
         -- LOGGER.log("setting range")
         set_to_desired_range(grid, desired)
         -- LOGGER.log("done setting range")
      end
   end
end

local function tick(event)
   local valid_players = 0
   for index,player in pairs(game.connected_players) do
      if player.character then
         valid_players = valid_players + 1
      end
   end
   update_rate = math.max(global.update_rate, valid_players * 2) -- minimum 2 ticks per player
   local tick_offset = 13 -- just a random prime to attempt avoiding overlap with other mods which does work at regular intervals
   local valid_index = 0
   for index,player in pairs(game.connected_players) do
      if player.character then
         valid_index = valid_index + 1
         if (game.tick + tick_offset + valid_index + 1) % update_rate == 0 then
            -- LOGGER.log("profile set t" .. game.tick)
            -- LOGGER.log("Tick: " .. game.tick)
            global.close_entities[player.name] = find_close_entities(player)
            -- LOGGER.log("done ticking")
            -- LOGGER.log("profile get t" .. game.tick)
         elseif (game.tick + tick_offset + valid_index) % update_rate == 0 then
            local close_entities = global.close_entities[player.name]
            if close_entities ~= nil then
               adjust_player_range(player, close_entities)
            end
         end
      end
   end
end

local function register_event_handlers()
   if global.update_rate and global.update_rate > 0 then
      script.on_event({defines.events.on_tick}, tick)
   else
      script.on_event({defines.events.on_tick}, nil)
   end
end

local function setup()
   global.close_entities = {}
   global.update_rate = d.update_rate_setting_table[settings.global[d.update_rate_setting].value]

   adjust_all_players_to_their_limit()
   register_event_handlers()
end

script.on_load(register_event_handlers)
script.on_event(defines.events.on_runtime_mod_setting_changed, setup)
script.on_configuration_changed(setup)

