require "utils";
require "assets/maps";

local CScreen = require "lib/cscreen";
local patchy = require "lib/patchy";
inspect = require "lib/inspect"; -- Deep info about lua tables

local firePart = require "particles/fire";

local IRobot = require "objects/robot";
local Player =  require "objects/player";
local AI = require "objects/ai";
local Map = require "objects/map";

-- State
state = 0; -- 0 Main Menu, 1 Tutorial, 2 Play
tutorialStep = 0;
playerTurn = false;
mouseX = 0;
mouseY = 0;

-- Menu
DEG = 0;

WIDTH = 1000;
HEIGHT = 700;

-- Dungeon Crawler Turn Based vs AI, turns increment to player and AI each turn
-- And where is the theme?: The more turns you have, the more damage AI can make you

function love.load()
    -- Screen setup
    -- The extra 300 pixels are for GUI & stuff
    CScreen.init(WIDTH, HEIGHT, true);
    -- CScreen.setColor(192, 203, 220);
    love.graphics.setBackgroundColor(192, 203, 220);

    love.graphics.setDefaultFilter("nearest", "nearest");
    map = Map:new();

    loadAssets();

    player = Player:new();
    player:setPosition(1, 1);

    aibot = AI:new();
    aibot:setPosition(4, 4);
end

function loadAssets()
    -- Font
    pressStart = love.graphics.newFont("assets/PressStart.ttf", 24);
    love.graphics.setFont(pressStart);

    -- IMGs
    atlas = love.graphics.newImage("assets/atlas.png");
    tile = {};
    tile[1] = love.graphics.newQuad(0, 0, 25, 25, atlas:getDimensions());
    tile[2] = love.graphics.newQuad(50, 0, 25, 25, atlas:getDimensions());
    grid = love.graphics.newQuad(25, 0, 25, 25, atlas:getDimensions());
    bot = love.graphics.newQuad(0, 25, 25, 25, atlas:getDimensions());
    bad_bot = love.graphics.newQuad(0, 52, 25, 25, atlas:getDimensions()); -- Bad Bot Bad Bot, what you going to doooOooO!
    heli = love.graphics.newQuad(25, 25, 13, 13, atlas:getDimensions());
    button = love.graphics.newQuad(48, 25, 52, 25, atlas:getDimensions());
    fire_particle_quad = love.graphics.newQuad(38, 25, 10, 10, atlas:getDimensions());
    bot_fire = createFireParticles(atlas, fire_particle_quad);
    side_pane = love.graphics.newQuad(75, 0, 300, 25, atlas:getDimensions());

    icon_laser = love.graphics.newQuad(38, 35, 10, 10, atlas:getDimensions());
    icon_ready = love.graphics.newQuad(38, 45, 10, 10, atlas:getDimensions());

    tilesetBatch = love.graphics.newSpriteBatch(atlas, 6 * 6);
end

function love.draw()
    CScreen.apply();

    if state == 0 then
        love.graphics.setColor(0, 0, 0);
        love.graphics.print("Greedy Robot Fight", (WIDTH/2)-pressStart:getWidth("Greedy Robot Fight")/2, 30+math.sin(DEG), 0, 1, 1);
        love.graphics.setColor(255, 255, 255);

        -- Tutorial
        if check_collision((WIDTH/2)-100*4/2, 100, ((WIDTH/2)-100*4/2)+100*4, 100+25*4, mouseX, mouseY) then
            if love.mouse.isDown(1) then
                map:update();
                player:setPosition(map.playerX, map.playerY);
                aibot:setPosition(map.botX, map.botY);
                tutorialStep = 0;
                state = 1;
            end
            love.graphics.setColor(254, 174, 52);
        end
        love.graphics.draw(atlas, side_pane, (WIDTH/2)-100*4/2, 100, 0, 4, 4);
        draw_shadowy_center_text("How to play", (WIDTH/2), 100+25*4/2);
        white();

        -- Play
        if check_collision((WIDTH/2)-100*4/2, 250, ((WIDTH/2)-100*4/2)+100*4, 250+25*4, mouseX, mouseY) then
            love.graphics.setColor(254, 174, 52);
        end
        love.graphics.draw(atlas, side_pane, (WIDTH/2)-100*4/2, 250, 0, 4, 4);
        draw_shadowy_center_text("Play", (WIDTH/2), 250+25*4/2);
        white();
        -- love.graphics.draw(atlas, button, (WIDTH/2)-52*6/2, 70, 0, 6, 6);
    elseif state == 1 then
        love.graphics.draw(tilesetBatch, 50, 50, 0, 4, 4);
        green();
        love.graphics.draw(atlas, side_pane, 650+25, 50, 0, 3, 3);
        draw_shadowy_center_text("Your turn", 650+25+(100*3/2), 50+(25*3/2)); -- Pray for magic numbers
        white();

        -- Laser BTN
        if check_collision(650+25, 150, 650+25+(100*3), 150+(25*3), mouseX, mouseY) then
            love.graphics.setColor(254, 174, 52);
        end

        love.graphics.draw(atlas, side_pane, 650+25, 150, 0, 3, 3);
        love.graphics.draw(atlas, icon_laser, 650+50+25, 150+(25*3/2), 0, 3, 3, 5, 5);
        draw_shadowy_center_text("Laser", 650+25+(100*3/2), 150+(25*3/2));
        white();

        -- Next BTN
        if check_collision(650+25, 250, 650+25+(100*3), 250+(25*3), mouseX, mouseY) then
            love.graphics.setColor(254, 174, 52);
        end

        love.graphics.draw(atlas, side_pane, 650+25, 250, 0, 3, 3);
        love.graphics.draw(atlas, icon_ready, 650+50+25, 250+(25*3/2), 0, 3, 3, 5, 5);
        draw_shadowy_center_text("Ready", 650+25+(100*3/2), 250+(25*3/2));
        white();

        -- Remaining Moves
        love.graphics.draw(atlas, side_pane, 650+25, 350, 0, 3, 3);
        draw_shadowy_center_text("1 remaining moves!", 650+25+(100*3/2), 350+(25*3/2), .6);
        love.graphics.setColor(255, 255, 255);


        player:draw();
        aibot:draw();
    end

    CScreen.cease();
end

function love.update(dt)
    mouseX, mouseY = CScreen.project(love.mouse.getX(), love.mouse.getY()); -- This project function is a life saver
    
    if state == 0 then
        DEG = DEG + 0.1;
    elseif state == 1 then
        bot_fire:update(dt);
        aibot:update();
        player:update();
    end
end

function love.resize(w, h)
    CScreen.update(w, h)
end