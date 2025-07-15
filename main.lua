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

    Known Issues:
    - Iterfft seems to duplicate output when going above 2048 samples
]]

local decoder ---@type love.Decoder
local source ---@type love.Source
function love.load()
    -- create sound decoder and audio source
    decoder = love.sound.newDecoder("audio/who.wav", 4096)
    source = love.audio.newSource(decoder, "stream")
    source:play()
end

local soundData ---@type love.SoundData
local fft_data, fft_benchmark
function love.update(dt)
    -- Clone decoder and seek to get SoundData at current position
    local d = decoder:clone()
    d:seek(source:tell("seconds"))
    soundData = d:decode()

    -- Compute and benchmark FFT
    local time_start = os.clock()
    fft_data = FFT.iterfft(soundData, window.hann)
    fft_benchmark = os.clock() - time_start
end

function love.draw()
    -- Print debug info
    love.graphics.setColor(1, 1, 1)
    DEBUG_PRINT_LINE = 0
    debug("SoundData: %d samples @ %dHz", soundData:getSampleCount(), soundData:getSampleRate())
    debug("Window resolution: %d x %d", love.graphics.getDimensions())
    debug("Mouse position: %d x %d", love.mouse.getPosition())
    debug("FFT computation time (iterfft): %f (%06.03f ms)", fft_benchmark, (fft_benchmark * 1000))

    -- time domain plot
    love.graphics.setColor(0, 0.5, 1)
    renderer.plot_sounddata(soundData, 100)

    -- frequency domain plot
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("iterfft", 0, love.graphics.getHeight() - 100)
    renderer.plot_fft(fft_data, 2, love.graphics.getHeight() - 100)
end

DEBUG_PRINT_LINE = 0
-- Handles printing debug messages to screen on a new line.
-- Uses string.format for more consise debug print statements
function debug(fmt, ...)
    love.graphics.print(string.format(fmt, ...), 0, 13 * DEBUG_PRINT_LINE)
    DEBUG_PRINT_LINE = DEBUG_PRINT_LINE + 1
end
