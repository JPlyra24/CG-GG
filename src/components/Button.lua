local button = {}

function button.new(x,y,image,onTapFunction)
    local buttonGroup = display.newGroup()

    
    local buttonImage = display.newImageRect(buttonGroup,image, 150, 39)

    buttonImage.x = x  
    buttonImage.y = y 

    function buttonImage:tap()
        if onTapFunction then
            onTapFunction()
        end
    end
    buttonImage:addEventListener("tap", buttonImage)

    return buttonGroup
end

return button