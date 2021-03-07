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
	int   finisher: 0x0431FE68, 0x40, 0x240, 0x758, 0x4DC;
}

state("BPMGame-Win64-Shipping", "steam-patch2")
{
	float timer: 0x043BEEE8, 0xDE8, 0x2D5C;
	float death: 0x043AC4F0,  0x30, 0x2B0, 0x370, 0x288, 0x1C8;
	int   world: 0x043AC4F0, 0x268, 0x3B0;
	int   menu:  0x043F0CC8, 0x38, 0x138;
	int   finisher: 0x043C2570, 0x128, 0x6A8, 0x4C8, 0x358, 0x4DC;
	int   pause: 0x043BEEE8, 0x8B8;
	int   boss: 0x043BEEE8, 0xDE8, 0x2E80;
	float bosshp: 0x043C2570, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;
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
	int   finisher: 0x042D5938, 0x20, 0x240, 0x758, 0x4DC;
}

state("BPMGame-Win64-Shipping", "GOG-patch2")
{
	float timer: 0x04374928, 0xDE8, 0x2D5C;
	float death: 0x04361F30, 0x30, 0x2B0, 0x370, 0x288, 0x1C8;
	int   world: 0x04361F30, 0x268, 0x3B0;
	int   menu:  0x043A6708, 0x38, 0x138;
	int   pause: 0x04374928, 0x8B8;
	int   finisher: 0x04377FB0, 0x128, 0x6A8, 0x4C8, 0x358, 0x4DC;
	int   boss: 0x04374928, 0xDE8, 0x2E80;
	float bosshp: 0x04377FB0, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;
}

init
{
	print("Size: " + modules.First().ModuleMemorySize);
	var versions = new Dictionary<int, string>() {
			{75317248, "steam-release"}, 
			{75321344, "steam-patch1"},
			{75427840, "steam-patch2"},
			{74993664, "GOG-release"},
			{75001856, "GOG-patch1"},
			{75096064, "GOG-patch2"}
        };
	
	version = versions[modules.First().ModuleMemorySize];
	print("VERSION: " + version);
	refreshRate = 30; //for load reduction
}

startup {	
	vars.timerValue = 0.0f;
	vars.timerState = 0;

	settings.Add("worldSplit", true, "Split on level transition."); //moved to top since this defaults to true
	settings.Add("allChars", false, "Multi-Character Mode. Auto-reset will be disabled.");
	settings.Add("bossMode", false, "Boss Rush Mode. Splits on boss death.");
	settings.Add("rta", false, "RTA Loadless timing.");

	timer.OnReset += (s,e) => {
		vars.timerValue = 0.0f;
		vars.timerState = 0;
	};
}

update {
	const int STOPPED = 0, RUNNING = 1, PAUSED = 2, RESET = 3;
	string[] STATE = {"STOPPED", "RUNNING", "PAUSED", "RESET"};
	
	bool t_eq_0 = current.timer == 0.0f;
	bool t_eq_t0 = current.timer == old.timer;
	bool t_gt_t0 = current.timer > old.timer;
	bool t_lt_t0 = current.timer < old.timer;

	bool alive = current.death == 0.0f;
	bool death = current.death > 0.0f && old.death == 0.0f;

	bool start = current.timer > 0.0f && old.timer == 0.0f;
	bool paused = current.pause == 1;
	bool mainmenu = current.menu == 1;
	
	Func<int, int> transitions = (timerState) => {
		switch(timerState)
		{
			case STOPPED:
				return (start && alive) ? RUNNING : STOPPED;
			case RUNNING:
				if (paused || t_eq_t0) return PAUSED;
				return ((t_eq_0 && t_lt_t0) || death) ? RESET : RUNNING;
			case PAUSED:
				if (t_gt_t0) return RUNNING;
				return ((t_eq_0 && t_lt_t0) || mainmenu) ? RESET : PAUSED;
			default:
				return STOPPED;
		}
	};
	int prevState = vars.timerState;
	vars.timerState = transitions(vars.timerState);
	if(prevState != vars.timerState)
		print("Timer State: " + STATE[vars.timerState]);
	if (vars.timerState == RESET && !settings["rta"]) {
		vars.timerValue = settings["allChars"]
			? vars.timerValue + (alive ? old.timer : current.death)
			: 0.0f;
	}
}

start {
	return vars.timerState == 1;
}

isLoading {
	 //remove loads from RTA
	return settings["rta"] 
		? (vars.timerState == 0 || vars.timerState == 3 || (vars.timerState == 2 && current.pause == 0))
		: true;
}

gameTime {
	if(!settings["rta"]) {
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
}

split {	
	return (settings["worldSplit"] && current.world == old.world + 1)
		|| (settings["bossMode"] && current.boss == old.boss + 1 && current.bosshp <= 0)
		|| (current.finisher == 9 && old.finisher == 8); //consolidated nidhogg split methods
}

reset {
	return !settings["allChars"] && vars.timerState == 3;
}
