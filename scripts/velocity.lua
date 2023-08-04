local body_rot
local old_body_rot
local rot
local old_rot

return function()
    old_body_rot = body_rot
    body_rot = player:getBodyYaw()

    if not old_body_rot then
        old_body_rot = body_rot
    end

    old_rot = rot
    rot = player:getRot()

    if not old_rot then
        old_rot = rot
    end

    local vel = player:getVelocity()
    local head_vel = vel * 1

    local body_rad = math.rad(-90-body_rot)

    vel.x, vel.z = vel.x * math.cos(body_rad) - vel.z * math.sin(body_rad), vel.x * math.sin(body_rad) + vel.z * math.cos(body_rad)

    local head_rad2 = math.rad(-90-rot.y)
    local head_rad = math.rad(rot.x)

    head_vel.x, head_vel.z = head_vel.x * math.cos(head_rad2) - head_vel.z * math.sin(head_rad2), head_vel.x * math.sin(head_rad2) + head_vel.z * math.cos(head_rad2)
    head_vel.x, head_vel.y = head_vel.x * math.cos(head_rad) - head_vel.y * math.sin(head_rad), head_vel.x * math.sin(head_rad) + head_vel.y * math.cos(head_rad)

    return vel, (body_rot - old_body_rot + 90) % 180 - 90, rot - old_rot, head_vel
end