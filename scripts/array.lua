local util = require("__core__.lualib.util")

array = {}

function array.deep_copy(array_table)
    return util.table.deepcopy(array_table)
end

function array.add(array_table, id, data)
    table.insert(array_table, {id = id, data = data})
end

function array.remove(array_table, id)
    local element_id = nil
    for index, element in pairs(array_table) do
        if element.id == id then
            element_id = index
            break
        end
    end

    if element_id then
        table.remove(array_table, element_id)
    end
end

function array.find(array_table, id)
    for _, element in pairs(array_table) do
        if element.id == id then
            return element.data
        end
    end

    return nil
end

return array