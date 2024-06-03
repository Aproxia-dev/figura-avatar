vanilla_model.PLAYER:setVisible(false)

local squapi = require('scripts.SquAPI')

headmates = {
    emi = {
        name        = "Emi",
        pronouns    = "§dshe§f/§cthey",
        variant     = 1,
        variants    = { { "casual", ":fox:"}, { "witch", ":witch:" }, { "engineer", ":zap:" } },
        icon        = "minecraft:pink_tulip",
    },
    chris = {
        name        = "Chris",
        pronouns    = "§3he§f/§8they",
        variant     = 1,
        variants    = { { "hoodie", nil }, { "coat", nil } },
        icon        = "minecraft:echo_shard",
    },
    ash = {
        name        = "ash.",
        pronouns    = "§8they§f/§4xe",
        variant     = 1,
        variants    = { { "emo", nil } },
        icon        = "minecraft:nether_wart",
    },
}

if tonumber(client.getVersion():sub(
    client.getVersion():find('.', 1, true) + 1,
    client.getVersion():find('.', 3, true) - 1
)) > 18 then
    headmates.chris.icon = "minecraft:echo_shard"
else
    headmates.chris.icon = "minecraft:soul_lantern"
end

switchWheel = action_wheel:newPage()
action_wheel:setPage(switchWheel)
action_wheel.rightClick = function()
        action_wheel:setPage(switchWheel)
end

-- Switch Function {{{
local currentModel

local modelInfo = {
    toggleables = {},
    disableOnSwitch = {},
    swOut = function() end,
}

function switch(name, variant, animate)
    currentModel = {name, variant, {} }
    headmates[name].variant = variant
    local variantName = headmates[name].variants[variant][1]

    if init == true then
        -- Effect
        particles:removeParticles()
        if animate ~= false then
        sounds:playSound("minecraft:block.lava.extinguish", player:getPos())
        for i = 0, 50, 1 do
            particles:newParticle("minecraft:cloud", player:getPos() + vec(math.random(-1, 1), math.random(0, 2), math.random(-1, 1)),
                                                     vec((math.random() - 0.5) * 0.2, math.random() * 0.2, (math.random() - 0.5) * 0.2)):setPhysics(false):setScale(3)
            end
        end
        
        -- Reset
        modelInfo.swOut()
        for n, h in pairs(headmates) do
            models[n]:setVisible(false)
            events.TICK:remove(n)
            if models[n].constant then
                models[n].constant:setVisible(false)
            end
            for _, var in pairs(h.variants) do
                events.TICK:remove(n .. "_" .. var[1])
                models[n][var[1]]:setVisible(false)
            end
        end

        -- Show chosen model
        models[name]:setVisible(true)
        models[name][variantName]:setVisible(true)
        if models[name].constant then
            models[name].constant:setVisible(true)
        end

        -- Reset toggleables and import scripts
        for _, part in pairs(modelInfo.disableOnSwitch) do
            part:setVisible(false)
        end
        togglePage = action_wheel:newPage()

        local modelScript
        modelScript, modelInfo = pcall(function() return require(name .. "." .. variantName)() end)
        if modelScript == false or modelInfo == nil then
            modelInfo = {
                toggleables = {},
                disableOnSwitch = {},
                swOut = function() end,
            }
        end
    end

    -- Change Nameplate
    nameplate.ENTITY:setPos(0, 0, 0)
    varIcon = headmates[name].variants[variant][2]
    if varIcon == nil then
        nameplate.ALL:setText(headmates[name].name)
        nameplate.ENTITY:setText(toJson({
            { text = "\n" },
            { text = table.concat({headmates[name].name, "${badges}"}, " ") },
            { text = "\n" },
            { text = "§7(" .. headmates[name].pronouns .. "§7)" }
        }))
    else
        nameplate.LIST:setText(headmates[name].name .. " " .. varIcon)
        nameplate.CHAT:setText(headmates[name].name)
        nameplate.ENTITY:setText(toJson({
            { text = "\n" },
            { text = table.concat({varIcon, headmates[name].name, "${badges}"}, " ") },
            { text = "\n" },
            { text = "§7(" .. headmates[name].pronouns .. "§7)" }
        }))
    end
end

pings.switch = switch
-- }}}

