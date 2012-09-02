--Battletoads - Flag Searcher by TheZlomuS
--Searches slot of minus flag,
CNT = 13
LEE = 0x7f
ITS = false
ITR = false
ITC = false
ICT = 0
ICP = 0
LAG = 0
FGF = 6
--QFGF = math.ceil(FGF / 4)
HFGF = math.ceil(FGF / 2)
--QHFGF = math.ceil(FGF / 1.5)
--SLT = 1
--LCF = 0
--RO = 0
--CLR = "#FF0000"
--WE = 0x55
FOT = {}
EOT = {}
ROT = {}
JP = {}

function SetButton()
	if math.random(2) == 1
	then return true
	else return nil
	end
end

function SetInput()--(q)
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

function Main()
	--gui.text(1, 1, "QF: " .. QFGF .. " HF: " .. HFGF .. " QHF: " .. QHFGF)
	FOT = memory.readbyterange(0x594, CNT)
	--EOT = memory.readbyterange(0x585, CNT)
	ROT = memory.readbyterange(0x3c3, CNT)
	--gui.text(1, 1, "")
	i = 0
	for i = 1, CNT do
		FO = string.byte(FOT, i)
		RO = string.byte(ROT, i)
		if FO  > LEE then --or (string.byte(EOT, i) == WE) then
			CHK = ICT > FGF
			if CHK then CLR = "green"
			--elseif ICT > QHFGF then CLR = "#00FFFF"
			elseif ICT > HFGF then CLR = "#FFC000" --"blue"
			--elseif ICT > QFGF then CLR = "#C000FF"
			else CLR = "red"
			end
			CFC = emu.framecount()
			ICP = math.floor(ICT/FGF*100)
			ITC = ICP%250 >= 200
			--LAG = emu.lagged()
			gui.text(1, 1, "Frame: " .. CFC .. ", Lag: " .. LAG .. "\r\nIndex: " .. i ..
					"\r\nValue: " .. FO .. " [HEX: " .. string.format("%2X", FO) .. "]" ..
					"\r\nID: " .. RO .. " [HEX: " .. string.format("%2X", RO) .. "]" ..
					"\r\nCount: " .. ICT .. " (" .. ICP .. "%)", CLR , "#00")
			if not ITR or ITC then
				ITR = (LRO ~= nil) and (LRO ~= RO)
			end

			DQS = (RO == LEE - 1) or (RO == LEE * 2) or (RO == LEE) or (RO == LEE * 2 + 1)
			if (ITR and CHK) or DQS then
				if DQS then
					gui.text(LEE-25, LEE, "THE END! at FRAME: " .. CFC)
					emu.pause()
					--emu.registerstop()
				end
				emu.message("Found the way!")
				emu.pause()
			end
			if not emu.lagged() then
				ICT = ICT + 1
			else LAG = LAG + 1
			end
			ITS = true
			if (LRO == nil) or ITC then
				emu.message("Detected object ID: " .. RO .. string.format(" [HEX: %2X], Index: " .. i, RO))
				LRO = RO
			end
			break
		else ITS = false end
	end		

	if not ITS and i ~= lst then
		ICT = 0
		LRO = nil
		LAG = 0
	end
	lst = i
	SetInput()
	joypad.set(1, JP)
	SetInput()
	joypad.set(2, JP)
end

emu.registerafter(Main)