--[[

    TODO:

    - Handle L/R channels being interleaved in sound data
    - Implement FFT rather than the naive DFT
    - Look into embedding complex number calculations rather than using a
      complex number module
    - Experiment with recording device samples (microphone)
    - Add windowing functions (perhaps a table/module of various functions)
    - Clean up code
]]

local complex = require "complex"
local socket = require "socket"
local fft = require "fft"

-- Attach debugger if necessary
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- Locals

local soundData ---@type love.SoundData
local decoder ---@type love.Decoder
local fft_data, comp_time_fft
local source ---@type love.Source

function love.load()
    -- local file = [[sin440Hz_44100Hz_1024samples.wav]]
    local file = [[untitled.wav]]
    -- soundData = love.sound.newSoundData(file)
    decoder = love.sound.newDecoder("song1.mp3", 4096)
    source = love.audio.newSource(decoder, "stream")
    source:play()
    -- initial data
    soundData = decoder:decode()

    fft_data, comp_time_fft = fft.naive_dft(soundData)
end

function love.update(dt)
    local start_time = socket.gettime()
    local d = decoder:clone()
    d:seek(source:tell("seconds"))
    soundData = d:decode()

    fft_data, comp_time_fft = fft.naive_dft(soundData)
    -- source = love.audio.newSource(soundData)
    -- source:play()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    -- Info
    DEBUG_PRINT_LINE = 0
    debug("%d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate())
    debug("Window resolution: %d x %d", love.graphics.getDimensions())
    debug("Mouse position: %d x %d", love.mouse.getPosition())
    debug("DFT computation time (naive): %f (%06.03f ms)", comp_time_fft, comp_time_fft * 1000)

    -- time domain plot
    local points = {}
    local centre_y = love.graphics.getHeight() / 2
    for i = 0, love.graphics.getWidth() do
        table.insert(points, i)
        table.insert(points, centre_y - soundData:getSample(i) * 100)
    end
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.points(points)

    -- frequency domain plot
    local points = {}
    local points2 = {}
    for i = 0, love.graphics.getWidth() do
        table.insert(points, i)
        table.insert(points2, i)
        local re, im = complex.get(fft_data[i])
        local magnitude = math.sqrt(re ^ 2 + im ^ 2)
        table.insert(points, centre_y - magnitude)
        table.insert(points2, centre_y + magnitude)
    end
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(points)
    love.graphics.line(points2)
end

DEBUG_PRINT_LINE = 0
function debug(fmt, ...)
    love.graphics.print(string.format(fmt, ...), 0, 13 * DEBUG_PRINT_LINE)
    DEBUG_PRINT_LINE = DEBUG_PRINT_LINE + 1
end