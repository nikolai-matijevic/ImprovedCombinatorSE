local util = require("__core__.lualib.util")
local constants = require("constants")

-- Core Factorio Function --
function make_rotated_animation_variations_from_sheet(variation_count, sheet) --makes remnants work with more than 1 variation
    local result = {}

    local function set_y_offset(variation, i)
        local frame_count = variation.frame_count or 1
        local line_length = variation.line_length or frame_count
        if (line_length < 1) then
            line_length = frame_count
        end

        local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
        variation.y = variation.height * (i - 1) * height_in_frames
    end

    for i = 1,variation_count do
        local variation = util.table.deepcopy(sheet)

        if variation.layers then
            for _, layer in pairs(variation.layers) do
                set_y_offset(layer, i)
                if (layer.hr_version) then
                set_y_offset(layer.hr_version, i)
                end
            end
        else
            set_y_offset(variation, i)
            if (variation.hr_version) then
                set_y_offset(variation.hr_version, i)
            end
        end

        table.insert(result, variation)
    end
    return result
end


local blank_image =
{
    filename = constants.blank_image,
    priority = "extra-high",
    width = 1,
    height = 1,
    frame_count = 1,
    shift = {0, 0}
}

local function main_item()
    local item =
    {
        type = "item",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        place_result = constants.entity.name,
        icon_size = 64,
        icon_mipmaps = 4,
        subgroup = "circuit-network",        
        order = "c[combinators]-z["..constants.entity.name.."]",
        stack_size = 50
    }
    return item
end

local function input_item()
    local combinator_input =
    {
        type = "item",
        name = constants.entity.input.name,
        icon = constants.entity.input.icon,
        place_result = constants.entity.input.name,
        icon_size = 64,
        flags = {"hidden"},
        subgroup = "circuit-network",
        order = "c[combinators]-z["..constants.entity.input.name.."]",
        stack_size = 50,
    }
    return combinator_input
end

local function output_item()
    local combinator_output =
    {
        type = "item",
        name = constants.entity.output.name,
        icon = constants.entity.output.icon,
        place_result = constants.entity.output.name,
        icon_size = 64,
        flags = {"hidden"},
        subgroup = "circuit-network",
        order = "c[combinators]-z["..constants.entity.output.name.."]",
        stack_size = 50,
    }
    return combinator_output
end

local function main_remnants()
    local main_remnants =
    {
        type = "corpse",
        name = constants.entity.remnants,
        icon = constants.entity.graphics.icon,
        icon_size = 64,
        icon_mipmaps = 4,
        scale_info_icons = true,
        scale_entity_info_icon = true,
        flags = {"placeable-neutral", "not-on-map"},
        selection_box = {{-0.75, -0.5}, {0.95, 0.5}},
        tile_width = 1,
        tile_height = 2,
        selectable_in_game = false,
        time_before_removed = 60 * 60 * 15, -- 15 minutes
        final_render_layer = "remnants",
        remove_on_tile_placement = false,
        animation = make_rotated_animation_variations_from_sheet (1,
        {
            filename = constants.entity.graphics.remnants,
            line_length = 1,
            width = 83,
            height = 59,
            frame_count = 1,
            variation_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            shift = util.by_pixel(0, 0),
            hr_version =
            {
                filename = constants.entity.graphics.hr_remnants,
                line_length = 1,
                width = 166,
                height = 118,
                frame_count = 1,
                variation_count = 1,
                axially_symmetrical = false,
                direction_count = 1,
                shift = util.by_pixel(0, 0),
                scale = 0.5,
            },
        })
    }
    return main_remnants
end

local function main_entity()
    local container =
    {
        type = "container",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        icon_size = 64,
        icon_mipmaps = 4,
        scale_info_icons = true,
        scale_entity_info_icon = true,
        flags = {"not-rotatable", "placeable-neutral", "placeable-player", "player-creation"},
        minable = {hardness = 0.2, mining_time = 2, result = constants.entity.name},
        max_health = 250,
        corpse = constants.entity.remnants,
        dying_explosion = "medium-explosion",
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		resistances = {{type = "fire", percent = 90}},
        collision_box = {{-1.0, -0.35}, {1.0, 0.35}},
        selection_box = {{-0.75, -0.5}, {0.95, 0.5}},
    	inventory_size = 0,
		circuit_wire_max_distance = 0,
		circuit_wire_connection_point = nil,
        picture =
        {
            layers =
            {
                {
                    filename = constants.entity.graphics.image,
                    priority = "extra-high",
                    width = 102,
                    height = 51,
                    shift = util.by_pixel(0, 0),
                    hr_version =
                    {
                        filename = constants.entity.graphics.hr_image,
                        priority = "extra-high",
                        width = 204,
                        height = 102,
                        shift = util.by_pixel(0, 0),
                        scale = 0.5
                    }
                },
                {
                    filename = constants.entity.graphics.image_shadow,
                    priority = "extra-high",
                    width = 100,
                    height = 33,
                    shift = util.by_pixel(8.9, 4.5),
                    draw_as_shadow = true,
                    hr_version =
                    {
                        filename = constants.entity.graphics.hr_image_shadow,
                        priority = "extra-high",
                        width = 200,
                        height = 66,
                        shift = util.by_pixel(8.7, 4.35),
                        draw_as_shadow = true,
                        scale = 0.5
                    }
                }
            }
        },
        se_allow_in_space = true
    }
    return container
