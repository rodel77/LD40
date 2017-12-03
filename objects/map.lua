Map = {};
MapMT = {__index = Map};

function Map:new()
    local o = {};
    setmetatable(o, MapMT);
    return o;
end

function Map:canMove(grid_x, grid_y)
    return true;
end

return Map;