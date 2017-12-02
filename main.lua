local CScreen = require "cscreen";

function love.load()
    -- Screen setup
    CScreen.init(800, 700, true);
    CScreen.setColor(255, 0, 0);

    love.graphics.setDefaultFilter("nearest", "nearest");
    img = love.graphics.newImage("ld40.png");
end

function love.draw()
    CScreen.apply();
    love.graphics.draw(img, 0, 0);
    CScreen.cease();
end

function love.resize(w, h)
    CScreen.update(w, h)
end