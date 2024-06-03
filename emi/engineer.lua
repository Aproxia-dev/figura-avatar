return function()
    local ret = {
        toggleables = {},
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
            models.emi.engineer.root.AboveWaist.Body.booba,
        },
        swOut = function() end
    }
    events.TICK:register(function()
        if player:getItem(5):getCount() > 0 then
            models.emi.engineer.root.AboveWaist.Body.booba:setVisible(false)
        else
            models.emi.engineer.root.AboveWaist.Body.booba:setVisible(true)
        end
    end, "emi_engineer")
    
    return ret
end
