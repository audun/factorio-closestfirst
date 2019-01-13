local d = require("defines")
data:extend({
      {
         type = "string-setting",
         name = d.search_area_setting,
         setting_type = "runtime-global",
         default_value = "80x80 (4x Roboport Mk2)",
         allowed_values = {
            "20x20",
            "30x30 (Roboport Mk1)",
            "40x40 (Roboport Mk2)",
            "50x50",
            "60x60 (4x Roboport Mk1)",
            "70x70",
            "80x80 (4x Roboport Mk2)",
            "90x90",
            "100x100 (6x Roboport Mk2)",
            "120×120 (9x Roboport Mk2)",
            "No limit (up to equipped Roboport range)"
         },
         order = "a",
      },
      {
         type = "string-setting",
         name = d.update_rate_setting,
         setting_type = "runtime-global",
         default_value = "Normal",
         allowed_values = {"Off", "Slow", "Normal", "Fast", "Faster", "Fastest"},
         order = "b",
      },
      {
         type = "string-setting",
         name = d.limit_area_setting,
         setting_type = "runtime-per-user",
         default_value = "80x80 (4x Roboport Mk2)",
         allowed_values = {
            "20x20",
            "30x30 (Roboport Mk1)",
            "40x40 (Roboport Mk2)",
            "50x50",
            "60x60 (4x Roboport Mk1)",
            "70x70",
            "80x80 (4x Roboport Mk2)",
            "90x90",
            "100x100 (6x Roboport Mk2)",
            "120×120 (9x Roboport Mk2)",
            "No limit (up to equipped Roboport range)"
         },
         order = "c",
      },
})
