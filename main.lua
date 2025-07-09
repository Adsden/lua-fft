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
local fft = require "fft"

-- Attach debugger if necessary
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- Locals

local decoder ---@type love.Decoder
local source ---@type love.Source
local soundData ---@type love.SoundData
local fft_data, comp_time_fft

function love.load()
    -- create sound decoder and source
    decoder = love.sound.newDecoder("song1.mp3", 4096)
    source = love.audio.newSource(decoder, "stream")
    source:play()
end

function love.update(dt)
    -- Clone decoder and seek to current audio position
    -- new decoder will have pos=0 which allows seeking to source's exact position
    local d = decoder:clone()
    d:seek(source:tell("seconds"))

    -- get sound data at current pos and compute fft
    soundData = d:decode()
    fft_data, comp_time_fft = fft.ditfft2(soundData)
end

function love.draw()
    -- Print debug info
    love.graphics.setColor(1, 1, 1)
    DEBUG_PRINT_LINE = 0
    debug("%d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate())
    debug("Window resolution: %d x %d", love.graphics.getDimensions())
    debug("Mouse position: %d x %d", love.mouse.getPosition())
    debug("DFT computation time (naive): %f (%06.03f ms)", comp_time_fft, comp_time_fft * 1000)
    debug("%d", #fft_data)

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
    points = {}
    for i = 0, love.graphics.getWidth() do
        table.insert(points, i)
        local re, im = complex.get(fft_data[i])
        local magnitude = math.sqrt(re ^ 2 + im ^ 2)
        table.insert(points, centre_y - magnitude)
    end
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(points)
end

DEBUG_PRINT_LINE = 0
-- Handles printing debug messages to screen on a new line.
-- Uses string.format for more consise debug print statements
function debug(fmt, ...)
    love.graphics.print(string.format(fmt, ...), 0, 13 * DEBUG_PRINT_LINE)
    DEBUG_PRINT_LINE = DEBUG_PRINT_LINE + 1
end