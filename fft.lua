local complex = require "complex"
local FFT = {}

-- Attach debugger if necessary
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

---@param x love.SoundData | table
---@return number[]
local function tolist(x)
    if type(x) ~= "userdata" then
        return x
    end

    local list = {}
    for i = 0, x:getSampleCount() - 1 do
        list[i] = x:getSample(i)
    end
    return list
end

---@param data love.SoundData
---@param first integer
---@param last integer
---@param step integer
---@return love.SoundData slice
---@return integer count
local function slicedata(data, first, last, step)
    local slice = love.sound.newSoundData(
        data:getSampleCount(),
        data:getSampleRate(),
        data:getBitDepth(),
        data:getChannelCount()
    )

    local j = 0                  -- j: slice index
    for i = first, last, step do -- i: data index
        print(string.format("slice[%d:%d:%d] data[%d] -> slice[%d]", first, last, step, i, j))
        slice:setSample(j, data:getSample(i))
        j = j + 1
    end

    return slice, j
end

local function slice(list, first, last, step)
    local s = {}
    for i = first, last, step do
        if #s == 0 then
            s[0] = list[i]
        else
            table.insert(s, list[i])
        end
    end
    return s
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

---@param data love.SoundData
function FFT.ditfft2(data, N)
    N = N or data:getSampleCount()

    -- trivial size-1 DFT base case
    -- DFT of a single sample is itself
    if N == 1 then
        local dft_single = love.sound.newSoundData(1, -- one sample
            data:getSampleRate(),
            data:getBitDepth(),
            data:getChannelCount()
        )
        dft_single:setSample(0, data:getSample(0))
        return dft_single
    end

    -- Recursively compute DFT on the odd and even "slices" of data
    local dft_even   = FFT.ditfft2(slicedata(data, 0, N - 2, 2)) -- 0, 2, 4,..., N-2 (N is even, so N-2 is too)
    local dft_odd    = FFT.ditfft2(slicedata(data, 1, N - 1, 2)) -- 1, 3, 5,..., N-1 (therefore N-1 must be odd)

    -- Merge dft results of odd and even slices
    local dft_merged = love.sound.newSoundData(
        data:getSampleCount(),
        data:getSampleRate(),
        data:getBitDepth(),
        data:getChannelCount()
    )

    for k = 0, (N / 2) - 1 do
        -- sample from even half
        local p = dft_even:getSample(k)

        -- sample from odd
        local twiddle = 2 * math.pi * complex.new(0, 1) * k -- −2πik (i: imag)
        twiddle = twiddle / N                               -- −2πik/N
        twiddle = complex.exp(twiddle)                      -- exp(−2πik/N)
        local q = twiddle * dft_odd:getSample(k)

        dft_merged:setSample(k, p + q)
        dft_merged:setSample(k + (N / 2), p - q)
    end

    return dft_merged
end

function FFT.ditfft2_old(x)
    print("FFT.ditfft2(x)")
    -- Sanitisation/preparation
    local data
    if type(x) == "userdata" then
        print("  x is userdata!")
        data = tolist(x) -- convert to 0-indexed list if x is love.SoundData
    else
        print("  x isnt userdata")
        data = x -- otherwise use x as-is
    end
    print("  actual type: " .. type(x))
    local N = #data + 1 -- number of samples
    print("  N = " .. tostring(N))

    -- trivial base case: size-1 DFT
    if N == 1 then
        print("  Base case! N = 1, returning data[0]")
        return { [0] = data[0] }
    end

    -- Split into even and odd samples
    print("  splitting even...")
    local even = slice(data, 0, N - 2, 2) -- 0, 2, 4,..., N-2 (N must be even, so N-2 is even too)
    print("  splitting odd...")
    local odd = slice(data, 1, N - 1, 2)  -- 1, 3, 5,..., N-1 (hence, N-1 is odd)
    -- Recursively compute DFT on odd & even slices
    print("    Taking even dft...")
    even = FFT.ditfft2_old(even)
    print("    Taking odd dft...")
    odd          = FFT.ditfft2_old(odd)

    local merged = even
    table.move(odd, 0, #odd, #even + 1)
    print("even", #even)
    print("odd", #odd)
    print("merged", #merged)

    -- Combine DFTs of odd & even halves into a complete DFT
    -- local twiddle = -2 * math.pi * complex.new(0, 1) -- −2πi
    -- twiddle       = twiddle / N -- −2πi/N

    for k = 0, (N / 2) - 1 do

    end

    return data, 0
end

return FFT
