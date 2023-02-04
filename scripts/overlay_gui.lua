local constants = require("constants")
local cached_signals = require("cached_signals")
local logger = require("logger")

local overlay_gui = {}
local signal_parent_name = "ac_overlay_signal_parent"
local constant_parent_name = "ac_overlay_constant_parent"
local constant_set_name = "ac_overlay_constant_set"
local overlay_name = "ac_overlay_button"
local group_name = "ac_overlay_group"
local signal_name = "ac_overlay_signal"
local constant_slider_name = "ac_overlay_slider"
local constant_textfield_name = "ac_overlay_textfield"
local constant_confirm_name = "ac_overlay_confirm"
local loaded = false
local signal_frame_height = 521
local signal_group_height = 71
local signal_current_signal_height = 0
local last_selected_group = nil

local function get_y_offset(constant_frame)
    --- ((mainframe height) - (constant frame hight) - (current signal frame height)) / 2
    return (608 - (constant_frame and 105 or 0) - signal_current_signal_height) / 2
end

local function text_to_slider(text)
    local value = tonumber(text)

    if value == nil then
        return 0
    end
    
    if 10 < value and value <= 100 then
        value = 10 + ((value / 100) * 10)
    elseif 100 < value and value <= 1000 then
        value = 20 + ((value / 1000) * 10)
    elseif 1000 < value and value <= 10000 then
        value = 30 + ((value / 10000) * 10)
    elseif 10000 < value and value <= 100000 then
        value = 40 + ((value / 100000) * 10)
    elseif 100000 < value and value <= 1000000 then
        value = 50 + ((value / 1000000) * 10)
    elseif 1000000 < value and value <= 10000000 then
        value = 60 + ((value / 10000000) * 10)
    elseif 10000000 < value and value <= 100000000 then
        value = 70 + ((value / 100000000) * 10)
    elseif 100000000 < value and value <= 1000000000 then
        value = 80 + ((value / 1000000000) * 10)
    elseif 1000000000 < value and value <= 2000000000 then
        value = 90 + ((value / 1000000000) * 10)
    end


    return value
end

local function slider_to_text(value)
    if 10 < value and value <= 20 then
        value = ((value % 10) * 10)
        value = (value ~= 0) and value or 100
    elseif 20 < value and value <= 30 then
        value = (value % 20) * 100
        value = (value ~= 0) and value or 1000
    elseif 30 < value and value <= 40 then
        value = (value % 30) * 1000
        value = (value ~= 0) and value or 10000
    elseif 40 < value and value <= 50 then
        value = (value % 40) * 10000
        value = (value ~= 0) and value or 100000
    elseif 50 < value and value <= 60 then
        value = (value % 50) * 100000
        value = (value ~= 0) and value or 1000000
    elseif 60 < value and value <= 70 then
        value = (value % 60) * 1000000
        value = (value ~= 0) and value or 10000000
    elseif 70 < value and value <= 80 then
        value = (value % 70) * 10000000
        value = (value ~= 0) and value or 100000000
    elseif 80 < value and value <= 90 then
        value = (value % 80) * 100000000
        value = (value ~= 0) and value or 1000000000
    elseif 90 < value and value <= 100 then
        value = (value % 90) * 2000000000
        value = (value ~= 0) and value or 2000000000
    end

    return tostring(value)
end

function overlay_gui.switch_nodes(old_node)
    old_node.gui.visible = false
    old_node.gui_element.visible = false

    local new_node = old_node.parent:recursive_find(old_node.events_params.other_node_id)    
    new_node.gui.visible = true
    new_node.gui_element.visible = true

    return new_node
end

function overlay_gui.enable_owner(entity_id)
    if global.owner then
        -- Bug-fix. Check if the recursive_find has been created 
        if global.entities[entity_id].node["recursive_find"] then
            local node = global.entities[entity_id].node:recursive_find(global.owner.node_id)

            if node.gui_element.type == "button" then
                node.gui_element.style = constants.style.dark_button_numbers_frame
            else
                node.gui_element.style = constants.style.dark_button_frame
            end
            
            global.owner = nil
        end
    end
end

function overlay_gui.destory_nodes()
    if global.screen_node then
        global.screen_node.destroy()
        global.screen_node = nil
    end
    if global.signal_node then
        global.signal_node.destroy()
        global.signal_node = nil
    end
    if global.constant_node then
        global.constant_node.destroy()
        global.constant_node = nil
    end
