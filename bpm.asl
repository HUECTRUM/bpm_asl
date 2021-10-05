state("BPMGame-Win64-Shipping", "steam-v0.0")
{
	float timer: 	0x43A68F8, 0x58,  0x1944;
	int   world: 	0x4393F30, 0x268, 0x368;
	int   death:    0;
	int	  pause:	0;
	int   boss: 	0;
	float bosshp: 	0;
}

state("BPMGame-Win64-Shipping", "GOG-v0.0")
{
	float timer: 	0x435B378, 0x58,  0x1944;
	int   world: 	0x435B3A8, 0xDE8, 0x1930;
	int   death:    0;
	int	  pause:	0;
	int   boss: 	0;
	float bosshp: 	0;
}

state("BPMGame-Win64-Shipping", "steam-v1.0")
{
	float timer: 	0x43A7C78, 0x58,  0x1944;
	float death: 	0x43952B0, 0x30,  0x50,  0x2B0, 0x370, 0x288, 0x160;
	int   world: 	0x43952B0, 0x268, 0x368;
	int	  pause:	0;
	int   boss: 	0;
	float bosshp: 	0;
}

state("BPMGame-Win64-Shipping", "GOG-v1.0")
{
	float timer: 	0x435D768, 0xDE8, 0x1944;
	float death: 	0x434AD70, 0x30,  0x2B0, 0x370, 0x288, 0x160;
	int   world: 	0x435D738, 0x58,  0x1930;
	int	  pause:	0;
	int   boss: 	0;
	float bosshp: 	0;
}

state("BPMGame-Win64-Shipping", "steam-v2.0")
{
	float timer: 	0x43BEEE8, 0xDE8, 0x2D5C;							//timer is at 0.0f on launch, is paused during loads and the pause menu, stops on victory and keeps running during death screen
	float death: 	0x43AC4F0, 0x30,  0x2B0, 0x370, 0x288, 0x1C8;		//death time is 0.0f when a game starts and is set when it appears on the death screen
	int   world: 	0x43AC4F0, 0x268, 0x3B0;							//world starts at 0 for asgard and increments by 1 for each level transition
	int   pause: 	0x43BEEE8, 0x8B8;									//pause is 1 in pause menu, 0 in game, in loads, in main menu, in death screen and in victory screen
	int   boss: 	0x43BEEE8, 0xDE8, 0x2E80;							//boss count starts at 0 when you start a game and increments by 1 for every boss and miniboss killed
	float bosshp: 	0x43C2570, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;	//boss hp bar starts at 100.0f when you start a game, and decreases by (damage/max boss hp pool)x100 every shot. When it is <=0, boss finisher is initiated
}

state("BPMGame-Win64-Shipping", "GOG-v2.0")
{
	float timer: 	0x4374928, 0xDE8, 0x2D5C;
	float death: 	0x4361F30, 0x30,  0x2B0, 0x370, 0x288, 0x1C8;
	int   world: 	0x4361F30, 0x268, 0x3B0;
	int   pause: 	0x4374928, 0x8B8;
	int   boss: 	0x4374928, 0xDE8, 0x2E80;
	float bosshp: 	0x4377FB0, 0x128, 0x6A8, 0x438, 0x150, 0xE0, 0x10;
}

state("BPMGame-Win64-Shipping", "steam-v3.0")
{
	float timer: 	0x4961F18, 0x58, 0x2D8C;
	float death: 	0x494E5A0, 0x30,  0x2B0, 0x370, 0x2B8, 0x200;
	int   world: 	0x4961F18, 0x58, 0x2D78;
	int   pause: 	0x49657E0, 0x118, 0x2B8;
	int   boss: 	0x4961F20, 0xDE8, 0x2EB0;
	float bosshp: 	0x49657E0, 0x118, 0x6B0, 0x468, 0x150, 0xE0, 0x10;
}

state("BPMGame-Win64-Shipping", "v3.1-3.2")
{
	float timer: 	0x4964318, 0x58, 0x2D8C;
	float death: 	0x49509A0, 0x30, 0x228, 0xE0, 0x2B0, 0x370, 0x2B8, 0x200;
	int   world: 	0x49509A0, 0x290, 0x3B0;
	int   pause: 	0x4964320, 0x8A8;
	int   boss: 	0x4967BE0, 0x180, 0x2EB0;
	float bosshp: 	0x4967BE0, 0x118, 0x6B0, 0x468, 0x150, 0x140, 0xB0, 0x14;
}

state("BPMGame-Win64-Shipping", "UNSUPPORTED")
{
	float timer: 	0;
	float death: 	0;
	int   world: 	0;
	int   pause: 	0;
	int   boss: 	0;
	float bosshp: 	0;
}

init
{
	Func<int, string> getVersion = (size) => {
		switch(size) {
			case 75317248: return "steam-v0.0";
			case 75321344: return "steam-v1.0";
			case 75427840: return "steam-v2.0";
			case 81747968: return "steam-v3.0";
			case 74993664: return "GOG-v0.0";
			case 75001856: return "GOG-v1.0";
			case 75096064: return "GOG-v2.0";
			case 81756160: return "v3.1-3.2";
			default: return "UNSUPPORTED";
		}
	};
	print("Size: " + modules.First().ModuleMemorySize);
	
	version = getVersion(modules.First().ModuleMemorySize);
	print("VERSION: " + version);
	refreshRate = 30; //for load reduction
	vars.patch = -1;

	string[] versions = { "v0.0", "v1.0", "v2.0", "v3.0", "v3.1" };
	for(int i = 0; i < versions.Length; i++) {
		if(version.Contains(versions[i])){
			vars.patch = float.Parse(versions[i].Substring(1));
			print("Support Version: " + vars.patch);
		}
	}
}

