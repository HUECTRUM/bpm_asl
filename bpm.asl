state("BPMGame-Win64-Shipping", "release")
{
	float timer: 0x43A68F8, 0x58, 0x1944;
	int   world: 0x4393F30, 0x268, 0x368;
	int   menu:  0x43D7340, 0x328, 0x108, 0x58;
}

state("BPMGame-Win64-Shipping", "patch1-steam")
{
	float timer: 0x43A7C78, 0x58, 0x1944;
	int   world: 0x43952B0, 0x268, 0x368;
	int   menu:  0x43D86C0, 0x328, 0x108, 0x58;
}

state("BPMGame-Win64-Shipping", "release-GOG")
{
	float timer: 0x0435B378, 0x58, 0x1944;
	int   world: 0x0435B3A8, 0xDE8, 0x1930;
	int   menu:  0x0438BDC0, 0x368, 0xA8, 0x58;
	//int   charSel: 0x043489B0, 0x1E8, 0x3A0, 0x288, 0x818;
	//int   pause: 0x0435B3A8, 0x8B8;
}

state("BPMGame-Win64-Shipping", "patch1-GOG")
{
	float timer: 0x0435D768, 0xDE8, 0x1944;
	int   world: 0x0435D738, 0x58, 0x1930;
	int   menu:  0x0438E180, 0x368, 0x78, 0x68;
	//int   charSel: 0x043489B0, 0x1E8, 0x3A0, 0x288, 0x818;
	//int   pause: 0x0435B3A8, 0x8B8;
}

init
{
	int mSize = modules.First().ModuleMemorySize;
	print("MODULE SIZE:" + mSize.ToString());
	
	switch(mSize) {
		case 75317248:
			version = "release";
			break;
		case 74993664:
			version = "release-GOG";
			break;
		case 75321344:
			version = "patch1-steam";
			break;
		case 75001856:
			version = "patch1-GOG";
			break;
		default:
			version = "unknown";
			break;
	}
	
	print("VERSION: " + version);
}

startup {
	vars.pauseMenuRestart = false;
	vars.exitToMainMenu = false;
	vars.timerValue = 0.0f;
	vars.timerState = 0; //0b00 = stopped 0b01 = running 0b10 = paused 0b11 = reset

	settings.Add("allChars", false, "All Characters Mode");

	timer.OnReset += (s,e) => vars.timerValue = 0.0f;
}

update {
	vars.pauseMenuRestart = current.timer == 0.0f && old.timer != 0.0f;
	vars.exitToMainMenu = current.menu == 1 && old.menu == 0;

	int state_machine_input = (current.timer < old.timer ? 0x8 : 0x0) | (current.timer > old.timer ? 0x4 : 0x0) | (current.timer == old.timer ? 0x2 : 0x0) | (current.timer == 0.0f ? 0x1 : 0x0);

	switch(state_machine_input)
	{
		case 0x2:
			vars.timerState = 0x2;
			break;
		case 0x3:
			vars.timerState = 0x0;
			break;
		case 0x4:
			vars.timerState = 0x1;
			break;
		case 0x9:
			vars.timerState = 0x3;
			break;
		default:
			break;
	} 
}

start {
	return current.world == 0 && Math.Abs(current.timer) > 1e-6 && Math.Abs(old.timer) < 1e-6;
}

isLoading {
	return true;
}

gameTime {
	float display_time = 0.0f;
	int state = vars.timerState;
	switch(state)
	{
		case 0x0: //stopped
			if(settings["allChars"])
				display_time = vars.timerValue;
			else
				display_time = current.timer;
			break;
		case 0x1: //running
			display_time = vars.timerValue + current.timer;
			break;
		case 0x2: //paused
			display_time = vars.timerValue + current.timer;
			break;
		case 0x3: //reset
			if(settings["allChars"])
				vars.timerValue += old.timer;
			else
				vars.timerValue = 0.0f;
			break;
	}
	return TimeSpan.FromSeconds(display_time);
}

split {
	return (current.world == old.world + 1) || (current.world == 0 && old.world == 7 && current.menu == 0);
}

reset {
	return  settings["allChars"] 
				? false
				: (vars.timerState == 0x3 ? true : false) /*|| vars.pauseMenuRestart || vars.exitToMainMenu*/;
}
