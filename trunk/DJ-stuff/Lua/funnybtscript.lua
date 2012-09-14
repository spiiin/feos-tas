--Battletoads - Allways Run!

while (true) do
	memory.writebyte(0x4a2, bit.bor(memory.readbyte(0x4a2), 0x10))
	memory.writebyte(0x4a3, bit.bor(memory.readbyte(0x4a3), 0x10))
	emu.frameadvance()
end