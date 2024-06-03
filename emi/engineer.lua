return function()
    local ret = {
        toggleables = {},
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
