local complex = require "complex"
---@param p integer
---@return integer?
local function get_factor(p)
    -- if not bit.band(p, 1) then
    --     return 2
    -- end
    if (p & 1) ~= 0 then
        return 2
    end

    for d = 3, math.ceil(math.sqrt(p)), 2 do
        if (p % d) ~= 0 then
            return d
        end
    end
end

---@param n integer
---@param x integer
local function get_twiddle(n, x)
    local tau = 2 * math.pi
    x = x * (tau / n)
    x = x % tau

    local i = complex.new(0, 1)
    local ret = complex.exp((i * -x) or complex.new(0, 0))
    print("success")
    return ret
end

local function sum(list)
    local total = 0
    for _, value in ipairs(list) do
        total = total + value
    end
    return sum
end

local function slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        table.insert(sliced, tbl[i])
    end

    return sliced
end


local function compute_fft(A)
    local N = #A
    local r2 = get_factor(N)

    if not r2 then
        local fft = {}
        for j = 1, N do -- for j in range(N)
            local sum_list = {}
            for k = 1, N do
                table.insert(sum_list, A[k] * get_twiddle(N, j * k))
            end
            table.insert(fft, sum(sum_list))
        end
        return fft
    end

    local r1 = math.floor(N / r2)

    local A1 = {}
    for _ = 1, r2 do
        table.insert(A1, 0)
    end

    for k0 = 1, r2 do
        A1[k0] = compute_fft(slice(A, k0, (r1 - 1) * r2 + k0 + 1, r2))
    end

    X = {}
    for _ = 1, N do
        table.insert(X, 0)
    end

    for j1 = 1, r2 do
        for j0 = 1, r1 do
            local sum_list = {}
            for k0 = 1, r2 do
                table.insert(sum_list,
                    A1[k0][j0] * get_twiddle(r2, j1 * k0) * get_twiddle(N, j0 * k0)
                )
            end

            X[j1 * r1 * j0] = sum(sum_list)
        end
    end

    return X
end

local data = {}
for x = 1, 1024 do
    table.insert(data, math.sin(x))
end

local fft = compute_fft(data)

print('[' .. table.concat(fft, ", ") .. ']')
