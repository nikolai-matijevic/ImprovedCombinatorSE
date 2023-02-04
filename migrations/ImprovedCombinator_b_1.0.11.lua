-- Account for the new decider method at index 5
for entity_id, entity in pairs(global.entities) do
    for entity_id, entity in pairs(global.entities) do
        for _, elem in pairs(entity.update_list) do
            if elem and elem.data and elem.data.children then
                for _, child_elem in pairs(elem.data.children) do
                    local update_logic = child_elem.data.update_logic
                    if update_logic.decider_combinator and update_logic.decider_method then
                        if update_logic.decider_method >= 5 then
                            update_logic.decider_method = update_logic.decider_method  + 1
                        end
                    end
                end
            end
        end
    end
end