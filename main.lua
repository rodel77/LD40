local CScreen = require "cscreen";

-- Dungeon Crawler Turn Based vs AI, turns increment to player and AI each turn
-- And where is the theme?: The more turns you have, the more damage AI can make you

function love.load()
    -- Screen setup
    -- The extra 100 pixels are for GUI & stuff
    CScreen.init(900, 700, true);
    CScreen.setColor(255, 0, 0);

    love.graphics.setDefaultFilter("nearest", "nearest");
    loadAssets();
end

function loadAssets()
    atlas = love.graphics.newImage("assets/atlas.png");
    grass_tile = love.graphics.newQuad(0, 0, 25, 25, atlas:getDimensions());

end

function love.draw()
    CScreen.apply();
    for i=0,6*100,100 do
        for j=0,6*100,100 do
            love.graphics.draw(atlas, grass_tile, i, j, 0, 4, 4);
        end
    end
    -- #DryRules...
    CScreen.cease();
end
function love.update()

end

function love.resize(w, h)
    CScreen.update(w, h)
end