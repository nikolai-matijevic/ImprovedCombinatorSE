local constants = require("constants")
local game_node = require("game_node")
local logger = require("logger")
local combinator = require("combinator")
local cached_signals = require("cached_signals")
local overlay_gui = require("overlay_gui")

local raised_warning = false
local time_since_last_warning = 0
local warning_delay = 60 * 60 -- ticks * seconds
local game_loaded = false
local input_signals = {}
local output_signals = {}

local function read_input_signals()

    local function read_signals(network, signals)
        if network and network.signals then            
            for _, nework_signal in pairs(network.signals) do
                if nework_signal and nework_signal.signal and nework_signal.count then
                    if signals[nework_signal.signal.name] then
                        signals[nework_signal.signal.name].count = signals[nework_signal.signal.name].count + nework_signal.count
                    else
                        signals[nework_signal.signal.name] = { signal = nework_signal.signal, count = nework_signal.count }
                    end
                end
            end
        end
    end

    for entity_id, entity in pairs(global.entities) do
        local input_entity = entity.entity_input
        if input_entity and input_entity.valid then
            input_signals[entity_id] = {}
            local signals = input_signals[entity_id]

            local red_network = input_entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
            local green_network = input_entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)

            read_signals(red_network, signals)
            read_signals(green_network, signals)
        end
    end
end

local function update_timer_and_progress_bar(gui_element, update_logic)
    local timer_finished = false

    if update_logic.activation_queued_on and update_logic.activation_queued_on < game.tick then
        update_logic.activation_queued_on = nil
        update_logic.active = true
    end

    if update_logic and update_logic.active then
        if update_logic.max_value > update_logic.value then
            update_logic.value = update_logic.value + 1
        else
            update_logic.value = 0
            timer_finished = true

            if not update_logic.repeatable then
                update_logic.active = false
            end
        end

        if gui_element and gui_element.valid and update_logic.max_value ~= 0 then
            -- Convert the game ticks to a range of 0..1
            gui_element.value = update_logic.value / update_logic.max_value
        end

        if timer_finished and update_logic.every_tick then
            return false
        elseif update_logic.every_tick then
            return true
        end
    end

    return timer_finished
end

local function is_invalid(update_logic)
    return (update_logic.signal_result == nil and update_logic.callable_node_id == nil) or
    (update_logic.signal_slot_1 == nil and update_logic.value_slot_1 == nil) or
    (update_logic.signal_slot_2 == nil and update_logic.value_slot_2 == nil)
end

local function get_value(input_signal, signal, value)
    local result = 0
    if value then
        result = value
    elseif signal and input_signal[signal.name] then
        result = input_signal[signal.name].count
    end
    return result
end

local function set_output_signal(signal, entity_id, result)
    if output_signals[entity_id] == nil then
        output_signals[entity_id] = {}
    end

    if output_signals[entity_id][signal.name] ~= nil then
        result = output_signals[entity_id][signal.name].count + result
    end

    output_signals[entity_id][signal.name] = {signal = signal, count = result}
end

local function schedule_callable_timer(entity_id, node_id)
    local node = global.entities[entity_id].node:recursive_find(node_id)
    if node and not node.update_logic.active and not node.update_logic.activation_queued_on then
        node.update_logic.activation_queued_on = game.tick
    end
end

local function everything_is_true(input_signal, update_logic, right_count)
    local everything_is_true = false

    for _, signal in pairs(input_signal) do
        local combinator_result = combinator.decider[update_logic.sign_index](signal.count, right_count)
        if combinator_result == nil then
            return false
        else
            everything_is_true = true
        end
    end

    return everything_is_true
end

local function anything_is_true(input_signal, update_logic, right_count)
    for _, signal in pairs(input_signal) do
        local combinator_result = combinator.decider[update_logic.sign_index](signal.count, right_count)
        if combinator_result ~= nil then
            return true
        end
    end

    return false
end

local decider_methods = {}

decider_methods[1] = function(input_signal, entity_id, update_logic, right_count)
    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    local combinator_result = combinator.decider[update_logic.sign_index](left_count, right_count)

    if combinator_result ~= nil then
        if not update_logic.output_value then
            combinator_result =  1
        end
        set_output_signal(update_logic.signal_result, entity_id, combinator_result)
    end
end

decider_methods[2] = function(input_signal, entity_id, update_logic, right_count)
    local combined_result = nil
    for _, signal in pairs(input_signal) do
        local combinator_result = combinator.decider[update_logic.sign_index](signal.count, right_count)

        if combinator_result ~= nil then
            if not update_logic.output_value then
                combinator_result =  1
            end

            if combined_result == nil then
                combined_result = combinator_result
            else
                combined_result = combined_result + combinator_result
            end
        end
    end

    if combined_result ~= nil then
        set_output_signal(update_logic.signal_result, entity_id, combined_result)
    end