end

function overlay_gui.on_load()
    if not loaded then
        overlay_gui.destory_nodes()

        -- Unselect the previous owner
        if global.owner then
            local node = global.entities[global.owner.unit_number].node:recursive_find(global.owner.node_id)

            if node.gui_element.type == "button" then
                node.gui_element.style = constants.style.dark_button_numbers_frame
            else
                node.gui_element.style = constants.style.dark_button_frame
            end

            global.owner = nil
        end

        loaded = true
    end
end

function overlay_gui.has_opened_signals_node()
    return global.screen_node and global.signal_node
end

function overlay_gui.on_click(event, entity_id)
    local name = event.element.name

    if name == overlay_name then
        overlay_gui.destory_top_nodes_and_unselect(event.player_index, entity_id)
    elseif string.match(name, "^"..group_name) then
        overlay_gui.on_click_change_subgroup(event, entity_id)
    elseif string.match(name, "^"..signal_name) then
        overlay_gui.on_click_select_signal(event, entity_id)
    elseif name == constant_set_name then
        overlay_gui.on_click_set_constant(event, entity_id)
    end
end

function overlay_gui.on_gui_text_changed(event, entity_id)
    local name = event.element.name

    if name == constant_textfield_name then
        overlay_gui.on_constant_text_changed(event)
    end
end

function overlay_gui.safely_destory_top_nodes(unit_number)
    if global.owner and global.owner.unit_number == unit_number then
        overlay_gui.destory_nodes()
    end
end

function overlay_gui.destory_top_nodes_and_unselect(player_index, entity_id)
    overlay_gui.destory_nodes()
    overlay_gui.enable_owner(entity_id)

    local entity = global.entities[entity_id]
    if entity then
        game.players[player_index].opened = entity.node.gui_element
    end
end

function overlay_gui.on_click_change_subgroup(event, entity_id)

    if event.element.enabled == false then
        return
    end

    for _, child in pairs(event.element.parent.children) do
        if child.name ~= event.element.name then
            child.enabled = true
        end
    end

    event.element.enabled = false

    local group = event.element.name:gsub(group_name.."_", "")
    local table_elements = event.element.parent.parent.children[2]

    for _, table_group in pairs(table_elements.children) do
        if table_group.name == group then
            table_group.visible = true
        else
            table_group.visible = false
        end
    end

    last_selected_group = group
end

function overlay_gui.on_click_select_signal(event, entity_id)
    if event.button == defines.mouse_button_type.left and
       event.element.type == "choose-elem-button" and
       event.element.elem_type and
       event.element.elem_value then
        if global.entities[entity_id] and global.owner then
            local node = global.entities[entity_id].node:recursive_find(global.owner.node_id)

            if node and node.gui.type == "button" then
                node = overlay_gui.switch_nodes(node)
             end

            if node and node.gui.type == "choose-elem-button" then
                node.gui.elem_value = event.element.elem_value
                node.gui_element.elem_value = event.element.elem_value
                overlay_gui.destory_top_nodes_and_unselect(event.player_index, entity_id)
                node:on_signal_confirm_change({element = node.gui_element})
            end
        end
    end
end

