-- feos, 2012
-- See what happens with sound channels volumes
-- Have fun!

iterator = 1
prev_keys = input.get()

volumes = {
	S1V = {},
	S2V = {},
	TV = {},
	NV = {},
	DPCMV = {}
}

function Draw()
	snd = sound.get()
	keys = input.get()

	if #volumes.S1V == 0 then
		channels = {
			Square1  = {x=1,      y=9, vol=volumes.S1V},
			Square2  = {x=1+45*1, y=9, vol=volumes.S2V},
			Triangle = {x=1+45*2, y=9, vol=volumes.TV},
			Noise    = {x=1+45*3, y=9, vol=volumes.NV},
			DPCM     = {x=1+45*4, y=9, vol=volumes.DPCMV}
		}
	end

	table.insert(channels.Square1.vol, 1, snd.rp2a03.square1.volume*15)
	table.insert(channels.Square2.vol, 1, snd.rp2a03.square2.volume*15)
	table.insert(channels.Triangle.vol, 1, snd.rp2a03.triangle.volume)
	table.insert(channels.Noise.vol, 1, snd.rp2a03.noise.volume*15)
	table.insert(channels.DPCM.vol, 1, snd.rp2a03.dpcm.volume)

	for name, chan in pairs(channels) do

		if iterator == 1 then
			if keys.ymouse <= 24 and keys.ymouse >= 0 then
				if keys["leftclick"] and not prev_keys["leftclick"] then iterator = #chan.vol end
			end
		else
			if keys.ymouse <= 24 and keys.ymouse >= 0 then
					if keys["leftclick"] and not prev_keys["leftclick"]
					then iterator = 1; print("Thanks...") end
			end
		end

		gui.text(chan.x+1, 9, name)	
		if iterator <=18 then
			for i = 1, iterator do
				gui.text(chan.x, chan.y+i*9+1, chan.vol[i])
				if chan.vol[i] > 0 then
					for j = 0, chan.vol[i]-1 do
						gui.drawbox(chan.x+13+j*2, chan.y+i*9, chan.x+15+j*2, chan.y+8+i*9, "#000000ff")
						gui.line(chan.x+14+j*2, chan.y+1+i*9, chan.x+14+j*2, chan.y+7+i*9, "#00ff00ff")
					end
				end
			end
		else
			for i = 1, 18 do
				gui.text(chan.x, chan.y+i*9+1, chan.vol[i])
				if chan.vol[i] > 0 then
					for j = 0, chan.vol[i]-1 do
						gui.drawbox(chan.x+13+j*2, chan.y+i*9, chan.x+15+j*2, chan.y+8+i*9, "#000000ff")
						gui.line(chan.x+14+j*2, chan.y+1+i*9, chan.x+14+j*2, chan.y+7+i*9, "#00ff00ff")
					end
				end
			end
			table.remove(chan.vol, 19)
		end

		if chan.vol[1] > 0 and iterator > 1 then
			gui.drawbox(chan.x+12, chan.y+8, chan.x+14+chan.vol[1]*2, chan.y+18, "#ffaaaa00")
		end
	end

	-- Delete this operation, it causes FCEUX to lag :P
	if iterator == 1 then gui.text(45*5-11, 9, "Hint:\nleftclick\nover the\ndisplay")
	else gui.text(45*5-11, 9, "WHAT\nHAVE\nYOU\nDONE\n?!"); print("MAKE IT STOP!!!")
	end

	prev_keys = keys
end

emu.registerafter(Draw);