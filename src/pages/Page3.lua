local composer = require("composer")

local scene = composer.newScene()

local button = require("src.components.button")

local images = {
    {filename = "src/assets/page3/Genomas.png", text = "Isso é o Genoma"},
    {filename = "src/assets/page3/Genes.png", text = "Isso é o Gene"}
}
local currentImageIndex = 1
local activeImage, overlayText

local function updateImage()
    -- Atualiza a imagem e o texto com base no índice atual
    activeImage.fill = {
        type = "image",
        filename = images[currentImageIndex].filename
    }
    overlayText.text = images[currentImageIndex].text
end

local function handleZoom(event)
    if event.phase == "began" then
        -- Inicia o zoom com dois toques
        display.getCurrentStage():setFocus(event.target, event.id)
        event.target.isZooming = true
        event.target.startScale = event.target.xScale
        event.target.startDistance = math.sqrt(
            (event.x - event.xStart) ^ 2 + (event.y - event.yStart) ^ 2
        )
    elseif event.phase == "moved" and event.target.isZooming then
        -- Calcula o novo nível de zoom
        local currentDistance = math.sqrt(
            (event.x - event.xStart) ^ 2 + (event.y - event.yStart) ^ 2
        )
        local scale = currentDistance / event.target.startDistance
        event.target.xScale = event.target.startScale * scale
        event.target.yScale = event.target.startScale * scale
    elseif event.phase == "ended" or event.phase == "cancelled" then
        -- Finaliza o zoom e verifica se deve mudar para a próxima imagem
        display.getCurrentStage():setFocus(nil, event.id)
        event.target.isZooming = false

        if event.target.xScale >= 2 then
            -- Troca a imagem e reseta o zoom
            currentImageIndex = currentImageIndex % #images + 1
            updateImage()
            event.target.xScale = 1
            event.target.yScale = 1
        end
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view
    
    local capa = display.newImageRect(sceneGroup, "src/assets/page3/Pg-03.png", 768, 1024)
    capa.x = display.contentCenterX
    capa.y = display.contentCenterY

    -- Botão de próximo
    local nextBtn = button.new(
        display.contentCenterX + 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-proximo.png",
        function()
            composer.gotoScene("src.pages.Page4", { effect = "slideLeft", time = 800 })
        end
    )
    sceneGroup:insert(nextBtn)
    
    -- Botão de voltar
    local backBtn = button.new(
        display.contentCenterX - 300,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-anterior.png",
        function()
            composer.gotoScene("src.pages.Page2", { effect = "slideRight", time = 800 })
        end
    )
    sceneGroup:insert(backBtn)

    -- Botão de áudio (caso necessário)
    local soundBtn = button.new(
        display.contentCenterX,
        display.contentCenterY + 480,
        "src/assets/controllers/Controle-audio.png",
        function()
            print("Audio button clicked!")
        end
    )
    sceneGroup:insert(soundBtn)

    -- Criação da imagem interativa
    activeImage = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY + 200, 320, 320) -- Ajustado para mais baixo
    activeImage.fill = {
        type = "image",
        filename = images[currentImageIndex].filename
    }
    activeImage:addEventListener("touch", handleZoom)

    -- Texto sobreposto
    overlayText = display.newText({
        parent = sceneGroup,
        text = images[currentImageIndex].text,
        x = display.contentCenterX,
        y = display.contentCenterY + 400, -- Ajustado para mais afastado
        font = native.systemFontBold,
        fontSize = 28,
        align = "center"
    })
    overlayText:setFillColor(1, 1, 1)
end

function scene:show(event)
    if event.phase == "did" then
        print("Scene shown!")
    end
end

function scene:hide(event)
    if event.phase == "will" then
        print("Scene hidden!")
    end
end

function scene:destroy(event)
    print("Scene destroyed!")
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
