Player = extends(IRobot);

function Player:drawMarker(relative_x, relative_y)
    local x = self.grid_x + relative_x;
    local y = self.grid_y + relative_y;
    local cx = (x*100)-50;
    local cy = (y*100)-50;
    local size = 4;

    if check_collision(cx, cy, cx+100, cy+100, mouseX, mouseY) then
        size = 4 + math.sin(self.rot) * 0.2;
    end

    love.graphics.circle("fill", mouseX, mouseY, 30);

    
    if map.canMove(x, y) then
        love.graphics.setColor(99, 199, 77); -- Endesga Rules
    else
        love.graphics.setColor(248, 59, 68);
    end
    
    if os.time()%2 == 0 then
        love.graphics.draw(atlas, grid, x*100, y*100, 0, size, size, 12.5, 12.5);
    else
        love.graphics.draw(atlas, grid, (x*100), y*100, 0, -size, size, 12.5, 12.5);
    end
    
    love.graphics.setColor(255, 255, 255);
end

function Player:draw()
    self:drawMarker(1, 0);
    self:drawMarker(0, 1);

    love.graphics.draw(atlas, bot, self:screenX(), self:screenY(), math.cos(self.rot)*.010, 4, 4, 12.5, 4);
    love.graphics.draw(atlas, heli, self:screenX(), self:screenY(), self.rot, 4, 4, 6.5, 6.5);
end

return Player;