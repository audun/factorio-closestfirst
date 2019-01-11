local d = require("defines")
local serpent = require("serpent")

-- Math
function dist2(position1, position2)
   return math.pow(position2.x - position1.x, 2) + math.pow(position2.y - position1.y, 2)
end


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


local function adjust_player_range(player)
   local logistic = player.character.logistic_network
   -- game.print("available: " .. logistic.available_construction_robots)
   -- game.print("range: " .. logistic.cells[1].construction_radius)

   -- Cannot use available_construction_robots here because it often becomes 0 when we need to change range
   if logistic and logistic.all_construction_robots > 0 and logistic.robot_limit > 0 then

      local grid = player.character.grid
      local limit_area = settings.get_player_settings(player)[d.limit_area_setting].value
      local original_range = 2 * get_original_range(grid)
      if limit_area > 0 then
         original_range = math.min(original_range, limit_area)
      end
      original_range = original_range / 2
      -- game.print(original_range)
      if original_range <= 0 then return end

      local radius = math.min(original_range, settings.global[d.search_area_setting].value / 2)
      local area = {
         {player.position.x-radius, player.position.y-radius},
         {player.position.x+radius, player.position.y+radius}}

      -- Can't see a filter that would allow me to find only ghosts and tiles/entities to be deconstructed
      local entities = player.surface.find_entities(area)
      -- ghosts = player.surface.find_entities_filtered{area = area, type = "entity-ghost"}
      if next(entities) == nil then
         -- game.print("no entities?")
         set_to_desired_range(grid, original_range)
      else
         local dists = {}

         -- Not sure if it's faster to get all or to query individually
         local items_quickbar = player.get_inventory(defines.inventory.player_quickbar).get_contents()
         local items_main = player.get_inventory(defines.inventory.player_main).get_contents()

         local targets = {}
         for index,entity in pairs(entities) do
            if entity.to_be_deconstructed(player.force) then
               table.insert(targets, entity)
               dists[entity] = dist2(entity.position, player.position)
            else
               if entity.type == "entity-ghost" or entity.type == "tile-ghost" then
                  dists[entity] = dist2(entity.position, player.position)
                  local has_item = items_main[entity.ghost_name] or items_quickbar[entity.ghost_name]
                  if has_item then
                     --    game.print("entity.ghost_name: " .. entity.ghost_name .. ' has_item')
                     table.insert(targets, entity)
                     -- else
                     --    -- game.print("entity.ghost_name: " .. entity.ghost_name .. ' missing_item')
                  end
               end
            end
         end
         -- game.print("targets: " .. #targets)

         -- Possible optimization opportunity is to use a partial sort, but I guess table.sort is natively implemented
         table.sort(targets,
                    function(a,b)
                       return dists[a] < dists[b]
                    end
         )

         -- This can return more bots than can be used by the roboports
         local bots = logistic.available_construction_robots
         local robot_limit = logistic.robot_limit
         -- game.print("robot_limit: " .. robot_limit)
         local cell = logistic.cells[1]
         local charging = cell.charging_robot_count + cell.to_charge_robot_count
         -- game.print("charging: " .. charging)
         -- local inventory_bots = (items_quickbar["construction-robot"] or 0) + (items_main["construction-robot"] or 0)
         -- game.print("inventory_bots: " .. inventory_bots)

         -- The construction bots are holding on to tasks while waiting for charging
         bots = math.min(logistic.available_construction_robots, robot_limit - charging)
--         bots = math.min(logistic.available_construction_robots, robot_limit)
         bots = math.max(bots, 1)
         -- game.print("bots: " .. bots)
         local desired = original_range * original_range
         for index,entity in pairs(targets) do
            if index <= bots then
               -- game.print(index .. ": " .. entity.entity_name .. " " .. dists[entity])
               desired = dists[entity]
            else
               break
            end
         end
         desired = math.ceil(math.sqrt(desired)) + 1
         desired = math.min(desired, original_range)
         -- game.print("desired: " .. desired)
         set_to_desired_range(grid, desired)
      end
   end
end

script.on_event({defines.events.on_tick},
   function (e)
      -- Disable if update_rate_setting is 0.
      -- TODO: Perhaps a settings changed event could let us restore the original roboports?
      local update_rate = settings.global[d.update_rate_setting].value
      if update_rate > 0 and game.tick % update_rate == 0
      then
         for index,player in pairs(game.connected_players) do
            if player.valid
               and player.connected
               and player.character
            then
               adjust_player_range(player)
            end
         end
      end
   end
)
