--Battletoads - Object Respawner by TheZlomuS
--o_slots =	0xF
o_id =	0x3C1
o_model =	0x3d0
o_x_l =	0x3FD
o_z_l =	0x493
o_y_l =	0x439
o_x_h =	0x3EE
o_z_h =	0x40C
o_y_h =	0x42A
o_speed =	0x565
o_event =	0x583
o_flag =	0x592
o_timer =	0x4DE
o_hp =	0x51a
require("auxlib");

function ShowDlg()
	los = iup.list{"Object Slot 1","Object Slot 2","Object Slot 3","Object Slot 4","Object Slot 5",
									"Object Slot 6","Object Slot 7","Object Slot 8","Object Slot 9","Object Slot 10",
									"Object Slot 11","Object Slot 12","Object Slot 13","Object Slot 14","Object Slot 15";
						  dropdown="YES",expand="YES",value="3"}
	toid = iup.text{value="0", expand="YES"}
	tom = iup.text{value="0", expand="YES", readonly="YES"}
	tox = iup.text{value="0", expand="YES"}
	toy = iup.text{value="0", expand="YES"}
	toz = iup.text{value="0", expand="YES"}
	tot = iup.text{value="0", expand="YES"}
	tos = iup.text{value="0", expand="YES"}
	toe = iup.text{value="0", expand="YES"}
	tof = iup.text{value="0", expand="YES"}
	tohp = iup.text{value="0", expand="YES"}
	bsro = iup.button{title="Set Respawn Object", expand="YES"}
	bgro = iup.button{title="Get Respawn Object", expand="YES"}
	bsro.action = 
		function (self)
			memory.writebyte(o_id + los.value - 1, toid.value)
			--memory.writebyte(o_model + los.value - 1, tom.value)
			memory.writebyte(o_x_l + los.value - 1, tox.value % 256)
			memory.writebyte(o_x_h + los.value - 1, math.floor(tox.value / 256))
			memory.writebyte(o_z_l + los.value - 1, toz.value % 256)
			--gui.text(1, 1, math.floor(toy.value / 256, 1) ..  "")
			memory.writebyte(o_z_h + los.value - 1, math.floor(toz.value / 256))
			memory.writebyte(o_y_l + los.value - 1, toy.value  % 256)
			memory.writebyte(o_y_h + los.value - 1, math.floor(toy.value / 256))
			memory.writebyte(o_timer + los.value - 1, tot.value)
			memory.writebyte(o_speed + los.value - 1, tos.value)
			memory.writebyte(o_event + los.value - 1, toe.value)
			memory.writebyte(o_flag + los.value - 1, tof.value)
			memory.writebyte(o_hp + los.value - 1, tohp.value)
			emu.message("Object Respawned!")
		end
	
	bgro.action = 
		function (self)
			toid.value = memory.readbyte(o_id + los.value - 1)
			tom.value = memory.readbyte(o_model + los.value - 1)
			tox.value = memory.readbyte(o_x_l + los.value - 1) + 256 * memory.readbyte(o_x_h + los.value - 1)
			toz.value = memory.readbyte(o_z_l + los.value - 1) + 256 * memory.readbyte(o_z_h + los.value - 1)
			toy.value = memory.readbyte(o_y_l + los.value - 1) + 256 * memory.readbyte(o_y_h + los.value - 1)
			tot.value = memory.readbyte(o_timer + los.value - 1)
			tos.value = memory.readbyte(o_speed + los.value - 1)
			toe.value = memory.readbyte(o_event + los.value - 1)
			tof.value = memory.readbyte(o_flag + los.value - 1)
			tohp.value = memory.readbyte(o_hp + los.value - 1)
		end
	
	dialogs = dialogs + 1;
	handles[dialogs] = 
		iup.dialog{
			title="Battletoads - Object Respawner",
			size="125x",
		  iup.vbox{
				--gap="5",
				--margin="5x5",
				bgro,
				iup.hbox{
				  iup.frame{
						title="Respawn Options",
						iup.vbox{
							los,
						  iup.label{title="Object ID:"},
						  toid,
						  iup.label{title="Object Model:"},
						  tom,
						  iup.label{title="Object X:"},
						  tox,
						  iup.label{title="Object Y:"},
						  toy,
						  iup.label{title="Object Z:"},
						  toz,
						  iup.label{title="Object Timer:"},
						  tot,
						  iup.label{title="Object Hit Points:"},
						  tohp,
						  iup.label{title="Object Speed:"},
						  tos,
						  iup.label{title="Object Event:"},
						  toe,
						  iup.label{title="Object Flag:"},
						  tof,
						}
				  },
				--iup.canvas{bgcolor="128 255 0"},
				--gap="5",
				--alignment="ARIGHT",
				--alignment="CENTER",
				
				},
				bsro,
				margin="5x5"
		  }
		};

	handles[dialogs]:show();
end


function Main()
	
end

ShowDlg()

while (true) do
--gui.text( 1, 1, (o_flag + los.value - 1))
	FCEU.frameadvance()
end
