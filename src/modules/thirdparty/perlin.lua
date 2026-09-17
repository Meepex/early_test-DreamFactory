-- Author: https://github.com/DarkOnGithub
-- Author (X): https://x.com/UwU__Dark

--Converted to Lua from Luau--

local floor = math.floor
local sqrt = math.sqrt

local F2 = 0.5 * (sqrt(3) - 1)
local G2 = (3 - sqrt(3)) / 6
local F3 = 1 / 3
local G3 = 1 / 6

local gradients = {
    1, 1, 0,  -1, 1, 0,  1, -1, 0,  -1, -1, 0,
    1, 0, 1,  -1, 0, 1,  1, 0, -1,  -1, 0, -1,
    0, 1, 1,   0, -1, 1,  0, 1, -1,   0, -1, -1
}

local function dot2(gi, x, y)
    local offset = gi * 3 + 1

    return gradients[offset] * x
         + gradients[offset + 1] * y
end

local function dot3(gi, x, y, z)
    local offset = gi * 3 + 1

    return gradients[offset] * x
         + gradients[offset + 1] * y
         + gradients[offset + 2] * z
end

-- Equivalent to the 0..255 indexing used by the Luau buffers.
local function wrap256(value)
    return (value % 256) + 1
end

local Handler = {}
Handler.__index = Handler

function Handler.New(seed)
    local obj = setmetatable({}, Handler)

    local permBuffer = {}
    local perm12Buffer = {}

    -- Lua's random generator is different from Roblox's Random,
    -- so this produces the same general type of permutation,
    -- but NOT the exact same permutation for a given seed.
    if seed ~= nil then
        math.randomseed(seed)
    else
        math.randomseed(os.time())
    end

    for i = 1, 512 do
        permBuffer[i] = (i - 1) % 256
    end

    -- Fisher-Yates shuffle.
    for i = 512, 2, -1 do
        local j = math.random(1, i)

        local temp = permBuffer[i]
        permBuffer[i] = permBuffer[j]
        permBuffer[j] = temp
    end

    for i = 1, 512 do
        local value = permBuffer[((i - 1) % 256) + 1]

        permBuffer[i] = value
        perm12Buffer[i] = value % 12
    end

    obj._permBuffer = permBuffer
    obj._perm12Buffer = perm12Buffer

    return obj
end

function Handler:Get2DValue(x, y)
    local permBuffer = self._permBuffer
    local perm12Buffer = self._perm12Buffer

    local s = (x + y) * F2

    local i = floor(x + s)
    local j = floor(y + s)

    local t = (i + j) * G2

    local x0 = x - (i - t)
    local y0 = y - (j - t)

    local i1, j1

    if x0 > y0 then
        i1, j1 = 1, 0
    else
        i1, j1 = 0, 1
    end

    local x1 = x0 - i1 + G2
    local y1 = y0 - j1 + G2

    local x2 = x0 - 1 + 2 * G2
    local y2 = y0 - 1 + 2 * G2

    local ii = i % 256
    local jj = j % 256

    local gi0 =
        perm12Buffer[
            (ii + 1) +  -- +1 because Lua is 1-indexed
            permBuffer[(jj + 1)]
            + 0
        ]

    local gi1 =
        perm12Buffer[
            (ii + i1 + 1) +
            permBuffer[(jj + j1) % 256 + 1]
        ]

    local gi2 =
        perm12Buffer[
            (ii + 1 + 1) +
            permBuffer[(jj + 1) % 256 + 1]
        ]

    -- Wrap the second-level indexes too.
    gi0 = gi0 % 12
    gi1 = gi1 % 12
    gi2 = gi2 % 12

    local n0, n1, n2 = 0, 0, 0

    local t0 = 0.5 - x0 * x0 - y0 * y0

    if t0 > 0 then
        t0 = t0 * t0
        n0 = t0 * t0 * dot2(gi0, x0, y0)
    end

    local t1 = 0.5 - x1 * x1 - y1 * y1

    if t1 > 0 then
        t1 = t1 * t1
        n1 = t1 * t1 * dot2(gi1, x1, y1)
    end

    local t2 = 0.5 - x2 * x2 - y2 * y2

    if t2 > 0 then
        t2 = t2 * t2
        n2 = t2 * t2 * dot2(gi2, x2, y2)
    end

    return 70 * (n0 + n1 + n2)
end

