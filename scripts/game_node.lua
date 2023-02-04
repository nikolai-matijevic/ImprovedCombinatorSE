local node = require("node")
local constants = require("constants")
local logger = require("logger")
local overlay_gui = require("overlay_gui")

function node:setup_combinators_logic()
    self.update_logic =
    {
        combinators = true
    }
end

function node:setup_progressbar_timer(repeatable, active, max_value, every_tick)
    self.update_logic =
    {
        timer = true,
        every_tick = every_tick,
        repeatable = repeatable,
        active = active,
        activation_queued_on = nil,
        value = 0,
        max_value = max_value
    }
end

function node:setup_decider_combinator()
    self.update_logic =
    {
        decider_combinator = true,
        decider_method = 1,
        signal_slot_1 = nil,
        sign_index = 1,
        signal_slot_2 = nil,
        value_slot_2 = nil,
        signal_result = nil,
        output_value = false
    }
end

function node:setup_arithmetic_combinator()
    self.update_logic =
    {
        arithmetic_combinator = true,
        arithmetic_method = 1,
        signal_slot_1 = nil,
        sign_index = 1,
        signal_slot_2 = nil,
        value_slot_2 = nil,
        signal_result = nil
    }
end

function node:setup_callable_timer()
    self.update_logic =
    {
        callable_combinator = true,
        callable_method = 1,
        signal_slot_1 = nil,
        sign_index = 1,
        signal_slot_2 = nil,
        value_slot_2 = nil,
        callable_node_ids = nil
    }
end

function node:safely_add_gui_child(parent, style)
    for _, child in pairs(parent.children) do
        if child == name then
            return child
        end
    end
    return parent.add(style)
end

function node:build_gui_nodes(parent, node_param)
    local new_gui = node:safely_add_gui_child(parent, node_param.gui)
    node_param.gui_element = new_gui

    if node_param.gui.elem_value then
        new_gui.elem_value = node_param.gui.elem_value
    end
    if node_param.gui.locked then
        new_gui.locked = true
    end

    for _, child in pairs(node_param.children) do
        node:build_gui_nodes(new_gui, child)
    end

    if node_param.gui.type == "tabbed-pane" then
        local tab = nil
        for _, child in pairs(node_param.children) do
            if not tab then
                tab = child
            else
                node_param.gui_element.add_tab(tab.gui_element, child.gui_element)
                tab = nil
            end
        end

        node_param.gui_element.selected_tab_index = node_param.events_params.selected_tab_index
    end

    return new_gui
end

function node:create_main_gui(unit_number)
    local root = node:new(unit_number, {
        type = "frame",
        direction = "vertical",
        style = constants.style.main_frame,
        caption =  {"improved-combinator.main-frame-title"}
    })

    local inner_mane_frame = root:add_child({
        type = "frame",
        style = "inside_deep_frame"
    })

    local tabbed_pane = inner_mane_frame:add_child({
        type = "tabbed-pane",
        direction = "horizontal",
        style = constants.style.main_tabbed_pane
    })
    tabbed_pane.events_params.selected_tab_index = 1

    local combinators_tab = tabbed_pane:add_child({
        type = "tab",
        direction = "vertical",
        caption = {"improved-combinator.combinators-tab"}
    })

    local combinators_tasks_area = tabbed_pane:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.tasks_frame
    })

    local combinators_scroll_pane = combinators_tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.scroll_pane
    })
    combinators_scroll_pane:setup_combinators_logic()
    combinators_scroll_pane:update_list_push()

    local combinators_dropdown_node = combinators_scroll_pane:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.task_dropdown_frame,
        items =
        {
            {"improved-combinator.decider-combinator"},
            {"improved-combinator.arithmetic-combinator"},
            {"improved-combinator.conditional-timer-combinator"}
        },
    })
    combinators_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_combinators_dropdown"

    local overlay_node = combinators_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = {"improved-combinator.add-combinator-button"}
    })

    local timer_tab = tabbed_pane:add_child({
        type = "tab",
        direction = "vertical",
        caption = {"improved-combinator.timers-tab"}
    })

    local timers_tasks_area = tabbed_pane:add_child({
        type = "frame",
        direction = "vertical",
        style = constants.style.tasks_frame
    })

    local timers_scroll_pane = timers_tasks_area:add_child({
        type = "scroll-pane",
        direction = "vertical",
        style = constants.style.scroll_pane
    })
    timers_scroll_pane.events_params = {callable_timers = {}}
    combinators_scroll_pane.events_params = {timers_scroll_pane_id = timers_scroll_pane.id}

    local new_task_dropdown_node = timers_scroll_pane:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.task_dropdown_frame,
        items =
        {
            {"improved-combinator.repeatable-timer"},
            {"improved-combinator.conditional-tick-timer"},
            {"improved-combinator.conditional-timer"}
        }
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = {"improved-combinator.add-timer-button"}
    })

    root:recursive_setup_events()
    return root
end

function node:setup_events(node_param)
    if not node_param.events_id then
        return
    elseif node_param.events_id.on_click then
        node_param.events.on_click = node.on_click[node_param.events_id.on_click]
    elseif node_param.events_id.on_gui_text_changed then
        node_param.events.on_gui_text_changed = node.on_gui_text_changed[node_param.events_id.on_gui_text_changed]
    elseif node_param.events_id.on_selection_state_changed then
        node_param.events.on_selection_state_changed = node.on_selection_state_changed[node_param.events_id.on_selection_state_changed]
    end
