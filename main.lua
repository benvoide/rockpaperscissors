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
            gameStatus = 'result'
            scaleTimer = 0
            rotationAngle = 0 -- Resetear la rotación cuando se confirma
        end
    elseif gameStatus == 'result' then
        -- Actualizar el timer de escala solo si la animación no ha terminado
        if not isScalingDone then
            cpuScaleTimer = cpuScaleTimer + dt * cpuScaleSpeed
            if cpuScaleTimer >= math.pi then  -- Un ciclo completo
                isScalingDone = true
                cpuScaleTimer = math.pi
            end
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
    elseif gameStatus == 'result' then
        -- Calcular la escala con un solo pulso
        local cpuScale = 1 + math.sin(cpuScaleTimer) * 0.3  -- Oscila entre 0.7 y 1.3
        
        -- Draw CPU selection con punto de anclaje en el centro
        local cpuImages = {CPUrockImage, CPUpaperImage, CPUscissorsImage}
        local cpuImage = cpuImages[cpuSelection]
        local imageWidth = cpuImage:getWidth()
        local imageHeight = cpuImage:getHeight()
        
        love.graphics.draw(cpuImage, 
            imageWidth/2,    -- posición x centrada
            imageHeight/2,   -- posición y centrada
            0,              -- rotación
            cpuScale, cpuScale,  -- escala x, y
            imageWidth/2,   -- punto de anclaje x en el centro
            imageHeight/2)  -- punto de anclaje y en el centro
        
        -- Draw player selection (sin cambios)
        local playerImages = {rockImage, paperImage, scissorsImage}
        love.graphics.draw(playerImages[playerSelection], 0, 0)
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
