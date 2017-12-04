Map = {
    currentMap = map0,
    playerX = 0,
    playerY = 0,
    botX = 0,
    botY = 0,
};
MapMT = {__index = Map};

function Map:new()
    local o = {};
    setmetatable(o, MapMT);
    return o;
end

function Map:update()
    tilesetBatch:clear();

    local x = 0;
    local y = 0;
    for i=1,#self.currentMap do
        for j=1,#self.currentMap[i] do
            local val = self.currentMap[i][j];
            local t = val;

            if val == 3 then
                self.botX = j;
                self.botY = i;
                t = 1;
            elseif val == 4 then
                self.playerX = j;
                self.playerY = i;
                t = 1;
            end
            tilesetBatch:add(tile[t], x, y);

            x = x + 25;
        end
        y = y + 25;
        x = 0;
    end
    tilesetBatch:flush();
end

function Map:canMove(grid_x, grid_y)
    return self.currentMap[grid_y][grid_x]~=2;
end

return Map;