end

--------------------------- ON CLICK EVENTS -------------------------------------
node.on_click = {

    on_click_play_button = function(event, node_param)

        local function set_sprites(element, sprite)
            element.sprite = sprite
            element.hovered_sprite = sprite
            element.clicked_sprite = sprite
        end
    
        local main_vertical_flow = node_param.parent.parent.parent
        local progressbar_node = node_param.parent.parent
        local timebox_node = node_param.parent:recursive_find(node_param.events_params.time_selection_node_id)
    
        local repeatable_sub_tasks_node = main_vertical_flow.parent:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)
        local new_task_dropdown_node = main_vertical_flow.parent:recursive_find(node_param.events_params.new_task_dropdown_node_id)
    
        progressbar_node.update_logic.value = 0
        progressbar_node.gui_element.value = 0
    
        if progressbar_node.update_logic.active then
            progressbar_node.update_logic.active = false
            set_sprites(event.element, "utility/play")
            set_sprites(node_param.gui, "utility/play")
        else
            progressbar_node.update_logic.active = true
            set_sprites(event.element, "utility/stop")
            set_sprites(node_param.gui, "utility/stop")
        end    
    end,

    on_click_close_button = function(event, node_param)

        if node_param.parent.parent.events_params.timer_name and node_param.events_params.scroll_pane_node_id then
            local unit_number = global.opened_entity[event.player_index]
            local scroll_pane_node = global.entities[unit_number].node:recursive_find(node_param.events_params.scroll_pane_node_id)
            if scroll_pane_node then
                scroll_pane_node:remove_dropdown_item(
                    global.entities[scroll_pane_node.entity_id].node,
                    node_param.parent.parent.events_params.timer_name)
            end
        end
    
        local entity_id_copy = node_param.entity_id
        node_param.parent.parent.parent:remove()
        event.element.parent.parent.parent.destroy()
    end,

    on_click_close_sub_button = function(event, node_param)
        if table_size(event.element.parent.parent.children) == 1 then
            node_param.parent.parent.gui.visible = false
            event.element.parent.parent.visible = false
        end

        local update_root_node = node_param.parent.parent.parent:recursive_find(node_param.events_params.update_root_node_id)
        node_param.parent:update_list_child_remove(update_root_node)
        node_param.parent:remove()
        event.element.parent.destroy()
    end,

    on_click_radiobutton_decider_combinator_one = function(event, node_param)

        local radio_parent = event.element.parent
        local other_radio_node = node_param.parent:recursive_find(node_param.events_params.other_radio_button)
    
        radio_parent[node_param.events_params.other_radio_button].state = false
        other_radio_node.gui.state = false
        node_param.gui.state = true
    
        node_param.parent.parent.update_logic.output_value = false
    end,
    
    on_click_radiobutton_decider_combinator_all = function(event, node_param)
    
        local radio_parent = event.element.parent
        local other_radio_node = node_param.parent:recursive_find(node_param.events_params.other_radio_button)
    
        radio_parent[node_param.events_params.other_radio_button].state = false
        other_radio_node.gui.state = false
        node_param.gui.state = true
    
        node_param.parent.parent.update_logic.output_value = true
    end,
    
    on_click_open_signal = function(event, node_param)
        if event.button == defines.mouse_button_type.left then
            if not overlay_gui.has_opened_signals_node() then

                overlay_gui.create_gui(
                    event.player_index,
                    node_param,
                    (event.element.type == "choose-elem-button") and event.element.elem_value or nil,
                    node:exclude_signals(node_param)
                )

                local root_node = global.entities[node_param.entity_id].node
                if root_node.gui_element.location then
                    overlay_gui.configure_location(root_node.gui_element.location)
                end
            end
        elseif event.button == defines.mouse_button_type.right then
            node:handle_right_input(event, node_param)
        end
    end,
}

--------------------------- ON TEXT CHANGED EVENTS ------------------------------
node.on_gui_text_changed = {

    on_text_change_time = function(event, node_param)
        local number = tonumber(event.element.text) 

        if not number then
            node_param.gui.text = nil
            node_param.parent.parent.update_logic.max_value = 0
        else
            node_param.gui.text = event.element.text
            node_param.parent.parent.update_logic.max_value = number * 60
        end
    end,

}

