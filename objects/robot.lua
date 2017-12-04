IRobot = {
    grid_x = 0,
    grid_y = 0,
    rot = 0,
    deg = math.random(1, 359),
    heal = 10,
    heal_barLerp = 100,
    attacking = false,
    sin = 0,
};
IRobotMT = {__index = IRobot};

function IRobot:draw()
end

function IRobot:update(dt)
    self:superUpdate(dt);
end

function IRobot:superUpdate(dt)
    self.rot = self.rot + 0.16;
    self.deg = self.deg + 1;
    if self.deg >= 360 then
        self.deg = 0;
    end

    self.sin = math.sin(self.rot);
end

function IRobot:screenX()
    return (self.grid_x*100);
end

function IRobot:screenY()
    return ((self.grid_y*100)-50)+self.sin*2.5;
end

function IRobot:staticX()
    return (self.grid_x*100)-50;
end

function IRobot:staticY()
    return (self.grid_y*100)-50;
end

function IRobot:performAttack()

end

function IRobot:healBar()
    self.heal_barLerp = lerp(self.heal_barLerp, (self.heal/10)*100, 0.1);
    black();
    love.graphics.rectangle("fill", self:screenX()-50-3, self:screenY()+80-3, 100+6, 20+6);
    red();
    love.graphics.draw(atlas, heal_bar, self:screenX()-50, self:screenY()+80, 0, 100, 2);
    green();
    love.graphics.draw(atlas, heal_bar, self:screenX()-50, self:screenY()+80, 0, self.heal_barLerp, 2);
    white();
end

function IRobot:showAttack()
    -- UP
    for i=self.grid_y-1,1,-1 do
        local val = map:get(self.grid_x, i);
        if val > 1 then
            self:showCross(self:staticX(), (i*100)-50);
            break
        end
        self:showCross(self:staticX(), (i*100)-50);
    end

    -- LEFT
    for i=self.grid_x-1,1,-1 do
        local val = map:get(i, self.grid_y);
        if val > 1 then
            self:showCross((i*100)-50, self:staticY());
            break
        end
        self:showCross((i*100)-50, self:staticY());
    end

    -- RIGHT
    for i=self.grid_x+1,6 do
        local val = map:get(i, self.grid_y);
        if val > 1 then
            self:showCross((i*100)-50, self:staticY());
            break
        end
        self:showCross((i*100)-50, self:staticY());
    end

    -- DOWN
    for i=self.grid_y+1,6 do
        local val = map:get(self.grid_x, i);
        if val > 1 then
            self:showCross(self:staticX(), (i*100)-50);
            break
        end
        self:showCross(self:staticX(), (i*100)-50);
    end
end

function IRobot:damageAttack()
    --UP
    for i=self.grid_y-1,1,-1 do
        local val = map:get(self.grid_x, i);
        if val == 2 then
            break
        end
        if val > 2 then
            return val;
        end
    end

    -- LEFT
    for i=self.grid_x-1,1,-1 do
        local val = map:get(i, self.grid_y);
        if val == 2 then
            break
        end
        if val > 2 then
            return val;
        end
    end

    -- RIGHT
    for i=self.grid_x+1,6 do
        local val = map:get(i, self.grid_y);
        if val == 2 then
            break
        end
        if val > 2 then
            return val;
        end
    end

    -- DOWN
    for i=self.grid_y+1,6 do
        local val = map:get(self.grid_x, i);
        if val == 2 then
            break
        end
        if val > 2 then
            return val;
        end
    end

    return -1;
end

function IRobot:attack()

end

function IRobot:showCross(x, y)
    love.graphics.draw(atlas, red_cross, x, y, 0,  4, 4);
end

function IRobot:setPosition(x, y)
    if self.grid_x ~= 0 and self.grid_y ~= 0 then
        map:set(self.grid_x, self.grid_y, 1);
    end
    self.grid_x = x;
    self.grid_y = y;
    map:set(x, y, self:getID());
end

function IRobot:getID()
    return 4;
end

function IRobot:isAI()
    return false;
end

return IRobot;