end

local function input_entity()
    local combinator_input_connection_points =
    {
        red = {0.05, 0.08},
        green = {0.05, -0.33}
    }
    local combinator_input =
    {
        type = "constant-combinator",
        name = constants.entity.input.name,
        icon = constants.entity.graphics.icon,
        icon_size = 1,
        fast_replaceable_group = constants.entity.input.name,
        flags = {"not-rotatable", "placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable"},
        mineable = nil,
        order = "y",
        max_health = 100,
        corpse = "small-remnants",
        collision_mask = {"not-colliding-with-itself"},
        collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        item_slot_count = 0,
        sprites =
        {
            north = blank_image,
            east = blank_image,
            south = blank_image,
            west = blank_image
        },
        activity_led_sprites =
        {
            north = blank_image,
            east = blank_image,
            south = blank_image,
            west = blank_image
        },
        activity_led_light =
        {
            intensity = 1,
            size = 1
        },
        activity_led_light_offsets =
        {
            {0, 0},
            {0, 0},
            {0, 0},
            {0, 0}
        },
        circuit_wire_connection_points =
        {
            {
                wire = combinator_input_connection_points,
                shadow = combinator_input_connection_points
            },
            {
                wire = combinator_input_connection_points,
                shadow = combinator_input_connection_points
            },
            {
                wire = combinator_input_connection_points,
                shadow = combinator_input_connection_points
            },
            {
                wire = combinator_input_connection_points,
                shadow = combinator_input_connection_points
            }
        },
        circuit_wire_max_distance = constants.entity.input.circuit_wire_max_distance
    }
    return combinator_input
end

local function output_entity()
    local combinator_output_connection_points =
    {
        red = {0.05, -0.45},
        green = {0.05, 0}
    }
    local combinator_output =
    {
        type = "constant-combinator",
        name = constants.entity.output.name,
        icon = constants.entity.graphics.icon,
        icon_size = 1,
        fast_replaceable_group = constants.entity.output.name,
        flags = {"not-rotatable", "placeable-player", "player-creation", "placeable-off-grid", "not-deconstructable"},
        mineable = nil,
        order = "y",
        max_health = 100,
        corpse = "small-remnants",
        collision_mask = {"not-colliding-with-itself"},
        collision_box = {{-0.0, -0.0}, {0.0, 0.0}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        item_slot_count = 50,
        sprites =
        {
            north = blank_image,
            east = blank_image,
            south = blank_image,
            west = blank_image
        },
        activity_led_sprites =
        {
            north = blank_image,
            east = blank_image,
            south = blank_image,
            west = blank_image
        },
        activity_led_light =
        {
            intensity = 1,
            size = 1
        },
        activity_led_light_offsets =
        {
            {0, 0},
            {0, 0},
            {0, 0},
            {0, 0}
        },
        circuit_wire_connection_points =
        {
            {
                wire = combinator_output_connection_points,
                shadow = combinator_output_connection_points
            },
            {
                wire = combinator_output_connection_points,
                shadow = combinator_output_connection_points
            },
            {
                wire = combinator_output_connection_points,
                shadow = combinator_output_connection_points
            },
            {
                wire = combinator_output_connection_points,
                shadow = combinator_output_connection_points
            }
        },
        circuit_wire_max_distance = constants.entity.output.circuit_wire_max_distance
    }
    return combinator_output
end

local function recipe()
    local recipe =
    {
        type = "recipe",
        name = constants.entity.name,
        icon = constants.entity.graphics.icon,
        icon_size = 64,
        icon_mipmaps = 4,
        enabled = false,
        ingredients = {{"constant-combinator", 2}, {"electronic-circuit", 5}},
        result = constants.entity.name
    }
    return recipe
end

local function technology()
    local technology =
    {
        type = "technology",
        name = constants.entity.name,
        icon = constants.entity.graphics.technology_icon,
        icon_size = 140,
        order = "a-d-e",
        unit =
        {
            time = 20,
            count = 200,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1}
            }
        },
        prerequisites = {"circuit-network"},
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = constants.entity.name
            }
        }
    }
    return technology
end

data:extend({main_item(), input_item(), output_item(), main_remnants(), main_entity(), input_entity(), output_entity(), recipe(), technology()})