startup {
	vars.timerValue = 0.0f;
	vars.timerState = 0;

	settings.Add("allChars", false, "Multi-Character Mode. Auto-reset is disabled after the first character.");
	settings.Add("bossMode", false, "Boss Rush Mode. Splits on boss death.");
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

	settings.SetToolTip("allChars", "Supported for versions 1.0+");
	settings.SetToolTip("bossMode", "Supported for versions 2.0+");
	settings.SetToolTip("rta", "Supported for versions 2.0+");

	timer.OnReset += (s,e) => { //needed for manual restarts, no way to remove anonymous event handlers on script shutdown, so this isn't ideal
		vars.timerValue = 0.0f;
		vars.timerState = 0;
	};
}

update {
	const int STOPPED = 1, RUNNING = 2, PAUSED = 4, RESET = 8; //each bit as a state allows for bitmasking
	string[] STATE = {"INITIAL","STOPPED", "RUNNING","3","PAUSED","5","6","7","RESET"}; //for logger
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
	bool loading = t_eq_t0 && !paused;
	bool restart = t_eq_0 && t_lt_t0;
	bool resume = t_gt_t0;
	
	bool bMultiCharacterMode = settings["allChars"] && vars.patch >= 1;
	bool bRTALoadlessTiming = settings["rta"] && vars.patch >= 2;
	bool bBossMode = settings["bossMode"] && vars.patch >= 2;
	
	Func<int, int> nextState = (timerState) => {
		switch(timerState)
		{
			case STOPPED:
				return (start && alive) ? RUNNING : STOPPED;
			case RUNNING:
				if (paused || loading) return PAUSED;
				return (restart || death) ? RESET : RUNNING;
			case PAUSED:
				if (resume) return RUNNING;
				return (restart) ? RESET : PAUSED;
			default:
				return STOPPED;
		}
	};
	Func<double> resetTimer = () => (bMultiCharacterMode && timer.CurrentSplitIndex > 0)
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
		if(vars.timerState == RESET && !bRTALoadlessTiming) 
			vars.timerValue = resetTimer();
		if(vars.timerState == STOPPED)
			refreshRate = updateRefreshRate();
	}
	
	LOGGER: {
		string msg = "";
		Func<string, string> log = (str) => msg += (str + '\n');
		
		if(start && settings["logger"]) {
			log("Timing Mode: " + (bRTALoadlessTiming ? "RTA Loadless" : "IGT"));
			log("Splitting Modes: \n" 
				+ (bMultiCharacterMode ? "Multi-Character" : "Single Character") + "\n"
				+ (bBossMode ? "Boss Split" : "World Split") + "\n");
		}

		if(settings["logvars"]) {
			//logging for debuging
			if(prevState != vars.timerState)
				log("Timer State: " + STATE[vars.timerState]);
			if(prevRefresh != refreshRate)
				log("Refresh Rate: " + refreshRate + "hz");
			if(prevTimer != vars.timerValue)
				log("Game Time: " + TimeSpan.FromSeconds(vars.timerValue).ToString());
		}

		if(settings["logstate"]) {
			if(old.death != current.death)
				log("Death Time: " + current.death);
			if(old.world != current.world)
				log("Current World: " + WORLD[current.world]);
			if(old.pause != current.pause)
				log("Pause: " + current.pause);
			if(old.boss != current.boss)
				log("Boss Count: " + current.boss);
			if(old.bosshp != current.bosshp && (current.bosshp == 100.0 || current.bosshp <= 0.0))
				log("Boss HP Bar: " + current.bosshp + "%");
		}

		if(settings["logtime"]) {
			if((prevState != PAUSED && vars.timerState == PAUSED) 
				|| (prevState != STOPPED && vars.timerState == STOPPED)
				|| (prevState != RESET && vars.timerState == RESET)
				|| (prevState != RUNNING && vars.timerState == RUNNING))
				log("Current Time: " 
					+ TimeSpan.FromSeconds(!alive ? current.death : current.timer).ToString());
		}
		if(settings["logger"] && msg != "")
			print(msg);
	}
}

start {
	const int RUNNING = 2;
	return vars.timerState == RUNNING;
}

isLoading {
	const int STOPPED = 1, PAUSED = 4, RESET = 8;
	//remove loads from RTA
	return (settings["rta"] && vars.patch >= 2)
		? ((vars.timerState & (STOPPED | PAUSED | RESET)) != 0 && current.pause == 0)
		: true;
}

gameTime {
	if(!(settings["rta"] && vars.patch >= 2)) {
		const int STOPPED = 1, RESET = 8;
		bool bMultiCharacterMode = settings["allChars"] && vars.patch >= 1;
		
		Func<int, double> stateToSeconds = (timerState) => {
			switch(timerState)
			{
				case STOPPED:
					return bMultiCharacterMode ? vars.timerValue : current.timer;
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
	const int STOPPED = 1, PAUSED = 4, RESET = 8;
	const int ASGARD_I = 0, VANAHEIM_II = 3, HELHEIM_II = 7;

	bool worldSplit = current.world != old.world;
	bool bossSplit = current.boss == ++old.boss && current.bosshp <= 0;
	bool charSplit = worldSplit && current.world == ASGARD_I;

	bool bMultiCharacterMode = settings["allChars"] && vars.patch >= 1;
	bool bBossMode = settings["bossMode"] && vars.patch >= 2;

	return (!bMultiCharacterMode && !bBossMode && worldSplit)
			|| (bBossMode && bossSplit)
			|| (bMultiCharacterMode && charSplit);
}

reset {
	const int RESET = 8;
	return !(settings["allChars"] && vars.patch >= 1 && timer.CurrentSplitIndex > 0) //check if not on first character
			&& vars.timerState == RESET;
}
