local window = {}
local cos = math.cos
local pi = math.pi

function window.rectangular(n, frameSize)
    return 1
end

function window.hann(n, frameSize)
    return 0.5 * (1 - cos((2 * pi * n) / (frameSize - 1)))
end

function window.hamming(n, frameSize)
    return 0.54 - 0.46 * cos((2 * pi * n) / (frameSize - 1));
end

return window
