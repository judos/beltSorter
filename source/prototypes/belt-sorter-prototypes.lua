local function BSpicture(lvl)
  return {
    layers = {
      {
        filename = "__beltSorter__/graphics/entity/belt-sorter-" .. lvl .. "-base.png",
        width = 64,
        height = 64,
        hr_version = {
          filename = "__beltSorter__/graphics/entity/hr-belt-sorter-" .. lvl .. "-base.png",
          width = 128,
          height = 128,
          scale = 0.5,
        }
      },
      {
        filename = "__beltSorter__/graphics/entity/belt-sorter-shadow.png",
        width = 64,
        height = 64,
        draw_as_shadow = true,
        hr_version = {
          filename = "__beltSorter__/graphics/entity/hr-belt-sorter-shadow.png",
          width = 128,
          height = 128,
          scale = 0.5,
          draw_as_shadow = true,
        }
      }
    }
  }
end

local BSledpicture = {
  filename = "__beltSorter__/graphics/entity/belt-sorter-light-on.png",
  width = 64,
  height = 64,
  draw_as_glow = true,
  hr_version = {
    filename = "__beltSorter__/graphics/entity/hr-belt-sorter-light-on.png",
    width = 128,
    height = 128,
    scale = 0.5,
    draw_as_glow = true,
  }
}

circuit_connector_definitions["beltsorter"] = circuit_connector_definitions.create(universal_connector_template, {
  {variation = 26, main_offset = util.by_pixel(7, 13), shadow_offset = util.by_pixel(0, 7), show_shadow = true}
})

-----------------------------------------------------------------------------------------------------------------------------------------------------------
function BeltSorterItemPrototype(i)
  data:extend({
    {
      type = "item",
      name = "belt-sorter" .. i,
      icon = "__beltSorter__/graphics/icons/belt-sorter" .. i .. ".png",
      icon_size = 64,
      subgroup = "belt",
      order = "z[belt-sorter]" .. i,
      place_result = "belt-sorter" .. i,
      stack_size = 50,
    }
  })
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
function BeltSorterPrototype(i, energy)
  local beltSorter = deepcopy(data.raw["lamp"]["small-lamp"])
  beltSorter.name = "belt-sorter"..i
  beltSorter.icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png"
  beltSorter.energy_usage_per_tick = tostring(energy).."W"
  beltSorter.light = {intensity = 0, size = 0}
  beltSorter.picture_off = BSpicture(i)
  beltSorter.picture_on = BSledpicture
  beltSorter.alert_icon_scale = 0.2
  beltSorter.minable.result = "belt-sorter"..i
  beltSorter.circuit_connector_sprites = nil
  beltSorter.circuit_wire_connection_point = circuit_connector_definitions["beltsorter"].points
  print(x(settings.startup['beltSorter-usePower']))
  if not settings.startup['beltSorter-usePower'].value then
    beltSorter.energy_source.type = "void"
  end
  data:extend({beltSorter})

  -- Entity: fake lamp for wire connection -- snouz: I think this should go but the control logic is convoluted, and it needs some tricky migration.
  local beltSorterLamp = deepcopy(data.raw["lamp"]["belt-sorter" .. i])
  beltSorterLamp.name = "belt-sorter-lamp"..i
  beltSorterLamp.collision_box = {{0, 0}, {0, 0}}
  beltSorterLamp.selection_box = {{0, 0}, {0, 0}}
  beltSorterLamp.flags = {"placeable-off-grid", "not-repairable", "not-on-map"}
  beltSorterLamp.picture_off = { filename = "__beltSorter__/graphics/entity/empty.png", size = 1 }
  beltSorterLamp.picture_on = BSledpicture
  data:extend({beltSorterLamp})
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
function BeltSorterRecipePrototype(i, ingredients)
  data:extend({
    {
      type = "recipe",
      name = "belt-sorter" .. i,
      enabled = false,
      ingredients = ingredients,
      result = "belt-sorter" .. i
    }
  })
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
function BeltSorterTechPrototype(i, prerequisites, count, ingredients)
  data:extend({
    {
      type = "technology",
      name = "belt-sorter" .. i,
      icon = "__beltSorter__/graphics/technology/belt-sorter" .. i .. ".png",
      icon_size = 256,
      prerequisites = prerequisites,
      effects = {
        {
          type = "unlock-recipe",
          recipe = "belt-sorter" .. i
        }
      },
      unit = {
        count = count,
        ingredients = ingredients,
        time = 15
      },
      order = "zzzz_belt-sorter" .. i
    }
  })
end
