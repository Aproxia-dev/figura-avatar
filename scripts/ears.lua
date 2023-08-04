--config
local config = {
    default_angle = 20, -- default rotation
    sneak_angle = 55, -- rotation when player is sneaking
    addAngle = {}, -- everything in this table will be added to default_angle or sneak_angle this might be useful if you want to control ears rotation with other script
}

--variables
local ears = {rawConfig = config}
local left_ear
local right_ear

local clamp = math.clamp

local rot = vec(0, 0, 0, 0)
local old_rot = rot
local vel = vec(0, 0, 0, 0)

function ears.tick(rot_vel, head_vel)
    old_rot = rot

    local angle = config.default_angle
    if player:getPose() == "CROUCHING" then
        angle = config.sneak_angle
    end
    for _, v in pairs(config.addAngle) do
        angle = angle + v
    end

    angle = angle + clamp(head_vel.y * 15, -8, 8)

    vel = vel * 0.4 + (vec(0, 0, 0,  angle) - rot) * 0.2

    rot = rot + vel

    rot.x = rot.x + clamp(rot_vel.x * 4 + head_vel.x * 30, -10, 10)

    rot.z = rot.z + clamp(head_vel.z * 20, -15, 15)
end

function ears.render(delta)
    local r = math.lerp(old_rot, rot, delta)

    left_ear:setRot(r.xyz+r.__w)
    right_ear:setRot(r.xyz-r.__w)
end

--metatable
setmetatable(ears, {
    __call = function(_, left, right) left_ear = left right_ear = right return ears end,
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

return ears