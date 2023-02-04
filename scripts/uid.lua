local logger = require("scripts.logger")

local uid = {}
uid.chars = {"A", "a", "B", "b", "C", "c", "D", "d", "E", "e", "F", "f", "G", "g", "g", "H", "h", "I", "i", "J", "j", "K", "k", "L", "l", "M", "m", "N", "n", "O", "o", "P", "p", "Q", "q", "R", "r", "S", "s", "T", "t", "U", "u", "V", "v", "W", "w", "X", "x", "Y", "y", "Z", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"  }
uid.max_length = 10

uid.generate = function()
    local new_uid = {}
    for i=1,uid.max_length do
        table.insert(new_uid, uid.chars[math.random(#uid.chars)])
    end
    return table.concat(new_uid)
end

return uid