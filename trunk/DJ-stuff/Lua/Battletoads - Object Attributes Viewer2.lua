-- TheZlomuS and feos, 2012
-- Battletoads Object RAM Viewer

require 'auxlib';

Root = 0x3C0;	-- Objects start address
Offs = 0xF;		-- Number of slots

-- Instert anything to check
-- You can check for single bit matches applying AND masks
Highlight = {
	--{CheckName="ID", CheckVal=0x01, Color="64 64 64"},	-- Player 1
	--{CheckName="ID", CheckVal=0x02, Color="32 32 32"},	-- Player 2
	{CheckName="ID", CheckVal=0x22, CheckName2="Target", CheckVal2=0x55, Color="0 0 192"},	-- Object Effector
	{CheckName="ID", CheckVal=0x7E, CheckName2="Cntr2", CheckVal2=0x7F, Color="0 192 0"},	-- Dark Queen
	{CheckName="ID", CheckVal=0x7F, CheckName2="VarFlg", CheckVal2=0x7F, Color="192 0 0"}	-- Level End
}

-- Whole Object RAM block
Attribs = {
	{name="ID",    shift=0}, -- 1
	{name="Anim1", shift=0}, -- 2
	{name="Cntr1", shift=0}, -- 3
	{name="Xpos",  shift=0}, -- 4 -> 4,5
	{name="Ypos",  shift=1}, -- 5 -> 6,7
	{name="Zpos",  shift=2}, -- 6 -> 8,9
	{name="Xsub",  shift=3}, -- 7
	{name="Ysub",  shift=3}, -- 8
	{name="Zsub",  shift=3}, -- 9
	{name="Zshad", shift=3}, -- 10
	{name="Xshad", shift=3}, -- 11
	{name="Yshad", shift=3}, -- 12
	{name="Flag",  shift=3}, -- 13
	{name="State", shift=3}, -- 14
	{name="Zspd",  shift=3}, -- 15
	{name="Unk1",  shift=3}, -- 16
	{name="Cntr2", shift=3}, -- 17
	{name="HitID", shift=3}, -- 18
	{name="HitTmr",shift=3}, -- 19
	{name="HP",    shift=3}, -- 20
	{name="Linked",shift=3}, -- 21
	{name="Linker",shift=3}, -- 22
	{name="AnmTmr",shift=3}, -- 23
	{name="Unk2",  shift=3}, -- 24
	{name="Xspd",  shift=3}, -- 25
	{name="DthTmr",shift=3}, -- 26
	{name="Anim2", shift=3}, -- 27
	{name="Target",shift=3}, -- 28
	{name="VarFlg",shift=3}, -- 29
	{name="Unk3",  shift=3}, -- 30
	{name="EndTmr",shift=3}, -- 31
};

-- Matrix
local mat = iup.matrix {
	numcol=Offs, numlin=#Attribs, numcol_visible=Offs, numlin_visible=Offs,
	width0="26", widthDef="20", heigth="6"
};

-- Headers BG color
for c=0,#Attribs do
	for l=0,Offs do
		mat["bgcolor".. 0 ..":".. l] = "80 0 0";
		mat["bgcolor".. c ..":".. 0] = "80 0 0";
	end;
end;

-- Line headers
for i,v in pairs(Attribs) do
	mat:setcell(i,0,v.name);
end;

-- Column headers
for i=1, Offs do
	mat:setcell(0,i,i);
end;

-- Table colors
mat.bgcolor = "0 0 0";
mat.fgcolor = "255 255 255";

-- Dialog name and pos
dialogs = dialogs + 1;
handles[dialogs] = iup.dialog{
	iup.vbox{mat,iup.fill{}},
	title="Battletoads - Object Attribute Viewer",
	size="448x236"
};
handles[dialogs]:showxy(iup.CENTER, iup.CENTER);

function DrawText(i, v, Slot, Val)
	gui.text(1,i*10-9, v.name..":")
	gui.text(1+Slot*16+18, i*10-9, string.format("%X:%02X",Slot,Val))
end;

function IsPlayer()
	if (LastSpecialID == 0x1) or (LastSpecialID == 0x2) or (LastSpecialID == 0x81) or (LastSpecialID == 0x82) then
		return true;
	else return false;
	end;
end;

-- Values calculation
function DrawMatrix()
	IsFound = false;
	LastSpecialSlot = 0;
	ColorToSet = "0 0 0";
	LastSpecialID = 0;
	for i,v in ipairs(Attribs) do	-- i    = line
		for Slot = 1, Offs do		-- Slot = column
			Address = (Root+(i+v.shift-1)*Offs+Slot);
			if i>=4 and i<=6 then	-- Position
				Val = memory.readbyte(Address)*0x100 + memory.readbyte(Address+Offs);
				mat:setcell(i,Slot,string.format("%04X",Val));
			else
				Val = memory.readbyte(Address);
				mat:setcell(i,Slot,string.format("%02X",Val));
			end;
			
			
			-- Highlight the cell and print debug info on matches
			-- You can add virtual breakpoints with memory.register library		
			for _,case in ipairs(Highlight) do
				if v.name == case.CheckName and (Val == case.CheckVal or Val == case.CheckVal + 0x80) then
					IsFound = true;
					LastSpecialSlot = Slot;
					LastSpecialID = Val;
					ColorToSet = case.Color;
				end;
				if IsFound and LastSpecialSlot == Slot and (LastSpecialID == 0x22 and v.name == case.CheckName2 and Val == case.CheckVal2) then --or IsPlayer() then --not work!
					mat["bgcolor*:".. Slot] = case.Color;
					DrawText(i, v, Slot, Val);
					IsFound = false;
				elseif IsFound and LastSpecialSlot == Slot and v.name == case.CheckName2 and Val > case.CheckVal2 then
					mat["bgcolor*:".. Slot] = ColorToSet;
					DrawText(i, v, Slot, Val);
					IsFound = false;
				--else mat.bgcolor = "0 0 0"; i GIVE UP IM NOT GUI PROGRAMER!!!
				end;				
			end;
		end;
		
	end;	
	 
	--if not IsFound then mat.bgcolor = "0 0 0"; end; --NOT WORK!
	mat.redraw = "C1:15";
end;

emu.registerafter(DrawMatrix);