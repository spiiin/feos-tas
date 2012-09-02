--Battletoads - Obiect Reviewer by TheZlomuS
--It shows the most important information about objects.
--It has a built "Randomforce".
--It has a special object detector.
--You can view the location of objects with keys: "up" and "down".
--Fixed: fast increasing.

CNT = 13
CLR = 0x7e
SE = 0x22
LEE = 0x7f
WE = 0x55
FOT = {}
EOT = {}
ROT = {}
TOT = {}
JP = {}
RF = not emu.readonly()

function SetButton()
	if math.random(2) == 1
	then return true
	else return nil
	end
end
--
--function FullState()
--	JP.A = true
--	JP.B = true
--	JP.select = true
--	JP.start = true
--	JP.up = true
--	JP.down = true
--	JP.left = true
--	JP.right = true
--end
--
function SetBit(q)
	JP.A = SetButton()
	JP.B = SetButton()
	JP.select = SetButton()
	--if q == false then
	--	JP.start = SetButton()
	--else JP.start = q
	--end
	JP.up = SetButton()
	JP.down = SetButton()
	JP.left = SetButton()
	JP.right = SetButton()
end
x = 3
function Main()
	key = input.get()
	CFC = emu.framecount()
	
	if key.up and (x <= 12) and (CFC % 10 == 0) then
		x = x + 1
	elseif key.down and (x >= 2) and (CFC % 10 == 0) then
		x = x - 1
	end
	
	if RF then
		SetBit()
		joypad.set(1, JP)
		SetBit()
		joypad.set(2, JP)
	end

	FOT = memory.readbyterange(0x594, CNT)
	EOT = memory.readbyterange(0x585, CNT)
	ROT = memory.readbyterange(0x3c3, CNT)
	TOT = memory.readbyterange(0x4e0, CNT)
	SFO = "ObjFlg: "
	SEO = "ObjEvt: "
	SRO = "ObjReS: "
	STO = "ObjTmr: "
	ISC = false

	for i = 1, CNT do
		FO = string.byte(FOT, i)
		EO = string.byte(EOT, i)
		RO = string.byte(ROT, i)
		TO = string.byte(TOT, i)
		SFO = SFO .. string.format("%2X|", FO) 
		SEO = string.format(SEO .. "%2X|", EO)
		SRO = SRO .. string.format("%2X|", RO)
		STO = string.format(STO .. "%2X|", TO)
		DQS = RO == LEE - 1 or RO == LEE * 2
		WRP = RO == SE or RO == SE + LEE + 1
		if not ISC then
			ISC = RO == CLR
		end
		if DQS or WRP then
			if DQS then
				if (FO > LEE) or ISC then
					emu.pause()
				end
			elseif EO == WE or EO == WE + 1 then
				emu.pause()
			end
		end
	end

	gui.text(1, 1, SRO)
	gui.text(1, 9, STO)
	gui.text(1, 17, SEO)
	gui.text(1, 25, SFO)
	gui.text(1, 216, string.format("P1X: %4X\tP2X: %4X\tO" .. x .. "X: %4X\tCX: %4X", memory.readbyte(0x3ee)*256 + memory.readbyte(0x3fd), memory.readbyte(0x3ef)*256 + memory.readbyte(0x3fe), memory.readbyte(0x3ef+x)*256 + memory.readbyte(0x3fe+x), memory.readbyte(0x87) + 256*memory.readbyte(0x88)))
	gui.text(1, 224, string.format("P1Y: %4X\tP2Y: %4X\tO" .. x .. "Y: %4X\tCY: %4X", memory.readbyte(0x42a)*256 + memory.readbyte(0x439), memory.readbyte(0x42a+1)*256 + memory.readbyte(0x439+1), memory.readbyte(0x42a+1+x)*256 + memory.readbyte(0x439+1+x), memory.readbyte(0x89) + 256*memory.readbyte(0xe0)))
	gui.text(1, 232, string.format("P1Z: %4X\tP2Z: %4X\tO" .. x .. "Z: %4X", memory.readbyte(0x40c)*256 + memory.readbyte(0x493), memory.readbyte(0x40c+1)*256 + memory.readbyte(0x493+1), memory.readbyte(0x40c+1+x)*256 + memory.readbyte(0x493+1+x)))
end

emu.registerafter(Main)