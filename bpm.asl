state("BPMGame-Win64-Shipping", "steam-release")
{
	float timer: 	0x43A68F8, 0x58,  0x1944;
	int   world: 	0x4393F30, 0x268, 0x368;
	int   menu:  	0x43D7340, 0x328, 0x108, 0x58;
}

state("BPMGame-Win64-Shipping", "GOG-release")
{
	float timer: 	0x435B378, 0x58,  0x1944;
	int   world: 	0x435B3A8, 0xDE8, 0x1930;
	int   menu:  	0x438BDC0, 0x368, 0xA8, 0x58;
}

state("BPMGame-Win64-Shipping", "steam-patch1")
{
	float timer: 	0x43A7C78, 0x58,  0x1944;
	float death: 	0x43952B0, 0x30,  0x50,  0x2B0, 0x370, 0x288, 0x160;
	int   world: 	0x43952B0, 0x268, 0x368;
	int   menu:  	0x43D86C0, 0x328, 0x108, 0x58;
	int   finisher: 0x431FE68, 0x40, 0x240, 0x758, 0x4DC;
}

state("BPMGame-Win64-Shipping", "GOG-patch1")
{
	float timer: 	0x435D768, 0xDE8, 0x1944;
	float death: 	0x434AD70, 0x30,  0x2B0, 0x370, 0x288, 0x160;
	int   world: 	0x435D738, 0x58,  0x1930;
	int   menu:  	0x438E180, 0x368, 0x78, 0x68;
	int   finisher: 0x42D5938, 0x20,  0x240, 0x758, 0x4DC;
}

state("BPMGame-Win64-Shipping", "steam-patch2")
{
	float timer: 	0x43BEEE8, 0xDE8, 0x2D5C;							//timer is at 0.0f on launch, is paused during loads and the pause menu, stops on victory and keeps running during death screen
	float death: 	0x43AC4F0, 0x30,  0x2B0, 0x370, 0x288, 0x1C8;		//death time is 0.0f when a game starts and is set when it appears on the death screen
	int   world: 	0x43AC4F0, 0x268, 0x3B0;							//world starts at 0 for asgard and increments by 1 for each level transition
	int   menu:  	0x43F0CC8, 0x38,  0x138;							//menu is 1 in main menu, 0 when in game, in loading screen, in pause, in victory screen and in death screen
	int   finisher: 0x43C2570, 0x128, 0x6A8, 0x4C8, 0x358, 0x4DC;		//finisher starts at 0 from when a boss fight is initiated and increments by 1 on each finisher shot
	int   pause: 	0x43BEEE8, 0x8B8;									//pause is 1 in pause menu, 0 in game, in loads, in main menu, in death screen and in victory screen
	int   boss: 	0x43BEEE8, 0xDE8, 0x2E80;							//boss count starts at 0 when you start a game and increments by 1 for every boss and miniboss killed
	float bosshp: 	0x43C2570, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;	//boss hp bar starts at 100.0f when you start a game, and decreases by (damage/max boss hp pool)x100 every shot. When it is <=0, boss finisher is initiated
}

state("BPMGame-Win64-Shipping", "GOG-patch2")
{
	float timer: 	0x4374928, 0xDE8, 0x2D5C;
	float death: 	0x4361F30, 0x30,  0x2B0, 0x370, 0x288, 0x1C8;
	int   world: 	0x4361F30, 0x268, 0x3B0;
	int   menu:  	0x43A6708, 0x38,  0x138;
	int   pause: 	0x4374928, 0x8B8;
	int   finisher: 0x4377FB0, 0x128, 0x6A8, 0x4C8, 0x358, 0x4DC;
	int   boss: 	0x4374928, 0xDE8, 0x2E80;
	float bosshp: 	0x4377FB0, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;
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

	// settings.Add("worldSplit", true, "Split on level transition."); //moved to top since this defaults to true
	settings.Add("allChars", false, "Multi-Character Mode. Auto-reset is disabled after the first character.");
	settings.Add("bossMode", false, "Boss Rush Mode. Splits on boss death.");
	settings.Add("practice", false, "Practice Difficulty Mode. Splits on Gullveig death.");
	settings.Add("experimental", false, "Experimental options. ONLY FOR TESTING PURPOSES.");
	settings.Add("altTiming", false, "Switch to an alternate timing method.", "experimental");
	settings.Add("rta", false, "RTA Loadless timing.", "altTiming");
	settings.Add("refreshRate", false, "Set a custom refresh rate. Default is 30hz to reduce lag.", "experimental");
	settings.SetToolTip("refreshRate", "Keep this at or below your framerate." 
									+ "\nWARNING: HIGHER REFRESH RATES MAY CAUSE LAG AND STUTTERING.");
	settings.Add("60hz", false, null, "refreshRate");
	settings.Add("120hz", false, null, "refreshRate");
	settings.Add("144hz", false, null, "refreshRate");
	settings.Add("200hz", false, null, "refreshRate");
	settings.Add("debug", false, "Enable debugging options.");
	settings.Add("logger", false, "Enable logging to console.", "debug");
	settings.Add("logvars", false, "Log variable changes to console.", "logger");
	settings.Add("logstate", false, "Log state value changes to console.", "logger");
	settings.Add("logtime", false, "Log current game time(on state change) to console.", "logger");

	timer.OnReset += (s,e) => {
		vars.timerValue = 0.0f;
		vars.timerState = 0;
	};
}

