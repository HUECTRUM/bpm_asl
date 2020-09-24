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

state("BPMGame-Win64-Shipping", "patch1-GOG")
{
	float timer: 0x0435B378, 0x58, 0x1944;
	int   world: 0x0435B3A8, 0xDE8, 0x1930;
	int   menu:  0x0438BDC0, 0x368, 0xA8, 0x58;
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

start {
	return current.world == 0 && Math.Abs(current.timer) > 1e-6 && Math.Abs(old.timer) < 1e-6;
}

isLoading {
	return true;
}

gameTime {
	return TimeSpan.FromSeconds(current.timer);
}

split {
	return (current.world == old.world + 1) || (current.world == 0 && old.world == 7 && current.menu == 0);
}

reset {
	return current.menu != 0 && old.menu == 0;
}
