vanilla_model.PLAYER:setVisible(false)

local squapi = require('scripts.SquAPI')

headmates = {
	emily = {
		name        = "Emily",
		pronouns    = "§bshe§f/§dher",
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
local currentModel

function pings.switch(name, variant, animate)
  currentModel = {name, variant}
 	 
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

-- STUFFIES
	local emiTail = {
		models.emily.constant.ears.Body.Tail1,
		models.emily.constant.ears.Body.Tail1.Tail2
	}

	squapi.ear(models.emily.constant.ears.head.Ears.LeftEar, models.emily.constant.ears.head.Ears.RightEar, true, 4000000, 0.7, nil, 0.3)
	squapi.smoothHead(models.emily.constant.ears.head, 1/4)
	squapi.tails(emiTail, nil, nil, nil, nil, nil, 1.5, nil, 3, nil, nil, nil, 5, 70)


	for _, v in ipairs(headmates.emily.variants) do
		local model = models.emily[v[1]] 
		local anim = animations["emily." .. v[1]]
		squapi.smoothHead(model.head, 1/4)
		squapi.bewb(model.Body.booba, true, 0.7)
		squapi.eye(model.head.Eyes.LeftEye, 0.1, 1.1)
		squapi.eye(model.head.Eyes.RightEye, 1.1, 0.1)
		squapi.blink(anim.blink)
	end

	-- Final Init
	headmates.emily.action:setToggled(true)
	pings.switch("emily", headmates.emily.variants[1], false)
end)
-- }}}

local players

events.TICK:register(function()
	if player:getPose() == "CROUCHING" then
		squapi.wagStrength = 4
	else
		squapi.wagStrength = 1
	end
  if world:getPlayers() == players then
    players = world:getPlayers()
    pings.switch(currentModel[1], currentModel[2], false)
  end
end)

