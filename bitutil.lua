local bitutil = {}

-- Swaps n consecutive individual bits in b at positions i and j
-- https://graphics.stanford.edu/~seander/bithacks.html#SwappingBitsXOR
function bitutil.bswap(b, i, j, n)
    n = n or 1
    -- local x = ((b >> i) ~ (b >> j)) & ((1 << n) - 1) -- XOR temporary
    local x = bit.band(bit.bxor(bit.rshift(b, i), bit.rshift(b, j)), (bit.lshift(1, n) - 1))
    -- local r = b ~ ((x << i) | (x << j))
    return bit.bxor(b, bit.bor(bit.lshift(x, i), bit.lshift(x, j)))
end

-- Reverses n bits in a number b
function bitutil.brev(b, n)
    for i = 0, math.floor((n - 1) / 2) do
        b = bitutil.bswap(b, i, n - 1 - i)
    end
    return b
end

return bitutil
