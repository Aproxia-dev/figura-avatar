-- default config --
local config = {
    -- please ignore config: base_rot, shape --
    base_rot = vec(10, 0, 0), -- default rotation for tail
    shape = {}, -- table containing more tables with vectors that give extra rotation to tail e.g. {[1] = {add = vec(4, 0, 0), mul = vec(0.5, 1, 1)}} it will multiply rotation of first tail part by vec(0.5, 1, 1) and then it will add 4 on x axis 

    shape_alt = {}, -- same as shape but will be applied when tail is facing up 
    use_alt_shape = false, -- when disabled tail will not use shape_alt

    sleep_pose = {}, -- table of vectors that have rotation that will be applied when player is sleeping
    sleep_random_side = true, -- if enabled tail will have 50% chance of making sleep_pose flipped into other direction

    swim_x_limit = 3, -- how far should tail move when swimming
    y_min = -11, -- how much tail should move up when falling
    y_max = 1, -- how much tail should move down when going up
    y_speed = 10, -- how fast should tail move up or down
    body_vel_limit = 7, -- max tail rotation when spinning (left or right)
    max_sit_rot = 15, -- max rotation when rotating left or right while sitting

    water_offset1 = vec(0, 0.7, 0), -- offset from player position for detecting if player is half under water
    water_offset2 = vec(0, 1.4, 0), -- offset from player position for detecting if player is fully under water

    wag_enabled = true, -- disable or enable tail wag
    wag_speed = 0.8, -- how fast tail should wag
    wag_distance = 12, -- how far it should wag
}

-- variables --
local lerp = math.lerp
local clamp = math.clamp

local time = 0
local tail = {rawConfig = config}
local parts = {}
local old_rot = {}
local rot = {}
local vel = vec(0, 0, 0)
local was_sleeping
local sleep_side = 1
local wagAnim = false
local old_crouch = false

-- pings --
function pings.tail_wag(x)
    wagAnim = x
end

-- player anim --
local anims = {
    STANDING = function(player_vel, body_vel, base_rot, inWater)
        rot[1].x = rot[1].x * (1-clamp(player_vel.x * 2.5, -0.05, 1)) + clamp(player_vel.y * config.y_speed, config.y_min, config.y_max)
        rot[1].y = rot[1].y + clamp(body_vel * 0.5 * (1-math.min(player_vel.xz:length() * 20, 1)), -config.body_vel_limit, config.body_vel_limit) + clamp(player_vel.z * -25, -3, 3) + math.sin(time * 0.5) * clamp(player_vel.x * 2, 0, 1)
        
        if inWater == -1 then
            base_rot.x = -math.abs(base_rot.x)
        elseif inWater == 0 then
            base_rot.x = base_rot.x < 0 and base_rot.x or 0
        end
        return base_rot
    end,
    CROUCHING = "STANDING",
    SWIMMING = function(player_vel, body_vel, base_rot, inWater)
        if inWater == 1 then
            --crawling
            rot[1].x = rot[1].x + clamp(player_vel.x * 5, -2, 2)
            rot[1].y = rot[1].y + clamp(body_vel * 0.1 * (1-math.min(player_vel.xz:length() * 20, 1)), -config.body_vel_limit, config.body_vel_limit)
        else
            --swimming
            rot[1].x = rot[1].x * 0.8 + math.clamp(player_vel.x * 30, -config.swim_x_limit, config.swim_x_limit)
            rot[1].y = rot[1].y + math.clamp(body_vel * 0.2, -config.body_vel_limit, config.body_vel_limit)
            base_rot.x = rot[1].x
        end

        return base_rot
    end,
    FALL_FLYING = function(_, body_vel, base_rot)
        rot[1].y = rot[1].y + math.clamp(body_vel * -0.3, -config.body_vel_limit, config.body_vel_limit)

        return base_rot
    end,
    SPIN_ATTACK = function(_, _, base_rot)
        rot[1].y = rot[1].y * 0.5 + config.body_vel_limit

        return base_rot
    end,
    SLEEPING = function()
        if not was_sleeping and config.sleep_random_side then
            sleep_side = math.random(0, 1) * 2 - 1
        end
        for i, v in pairs(config.sleep_pose) do
            rot[i] = v * 1
            rot[i].y = rot[i].y * sleep_side
            rot[i].z = rot[i].z * sleep_side
        end
        return rot[1], true
    end,
    SIT = function(player_vel, body_vel, base_rot, inWater)
        if inWater == -1 then
            base_rot.x = -math.abs(base_rot.x)
            rot[1].y = rot[1].y * 0.8 + body_vel * 0.1
        else
            rot[1].y = clamp((rot[1].y + body_vel * 0.1) * (1-player_vel.x), -config.max_sit_rot, config.max_sit_rot)
            base_rot.x = 2
        end
        base_rot.y = rot[1].y
        return base_rot
    end
}

