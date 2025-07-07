local complex = require "complex"
local FFT = {}

---Computes the naive DFT. Not a fast fourier transform, and not optimised:
---[See top of section](https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm#The_radix-2_DIT_case)
---@param x love.SoundData
---@return table[]
---@return number time Computation time (for benchmarking purposes)
function FFT.naive_dft(x)
    local time_start = os.clock()
    local X = {} -- X[k] Complex frequency spectrum
    local N = x:getSampleCount()

    -- 2pi/N * -i
    local W = complex.new(0, -1) * ((2 * math.pi) / N)

    -- k: frequency index X[k]
    for k = 0, N - 1 do
        local sum = complex.to(0)
        for n = 0, N - 1 do
            sum = sum + (x:getSample(n) * complex.exp(W * k * n))
        end

        X[k] = sum
    end

    return X, os.clock() - time_start
end

return FFT