-- Putting this in data-updates.lua, I guess any other mods that defines their own roboports
-- will do that in data.lua, and this should definitely go before StopThat

local d = require("defines")

local roboports = {}
for name, eq in pairs(data.raw["roboport-equipment"]) do
   roboports[name] = eq
end
for name, eq in pairs(roboports) do
   local radius = eq.construction_radius
   for i=0, radius do
      local robocopy = table.deepcopy(eq)
      robocopy.construction_radius = i
      robocopy.name = robocopy.name .. "-reduced-" .. i;
      robocopy.order = d._ORDER
      if not eq.take_result then
         robocopy.take_result = eq.name
      end
      data:extend{robocopy};
   end
end
