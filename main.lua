function love.load()
    love.window.setMode(640, 480)
    -- Load images
    background      = love.graphics.newImage("assets/bg.png")
    CPUwinsImage    = love.graphics.newImage("assets/face.png")
    CPUlosesImage   = love.graphics.newImage("assets/sad_face.png")

    rockImage       = love.graphics.newImage("assets/user_r.png")
    paperImage      = love.graphics.newImage("assets/user_p.png")
    scissorsImage   = love.graphics.newImage("assets/user_s.png")

    CPUrockImage       = love.graphics.newImage("assets/cpu_r.png")
    CPUpaperImage      = love.graphics.newImage("assets/cpu_p.png")
    CPUscissorsImage   = love.graphics.newImage("assets/cpu_s.png")

    tutorialImage   = love.graphics.newImage("assets/tutorial.png")
    hasShownTutorial = false;
    gameStatus  = 'selecting'



    -- Base position of the upper image
    posX = 0
    posY = 0

    -- Vibration intensity
    vibration = 2

    alphaFadeOut = 1  -- Inicializar alphaFadeOut
    tutorialStarted = false  -- Nueva variable para rastrear si el tutorial comenzó
    timer = 0  -- Agregar timer para la animación
    waveSpeed = 1.2  -- Nueva variable para controlar la velocidad de la onda
    waveAmplitude = 1.5  -- Nueva variable para controlar la amplitud
    rotationAngle = 0
    rotationSpeed = 2  -- Velocidad de la oscilación
    rotationAmplitude = 0.3  -- Amplitud de la oscilación (en radianes)

    -- Agregar variable para rastrear la opción seleccionada
    currentOption = 1  -- 1=rock, 2=paper, 3=scissors
    optionImages = {rockImage, paperImage, scissorsImage}

    -- Agregar variables de estado
    playerSelection = nil
    cpuSelection = nil

    -- Agregar variables para la animación de escalado
    scaleTimer = 0
    maxScaleTime = 0.3 -- duración de la animación en segundos
    maxScale = 1.3 -- escala máxima
    currentScale = 1

    -- Cargar y configurar la música
    bgMusic = love.audio.newSource("assets/music.ogg", "stream")
    bgMusic:setLooping(true)
    bgMusic:setVolume(0.3)  -- Ajustar volumen al 30%
    isMuted = false
    bgMusic:play()

    -- Agregar variables para la animación de escala del CPU
    cpuScaleTimer = 0
    cpuScaleSpeed = 5  -- Aumentado para una animación más rápida
    isScalingDone = false  -- Nueva variable para controlar si la animación terminó

    -- Agregar variables para el score
    playerScore = 0
    cpuScore = 0
    lastResult = ""  -- Para mostrar el resultado de la última jugada

    -- Agregar variable para el temporizador de resultado
    resultTimer = 0
    resultDisplayTime = 2 -- segundos que se muestra el resultado
end

-- Variable to store the pressed button
buttonPressed = ""

