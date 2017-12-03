IRobot = {
    grid_x = 0,
    grid_y = 0,
};
IRobotMT = {__index = IRobot};

function IRobot:new()
    local o = {};
    setmetatable(o, IRobotMT);
    return o;
end

return IRobot;