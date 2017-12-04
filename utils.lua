function check_collision(x1, y1, x2, y2, x, y)
    return x > x1 and y > y1 and x < x2 and y < y2;
end

function lerp(a,b,t) return (1-t)*a + t*b end

function black()
    love.graphics.setColor(24, 20, 37); -- Endesga Rules
end

function green()
    love.graphics.setColor(99, 199, 77); -- Endesga Rules
end

function red()
    love.graphics.setColor(248, 59, 68); -- Endesga Rules
end

function white()
    love.graphics.setColor(255, 255, 255);
end

function gray()
    love.graphics.setColor(50, 50, 50);
end

function draw_center_text(text, x, y, scale)
    scale = scale or 1;
    love.graphics.print(text, x-(pressStart:getWidth(text)/2)*scale, y-(pressStart:getHeight()/2)*scale, 0, scale, scale);
end

function draw_shadowy_center_text(text, x, y, scale)
    scale = scale or 1;
    love.graphics.setColor(24, 20, 37);
    draw_center_text(text, x+1, y+1, scale);
    love.graphics.setColor(38, 43, 68);
    draw_center_text(text, x, y, scale);
    love.graphics.setColor(255, 255, 255);
end

function draw_shadowy_text(text, x, y, scale)
    scale = scale or 1;
    love.graphics.setColor(24, 20, 37);
    love.graphics.print(text, x+2, y+2, 0, scale, scale);
    love.graphics.setColor(38, 43, 68);
    love.graphics.print(text, x, y, 0, scale, scale);
    love.graphics.setColor(255, 255, 255);
end