function overlay_gui.on_click_set_constant(event, entity_id)
    if event.button == defines.mouse_button_type.left then
        if global.entities[entity_id] and global.owner then
            local node = global.entities[entity_id].node:recursive_find(global.owner.node_id)

            if node and node.gui.type == "choose-elem-button" then
                node = overlay_gui.switch_nodes(node)
            end

            if node and node.gui.type == "button" then
                -- Convert the input text to a number an back to text to remove leading zeroes
                local number = tonumber(event.element.parent.children[2].text)
                local text = tostring(number)

                -- Remove negative zero
                if number == -0 then
                    number = 0
                    text = "0"
                end

                -- Cap values --
                if number > 2000000000 then
                    number = 2000000000
                    text = "2000000000"
                elseif number < -2000000000 then
                    number = -2000000000
                    text = "-2000000000"
                end

                node.gui.raw_value = text

                -- Positive values
                if number >= 10^9 then
                    text = string.format("%.1fG", number / 10^9)
                elseif number >= 10^6 then
                    local floating_number = math.floor(number / 10^6)
                    if number >= 10000000 then
                        text = string.format("%.0fM", floating_number)
                    else
                        text = string.format("%.1fM", floating_number)
                    end
                elseif number >= 10^3 then
                    local floating_number = math.floor(number / 10^3)
                    if number >= 10000 then
                        text = string.format("%.0fk", floating_number)
                    else
                        text = string.format("%.1fk", floating_number)
                    end
                -- Negative values
                elseif number <= (-10^9) then
                    text = string.format("-%.1fG", number / (-10^9))
                elseif number <= (-10^6) then
                    local floating_number = math.floor(number / (-10^6))
                    if number <= (-10000000) then
                        text = string.format("-%.0fM", floating_number)
                    else
                        text = string.format("-%.1fM", floating_number)
                    end
                elseif number <= (-10^3) then
                    local floating_number = math.floor(number / (-10^3))
                    if number <= (-10000) then
                        text = string.format("-%.0fk", floating_number)
                    else
                        text = string.format("-%.1fk", floating_number)
                    end
                end

                node.gui.caption = text
                node.gui.number = number

                overlay_gui.destory_top_nodes_and_unselect(event.player_index, entity_id)
                node:on_signal_confirm_change()
            end
        end
    end
end

function overlay_gui.on_constant_text_changed(event)
    local slider = event.element.parent.children[1]
    slider.slider_value = text_to_slider(event.element.text)
end

function overlay_gui.create_signal_fill_gui(player)
    local root = player.gui.screen.add({
        type = "button",
        name = overlay_name,
        direction = "vertical",
        style = constants.style.screen_strech_frame,
    })

    return root
end

function overlay_gui.is_signal_included(signal_type, signal_name, exclude_signals)
    if exclude_signals then
        for _, exclude_signal in pairs(exclude_signals) do
            if exclude_signal.type == signal_type and exclude_signal.name == signal_name then
                return false
            end
        end
    end

    return true
end

function overlay_gui.create_signal_gui(player, node_param, current_signal, exclude_signals)

    global.owner = {unit_number = node_param.entity_id, node_id = node_param.id}
    
    local root = player.gui.screen.add({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_frame,
        name = signal_parent_name,
        caption = {"improved-combinator.signals-title"}
    })

    local tasks_area = root.add({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_inner_frame
    })

    local scroll_pane = tasks_area.add({
        type = "table",
        direction = "horizontal",
        column_count = 6,
        vertical_centering = true,
        style = constants.style.signal_group_frame
    })

    local signals_scroll_pane = tasks_area.add({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.signal_subgroup_scroll_frame,
        vertical_scroll_policy = "always",
        horizontal_scroll_policy = "never"
    })

    -------------------------------------------------------------------------------
    for _, group in pairs(cached_signals.groups) do

        local current_group = false
        local sprite_path = group.sprite
        if not game.is_valid_sprite_path(sprite_path) then
            sprite_path = nil
        end

        local group_button = scroll_pane.add({
            type = "sprite-button",
            name = group_name.."_"..group.name,
            direction = "vertical",
            style = constants.style.signal_group_button_frame,
            group_name = group.name,
            sprite = sprite_path,
            hovered_sprite = sprite_path,
            clicked_sprite = sprite_path,
            tooltip = {"item-group-name."..group.name}
        })

        if not sprite_path then
            local image_label = group_button.add({
                type = "label",
                caption = group.icon,
                style = constants.style.signal_group_label,
                ignored_by_interaction = true
            })
        end

        local signals_table = signals_scroll_pane.add({
            type = "table",
            name = group.name,
            direction = "vertical",
            column_count = 10,
            vertical_centering = true,
            style = constants.style.signal_subgroup_frame
        })

        for _, subgroup in pairs(group.subgroups) do

            local excluded_signals = 0
            for _, signal in pairs(subgroup.signals) do
                if overlay_gui.is_signal_included(subgroup.type, signal.name, exclude_signals) then
                    local button_node = signals_table.add({
                        type = "choose-elem-button",
                        name = signal_name.."_"..signal.name,
                        direction = "vertical",
                        style = constants.style.signal_subgroup_button_frame,
                        elem_type = "signal",
                    })
                    button_node.elem_value = {type = subgroup.type, name = signal.name}
                    button_node.locked = true

                    if current_signal and current_signal.type == subgroup.type and current_signal.name == signal.name then
                        current_group = true
                        button_node.style = constants.style.signal_subgroup_selected_button_frame
                    end
                else
                    excluded_signals = excluded_signals + 1
                end
            end

            local empty_cells = subgroup.empty_cells + excluded_signals
            if empty_cells ~= 10 then
                for i = 1, empty_cells do
                    local empty_node = signals_table.add({
                        type = "empty-widget",
                        direction = "vertical"
                    })
                end
            end
        end

        if current_signal == nil then
            if last_selected_group == nil then
                group_button.enabled = (group.name ~= "logistics") or false
                signals_table.visible = (group.name == "logistics") and true or false
            elseif last_selected_group == group.name then
                group_button.enabled = false
                signals_table.visible = true
             else
                group_button.enabled = true
                signals_table.visible = false
            end
        else
            if current_group then
                group_button.enabled = false
                signals_table.visible = true
            else
                group_button.enabled = true
                signals_table.visible = false
            end
        end
    end
    -------------------------------------------------------------------------------

    -- Calculate the current frame height
    signal_current_signal_height = signal_frame_height +
        (signal_group_height * math.ceil(table_size(scroll_pane.children) / 6))

    return root
