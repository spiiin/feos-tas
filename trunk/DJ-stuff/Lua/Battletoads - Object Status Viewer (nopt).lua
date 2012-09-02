--Battletoads Object Status Viewer by TheZlomuS
-- v0.01a (not optimalized!)
-- include known stat of objects
require 'auxlib';

local function toHexStr(n)
	return string.format("%X",n);
end;

local function getMem(n)
	return memory.readbyte(n);
end;

--pos_start_addr = 0x3ed;
--pos_end_addr = 0x447;
i_xyz_start = 3;
--i_xyz_end = 8;
--i_flag = 0x1f;
start_addr = 0x3c0;
NO = 0xf; --nr. obj.
NL = 0x20 - i_xyz_start; --nr. lin.
WO = 0x22;
WE = 0x55;
EO = 0x7f;

local mat = iup.matrix {
numcol=NO, numlin=NL, numcol_visible=NO, numlin_visible=NO,
width0="22",
width1="18",
width2="18",
width3="18",
width4="18",
width5="18",
width6="18",
width7="18",
width8="18",
width9="18",
width10="22",
width11="22",
width12="22",
width13="22",
width14="22",
width15="22",
heigth="6"};
mat:setcell(0,0,"ObjSt");

for i=1, NL do
	if i == 1 then
		mat:setcell(i,0,"ObjID");
	elseif i == 2 then
		mat:setcell(i,0,"ObjMd");
	elseif i == i_xyz_start then
		mat:setcell(i,0,"ObjX");
		--k = 1;
	elseif i == i_xyz_start + 1 then
		mat:setcell(i,0,"ObjY");
		--k = k + 1;
	elseif i == i_xyz_start + 2 then
		mat:setcell(i,0,"ObjZ");
	elseif i == i_xyz_start + 10 then
		mat:setcell(i,0,"ObjCR"); --charge/reversal status
	elseif i == i_xyz_start + 11 then
		mat:setcell(i,0,"ObjMv");
	elseif i == i_xyz_start + 12 then
		mat:setcell(i,0,"ObjSt");
	elseif i == i_xyz_start + 14 then
		mat:setcell(i,0,"ObjTm");
	--elseif i == i_xyz_start + 5 then
	--	mat:setcell(i,0,"ObjX");
	--	--k = 1;
	--elseif i == i_xyz_start + 3 then
	--	mat:setcell(i,0,"ObjHZ");
	--	--k = k + 1;
	--elseif i == i_xyz_start + 5 then
	--	mat:setcell(i,0,"ObjHY");
	--	--k = k + 1;
	elseif i == NL - 10 then
		mat:setcell(i,0,"ObjCt"); --counter
	elseif i == NL - 9 then
		mat:setcell(i,0,"ObjCd"); --counted
	elseif i == NL - 8 then
		mat:setcell(i,0,"ObjHP");
	elseif i == NL - 7 then
		mat:setcell(i,0,"ObjLd");
	elseif i == NL - 6 then
		mat:setcell(i,0,"ObjLr");
	elseif i == NL - 4 then
		mat:setcell(i,0,"ObjDr");
	elseif i == NL - 3 then
		mat:setcell(i,0,"ObjSp");
	elseif i == NL - 1 then
		mat:setcell(i,0,"ObjEv");
	elseif i == NL then
		mat:setcell(i,0,"ObjFg");
	else
		mat:setcell(i,0,"Unk" .. i);
	end;
end;

for i=1, NO do
	mat:setcell(0,i,"Obj" .. i);
end;

mat.bgcolor = "0 0 0";

dialogs = dialogs + 1;
handles[dialogs] = 
	iup.dialog{
		iup.vbox{
			--iup.fill{size="5"},
			mat,
			iup.fill{},
		},
		title="Battletoads Object Status Viewer",
		size="460x236"--,
		--margin="10x10"
	};

handles[dialogs]:showxy(iup.CENTER, iup.CENTER);

while (true) do
	k = 0;
	currobjidx = 0;
	--local cols = tonumber(mat.numcol);
	for i=1, NL do
		if i+k >= i_xyz_start and i+k <= i_xyz_start + 4 then
			for j=1, NO do
				temp = getMem(start_addr+(i+k-1)*NO+j) + 0x100*getMem(start_addr+(i+k)*NO+j);
				mat:setcell(i,j,toHexStr(temp));
			end;
			k = k + 1;
			--i = i + 1;
		else
			for j=1, NO do
				temp = getMem(start_addr+(i+k-1)*NO+j);
				mat:setcell(i,j,toHexStr(temp));
				if i == 1 and (temp == WO or temp == EO or temp == EO - 1) then
					specfound = true;
					currobj = temp;
					currobjidx = j;
				end;
				if specfound then
					if currobj == WO and (i == NL - 1) and (temp == WE or temp == WE + 1) and j == currobjidx then
						mat.bgcolor = "0 0 192";
					elseif (currobj == EO - 1) and i == NL and temp > EO and j == currobjidx then
						mat.bgcolor = "0 192 0";
						--emu.pause();
					elseif currobj == EO then
						mat.bgcolor = "192 0 0";
					--else
						--specfound = false;
					end;
				end;

					
	--bgcolor_cb
				--gui.text(1,1,start_addr+i*NO+j .. "");
			end;
		end;
	end;
	--if not specfound then
	if getMem(start_addr+currobjidx) ~= currobj then
		currobj = 0;
		currobjidx = 0;
		mat.bgcolor = "0 0 0";
		specfound = false;
	end;
	--end;
	mat.fgcolor = "255 255 255";
		
	mat.redraw = "C1:15"; --= "L1:15";
	--mat.bgcolor = "0 0 0";
	--mat.redraw = "C1:15";
	
	FCEU.frameadvance();
end;
