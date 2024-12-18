local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.Button")

local audioHandle
local isPlaying = false

local backgroundMusic = audio.loadStream("src/assets/Sounds/Capa.mp3")

local function toggleAudio()
    if isPlaying == true then
        audio.stop(audioHandle)    
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/Sounds/Capa.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
        
    end
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/Capa/Capa.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY
    
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page1", { effect = "slideLeft", time = 800 })
            
        end
    )
    sceneGroup:insert(nextBtn)

    local soundBtn = button.new(
        display.contentCenterX + 0,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-audio.png",
        toggleAudio
    )
    sceneGroup:insert(soundBtn)
    
   
end

function scene:destroy(e)
    audio.stop()
    audio.dispose(backgroundMusic)
    backgroundMusic = nil
end

function scene:hide(event)
    if event.phase == "will" then
        audio.stop() 
        isPlaying = false 
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)

return scene