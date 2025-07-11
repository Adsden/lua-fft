local renderer = {}

---@param soundData love.SoundData
function renderer.plot_sounddata(soundData, amp)
    local points = {}
    local centre_y = love.graphics.getHeight() / 2
    local dx = love.graphics.getWidth() / soundData:getSampleCount()

    for i = 0, soundData:getSampleCount() - 1 do
        table.insert(points, i * dx)
        table.insert(points, centre_y - soundData:getSample(i) * (amp or 100))
    end
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.line(points)
end

return renderer
