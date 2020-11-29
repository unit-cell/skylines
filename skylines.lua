-- m185g
-- @markel

MusicUtil = require "musicutil"
include('lib/helpers')
g = grid.connect()
g:rotation(45)              -- vertical orientation, cable on top
engine.name = 'PolyPerc'

function init()
  -- params

  -- init
  clockDivision = 1/4
  menuPage = 1
  m = midi.connect()
  -- presets.last_loaded_x and presets.last_loaded_y keep track of last preset loaded
  presets = tab.load('/home/we/dust/code/skylines/presets/presets.txt')
  enc_position = 0
  enc3_position = 0
  loading = false
  saving = false
  deleting = false
  e3_mode = 'save'
  
  g:all(0)
  clock_id = clock.run(forever)
  clock.cancel(clock_id)
  clockState = 'pause'
  v_ = blank_voice()
  if presets.last_loaded_x ~= nil and presets.last_loaded_y ~= nil then
    v_ = load_table(presets.last_loaded_x, presets.last_loaded_y)
  end

  crow.input[1].mode('change', 2.0, 0.25, 'rising')
  crow.input[1].change = function()
    if should_note_play(v_[1], v_[1].bookmark.step, v_[1].bookmark.rep) then play(v_[1]) end
    if should_note_play(v_[2], v_[2].bookmark.step, v_[2].bookmark.rep) then play(v_[2]) end
    redraw()
    grid_redraw()
    advance(v_[1])
    advance(v_[2])
  end
  
  -- input 2: resets 
  crow.input[2].mode('change', 2.0, 0.25, 'rising')
  crow.input[2].change = function()
    reset()
  end
  
  grid_redraw()
  redraw()
end

-- clock
function forever()
  while true do
    clock.sync(clockDivision)
    if should_note_play(v_[1], v_[1].bookmark.step, v_[1].bookmark.rep) then play(v_[1]) end
    if should_note_play(v_[2], v_[2].bookmark.step, v_[2].bookmark.rep) then play(v_[2]) end
    redraw()
    grid_redraw()
    advance(v_[1])
    advance(v_[2])
  end
end

