require "utils";
require "assets/maps";

local CScreen = require "lib/cscreen"; -- GIT: https://github.com/CodeNMore/CScreen
local patchy = require "lib/patchy"; -- GIT: https://github.com/excessive/patchy
inspect = require "lib/inspect"; -- Deep info about lua tables

local firePart = require "particles/fire";

local IRobot = require "objects/robot";
local Player =  require "objects/player";
local AI = require "objects/ai";
local Map = require "objects/map";

-- PathFinding: https://github.com/Yonaba/Jumper (First we meassure the nearest tile to attack player, and then we use jumper to make a path from the bot to that tile!)
-- Cause time reasons, the bot its just offensive, it cannot hide from player, this may take too much time for a ld :/
Grid = require "lib.jumper.grid";
Pathfinder = require "lib.jumper.pathfinder";

cron = require "lib.cron"; -- GIT: https://github.com/kikito/cron.lua

-- State
state = 0; -- 0 Main Menu, 1 Play, 2 Win/Death
playerTurn = true;
remainingMoves = 1;
currentMoves = 1;
mouseX = 0;
mouseY = 0;
shaking = false;

winner = "None";
winTimer = nil;

upress = false;
dpress = false;

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

    love.filesystem.setIdentity('rodel77-LD40');

    love.graphics.setDefaultFilter("nearest", "nearest");
    map = Map:new();

    loadAssets();

    player = Player:new();

    aibot = AI:new();
end

function loadAssets()
    -- Font
    pressStart = love.graphics.newFont("assets/PressStart.ttf", 24);
    love.graphics.setFont(pressStart);

    -- Sound
    snd_death = love.audio.newSource("assets/death.wav" ,"static")
    snd_next = love.audio.newSource("assets/next.wav" ,"static")
    snd_move = love.audio.newSource("assets/move.wav" ,"static")
    snd_charge = love.audio.newSource("assets/charge.wav" ,"static")
    snd_laser = love.audio.newSource("assets/laser.wav" ,"static")
    snd_hit = love.audio.newSource("assets/hit.wav" ,"static")

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

    red_cross = love.graphics.newQuad(0, 75, 25, 25, atlas:getDimensions());
    
    heal_bar = love.graphics.newQuad(36, 38, 1, 10, atlas:getDimensions());
    icon_laser = love.graphics.newQuad(38, 35, 10, 10, atlas:getDimensions());
    icon_ready = love.graphics.newQuad(38, 45, 10, 10, atlas:getDimensions());

    theme = love.audio.newSource("assets/theme.ogg");
    theme:setLooping(true);
    theme:play();

    tilesetBatch = love.graphics.newSpriteBatch(atlas, 6 * 6);
end

function checkDeath()
    if aibot.heal == 0 or player.heal == 0 then
        print("Death");
        playerTurn = false;

        if aibot.heal == 0 then
            winner = "You";
        else
            winner = "Bad Bot"
        end

        snd_death:play();
        winTimer = cron.after(2, function()
            state = 2;
        end);
    end
end

