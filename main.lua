require "utils";
require "assets/maps";

local CScreen = require "lib/cscreen";
inspect = require "lib/inspect"; -- Deep info about lua tables

local firePart = require "particles/fire";

local IRobot = require "objects/robot";
local Player = require "objects/player";
local Map = require "objects/map";

-- State
playerTurn = true;
mouseX = 0;
mouseY = 0;

-- Dungeon Crawler Turn Based vs AI, turns increment to player and AI each turn
-- And where is the theme?: The more turns you have, the more damage AI can make you

function love.load()
    -- Screen setup
    -- The extra 200 pixels are for GUI & stuff
    CScreen.init(900, 700, true);
    -- CScreen.setColor(192, 203, 220);
    love.graphics.setBackgroundColor(192, 203, 220);

    love.graphics.setDefaultFilter("nearest", "nearest");
    map = Map:new();

    loadAssets();

    player = Player:new();
    player:setPosition(1, 1);
end

function loadAssets()
    -- IMGs
    atlas = love.graphics.newImage("assets/atlas.png");
    tile = {};
    tile[1] = love.graphics.newQuad(0, 0, 25, 25, atlas:getDimensions());
    tile[2] = love.graphics.newQuad(50, 0, 25, 25, atlas:getDimensions());
    grid = love.graphics.newQuad(25, 0, 25, 25, atlas:getDimensions());
    bot = love.graphics.newQuad(0, 25, 25, 25, atlas:getDimensions());
    heli = love.graphics.newQuad(25, 25, 13, 13, atlas:getDimensions());
    fire_particle_quad = love.graphics.newQuad(38, 25, 10, 10, atlas:getDimensions());
    bot_fire = createFireParticles(atlas, fire_particle_quad);

    tilesetBatch = love.graphics.newSpriteBatch(atlas, 6 * 6);

    map:update();
end

function love.draw()
    CScreen.apply();
    for i=0,5*100,100 do
        for j=0,5*100,100 do
            -- love.graphics.draw(atlas, tile0, i + 50, j + 50, 0, 4, 4);
        end
    end

    love.graphics.draw(tilesetBatch, 50, 50, 0, 4, 4);

    player:draw();

    mouseX, mouseY = CScreen.project(love.mouse.getX(), love.mouse.getY()); -- This project function is a life saver

    -- love.graphics.circle("fill", xx, yy, 30);

    -- if os.time()%2==0 then
    --     love.graphics.draw(atlas, grid, 0, 0, 0, 4, 4);
    -- else
    --     love.graphics.draw(atlas, grid, 100, 0, 0, -4, 4);
    -- end
    
    -- love.graphics.draw(bot_fire, 90, 170);
    -- love.graphics.draw(atlas, bot, 90, 90, 0, 4, 4, 12.5, 4);
    -- love.graphics.draw(atlas, heli, 90, 90, rot, 4, 4, 6.5, 6.5);
    -- #DryRules...
    CScreen.cease();
end

function love.update(dt)
    bot_fire:update(dt);
    player:update();
end

function love.resize(w, h)
    CScreen.update(w, h)
end