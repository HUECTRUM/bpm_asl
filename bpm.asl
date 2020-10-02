state("BPMGame-Win64-Shipping", "release-steam")
{
	float timer: 0x43A68F8, 0x58, 0x1944;
	int   world: 0x4393F30, 0x268, 0x368;
	int   menu:  0x43D7340, 0x328, 0x108, 0x58;
}

state("BPMGame-Win64-Shipping", "patch1-steam")
{
	float timer: 0x43A7C78, 0x58, 0x1944;
	float death: 0x43952B0, 0x30, 0x50, 0x2B0, 0x370, 0x288, 0x160;
	int   world: 0x43952B0, 0x268, 0x368;
	int   menu:  0x43D86C0, 0x328, 0x108, 0x58;
	// int   pause: 0x043AB330, 0x128, 0x2B8;
	// int   alive: 0x043D8BF8, 0x498;
	int   finale: 0x0431FE68, 0x40, 0x240, 0x758, 0x4DC;
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
	float death: 0x0434AD70, 0x30, 0x2B0, 0x370, 0x288, 0x160;
	int   world: 0x0435D738, 0x58, 0x1930;
	int   menu:  0x0438E180, 0x368, 0x78, 0x68;
	// int   pause: 0x04360DF0, 0x128, 0x2B8;
	// int   alive: 0x0438E160, 0x64;
	int   finale: 0x042D5938, 0x20, 0x240, 0x758, 0x4DC;
}

init
{
	int mSize = modules.First().ModuleMemorySize;
	print("MODULE SIZE:" + mSize.ToString());
	
	switch(mSize) {
		case 75317248:
			version = "release-steam";
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
	vars.timerValue = 0.0f;
	vars.timerState = 0;

	settings.Add("allChars", false, "All Characters Mode. Auto-reset will be disabled after first character.");
	settings.Add("bossMode", false, "Boss Rush Mode. Splits on boss death.");
	settings.Add("worldSplit", true, "Split on level transition.");

	timer.OnReset += (s,e) => vars.timerValue = 0.0f;
}

update {
	bool t_eq_0 = current.timer == 0.0f;
	bool t_eq_t0 = current.timer == old.timer;
	bool t_gt_t0 = current.timer > old.timer;
	bool t_lt_t0 = current.timer < old.timer;
	bool alive = current.death == 0.0f;
	bool dead = current.death > 0.0f;
	bool start = current.timer > 0.0f && old.timer == 0.0f;
	bool exit = current.menu == 1 && old.menu == 0;

	int state = vars.timerState;
	switch(state)
	{
		case 0:	//stopped
			if(start || (t_gt_t0 && alive))
				vars.timerState = 1;
			break;
		case 1:	//running
			if(t_eq_t0)
				vars.timerState = 2;
			else if((t_eq_0 && t_lt_t0) || dead)
				vars.timerState = 3;
			break;
		case 2:	//paused
			if(t_gt_t0) 
				vars.timerState = 1;
			else if((t_eq_0 && t_lt_t0) || exit)
				vars.timerState = 3;
			break;
		case 3:	//reset
			vars.timerState = 0;
			break;
	}
}

start {
	return current.timer > 0.0f && old.timer == 0.0f;
}

isLoading {
	return true;
}

gameTime {
	float display_time = 0.0f;
	bool alive = current.death == 0.0f;
	int state = vars.timerState;
	switch(state)
	{
		case 0: //stopped
			display_time = settings["allChars"] ? vars.timerValue : current.timer;
			break;
		case 3: //reset
			if(settings["allChars"])
				vars.timerValue += alive ? old.timer : current.death;
			else
				vars.timerValue = 0.0f;
			display_time = vars.timerValue;
			break;
		default:
			display_time = vars.timerValue + current.timer;
			break;
	}
	return TimeSpan.FromSeconds(display_time);
}

split {
	bool boss = (current.finale == 5 && old.finale == 4) ||
				(current.finale == 6 && old.finale == 5);//svartalfheim 1 boss finale is 6 shots
	bool nextWorld = current.world == old.world + 1;
	bool nidhogg = (current.world == 7 && current.finale == 9 && old.finale == 8) 
				|| (current.world == 0 && old.world == 7 && current.menu == 0);
	return (settings["worldSplit"] && nextWorld) || (settings["bossMode"] && boss) || nidhogg;
}

reset {
	return !settings["allChars"] && vars.timerState == 3;
}
