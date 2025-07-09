local complex = require "complex"
local FFT = {}

---Converts love.SoundData objects to a 0-indexed lists of complex numbers
---@param soundData love.SoundData
local function tolist(soundData)
    local list = {}
    for i = 0, soundData:getSampleCount() - 1 do
        list[i] = complex.to(soundData:getSample(i))
    end
    return list
end

local function ditfft2(data, N, s)
    N = N or #data + 1
    s = s or 1

    if (N == 1) then
        return { [0] = data[0] }
    end

    local dft_even = ditfft2(data, N / 2, 2 * s)
    local dft_odd = ditfft2(table.move(data, s, #data, 0, {}), N / 2, 2 * s)

    local dft_merged = {}
    for k = 0, (N / 2) - 1 do
        p = dft_even[k]
        q = complex.exp((-2 * math.pi * complex.new(0, 1) * k) / N) * dft_odd[k]

        dft_merged[k] = p + q
        dft_merged[k + (N / 2)] = p - q
    end

    return dft_merged
end

-- wrapper function for love.SoundData
function FFT.ditfft2(soundData)
    local time_start = os.clock()
    return ditfft2(tolist(soundData)), os.clock() - time_start
end

return FFT
