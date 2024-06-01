return function()
    local ret = {
        toggleables = {},
        disableOnSwitch = {
            models.emily.casual.root.LeftLeg.LShoe,
            models.emily.casual.root.RightLeg.RShoe,
            models.emily.casual.root.AboveWaist.Body.booba,
        },
        swOut = function() end
    }

    events.TICK:register(function()
        if player:getItem(3):getCount() > 0 then
            models.emily.casual.root.LeftLeg.LShoe:setVisible(false)
            models.emily.casual.root.RightLeg.RShoe:setVisible(false)
        else
            models.emily.casual.root.LeftLeg.LShoe:setVisible(true)
            models.emily.casual.root.RightLeg.RShoe:setVisible(true)
        end

        if player:getItem(5):getCount() > 0 then
            models.emily.casual.root.AboveWaist.Body.booba:setVisible(false)
        else
            models.emily.casual.root.AboveWaist.Body.booba:setVisible(true)
        end
    end, "emily_casual")

    return ret
end
