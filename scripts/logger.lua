
local debugMode = false
logger = {}

function logger.area_to_string(area)
    return string.format("{{%s, %s}, {%s, %s}}", area[1][1], area[2][1], area[1][2], area[2][2])
end

function logger.position_to_string(position)
    return string.format("{%s, %s}", position.x, position.y)
end

function logger.print(message)
    if debugMode then
        local player = game.players[1]
        if (player ~= nil) then
            player.print(message)
        end
    end
end

function logger.file_log(message)
    if debugMode then
        game.write_file("logfile.txt", message.."\n", true)
    end
end

return logger