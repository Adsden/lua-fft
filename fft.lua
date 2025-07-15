local complex = require "complex"
local windows = require "windows"
local bitutil = require "bitutil"

---Converts love.SoundData objects to regular 0-indexed arrays/lists.
---Each sample value is converted to a complex number (with to imaginary part),
---and a window function is also applied. (Defaults to a Hann window)
---@param soundData any
---@param window any
---@return table
local function tolist(soundData, window)
    window = window or windows.hann
    local list = {}
    local N = soundData:getSampleCount()
    for i = 0, N - 1 do
        list[i] = complex.to(soundData:getSample(i) * window(i, N))
    end
    return list
end

---Permutes an array using bit-reversal.
---@param array any[] 0-Indexed array
---@return any[] bitrev_array Permuted 0-indexed array
local function bit_reverse_array(array)
    -- Calculate number of bits used in numbers
    local n = math.log(#array + 1, 2)

    local bitrev_array = {}
    for i = 0, #array do -- array is zero-indexed
        bitrev_array[bitutil.brev(i, n)] = array[i]
    end

    return bitrev_array
end

---Computes the Cooley-Tukey Radix-2 DIT fast fourier transform using an
---iterative, non-recursive implementation based on bit-reversal permutation.
---[See More](https://en.m.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm#Data_reordering,_bit_reversal,_and_in-place_algorithms)
---@param data table[] 0-Indexed array of complex numbers representing samples (Time domain)
---@return table[] 0-Indexed array of complex numbers representing FFT result. (Frequency domain)
local function iterfft(data)
    local n = #data + 1
    local A = bit_reverse_array(data)

    for s = 1, math.log(n, 2) do
        local m = 2 ^ s
        local wm = complex.exp((-2 * math.pi * complex.new(0, 1)) / m)
        for k = 0, n - 1, m do
            local w = 1
            for j = 0, (m / 2) - 1 do
                local t = w * A[k + j + (m / 2)]
                local u = A[k + j]
                A[k + j] = u + t
                A[k + j + (m / 2)] = u - t
                w = w * wm
            end
        end
    end

    return A
end

---Computes the Cooley-Tukey Radix-2 DIT fast fourier transform using a recursive implementation.
---[See More](https://en.m.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm#Pseudocode)
---@param data table[] 0-Indexed array of 2^k complex numbers representing samples (Time domain)
---@param N? integer Only used for recursion - should not be set manually! Sample count, must be a power of 2.
---@param s? integer Only used for recursion - should not be set manually! Input stride.
---@return table[] 0-Indexed array of complex numbers representing FFT result. (Frequency domain)
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

---Computes the naive DFT. Not a fast fourier transform, and not optimised.
---[See More](https://en.wikipedia.org/wiki/Discrete_Fourier_transform)
---@param data table[] 0-Indexed array of complex numbers representing samples (Time domain)
---@return table[] 0-Indexed array of complex numbers representing FFT result. (Frequency domain)
local function naive_dft(data)
    local X = {} -- X[k] Complex frequency spectrum
    local N = #data + 1

    -- 2pi/N * -i
    local W = complex.new(0, 1) * ((2 * math.pi) / N)

    -- k: frequency index X[k]
    for k = 0, N - 1 do
        local sum = complex.to(0)
        for n = 0, N - 1 do
            sum = sum + (data[n] * complex.exp(W * k * n))
        end

        X[k] = sum
    end

    return X
end

local FFT = {}

---Computes the Cooley-Tukey Radix-2 DIT fast fourier transform using an
---iterative, non-recursive implementation based on bit-reversal permutation.
---@param soundData love.SoundData Sound data. Must contain a power-of-2 amount of samples.
---@param window? WindowFunction Window function to apply to data. Defaults to a Hann window.
---@return table[] 0-Indexed array of complex numbers representing FFT result.
function FFT.iterfft(soundData, window)
    return iterfft(tolist(soundData, window))
end

---Computes the Cooley-Tukey Radix-2 DIT fast fourier transform using a recursive implementation
---@param soundData love.SoundData Sound data. Must contain a power-of-2 amount of samples.
---@param window? WindowFunction Window function to apply to data. Defaults to a Hann window.
---@return table[] 0-Indexed array of complex numbers representing FFT result.
function FFT.ditfft2(soundData, window)
    return ditfft2(tolist(soundData, window))
end

---Computes the discrete fourier transform using a naive implementation
---based on its definition. Not a *fast* fourier transform, and not optimised.
---[See More](https://en.wikipedia.org/wiki/Discrete_Fourier_transform)
---@param soundData love.SoundData Sound data.
---@param window? WindowFunction Window function to apply to data. Defaults to a Hann window.
---@return table[] 0-Indexed array of complex numbers representing FFT result.
function FFT.naive_dft(soundData, window)
    return naive_dft(tolist(soundData, window))
end

return FFT