function Handler:Get3DValue(x, y, z)
    local permBuffer = self._permBuffer
    local perm12Buffer = self._perm12Buffer

    local s = (x + y + z) * F3

    local i = floor(x + s)
    local j = floor(y + s)
    local k = floor(z + s)

    local t = (i + j + k) * G3

    local x0 = x - (i - t)
    local y0 = y - (j - t)
    local z0 = z - (k - t)

    local i1, j1, k1
    local i2, j2, k2

    if x0 >= y0 then
        if y0 >= z0 then
            i1, j1, k1 = 1, 0, 0
            i2, j2, k2 = 1, 1, 0
        elseif x0 >= z0 then
            i1, j1, k1 = 1, 0, 0
            i2, j2, k2 = 1, 0, 1
        else
            i1, j1, k1 = 0, 0, 1
            i2, j2, k2 = 1, 0, 1
        end
    else
        if y0 < z0 then
            i1, j1, k1 = 0, 0, 1
            i2, j2, k2 = 0, 1, 1
        elseif x0 < z0 then
            i1, j1, k1 = 0, 1, 0
            i2, j2, k2 = 0, 1, 1
        else
            i1, j1, k1 = 0, 1, 0
            i2, j2, k2 = 1, 1, 0
        end
    end

    local x1 = x0 - i1 + G3
    local y1 = y0 - j1 + G3
    local z1 = z0 - k1 + G3

    local x2 = x0 - i2 + 2 * G3
    local y2 = y0 - j2 + 2 * G3
    local z2 = z0 - k2 + 2 * G3

    local x3 = x0 - 1 + 3 * G3
    local y3 = y0 - 1 + 3 * G3
    local z3 = z0 - 1 + 3 * G3

    local ii = i % 256
    local jj = j % 256
    local kk = k % 256

    local gi0 =
        perm12Buffer[
            (ii + permBuffer[
                (jj + permBuffer[kk + 1] % 256) % 256 + 1
            ]) % 256 + 1
        ]

    local gi1 =
        perm12Buffer[
            (
                ii + i1 +
                permBuffer[
                    (
                        jj + j1 +
                        permBuffer[(kk + k1) % 256 + 1]
                    ) % 256 + 1
                ]
            ) % 256 + 1
        ]

    local gi2 =
        perm12Buffer[
            (
                ii + i2 +
                permBuffer[
                    (
                        jj + j2 +
                        permBuffer[(kk + k2) % 256 + 1]
                    ) % 256 + 1
                ]
            ) % 256 + 1
        ]

    local gi3 =
        perm12Buffer[
            (
                ii + 1 +
                permBuffer[
                    (
                        jj + 1 +
                        permBuffer[(kk + 1) % 256 + 1]
                    ) % 256 + 1
                ]
            ) % 256 + 1
        ]

    gi0 = gi0 % 12
    gi1 = gi1 % 12
    gi2 = gi2 % 12
    gi3 = gi3 % 12

    local n0, n1, n2, n3 = 0, 0, 0, 0

    local t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0

    if t0 > 0 then
        t0 = t0 * t0
        n0 = t0 * t0 * dot3(gi0, x0, y0, z0)
    end

    local t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1

    if t1 > 0 then
        t1 = t1 * t1
        n1 = t1 * t1 * dot3(gi1, x1, y1, z1)
    end

    local t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2

    if t2 > 0 then
        t2 = t2 * t2
        n2 = t2 * t2 * dot3(gi2, x2, y2, z2)
    end

    local t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3

    if t3 > 0 then
        t3 = t3 * t3
        n3 = t3 * t3 * dot3(gi3, x3, y3, z3)
    end

    return 32 * (n0 + n1 + n2 + n3)
end

function Handler:Get2DFBM(
    x,
    y,
    amplitude,
    frequency,
    octaveCount,
    persistence,
    lacunarity
)
    local value = 0
    local maxAmplitude = 0

    local currentAmplitude = amplitude
    local currentFrequency = frequency

    for i = 1, octaveCount do
        if currentAmplitude < 0.001 then
            break
        end

        value = value
            + currentAmplitude
            * self:Get2DValue(
                x * currentFrequency,
                y * currentFrequency
            )

        maxAmplitude = maxAmplitude + currentAmplitude

        currentAmplitude = currentAmplitude * persistence
        currentFrequency = currentFrequency * lacunarity
    end

    if maxAmplitude > 0 then
        return value / maxAmplitude
    end

    return 0
end