-- grid keys
g.key = function(x,y,z)
  if menuPage == 1 then
    -- select voice and change length
    if z==1 and (y==1 or y==2) then 
      if y == v_.selected then v_[y].length = x end
      v_.selected = y 
    end
    -- change reps
    if z==1 and y > 2 and y < 11 and v_[v_.selected].noteMode == false then
      v_[v_.selected][x].reps = 11 - y
    end
    -- select trig mode
    if v_[v_.selected].noteMode == false and z==1 and y==12 then
      if v_[v_.selected][x].trigMode == 1 then v_[v_.selected][x].trigMode = 2 else v_[v_.selected][x].trigMode = 1 end
    end
    if v_[v_.selected].noteMode == false and z==1 and y==13 then 
      v_[v_.selected][x].trigMode = 3
    end
    if v_[v_.selected].noteMode == false and z==1 and y==14 then 
      if v_[v_.selected][x].trigMode >= 4 and v_[v_.selected][x].trigMode < 6 then
        v_[v_.selected][x].trigMode = v_[v_.selected][x].trigMode + 1
      else v_[v_.selected][x].trigMode = 4
      end
    end
    if v_[v_.selected].noteMode == false and z==1 and y==15 then 
      v_[v_.selected][x].trigMode = 7 
    end
    -- select note mode
    -- CHANGED Y>2 TO ACCOUNT FOR # OF SCALE DEGREES
    if v_[v_.selected].noteMode == true and z==1 and y>(10-#MusicUtil.generate_scale(0,v_[v_.selected].scaleType)) and y<12 then
      if v_[v_.selected].stepSelected == x and y==11 then 
        v_[v_.selected].noteMode = false                            -- exit note mode
      elseif y==11 then                                           -- change note selected
        v_[v_.selected].stepSelected = x 
      else 
        v_[v_.selected].stepSelected = x                            -- set note according to selection
        set_note(v_[v_.selected], x, 11-y, v_[v_.selected][x].octave)
      end
    elseif z==1 and y==11 and v_[v_.selected].noteMode == false then 
      v_[v_.selected].noteMode = true
      v_[v_.selected].stepSelected = x
    end
    -- select octave
    if v_[v_.selected].noteMode == true and z==1 and x<6 and y==12 then
      set_note(v_[v_.selected], v_[v_.selected].stepSelected, v_[v_.selected][v_[v_.selected].stepSelected].noteDegree, x)
    end
    -- select gate length
    if v_[v_.selected].noteMode == true and z==1 and y==13 then
      set_gate_length(v_[v_.selected], v_[v_.selected].stepSelected, x)
    end
    -- change voice mode/direction
    if v_[v_.selected].noteMode == false and z==1 and y==16 and x<5 then
      if x==1 then v_[v_.selected].mode = 'forward'
      elseif x==2 then v_[v_.selected].mode = 'reverse'
      elseif x==3 then 
        if v_[v_.selected].mode == 'forward' or v_[v_.selected].mode == 'random' then 
          v_[v_.selected].direction = 'forth'
        elseif v_[v_.selected].mode == 'reverse' then 
          v_[v_.selected].direction = 'back'
        end
        v_[v_.selected].mode = 'pingpong'
      elseif x==4 then v_[v_.selected].mode = 'random'
      end
    end
    -- randomization keys
    if v_[v_.selected].noteMode == false then
      if z==1 and x==5 and y==16 then random_trigs(v_[1]) end
      if z==1 and x==6 and y==16 then random_notes(v_[1]) end
      if z==1 and x==7 and y==16 then random_trigs(v_[2]) end
      if z==1 and x==8 and y==16 then random_notes(v_[2]) end
    end
    -- glide row
    if v_[v_.selected].noteMode == true and z==1 and y==16 then
      if v_[v_.selected][x].glide == true then v_[v_.selected][x].glide = false
      else v_[v_.selected][x].glide = true
      end
    end
  end
  
  -- save/load grid keys
  if menuPage == 2 then
    if z==1 and y<5 then
      if saving == true then 
        save_table(v_, x, y)
        saving = false
        update_preset_memory(true, x, y)  
        
      elseif loading == true then
        v_ = load_table(x, y)
        presets.last_loaded_x = x
        presets.last_loaded_y = y
        tab.save(presets, '/home/we/dust/code/skylines/presets/presets.txt')
        loading = false
        
      elseif deleting == true then
        save_table(blank_voice(), x, y)
        deleting = false
        update_preset_memory(false, x, y)          
      end
    end
    
    -- root
    if z==1 and y<8 and y>5 then
      if y == 6 then
        if x ~= 1 and x ~=4 and x ~= 8 then
          for i=1,2 do
            v_[i].root = grid_to_root(x,y)
          end
          set_both_scales(root_to_num(v_[1].root), v_[1].scaleType)
        end
      elseif y == 7 then
        if x ~= 8 then
          for i=1,2 do
            v_[i].root = grid_to_root(x,y)
          end
          set_both_scales(root_to_num(v_[1].root), v_[1].scaleType)
        end
      end
    end
  
    -- scales
    if z==1 and y>8 and y<14 then
      grid_to_scale(x, y)
      v_.scale_led = {x,y}
    end
  
    redraw()
  end
  
  grid_redraw()
end

function led_reps(voice) 
  if menuPage == 1 then  
    for i=1,voice.length do
      for j=1,voice[i].reps do
        if i < voice.bookmark.step and voice.mode ~= 'random' then
          g:led(i,11-j,15)
        elseif i == voice.bookmark.step and j <= voice.bookmark.rep then
          g:led(i,11-j,15)
        else
          g:led(i,11-j,10)
        end
        -- check if note should fire
        if voice[i].trigMode ~= 7 then
          if not should_note_play(voice, i, j) then 
            if i == voice.bookmark.step and j == voice.bookmark.rep then g:led(i,11-j,15)   -- bookmark step always on
            else g:led(i,11-j,3) -- note will not play
            end 
        end
        elseif  i == voice.bookmark.step and j == voice.bookmark.rep then g:led(i,11-j,15)  -- bookmark step always on
        elseif voice[i].trigMode == 7 then g:led(i,11-j,5)                                   -- blinks for random trig mode
        else g:led(i,11-j,0)
        end
        -- trig selection leds
        if voice[i].trigMode == 1 then g:led(i,12,15)
        elseif voice[i].trigMode == 2 then g:led(i,12,3)
        else g:led(i,12,5)
        end
        if voice[i].trigMode == 3 then g:led(i,13,15) else g:led(i,13,5) end
        if voice[i].trigMode >= 4 and voice[i].trigMode < 7 then g:led(i,14,15) else g:led(i,14,5) end
        if voice[i].trigMode == 7 then g:led(i,15,15) else g:led(i,15,5) end
      end
    end
    -- play direction mode leds
    for i=1,8 do
      if voice.mode == 'forward' then 
        if i==1 then g:led(i,16,15) else g:led(i,16,5) end
      elseif voice.mode == 'reverse' then
        if i==2 then g:led(i,16,15) else g:led(i,16,5) end
      elseif voice.mode == 'pingpong' then
        if i==3 then g:led(i,16,15) else g:led(i,16,5) end
      elseif voice.mode == 'random' then
        if i==4 then g:led(i,16,15) else g:led(i,16,5) end
      end
    end
    -- randomization leds
    g:led(5,16,15)
    g:led(6,16,10)
    g:led(7,16,15)
    g:led(8,16,10)
  end
end

function led_notes(voice)
  if menuPage == 1 then
    for i=1,voice.length do 
      -- note selection leds
      if i == voice.stepSelected then g:led(i,11,15)
      else g:led(i,11,3)
      end
      -- glide row
      if voice[i].glide == true then g:led(i,16,15)
        else g:led(i,16,5)
      end
      -- note panel
      for j=1,#MusicUtil.generate_scale(0,v_[v_.selected].scaleType) do
        if j == voice[i].noteDegree then g:led(i,11-j,15)
        else g:led(i,11-j,5)
        end
      end
    end
    -- octave row
    for i=1,5 do
      if i == voice[voice.stepSelected].octave then g:led(i,12,15)
      else g:led(i,12,5) end
    end
    -- gate length row
    for i=1,8 do
      if voice[voice.stepSelected].gateLength >= i then g:led(i,13,15)
        else g:led(i,13,3)
      end
    end
  end
end

function grid_redraw()
  g:all(0)
  
  if menuPage == 1 then
    for i=1,v_[v_.selected].length do 
      g:led(i,v_.selected,3)
    end
    g:led(v_[1].bookmark.step,1,15)
    g:led(v_[2].bookmark.step,2,15)
    if v_[v_.selected].noteMode == false then led_reps(v_[v_.selected])
    else led_notes(v_[v_.selected]) end
  end
  
  if menuPage == 2 then 
    for i=1,4 do
      for j=1,8 do
        if presets[i][j] == false then 
          g:led(j,i,3)
        else g:led(j,i,8)
        end
        if presets.last_loaded_x ~= nil then
          if i == presets.last_loaded_y and j == presets.last_loaded_x then g:led(j,i,15) end
        end
      end
    end
  
    -- all notes at brightness 3
    for k, val in ipairs(note_leds_i) do
      g:led(note_leds_i[k][1],note_leds_i[k][2],3)
    end
    -- notes in scale at brightness 5
    for k, val in ipairs(leds_in_scale(root_to_num(v_[1].root), v_[1].scaleType)) do
      g:led(note_leds_i[val][1], note_leds_i[val][2], 5)
    end
    -- root note at brightness 15
    g:led(root_to_grid(v_[1].root)[1], root_to_grid(v_[1].root)[2], 15)
    
    -- scale selection leds
    for j=9,13 do
      for i=1,8 do
        g:led(i,j,3)
      end
    end
    g:led(v_.scale_led[1], v_.scale_led[2], 15)
  end
  
  g:refresh()
  redraw()
end

-- norns keys
function key(n,z)
  
  if menuPage ==1 then
    -- play/pause
    if n==3 and z==1 then play_pause() end
    -- reset
    if n==2 and z==1 then reset() end
  end
  
  if menuPage == 2 then
    -- save/load/delete
    if n==3 and z==1 then 
      if deleting == true or saving == true then
        deleting = false
        saving = false
      elseif e3_mode == 'save' then 
        deleting = false
        saving = true
        loading = false
      elseif e3_mode == 'del' then
        deleting = true
        saving = false
        loading = false
      end
    end
    if n==2 and z==1 then
      if loading == true then 
        loading = false
        saving = false
        deleting = false 
      else
        loading = true
        saving = false
        deleting = false
      end
    end
  end
  
  redraw()
end

-- norns encoder
function enc(n,d)
  if n == 1 then
    enc_position = enc_position + d 
    if enc_position % 5 == 0 then        -- choose modulo to set encoder sensitivity
      if menuPage == 1 then menuPage = 2
      elseif menuPage == 2 then menuPage = 1
      end
    end
    redraw()
    grid_redraw()
  end
  
  -- save/delete selection
  if n == 3 then
    enc3_position = enc3_position + d
    if enc3_position % 5 == 0 then        -- choose modulo to set encoder sensitivity
      if e3_mode == 'save' then
        e3_mode = 'del'
      else e3_mode = 'save'
      end
    end
    redraw()
    grid_redraw()
  end
end

-- norns screen
function redraw()
  screen.clear()
  
  -- city
  if saving == false and loading == false and deleting == false then
    screen.move(3,58)
    screen.level(2)
    screen.line_rel(5,0)
    for i=1,v_[2].length do 
      screen.line_rel(0,-5*v_[2][i].reps)
      screen.line_rel(4,0)
      screen.line_rel(0,5*v_[2][i].reps)
      screen.line_rel(4,0)
    end
  
    screen.stroke()
    
    screen.move(1,60)
    screen.level(15)
    screen.line_rel(5,0)
    for i=1,v_[1].length do 
      screen.line_rel(0,-5*v_[1][i].reps)
      screen.line_rel(4,0)
      screen.line_rel(0,5*v_[1][i].reps)
      screen.line_rel(4,0)
    end
    
    screen.stroke()
  end

  -- UI
  screen.move(1,10)
  screen.level(1)
  screen.text('E1')
  
  if menuPage == 1 then
    screen.level(15)
    screen.move(12,10)
    screen.text('1')
    screen.rect(10,4,8,8)
    screen.move(32,10)
    screen.text('Sequence')
    
    screen.level(1)
    screen.move(22,10)
    screen.text('2')
    screen.move(92,39)
    screen.text('K2')
    screen.move(112,39)
    screen.text('K3')
    
    screen.level(15)
    screen.rect(88,42,18,18)
    screen.rect(108,42,18,18)
    screen.stroke()
    screen.move(96,53)
    screen.text_center('RES')

    if clockState == 'pause' then 
      screen.move(116,53)
      screen.text_center('GO!')
      
    else
      screen.rect(113,47,2,7)
      screen.fill()
      screen.rect(118,47,2,7)
      screen.fill()
      screen.stroke()
    end
    
  elseif menuPage == 2 then
    screen.level(1)
    screen.move(12,10)
    screen.text('1')
    screen.move(92,39)
    screen.text('K2')
    screen.move(108,19)
    screen.text('K3E3')
    
    screen.level(15)
    screen.move(22,10)
    screen.text('2')
    screen.rect(20,4,8,8)
    screen.stroke()
    screen.move(32,10)
    screen.text('Presets & Scales')
    screen.move(96,53)
    screen.text_center('L')
    screen.rect(88,42,18,18)
    screen.stroke()
    
    if e3_mode == 'del' then screen.level(1) end
    screen.move(117,53)
    screen.text_center('S')
    screen.rect(108,42,18,18)
    screen.stroke()
    screen.level(15)

    if e3_mode == 'save' then screen.level(1) end
    screen.move(117,33)
    screen.text_center('DEL')
    screen.rect(108,22,18,18)
    screen.stroke()
    screen.level(15)

    if loading == true then 
      screen.move(30,40)
      screen.text('LOADING')
    elseif saving == true then
      screen.move(30,40)
      screen.text('SAVING')
    elseif deleting == true then
      screen.move(30,40)
      screen.text('DELETING') 
    end
  end
  
  screen.update()
end