--------------------------- ON SELECTION CHANGED EVENTS -------------------------
node.on_selection_state_changed = {

    on_selection_changed_task_dropdown = function(event, node_param, selected_index)
        -- Reset dropdown selection index --
        event.element.selected_index = 0
    
        if selected_index == 1 then
            node.on_selection_repeatable_timer(event, node_param)
        elseif selected_index == 2 then
            node.on_selection_callable_tick_timer(event, node_param)
        elseif selected_index == 3 then
            node.on_selection_callable_timer(event, node_param)
        end
    end,

    on_selection_changed_subtask_dropdown = function(event, node_param, selected_index)
        -- Reset dropdown selection index --
        event.element.selected_index = 0
    
        if selected_index == 1 then
            node.on_selection_decider_combinator_in_timers(event, node_param)
        elseif selected_index == 2 then
            node.on_selection_arithmetic_combinator_in_timers(event, node_param)
        elseif selected_index == 3 then
            node.on_selection_callable_combinator_in_timers(event, node_param)
        end
    end,
    
    on_selection_combinator_changed = function(event, node_param, selected_index)
        node_param.gui.selected_index = selected_index
        node_param.parent.update_logic.sign_index = selected_index
    end,

    on_selection_callable_timer_changed = function(event, node_param, selected_index)
        node_param.gui.selected_index = selected_index
    
        local unit_number = global.opened_entity[event.player_index]
    
        if global.entities[unit_number] then
            local scroll_pane_node = global.entities[unit_number].node:recursive_find(node_param.events_params.timers_scroll_pane_id)
            if scroll_pane_node then
                node_param.parent.update_logic.callable_node_id = scroll_pane_node.events_params.callable_timers[selected_index]
            end
        end
    end,

    on_selection_changed_combinators_dropdown = function(event, node_param, selected_index)
        -- Reset dropdown selection index --
        event.element.selected_index = 0
    
        if selected_index == 1 then
            node.on_selection_decider_combinator(event, node_param)
        elseif selected_index == 2 then
            node.on_selection_arithmetic_combinator(event, node_param)
        elseif selected_index == 3 then
            node.on_selection_callable_combinator(event, node_param)
        end
    end,
}
---------------------------------------------------------------------------------

function node:exclude_signals(node_param)
    local excluded_signals = {}

    if node_param.events_params.callable_timer then
        if node_param.events_params.signal_type == "left_decider_signal" or 
           node_param.events_params.signal_type == "left_decider_constant" then
            table.insert(excluded_signals, {type="virtual", name="signal-each"})
        end
    elseif node_param.events_params.signal_type == "left_arithmetic_signal" or
           node_param.events_params.signal_type == "left_arithmetic_constant" then
        table.insert(excluded_signals, {type="virtual", name="signal-everything"})
        table.insert(excluded_signals, {type="virtual", name="signal-anything"})
    elseif node_param.events_params.signal_type == "result_arithmetic_signal" then
        table.insert(excluded_signals, {type="virtual", name="signal-everything"})
        table.insert(excluded_signals, {type="virtual", name="signal-anything"})
        
        local left_signal_node = node_param.parent:recursive_find(node_param.events_params.signals_node_id)
        if not (left_signal_node and left_signal_node.gui.elem_value and left_signal_node.gui.elem_value.name == "signal-each") then
            table.insert(excluded_signals, {type="virtual", name="signal-each"})
        end
    elseif node_param.events_params.signal_type == "left_decider_signal" or
           node_param.events_params.signal_type == "left_decider_constant" then
        excluded_signals = {}
    elseif node_param.events_params.signal_type == "result_decider_signal" then

        local left_signal_node = node_param.parent:recursive_find(node_param.events_params.signals_node_id)
        if left_signal_node and left_signal_node.gui.elem_value and left_signal_node.gui.elem_value.name == "signal-each" then
            table.insert(excluded_signals, {type="virtual", name="signal-everything"})
            table.insert(excluded_signals, {type="virtual", name="signal-anything"})
        else
            table.insert(excluded_signals, {type="virtual", name="signal-anything"})
            table.insert(excluded_signals, {type="virtual", name="signal-each"})
        end
    else
        table.insert(excluded_signals, {type="virtual", name="signal-everything"})
        table.insert(excluded_signals, {type="virtual", name="signal-anything"})
        table.insert(excluded_signals, {type="virtual", name="signal-each"})
    end

    return excluded_signals
end

function node:update_result_signal(special_name)
    if self.gui.elem_value and self.gui.elem_value.name == special_name then
        self.gui.elem_value = nil
        self.gui_element.elem_value = nil
        self:on_signal_confirm_change()
    end
end

function node:handle_right_input(event, node_param)

    local is_choose_elem = node_param.gui.type == "choose-elem-button"

    if node_param.events_params.signal_type == "left_arithmetic_signal" or
       node_param.events_params.signal_type == "left_decider_signal" then
        if is_choose_elem and node_param.gui.elem_value and node_param.gui.elem_value.name == "signal-each" then
            local results_node = node_param.parent.parent:recursive_find(node_param.events_params.results_node_id)
            if results_node then
                results_node:update_result_signal("signal-each")
            end
        end
    end

    if is_choose_elem then     
        node_param.gui.elem_value = nil
        event.element.elem_value = nil
    else
        node_param.gui.caption = ""
        node_param.gui.number = nil
        event.element.caption = ""
    end

    node_param:on_signal_confirm_change()
end