function Handler:Get2DFBMBatch(
    offsetX,
    offsetY,
    width,
    height,
    results,
    amplitude,
    frequency,
    octaveCount,
    persistence,
    lacunarity
)
    local permBuffer = self._permBuffer
    local perm12Buffer = self._perm12Buffer

    offsetX = offsetX or 0
    offsetY = offsetY or 0

    local octaveParams = {}

    local currentAmplitude = amplitude
    local currentFrequency = frequency
    local maxAmplitude = 0

    for i = 1, octaveCount do
        if currentAmplitude < 0.001 then
            break
        end

        octaveParams[i] = {
            amplitude = currentAmplitude,
            frequency = currentFrequency
        }

        maxAmplitude = maxAmplitude + currentAmplitude

        currentAmplitude = currentAmplitude * persistence
        currentFrequency = currentFrequency * lacunarity
    end

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local value = 0

            for i = 1, #octaveParams do
                local params = octaveParams[i]

                local freqX = (x + offsetX) * params.frequency
                local freqY = (y + offsetY) * params.frequency

                local s = (freqX + freqY) * F2

                local ix = floor(freqX + s)
                local jy = floor(freqY + s)

                local t = (ix + jy) * G2

                local x0 = freqX - (ix - t)
                local y0 = freqY - (jy - t)

                local i1, j1

                if x0 > y0 then
                    i1, j1 = 1, 0
                else
                    i1, j1 = 0, 1
                end

                local x1 = x0 - i1 + G2
                local y1 = y0 - j1 + G2

                local x2 = x0 - 1 + 2 * G2
                local y2 = y0 - 1 + 2 * G2

                local ii = ix % 256
                local jj = jy % 256

                local gi0 =
                    perm12Buffer[
                        (ii + permBuffer[jj + 1]) % 256 + 1
                    ]

                local gi1 =
                    perm12Buffer[
                        (
                            ii + i1 +
                            permBuffer[
                                (jj + j1) % 256 + 1
                            ]
                        ) % 256 + 1
                    ]

                local gi2 =
                    perm12Buffer[
                        (
                            ii + 1 +
                            permBuffer[(jj + 1) % 256 + 1]
                        ) % 256 + 1
                    ]

                gi0 = gi0 % 12
                gi1 = gi1 % 12
                gi2 = gi2 % 12

                local n0, n1, n2 = 0, 0, 0

                local t0 = 0.5 - x0 * x0 - y0 * y0

                if t0 > 0 then
                    t0 = t0 * t0
                    n0 = t0 * t0 * dot2(gi0, x0, y0)
                end

                local t1 = 0.5 - x1 * x1 - y1 * y1

                if t1 > 0 then
                    t1 = t1 * t1
                    n1 = t1 * t1 * dot2(gi1, x1, y1)
                end

                local t2 = 0.5 - x2 * x2 - y2 * y2

                if t2 > 0 then
                    t2 = t2 * t2
                    n2 = t2 * t2 * dot2(gi2, x2, y2)
                end

                value = value
                    + params.amplitude
                    * 70
                    * (n0 + n1 + n2)
            end

            results[y * width + x + 1] =
                maxAmplitude > 0
                and value / maxAmplitude
                or 0
        end
    end

    return results
end

function Handler:Get2DBatch(
    offsetX,
    offsetY,
    width,
    height,
    results,
    frequency
)
    local permBuffer = self._permBuffer
    local perm12Buffer = self._perm12Buffer

    frequency = frequency or 1
    offsetX = offsetX or 0
    offsetY = offsetY or 0

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local posX = (x + offsetX) * frequency
            local posY = (y + offsetY) * frequency

            local s = (posX + posY) * F2

            local ix = floor(posX + s)
            local jy = floor(posY + s)

            local t = (ix + jy) * G2

            local x0 = posX - (ix - t)
            local y0 = posY - (jy - t)

            local i1, j1

            if x0 > y0 then
                i1, j1 = 1, 0
            else
                i1, j1 = 0, 1
            end

            local x1 = x0 - i1 + G2
            local y1 = y0 - j1 + G2

            local x2 = x0 - 1 + 2 * G2
            local y2 = y0 - 1 + 2 * G2

            local ii = ix % 256
            local jj = jy % 256

            local gi0 =
                perm12Buffer[
                    (ii + permBuffer[jj + 1]) % 256 + 1
                ]

            local gi1 =
                perm12Buffer[
                    (
                        ii + i1 +
                        permBuffer[
                            (jj + j1) % 256 + 1
                        ]
                    ) % 256 + 1
                ]

            local gi2 =
                perm12Buffer[
                    (
                        ii + 1 +
                        permBuffer[(jj + 1) % 256 + 1]
                    ) % 256 + 1
                ]

            gi0 = gi0 % 12
            gi1 = gi1 % 12
            gi2 = gi2 % 12

            local n0, n1, n2 = 0, 0, 0

            local t0 = 0.5 - x0 * x0 - y0 * y0

            if t0 > 0 then
                t0 = t0 * t0
                n0 = t0 * t0 * dot2(gi0, x0, y0)
            end

            local t1 = 0.5 - x1 * x1 - y1 * y1

            if t1 > 0 then
                t1 = t1 * t1
                n1 = t1 * t1 * dot2(gi1, x1, y1)
            end

            local t2 = 0.5 - x2 * x2 - y2 * y2

            if t2 > 0 then
                t2 = t2 * t2
                n2 = t2 * t2 * dot2(gi2, x2, y2)
            end

            results[y * width + x + 1] =
                70 * (n0 + n1 + n2)
        end
    end

    return results
end

return Handler.New