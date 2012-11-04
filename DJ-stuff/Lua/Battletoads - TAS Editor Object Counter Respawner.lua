--Script: Battletoads - TAS Editor Object Counter (Object Respawner)
--Author: TheZlomuS (DJtZ/DJZ)
--Description: Usage --> Tool compatible with TAS Editor only!
--Version: v.1.0.68
--This tool helps with finding object counter results in the jet/surfboard glitch.
--Tool is maked only for test (is simple and clear).
--Attention! Script make automatic results, to stop it, you need to use external tools or by user stop.
--TODO: detector for game stuck, expanded respawner, fixing the lost game ending.

--user option variables
start_frame = 3426
limit_frame = 5000
max_resets = 2
autoturbo = false
nolimit = false
nocheck = false
nospawn = false
isdebug = false

--script procedures
--bit functions
function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
  return x % (p + p) >= p       
end

function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end

--this function make new input per frame.
function SetInput(start)
	if start then
		rnd = setbit(math.random(256), bit(4))
	elseif start == nil then
		rnd = math.random(256)
	elseif not start then
		rnd = clearbit(math.random(256), bit(4))--bit.band(math.random(256), 0x10) --need del bit
	end
	return rnd
end

--return minus player id
function SetPlayerInput()
	return 0x81
end

--script define variables (do not edit!)
end_frame = start_frame + 4*(max_resets + 1) --- 2
once_was = false
iStart = nil

--debug vars. and proc.
if isdebug then
	obj_ids = "ID: "
	obj_len = 15
	obj_adr = 0x3c0
	obj_ctr_adr = 0xB7
end

--main program
function Main()
	curr_frame = emu.framecount()
	--interior debug
	--s_add = ""
	
	if not nospawn and taseditor.engaged() and (curr_frame == start_frame) then
		if autoturbo then
			emu.speedmode("turbo")
		end
		once_was = false
		curr_input = 0
		k = start_frame % 4		
		taseditor.clearinputchanges()
		for i = start_frame, end_frame - 1 do 
			if ((i + k) % 4 == 0) then
				curr_input = SetInput()
				iStart = hasbit(curr_input, bit(4))
				--interior debug
				--s_add = s_add .. "IS: " .. tostring(iStart) .. " frame: " .. i .. "\n"
				taseditor.submitinputchange(i, 1, curr_input)
			elseif ((i + k) % 4 == 1) then
				--interior debug
				--s_add = s_add .. "IS: " .. tostring(iStart) .. " frame: " .. i .. "\n"
				taseditor.submitinputchange(i, 2, SetInput(iStart))
			elseif ((i + k) % 4 == 2) and ((i + k) < end_frame - 2) then
				taseditor.submitinputchange(i, 1, SetInput(true))
			elseif ((i + k) % 4 == 3) and ((i + k) < end_frame - 2) then
				taseditor.submitinputchange(i, 2, 255)
			elseif ((i + k) % 4 == 2) and ((i + k) >= end_frame - 2) then
				taseditor.submitinputchange(i, 1, SetInput(false))
			elseif ((i + k) % 4 == 3) and ((i + k) >= end_frame - 2) then
				taseditor.submitinputchange(i, 2, SetPlayerInput())
			end
		end
		taseditor.applyinputchanges("Respawn Objects")
	end
	
	--interior debug
	--gui.text(1, 25, s_add)
	
	game_end = memory.readbyte(0xF4) == 0
	oc_buged = memory.readbyte(0x88) ~= 0xFF
	
	--interior debug
	--gui.text(1, 17, "OW: " .. tostring(once_was))
	
	if not nocheck and (curr_frame > end_frame) and (game_end or oc_buged) then
		if taseditor.engaged() and not once_was then
			taseditor.setplayback(start_frame - 1)
		end
	elseif not nocheck and (curr_frame > end_frame) and not once_was then
		once_was = true
		if autoturbo then
			emu.speedmode("normal")
		end
	end
	
	if not nolimit and (curr_frame >= limit_frame) and taseditor.engaged() then
		taseditor.setplayback(start_frame - 1)
	end
	
	--if debug enabled
	--info about: object counter pointer, spawned objects, camera position, game status
	if isdebug then
		obj_ctr = memory.readbyte(obj_ctr_adr) + 256*memory.readbyte(obj_ctr_adr + 1)
		cam_xpos = memory.readbyte(0x87) + 256*memory.readbyte(0x88)
		cam_ypos = memory.readbyte(0x89) + 256*memory.readbyte(0x8a)
		gui.text(1, 1, obj_ids)
		gui.text(1, 9, string.format("GE: %s", tostring(not game_end)))
		gui.text(48, 9, string.format("CB: %s", tostring(not oc_buged)))
		gui.text(96, 9, string.format("OC: %X", obj_ctr))
		gui.text(150, 9, string.format("CX: %X", cam_xpos))
		gui.text(210, 9, string.format("CY: %X", cam_ypos))
		for i = 1, obj_len do
			gui.text(i*16 + 4, 1, string.format("%X", memory.readbyte(obj_adr + i)))
		end
	end
end

emu.registerafter(Main)