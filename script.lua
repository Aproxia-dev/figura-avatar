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

-- Switch Function {{{
local currentModel

local modelInfo = {
    toggleables = {},
    disableOnSwitch = {},
    swOut = function() end,
}

function updateNameplate(name, variant)
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

pings.updateNameplate = updateNameplate

-- Toggle Function {{{

function toggle(index, bool)
    if bool then
        currentModel[3][index] = true
    else
        currentModel[3][index] = nil
    end
    local part = modelInfo.toggleables[index].part
    if init then
        part:setVisible(bool)
    end
end

pings.toggle = toggle

-- }}}

-- Emote Function {{{

pings.playAnim = function(index)
    local variantName = table.concat({currentModel[1], headmates[currentModel[1]].variants[currentModel[2]][1]}, ".")
    local animation = modelInfo.emotes[index].anim
    for _, v in pairs(models[currentModel[1]]["constant"]:getChildren()) do
        if animations[table.concat({currentModel[1], "constant", v:getName()}, ".")][animation] then
            animations[table.concat({currentModel[1], "constant", v:getName()}, ".")][animation]:restart()
        end
    end
    animations[variantName][animation]:restart()
end

-- }}}

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

        -- Reset toggleables
        for _, part in pairs(modelInfo.disableOnSwitch) do
            part:setVisible(false)
        end


        -- Import scripts
        local modelScript
        modelScript, modelInfo = pcall(function() return require(name .. "." .. variantName)() end)
        if modelScript == false or modelInfo == nil then
            modelInfo = {
                toggleables = {},
                emotes = {},
                disableOnSwitch = {},
                swOut = function() end,
            }
        end

        -- Import toggleables and emotes
        togglePage = action_wheel:newPage()
        for k, v in pairs(modelInfo.toggleables) do
            local toggleAction = togglePage	:newAction()
                                            :setItem(v.icon)
                                            :setTitle("Enable " .. v.name)
                                            :setToggleTitle("Disable " .. v.name)
                                            :setToggled(v.default)
            toggleAction:onLeftClick(function()
                toggleAction:setToggled(not toggleAction:isToggled())
                pings.toggle(k, toggleAction:isToggled())
            end)

            pings.toggle(k, default)
        end
        togglePage  :newAction()
                    :setItem("minecraft:arrow")
                    :setTitle("Back")
                    :onLeftClick(function()
                        action_wheel:setPage(headmates[name].page)
                    end)


        emotePage = action_wheel:newPage()
        for k, v in pairs(modelInfo.emotes) do
            local emoteAction = emotePage	:newAction()
                                            :setItem(v.icon)
                                            :setTitle(v.name)
            emoteAction :onLeftClick(function()
                pings.playAnim(k)
            end)
        end
        emotePage   :newAction()
                    :setItem("minecraft:arrow")
                    :setTitle("Back")
                    :onLeftClick(function()
                        action_wheel:setPage(headmates[name].page)
                    end)
    end

    updateNameplate(name, variant)
end

pings.switch = switch
-- }}}

-- Headmate Init {{{

local cycle = function(index, steps, len)
    return ((index - 1 + steps) % len + len) % len + 1 
end

local makeSwitchText = function(meta)
    return string.format(
        "Switch Variant\n§7LMB - %s, RMB - %s",
        meta.variants[cycle(meta.variant,  1, #meta.variants)][1]:gsub("^%l", string.upper),
        meta.variants[cycle(meta.variant, -1, #meta.variants)][1]:gsub("^%l", string.upper)
    )
end

for headmate, hInfo in pairs(headmates) do
        hInfo.page   = action_wheel :newPage()
    if #hInfo.variants > 1 then

        hInfo.switch = hInfo.page	:newAction()
                                    :setItem("minecraft:lever")
                                    :setTitle(makeSwitchText(hInfo))
                                    :onLeftClick(function()
                                        hInfo.variant = cycle(hInfo.variant,  1, #hInfo.variants)
                                        hInfo.switch:setTitle(makeSwitchText(hInfo))
                                        pings.switch(headmate, hInfo.variant)
                                    end)
                                    :onRightClick(function()
                                        hInfo.variant = cycle(hInfo.variant, -1, #hInfo.variants)
                                        hInfo.switch:setTitle(makeSwitchText(hInfo))
                                        pings.switch(headmate, hInfo.variant)
                                    end)
    end
    hInfo.page	:newAction()
                :setItem("minecraft:command_block")
                :setTitle("Toggleables")
                :onLeftClick(function()
                    action_wheel:setPage(togglePage)
                end)
    
    hInfo.page  :newAction()
                :setItem("player_head{SkullOwner:Aproxia}")
                :setTitle("Emotes")
                :onLeftClick(function()
                    action_wheel:setPage(emotePage)
                end)

    hInfo.page  :newAction()
                :setItem("minecraft:arrow")
                :setTitle("Back")
                :onLeftClick(function()
                    action_wheel:setPage(switchWheel)
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
currentModel = { "emi", 1 }

events.ENTITY_INIT:register(function()

    init = true

-- STUFFIES
    local emiTail = {
        models.emi.constant.ears.root.AboveWaist.Body.Tail1,
        models.emi.constant.ears.root.AboveWaist.Body.Tail1.Tail2
    }

    animations["emi.constant.ears"].raiseTail:play()

    squapi.ear(models.emi.constant.ears.root.AboveWaist.head.Ears.LeftEar, models.emi.constant.ears.root.AboveWaist.head.Ears.RightEar, true, 4000000, 0.4, nil, 0.3)
    squapi.smoothHead(models.emi.constant.ears.root.AboveWaist.head, 1/4)
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
            pings.updateNameplate(currentModel[1], currentModel[2])
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

