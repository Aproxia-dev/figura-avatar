return function()
    disableOnSwitch = {
        models.emily.casual.LeftLeg.LShoe,
        models.emily.casual.RightLeg.RShoe,
        models.emily.casual.Body.booba,
    }

    events.TICK:register(function()
        if player:getItem(3):getCount() > 0 then
          models.emily.casual.LeftLeg.LShoe:setVisible(false)
          models.emily.casual.RightLeg.RShoe:setVisible(false)
        else
          models.emily.casual.LeftLeg.LShoe:setVisible(true)
          models.emily.casual.RightLeg.RShoe:setVisible(true)
        end

        if player:getItem(5):getCount() > 0 then
          models.emily.casual.Body.booba:setVisible(false)
        else
          models.emily.casual.Body.booba:setVisible(true)
        end
    end, "emily_casual")
end