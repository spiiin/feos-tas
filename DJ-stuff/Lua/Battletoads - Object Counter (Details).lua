--Battletoads - Details for Object Counter by TheZlomuS
--Shows all details for OC
RA = 0x10000 + 0x10
OCR = 0xB
CNT = OCR + (0x10 - OCR) - 1
OCA = OCR * 0x10 + 7
OCC = -1
OCV = -1
OCS = ""
OCT = {}
OIA = 0x3C1
COT = {}
OAA = OIA + 0x1C2
CAT = {}

function Main()
	OCC = memory.readbyte(OCA) + memory.readbyte(OCA + 1) * 0x100
	COT = memory.readbyterange(OIA, CNT)
	CAT = memory.readbyterange(OAA, CNT)
	if OCC < 0x8000 then
		OCT = memory.readbyterange(OCC, OCR)
	else
		OCT = ""
		for i = 0, OCR do
			OCT = OCT .. string.char(rom.readbyte(OCC + RA + i))
		end
	end
	OCS = "ID[H]: "
	for i = 1, CNT do
		OCV = string.byte(COT, i)
		OCS = OCS .. string.format("%2X", OCV) .. "|"
	end
	OCS = OCS .. "\nA2[H] "
	for i = 1, CNT do
		OCV = string.byte(CAT, i)
		OCS = OCS .. string.format("%2X", OCV) .. "|"
	end
	OCS = OCS .. "\nINFO [SHC]: ID, ??,??,XH,XL,YH,YL,ZH,ZL,A2,??\nOCO [HEX]: "
	for i = 1, OCR do
		OCV = string.byte(OCT, i)
		OCS = OCS .. "|" .. string.format("%2X", OCV)
	end
	OCS = OCS .. "|\nOCL [HEX]: "
	for i = 1, OCR do
		OCV = (OCC + i - 1) % 0x100
		OCS = OCS .. "|" .. string.format("%2X", OCV)
	end
	OCS = OCS .. "|\n" .. "OCC [HEX]: " .. string.format("%X\tOCA [HEX]: %X", OCC, OCA)
	gui.text(1, 1, OCS)
end

emu.registerafter(Main)