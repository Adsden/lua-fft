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
    local start_time = socket.gettime()
    local d = decoder:clone()
    d:seek(source:tell("seconds"))
    soundData = d:decode()

    fft, comp_time_fft = naive_dft(soundData)
    -- source = love.audio.newSource(soundData)
    -- source:play()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    -- Info
    DEBUG_PRINT_LINE = 0
    love.graphics.debugf("%d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate())
    love.graphics.debugf("Window resolution: %d x %d", love.graphics.getDimensions())
    love.graphics.debugf("Mouse position: %d x %d", love.mouse.getPosition())
    love.graphics.debugf("DFT computation time (naive): %f (%06.03f ms)", comp_time_fft, comp_time_fft * 1000)

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

DEBUG_PRINT_LINE = 0
function love.graphics.debugf(fmt, ...)
    love.graphics.print(string.format(fmt, ...), 0, 13 * DEBUG_PRINT_LINE)
    DEBUG_PRINT_LINE = DEBUG_PRINT_LINE + 1
end