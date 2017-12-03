function extends(baseClass)
    local new = {};
    setmetatable(new, {__index = baseClass});
    return new;
end