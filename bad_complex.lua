local M = {} -- the module

-- creates a new complex number
local function complex(r, i)
    ---@class complex
    local c = { r = r or 0, i = i or 0 }
    setmetatable(c, {
        __add = M.add,
        __sub = M.sub,
        __mul = M.mul,
        __div = M.div,
        __pow = function (t1, t2)
            
        end
        __tostring = M.tostring
    })
    return c
end
M.new = complex -- add 'new' to the module


-- Imaginary constant 'i'
M.i = complex(0, 1)

---@param c1 complex
---@param c2 complex
function M.add(c1, c2)
    if type(c1) == "number" then c1 = complex(c1) end
    if type(c2) == "number" then c2 = complex(c2) end

    return complex(c1.r + c2.r, c1.i + c2.i)
end

---@param c1 complex
---@param c2 complex
function M.sub(c1, c2)
    if type(c1) == "number" then c1 = complex(c1) end
    if type(c2) == "number" then c2 = complex(c2) end

    return complex(c1.r - c2.r, c1.i - c2.i)
end

---@param c1 complex
---@param c2 complex
function M.mul(c1, c2)
    if type(c1) == "number" then c1 = complex(c1) end
    if type(c2) == "number" then c2 = complex(c2) end

    return complex(
        c1.r * c2.r - c1.i * c2.i,
        c1.r * c2.i + c1.i * c2.r)
end

---@param c complex
local function inv(c)
    if type(c) == "number" then c = complex(c) end

    local n = c.r ^ 2 + c.i ^ 2
    return complex(c.r / n, -c.i / n)
end

---@param c1 complex
---@param c2 complex
function M.div(c1, c2)
    if type(c1) == "number" then c1 = complex(c1) end
    if type(c2) == "number" then c2 = complex(c2) end

    return M.mul(c1, inv(c2))
end

---@param c complex
function M.tostring(c)
    if type(c) == "number" then c = complex(c) end

    -- return string.format("(%g, %g)", c.r, c.i)
    return string.format("(%g,%g)", c.r, c.i)
end

local z1 = complex(1, 0)
local z2 = complex(1, 1)

print(1 + complex(0, 12))

return M
