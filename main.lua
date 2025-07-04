local complex = require "complex"
local socket = require "socket"

-- Attach debugger if necessary
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- Locals

local soundData ---@type love.SoundData
local decoder ---@type love.Decoder
local fft, comp_time_fft
local source ---@type love.Source
local comp_time_update
local comp_time_decode
local delta_time

function love.load()
    -- local file = [[sin440Hz_44100Hz_1024samples.wav]]
    local file = [[untitled.wav]]
    -- soundData = love.sound.newSoundData(file)
    decoder = love.sound.newDecoder("song.mp3", 4096)
    soundData = decoder:decode()
    source = love.audio.newSource(decoder, "stream")
    source:play()

    fft, comp_time_fft = naive_dft(soundData)
end

function love.update(dt)
    delta_time = dt
    local start_time = socket.gettime()
    local d = decoder:clone()
    d:seek(source:tell("seconds"))
    soundData = d:decode()
    comp_time_decode = socket.gettime() - start_time

    fft, comp_time_fft = naive_dft(soundData)
    -- source = love.audio.newSource(soundData)
    -- source:play()
    comp_time_update = socket.gettime() - start_time
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    -- Info
    love.graphics.print(
        string.format("%d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate()))
    love.graphics.print(string.format("%d x %d", love.graphics.getDimensions()), 0, 13 * 1)
    love.graphics.print(string.format("%d x %d", love.mouse.getPosition()), 0, 13 * 2)
    love.graphics.print(string.format("DFT computation time (naive): %f (%06.03f ms)", comp_time_fft, comp_time_fft * 1000), 0, 13 * 3)
    love.graphics.print(string.format("SoundData decode time: %f (%06.03f ms)", comp_time_decode, comp_time_decode * 1000), 0, 13 * 6)
    love.graphics.print(string.format("Decode + DFT computation time: %f (%06.03f ms)", comp_time_update, comp_time_update * 1000), 0, 13 * 4)
    love.graphics.print(string.format("Delta time: %f (%06.03f ms)", delta_time, delta_time * 1000), 0, 13 * 5)

    -- time domain plot
    local points = {}
    local centre_y = love.graphics.getHeight() / 2
    for i = 0, love.graphics.getWidth() do
        table.insert(points, i)
        table.insert(points, centre_y - soundData:getSample(i) * 100)
    end
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.line(points)

    -- frequency domain plot
    local points = {}
    for i = 0, love.graphics.getWidth() do
        table.insert(points, i)
        local re, im = complex.get(fft[i])
        local magnitude = math.sqrt(re ^ 2 + im ^ 2)
        table.insert(points, centre_y - magnitude)
    end
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(points)
end

---@param x love.SoundData
function naive_dft(x)
    local time_start = socket.gettime()
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

    return X, socket.gettime() - time_start
end