function love.draw()
    CScreen.apply();

    if shaking then
        love.graphics.translate(math.random(-2, 2), math.random(-2, 2));
    end

    if state == 0 then
        love.graphics.setColor(0, 0, 0);
        love.graphics.print("Greedy Robot Fight", (WIDTH/2)-pressStart:getWidth("Greedy Robot Fight")/2, 60+math.sin(DEG), 0, 1, 1);

        love.graphics.print(
[[Created by @therodel77 for LudumDare 40
        
How to Play:
+ Move clicking the green squares
+ Damage in four directions with Laser
+ Each bot turn you have 1 more move
+ But the but also has another move

Created in Love2D]], 10, 400);
        love.graphics.setColor(255, 255, 255);

        -- Play
        if check_collision((WIDTH/2)-100*4/2, (HEIGHT/2)-(25*4), ((WIDTH/2)-100*4/2)+100*4, (HEIGHT/2)-(25*4)+25*4, mouseX, mouseY) then
            if dpress then
                playerTurn = true;
                local mapNum = math.random(#maps);
                map.currentMap = shallowCopy(maps[mapNum]);
                map:update();
                player:setPosition(map.playerX, map.playerY);
                aibot:setPosition(map.botX, map.botY);
                state = 1;
                currentMoves = 1;
                remainingMoves = 1;
                dpress = false;
            end
            love.graphics.setColor(254, 174, 52);
        end
        
        love.graphics.draw(atlas, side_pane, (WIDTH/2)-100*4/2, (HEIGHT/2)-(25*4), 0, 4, 4);
        draw_shadowy_center_text("Play", (WIDTH/2), (HEIGHT/2)-(25*4)/2);
        white();
    elseif state == 1 then
        love.graphics.draw(tilesetBatch, 50, 50, 0, 4, 4);
        local text = "Bot turn";
        if playerTurn then
            text = "Your turn";
            green();
        end
        love.graphics.draw(atlas, side_pane, 650+25, 50, 0, 3, 3);
        draw_shadowy_center_text(text, 650+25+(100*3/2), 50+(25*3/2)); -- Pray for magic numbers
        white();

        -- Laser BTN
        if check_collision(650+25, 150, 650+25+(100*3), 150+(25*3), mouseX, mouseY) then
            love.graphics.setColor(254, 174, 52);
            if dpress and playerTurn and not player.attacking and remainingMoves > 0 then
                player:doAttack();
                remainingMoves = remainingMoves - 1;
            end
        end
        if not playerTurn or remainingMoves < 1 or player.attacking then
            gray();
        end

        love.graphics.draw(atlas, side_pane, 650+25, 150, 0, 3, 3);
        love.graphics.draw(atlas, icon_laser, 650+50+25, 150+(25*3/2), 0, 3, 3, 5, 5);
        draw_shadowy_center_text("Laser", 650+25+(100*3/2), 150+(25*3/2));
        white();

        -- Next BTN
        if check_collision(650+25, 250, 650+25+(100*3), 250+(25*3), mouseX, mouseY) then
            love.graphics.setColor(254, 174, 52);
            if playerTurn and dpress and remainingMoves==0 and not player.attacking then
                switchTurn();
                aibot:computeMovement();
            end
        end
        if not playerTurn or remainingMoves > 0 or player.attacking then
            gray();
        end
        if not playerTurn then
            gray();
        end

        love.graphics.draw(atlas, side_pane, 650+25, 250, 0, 3, 3);
        love.graphics.draw(atlas, icon_ready, 650+50+25, 250+(25*3/2), 0, 3, 3, 5, 5);
        draw_shadowy_center_text("Ready", 650+25+(100*3/2), 250+(25*3/2));
        white();

        -- Remaining Moves
        love.graphics.draw(atlas, side_pane, 650+25, 350, 0, 3, 3);
        draw_shadowy_center_text(remainingMoves.." remaining moves!", 650+25+(100*3/2), 350+(25*3/2), .6);

        if playerTurn then
            player:draw();
            aibot:draw();
        else
            aibot:draw();
            player:draw();
        end
    else
        black();
        --Click on play again to play a random map!
        love.graphics.print(winner.." win! \n\n", (WIDTH/2)-pressStart:getWidth(winner.." win!")/2, 40, 0, 1, 1);
        love.graphics.print("Click on play again to play a random map!", (WIDTH/2)-pressStart:getWidth("Click on play again to play a random map!")/2, 60, 0, 1, 1);
        white();

        if check_collision((WIDTH/2)-100*4/2, (HEIGHT/2)-(25*4), ((WIDTH/2)-100*4/2)+100*4, (HEIGHT/2)-(25*4)+25*4, mouseX, mouseY) then
            if dpress then
                playerTurn = true;
                local mapNum = math.random(#maps);
                map.currentMap = shallowCopy(maps[mapNum]);
                map:update();
                print(mapNum, inspect(map.currentMap));
                aibot.heal = 10;
                aibot.heal_barLerp = 100;
                aibot.attacking = false;
                player.heal = 10;
                player.heal_barLerp = 100;
                player.attacking = false;
                player:setPosition(map.playerX, map.playerY);
                aibot:setPosition(map.botX, map.botY);
                currentMoves = 1;
                remainingMoves = 1;
                dpress = false;
                state = 1;
            end
            love.graphics.setColor(254, 174, 52);
        end
        
        love.graphics.draw(atlas, side_pane, (WIDTH/2)-100*4/2, (HEIGHT/2)-(25*4), 0, 4, 4);
        draw_shadowy_center_text("Play Again", (WIDTH/2), (HEIGHT/2)-(25*4)/2);
        white();
    end
    dpress = false;
    -- CScreen:cease();
end

function switchTurn()
    snd_next:play();
    playerTurn = not playerTurn; -- Switch
    remainingMoves = currentMoves;
end

function doShake()
    shaking = true;
    shakeTimer = cron.after(1.5, function()
        shaking = false;
    end);
end

local numgen = false;

function love.update(dt)
    mouseX, mouseY = CScreen.project(love.mouse.getX(), love.mouse.getY()); -- This project function is a life saver
    
    if shakeTimer then
        if shakeTimer:update(dt) then
            shakeTimer = nil;
        end
    end
    if winTimer then
        winTimer:update(dt);
    end

    if state == 0 then
        DEG = DEG + 0.1;
    elseif state == 1 then
        bot_fire:update(dt);
        aibot:update(dt);
        player:update(dt);
    end
    upress = false;
end

function love.mousepressed(x, y, button)
    upress = true;
    dpress = true;
end

function love.resize(w, h)
    CScreen.update(w, h)
end