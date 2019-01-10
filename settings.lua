local d = require("defines")
data:extend({
      {
         type = "int-setting",
         name = d.search_area_setting,
         setting_type = "runtime-global",
         default_value = 20,
         minimum_value = 0,
         order = "a",
      },
      {
         type = "int-setting",
         name = d.update_rate_setting,
         setting_type = "runtime-global",
         default_value = 60,
         minimum_value = 0,
         maximum_value = 300,
         order = "b",
      },
      {
         type = "int-setting",
         name = d.limit_area_setting,
         setting_type = "runtime-per-user",
         default_value = 30,
         minimum_value = 0,
         order = "c",
      },
})