-- Toggle Function {{{

function toggle(model, bool)
    if bool then
        currentModel[3][model] = modelInfo.toggleables[model]
    else
        currentModel[3][model] = nil
    end
    if init then
        modelInfo.toggleables[model]:setVisible(bool)
    end
end

pings.toggle = toggle

function makeTog(name, icon, default)
    yeah = togglePage	:newAction()
                        :setItem(icon)
                        :setTitle("Enable " .. name)
                        :setToggleTitle("Disable " .. name)
                        :setToggled(default)
                        :onLeftClick(function()
                            yeah:setToggled(not yeah:isToggled())
                            pings.toggle(name, yeah:isToggled())
                        end)
    
    pings.toggle(name, default)
end

-- }}}

-- Headmate Init {{{
for headmate, hInfo in pairs(headmates) do
        hInfo.page   = action_wheel :newPage()
    if #hInfo.variants > 1 then

        hInfo.switch = hInfo.page	:newAction()
                                    :setItem("minecraft:lever")
                                    :setTitle(string.format("Switch to %s", hInfo.variants[hInfo.variant + 1][1]:gsub("^%l", string.upper)))
                                    :onLeftClick(function()
                                        hInfo.variant = hInfo.variant + 1 <= #hInfo.variants and hInfo.variant + 1 or 1
                                        hInfo.switch:setTitle(string.format("Switch to %s", hInfo.variants[hInfo.variant + 1 <= #hInfo.variants and hInfo.variant + 1 or 1][1]:gsub("^%l", string.upper)))
                                        pings.switch(headmate, hInfo.variant)
                                    end)
    end
    hInfo.page	:newAction()
                :setItem("minecraft:command_block")
                :setTitle("Toggleables")
                :onLeftClick(function()
                    action_wheel:setPage(togglePage)
                end)
            
    hInfo.action = switchWheel  :newAction()
                                :setItem(hInfo.icon)
                                :setTitle(hInfo.name)
                                :onLeftClick(function()
                                    if hInfo.action:isToggled() == false then
                                        for _, h in pairs(headmates) do
                                            h.action:setToggled(false)
                                        end
                                        hInfo.action:setToggled(true)
                                        pings.switch(headmate, hInfo.variant)
                                        action_wheel:setPage(hInfo.page)
                                    else
                                        action_wheel:setPage(hInfo.page)
                                    end
                                end)
end
headmates.emi.action:setToggled(true)
currentModel = { "Emi", 1 }

events.ENTITY_INIT:register(function()

    init = true

-- STUFFIES
    local emiTail = {
        models.emi.constant.ears.Body.Tail1,
        models.emi.constant.ears.Body.Tail1.Tail2
    }

    animations["emi.constant.ears"].raiseTail:play()

    squapi.ear(models.emi.constant.ears.head.Ears.LeftEar, models.emi.constant.ears.head.Ears.RightEar, true, 4000000, 0.4, nil, 0.3)
    squapi.smoothHead(models.emi.constant.ears.head, 1/4)
    squapi.tails(emiTail, nil, nil, nil, nil, nil, 1.5, nil, 3, nil, nil, nil, 5, 70)


    for _, v in ipairs(headmates.emi.variants) do
        local model = models.emi[v[1]] 
        local anim = animations["emi." .. v[1]]
        squapi.smoothHead(model.root.AboveWaist.head, 1/4)
        squapi.bewb(model.root.AboveWaist.Body.booba, true, 0.7)
        squapi.eye(model.root.AboveWaist.head.Eyes.Pupils.LeftPupil, 0.1, 1.1)
        squapi.eye(model.root.AboveWaist.head.Eyes.Pupils.RightPupil, 1.1, 0.1)
        squapi.blink(anim.blink)
    end

    switch(currentModel[1], currentModel[2], false)
    for k, _ in pairs(currentModel[3]) do
        toggle(k, true)
    end
end)
-- }}}


local tick_counter = 0
events.TICK:register(function()
    tick_counter = tick_counter + 1

    if tick_counter > 5 * 20 then -- 5 seconds
            pings.switch(currentModel[1], currentModel[2], false)
            tick_counter = 0
    end

    if player:getPose() == "CROUCHING" then
        squapi.wagStrength = 6
        animations["emi.constant.ears"].raiseTail:setSpeed(1)
    else
        squapi.wagStrength = 1
        animations["emi.constant.ears"].raiseTail:setSpeed(-1)
    end
end)

