

function love.load()

  -- screen
  succes = love.graphics.setMode( 1280, 720 )

  -- game state
  state = "counting"

  -- graphics
  viewer = love.graphics.newImage("viewer.png")
  viewer_win = love.graphics.newImage("viewer_win.png")
  viewer_over = love.graphics.newImage("viewer_over.png")
  img = {
    crew = { love.graphics.newImage("crew.png"), 900, 400 },
    engineer = { love.graphics.newImage("engineer.png"), 1000, 410 },
    tactical = { love.graphics.newImage("tactical.png"), 1100, 420 },
    blast = { love.graphics.newImage("blastcol.png"), 457, 108 },
  }

  -- ui positioning
  uipos = { x = 205, y = 205 }

  -- ui sounds
  uisnd = {
    x = love.audio.newSource("96128__bmaczero__contact2.ogg"),
    y = love.audio.newSource("96127__bmaczero__contact1.ogg"),
  }

  -- blaster (enemy, target)
  blaster = {
    187,
    49,
    181,
  }

  -- font
  love.graphics.setFont(love.graphics.setNewFont(24))

  -- shield tolerance
  blaster_tolerance = 15

  -- shield (interactive bit)
  shield = {
    135,
    155,
    125,
  }
  shield_selection = 1

  -- timer
  timer = {
    global = 0,
    x = 0,
    y = 0,
  }

  -- input delay/sensitivity higher = less sensitive, longer delay
  delay = {
  x = .2,
  y = .003,
  }

  -- input state
  input = {
    x = 0,
    y = 0,
  }

  -- sounds
  snd = {
  {love.audio.newSource("attack.ogg"), 2, false, "tactical"}, -- weapons: the blorg are attacking
  {love.audio.newSource("command.ogg"), 5, false, "crew"}, -- captain: match frequencies
  {love.audio.newSource("threemore.ogg"), 15, false, "tactical"}, -- weapons: damage reports
  {love.audio.newSource("twomore.ogg"), 23, false, "engineer"}, -- engineer: reactor core integrity fading
  {love.audio.newSource("onemore.ogg"), 34, false, "engineer"}, -- engineer: she's gonna blow!
  {love.audio.newSource("over.ogg"), 50, false, "crew"}, -- captain: abandon ship
  {love.audio.newSource("blasted.ogg"), 4, false, "blast"}, -- 
  {love.audio.newSource("blasted.ogg"), 12, false, "blast"}, -- 
  {love.audio.newSource("blasted.ogg"), 21, false, "blast"}, -- 
  {love.audio.newSource("blasted.ogg"), 33, false, "blast"}, -- 
  {love.audio.newSource("blasted.ogg"), 50, false, "blast"}, -- 
  }

  -- music
  mus = love.audio.newSource("Butterfly_Tea_-_Arabian_Travel.mp3", "stream")
  mus:setVolume(0.25)
  -- actuall it has the perfect length
  --mus:setLooping(true)
  love.audio.play(mus)
  alert = love.audio.newSource("182724__qubodup__alert.ogg", "stream")
  alert:setVolume(0.05)
  alert:setLooping(true)
  love.audio.play(alert)

  -- credits
  credits = [[Ensign's Frequency Adventure...

Captain's voice by Jennifer Ludwig all rights reserved

Tactical officer's voice by Jana Leinweber janaleinweber.de all rights reserved

Engineer's voice by Kelsey Bass kelsey-bass.com all rights reserved

Code, graphics & other sounds by Iwan 'qubodup' Gabovitch qubodup.net

Arabian Travel by Butterfly Tea
jamendo.com/en/track/249056 | CC-BY-SA 3.0 License

Success (trumpetbuildup) by theredshore
freesound.org/people/theredshore/sounds/83980/ | CC0

Fail (Dramatic13) by digifishmusic
freesound.org/people/digifishmusic/sounds/76053/ | CC-BY 3.0 License

Alert by qubodup
freesound.org/people/qubodup/sounds/182724/ | CC0

Yay for Berlin Mini Jam!]]

