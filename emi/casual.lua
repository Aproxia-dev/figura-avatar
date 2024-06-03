return function()
    local ret = {
        toggleables = {},
        disableOnSwitch = {
            models.emi.casual.root.LeftLeg.LShoe,
            models.emi.casual.root.RightLeg.RShoe,
            models.emi.casual.root.AboveWaist.Body.booba,
        },
        swOut = function() end
    }

    events.TICK:register(function()
        if player:getItem(3):getCount() > 0 then
            models.emi.casual.root.LeftLeg.LShoe:setVisible(false)
            models.emi.casual.root.RightLeg.RShoe:setVisible(false)
        else
            models.emi.casual.root.LeftLeg.LShoe:setVisible(true)
            models.emi.casual.root.RightLeg.RShoe:setVisible(true)
        end

        if player:getItem(5):getCount() > 0 then
            models.emi.casual.root.AboveWaist.Body.booba:setVisible(false)
        else
            models.emi.casual.root.AboveWaist.Body.booba:setVisible(true)
        end
    end, "emi_casual")

    return ret
end
