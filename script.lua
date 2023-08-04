vanilla_model.INNER_LAYER:setVisible(false)
vanilla_model.OUTER_LAYER:setVisible(false)  

headmates = {
	["emily"] = {
		["name"]        = "Emily",
		["pronouns"]    = "§bshe§f/§dher",
		["variant"]     = 1,
		["variants"]    = { { "casual", ":fox:"}, { "witch", ":witch:" }, { "engineer", ":zap:" } },
		["icon"]        = "minecraft:pink_tulip",
	},
	["chris"] = {
		["name"]        = "Chris",
		["pronouns"]    = "§3he§f/§8they",
		["variant"]     = 1,
		["variants"]    = { { "hoodie", nil }, { "coat", nil } },
		["icon"]        = "minecraft:echo_shard",
	},
	["ash"] = {
		["name"]        = "ash.",
		["pronouns"]    = "§8they§f/§4xe",
		["variant"]     = 1,
		["variants"]    = { { "emo", nil } },
		["icon"]        = "minecraft:nether_wart",
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

function pings.toggle(model, bool)
	toggleables[model]:setVisible(bool)
end

swOut = function() end
disableOnSwitch = {}
toggleables = {}

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

-- Switch Function {{{
function pings.switch(name, variant)
	
	-- Effect
	particles:removeParticles()
    sounds:playSound("minecraft:block.lava.extinguish", player:getPos())
	for i = 0, 64, 1 do
		particles:newParticle("minecraft:cloud", player:getPos() + vec(math.random(-1, 1), math.random(0, 2), math.random(-1, 1)),
														vec((math.random() - 0.5) * 0.2, math.random() * 0.2, (math.random() - 0.5) * 0.2)):setPhysics(false):setScale(3)
	end
	
	-- Reset
  swOut()
	for n, h in pairs(headmates) do
		models[n]:setVisible(false)
		events.TICK:remove(n)
		if models[n].constant then
			models[n].constant:setVisible(false)
		end
		for _, var in pairs(h.variants) do
			-- log(n .. "_" .. var[1])
			events.TICK:remove(n .. "_" .. var[1])
			models[n][var[1]]:setVisible(false)
		end
	end

	-- Change Nameplate
	nameplate.ENTITY:setPos(0, 0, 0)
	local varIcon = headmates[name].variants[headmates[name].variant][2]
	if  varIcon == nil then
		nameplate.ALL:setText(headmates[name].name)
		nameplate.ENTITY:setText([[
			[{"text": "\n"},
			 {"text": "]] .. headmates[name].name .. [[ ${badges}" },
			 {"text": "\n§7(]] .. headmates[name].pronouns .. [[§7)"}]
		]])
	else
		nameplate.LIST:setText(headmates[name].name .. " " .. varIcon)
		nameplate.CHAT:setText(headmates[name].name)
		nameplate.ENTITY:setText([[
			[{"text": "\n"},
			 {"text": "]] .. varIcon .. " " .. headmates[name].name .. [[ ${badges}" },
			 {"text": "\n§7(]] .. headmates[name].pronouns .. [[§7)"}]
		]])
	end

	-- Show chosen model
	models[name]:setVisible(true)
	models[name][variant[1]]:setVisible(true)
	if models[name].constant then
		models[name].constant:setVisible(true)
	end

	-- Reset toggleables and import scripts
	for _, part in pairs(disableOnSwitch) do
		part:setVisible(false)
	end
	togglePage = action_wheel:newPage()
	disableOnSwitch = {}
	toggleables = {}
	pcall(function() require(name .. "." .. variant[1])() end)
end
-- }}}

-- Headmate Init {{{
events.ENTITY_INIT:register(function()
	for headmate, hInfo in pairs(headmates) do
		hInfo.page   = action_wheel :newPage()
    if #hInfo.variants > 1 then
	
		  hInfo.switch = hInfo.page   :newAction()
		  							:setItem("minecraft:lever")
		  							:setTitle(string.format("Switch to %s", hInfo.variants[hInfo.variant + 1][1]:gsub("^%l", string.upper)))
		  							:onLeftClick(function()
		  								hInfo.variant = hInfo.variant + 1 <= #hInfo.variants and hInfo.variant + 1 or 1
		  								hInfo.switch:setTitle(string.format("Switch to %s", hInfo.variants[hInfo.variant + 1 <= #hInfo.variants and hInfo.variant + 1 or 1][1]:gsub("^%l", string.upper)))
		  								pings.switch(headmate, hInfo.variants[hInfo.variant])
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
											pings.switch(headmate, hInfo.variants[hInfo.variant])
											action_wheel:setPage(hInfo.page)
										else
											action_wheel:setPage(hInfo.page)
										end
									end)
	end
-- }}}

-- Eyes {{{

	local blinkLength = 3
	local blinkMinDelay = 80
	local blinkMaxDelay = 100
	local eyeHeight = 2
	
	local blinking = true
	local isBlinking = false
	local blinkFrame = 0
	local blinkTick = 0
	
	events.TICK:register(function()
	
		blinkTick = blinkTick + 1
	
		if blinking then
			if isBlinking then
				if blinkFrame >= blinkLength then
					isBlinking = false
					blinkTick = 0
					blinkFrame = 0
				else
					blinkFrame = blinkFrame + 1
				end
			elseif (blinkTick >= blinkMinDelay and math.ceil(math.random(blinkMaxDelay - blinkMinDelay)) == blinkMaxDelay - blinkMinDelay)
							or blinkTick >= blinkMaxDelay then
				isBlinking = true
			end
		end
	end)
	
	events.TICK:register(function()
		if player:getPose() == "SLEEPING" then
			blinking = false
			if blinkFrame <= (blinkLength / 2) then
				blinkFrame = blinkFrame + 1
			end
		else 
			blinking = true
		end
	end)
	
	events.RENDER:register(function(delta)
		local lidPos
		local blinkPos = blinkFrame + delta
		local blinkHL = blinkLength / 2
		
		if isBlinking then
			lidPos = math.clamp(math.abs(blinkPos - blinkHL) - blinkHL, -blinkHL, 0) / blinkHL * eyeHeight
		elseif player:getPose() == "SLEEPING" then
			lidPos = math.clamp(-blinkPos, -blinkHL, 0) / blinkHL * eyeHeight
		else
			lidPos = 0
		end
	
		for headmate, i in pairs(headmates) do
			for _, variant in pairs(i.variants) do
				models[headmate][variant[1]].Head.eyelids:setPos(0, lidPos)
			end
		end
	end)

-- }}}

-- Ears & Tail {{{
	getVelocity = require("scripts.velocity")
	ears        = require("scripts.ears")(models.emily.constant.ears.Head.Ears.LeftEar, models.emily.constant.ears.Head.Ears.RightEar)
	tail        = require("scripts.tail")(models.emily.constant.ears.Body.Tail1)

	ears.config = {
		default_angle = -5,
		sneak_angle = 0,
	}

	tail.config = {
		swim_x_limit = 20,
	}
	events.TICK:register(function()
		local pos  = player:getPos()
		local pose = player:getPose()
		if player:getVehicle() then
					pose = "SIT"
			end
		local vel, body_vel, rot_vel, head_vel = getVelocity()

		ears.tick(rot_vel, head_vel)
		tail.tick(pos, pose, vel, body_vel)
	end)

	events.RENDER:register(function(delta)
		ears.render(delta)
		tail.render(delta)
	end)
-- }}}

-- Final Init
headmates.emily.action:setToggled(true)
pings.switch("emily", headmates.emily.variants[1])
end)
