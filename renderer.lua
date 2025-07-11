local complex = require "complex"
local renderer = {}

---@param soundData love.SoundData
function renderer.plot_sounddata(soundData, amp, baseline)
    local baseline = baseline or love.graphics.getHeight() / 2
    local dx = love.graphics.getWidth() / soundData:getSampleCount()

    local points = {}
    for i = 0, soundData:getSampleCount() - 1 do
        table.insert(points, i * dx)
        table.insert(points, baseline - soundData:getSample(i) * (amp or 100))
    end
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.line(points)
end

function renderer.plot_fft(fftData, amp, baseline)
    baseline = baseline or love.graphics.getHeight()
    local N = (#fftData + 1) / 2
    local dx = love.graphics.getWidth() / N

    local points = {}
    for i = 0, N - 1 do
        table.insert(points, i * dx)
        -- calculate magnitude
        local re, im = complex.get(fftData[i])
        local magnitude = math.sqrt(re ^ 2 + im ^ 2) * (amp or 1)
        table.insert(points, baseline - magnitude)
    end

    love.graphics.setColor(0, 1, 0)
    love.graphics.line(points)
end

return renderer
