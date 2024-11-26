local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.button")

local audioHandle
local isPlaying = false

local backgroundMusic = audio.loadStream("src/assets/Sounds/Page2.mp3")

local shakeImage1, shakeImage2
local activeImage = 1 -- Controla qual imagem está ativa
local imageIndex = 1
local images = {
    "src/assets/page2/Mariposas.png",
    "src/assets/page2/Mariposas-cinzas.png"
}

local function toggleAudio()
    if isPlaying == true then
        audio.stop(audioHandle)    
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/Sounds/Page2.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
    end
end

local function changeImage()
    -- Define qual imagem será a visível e qual será a de fundo
    local frontImage = activeImage == 1 and shakeImage1 or shakeImage2
    local backImage = activeImage == 1 and shakeImage2 or shakeImage1

    -- Atualiza o índice para a próxima imagem
    imageIndex = imageIndex % #images + 1
    backImage.fill = {
        type = "image",
        filename = images[imageIndex]
    }

    -- Configura a imagem de fundo para estar visível, mas totalmente transparente
    backImage.alpha = 0

    -- Inicia o efeito de "crossfade"
    transition.to(frontImage, {
        time = 1000, -- Tempo da transição
        alpha = 0, -- Faz a imagem da frente desaparecer
    })
    transition.to(backImage, {
        time = 1000, -- Tempo da transição
        alpha = 1, -- Faz a imagem de trás aparecer
        onComplete = function()
            -- Atualiza a imagem ativa
            activeImage = activeImage == 1 and 2 or 1
        end
    })
end

shakeListener = function(event)
    if event.isShake then
        changeImage()
    end
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/page2/Pg-02.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY
    
    -- Botão de próximo
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page3", { effect = "slideLeft", time = 800 })
        end
    )
    sceneGroup:insert(nextBtn)
    
    -- Botão de voltar
    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Page1",{ effect = "slideRight", time = 800 })
        end
    )
    sceneGroup:insert(backBtn)

    -- Botão de áudio
    local soundBtn = button.new(
        display.contentCenterX + 0,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-audio.png",
        toggleAudio
    )
    sceneGroup:insert(soundBtn)

    -- Criação das imagens sobrepostas
    -- Ajuste a posição (x, y) para movê-las para baixo e para a esquerda
    local imageX = display.contentCenterX - 150 -- Mais para a esquerda
    local imageY = display.contentCenterY + 210 -- Mais para baixo

    shakeImage1 = display.newRect(sceneGroup, imageX, imageY, 350, 250)
    shakeImage1.fill = {
        type = "image",
        filename = images[1]
    }
    shakeImage1.alpha = 1 -- Começa como a imagem ativa

    shakeImage2 = display.newRect(sceneGroup, imageX, imageY, 350, 250)
    shakeImage2.alpha = 0 -- Começa como a imagem de fundo
end

function scene:show(event)
    if event.phase == "did" then
        -- Adicionar listener de shake
        Runtime:addEventListener("accelerometer", shakeListener)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        -- Remover listener de shake
        Runtime:removeEventListener("accelerometer", shakeListener)
        audio.stop()
        isPlaying = false
    end
end

function scene:destroy(event)
    Runtime:removeEventListener("accelerometer", shakeListener)
    audio.stop()
    audio.dispose(backgroundMusic)
    backgroundMusic = nil
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