-- functions --
local function updateAllParts(_, ...)
    local tbl = {...}
    parts = {}
    rot = {}
    for i = 1, #tbl do
        local part = tbl[i]
        parts[i] = {part}
        local parts_tbl = parts[i]
        local part_name, part_id = part:getName():match("^(.-)([%d-]*)$")
        part_id = tonumber(part_id) or 1

        local id = 1
        while part do
            id = id + 1
            part_id = part_id + 1
            part = part[part_name..part_id]
            parts_tbl[id] = part
        end
    end

    -- generate rotation related variables
    local start_rot_sum = vec(0, 0, 0)
    local average_abs_rot = vec(0, 0, 0)
    local parts_limit = #parts[1]
    local start_parts_limit = parts_limit * 0.4
    -- loop
    for i = 1, parts_limit do
        -- generate base rot
        local part = parts[1][i]
        local r = part:getRot()
        start_rot_sum = start_rot_sum + math.max(1 - (i - 1) / start_parts_limit, 0) * r
        average_abs_rot = average_abs_rot + r:copy():applyFunc(math.abs)

        -- add variables for later calculation
        config.shape[i] = r

        -- generate rotation variables
        rot[i] = vec(0, 0, 0)
        old_rot[i] = rot[i]
    end

    -- calculate final base rot
    average_abs_rot = average_abs_rot / parts_limit

    local rot_sign = vec(start_rot_sum.x < 0 and -1 or 1, start_rot_sum.y < 0 and -1 or 1, start_rot_sum.z < 0 and -1 or 1)

    local base_rot = average_abs_rot * rot_sign
    config.base_rot = base_rot

    -- calculate shape
    for i = 1, parts_limit do
        -- local part = parts[1][i]
        local r = config.shape[i]

        local add = vec(0, 0, 0)
        local mul = vec(1, 1, 1)

        for i2 = 1, 3 do
            local difference = r[i2] - base_rot[i2]
            local flipped_difference = r[i2] + base_rot[i2]
            if math.abs(difference) <= math.abs(flipped_difference) then
                add[i2] = difference
            else
                add[i2] = flipped_difference
                mul[i2] = -1
            end
        end

        config.shape[i] = {add = add, mul = mul}
        -- print(config.shape[i])
    end

    return tail
end

-- tick --
function tail.tick(pos, player_anim, player_vel, body_vel)
    --update time
    time = time + 1

    --move rotation
    for i = #parts[1], 1, -1 do
        old_rot[i] = rot[i]
        if i ~= 1 then
            rot[i] = rot[i-1]
        end
    end

    --update rot
    rot[1] = rot[1] + vel

    --tail wag
    if wagAnim then
        rot[1].y = rot[1].y * 0.5 + math.sin(time * config.wag_speed) * config.wag_distance
    end

    --change physics behaviour based on animation
    local base_rot = config.base_rot * 1

    --in water
    local inWater = 1
    if #world.getBlockState(pos+config.water_offset1):getFluidTags() >= 1 then
        if #world.getBlockState(pos+config.water_offset2):getFluidTags() >= 1 then
            inWater = -1
        else
            inWater = 0
        end
    end

    if player_anim == "CROUCHING" and not old_crouch then
      pings.tail_wag(true)
      old_crouch = true
    elseif player_anim == "CROUCHING" then
      inWater = 0
    elseif player_anim ~= "CROUCHING" and old_crouch then
      pings.tail_wag(false)
      old_crouch = false
    end

    --update rotation based on animation
    if anims[player_anim] then
        if type(anims[player_anim]) == "string" then
            base_rot, was_sleeping = anims[anims[player_anim]](player_vel, body_vel, base_rot, inWater)
        else
            base_rot, was_sleeping = anims[player_anim](player_vel, body_vel, base_rot, inWater)
        end
    else
        base_rot, was_sleeping = anims.STANDING(player_vel, body_vel, base_rot, inWater)
    end


    --update velocity
    vel = vel * 0.7 + (base_rot - rot[1]) * 0.1
end

-- render --
function tail.render(delta)
    local shape = config.shape
    local shape_alt = config.use_alt_shape and config.shape_alt or config.shape

    for _, v in pairs(parts) do
        for i, v2 in pairs(v) do
            local part_rot = lerp(old_rot[i], rot[i], delta)
            if part_rot.x < 0 then
                -- if shape_alt[i] then
                --     if shape_alt[i].mul then
                --         part_rot = part_rot * shape_alt[i].mul
                --     end
                --     if shape_alt[i].add then
                --         part_rot = part_rot + shape_alt[i].add
                --     end
                -- end
                part_rot = part_rot * shape_alt[i].mul + shape_alt[i].add
            else
                -- if shape[i] then
                --     if shape[i].mul then
                --         part_rot = part_rot * shape[i].mul
                --     end
                --     if shape[i].add then
                --         part_rot = part_rot + shape[i].add
                --     end
                -- end
                part_rot = part_rot * shape[i].mul + shape[i].add
            end 
            v2:setRot(part_rot)
        end
    end
end

--metatable
setmetatable(tail, {
    __call = updateAllParts,
    __newindex = function(t, i, v)
        if i == "config" then
            for i2, v2 in pairs(v) do
                config[i2] = v2
            end
        else
            rawset(t, i, v)
        end
    end
})

--return
return tail
