local constants = require("constants")
local uid = require("uid")
local update_array = require("update_array")
local logger = require("logger")

local node = {}
local recreate_metatables = false

function node:new(entity_id, gui)
    new_node = {}
    setmetatable(new_node, self)
    self.__index = self
    new_node.id = uid.generate()
    new_node.entity_id = entity_id
    new_node.parent = nil
    new_node.events_id = {}
    new_node.events_params = {}
    new_node.events = {}
    new_node.gui_element = nil  -- Non-persistent Factorio element
    new_node.children = {}
    new_node.update_logic = nil
    new_node.updatable = false

    if gui then
        new_node.gui = gui
        new_node.gui.name = new_node.id
    else
        new_node.gui = {}
    end

    return new_node
end

function node:create_from_json(id, json_node, entity_id)
    new_node = {}
    setmetatable(new_node, self)
    self.__index = self

    new_node.id = id
    new_node.entity_id = entity_id
    new_node.parent = nil
    new_node.events_id = json_node.events_id
    new_node.events_params = json_node.events_params
    new_node.events = {}
    new_node.gui_element = nil  -- Non-persistent Factorio element
    new_node.children = {}
    new_node.update_logic = json_node.update_logic
    new_node.updatable = json_node.updatable
    new_node.gui = json_node.gui

    return new_node
end

function node.node_to_json(node_param)

    local nodes_list = {}

    local function recursive_add(param)
        nodes_list[param.id] = {
            parent_id = param.parent and param.parent.id or nil,
            events_id = param.events_id,
            events_params = param.events_params,
            update_logic = param.update_logic,
            updatable = param.updatable,
            gui = param.gui
        }

        for _, child in pairs(param.children) do
            recursive_add(child)
        end
    end

    recursive_add(node_param)

    return game.table_to_json(nodes_list)
end

function node.node_from_json(json, entity_id)
    local nodes_list = game.json_to_table(json)

    local new_nodes = {}
    local root_node = nil

    -- Find and create the root node
    for id, json_node in pairs(nodes_list) do
        if not json_node.parent_id then
            root_node = node:create_from_json(id, json_node, entity_id)
            json_node.processed = true
            break
        end
    end

    -- Failed to create the root node
    if not root_node then
        return nil
    end

    local loop_counter = 1
    local processed = 1
    local has_elements = true
    local nodes_count = table_size(nodes_list)

    while has_elements do
        for id, json_node in pairs(nodes_list) do
            if not json_node.processed and json_node.parent_id then
                local parent_node = root_node:recursive_find(json_node.parent_id)

                if parent_node then
                    local new_node = node:create_from_json(id, json_node, entity_id)
                    new_node.parent = parent_node
                    parent_node.children[id] = new_node
                    processed = processed + 1
                    json_node.processed = true
                end
            end
        end

        if processed <= nodes_count then
            has_elements = false
        end

        loop_counter = loop_counter + 1

        if loop_counter >= nodes_count then
            has_elements = false
        end
    end

    root_node:recursive_setup_events()
    return root_node
end


local function simple_deep_copy(object)
    if type(object) ~= 'table' then
        return object
    end
    local result = {}
    for k, v in pairs(object) do
        result[simple_deep_copy(k)] = simple_deep_copy(v)
    end
    return result
end

function node.deep_copy(entity_id, parent_node, other_node)
    local new_node = node:new(entity_id)

    new_node.id = other_node.id
    new_node.parent = parent_node
    new_node.events_id = simple_deep_copy(other_node.events_id)
    new_node.events_params = simple_deep_copy(other_node.events_params)
    new_node.events = simple_deep_copy(other_node.events)
    new_node.gui = simple_deep_copy(other_node.gui)
    new_node.update_logic = simple_deep_copy(other_node.update_logic)
    new_node.updatable = other_node.updatable

    node:setup_events(new_node)

    for _, children in pairs(other_node.children) do
        local new_child = node.deep_copy(entity_id, new_node, children)
        new_node.children[new_child.id] = new_child
    end

    return new_node
end

function node.recreate_metatables()
    if not recreate_metatables then
        for _, entity in pairs(global.entities) do
            if not entity.node.valid then
                node:recursive_create_metatable(entity.node)
            end
        end
        recreate_metatables = true
    end
end

function node:create_metatable(node_param)
    setmetatable(node_param, self)
    self.__index = self
end

function node:recursive_create_metatable(node_param)
    node:create_metatable(node_param)
    node:setup_events(node_param)
    for _, child in pairs(node_param.children) do
        node:recursive_create_metatable(child)
    end
end

function node:recursive_setup_events()
    node:setup_events(self)
    for _, child in pairs(self.children) do
        child:recursive_setup_events()
    end
end

function node:add_child(gui)
    new_node = self:new(self.entity_id)
    new_node.parent = self
    if gui then
        new_node.gui = gui
        new_node.gui.name = new_node.id
    end
    self.children[new_node.id] = new_node
    return new_node
end

function node:remove_child(id)
    if self.children[id] then
        self.children[id]:clear_children()
        self.children[id]:clear()
        self.children[id] = nil
    end
end

function node:remove()
    if self.parent then
        self.parent:remove_child(self.id)
    else
        self:clear_children()
        self:clear()
    end
end

function node:clear_children()
    for _, child in pairs(self.children) do
        child:clear_children()
    end
    self:clear()
end

function node:clear()
    self:update_list_remove()
    self.id = nil
    self.entity_id = nil
    self.parent = nil
    self.events_id = {}
    self.events_params = {}
    self.events = {}
    self.gui = {}
    self.gui_element = nil
    self.children = {}
    self.update_logic = nil
    self.updatable = false
end

function node:find_child(id)
    for _, child in pairs(self.children) do
        if child.id == id then
            return child
        end
    end
    return nil
end

function node:recursive_find(id)
    if self.id == id then
        return self
    else
        for _, child in pairs(self.children) do
            local child_node = child:recursive_find(id)
            if child_node then
                return child_node
            end
        end
    end

    return nil
end

function node:valid()
    return true
end

function node:root_parent()
    if self.parent then
        return self.parent:root_parent()
    else
        return self
    end
end

function node:update_list_push()
    if not self.updatable then
        update_array.add(self)
        self.updatable = true
    end
end

function node:update_list_remove()
    if self.updatable then
        update_array.remove(self)
        self.updatable = false
    end
end

function node:update_list_child_push(parent_node)
    if parent_node.updatable then
        update_array.add_child(parent_node, self)
    end
end

function node:update_list_child_remove(parent_node)
    if parent_node.updatable then
        update_array.remove_child(parent_node, self)
    end
end

function node:debug_print(index)

    local debug_string = ""
    for i=1,index do
        debug_string = debug_string.."   "
    end

    index = index + 1

    for _, chilren in pairs(self.children) do
        chilren:debug_print(index)
    end
end

function node:debug_print_factorio_gui(element, index, max_level)
    local str = ""

    for i=1,index do
        str = str.."    "
    end

    index = index + 1
    if index >= max_level then
        return
    end

    str = str.."name: "..element.name..", type: "..element.type
    if element.type == "label" and element.caption then
        str = str..", caption: "

        for i = 1, #element.caption do
            str = str.." "..element.caption:sub(i,i)
        end
    end
    
    str = str.."\n"

    for _, child in pairs(element.children) do
        str = str..node:debug_print_factorio_gui(child, index, max_level)
    end

    return str
end

return node