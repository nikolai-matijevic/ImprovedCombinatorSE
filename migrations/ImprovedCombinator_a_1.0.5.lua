
-- Check if this save has already been migrated
local already_migrated = false
for entity_id, entity in pairs(global.entities) do
    local iter = entity.update_list.front
    if iter == nil then
        already_migrated = true
        break
    end
end

if already_migrated then
    return
end

local old_entity_update_list = {}

-- Make all input and output entities indestructible
for entity_id, entity in pairs(global.entities) do
    if entity.entity_input then
        entity.entity_input.direction = defines.direction.east
        entity.entity_input.destructible = false
        entity.entity_input.operable = false
        entity.entity_input.minable = false
    end
    if entity.entity_output then
        entity.entity_output.direction = defines.direction.east
        entity.entity_output.destructible = false
        entity.entity_output.operable = false
        entity.entity_output.minable = false
    end
end

-- Copy the old update_list data and store it in a table
for entity_id, entity in pairs(global.entities) do
    local update_list = {}
    local iter = entity.update_list.front

    while iter do
        local children = {}
        local child_iter = iter.data.children.front
        while child_iter do
            table.insert(children, {id = child_iter.data.node_element.id, data = child_iter.data.node_element})
            child_iter = child_iter.next
        end
        table.insert(update_list, {id = iter.data.node_element.id, data = {node = iter.data.node_element, children = children}})

        iter = iter.next
    end

    old_entity_update_list[entity_id] = update_list
end

-- Clear the old global update list
for _, entity in pairs(global.entities) do
    local iter = entity.update_list.front
    while iter do
        local child_iter = iter.data.children.front
        while child_iter do
            local next = iter.data.children.next
            child_iter = nil
            child_iter = next
        end
        local next = iter.next
        iter = nil
        iter = next
    end
    entity.update_list = nil
end

-- Copy the new array update list into the global entity data
for entity_id, entity in pairs(global.entities) do
    global.entities[entity_id].update_list = old_entity_update_list[entity_id]
end
