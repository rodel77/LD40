AI = {};

function AI:new()
    local o = AI;
    setmetatable(o, {__index = IRobot}); -- __index
    return o;
end

function AI:draw()
    if self.attackTime~=-1 then
        self:showAttack();
    end
    love.graphics.draw(atlas, bad_bot, self:screenX(), self:screenY(), math.cos(self.rot)*.010, 4, 4- math.sin(self.rot) * 0.1, 12.5, 4);
    love.graphics.draw(atlas, heli, self:screenX(), self:screenY(), self.rot, 4, 4, 6.5, 6.5);
    self:healBar();

    
end

function AI:attack()
    if self:damageAttack()==4 then
        player.heal = player.heal - 1;
        attackEnd = os.time()+2;
    end
end

function AI:computeMovement()
    -- Check if can damage player
    local val =  self:damageAttack();
    if val == 4 then
        if self.attackTime == -1 then
            self.attackTime = os.time()+2;
        end
    end
end

function AI:isAI()
    return true;
end

function AI:getID()
    return 3;
end

return AI;