local noPicture = { filename = "__beltSorter__/graphics/entity/empty.png", size = 1 }

local function picture(lvl, mode_on)
  layering = {
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
  if mode_on then
    table.insert(layering.layers, {
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
    )
  end
  return layering
end

function createBeltSorterPrototype(i, energy)

  local beltSorter = deepcopy(data.raw["lamp"]["small-lamp"])
  beltSorter.name = "belt-sorter"..i
  beltSorter.icon = "__beltSorter__/graphics/icons/belt-sorter"..i..".png"
  beltSorter.energy_usage_per_tick = tostring(energy).."W"
  beltSorter.light = {intensity = 0, size = 0}
  beltSorter.picture_off = picture(i, false)
  beltSorter.picture_on = picture(i, true)
  beltSorter.alert_icon_scale = 0.2
  beltSorter.minable.result = "belt-sorter"..i
  beltSorter.circuit_connector_sprites = nil
  print(x(settings.startup['beltSorter-usePower']))
  if not settings.startup['beltSorter-usePower'].value then
    beltSorter.energy_source.type = "void"
  end
  data:extend({beltSorter})

  -- Entity: fake lamp for wire connection
  local beltSorterLamp = deepcopy(data.raw["lamp"]["belt-sorter" .. i])
  beltSorterLamp.name = "belt-sorter-lamp"..i
  beltSorterLamp.order = "zzz"
  beltSorterLamp.collision_box = {{0, 0}, {0, 0}}
  beltSorterLamp.selection_box = {{0, 0}, {0, 0}}
  beltSorterLamp.flags = {"placeable-off-grid", "not-repairable", "not-on-map"}
  beltSorterLamp.picture_off = noPicture
  beltSorterLamp.picture_on = noPicture
  data:extend({beltSorterLamp})

end

function createBeltSorterItemPrototype(i)
  local beltSorter = {
    type = "item",
    name = "belt-sorter" .. i,
    icon = "__beltSorter__/graphics/icons/belt-sorter" .. i .. ".png",
    icon_size = 64,
    subgroup = "inserter",
    order = "z[belt-sorter]" .. i,
    place_result = "belt-sorter" .. i,
    stack_size = 50,
  }
  data:extend({beltSorter})
end
