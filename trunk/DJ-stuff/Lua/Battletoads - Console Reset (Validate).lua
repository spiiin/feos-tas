--onece seq. console reset (int.) for bt
--fixed lag!
--TODO: more frame reset seq.

start_counter = emu.framecount()
reset_check_frames = 60
joy = {}
start_savestate = savestate.create() --nil
current_frame = 0
validate = 0
lvl_id = 0
last_lvl = memory.readbyte(0xd)
game_end = 0
stop = false

function set_joy(frame)
	if frame == 0 then
		joy.start = true
		joypad.set(1, joy)
	else
		joy.start = nil
		joypad.set(1, joy)
	end
end

function main()
	current_frame = emu.framecount()
	validate = current_frame - start_counter
	
	if validate < reset_check_frames then
		set_joy(current_frame % 2)
	elseif validate >= reset_check_frames then
		lvl_id = memory.readbyte(0xd)
		game_end = memory.readbyte(0xf4)
		if ((lvl_id ~= 0) and (lvl_id ~= last_lvl)) or (game_end ~= 0) then
			emu.message("YOU FIND THE CRASH!")
			gui.text(1,9, "Reset Glich Frame: " .. current_frame - reset_check_frames)
			gui.text(1,17, "Level ID: " .. lvl_id .. "\nGame End: " .. game_end)
			emu.pause()
			emu.registerexit(main)
		else
			savestate.load(start_savestate)
			stop = true
		end	
	end
end

emu.unpause()
savestate.save(start_savestate)
memory.setregister("pc",0x82AB)

while (not stop) do
	main()
	emu.frameadvance()
end
