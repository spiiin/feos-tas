--Battletoads Reset Tester
--If you want see the reset intro screen? Change the "reset_check_frames" parameter. (to example 1200++, if you want see more)

start_counter = emu.framecount() + 1
reset_check_frames = 11
joy = {}
start_savestate = nil
current_frame = 0
reseted = false

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
	
	if not reseted then
		if current_frame == start_counter then
			if start_savestate == nil then
				emu.speedmode("turbo")
				emu.speedmode("maximum")
				gui.text(1,17,
				"Attention!\n" ..
				"Using this script you can crash the emulator\n" ..
				"If you want to continue, unpause the game\n" ..
				"If you want to change the speed on normal do it now", "red", "black")
				emu.pause()
				start_savestate = savestate.create()
			end
			savestate.save(start_savestate)
			start_counter = start_counter + 1
			emu.softreset()
			reseted = true
		end
	else
		set_joy(current_frame % 2)
		if current_frame == reset_check_frames then
			if (memory.readbyte(0xd) ~= 0) or (memory.readbyte(0xf4) ~= 0) then
				emu.message("YOU FIND THE CRASH!")
				gui.text(1,9, "Reset Glich Frame: " .. start_counter)
				emu.pause()
				emu.registerexit(main)
			end
			reseted = false
			savestate.load(start_savestate)
		end
	end
end

emu.registerafter(main)

