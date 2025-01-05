function love.load()
    love.window.setMode(640, 480)
    -- Load images
    background      = love.graphics.newImage("assets/bg.png")
    CPUwinsImage    = love.graphics.newImage("assets/face.png")
    CPUlosesImage   = love.graphics.newImage("assets/sad_face.png")
    rockImage       = love.graphics.newImage("assets/sad_face.png")
    paperImage      = love.graphics.newImage("assets/sad_face.png")
    scissorsImage   = love.graphics.newImage("assets/sad_face.png")

    gameStatus  = 'waiting'



    -- Base position of the upper image
    posX = 0
    posY = 0

    -- Vibration intensity
    vibration = 2
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
    elseif love.keyboard.isDown('s') then
        buttonPressed = "D-PAD: down"
    elseif love.keyboard.isDown('d') then
        buttonPressed = "D-PAD: right"
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
        buttonPressed = ""  -- Reset if nothing is pressed
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1)  -- RGB for white (uncomment for background)
    -- Draw the background
    love.graphics.draw(background, 0, 0)
    -- Draw the upper image with vibration
    love.graphics.draw(CPUwinsImage, posX + offsetX, posY + offsetY)
    love.graphics.setColor(0, 0, 0, 1)  -- RGB for black (uncomment for text)
    love.graphics.print("Button pressed: " .. buttonPressed, 10, 10)  -- Show the pressed button
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
