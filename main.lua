-- Attach debugger if necessary
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local window = require "windows"
local renderer = require "renderer"
local FFT = require "fft"

--[[

    TODO:

    - [ ] Handle L/R channels being interleaved in sound data
    - [x] Implement FFT rather than the naive DFT
    - [ ] Look into embedding complex number calculations rather than using a
          complex number module
    - [ ] Experiment with recording device samples (microphone)
    - [x] Add windowing functions (perhaps a table/module of various functions)
    - [ ] Clean up code
]]

local decoder ---@type love.Decoder
local source ---@type love.Source
function love.load()
    -- create sound decoder and source
    decoder = love.sound.newDecoder("audio/who.wav", 4096)
    -- decoder = love.sound.newDecoder("song1_mono.wav", 4096 / 2)
    source = love.audio.newSource(decoder, "stream")
    source:play()
end

local soundData ---@type love.SoundData
-- local ditfft_data, ditfft_benchmark
local iterfft_data, iterfft_benchmark
function love.update(dt)
    -- Clone decoder and seek to current audio position
    local d = decoder:clone()
    d:seek(source:tell("seconds"))
    soundData = d:decode()

    -- Compute and benchmark FFT
    -- local time_start = os.clock()
    -- ditfft_data = FFT.ditfft2(soundData, window.hann)
    -- ditfft_benchmark = os.clock() - time_start

    local time_start = os.clock()
    iterfft_data = FFT.iterfft(soundData, window.hann)
    iterfft_benchmark = os.clock() - time_start
end

function love.draw()
    -- Print debug info
    love.graphics.setColor(1, 1, 1)
    DEBUG_PRINT_LINE = 0
    debug("%d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate())
    debug("Window resolution: %d x %d", love.graphics.getDimensions())
    debug("Mouse position: %d x %d", love.mouse.getPosition())
    debug("FFT computation time (iterfft): %f (%06.03f ms)", iterfft_benchmark, iterfft_benchmark * 1000)
    -- debug("FFT computation time (ditfft): %f (%06.03f ms)", ditfft_benchmark, ditfft_benchmark * 1000)

    -- time domain plot
    love.graphics.setColor(0, 0.5, 1)
    renderer.plot_sounddata(soundData, 100)

    -- frequency domain plot
    -- love.graphics.setColor(0, 1, 0)
    -- love.graphics.print("ditfft", 0, love.graphics.getHeight() - 100)
    -- renderer.plot_fft(ditfft_data, 2, love.graphics.getHeight() - 100)

    love.graphics.setColor(1, 0, 0)
    love.graphics.print("iterfft", 0, love.graphics.getHeight() - 100)
    renderer.plot_fft(iterfft_data, 2, love.graphics.getHeight() - 100)
end

DEBUG_PRINT_LINE = 0
-- Handles printing debug messages to screen on a new line.
-- Uses string.format for more consise debug print statements
function debug(fmt, ...)
    love.graphics.print(string.format(fmt, ...), 0, 13 * DEBUG_PRINT_LINE)
    DEBUG_PRINT_LINE = DEBUG_PRINT_LINE + 1
end