function node:handle_result_special_selection()
    if self.events_params.signal_type == "left_decider_signal" then
        if self.gui.elem_value and self.gui.elem_value.name ~= "signal-each" then
            local results_node = self.parent.parent:recursive_find(self.events_params.results_node_id)
            if results_node then
                results_node:update_result_signal("signal-each")
            end
        elseif self.gui.elem_value and self.gui.elem_value.name == "signal-each" then
            local results_node = self.parent.parent:recursive_find(self.events_params.results_node_id)
            if results_node and results_node.gui.elem_value and results_node.gui.elem_value.name ~= "signal-each" then
                results_node.gui.elem_value = nil
                results_node.gui_element.elem_value = nil
                results_node:on_signal_confirm_change()
            end
        end
    elseif self.events_params.signal_type == "left_arithmetic_signal" then
        if self.gui.elem_value and self.gui.elem_value.name ~= "signal-each" then
            local results_node = self.parent.parent:recursive_find(self.events_params.results_node_id)
            if results_node then
                results_node:update_result_signal("signal-each")
            end
        end
    elseif self.events_params.signal_type == "left_decider_constant" or
           self.events_params.signal_type == "left_arithmetic_constant" then
        local signal_node = self.parent:recursive_find(self.events_params.other_node_id)
        if signal_node.gui.elem_value and signal_node.gui.elem_value.name == "signal-each" then
            signal_node.gui.elem_value = nil
            local results_node = signal_node.parent.parent:recursive_find(signal_node.events_params.results_node_id)
            if results_node then
                results_node:update_result_signal("signal-each")
            end
        end
    end
end

function node:update_arithmetic_logic()
    if self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-each" and
       self.update_logic.signal_result and self.update_logic.signal_result.name == "signal-each" then
        self.update_logic.arithmetic_method = 3
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-each" then
        self.update_logic.arithmetic_method = 2
    else
        self.update_logic.arithmetic_method = 1
    end
end

function node:update_decider_logic()
    if self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-each" and
       self.update_logic.signal_result and self.update_logic.signal_result.name == "signal-each" then
        self.update_logic.decider_method = 8
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-everything" and
           self.update_logic.signal_result and self.update_logic.signal_result.name == "signal-everything" then
        self.update_logic.decider_method = 7
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-anything" and
           self.update_logic.signal_result and self.update_logic.signal_result.name == "signal-everything" then
        self.update_logic.decider_method = 6
    elseif self.update_logic.signal_result and self.update_logic.signal_result.name == "signal-everything" then
        self.update_logic.decider_method = 5
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-everything" then
        self.update_logic.decider_method = 4
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-anything" then
        self.update_logic.decider_method = 3
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-each" then
        self.update_logic.decider_method = 2
    else
        self.update_logic.decider_method = 1
    end
end

function node:update_callable_logic()
    if self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-everything" then
        self.update_logic.callable_method = 3
    elseif self.update_logic.signal_slot_1 and self.update_logic.signal_slot_1.name == "signal-anything" then
        self.update_logic.callable_method = 2
    else
        self.update_logic.callable_method = 1
    end
end

function node:on_text_changed_constant_slot_1()
    self.parent.parent.update_logic.signal_slot_1 = nil
    self.parent.parent.update_logic.value_slot_1 = self.gui.number
    self.gui_element.caption = self.gui.caption
end

function node:on_text_changed_constant_slot_2()
    self.parent.parent.update_logic.signal_slot_2 = nil
    self.parent.parent.update_logic.value_slot_2 = self.gui.number
    self.gui_element.caption = self.gui.caption 
end

function node:on_signal_changed_1()
    self.parent.parent.update_logic.signal_slot_1 = self.gui.elem_value
    self.parent.parent.update_logic.value_slot_1 = nil

    if self.parent.parent.update_logic.arithmetic_combinator then
        self.parent.parent:update_arithmetic_logic()
    elseif self.parent.parent.update_logic.decider_combinator then
        self.parent.parent:update_decider_logic()
    elseif self.parent.parent.update_logic.callable_combinator then
        self.parent.parent:update_callable_logic()
    end
end

function node:on_signal_changed_2()
    self.parent.parent.update_logic.signal_slot_2 = self.gui.elem_value
    self.parent.parent.update_logic.value_slot_2 = nil
end

function node:on_signal_changed_result()
    self.parent.update_logic.signal_result = self.gui.elem_value

    if self.parent.update_logic.arithmetic_combinator then
        self.parent:update_arithmetic_logic()
    elseif self.parent.update_logic.decider_combinator then
        self.parent:update_decider_logic()
    elseif self.parent.update_logic.callable_combinator then
        self.parent:update_callable_logic()
    end
end

function node:on_signal_confirm_change()
    if self.events_params.signal_type == "left_arithmetic_signal" or
       self.events_params.signal_type == "left_decider_signal" then
        self:handle_result_special_selection()
        self:on_signal_changed_1()
    elseif self.events_params.signal_type == "left_arithmetic_constant" or
           self.events_params.signal_type == "left_decider_constant" then
        self:handle_result_special_selection()
        self:on_text_changed_constant_slot_1()
    elseif self.events_params.signal_type == "right_arithmetic_signal" or
           self.events_params.signal_type == "right_decider_signal" then
        self:on_signal_changed_2()
    elseif self.events_params.signal_type == "right_arithmetic_constant" or
           self.events_params.signal_type == "right_decider_constant" then
        self:on_text_changed_constant_slot_2()
    elseif self.events_params.signal_type == "result_arithmetic_signal" or
           self.events_params.signal_type == "result_decider_signal" then 
        self:on_signal_changed_result()
    end
end

