-- Fireworks screensaver animation
-- By L0laapk3, based on Rectar's Fireworks

local launchRate = 0.025

local fireworks = {}
local particles = {}
local fcolors = { 1, 2, 4, 8, 16, 32, 64, 512, 1024, 2048, 8192, 16384 }
local particleChars = { "#", "X", "+", "*", "." }

local starsChance = "+++xxx***.....,,,,,"
local stars = {}
local defaultString = ""
local w, h = term.getSize()
local QSIZE = 8
local speaker = peripheral.find("speaker")

local window = window.create(term.current(), 1, 1, w, h)
term.redirect(window)
term.setBackgroundColor(colors.black)

-- function generateStars()

for xQ = 1, w + QSIZE, QSIZE do
    for yQ = 1, h + QSIZE, QSIZE do
        local star = {}
        star.x = xQ + math.floor(math.random() * QSIZE)
        star.y = yQ + math.floor(math.random() * QSIZE)
        local charI = math.floor(#starsChance * math.random())
        star.char = starsChance:sub(charI, charI)
        local closeColors = charI <= math.random() * #starsChance
        star.color1 = closeColors and 0x1 or 0x80
        star.color2 = closeColors and 0x80 or 0x100
        star.blinkI = math.random()
        star.blinkIncr = .03 * math.random()
        star.blinkDecr = .2 * math.random()
        star.isBright = math.random() > .2

        stars[#stars + 1] = star
    end
end

local function drawStars()
    for i = 1, #stars do
        local star = stars[i]
        local color = star.isBright and star.color1 or star.color2
        star.blinkI = star.isBright and (star.blinkI - star.blinkDecr) or (star.blinkI + star.blinkIncr)
        if star.isBright and star.blinkI <= 0 then
            star.isBright = false
        elseif not star.isBright and star.blinkI >= 1 then
            star.isBright = true
        end
        term.setTextColor(color)
        term.setCursorPos(star.x, star.y)
        term.write(star.char)
    end
end

local IFirework = {
    x = w,
    y = h,
    vx = 0,
    vy = 0
}

local function launchFirework()
    local firework = {}
    setmetatable(firework, { __index = IFirework })
    firework.x = math.random() * w
    firework.vx = (math.random() - 0.5) * .7
    firework.vy = -((math.random()) + 3)
    table.insert(fireworks, firework)
end

local function drawFireworks()
    for i = 1, #fireworks do
        local firework = fireworks[i]
        local dx = math.floor(firework.x)
        local dy = math.floor(firework.y)
        term.setCursorPos(dx, dy)
        term.setTextColor(colors.white)
        term.write((-firework.vx * 1.5) > -firework.vy and "\\" or (firework.vx * 1.5) > -firework.vy and "/" or "|")
    end
end

local function spawnParticles(x, y)
    local particleColor = fcolors[math.floor(math.random() * #fcolors) + 1]
    local numPart = math.floor(math.random() * 90) + 20
    local commonPartSpeed = .70 * math.random()
    for i = 1, numPart do
        local z = math.random()
        local angle = i * 6.283185 / numPart
        local particle = {
            x = x,
            y = y,
            c = particleColor,
            vx = math.sin(angle) * 3 * z * commonPartSpeed,
            vy = math.cos(angle) * 2 * z * commonPartSpeed,
            life = 1,
            lifeSpeed = .2 + .8 * math.random()
        }
        table.insert(particles, particle)
    end
end

local function playFireworkSound()
    if not speaker then return end
    local sound = math.random() > .5 and "blast" or "large_blast"
    -- make a speedVariance between 0.9 to 1.1
    local speedVariance = math.random() * .2 + .9
    speaker.playSound("minecraft:entity.firework_rocket." .. sound,1,speedVariance)
end

local function updateFireworks()
    local toRemove = {}
    for i = 1, #fireworks do
        local firework = fireworks[i]
        firework.x = firework.x + firework.vx
        firework.y = firework.y + firework.vy

        firework.vx = firework.vx * 1.1
        firework.vy = firework.vy * 0.9
        if firework.vy > -0.5 then
            spawnParticles(firework.x, firework.y)
            playFireworkSound()
            table.insert(toRemove, i)
        end
    end
    for i = 1, #toRemove do
        table.remove(fireworks, toRemove[i])
    end
end

local function drawParticles()
    for i = 1, #particles do
        local particle = particles[i]
        local dx = math.floor(particle.x)
        local dy = math.floor(particle.y)
        local pchar = particleChars[math.floor(particle.life)] or defaultString
        term.setTextColor(particle.c)
        term.setCursorPos(dx, dy)
        term.write(pchar)
    end
end

local function updateParticles()
    local toRemove = {}
    for i = 1, #particles do
        local particle = particles[i]
        particle.x = particle.x + particle.vx
        particle.y = particle.y + particle.vy

        particle.vx = particle.vx * .98
        particle.vy = particle.vy * .98 + 0.01

        particle.life = particle.life + particle.lifeSpeed * math.random()
        if particle.life >= 6 then
            table.insert(toRemove, i)
        end
    end
    for i = 1, #toRemove do
        table.remove(particles, toRemove[i])
    end
end

launchFirework()

local lrate = (1 - launchRate)
local clock = (os.clock()*100)
local function particleUpdater()
    local curTime = (os.clock()*100)
    if curTime - clock < 5 then
        return
    end
    clock = curTime
    window.setVisible(false)
    term.clear()
    if math.random() > lrate then
        launchFirework()
    end
    parallel.waitForAll(updateFireworks, updateParticles)
    parallel.waitForAll(drawStars, drawFireworks, drawParticles)
    window.setVisible(true)
end

local function eventHandler(ev)
    if ev[1] == "mouse_drag" or ev[1] == "mouse_up" or ev[1] == "mouse_click" or ev[1] == "monitor_touch" then
        local x, y = ev[3], ev[4]
        spawnParticles(x, y)
    elseif ev[1] == "key" and ev[2] == keys.q then
        term.clear()
        term.setCursorPos(1, 1)
        error("", 0)
    end
end

while true do
    local t = os.startTimer(0.05)
    local ev = { os.pullEvent() }
    parallel.waitForAll(function() eventHandler(ev) end, particleUpdater)
    os.cancelTimer(t)
end
