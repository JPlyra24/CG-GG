system.activate("multitouch")

local composer = require("composer")
local scene = composer.newScene()

local button = require("src.components.Button")

local images = {}
local currentIndex = 1

local audioHandle
local isPlaying = false

local texts = {}

local backgroundMusic = audio.loadStream("src/assets/sounds/page3.mp3")

local function toggleAudio()
    if isPlaying then
        audio.stop(audioHandle)
        backgroundMusic = nil
        isPlaying = false
    else
        backgroundMusic = audio.loadStream("src/assets/sounds/page3.mp3")
        audioHandle = audio.play(backgroundMusic)
        isPlaying = true
    end
end

local function changeImage(sceneGroup, index)
    for i = 1, #images do
        if i == index then
            if not images[i].isVisible or images[i].alpha < 1 then
                images[i].isVisible = true
                images[i].alpha = 0
                transition.to(images[i], {
                    alpha = 1,
                    time = 500,
                    onComplete = function()
                        images[i].isVisible = true
                    end
                })
            end
            texts[i].isVisible = true
        else
            if images[i].isVisible and images[i].alpha > 0 then
                transition.to(images[i], {
                    alpha = 0,
                    time = 500,
                    onComplete = function()
                        images[i].isVisible = false
                    end
                })
            end
            texts[i].isVisible = false
        end
    end
end

local finger1, finger2
local initialDistance
local isZooming = false

local function calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

local function onTouch(event)
    if event.phase == "began" then
        if not finger1 then
            finger1 = event
        elseif not finger2 then
            finger2 = event
            isZooming = true
            initialDistance = calculateDistance(finger1.x, finger1.y, finger2.x, finger2.y)
        end
    elseif event.phase == "moved" and isZooming then
        if finger1 and event.id == finger1.id then
            finger1 = event
        elseif finger2 and event.id == finger2.id then
            finger2 = event
        end

        if finger1 and finger2 then
            local currentDistance = calculateDistance(finger1.x, finger1.y, finger2.x, finger2.y)
            local scale = currentDistance / initialDistance

            if scale > 1.1 and currentIndex < #images then
                currentIndex = currentIndex + 1
                changeImage(scene.view, currentIndex)
            elseif scale < 0.9 and currentIndex > 1 then
                currentIndex = currentIndex - 1
                changeImage(scene.view, currentIndex)
            end

            initialDistance = currentDistance
        end
    elseif event.phase == "ended" or event.phase == "cancelled" then
        if finger1 and event.id == finger1.id then
            finger1 = nil
        elseif finger2 and event.id == finger2.id then
            finger2 = nil
        end

        if not finger1 or not finger2 then
            isZooming = false
        end
    end
    return true
end

local function resetScene()
    for i = 1, #images do
        images[i].isVisible = false
    end
    images[1].isVisible = true
end

function scene:create(event)
    local sceneGroup = self.view

    local capa = display.newImageRect(sceneGroup, "src/assets/page3/Pg-03.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY

    images[1] = display.newImageRect(sceneGroup, "src/assets/page3/Genomas.png", 350, 350)
    images[2] = display.newImageRect(sceneGroup, "src/assets/page3/Genes.png", 350, 350)

    texts[1] = display.newText({
        parent = sceneGroup,
        text = "Isso é o Genoma",
        x = display.contentCenterX,
        y = display.contentCenterY + 380,
        font = native.systemFontBold,
        fontSize = 36
    })
    texts[1]:setFillColor(1, 1, 1)

    texts[2] = display.newText({
        parent = sceneGroup,
        text = "Isso é o Gene",
        x = display.contentCenterX,
        y = display.contentCenterY + 380,
        font = native.systemFontBold,
        fontSize = 36
    })
    texts[2]:setFillColor(1, 1, 1)

    for i = 1, #images do
        images[i].x = display.contentCenterX
        images[i].y = display.contentCenterY + 210
        images[i].isVisible = false
        texts[i].isVisible = false
    end

    changeImage(sceneGroup, currentIndex)

    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page4", { effect = "slideLeft", time = 800 })
        end
    )
    sceneGroup:insert(nextBtn)

    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Page2", { effect = "slideRight", time = 800 })
        end
    )
    sceneGroup:insert(backBtn)

    local soundBtn = button.new(
        display.contentCenterX,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-audio.png",
        toggleAudio
    )
    sceneGroup:insert(soundBtn)

    Runtime:addEventListener("touch", onTouch)
end

function scene:destroy(event)
    Runtime:removeEventListener("touch", onTouch)
    audio.stop()
    audio.dispose(backgroundMusic)
    backgroundMusic = nil
end

function scene:show(event)
    if event.phase == "will" then
        resetScene()
    end
end

function scene:hide(event)
    if event.phase == "will" then
        audio.stop()
        isPlaying = false
    end
end

scene:addEventListener("show", scene)
scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
scene:addEventListener("hide", scene)

return scene