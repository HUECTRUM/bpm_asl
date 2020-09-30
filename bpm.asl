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
	int   pause: 0x043AB330, 0x128, 0x2B8;
	int   alive: 0x043D8BF8, 0x498;
}

state("BPMGame-Win64-Shipping", "release-GOG")
{
	float timer: 0x0435B378, 0x58, 0x1944;
	int   world: 0x0435B3A8, 0xDE8, 0x1930;
	int   menu:  0x0438BDC0, 0x368, 0xA8, 0x58;
}

state("BPMGame-Win64-Shipping", "patch1-GOG")
{
	float timer: 0x0435D768, 0xDE8, 0x1944;
	int   world: 0x0435D738, 0x58, 0x1930;
	int   menu:  0x0438E180, 0x368, 0x78, 0x68;
	int   pause: 0x04360DF0, 0x128, 0x2B8;
	int   alive: 0x0438E160, 0x64;
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
	vars.exitToMainMenu = false;
	vars.timerValue = 0.0f;
	vars.timerState = 0;

	settings.Add("allChars", false, "All Characters Mode. Auto-reset will be disabled.");

	timer.OnReset += (s,e) => vars.timerValue = 0.0f;
}

update {
	vars.exitToMainMenu = current.menu == 1 && old.menu == 0;

	bool t_eq_0 = current.timer == 0.0f;
	bool t_eq_t0 = current.timer == old.timer;
	bool t_gt_t0 = current.timer > old.timer;
	bool t_lt_t0 = current.timer < old.timer;

	int state = vars.timerState;
	switch(state)
	{
		case 0:	//stopped
			if(t_gt_t0 && current.alive == 1)
				vars.timerState = 1;
			break;
		case 1:	//running
			if(t_eq_t0)
				vars.timerState = 2;
			else if((t_eq_0 && t_lt_t0) || current.alive == 0)
				vars.timerState = 3;
			break;
		case 2:	//paused
			if(t_gt_t0)
				vars.timerState = 1;
			else if((t_eq_0 && t_lt_t0) || vars.exitToMainMenu)
				vars.timerState = 3;
			break;
		case 3:	//reset
			vars.timerState = 0;
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
		case 0: //stopped
			if(settings["allChars"])
				display_time = vars.timerValue;
			else
				display_time = current.timer;
			break;
		case 1: //running
			display_time = vars.timerValue + current.timer;
			break;
		case 2: //paused
			display_time = vars.timerValue + current.timer;
			break;
		case 3: //reset
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
				: (vars.timerState == 0x3 ? true : false);
}
