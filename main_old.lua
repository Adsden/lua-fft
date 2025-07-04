function f(x)
    return math.sin(x)
end

function X(k, N, f)
    local sum = 0
    local e = math.exp(1)

    for n = 0, N - 1 do
        love.graphics.print(math.exp(1), 10, 10)
    end
end

local sx = 3
local sy = 10

function love.load()
    love.keyboard.setKeyRepeat(true)
end

function love.draw()
    local width, cy = love.graphics.getDimensions()
    cy = cy / 2;

    love.graphics.print(string.format("scale x: %d, scale y: %d", sx, sy))

    local prev_y = cy + sy * f(0)
    for x = 1, width do
        local y = cy + sy * f(x / sx)
        love.graphics.line(
            x - 1, prev_y,
            x, y)
        prev_y = y
    end
end

function love.keypressed(key)
    if key == "up" then
        sy = sy + 1
    end
    if key == "down" then
        sy = sy - 1
    end

    if key == "right" then
        sx = sx + 1
    end
    if key == "left" then
        sx = sx - 1
    end
end
