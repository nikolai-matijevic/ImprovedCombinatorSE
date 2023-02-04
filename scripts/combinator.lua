local combinator = { arithmetic = {}, decider = {}}

--- * ---
combinator.arithmetic[1] = function(left_count, right_count)
    return left_count * right_count
end

--- / ---
combinator.arithmetic[2] = function(left_count, right_count)
    local result = left_count / right_count
    if result < 0 then
        result = math.ceil(result)
    else
        result = math.floor(result)
    end
    return result
end

--- + ---
combinator.arithmetic[3] = function(left_count, right_count)
    return left_count + right_count
end

--- - ---
combinator.arithmetic[4] = function(left_count, right_count)        
    return left_count - right_count
end

--- % ---
combinator.arithmetic[5] = function(left_count, right_count)
    return math.fmod(left_count, right_count)
end

--- ^ ---
combinator.arithmetic[6] = function(left_count, right_count)
    local result = left_count ^ right_count
    if result < 0 then
        result = math.ceil(result)
    else
        result = math.floor(result)
    end
    return result
end

--- << ---
combinator.arithmetic[7] = function(left_count, right_count)
    return bit32.lshift(left_count, right_count)
end

--- >> ---
combinator.arithmetic[8] = function(left_count, right_count)
    return bit32.rshift(left_count, right_count)
end

--- AND ---
combinator.arithmetic[9] = function(left_count, right_count)
    return bit32.band(left_count, right_count)
end

--- OR ---
combinator.arithmetic[10] = function(left_count, right_count)
    return bit32.bor(left_count, right_count)
end

--- XOR ---
combinator.arithmetic[11] = function(left_count, right_count)
    return bit32.bxor(left_count, right_count)
end

--- ">" ---
combinator.decider[1] = function(left_count, right_count)
    if left_count > right_count then
        return left_count
    else
        return nil
    end
end

--- "<" ---
combinator.decider[2] = function(left_count, right_count)
    if left_count < right_count then
        return left_count
    else
        return nil
    end
end

--- "=" ---
combinator.decider[3] = function(left_count, right_count)
    if left_count == right_count then
        return left_count
    else
        return nil
    end
end

--- "≥" ---
combinator.decider[4] = function(left_count, right_count)
    if left_count >= right_count then
        return left_count
    else
        return nil
    end
end

--- "≤" ---
combinator.decider[5] = function(left_count, right_count)
    if left_count <= right_count then
        return left_count
    else
        return nil
    end
end

--- "≠" ---
combinator.decider[6] = function(left_count, right_count)
    if left_count ~= right_count then
        return left_count
    else
        return nil
    end
end


return combinator