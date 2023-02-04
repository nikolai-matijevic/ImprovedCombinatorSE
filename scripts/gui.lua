local constants = require("constants")
local game_node = require("game_node")
local logger = require("logger")
local overlay_gui = require("overlay_gui")

local opened_signal_frame = nil

local function on_gui_opened(event)
    if not event.entity then
        return
    end

    local player = game.players[event.player_index]
    if player.selected then        
        if player.selected.name == constants.entity.name then
            global.opened_entity[event.player_index] = event.entity.unit_number
            if global.entities[event.entity.unit_number] then
                player.opened = game_node:build_gui_nodes(player.gui.screen, global.entities[event.entity.unit_number].node)
                player.opened.force_auto_center()
            end

        elseif player.selected.name == constants.entity.input.name or player.selected.name == constants.entity.output.name then
            player.opened = nil
        end
    end
end

local function on_gui_closed(event)
    if event.element and global.opened_entity then
        local unit_number = global.opened_entity[event.player_index]

        -- Check if the entity is owned by this mod
        if global.entities[unit_number] then
            if overlay_gui.has_opened_signals_node() and global.opened_entity[event.player_index] then
                overlay_gui.destory_top_nodes_and_unselect(event.player_index, unit_number)
            else
                event.element.destroy()
                event.element = nil
                game.players[event.player_index].opened = nil
                global.opened_entity[event.player_index] = nil
            end
        end
    end
end

local function on_gui_click(event)
    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    -- Process overlay on-click events
    overlay_gui.on_click(event, unit_number)

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_click then
            node.events.on_click(event, node)
        end
    end
end

local function on_gui_elem_changed(event)
    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_elem_changed then
            node.events.on_gui_elem_changed(event, node)
        end
    end
end

local function on_gui_text_changed(event)
    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]

    -- Process overlay on-text-changed events
    overlay_gui.on_gui_text_changed(event, unit_number)

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_text_changed then
            node.events.on_gui_text_changed(event, node)
        end
    end
end

local function on_gui_selection_state_changed(event)
    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_selection_state_changed then
            node.events.on_selection_state_changed(event, node, selected_index)
        end
    end
end

local function on_gui_location_changed(event)
    if event.element.location then
        overlay_gui.on_gui_location_changed(event)
    end
end

local function on_gui_value_changed(event)
    overlay_gui.on_gui_value_changed(event)
end


local function on_gui_selected_tab_changed(event)
    local name = event.element.name
    local unit_number = global.opened_entity[event.player_index]
    local selected_index = event.element.selected_index

    if global.entities[unit_number] then
        local node = global.entities[unit_number].node:recursive_find(name)
        if node and node.events.on_gui_selected_tab_changed then
            node.events.on_gui_selected_tab_changed(event, node)
        end
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_gui_text_changed, on_gui_text_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
script.on_event(defines.events.on_gui_location_changed, on_gui_location_changed)
script.on_event(defines.events.on_gui_value_changed, on_gui_value_changed)
