function extends(class, super)
    setmetatable(class, super);
    return class;
end

function check_collision(x1, y1, x2, y2, x, y)
    return x > x1 and y > y1 and x < x2 and y < y2;
end