end

decider_methods[3] = function(input_signal, entity_id, update_logic, right_count)
    if anything_is_true(input_signal, update_logic, right_count) then

        if not update_logic.output_value then
            set_output_signal(update_logic.signal_result, entity_id, 1)
        else
            local output_signal = input_signal[update_logic.signal_result.name]
            if output_signal then
                if not update_logic.output_value then
                    set_output_signal(output_signal.signal, entity_id, 1)
                else
                    set_output_signal(output_signal.signal, entity_id, output_signal.count)
                end
            end
        end
    end
end

decider_methods[4] = function(input_signal, entity_id, update_logic, right_count)
    if everything_is_true(input_signal, update_logic, right_count) then

        if not update_logic.output_value then
            set_output_signal(update_logic.signal_result, entity_id, 1)
        else
            local output_signal = input_signal[update_logic.signal_result.name]
            if output_signal then
                if not update_logic.output_value then
                    set_output_signal(output_signal.signal, entity_id, 1)
                else
                    set_output_signal(output_signal.signal, entity_id, output_signal.count)
                end
            end
        end

    end
end

decider_methods[5] = function(input_signal, entity_id, update_logic, right_count)
    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    local combinator_result = combinator.decider[update_logic.sign_index](left_count, right_count)

    if combinator_result ~= nil then
        for _, signal in pairs(input_signal) do
            local signal_count = signal.count
            if not update_logic.output_value then
                signal_count =  1
            end
            set_output_signal(signal.signal, entity_id, signal_count) 
        end
    end
end

decider_methods[6] = function(input_signal, entity_id, update_logic, right_count)
    if anything_is_true(input_signal, update_logic, right_count) then
        for _, signal in pairs(input_signal) do
            local combinator_result = signal.count
            if not update_logic.output_value then
                combinator_result =  1
            end
            set_output_signal(signal.signal, entity_id, combinator_result) 
        end
    end
end

decider_methods[7] = function(input_signal, entity_id, update_logic, right_count)
    if everything_is_true(input_signal, update_logic, right_count) then
        for _, signal in pairs(input_signal) do
            local combinator_result = signal.count
            if not update_logic.output_value then
                combinator_result =  1
            end
            set_output_signal(signal.signal, entity_id, combinator_result) 
        end
    end
end

decider_methods[8] = function(input_signal, entity_id, update_logic, right_count)
    for _, signal in pairs(input_signal) do
        local combinator_result = combinator.decider[update_logic.sign_index](signal.count, right_count)

        if combinator_result ~= nil then
            if not update_logic.output_value then
                combinator_result =  1
            end
            set_output_signal(signal.signal, entity_id, combinator_result)
        end
    end
end

local function update_decider_combinator(input_signal, entity_id, update_logic)
    if is_invalid(update_logic) then
        return
    end

    local right_count = get_value(input_signal, update_logic.signal_slot_2, update_logic.value_slot_2)
    decider_methods[update_logic.decider_method or 1](input_signal, entity_id, update_logic, right_count)    
end

local arithmetic_methods = {}

arithmetic_methods[1] = function(input_signal, entity_id, update_logic, right_count)
    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    local arithmetic_result = combinator.arithmetic[update_logic.sign_index](left_count, right_count)

    if arithmetic_result ~= nil then
        set_output_signal(update_logic.signal_result, entity_id, arithmetic_result)
    end
end

arithmetic_methods[2] = function(input_signal, entity_id, update_logic, right_count)
    local combined_result = nil
    for _, signal in pairs(input_signal) do
        local arithmetic_result = combinator.arithmetic[update_logic.sign_index](signal.count, right_count)
        if arithmetic_result ~= nil then
            if combined_result == nil then
                combined_result = arithmetic_result
            else
                combined_result = combined_result + arithmetic_result
            end
        end
    end

    if combined_result ~= nil then
        set_output_signal(update_logic.signal_result, entity_id, combined_result)
    end
end

arithmetic_methods[3] = function(input_signal, entity_id, update_logic, right_count)
    for _, signal in pairs(input_signal) do
        local arithmetic_result = combinator.arithmetic[update_logic.sign_index](signal.count, right_count)
        if arithmetic_result ~= nil then
            set_output_signal(signal.signal, entity_id, arithmetic_result)
        end
    end
end

local function update_arithmetic_combinator(input_signal, entity_id, update_logic)
    if is_invalid(update_logic) then
        return
    end

    local right_count = get_value(input_signal, update_logic.signal_slot_2, update_logic.value_slot_2)
    arithmetic_methods[update_logic.arithmetic_method or 1](input_signal, entity_id, update_logic, right_count)
