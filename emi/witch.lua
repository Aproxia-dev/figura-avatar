return function()
    local ret = { 
        toggleables = {
			{
            	name = "Bunny",
				part = models.emi.witch.root.AboveWaist.Body.Bunny,
				icon = [[minecraft:player_head{SkullOwner:{Id:[I;1200811417,-813083452,-1179688126,-1665032625],Properties:{textures:[{Value:"e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmZjOTA4ODgxZDdhMWVjMjZlZjJiYmNhZTg0YmY4ZThhMWJhMmY3ZjUxNWZiODAxM2ZjMWNjMzMwNDNiMzEwOCJ9fX0="}]}}})]],
				default = true,
			}
		},
		emotes = {
			{
				name = "Club Penguin Dance",
				anim = "club_penguin",
				icon = "minecraft:packed_ice",
			},
			{
				name = "Rock and Stone",
				anim = "rock_and_stone",
				icon = "minecraft:iron_pickaxe",
			},
		},
        disableOnSwitch = {
            models.emi.witch.root.AboveWaist.Body.booba,
            models.emi.witch.root.AboveWaist.Body.Bunny,
        },
        swOut = function()
            vanilla_model.HELMET:setVisible(true)
            animations["emi.constant.ears"].witch:stop()
        end
    }

    nameplate.ENTITY:setPos(0, 0.3, 0)
    animations["emi.constant.ears"].witch:play()

    -- vanilla_model.HELMET:setVisible(false)

    events.TICK:register(function()
        bunnyRot = player:getRot() * vec(-0.33, -1)
        models.emi.witch.root.AboveWaist.Body.Bunny:setOffsetRot(bunnyRot.x, bunnyRot.y % 360 + player:getBodyYaw(), nil)
        
        if player:getPose() == "CROUCHING" then
            models.emi.witch.root.AboveWaist.Body.Bunny:setRot(22.5, 0, 0)
        else
            models.emi.witch.root.AboveWaist.Body.Bunny:setRot(0, 0, 0)
        end

        if player:getItem(5):getCount() > 0 then
            models.emi.witch.root.AboveWaist.Body.booba:setVisible(false)
        else
            models.emi.witch.root.AboveWaist.Body.booba:setVisible(true)
        end
    end, "emi_witch")

    return ret
end
