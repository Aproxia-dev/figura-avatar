return function()
	nameplate.ENTITY:setPos(0, 0.3, 0)

	toggleables["Bunny"] = models.emily.witch.Body.Bunny

  disableOnSwitch = {
    models.emily.witch.Body.booba,
		models.emily.witch.Body.Bunny,
  }

  swOut = function()
	  vanilla_model.HELMET:setVisible(true)
  end
    

	makeTog(
		"Bunny",
		[[minecraft:player_head{SkullOwner:{Id:[I;1200811417,-813083452,-1179688126,-1665032625],Properties:{textures:[{Value:"e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmZjOTA4ODgxZDdhMWVjMjZlZjJiYmNhZTg0YmY4ZThhMWJhMmY3ZjUxNWZiODAxM2ZjMWNjMzMwNDNiMzEwOCJ9fX0="}]}}})]],
		true
	)

	vanilla_model.HELMET:setVisible(false)

	events.TICK:register(function()
		bunnyRot = player:getRot() * vec(-0.33, -1)
		models.emily.witch.Body.Bunny:setOffsetRot(bunnyRot.x, bunnyRot.y % 360 + player:getBodyYaw(), nil)
		
		if player:getPose() == "CROUCHING" then
			models.emily.witch.Body.Bunny:setRot(22.5, 0, 0)
		else
			models.emily.witch.Body.Bunny:setRot(0, 0, 0)
		end

		if player:getItem(5):getCount() > 0 then
			models.emily.witch.Body.booba:setVisible(false)
		else
			models.emily.witch.Body.booba:setVisible(true)
		end
	end, "emily_witch")
end
