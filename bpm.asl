state("BPMGame-Win64-Shipping")
{
	float timer: 0x43A68F8, 0x58, 0x1944;
	int	  world: 0x4393F30, 0x268, 0x368;
	int   menu:  0x43D7340, 0x328, 0x108, 0x58;
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