function love.update(dt)
    -- Calculate a random position within the vibration range
    offsetX = love.math.random(-vibration, vibration)
    offsetY = love.math.random(-vibration, vibration)

    -- Detect inputs and update the buttonPressed variable
    if love.keyboard.isDown('w') then
        buttonPressed = "D-PAD: up"
    elseif love.keyboard.isDown('a') then
        buttonPressed = "D-PAD: left"
        -- Rotar hacia la izquierda
        if not wasKeyPressed then
            currentOption = currentOption - 1
            if currentOption < 1 then currentOption = 3 end
            wasKeyPressed = true
        end
    elseif love.keyboard.isDown('s') then
        buttonPressed = "D-PAD: down"
    elseif love.keyboard.isDown('d') then
        buttonPressed = "D-PAD: right"
        -- Rotar hacia la derecha
        if not wasKeyPressed then
            currentOption = currentOption + 1
            if currentOption > 3 then currentOption = 1 end
            wasKeyPressed = true
        end
    elseif love.keyboard.isDown('space') then
        buttonPressed = "Button: X"
    elseif love.keyboard.isDown('b') then
        buttonPressed = "Button: Y"
    elseif love.keyboard.isDown('lshift') then
        buttonPressed = "Button: B"
    elseif love.keyboard.isDown('z') then
        buttonPressed = "Button: A"
    elseif love.keyboard.isDown('escape') then
        buttonPressed = "SEL"
    elseif love.keyboard.isDown('return') then
        buttonPressed = "START"
    else
        wasKeyPressed = false  -- Reiniciamos cuando no hay tecla presionada
        buttonPressed = ""
    end

    if buttonPressed ~= "" then
        tutorialStarted = true
    end

    timer = timer + dt * waveSpeed  -- Velocidad reducida
    
    if tutorialStarted then
        alphaFadeOut = alphaFadeOut - 1 * dt
        if alphaFadeOut < 0 then
            alphaFadeOut = 0
        end
    end

    if gameStatus == 'selecting' then
        -- Actualizar rotación solo durante la selección
        rotationAngle = math.sin(love.timer.getTime() * rotationSpeed) * rotationAmplitude
        
        if love.keyboard.isDown('z') then -- A button
            playerSelection = currentOption
            cpuSelection = love.math.random(1, 3)
            
            -- Determinar el ganador
            if playerSelection == cpuSelection then
                lastResult = "¡Empate!"
            elseif (playerSelection == 1 and cpuSelection == 3) or  -- Piedra vence Tijera
                   (playerSelection == 2 and cpuSelection == 1) or  -- Papel vence Piedra
                   (playerSelection == 3 and cpuSelection == 2) then -- Tijera vence Papel
                playerScore = playerScore + 1
                lastResult = "¡Ganaste!"
            else
                cpuScore = cpuScore + 1
                lastResult = "¡Perdiste!"
            end
            
            gameStatus = 'result'
            scaleTimer = 0
            rotationAngle = 0
        end
    elseif gameStatus == 'result' then
        -- Actualizar el temporizador
        resultTimer = resultTimer + dt
        
        -- Actualizar el timer de la animación
        cpuScaleTimer = cpuScaleTimer + dt
        
        -- Después del tiempo establecido, volver a la selección
        if resultTimer >= resultDisplayTime then
            gameStatus = 'selecting'
            resultTimer = 0
            playerSelection = nil
            cpuSelection = nil
            cpuScaleTimer = 0  -- Reiniciar también el timer de escala
        end
    end

    -- Manejar el muteo con Select (escape)
    if love.keyboard.isDown('escape') and not wasEscapePressed then
        isMuted = not isMuted
        if isMuted then
            bgMusic:setVolume(0)
        else
            bgMusic:setVolume(1)
        end
        wasEscapePressed = true
    elseif not love.keyboard.isDown('escape') then
        wasEscapePressed = false
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(background, 0, 0)

    if gameStatus == 'selecting' then
        -- Draw current player selection with rotation
        local currentImage = optionImages[currentOption]
        local imageWidth = currentImage:getWidth()
        local imageHeight = currentImage:getHeight()
        love.graphics.draw(currentImage, 
            imageWidth/2,
            imageHeight/2,
            rotationAngle,
            1, 1,
            imageWidth/2,
            imageHeight/2)
    elseif gameStatus == 'result' and playerSelection and cpuSelection then
        -- Calcular la escala con un solo pulso que dura 2 segundos
        local scaleAnimationDuration = 2 -- duración en segundos
        local cpuScale = 1
        
        if cpuScaleTimer < scaleAnimationDuration then
            cpuScale = 1 + math.sin(cpuScaleTimer * 5) * 0.3
        end
        
        -- Draw CPU selection
        local cpuImages = {CPUrockImage, CPUpaperImage, CPUscissorsImage}
        local cpuImage = cpuImages[cpuSelection]
        local imageWidth = cpuImage:getWidth()
        local imageHeight = cpuImage:getHeight()
        
        love.graphics.draw(cpuImage, 
            imageWidth/2,
            imageHeight/2,
            0,
            cpuScale, cpuScale,
            imageWidth/2,
            imageHeight/2)
        
        -- Draw player selection
        local playerImages = {rockImage, paperImage, scissorsImage}
        local playerImage = playerImages[playerSelection]
        local playerWidth = playerImage:getWidth()
        local playerHeight = playerImage:getHeight()
        
        love.graphics.draw(playerImage, 
            playerWidth/2,
            playerHeight/2,
            0,
            cpuScale, cpuScale,
            playerWidth/2,
            playerHeight/2)
    end

    love.graphics.setColor(1, 1, 1, 1)  -- RGB for white (uncomment for background)
    -- Draw the upper image with vibration
    --love.graphics.draw(CPUwinsImage, posX + offsetX, posY + offsetY)
    --love.graphics.setColor(0, 0, 0, 1)  -- RGB for black (uncomment for text)
    love.graphics.print("Button pressed: " .. buttonPressed, 10, 10)  -- Show the pressed button

    if hasShownTutorial == false then
        love.graphics.setColor(1, 1, 1, alphaFadeOut)
        local waveOffset = math.sin(timer) * waveAmplitude  -- Amplitud reducida
        love.graphics.draw(tutorialImage, 0, waveOffset)
    end

    -- Dibujar el score y el resultado
    love.graphics.setColor(0, 0, 0, 1)  -- Color negro para el texto
    love.graphics.print("Jugador: " .. playerScore, 10, 30)
    love.graphics.print("CPU: " .. cpuScore, 10, 50)
    
    if gameStatus == 'result' then
        -- Centrar el texto del resultado
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(lastResult)
        love.graphics.print(lastResult, 
            (love.graphics.getWidth() - textWidth) / 2, 
            love.graphics.getHeight() - 50)
    end
end

-- Key mapping for r36s - ArkOS 2.0 (08232024-1 AeUX)
-- D-PAD
-- : up    - w
-- : left  - a
-- : down  - s
-- : right - d
--
-- Buttons
-- : X - space
-- : Y - b
-- : B - lshift
-- : A - z
--
-- FN    - (nil)
-- SEL   - esc
-- START - return
--
-- POWER      - power
-- VOLUMEUP   - volumeup
-- VOLUMEDOWN - volumedown
--
-- L-Stick
-- : up    - up
-- : left  - left
-- : down  - down
-- : right - right
--
-- R-Stick
-- : up    - (mouse movement)
-- : left  - (mouse movement)
-- : down  - (mouse movement)
-- : right - (mouse movement)
--
-- Back
-- : L1 - l
-- : L2 - x
-- : R1 - r
-- : R2 - y
--
-- Extra (manually edit gptokeyb file on console, otherwise disabled)
-- : L3 - 1
-- : R3 - 2
