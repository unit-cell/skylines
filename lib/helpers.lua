gate_length_mult = 0.025

-- play/pause
function play_pause()
  if clockState == 'pause' then 
    clockState = 'play'
    clock_id = clock.run(forever)
    redraw()
    grid_redraw()
    m:continue()
  elseif clockState == 'play' then
    clockState = 'pause'
    clock.cancel(clock_id)
    redraw()
    grid_redraw()
    m:stop()
  end
end

-- reset
function reset()
  for i=1,2 do
    v_[i].bookmark.step = 1
    v_[i].bookmark.rep = 1
  end
  grid_redraw()
end

-- note setting helper function
function set_note(voice, step, degree, octave)
  voice[step].noteDegree = degree
  voice[step].octave = octave
  -- check if previously selected degree is within current scale, otherwise set degree 1
  if voice.scales[voice[step].octave][voice[step].noteDegree] == nil then voice[step].noteDegree = 1 end
  voice[step].noteNum = voice.scales[voice[step].octave][voice[step].noteDegree] 
end

function root_to_num(root_note)
  -- returns midi num of note in octave 2
  if root_note == 'C' then return 36
  elseif root_note == 'C#' or root_note == 'Db' then return 37
  elseif root_note == 'D' then return 38
  elseif root_note == 'D#' or root_note == 'Eb' then return 39  
  elseif root_note == 'E' then return 40
  elseif root_note == 'F' then return 41  
  elseif root_note == 'F#' or root_note == 'Gb' then return 42
  elseif root_note == 'G' then return 43
  elseif root_note == 'G#' or root_note == 'Ab' then return 44
  elseif root_note == 'A' then return 45
  elseif root_note == 'A#' or root_note == 'Bb' then return 46
  elseif root_note == 'B' then return 47
  end
end

note_leds = {
  C = {1,7},
  Db = {2,6},
  D = {2,7},
  Eb = {3,6},
  E = {3,7},
  F = {4,7},
  Gb = {5,6},
  G = {5,7},
  Ab = {6,6},
  A = {6,7},
  Bb = {7,6},
  B = {7,7},
}

note_leds_i = {
  {1,7},
  {2,6},
  {2,7},
  {3,6},
  {3,7},
  {4,7},
  {5,6},
  {5,7},
  {6,6},
  {6,7},
  {7,6},
  {7,7},
}

