-- Provides various different window functions for computing fourier transforms
local window = {}
local cos = math.cos
local pi = math.pi

---@alias windowFunction fun(n:integer, frameSize:integer):number

---@type windowFunction
function window.rectangular(n, frameSize)
    return 1
end

---@type windowFunction
function window.hann(n, frameSize)
    return 0.5 * (1 - cos((2 * pi * n) / (frameSize - 1)))
end

---@type windowFunction
function window.hamming(n, frameSize)
    return 0.54 - 0.46 * cos((2 * pi * n) / (frameSize - 1));
end

return window
