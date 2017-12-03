require "utils.lua";

local CScreen = require "lib/cscreen";
local inspect = require "lib/inspect"; -- Deep info about lua tables

local firePart = require "particles/fire";

local IRobot = require "objects/robot";
local Player = require "objects/player";


-- Dungeon Crawler Turn Based vs AI, turns increment to player and AI each turn
-- And where is the theme?: The more turns you have, the more damage AI can make you

function love.load()
    -- Screen setup
    -- The extra 200 pixels are for GUI & stuff
    CScreen.init(900, 700, true);
    CScreen.setColor(255, 0, 0);

    love.graphics.setDefaultFilter("nearest", "nearest");
    loadAssets();

    local player = Player:new();
    print(inspect(player))
end

function loadAssets()
    -- IMGs
    atlas = love.graphics.newImage("assets/atlas.png");
    grass_tile = love.graphics.newQuad(0, 0, 25, 25, atlas:getDimensions());
    grid = love.graphics.newQuad(25, 0, 25, 25, atlas:getDimensions());
    bot = love.graphics.newQuad(0, 25, 25, 25, atlas:getDimensions());
    heli = love.graphics.newQuad(25, 25, 13, 13, atlas:getDimensions());
    fire_particle_quad = love.graphics.newQuad(38, 25, 10, 10, atlas:getDimensions());
    bot_fire = createFireParticles(atlas, fire_particle_quad);
end

function love.draw()
    rot = rot + 0.1;
    CScreen.apply();
    for i=0,6*100,100 do
        for j=0,6*100,100 do
            love.graphics.draw(atlas, grass_tile, i, j, 0, 4, 4);
            love.graphics.rectangle("line", i, j, 100, 100)
        end
    end
    if os.time()%2==0 then
        love.graphics.draw(atlas, grid, 0, 0, 0, 4, 4);
    else
        love.graphics.draw(atlas, grid, 100, 0, 0, -4, 4);
    end
    
    love.graphics.draw(bot_fire, 90, 170);
    love.graphics.draw(atlas, bot, 90, 90, 0, 4, 4, 12.5, 4);
    love.graphics.draw(atlas, heli, 90, 90, rot, 4, 4, 6.5, 6.5);
    -- #DryRules...
    CScreen.cease();
end

function dottedLine(x1, y1, x2, y2, size, interval)
    local size = size or 5
    local interval = interval or 2
 
    local dx = (x1-x2)*(x1-x2)
    local dy = (y1-y2)*(y1-y2)
    local length = math.sqrt(dx+dy)
    local t = size/interval
 
    for i = 1, math.floor(length/size) do
        if i % interval == 0 then
            love.graphics.line(x1+t*(i-1)*(x2-x1), y1+t*(i-1)*(y2-y1),
                               x1+t*i*(x2-x1), y1*t*i*(y2-y1))
        end
    end
end

function love.update(dt)
    bot_fire:update(dt);
end

function love.resize(w, h)
    CScreen.update(w, h)
end