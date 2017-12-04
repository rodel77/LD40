Player = {};

function Player:new()
    local o = Player;
    setmetatable(o, {__index = IRobot});
    return o;
end

function Player:drawMarker(relative_x, relative_y)
    local x = self.grid_x + relative_x;
    local y = self.grid_y + relative_y;
    local cx = (x*100)-50;
    local cy = (y*100)-50;
    local size = 4;

    if x < 1 or y < 1 or x > 6 or y > 6 then
        return;
    end

    local canMove = map:canMove(x, y)

    if check_collision(cx, cy, cx+100, cy+100, mouseX, mouseY) and canMove then
        size = 4 + math.sin(self.rot) * 0.2;

        if love.mouse.isDown(1) then
            self:setPosition(x, y);
            local nearX, nearY, nearDist = self:calculateDistance();
            -- PF by Jumper
            local grid = Grid(map.currentMap);
            local finder = Pathfinder(grid, "JPS", 1);
            finder:setMode("ORTHOGONAL");

            print(inspect(grid))
            local path = finder:getPath(aibot.grid_x, aibot.grid_y, nearX, nearY);
            if path then
                print(('Path found: %.2f'):format(path:getLength()));
                for node,count in path:nodes() do
                    print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()));
                    love.graphics.rectangle("fill", (node:getX()*100)-50, (node:getY()*100)-50, 100, 100);
                end
            end

            local screenShot = love.graphics.newScreenshot();
            screenShot:encode('png', 'test.png');

            -- remainingMoves = remainingMoves - 1;
        end
    end

    if canMove then
        green();
    else
        red();
    end
    
    if os.time()%2 == 0 then
        love.graphics.draw(atlas, grid, x*100, y*100, 0, size, size, 12.5, 12.5);
    else
        love.graphics.draw(atlas, grid, (x*100), y*100, 0, -size, size, 12.5, 12.5);
    end
    
    love.graphics.setColor(255, 255, 255);

end

function Player:calculateDistance()
    local nearX = 0;
    local nearY = 0;
    local nearDist = -1;

    for i=self.grid_y-1,1,-1 do
        local val = map:get(self.grid_x, i);
        if val == 2 then
            break
        end

        local distance = math.dist(aibot.grid_x, aibot.grid_y, self.grid_x, i);
        if nearDist == -1 or distance < nearDist then
            nearX = self.grid_x;
            nearY = i;
            nearDist = distance;
        end

        -- love.graphics.print(distance, self:staticX(), (i*100)-50);
    end

    return nearX, nearY, nearDist;
end

function Player:draw()
    if self.attackTime~=-1 then
        self:showAttack();
    end

    if playerTurn and remainingMoves>0 then
        self:drawMarker(1, 0);
        self:drawMarker(-1, 0);
        self:drawMarker(0, 1);
        self:drawMarker(0, -1);
    end

    love.graphics.draw(atlas, bot, self:screenX(), self:screenY(), math.cos(self.rot)*.010, 4, 4- self.sin * 0.1, 12.5, 4);
    love.graphics.draw(atlas, heli, self:screenX(), self:screenY(), self.rot, 4, 4, 6.5, 6.5);

    black();
    love.graphics.rectangle("fill", self:screenX()-50-3, self:screenY()+80-3, 100+6, 20+6);
    red();
    love.graphics.draw(atlas, heal_bar, self:screenX()-50, self:screenY()+80, 0, 100, 2);
    green();
    love.graphics.draw(atlas, heal_bar, self:screenX()-50, self:screenY()+80, 0, (self.heal/10)*100, 2);
    white();
end

function Player:attack()
    if self:damageAttack()==3 then
        aibot.heal = aibot.heal - 1;
        attackEnd = os.time()+2;
    end
end

function Player:doAttack()
    if self.attackTime == -1 then
        self.attackTime = os.time()+2;
    end
end

return Player;