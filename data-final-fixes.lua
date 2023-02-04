
local function load_sprites(data)
    local sprites = {}

    for _, item in pairs(data) do
        if item.name ~= nil and item.icon ~= nil and item.icon_size ~= nil then
            table.insert(sprites,
                {
                    type = "sprite",
                    name = "improved-combinator-"..item.type.."-"..item.name,
                    filename = item.icon,
                    priority = "extra-high-no-scale",
                    width = item.icon_size,
                    height = item.icon_size,
                    mipmap_count = 1,
                    flags = {"gui-icon"}
                }
            )
        end
    end

    return sprites
end

data:extend(load_sprites(data.raw["item-group"]))