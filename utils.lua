function extends(class, super)
    print("extends ", inspect(class))
    setmetatable(class, {__index = super});
    return class;
end

function class(base, init)
    local c = {}    -- a new class instance
    if not init and type(base) == 'function' then
       init = base
       base = nil
    elseif type(base) == 'table' then
     -- our new class is a shallow copy of the base class!
       for i,v in pairs(base) do
          c[i] = v
       end
       c._base = base
    end
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c
 
    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    mt.__call = function(class_tbl, ...)
    local obj = {}
    setmetatable(obj,c)
    if init then
       init(obj,...)
    else 
       -- make sure that any stuff from the base class is initialized!
       if base and base.init then
       base.init(obj, ...)
       end
    end
    return obj
    end
    c.init = init
    c.is_a = function(self, klass)
       local m = getmetatable(self)
       while m do 
          if m == klass then return true end
          m = m._base
       end
       return false
    end
    setmetatable(c, mt)
    return c
 end

function check_collision(x1, y1, x2, y2, x, y)
    return x > x1 and y > y1 and x < x2 and y < y2;
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