update {
	const int STOPPED = 1, RUNNING = 2, PAUSED = 4, RESET = 8;
	string[] STATE = {"INITIAL","STOPPED", "RUNNING","3","PAUSED","5","6","7","RESET"};
	string[] WORLD = {"ASGARD_I", "ASGARD_II_OR_CRYPTS", "VANAHEIM_I", "VANAHEIM_II",
						"SVARTALFHEIM_I","SVARTALFHEIM_II","HELHEIM_I","HELHEIM_II"};
	
	bool t_eq_0 = current.timer == 0.0f;
	bool t_eq_t0 = current.timer == old.timer;
	bool t_gt_t0 = current.timer > old.timer;
	bool t_lt_t0 = current.timer < old.timer;

	bool alive = current.death == 0.0f;
	bool death = current.death > 0.0f && old.death == 0.0f;

	bool start = current.timer > 0.0f && old.timer == 0.0f;
	bool paused = current.pause == 1;
	bool mainmenu = current.menu == 1;
	
	Func<int, int> nextState = (timerState) => {
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
	Func<double> resetTimer = () => (settings["allChars"] && timer.CurrentSplitIndex > 0)
			? vars.timerValue + (alive ? old.timer : current.death)
			: 0.0f;
	Func<double> updateRefreshRate = () => settings["60hz"] ? 60
				: settings["120hz"] ? 120
				: settings["144hz"] ? 144
				: settings["200hz"] ? 200
				: 30;

	int prevState = vars.timerState;
	double prevRefresh = refreshRate;
	double prevTimer = vars.timerValue;

	MAIN: {	
		vars.timerState = nextState(vars.timerState);
		if(vars.timerState == RESET && !settings["rta"]) 
			vars.timerValue = resetTimer();
		if(vars.timerState == STOPPED)
			refreshRate = updateRefreshRate();
	}
	
	LOGGER: {
		if(settings["logvars"]) {
			//logging for debuging
			if(prevState != vars.timerState)
				print("Timer State: " + STATE[vars.timerState]);
			if(prevRefresh != refreshRate)
				print("Refresh Rate: " + refreshRate + "hz");
			if(prevTimer != vars.timerValue)
				print("Game Time: " + TimeSpan.FromSeconds(vars.timerValue).ToString());
		}

		if(settings["logstate"]) {
			if(old.death != current.death)
				print("Death Time: " + current.death);
			if(old.world != current.world)
				print("Current World: " + WORLD[current.world]);
			if(old.menu != current.menu)
				print("Menu: " + current.menu);
			if(old.pause != current.pause)
				print("Pause: " + current.pause);
			if(old.finisher != current.finisher)
				print("Finisher Shot: " + current.finisher);
			if(old.boss != current.boss)
				print("Boss Count: " + current.boss);
			if(old.bosshp != current.bosshp)
				print("Boss HP Bar: " + current.bosshp + "%");
		}

		if(settings["logtime"]) {
			if((prevState != PAUSED && vars.timerState == PAUSED) 
				|| (prevState != STOPPED && vars.timerState == STOPPED)
				|| (prevState != RESET && vars.timerState == RESET)
				|| (prevState != RUNNING && vars.timerState == RUNNING))
				print("Current Time: " 
					+ TimeSpan.FromSeconds(current.death > 0.0f ? current.death : current.timer).ToString());
		}
	}
}

start {
	const int RUNNING = 2;
	return vars.timerState == RUNNING;
}

isLoading {
	const int STOPPED = 1, PAUSED = 4, RESET = 8;
	//remove loads from RTA
	return settings["rta"] 
		? ((vars.timerState & (STOPPED | PAUSED | RESET)) != 0 && current.pause == 0)
		: true;
}

gameTime {
	if(!settings["rta"]) {
		const int STOPPED = 1, RESET = 8;
		
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
	const int VANAHEIM_II = 3;
	const int GULLVEIG = 5, NIDHOGG = 9;
	Func<int, bool> isFinalShot = (shot) => current.finisher == shot && old.finisher == --shot;

	return (!settings["allChars"] && current.world == ++old.world)	//removed "worldSplit" option and made it default behavior if multi-character mode is disabled
		|| (settings["bossMode"] && current.boss == ++old.boss && current.bosshp <= 0)	//bosshp is the health bar value, otherwise the boss counter increments on cloned bosses
		|| (settings["practice"] && old.world == VANAHEIM_II && isFinalShot(GULLVEIG))	//checking for vanaheim 2 on practice difficulty works
		|| isFinalShot(NIDHOGG);	//checking for helheim 2 is unreliable, nidhogg is the only boss whose finisher is 9 shots
}

reset {
	const int RESET = 8;
	return !(settings["allChars"] && timer.CurrentSplitIndex > 0) //check if not on first character
			&& vars.timerState == RESET;
}
