local windows = require "windows"
local complex = require "complex"

-- Provides methods for interacting with love.SoundData objects
local sdutil = {}

---Converts love.SoundData objects to 0-indexed arrays/lists ready for FFT analysis.
---Each sample is converted to a complex number, and a window function is applied. (Defaults to Hann)
---@param soundData love.SoundData SoundData to convert
---@param channel? number|"mono"|"left"|"right" Audio channel to use. 0 or "mono" to mix stereo to mono. leave nil/default to leave samples interleaved.
---@param window? WindowFunction Window function to apply to data.
---@return table[]
function sdutil.tolist(soundData, channel, window)
    window = window or windows.hann
    if channel == "mono" then channel = 0 end
    if channel == "left" then channel = 1 end
    if channel == "right" then channel = 2 end
    local N = soundData:getSampleCount()

    local list = {}
    if channel == 0 then -- Mix stereo down to mono
        for i = 0, N - 1 do
            local avgSample = (soundData:getSample(i, 1) + soundData:getSample(i, 2)) / 2
            list[i] = complex.to(avgSample * window(i, N))
        end
    else -- Use selected channel (or nil for default behaviour of getSample)
        for i = 0, N - 1 do
            ---@diagnostic disable-next-line: param-type-mismatch
            list[i] = complex.to(soundData:getSample(i, channel) * window(i, N))
        end
    end

    return list
end

return sdutil
