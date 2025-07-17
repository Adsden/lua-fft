# Lua/LOVE2D FFT
A simple FFT implementation written in Lua. Uses LOVE2D for rendering and retrieving audio samples, but the core FFT implementation doesn't depend on it.

> [!NOTE]
> Note that the `iterfft` implementation requires bitwise operations, and therefore uses LuaJIT's bundled `bit` module to run in LOVE2D. This functionality lives in `bitutil.lua` and can easily be modified to use the built-in bitwise operators in pure Lua (5.3+).-in bitwise operator in pure Lua (5.3+).

## FFT Implementations
`fft.Lua` contains all the FFT implementation code:

- `iterfft` - A non-recursive/iterative Cooley-Tukey radix-2 DIT implementation using bit-reversal permutation. (fastest)
- `ditfft2` - A recursive Cooley-Tukey radix-2 DIT implementation. (less fast)
- `naive_dft` - A naive implementation of the DFT based off of its mathematical definition. (not fast)

These FFT functions expect 0-indexed arrays of complex numbers. The `sdutil` module can convert LOVE2D's `SoundData` objects into the correct format. (It also applies a window function for convenience)

## Window Functions
`windows.lua` contains various window functions. The Hann window is a good default if you do not know which to pick. (This is already the default for the `sdutil` module)

## Credits & Misc
- [`complex.lua`](http://Lua-users.org/wiki/ComplexNumbers) is a complex number module from Lua-users.org, which itself is from LuaMatrix.
- Most of the FFT implementations are adapted from [Wikipedia](https://en.m.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm).
- Many of the other files in the project are only related to LOVE2D (e.g: rendering, playback, etc). All the FFT logic is in the above mentioned files.
