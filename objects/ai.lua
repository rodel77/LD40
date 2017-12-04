AI = {
    attackCron = nil
};

function AI:new()
    local o = AI;
    setmetatable(o, {__index = IRobot}); -- __index
    return o;
end

function AI:draw()
    if self.attacking then
        self:showAttack();
    end

    love.graphics.draw(atlas, bad_bot, self:screenX(), self:screenY(), math.cos(self.rot)*.010, 4, 4- math.sin(self.rot) * 0.1, 12.5, 4);
    love.graphics.draw(atlas, heli, self:screenX(), self:screenY(), self.rot, 4, 4, 6.5, 6.5);
    self:healBar();


end

function AI:attack()
    if self:damageAttack()==4 then
        player.heal = player.heal - 1;
        if not checkDeath() then
            doShake();
            
            if remainingMoves <= 0 then
                currentMoves = currentMoves + 1;
                switchTurn();
            else
                self.attacking = false;
                self.attackCron = cron.after(1.5, function()
                    self:computeMovement();
                end);
            end
        end

    end
end

-- This is the bot turn method!
function AI:computeMovement()
    -- First check if the bot can attack the player
    local canAttack = self:tryAttack();

    if not canAttack then
       self:gotoPath();
    end
end

-- Follow PF path
function AI:gotoPath()
    -- Else search where can attack it, it will use path finding to do it
    -- Move one step, and check if can attack, otherwise continue moving
    -- If can attack, check again if can, and spend all the remainig turns...

    -- Calculate PathFinding
    local nearX, nearY, nearDist = player:calculateDistance(); -- Calculate the nearest node "from the player", and then use pathfinding
    local grid = Grid(map.currentMap); -- Use the current map as pf data, 1 is walkable
    local finder = Pathfinder(grid, "JPS", 1);
    finder:setMode("ORTHOGONAL"); -- 4 directions
    
    local nodes = {};
    local path = finder:getPath(aibot.grid_x, aibot.grid_y, nearX, nearY);
    -- if path then (If not path, let love2d throw a error, its impossible not get a path, if you get it its because the map load wrongly..)
        local first = false; -- Skip the first node, because is the same as the bot
        for node,count in path:nodes() do
            if first then
                -- print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()));
                -- love.graphics.rectangle("fill", (node:getX()*100)-50, (node:getY()*100)-50, 100, 100);
                table.insert(nodes, {
                    x = node:getX(),
                    y = node:getY(),
                });
            else
                first = true;
            end
        end
            -- end
    
    self.attackCron = cron.every(1, function()
        if not self:tryAttack() then
            if #nodes==0 or remainingMoves<=0 then
                self.attackCron = nil;
                currentMoves = currentMoves + 1;
                switchTurn();
            else
                snd_move:play();
                local coords = table.remove( nodes, 1 );
                self:setPosition(coords.x, coords.y);
                remainingMoves = remainingMoves - 1;
                self:tryAttack();
            end
        end
    end)
end

-- If can attack do it, else return false
function AI:tryAttack()
    if remainingMoves > 0 then
        local val =  self:damageAttack();
        if val == 4 then -- 4 is player tile
            self.attacking = true;
            snd_charge:rewind();
            snd_charge:play();
            remainingMoves = remainingMoves - 1;
            self.attackCron = cron.after(1.5, function()
                self.attacking = false;
                self:attack();
                snd_laser:play();
            end);
        end
    
        return val == 4;
    end
end

function AI:update(dt)
    self:superUpdate();

    if self.attackCron then
        if self.attackCron:update(dt) then
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