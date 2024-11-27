local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.Button")

local audioHandle
local isPlaying = false
local movementTimer
local resultImage 
local isStopped = false 


local backgroundMusic = audio.loadStream("src/assets/Sounds/Page4.mp3")

local function toggleAudio()
    if isPlaying == true then
        audio.stop(audioHandle)    
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/Sounds/Page4.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
        
    end
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/page4/Pg-04.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY
    
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page5", { effect = "slideLeft", time = 800 })
            
        end
    )

    sceneGroup:insert(nextBtn)
    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Page3",{ effect = "slideRight", time = 800 })
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
    
    local square = display.newRect(sceneGroup, display.contentCenterX - 130, display.contentCenterY + 250, 450, 300)
    square:setFillColor(0, 0, 0, 0) -- Transparente (R=0, G=0, B=0, Alpha=0)
    square.strokeWidth = 4 -- Define a espessura da borda
    square:setStrokeColor(0, 0, 0)

    -- Bola amarela maior com "XX"
    local bigBall = display.newCircle(sceneGroup, square.x - 160, square.y - 80, 45)
    bigBall:setFillColor(1, 1, 0) -- Cor amarela
    local bigBallText = display.newText(sceneGroup, "X", bigBall.x, bigBall.y, native.systemFontBold, 24)
    bigBallText:setFillColor(0, 0, 0) -- Cor preta

     -- Imagem branca menor com "XY"
     local smallBall1 = display.newImageRect(sceneGroup, "src/assets/page4/XY.png", 60, 60)
     smallBall1.x = square.x - 70
     smallBall1.y = square.y + 50
 
     -- Imagem branca menor com "XX"
     local smallBall2 = display.newImageRect(sceneGroup, "src/assets/page4/XX.png", 60, 60)
     smallBall2.x = square.x + 70
     smallBall2.y = square.y + 50

   

    -- Função para verificar colisão
    local function checkCollision(ball, imagePath)
        if isStopped then return end 
        local dx = ball.x - bigBall.x
        local dy = ball.y - bigBall.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance <= ball.width / 2 + bigBall.width / 2 then
            if resultImage == nil then
                resultImage = display.newImageRect(sceneGroup, imagePath, 150, 200)
                resultImage.x = square.x + 350
                resultImage.y = square.y
                isStopped = true -- Para o movimento
                timer.cancel(movementTimer)
            end
        end
    end

    -- Função para movimentar as bolas brancas aleatoriamente dentro do quadrado
    local function moveBalls()
        if isStopped then return end
        local function moveBall(ball, label)
            local minX = square.x - square.width / 2 + ball.width / 2
            local maxX = square.x + square.width / 2 - ball.width / 2
            local minY = square.y - square.height / 2 + ball.height / 2
            local maxY = square.y + square.height / 2 - ball.height / 2

            transition.to(ball, {
                time = 500,
                x = math.random(minX, maxX),
                y = math.random(minY, maxY),
                onComplete = function()
                    checkCollision(ball, label)
                    if not isStopped then
                        moveBall(ball, label)
                    end
                end
            })
        end

        moveBall(smallBall1, "src/assets/page4/Menino.png")
        moveBall(smallBall2, "src/assets/page4/Menina.png")
    end

    -- Evento de toque na bola amarela
    local function onBigBallTouch(event)
        if event.phase == "began" then
            if not movementTimer then
                movementTimer = timer.performWithDelay(500, moveBalls, 0)
            end
        end
        return true
    end

    bigBall:addEventListener("touch", onBigBallTouch)
   
end

function scene:destroy(e)
    audio.stop()
    audio.dispose(backgroundMusic)
    backgroundMusic = nil
    if movementTimer then
        timer.cancel(movementTimer)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        audio.stop() 
        isPlaying = false 
         if movementTimer then
            timer.cancel(movementTimer)
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)

return scene