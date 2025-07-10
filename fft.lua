local complex = require "complex"
local windows = require "windows"
local FFT = {}

---Converts love.SoundData objects to a 0-indexed lists of complex numbers
---@param soundData love.SoundData
local function tolist(soundData, window)
    local list = {}
    local N = soundData:getSampleCount()
    for i = 0, N - 1 do
        list[i] = complex.to(soundData:getSample(i) * window(i, N))
    end
    return list
end

local function ditfft2(data, N, s)
    N = N or #data + 1
    s = s or 1

    -- Trivial size-1 DFT base case
    -- The DFT of a single sample is itself
    if (N == 1) then
        return { [0] = data[0] }
    end

    -- Recursively compute DFTs of even and odd "halves"
    local dft_even = ditfft2(data, N / 2, 2 * s)
    local dft_odd = ditfft2(table.move(data, s, #data, 0, {}), N / 2, 2 * s)

    -- Create cache for twiddle values used in merging the DFTS
    local twiddle_cache = {}
    local function get_twiddle(k)
        if twiddle_cache[k] then return twiddle_cache[k] end
        twiddle_cache[k] = complex.exp((-2 * math.pi * complex.new(0, 1) * k) / N)
        return twiddle_cache[k]
    end

    -- Merge even and odd DFTs into one
    local dft_merged = {}
    for k = 0, (N / 2) - 1 do
        local p = dft_even[k]
        -- local q = complex.exp((-2 * math.pi * complex.new(0, 1) * k) / N) * dft_odd[k]
        local q = get_twiddle(k) * dft_odd[k]

        dft_merged[k] = p + q
        dft_merged[k + (N / 2)] = p - q
    end

    return dft_merged
end

---Computes the Cooley-Tukey Radix-2 DIT FFT
---@param soundData love.SoundData
---@param window? windowFunction Window function to be applied. Defaults to a Hann window
---@return table[] fft A zero-indexed array of complex numbers
function FFT.ditfft2(soundData, window)
    window = window or windows.hann
    return ditfft2(tolist(soundData, window))
end

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
