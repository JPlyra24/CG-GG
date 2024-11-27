local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.Button")

local audioHandle
local isPlaying = false

local backgroundMusic = audio.loadStream("src/assets/Sounds/Page1.mp3")

local function toggleAudio()
    if isPlaying == true then
        audio.stop(audioHandle)    
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/Sounds/Page1.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
        
    end
end

local function onDrop(draggedImage, targetImage, changeFunction)
    if math.abs(draggedImage.x - targetImage.x) < 50 and math.abs(draggedImage.y - targetImage.y) < 50 then
        changeFunction()
    end
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/page1/Pg-01.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY
    
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page2", { effect = "slideLeft", time = 800 })
            
        end
    )

    sceneGroup:insert(nextBtn)
    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Capa",{ effect = "slideRight", time = 800 })
        end
    )
    sceneGroup:insert(backBtn)

    local soundBtn = button.new(
        display.contentCenterX + 0,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-audio.png",
        toggleAudio
    )
    sceneGroup:insert(soundBtn)

    
    local headBase = display.newImageRect(sceneGroup, "src/assets/page1/Mascara-mulher.png", 200, 200)
    headBase.x = display.contentCenterX - 200
    headBase.y = display.contentCenterY + 270

    
    local hairOverlay = display.newRect(sceneGroup, headBase.x, headBase.y, 200, 200)
    hairOverlay:setFillColor(0, 0, 0, 0) 
    local skinOverlay = display.newRect(sceneGroup, headBase.x, headBase.y, 200, 200)
    skinOverlay:setFillColor(0, 0, 0, 0)

    
    local dnaBaseTop = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Cima.png", 100, 100)
    dnaBaseTop.x = display.contentCenterX - 50
    dnaBaseTop.y = display.contentCenterY + 220

    local dnaBaseBottom = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Baixo.png", 100, 100)
    dnaBaseBottom.x = display.contentCenterX - 50
    dnaBaseBottom.y = display.contentCenterY + 320

    local dnaLightSkin = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Pele-clara.png", 100, 100)
    dnaLightSkin.x = display.contentCenterX + 100
    dnaLightSkin.y = display.contentCenterY + 320

    local dnaDarkSkin = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Pele-escura.png", 100, 100)
    dnaDarkSkin.x = display.contentCenterX + 200
    dnaDarkSkin.y = display.contentCenterY + 320
    
    local dnaBlondeHair = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Cabelo-Claro.png", 100, 100)
    dnaBlondeHair.x = display.contentCenterX + 100
    dnaBlondeHair.y = display.contentCenterY + 220

    local dnaDarkHair = display.newImageRect(sceneGroup, "src/assets/page1/DNA-Cabelo-escuro.png", 100, 100)
    dnaDarkHair.x = display.contentCenterX + 200
    dnaDarkHair.y = display.contentCenterY + 220


    -- Funções para alterar sobreposições
    local function setBlondeHair()
        hairOverlay.fill = { type = "image", filename = "src/assets/page1/Cabelo-claro.png" }
    end

    local function setDarkHair()
        hairOverlay.fill = { type = "image", filename = "src/assets/page1/Cabelo-escuro.png" }
    end

    local function setLightSkin()
        skinOverlay.fill = { type = "image", filename = "src/assets/page1/pele-clara.png" }
    end

    local function setDarkSkin()
        skinOverlay.fill = { type = "image", filename = "src/assets/page1/pele-escura.png" }
    end

    -- Função genérica de drag-and-drop
    local function makeDraggable(image, target, onDropFunction)
        image:addEventListener("touch", function(event)
            if event.phase == "began" then
                display.getCurrentStage():setFocus(image)
                image.isFocus = true
                image.startX = image.x
                image.startY = image.y
            elseif event.phase == "moved" and image.isFocus then
                image.x = event.x
                image.y = event.y
            elseif event.phase == "ended" or event.phase == "cancelled" then
                if image.isFocus then
                    -- Verifica se foi solto próximo ao alvo
                    if math.abs(image.x - target.x) < 50 and math.abs(image.y - target.y) < 50 then
                        onDropFunction()
                    end
                    -- Retorna à posição inicial
                    image.x = image.startX
                    image.y = image.startY
                    display.getCurrentStage():setFocus(nil)
                    image.isFocus = false
                end
            end
            return true
        end)
    end

    
    makeDraggable(dnaBlondeHair, dnaBaseTop, setBlondeHair)
    makeDraggable(dnaDarkHair, dnaBaseTop, setDarkHair)
    makeDraggable(dnaLightSkin, dnaBaseBottom, setLightSkin)
    makeDraggable(dnaDarkSkin, dnaBaseBottom, setDarkSkin)
   
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