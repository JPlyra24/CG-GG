local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.Button")

local audioHandle
local isPlaying = false
local greenBall -- Variável para a bola verde
local isBallMoving = false -- Controle para evitar múltiplos lançamentos

local backgroundMusic = audio.loadStream("src/assets/Sounds/Page5.mp3")

local function toggleAudio()
    if isPlaying == true then
        audio.stop(audioHandle)    
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/Sounds/Page5.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
    end
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/page5/Pg-05.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY
    
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Contra-Capa", { effect = "slideLeft", time = 800 })
        end
    )

    sceneGroup:insert(nextBtn)
    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Page4", { effect = "slideRight", time = 800 })
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
    
    -- Imagem da placa de radiação
    local radiationSign = display.newImageRect(sceneGroup, "src/assets/page5/Radiacao.png", 100, 100)
    radiationSign.x = display.contentCenterX - 200
    radiationSign.y = display.contentCenterY + 250

    -- Imagem da linha genética
    local geneticLine = display.newImageRect(sceneGroup, "src/assets/page5/Fita1.png", 200, 100)
    geneticLine.x = display.contentCenterX + 200
    geneticLine.y = display.contentCenterY + 250

    -- Variável para armazenar a linha destruída
    local destroyedLinePath = "src/assets/page5/Fita-Delecao.png"

    -- Função para lançar a bola verde
    local function launchGreenBall(event)
        if event.phase == "began" and not isBallMoving then
            isBallMoving = true

            -- Criar a bola verde
            greenBall = display.newCircle(sceneGroup, radiationSign.x, radiationSign.y, 20)
            greenBall:setFillColor(0, 1, 0) -- Verde

            -- Mover a bola em direção à linha genética
            transition.to(greenBall, {
                time = 1000,
                x = geneticLine.x,
                y = geneticLine.y,
                onComplete = function()
                    -- Substituir a imagem da linha genética pela destruída
                    geneticLine:removeSelf()
                    geneticLine = display.newImageRect(sceneGroup, destroyedLinePath, 200, 100)
                    geneticLine.x = display.contentCenterX + 200
                    geneticLine.y = display.contentCenterY + 250

                    -- Remover a bola verde
                    greenBall:removeSelf()
                    greenBall = nil
                    isBallMoving = false
                end
            })
        end
    end

    -- Adicionar evento de toque à placa de radiação
    radiationSign:addEventListener("touch", launchGreenBall)
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