end

local callable_methods = {}

callable_methods[1] = function(input_signal, entity_id, update_logic, right_count)
    local left_count = get_value(input_signal, update_logic.signal_slot_1, update_logic.value_slot_1)
    return (combinator.decider[update_logic.sign_index](left_count, right_count) ~= nil)
end

callable_methods[2] = function(input_signal, entity_id, update_logic, right_count)
    return anything_is_true(input_signal, update_logic, right_count)
end

callable_methods[3] = function(input_signal, entity_id, update_logic, right_count)
    return everything_is_true(input_signal, update_logic, right_count)
end

local function update_callable_combinator(input_signal, entity_id, update_logic)
    if is_invalid(update_logic) then
        return
    end

    local right_count = get_value(input_signal, update_logic.signal_slot_2, update_logic.value_slot_2)
    local schedule_timer = callable_methods[update_logic.callable_method or 1](input_signal, entity_id, update_logic, right_count)

    if schedule_timer then
        schedule_callable_timer(entity_id, update_logic.callable_node_id)
    end
end

local function process_events()
    for entity_id, entity in pairs(global.entities) do
        local input_signal = input_signals[entity_id]
        if input_signal then
            for _, elem in pairs(entity.update_list) do
                local check_combinators =
                    elem.data.node.update_logic.combinators or 
                    update_timer_and_progress_bar(
                        elem.data.node.gui_element,
                        elem.data.node.update_logic)

                if check_combinators then
                    for _, child_elem in pairs(elem.data.children) do
                        local update_logic = child_elem.data.update_logic

                        if update_logic.decider_combinator then
                            update_decider_combinator(input_signal, entity_id, update_logic)
                        elseif update_logic.arithmetic_combinator then
                            update_arithmetic_combinator(input_signal, entity_id, update_logic)
                        elseif update_logic.callable_combinator then
                            update_callable_combinator(input_signal, entity_id, update_logic)
                        end
                    end
                end
            end
        end
    end
end

local function raise_warning()
    if time_since_last_warning == 0 and not raised_warning then
        raised_warning = true
    end
end

local function print_warning()
    if raised_warning then
        raised_warning = false
        time_since_last_warning = warning_delay
        game.print({"improved-combinator.maximum-output-warning"})
    end

    if time_since_last_warning ~= 0 then
        time_since_last_warning = time_since_last_warning - 1
    end
end

local function write_output_signals()
    for entity_id, entity in pairs(global.entities) do
        local entity_output = entity.entity_output

        if entity_output and entity_output.valid then
            local parameters = {}
            local index = 0
            local signals = output_signals[entity_id]

            if signals then
                for _, signal in pairs(signals) do
                    if signal and signal.signal and signal.count then
                        index = index + 1
                        if index <= 50 then
                            parameters[index] = { index = index, signal = signal.signal, count = math.min(math.floor(signal.count), 2100000000) }
                        else
                            raise_warning()
                        end
                    end
                end
                entity_output.get_control_behavior().parameters = parameters
            else
                entity_output.get_control_behavior().parameters = nil
            end
        end
    end
end

local function validate_sigals()

    local function recursive_signal_search(node)
        if node.gui.type == "choose-elem-button" and node.gui.elem_value then
            if cached_signals.functions.on_contains_element(node.gui.elem_value) == false then
                node.gui.elem_value = nil
            end
        end

        for _, child in pairs(node.children) do
            recursive_signal_search(child)
        end
    end


    for entity_id, entity in pairs(global.entities) do

        recursive_signal_search(entity.node)

        for _, elem in pairs(entity.update_list) do
            for _, child_elem in pairs(elem.data.children) do
                local update_logic = child_elem.data.update_logic

                if update_logic.signal_slot_1 then
                    if cached_signals.functions.on_contains_element(update_logic.signal_slot_1) == false then
                        update_logic.signal_slot_1 = nil
                    end
                end

                if update_logic.signal_slot_2 then
                    if cached_signals.functions.on_contains_element(update_logic.signal_slot_2) == false then
                        update_logic.signal_slot_2 = nil
                    end
                end

                if update_logic.signal_result then
                    if cached_signals.functions.on_contains_element(update_logic.signal_result) == false then
                        update_logic.signal_result = nil
                    end
                end
            end
        end
    end
end

local function on_tick()
    -- Recreate all metatables once after a game is loaded
    if not game_loaded then
        cached_signals.functions.on_game_load()
        game_node.recreate_metatables()
        overlay_gui.on_load()
        validate_sigals()
        game_loaded = true
    end

    input_signals = {}
    output_signals = {}

    read_input_signals()
    process_events()
    write_output_signals()
    print_warning()
end


script.on_event(defines.events.on_tick, on_tick)