function node.on_selection_repeatable_timer(event, node_param)
    event.element.selected_index = 0

    -- Setup Persistent Nodes --
    local scroll_pane_node = node_param.parent
    local scroll_pane_gui = event.element.parent

    local vertical_flow_node = scroll_pane_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.group_vertical_flow_frame,
    })

    ------------------------------ Frame Area 1 ---------------------------------
    local repeatable_time_node = vertical_flow_node:add_child({
        type = "progressbar",
        direction = "vertical",
        style = constants.style.conditional_progress_frame,
        value = 0
    })
    repeatable_time_node:setup_progressbar_timer(true, false, 600, false)
    repeatable_time_node:update_list_push()

    local repeatable_time_flow_node = repeatable_time_node:add_child({
        type = "flow",
        direction = "horizontal",
        style = constants.style.conditional_flow_frame,
    })

    local play_button_node = repeatable_time_flow_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.play_button_frame,
        sprite = "utility/play",
        hovered_sprite = "utility/play",
        clicked_sprite = "utility/stop"
    })

    local label_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.repeatable_begining_label_frame,
        caption = {"improved-combinator.combinator-repeat-timer-prefix"}
    })

    local time_selection_node = repeatable_time_flow_node:add_child({
        type = "textfield",
        direction = "vertical",
        style = constants.style.time_selection_frame,
        numeric = true,
        allow_decimal = true,
        allow_negative = false,
        lose_focus_on_confirm = true,
        text = "10"
    })
    time_selection_node.events_id.on_gui_text_changed = "on_text_change_time"
    play_button_node.events_id.on_click = "on_click_play_button"

    local padding_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.repeatable_end_label_frame,
        caption = {"improved-combinator.combinator-timer-suffix"}
    })

    local close_button_node = repeatable_time_flow_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black"
    })
    close_button_node.events_id.on_click = "on_click_close_button"
    ------------------------------ Frame Area 2 ---------------------------------
    local repeatable_sub_tasks_flow = vertical_flow_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.sub_group_vertical_flow_frame,
        visible = false
    })
    ------------------------------ Frame Area 3 ---------------------------------
    local new_task_dropdown_node = vertical_flow_node:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.subtask_dropdown_frame,
        items =
        {
            {"improved-combinator.decider-combinator"},
            {"improved-combinator.arithmetic-combinator"},
            {"improved-combinator.conditional-timer-combinator"}
        }
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_subtask_dropdown"
    new_task_dropdown_node.events_params =
    {
        repeatable_time_node_id = repeatable_time_node.id,
        repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id
    }

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = {"improved-combinator.add-combinator-button"}
    })
    play_button_node.events_params =
    {
        time_selection_node_id = time_selection_node.id,
        repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id,
        new_task_dropdown_node_id = new_task_dropdown_node.id
    }
    ------------------------------------------------------------------------------

    -- Setup Node Events --
    scroll_pane_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(scroll_pane_gui, vertical_flow_node)
end

function node.on_selection_callable_tick_timer(event, node_param)
    node.callable_timer(
        event,
        node_param,
        "improved-combinator.tick-timer",
        "tick timer",
        true
    )
end

function node.on_selection_callable_timer(event, node_param)
    node.callable_timer(
        event,
        node_param,
        "improved-combinator.timer",
        "timer",
        false
    )
end

function node.callable_timer(event, node_param, timer_caption, timer_type, every_tick)

    -- Setup Persistent Nodes --
    local scroll_pane_node = node_param.parent
    local scroll_pane_gui = event.element.parent

    local vertical_flow_node = scroll_pane_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.group_vertical_flow_frame,
    })

    ------------------------------ Frame Area 1 ---------------------------------
    local callable_time_node = vertical_flow_node:add_child({
        type = "progressbar",
        direction = "vertical",
        style = constants.style.conditional_progress_frame,
        value = 0
    })
    callable_time_node:setup_progressbar_timer(false, false, 600, every_tick)
    callable_time_node:update_list_push()

    local repeatable_time_flow_node = callable_time_node:add_child({
        type = "flow",
        direction = "horizontal",
        style = constants.style.conditional_flow_frame,
    })

    local timer_id_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.callable_timer_label,
        caption = scroll_pane_node:find_next_available_name(timer_caption, timer_type)
    })
    callable_time_node.events_params = {timer_name = timer_id_node.gui.caption, timer_type = timer_type}

    local label_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.callable_begining_label_frame,
        caption = {"improved-combinator.combinator-callable-timer-prefix"}
    })

    local time_selection_node = repeatable_time_flow_node:add_child({
        type = "textfield",
        direction = "vertical",
        style = constants.style.time_selection_frame,
        numeric = true,
        allow_decimal = true,
        allow_negative = false,
        lose_focus_on_confirm = true,
        text = "10"
    })
    time_selection_node.events_id.on_gui_text_changed = "on_text_change_time"

    local padding_node = repeatable_time_flow_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.repeatable_end_label_frame,
        caption = {"improved-combinator.combinator-timer-suffix"}
    })

    local close_button_node = repeatable_time_flow_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black"
    })
    close_button_node.events_id.on_click = "on_click_close_button"
    close_button_node.events_params = {scroll_pane_node_id = scroll_pane_node.id}

    ------------------------------ Frame Area 2 ---------------------------------
    local repeatable_sub_tasks_flow = vertical_flow_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.sub_group_vertical_flow_frame,
        visible = false
    })
    ------------------------------ Frame Area 3 ---------------------------------
    local new_task_dropdown_node = vertical_flow_node:add_child({
        type = "drop-down",
        direction = "horizontal",
        style = constants.style.subtask_dropdown_frame,
        items =
        {
            {"improved-combinator.decider-combinator"},
            {"improved-combinator.arithmetic-combinator"},
            {"improved-combinator.conditional-timer-combinator"}
        }
    })
    new_task_dropdown_node.events_id.on_selection_state_changed = "on_selection_changed_subtask_dropdown"
    new_task_dropdown_node.events_params =
    {
        repeatable_time_node_id = callable_time_node.id,
        repeatable_sub_tasks_flow_id = repeatable_sub_tasks_flow.id
    }

    local overlay_node = new_task_dropdown_node:add_child({
        type = "label",
        direction = "vertical",
        style = constants.style.dropdown_overlay_label_frame,
        ignored_by_interaction = true,
        caption = {"improved-combinator.add-combinator-button"}
    })
    ------------------------------------------------------------------------------

    -- Update all callable dropdown menus --
    scroll_pane_node:add_dropdown_item(
        global.entities[scroll_pane_node.entity_id].node,
        timer_id_node.gui.caption,
        callable_time_node.id
    )

    -- Setup Node Events --
    scroll_pane_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(scroll_pane_gui, vertical_flow_node)
