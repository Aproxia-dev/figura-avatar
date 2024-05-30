return function()
	local ret = {
		toggleables = {},
		disableOnSwitch = {
			models.emily.engineer.root.AboveWaist.Body.booba,
		},
		swOut = function() end
	}
	events.TICK:register(function()
		if player:getItem(5):getCount() > 0 then
			models.emily.engineer.root.AboveWaist.Body.booba:setVisible(false)
		else
			models.emily.engineer.root.AboveWaist.Body.booba:setVisible(true)
		end
	end, "emily_engineer")
	
	return ret
end