-- returns table with indices of note_leds to light up in root/scale view
function leds_in_scale(root, scale)
  -- root must be index (1-12)
  notes_in_scale = {}
  for k, v in ipairs(MusicUtil.generate_scale(0,scale)) do
    notes_in_scale[k] = ((root + v)%12)+1
  end
  table.remove(notes_in_scale, #notes_in_scale)
  return notes_in_scale
end

-- indicate root
function root_to_grid(root_note)
  if root_note == 'C' then return {1,7}
  elseif root_note == 'C#' or root_note == 'Db' then return {2,6}
  elseif root_note == 'D' then return {2,7}
  elseif root_note == 'D#' or root_note == 'Eb' then return {3,6}  
  elseif root_note == 'E' then return {3,7}
  elseif root_note == 'F' then return {4,7}  
  elseif root_note == 'F#' or root_note == 'Gb' then return {5,6}
  elseif root_note == 'G' then return {5,7}
  elseif root_note == 'G#' or root_note == 'Ab' then return {6,6}
  elseif root_note == 'A' then return {6,7}
  elseif root_note == 'A#' or root_note == 'Bb' then return {7,6}
  elseif root_note == 'B' then return {7,7}
  end
end

function grid_to_root(x, y)
  if x == 1 and y == 7 then return 'C'
  elseif x == 2 and y == 6 then return 'Db'
  elseif x == 2 and y == 7 then return 'D'
  elseif x == 3 and y == 6 then return 'Eb'
  elseif x == 3 and y == 7 then return 'E'
  elseif x == 4 and y == 7 then return 'F'
  elseif x == 5 and y == 6 then return 'Gb'
  elseif x == 5 and y == 7 then return 'G'
  elseif x == 6 and y == 6 then return 'Ab'
  elseif x == 6 and y == 7 then return 'A'
  elseif x == 7 and y == 6 then return 'Bb'
  elseif x == 7 and y == 7 then return 'B'
  end
end

function grid_to_scale(x, y)
  if x==1 and y==9 then set_both_scales(root_to_num(v_[1].root), 'major') end
  if x==2 and y==9 then set_both_scales(root_to_num(v_[1].root), 'natural minor') end
  if x==3 and y==9 then set_both_scales(root_to_num(v_[1].root), 'harmonic minor') end
  if x==4 and y==9 then set_both_scales(root_to_num(v_[1].root), 'melodic minor') end
  if x==5 and y==9 then set_both_scales(root_to_num(v_[1].root), 'dorian') end
  if x==6 and y==9 then set_both_scales(root_to_num(v_[1].root), 'phrygian') end
  if x==7 and y==9 then set_both_scales(root_to_num(v_[1].root), 'lydian') end
  if x==8 and y==9 then set_both_scales(root_to_num(v_[1].root), 'mixolydian') end
  if x==1 and y==10 then set_both_scales(root_to_num(v_[1].root), 'locrian') end
  if x==2 and y==10 then set_both_scales(root_to_num(v_[1].root), 'gypsy minor') end
  if x==3 and y==10 then set_both_scales(root_to_num(v_[1].root), 'whole tone') end
  if x==4 and y==10 then set_both_scales(root_to_num(v_[1].root), 'major pentatonic') end
  if x==5 and y==10 then set_both_scales(root_to_num(v_[1].root), 'minor pentatonic') end
  if x==6 and y==10 then set_both_scales(root_to_num(v_[1].root), 'major bebop') end
  if x==7 and y==10 then set_both_scales(root_to_num(v_[1].root), 'altered scale') end
  if x==8 and y==10 then set_both_scales(root_to_num(v_[1].root), 'blues scale') end
  if x==1 and y==11 then set_both_scales(root_to_num(v_[1].root), 'neapolitan major') end
  if x==2 and y==11 then set_both_scales(root_to_num(v_[1].root), 'hungarian major') end
  if x==3 and y==11 then set_both_scales(root_to_num(v_[1].root), 'harmonic major') end
  if x==4 and y==11 then set_both_scales(root_to_num(v_[1].root), 'hungarian minor') end
  if x==5 and y==11 then set_both_scales(root_to_num(v_[1].root), 'lydian minor') end
  if x==6 and y==11 then set_both_scales(root_to_num(v_[1].root), 'neapolitan minor') end
  if x==7 and y==11 then set_both_scales(root_to_num(v_[1].root), 'major locrian') end
  if x==8 and y==11 then set_both_scales(root_to_num(v_[1].root), 'leading whole tone') end
  if x==1 and y==12 then set_both_scales(root_to_num(v_[1].root), 'six tone symmetrical') end
  if x==2 and y==12 then set_both_scales(root_to_num(v_[1].root), 'arabian') end
  if x==3 and y==12 then set_both_scales(root_to_num(v_[1].root), 'balinese') end
  if x==4 and y==12 then set_both_scales(root_to_num(v_[1].root), 'byzantine') end
  if x==5 and y==12 then set_both_scales(root_to_num(v_[1].root), 'hungarian gypsy') end
  if x==6 and y==12 then set_both_scales(root_to_num(v_[1].root), 'persian') end
  if x==7 and y==12 then set_both_scales(root_to_num(v_[1].root), 'east indian purvi') end
  if x==8 and y==12 then set_both_scales(root_to_num(v_[1].root), 'oriental') end
  if x==1 and y==13 then set_both_scales(root_to_num(v_[1].root), 'double harmonic') end
  if x==2 and y==13 then set_both_scales(root_to_num(v_[1].root), 'enigmatic') end
  if x==3 and y==13 then set_both_scales(root_to_num(v_[1].root), 'overtone') end
  if x==4 and y==13 then set_both_scales(root_to_num(v_[1].root), 'prometheus') end
  if x==5 and y==13 then set_both_scales(root_to_num(v_[1].root), 'Gagaku Rittsu Sen Pou') end
  if x==6 and y==13 then set_both_scales(root_to_num(v_[1].root), 'Gagaku Ryo Sen Pou') end
  if x==7 and y==13 then set_both_scales(root_to_num(v_[1].root), 'Zokugaku Yo Sen Pou') end
  if x==8 and y==13 then set_both_scales(root_to_num(v_[1].root), 'In Sen Pou') end
end

-- populate scales table
function set_scales(voice, root_num, scale_type)
  for i = 1,5 do
    voice.scales[i] = MusicUtil.generate_scale(root_num+((i-1)*12), scale_type)
    voice.scaleType = scale_type
  end
end

function set_both_scales(root_num, scale_type)
  for i = 1,5 do
    for j =1,2 do
      v_[j].scales[i] = MusicUtil.generate_scale(root_num+((i-1)*12), scale_type)
      v_[j].scaleType = scale_type
    end
  end
  for i=1,2 do
    for step=1,v_[i].length do
      set_note(v_[i], step, v_[i][step].noteDegree, v_[i][step].octave)
    end
  end
end

-- gate length setting helper function
function set_gate_length(voice, step, length)
  voice[step].gateLength = length
end

-- play note
function play(voice)
  engine.release(0.2*voice[voice.bookmark.step].gateLength)
  engine.hz(MusicUtil.note_num_to_freq(voice[voice.bookmark.step].noteNum))
  send_cv(voice)
end

-- crow
function send_cv(voice)
  if voice.voice == 1 then
    if voice[voice.bookmark.step].glide == true then 
      crow.output[1].slew = v_[1].slewTime
    else
      crow.output[1].slew = 0
    end
    crow.output[1].volts = (voice[voice.bookmark.step].noteNum - 60) * 1/12
    crow.output[2].action =  "pulse("..v_[1][v_[1].bookmark.step].gateLength*(gate_length_mult)..",5.0,positive)"
    crow.output[2]()
  else
    if voice[voice.bookmark.step].glide == true then 
      crow.output[3].slew = v_[2].slewTime
    else
      crow.output[3].slew = 0
    end
    crow.output[3].volts = (voice[voice.bookmark.step].noteNum - 60) * 1/12
    crow.output[4].action =  "pulse("..v_[2][v_[2].bookmark.step].gateLength*(gate_length_mult)..",5.0,positive)"
    crow.output[4]()
  end
end

-- advancing the sequence
function advance(voice)
  -- forward
  if voice.mode == 'forward' then
    if voice.bookmark.rep < voice[voice.bookmark.step].reps then
      voice.bookmark.rep = voice.bookmark.rep + 1
    elseif voice.bookmark.step < voice.length then
      voice.bookmark.rep = 1
      voice.bookmark.step = voice.bookmark.step + 1
    else
      voice.bookmark.rep = 1
      voice.bookmark.step = 1
    end
  end
  -- reverse
  if voice.mode == 'reverse' then
    if voice.bookmark.rep > 1 then
      voice.bookmark.rep = voice.bookmark.rep - 1
    elseif voice.bookmark.step > 1 then
      voice.bookmark.step = voice.bookmark.step - 1
      voice.bookmark.rep = voice[voice.bookmark.step].reps
    else
      voice.bookmark.step = voice.length
      voice.bookmark.rep = voice[voice.bookmark.step].reps
    end
  end
  -- pingpong
  if voice.mode == 'pingpong' then
    if voice.direction == 'forth' then
      if voice.bookmark.rep < voice[voice.bookmark.step].reps then
        voice.bookmark.rep = voice.bookmark.rep + 1
      elseif voice.bookmark.step < voice.length then
        voice.bookmark.rep = 1
        voice.bookmark.step = voice.bookmark.step + 1
      else
        voice.direction = 'back'
      end
    end
    if voice.direction == 'back' then
      if voice.bookmark.rep > 1 then
        voice.bookmark.rep = voice.bookmark.rep - 1
      elseif voice.bookmark.step > 1 then
        voice.bookmark.step = voice.bookmark.step - 1
        voice.bookmark.rep = voice[voice.bookmark.step].reps
      else
        voice.direction = 'forth'
        advance(voice)
      end
    end   
  end
  -- random
  if voice.mode == 'random' then
    if voice.bookmark.rep < voice[voice.bookmark.step].reps then
      voice.bookmark.rep = voice.bookmark.rep + 1
    else
      voice.bookmark.step = math.random(1,voice.length)
      voice.bookmark.rep = 1
    end
  end
end

-- trig logic: all, none, first, seconds, thirds, fourths, random
function should_note_play(voice, step, rep)
  if voice.length < step or voice[step].reps < rep then return false end -- sanity check
  if voice[step].trigMode == 1 then return true        -- all
  elseif voice[step].trigMode == 2 then return false   -- none
  elseif voice[step].trigMode == 3 then                -- first
    if rep == 1 then return true
    else return false end
  elseif voice[step].trigMode == 4 then                -- every 2
    if rep % 2 == 0 then return true
    else return false end
  elseif voice[step].trigMode == 5 then                -- every 3
    if rep % 3 == 0 then return true
    else return false end    
  elseif voice[step].trigMode == 6 then                -- every 4
    if rep % 4 == 0 then return true
    else return false end
  elseif voice[step].trigMode == 7 then                -- random
    if math.random(1,2) == 1 then return true
    else return false end
  end
end

-- randomize trigs
function random_trigs(voice)
  for j=1,voice.length do
    voice[j].trigMode = math.random(1,7)
    voice[j].reps = math.random(1,8)
  end
end
    
-- randomize notes
function random_notes(voice)
  for j=1,voice.length do
    --voice[j].gateLength = math.random(1,8)
    -- voice[j].octave = math.random(2,6)     -- too random?
    set_note(voice, j, math.random(1,#MusicUtil.generate_scale(0,voice.scaleType)), voice[j].octave)
    if math.random (1,2) == 1 then voice[j].glide = false else voice[j].glide = true end
  end
end

-- save/load
function save_table(tab_to_save, x, y)
  tab.save(tab_to_save, '/home/we/dust/code/skylines/presets/preset'..tostring(y)..tostring(x)..'.txt')
end

function load_table(x, y)
  return tab.load('/home/we/dust/code/skylines/presets/preset'..tostring(y)..tostring(x)..'.txt')
end

function update_preset_memory(bool, x, y)
  presets[y][x] = bool
  tab.save(presets, '/home/we/dust/code/skylines/presets/presets/presets.txt')
end

-- preset management
function blank_voice()
  voice = {}
    voice.selected = 1
    voice.scale_led = {1,9}
    for i = 1,2 do               -- construct tables for 2 voices
      voice[i] = {}
      voice[i].voice = i
      voice[i].length = 8
      voice[i].slewTime = 0.1
      voice[i].root = 'C'
      voice[i].scaleType = 'major'
      voice[i].scales = {}          -- TO DO: provide options, in norns params (scale and root note per voice)
      voice[i].mode = 'forward'     -- forward, reverse, pingpong, random
      voice[i].direction = 'forth'  -- forth, back or random
      voice[i].noteMode = false     -- change led panel to note input mode when true
      voice[i].stepSelected = 1     -- select step in note input mode
      voice[i].bookmark = {}
      voice[i].bookmark.step = 1
      voice[i].bookmark.rep = 1
      set_scales(voice[i], root_to_num(voice[i].root), voice[i].scaleType)
      for j=1,8 do              -- construct tables for 8 steps
        voice[i][j] = {}
        voice[i][j].trigMode = 2
        voice[i][j].reps = 8
        voice[i][j].gateLength = 1
        voice[i][j].noteDegree = j
        voice[i][j].octave = 4
        voice[i][j].noteNum = voice[i].scales[voice[i][j].octave][voice[i][j].noteDegree]
        voice[i][j].glide = false
      end
    end
  return voice
end
  
function generate_blank_preset_memory()
  presets = {}

  for i=1,4 do
    presets[i]={}
    for j=1,8 do
      presets[i][j]=false
    end
  end

  tab.save(presets, '/home/we/dust/code/skylines/presets/presets.txt')
end

function wipe_presets()
  voice = blank_voice()
  for y=1,4 do
    for x=1,8 do
      save_table(voice, x, y)
    end
  end
  generate_blank_preset_memory()
end