end

function node.on_selection_decider_combinator(event, node_param)
    local vertical_flow_node = node_param.parent
    node.decider_combinator(vertical_flow_node, vertical_flow_node)
end

function node.on_selection_decider_combinator_in_timers(event, node_param)
    local progressbar_node = node_param.parent.children[node_param.events_params.repeatable_time_node_id]
    local vertical_flow_node = node_param.parent

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    node.decider_combinator(sub_tasks_flow, progressbar_node)
end

function node.decider_combinator(root_node, update_node)
    --------------------------------------------------------
    local decider_frame_node = root_node:add_child({
        type = "frame",
        direction = "horizontal",
        style = constants.style.sub_conditional_frame
    })
    decider_frame_node:setup_decider_combinator()
    decider_frame_node:update_list_child_push(update_node)
 
    --------------------------------------------------------
    local left_signal_flow_node, signals_node = node.create_signal_constant(
        decider_frame_node,
        true,
        {
            signal_type = "left_decider_signal",
            constant_type = "left_decider_constant",
        }
    )

    --------------------------------------------------------

    local constant_menu_node = decider_frame_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { ">", "<", "=", "≥", "≤", "≠" }
    })
    constant_menu_node.events_id.on_selection_state_changed = "on_selection_combinator_changed"

    --------------------------------------------------------

    local right_signal_flow_node = node.create_signal_constant(
        decider_frame_node,
        true,
        {
            signal_type = "right_decider_signal",
            constant_type = "right_decider_constant"
        }
    )

    --------------------------------------------------------

    local equals_sprite_node = decider_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        sprite = "improved-combinator-sprites-equals-white",
        hovered_sprite = "improved-combinator-sprites-equals-white",
        clicked_sprite = "improved-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    })


    local result_signal_node = node.create_signal_constant(
        decider_frame_node,
        false,
        {
            signal_type = "result_decider_signal",
        }
    )
    signals_node.events_params.results_node_id = result_signal_node.id
    result_signal_node.events_params.signals_node_id = signals_node.id

    --------------------------------------------------------
    local radio_group_node = decider_frame_node:add_child({
        type = "flow",
        direction = "vertical",
        style = constants.style.radio_vertical_flow_frame
    })

    local radio_button_1 = radio_group_node:add_child({
        type = "radiobutton",
        style = constants.style.radiobutton_frame,
        caption = {"improved-combinator.decider-combinator-output-one"},
        state = true
    })
    radio_button_1.events_id.on_click = "on_click_radiobutton_decider_combinator_one"

    local radio_button_2 = radio_group_node:add_child({
        type = "radiobutton",
        style = constants.style.radiobutton_frame,
        caption = {"improved-combinator.decider-combinator-output-all"},
        state = false
    })
    radio_button_2.events_id.on_click = "on_click_radiobutton_decider_combinator_all"

    radio_button_1.events_params = { other_radio_button = radio_button_2.id }
    radio_button_2.events_params = { other_radio_button = radio_button_1.id }
    --------------------------------------------------------
    local close_button_node = decider_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    })
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    close_button_node.events_params = { update_root_node_id = update_node.id }
    --------------------------------------------------------

    -- Setup Node Events --
    decider_frame_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(root_node.gui_element, decider_frame_node)
end

function node.on_selection_arithmetic_combinator(event, node_param)
    local vertical_flow_node = node_param.parent
    node.arithmetic_combinator(vertical_flow_node, vertical_flow_node)
end

function node.on_selection_arithmetic_combinator_in_timers(event, node_param)

    local progressbar_node = node_param.parent.children[node_param.events_params.repeatable_time_node_id]
    local vertical_flow_node = node_param.parent
    local vertical_flow_gui = event.element.parent

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    node.arithmetic_combinator(sub_tasks_flow, progressbar_node)
end

