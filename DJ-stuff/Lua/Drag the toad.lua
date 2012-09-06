-- Drand the toad with the mouse.
-- Up/down still works.

a1xl = 0x3fd
a1xh = 0x3ee
a1yl = 0x439
a1yh = 0x42a
a2xl = a1xl + 1
a2xh = a1xh + 1
a2yl = a1yl + 1
a2yh = a1yh + 1
ax = 0x484
ay = ax+0xf
y1 = 0
y2 = 0
function main()
	inp = input.get()
	if not inp.leftclick then
		y1 = memory.readbyteunsigned(a1yl) + 256 * memory.readbytesigned(a1yh)
		y2 = memory.readbyteunsigned(a2yl) + 256 * memory.readbytesigned(a2yh)
		gui.text(1, 25, "y1: " .. y1 .. " y2: " .. y2)
	else
		cx = memory.readbyte(0x87) + 256*memory.readbyte(0x88)
		--cy = memory.readbyte(0x89) + 256*memory.readbyte(0x90)
		
		xm = inp.xmouse
		ym = inp.ymouse
		
		sy1 = y1 + (170 - ym)
		sy2 = y2 + (170 - ym)
		scx = cx + xm
		
		gui.text(1, 1, "xm: " .. xm .. " ym: " .. ym)
		gui.text(1, 9, "cx: " .. cx)
		gui.text(1, 17, "sy1: " .. sy1 .. " sy2: " .. sy2)
		
		
		
		memory.writebyte(ax, xm)
		--memory.writebyte(ax+1, xm)
		memory.writebyte(ay, ym)
		--memory.writebyte(ay+1, ym)

		memory.writebyte(a1xl, scx)
		memory.writebyte(a1yl, sy1)
		memory.writebyte(a2xl, scx)
		memory.writebyte(a2yl, sy2)
		
		memory.writebyte(a1xh, math.floor(scx/256))
		memory.writebyte(a1yh, math.floor(sy1/256))
		memory.writebyte(a2xh, math.floor(scx/256))
		memory.writebyte(a2yh, math.floor(sy2/256))
	end
end

emu.registerafter(main)