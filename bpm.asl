state("BPMGame-Win64-Shipping", "steam-release")
{
	float timer: 0x43A68F8, 0x58, 0x1944;
	int   world: 0x4393F30, 0x268, 0x368;
	int   menu:  0x43D7340, 0x328, 0x108, 0x58;
}

state("BPMGame-Win64-Shipping", "steam-patch1")
{
	float timer: 0x43A7C78, 0x58, 0x1944;
	float death: 0x43952B0, 0x30, 0x50, 0x2B0, 0x370, 0x288, 0x160;
	int   world: 0x43952B0, 0x268, 0x368;
	int   menu:  0x43D86C0, 0x328, 0x108, 0x58;
	int   finale: 0x0431FE68, 0x40, 0x240, 0x758, 0x4DC;
}

state("BPMGame-Win64-Shipping", "GOG-release")
{
	float timer: 0x0435B378, 0x58, 0x1944;
	int   world: 0x0435B3A8, 0xDE8, 0x1930;
	int   menu:  0x0438BDC0, 0x368, 0xA8, 0x58;
}

state("BPMGame-Win64-Shipping", "GOG-patch1")
{
	float timer: 0x0435D768, 0xDE8, 0x1944;
	float death: 0x0434AD70, 0x30, 0x2B0, 0x370, 0x288, 0x160;
	int   world: 0x0435D738, 0x58, 0x1930;
	int   menu:  0x0438E180, 0x368, 0x78, 0x68;
	int   finale: 0x042D5938, 0x20, 0x240, 0x758, 0x4DC;
}


init
{
	var versions = new Dictionary<int, string>() {
                {75317248, "steam-release"}, {75321344, "steam-patch1"},
		{74993664, "GOG-release"}, {75001856, "GOG-patch1"},
        };
	
	version = versions[modules.First().ModuleMemorySize];
	print("VERSION: " + version);
}

startup {	
	vars.timerValue = 0.0f;
	vars.timerState = 0;

	settings.Add("allChars", false, "All Characters Mode. Auto-reset will be disabled.");
	settings.Add("bossMode", false, "Boss Rush Mode. Splits on boss death.");
	settings.Add("worldSplit", true, "Split on level transition.");

	timer.OnReset += (s,e) => vars.timerValue = 0.0f;
}

update {
	const int STOPPED = 0, RUNNING = 1, PAUSED = 2, RESET = 3;
	
	bool t_eq_0 = current.timer == 0.0f;
	bool t_eq_t0 = current.timer == old.timer;
	bool t_gt_t0 = current.timer > old.timer;
	bool t_lt_t0 = current.timer < old.timer;

	bool alive = current.death == 0.0f;
	bool death = current.death > 0.0f && old.death == 0.0f;

	bool start = current.timer > 0.0f && old.timer == 0.0f;
	bool exit = current.menu == 1 && old.menu == 0;
	
	Func<int, int> transitions = (timerState) => {
		switch(timerState)
		{
			case STOPPED:
				return (start || (t_gt_t0 && alive)) ? RUNNING : STOPPED;
			case RUNNING:
				if (t_eq_t0) return PAUSED;
				return ((t_eq_0 && t_lt_t0) || death) ? RESET : RUNNING;
			case PAUSED:
				if (t_gt_t0) return RUNNING;
				return ((t_eq_0 && t_lt_t0) || exit) ? RESET : PAUSED;
			default:
				return STOPPED;
		}
	};
	vars.timerState = transitions(vars.timerState);
	
	if (vars.timerState == RESET) {
		vars.timerValue = settings["allChars"]
			? vars.timerValue + (alive ? old.timer : current.death)
			: 0.0f;
	}
}

start {
	return current.timer > 0.0f && old.timer == 0.0f;
}

isLoading {
	return true;
}

gameTime {
	const int STOPPED = 0, RUNNING = 1, PAUSED = 2, RESET = 3;
	
	Func<int, double> stateToSeconds = (timerState) => {
		switch(timerState)
		{
			case STOPPED:
				return settings["allChars"] ? vars.timerValue : current.timer;
			case RESET:
				return vars.timerValue;
			default:
				return vars.timerValue + current.timer;
		}
	};
	
	return TimeSpan.FromSeconds(stateToSeconds(vars.timerState));
}

split {
	bool nidhogg = version.StartsWith("steam") 
		? (current.world == 0 && old.world == 7 && current.menu == 0)
		: (current.world == 7 && current.finale == 9 && old.finale == 8) ;
	
	return (settings["worldSplit"] && current.world == old.world + 1) 
		|| (settings["bossMode"] && current.finale == 5 && old.finale == 4) 
		|| nidhogg;
}

reset {
	return !settings["allChars"] && vars.timerState == 3;
}
