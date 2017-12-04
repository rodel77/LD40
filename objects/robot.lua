IRobot = {
    grid_x = 0,
    grid_y = 0,
    rot = 0,
    deg = 0,
    heal = 5,
};
IRobotMT = {__index = IRobot};

function IRobot:draw()
end

function IRobot:update()
    self.rot = self.rot + 0.16;
    self.deg = self.deg + 1;
    if self.deg >= 360 then
        self.deg = 0;
    end
end

function IRobot:screenX()
    return (self.grid_x*100);
end

function IRobot:screenY()
    return ((self.grid_y*100)-50)+math.sin(self.rot)*2.5;
end

function IRobot:setPosition(x, y)
    self.grid_x = x;
    self.grid_y = y;
end

function IRobot:isAI()
    return false;
end

return IRobot;