end

function overlay_gui.create_constant_gui(player, node_param)
    local root = player.gui.screen.add({
        type = "frame",
        direction = "vertical",
        style = constants.style.signal_constants_frame,
        name = constant_parent_name,
        caption = {"improved-combinator.constant-title"}
    })

    local horizontal_flow = root.add({
        type = "frame",
        direction = "horizontal",
        style = constants.style.signal_constants_inner_frame
    })

    local raw_value = node_param.gui.raw_value or "0"

    local right_button_node = horizontal_flow.add({
        type = "slider",
        direction = "vertical",
        style = "slider",
        name = constant_slider_name,
        value = text_to_slider(raw_value),
        value_step = 1,
        minimum_value = 0,
        maximum_value = 100, -- 2000000000
        discrete_slider = true,
        discrete_values = true
    })

    local right_button_node = horizontal_flow.add({
        type = "textfield",
        direction = "vertical",
        style = constants.style.signal_constants_value_frame,
        name = constant_textfield_name,
        numeric = true,
        allow_decimal = false,
        allow_negative = true,
        lose_focus_on_confirm = true,
        text = raw_value
    })

    local set_button_node = horizontal_flow.add({
        type = "button",
        direction = "vertical",
        style = constants.style.constant_button_frame,
        name = constant_set_name,
        caption = {"improved-combinator.constant-set-button"}
    })    

    return root
end

function overlay_gui.configure_location(main_gui_location)
    global.signal_node.location =
    {
        x = main_gui_location.x + 406,
        y = main_gui_location.y + get_y_offset(global.constant_node)
    }

    if global.constant_node then
        global.constant_node.location =
        {
            x = global.signal_node.location.x,
            y = global.signal_node.location.y + signal_current_signal_height
        }
    end
end

function overlay_gui.on_gui_location_changed(event)
    if event.element.name and event.element.location then
        if event.element.name == signal_parent_name then
            if global.constant_node then
                global.constant_node.location =
                {
                    x = global.signal_node.location.x,
                    y = global.signal_node.location.y + signal_current_signal_height
                }
            end
        elseif event.element.name == constant_parent_name then
            global.signal_node.location =
            {
                x = global.constant_node.location.x,
                y = global.constant_node.location.y - signal_current_signal_height
            }
        end
    end
end

function overlay_gui.on_gui_value_changed(event)
    if event.element.name == constant_slider_name then
        local textfield = event.element.parent.children[2]
        textfield.text = slider_to_text(event.element.slider_value)
    end
end

function overlay_gui.create_gui(player_index, node_param, elem_value, exclude_signals)
    local player = game.players[player_index]

    global.screen_node = overlay_gui.create_signal_fill_gui(player)
    global.signal_node = overlay_gui.create_signal_gui(player, node_param, elem_value, exclude_signals)
    global.signal_node.focus()

    if node_param.events_params.constant_pane then
        global.constant_node = overlay_gui.create_constant_gui(player, node_param)
    end
    
    -- Disable the GUI element without persisting the change
    if node_param.gui_element.type == "button" then
        node_param.gui_element.style = constants.style.dark_button_selected_numbers_frame
    else
        node_param.gui_element.style = constants.style.dark_button_selected_frame
    end
end

return overlay_gui