function node.arithmetic_combinator(root_node, update_node)
    --------------------------------------------------------
    local arithmetic_frame_node = root_node:add_child({
        type = "frame",
        direction = "horizontal",
        style = constants.style.sub_conditional_frame
    })
    arithmetic_frame_node:setup_arithmetic_combinator()
    arithmetic_frame_node:update_list_child_push(update_node)
    --------------------------------------------------------

    local left_signal_flow_node, signals_node = node.create_signal_constant(
        arithmetic_frame_node,
        true,
        {
            signal_type = "left_arithmetic_signal",
            constant_type = "left_arithmetic_constant",
        }
    )

    --------------------------------------------------------

    local arithmetic_menu_node = arithmetic_frame_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { "*", "/", "+", "-", "%", "^", "<<", ">>", "AND", "OR", "XOR" }
    })
    arithmetic_menu_node.events_id.on_selection_state_changed = "on_selection_combinator_changed"

    --------------------------------------------------------

    local right_signal_flow_node = node.create_signal_constant(
        arithmetic_frame_node,
        true,
        {
            signal_type = "right_arithmetic_signal",
            constant_type = "right_arithmetic_constant"
        }
    )

    --------------------------------------------------------

    local equals_sprite_node = arithmetic_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        sprite = "improved-combinator-sprites-equals-white",
        hovered_sprite = "improved-combinator-sprites-equals-white",
        clicked_sprite = "improved-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    })

    local result_signal_node = node.create_signal_constant(
        arithmetic_frame_node,
        false,
        {
            signal_type = "result_arithmetic_signal",
        }
    )
    signals_node.events_params.results_node_id = result_signal_node.id
    result_signal_node.events_params.signals_node_id = signals_node.id

    --------------------------------------------------------
    local close_padding_node = arithmetic_frame_node:add_child({
        type = "empty-widget",
        direction = "vertical",
        style = constants.style.combinator_horizontal_padding_frame
    })

    local close_button_node = arithmetic_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    })
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    close_button_node.events_params = {update_root_node_id = update_node.id}
    --------------------------------------------------------

    -- Setup Node Events --
    arithmetic_frame_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(root_node.gui_element, arithmetic_frame_node)
end

function node.on_selection_callable_combinator(event, node_param)
    local unit_number = global.opened_entity[event.player_index]
    local vertical_flow_node = node_param.parent

    if global.entities[unit_number] then
        local timers_scroll_pane_node =
            global.entities[unit_number].node:recursive_find(vertical_flow_node.events_params.timers_scroll_pane_id)

        node.callable_combinator(vertical_flow_node, vertical_flow_node, timers_scroll_pane_node)
    end
end

function node.on_selection_callable_combinator_in_timers(event, node_param)
    local progressbar_node = node_param.parent.children[node_param.events_params.repeatable_time_node_id]
    local scroll_pane_node = node_param.parent.parent
    local vertical_flow_node = node_param.parent
    local vertical_flow_gui = vertical_flow_node.gui_element

    local sub_tasks_flow = vertical_flow_node:recursive_find(node_param.events_params.repeatable_sub_tasks_flow_id)

    if not sub_tasks_flow.gui_element.visible then
        sub_tasks_flow.gui.visible = true
        sub_tasks_flow.gui_element.visible = true
    end

    node.callable_combinator(sub_tasks_flow, progressbar_node, scroll_pane_node)
end

function node.callable_combinator(root_node, update_node, scroll_pane_node)

    --------------------------------------------------------
    local callable_frame_node = root_node:add_child({
        type = "frame",
        direction = "horizontal",
        style = constants.style.sub_conditional_frame
    })
    callable_frame_node:setup_callable_timer()
    callable_frame_node:update_list_child_push(update_node)
    -------------------------------------------------------- 

    local left_signal_flow_nodem, signal_node, constant_node = node.create_signal_constant(
        callable_frame_node,
        true,
        {
            signal_type = "left_decider_signal",
            constant_type = "left_decider_constant"
        }
    )
    signal_node.events_params.callable_timer = true
    constant_node.events_params.callable_timer = true

    --------------------------------------------------------

    local constant_menu_node = callable_frame_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.condition_comparator_dropdown_frame,
        selected_index = 1,
        items = { ">", "<", "=", "≥", "≤", "≠" }
    })
    constant_menu_node.events_id.on_selection_state_changed = "on_selection_combinator_changed"

    --------------------------------------------------------

    local right_signal_flow_node = node.create_signal_constant(
        callable_frame_node,
        true,
        {
            signal_type = "right_decider_signal",
            constant_type = "right_decider_constant"
        }
    )

    --------------------------------------------------------

    local equals_sprite_node = callable_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        sprite = "improved-combinator-sprites-equals-white",
        hovered_sprite = "improved-combinator-sprites-equals-white",
        clicked_sprite = "improved-combinator-sprites-equals-white",
        style = constants.style.invisible_frame,
        ignored_by_interaction = true
    })

    --------------------------------------------------------

    local callable_timer_node = callable_frame_node:add_child({
        type = "drop-down",
        direction = "vertical",
        style = constants.style.callable_timer_dropdown_frame,
        selected_index = 0,
        items = scroll_pane_node:find_all_timers(),
    })
    if table_size(callable_timer_node.gui.items) == 0 then
        callable_timer_node.gui.enabled = false
    end
    callable_timer_node.events_id.on_selection_state_changed = "on_selection_callable_timer_changed"
    callable_timer_node.events_params = { timers_scroll_pane_id = scroll_pane_node.id , callable_timer_node = true}

    --------------------------------------------------------

    local close_button_node = callable_frame_node:add_child({
        type = "sprite-button",
        direction = "vertical",
        style = constants.style.close_button_frame,
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
    })
    close_button_node.events_id.on_click = "on_click_close_sub_button"
    close_button_node.events_params = {update_root_node_id = update_node.id}
    --------------------------------------------------------

    -- Setup Node Events --
    callable_frame_node:recursive_setup_events()

    -- Setup Factorio GUI --
    node:build_gui_nodes(root_node.gui_element, callable_frame_node)