end
function love.update(dt)

  -- timer
  if (state == "counting") then
    timer.global = timer.global + dt
  end

  -- play sounds
  for i,v in ipairs(snd) do
    if timer.global > v[2] and not v[3] then
      love.audio.play(v[1])
      snd[i][3] = true
    end
  end

  -- win
  if( state ~= "win" and blaster[1] + blaster_tolerance > shield[1] and blaster[1] - blaster_tolerance < shield[1] and blaster[2] +blaster_tolerance > shield[2] and blaster[2] -blaster_tolerance < shield[2] and blaster[3] + blaster_tolerance > shield[3] and blaster[3] - blaster_tolerance < shield[3]) then
    state = "win"
    love.audio.play(love.audio.newSource("win.ogg"))
    love.audio.stop(mus)
    love.audio.stop(alert)
  end

  -- game over
  if timer.global > 50 then
    state = "over"
  end

  -- joystick controls
  input.x = love.joystick.getAxis(1, 7)
  input.y = love.joystick.getAxis(1, 8) 
  if love.keyboard.isDown("q", "escape") then
    love.event.quit()
  end
  if love.keyboard.isDown("up","w") then
    input.y = -1
  end
  if love.keyboard.isDown("down","s") then
    input.y = 1
  end
  if love.keyboard.isDown("left","a") then
    input.x = -1
  end
  if love.keyboard.isDown("right","d") then
    input.x = 1
  end

  -- debug input
  -- print(input.x, input.y)

  -- change selected shield based on input
  if(input.y ~= 0) then
    -- move if timer is 0
    if(timer.y <=0) then
      shield[shield_selection] = shield[shield_selection] + input.y * ( (1 * timer.y) / delay.y)
      timer.y = delay.y
    love.audio.stop(uisnd.y)
    love.audio.play(uisnd.y)

      -- lol you expect me to do math? LMAO
      if(shield[shield_selection] > 255) then shield[shield_selection] = 255 end
      if(shield[shield_selection] < 0) then shield[shield_selection] = 0 end
    -- otherwise count
    else
      timer.y = timer.y - dt
    end
  end

  -- change shield selection based on input
  if(input.x ~= 0) then
    -- move if timer is 0 or less
    if(timer.x <=0) then
      timer.x = delay.x
      shield_selection = shield_selection + input.x
    love.audio.stop(uisnd.x)
    love.audio.play(uisnd.x)

      -- % mod wat?
      if shield_selection == 4 then shield_selection = 1 end
      if shield_selection == 0 then shield_selection = 3 end

    end
  end
  -- always count
  timer.x = timer.x - dt

end

function love.draw()

  -- bg
  if state ~= "win" and state ~= "over" then
    love.graphics.draw(viewer)
  elseif state == "win" then
    love.graphics.draw(viewer_win)
  elseif state == "over" then
    love.graphics.draw(viewer_over)
  end

  -- crew while somebody's talking
  for i,v in ipairs(snd) do
    if not v[1]:isStopped() then
      love.graphics.draw(img[v[4]][1], img[v[4]][2], img[v[4]][3])
    end
  end

  -- shield pattern
  love.graphics.setColor(shield[1], shield[2], shield[3], 255)
  love.graphics.rectangle("fill", uipos.x - 10, uipos.y - 10, 175, 375)

  -- shield selection
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle("fill", uipos.x - 00, uipos.y, 155, 255 + 10)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print("Shield Pattern", 190, 160)
  love.graphics.rectangle("fill", uipos.x - 50 + shield_selection*50, uipos.y, 45 + 10, 255 + 10)

  -- shield freq
  love.graphics.setColor(shield[1], 0, 0, 255)
  love.graphics.rectangle("fill", uipos.x + 5, uipos.y + 5, 45, 255)
  love.graphics.setColor(0, shield[2], 0, 255)
  love.graphics.rectangle("fill", uipos.x + 55, uipos.y + 5, 45, 255)
  love.graphics.setColor(0, 0, shield[3], 255)
  love.graphics.rectangle("fill", uipos.x + 105, uipos.y + 5, 45, 255)

  -- levels
  love.graphics.setColor(255,255,255,255)
  love.graphics.rectangle("fill", uipos.x     , uipos.y + 260 - shield[1], 55, 2)
  love.graphics.rectangle("fill", uipos.x + 50, uipos.y + 260 - shield[2], 55, 2)
  love.graphics.rectangle("fill", uipos.x + 100, uipos.y + 260 - shield[3], 55, 2)

  -- credits
  if state == "win" then
    love.graphics.setColor(255,255,255,155)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print("Great job, ensign!\n\n" .. credits, 300, 10)
  elseif state == "over" then
    love.graphics.setColor(0, 0, 0, 155)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)
    love.graphics.setColor(255,255,255,255)
    love.graphics.print("Bad job, ensign D: !\n\n" .. credits, 300, 10)
  end

  -- reset color for some reason
  love.graphics.setColor(255,255,255,255)
  
end
