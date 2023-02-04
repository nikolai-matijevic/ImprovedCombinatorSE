local array = require("array")
local update_array = {}

function update_array.add(node)
    array.add(global.entities[node.entity_id].update_list, node.id, {node = node, children = {}})
end

function update_array.remove(node)
    array.remove(global.entities[node.entity_id].update_list, node.id)
end

function update_array.add_child(parent_node, child_node)
    local list_element = array.find(global.entities[parent_node.entity_id].update_list, parent_node.id)
    array.add(list_element.children, child_node.id, child_node)
end

function update_array.remove_child(parent_node, child_node)
    local list_element = array.find(global.entities[parent_node.entity_id].update_list, parent_node.id)
    array.remove(list_element.children, child_node.id)
end

function update_array.deep_copy(original_list, new_root_node)
    local update_list = {}
    for _, update_element in pairs(original_list) do
        local update_node = new_root_node:recursive_find(update_element.id)
        if update_node then
            local children = {}
            for _, child_element in pairs(update_element.data.children) do
                local child_node = new_root_node:recursive_find(child_element.id)
                if child_node then
                    array.add(children, child_element.id, child_node)
                end
            end
            array.add(update_list, update_element.id, {node = update_node, children = children})
        end
    end

    return update_list
end

function update_array.table_to_json(update_list)
    local json_list = {}

    for _, update_element in pairs(update_list) do
        local children = {}
        for _, child_element in pairs(update_element.data.children) do
            table.insert(children, child_element.id)
        end
        table.insert(json_list, {id = update_element.id, children = children})
    end

    return game.table_to_json(json_list)
end

function update_array.json_to_table(root_node, json)
    local json_list = game.json_to_table(json)
    local update_list = {}

    for _, update_element in pairs(json_list) do
        local update_node = root_node:recursive_find(update_element.id)
        if update_node then
            local children = {}
            for _, child_element in pairs(update_element.children) do
                local child_node = root_node:recursive_find(child_element)
                if child_node then
                    array.add(children, child_node.id, child_node)
                end
            end
            array.add(update_list, update_node.id, {node = update_node, children = children})
        end
    end

    return update_list
end

return update_array