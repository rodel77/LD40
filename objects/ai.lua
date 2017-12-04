AI = {};

function AI:new()
    local o = AI;
    setmetatable(o, {__index = IRobot}); -- __index
    return o;
end

function AI:draw()
    love.graphics.draw(atlas, bad_bot, self:screenX(), self:screenY(), math.cos(self.rot)*.010, 4, 4- math.sin(self.rot) * 0.1, 12.5, 4);
    love.graphics.draw(atlas, heli, self:screenX(), self:screenY(), self.rot, 4, 4, 6.5, 6.5);
    self:healBar();
end

function AI:isAI()
    return true;
end

function AI:getID()
    return 3;
end

return AI;