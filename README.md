# Lua/LOVE2D FFT
A simple FFT implementation written in lua. Runs in LOVE2D for rendering and retrieving audio samples, but the core FFT implementation doesn't depend on it. Note that the `iterfft` implementation requires bitwise operations, and therefore uses LuaJIT's `bit` module to run in LOVE2D. This can easily be replaced with the built-in bitwise operators in pure lua (5.3+).

## FFT Implementations
`fft.lua` contains all the FFT implementation code:
- `iterfft` A non-recursive/iterative Cooley-Tukey radix-2 DIT implementation using bit-reversal permutation. (fastest)
- `ditfft2` A recursive Cooley-Tukey radix-2 DIT implementation. (less fast)
- `naive_dft` A naive implementation of the DFT based off of its definition. (not fast)
Each of the implementations have a simple wrapper to convert LOVE2D's `SoundData` objects into the 0-indexed complex arrays that the functions expect.

## Window Functions
`windows.lua` contains various window functions. The Hann window is used as the default wherever necessary.

## Credits & Misc
- [`complex.lua`](http://lua-users.org/wiki/ComplexNumbers) is a complex number module from lua-users.org, based on LuaMatrix
- Most of the FFT implementations are adapted from [Wikipedia](https://en.m.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm)
- All other files in the project are related to LOVE2D
