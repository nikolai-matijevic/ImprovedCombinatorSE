local loaded = false
local cache = {
    groups = {},
    functions = {}
}

local function has_visible_items(signals_group)
    for _, signal in pairs(signals_group) do
        if signal.has_flag("hidden") == false then
            return true
        end
    end
    return false
end

local function has_visible_fluids(signals_group)
    for _, signal in pairs(signals_group) do
        if signal.hidden == false then
            return true
        end
    end
    return false
end

local function filtered_signal_prototypes(subgroup_name)
    --- Check if the group contains items --
    local signals_group = game.get_filtered_item_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
    if #signals_group ~= 0 then
        if has_visible_items(signals_group) then
            return "item", signals_group
        else
            signals_group = {}
        end
    end
 
    --- Check if the group contains fluids --
    if #signals_group == 0 then
        signals_group = game.get_filtered_fluid_prototypes({{filter = "subgroup", subgroup = subgroup_name}})
        if #signals_group ~= 0 then
            if has_visible_fluids(signals_group) then
                return "fluid", signals_group
            else
                signals_group = {}
            end
        end
    end

    --- Check if the group contains signals --
    signals_group = {}
    for _, virtual_signal in pairs(game.virtual_signal_prototypes) do
        if virtual_signal.subgroup.name ~= "other" and virtual_signal.subgroup.name == subgroup_name then
            table.insert(signals_group, virtual_signal)
        end
    end

    return "virtual", signals_group
end

function cache.functions.on_game_load()
    if not loaded then
        for _, item_group in pairs(game.item_group_prototypes) do
            local cached_groups = {
                sprite = "improved-combinator-item-group-"..item_group.name,
                icon="[font=large-group-36][img=item-group/"..item_group.name.."][/font]",
                name = item_group.name,
                subgroups = {}
            }

            for _, subgroup in pairs(item_group.subgroups) do
                local type, group_signals = filtered_signal_prototypes(subgroup.name)
                local signals = {}
                local row_items = 0

                for _, signal in pairs(group_signals) do
                    if type == "virtual" or type == "item" and signal.has_flag("hidden") == false or type == "fluid" and signal.hidden == false then
                        table.insert(signals, signal)
                        row_items = row_items + 1
                    end
                end

                if table_size(signals) ~= 0  then
                    table.insert(cached_groups.subgroups, {
                        type = type,
                        signals = signals,
                        empty_cells = 10 - (row_items % 10)
                    })
                end
            end

            if table_size(cached_groups.subgroups) ~= 0  then
                table.insert(cache.groups,  cached_groups)
            end
        end
        loaded = true
    end
end

function cache.functions.on_contains_element(elem_value)
    if elem_value.type ~= nil and elem_value.name ~= nil then
        for _, group in pairs(cache.groups) do
            for _, subgroup in pairs(group.subgroups) do
                for _, signal in pairs(subgroup.signals) do
                    if subgroup.type == elem_value.type and signal.name == elem_value.name then
                        return true
                    end
                end
            end
        end
    end
    return false
end

return cache