end

function node.create_signal_constant(parent_node, create_constant, types)

    if not create_constant then
        local signal_node = parent_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = constants.style.dark_button_frame,
            elem_type = "signal",
            locked = true,
        })
        signal_node.events_id.on_click = "on_click_open_signal"
        signal_node.events_params =
        {
            constant_pane = false,
            signal_type = types.signal_type
        }

        return signal_node
    else
        local flow_node = parent_node:add_child({
            type = "flow",
            direction = "horizontal",
        })

        local signal_node = flow_node:add_child({
            type = "choose-elem-button",
            direction = "vertical",        
            style = constants.style.dark_button_frame,
            elem_type = "signal",
            locked = true,
        })
        signal_node.events_id.on_click = "on_click_open_signal"

        local constant_node = flow_node:add_child({
            type = "button",
            direction = "vertical",        
            style = constants.style.dark_button_numbers_frame,
            tooltip = {"improved-combinator.constant-signal-tooltip"},
            visible = false
        })
        constant_node.events_id.on_click = "on_click_open_signal"
        constant_node.events_params =
        {
            other_node_id = signal_node.id,
            constant_pane = true,
            signal_type = types.constant_type
        }
        signal_node.events_params =
        {
            other_node_id = constant_node.id,
            constant_pane = true,
            signal_type = types.signal_type
        }
        return flow_node, signal_node, constant_node
    end
end

function node:find_callable_timers(timers)
    if self.gui.type == "progressbar" then
        table.insert(timers, self)
    else
        for _, child in pairs(self.children) do
            child:find_callable_timers(timers)
        end
    end
end

function node:find_next_available_name(timer_caption, timer_type)
    local timers = {}
    self:find_callable_timers(timers)

    local existing_timers = {}
    for _, progressbar in pairs(timers) do
        if progressbar.events_params.timer_name and progressbar.events_params.timer_type == timer_type then
            if progressbar.events_params.timer_name then
                local number = tonumber(progressbar.events_params.timer_name[2])
                table.insert(existing_timers, number) 
            end
        end
    end

    function recursive_find_index(index)
        local match = false
        for k, v in pairs(existing_timers) do
            if index == v then
                match = true
                break
            end
        end

        if match then
            index = index + 1
            return recursive_find_index(index)
        else
            return index
        end
    end

    local index = recursive_find_index(1)
    local timer_name = {timer_caption, tostring(index)}

    return timer_name
end

function node:find_callable_dropdown_nodes(dropdown_nodes)
    if self.events_params.callable_timer_node then
        table.insert(dropdown_nodes, self)
    else
        for _, child in pairs(self.children) do
            child:find_callable_dropdown_nodes(dropdown_nodes)
        end
    end
end

function node:add_dropdown_item(root, item_name, timer_id)
    local dropdown_nodes = {}
    root:find_callable_dropdown_nodes(dropdown_nodes)

    local added_callable_timer = false

    for _, dropdown_node in pairs(dropdown_nodes) do
        if dropdown_node.gui.type == "drop-down" then

            if not dropdown_node.gui.enabled then
                dropdown_node.gui_element.enabled = true
                dropdown_node.gui.enabled = true
            end

            dropdown_node.gui_element.add_item(item_name)
            dropdown_node.gui.items = dropdown_node.gui_element.items

            -- Ensure the timer is added into the shared list only once 
            if not added_callable_timer then
                table.insert(self.events_params.callable_timers, timer_id)
                added_callable_timer = true
            end
        end
    end    
end

function node:remove_dropdown_item(root, item_name)
    local dropdown_nodes = {}
    root:find_callable_dropdown_nodes(dropdown_nodes)

    function compare_localized_strings(left, right)
        return left[1] == right[1] and left[2] == right[2]
    end

    local removed_callable_timer = false

    for _, dropdown_node in pairs(dropdown_nodes) do
        if dropdown_node.gui.type == "drop-down" then
            for index, item in pairs(dropdown_node.gui_element.items) do
                if compare_localized_strings(item, item_name) then
                    dropdown_node.gui_element.remove_item(index)

                    -- Ensure the timer is removed from the shared list only once 
                    if not removed_callable_timer then
                        table.remove(self.events_params.callable_timers, index)
                        removed_callable_timer = true
                    end
                end
            end

            dropdown_node.gui.items = dropdown_node.gui_element.items
            dropdown_node.gui.selected_index = dropdown_node.gui_element.selected_index

            if table_size(dropdown_node.gui.items) == 0 then
                dropdown_node.gui_element.enabled = false
                dropdown_node.gui.enabled = false
            end
        end
    end
end

function node:find_all_timers()
    local callable_timers = {}
    self:find_callable_timers(callable_timers)

    local items = {}
    local array_index = 1

    for _, timer in pairs(callable_timers) do
        if timer.events_params.timer_name then
            items[array_index] = timer.events_params.timer_name
            self.events_params.callable_timers[array_index] = timer.id
            array_index = array_index + 1
        end
    end

    return items
end

return node