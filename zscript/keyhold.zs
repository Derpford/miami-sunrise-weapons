class KeyHold : HoldPoint
{
	// A hold that drops a key at the end.
	default
	{
		HoldPoint.CapRadius 128.;
		HoldPoint.CapCharge 1.,.3;
		HoldPoint.CapMax 175;
		HoldPoint.Barriers 4;
	}
}

class RedFloppy : RedCard
{
	// A red floppy disk.
	default
	{
		Inventory.PickupMessage "Decrypted a red keydisk.";
		Inventory.Icon "STKEYS2";
		Species "RedCard";
	}

	states
	{
		Spawn:
			DISR A -1;
			Stop;
	}
}

class BlueFloppy : BlueCard
{
	// A blue floppy disk.
	default
	{
		Inventory.PickupMessage "Decrypted a blue keydisk.";
		Inventory.Icon "STKEYS1";
		Species "BlueCard";
	}

	states
	{
		Spawn:
			DISB A -1;
			Stop;
	}
}

class YellowFloppy : YellowCard
{
	// A yellow floppy disk.
	default
	{
		Inventory.PickupMessage "Decrypted a yellow keydisk.";
		Inventory.Icon "STKEYS0";
		Species "YellowCard";
	}

	states
	{
		Spawn:
			DISY A -1;
			Stop;
	}
}

class RedKey : RedSkull replaces RedSkull
{
	// A strange key with a red tag.
	default
	{
		Inventory.PickupMessage "The tag is stained red. Gotta get a grip...";
		Inventory.Icon "STKEYS5";
		Species "RedSkull";
	}

	states
	{
		Spawn:
			KEYR A 3;
			KEYR A 3 Bright;
			Loop;
	}
}

class BlueKey : BlueSkull replaces BlueSkull
{
	// A strange key with a blue tag.
	default
	{
		Inventory.PickupMessage "Royal colors for royal bastards. Gotta get a grip...";
		Inventory.Icon "STKEYS3";
		Species "BlueSkull";
	}

	states
	{
		Spawn:
			KEYB A 3;
			KEYB A 3 Bright;
			Loop;
	}
}

class YellowKey : YellowSkull replaces YellowSkull
{
	// A strange key with a red tag.
	default
	{
		Inventory.PickupMessage "Gold foil, greed's reward. Gotta get a grip...";
		Inventory.Icon "STKEYS4";
		Species "YellowSkull";
	}

	states
	{
		Spawn:
			KEYY A 3;
			KEYY A 3 Bright;
			Loop;
	}
}

// And now the actual holds.

class RedKeyHold : KeyHold replaces RedCard
{
	default
	{
		HoldPoint.CapReward "RedFloppy", 1;
	}

	states
	{
		Spawn:
			DISR A 3;
			DISR A 3 Bright;
			Loop;
	}
}

class BlueKeyHold : KeyHold replaces BlueCard
{
	default
	{
		HoldPoint.CapReward "BlueFloppy", 1;
	}

	states
	{
		Spawn:
			DISB A 3;
			DISB A 3 Bright;
			Loop;
	}
}

class YellowKeyHold : KeyHold replaces YellowCard
{
	default
	{
		HoldPoint.CapReward "YellowFloppy", 1;
	}

	states
	{
		Spawn:
			DISY A 3;
			DISY A 3 Bright;
			Loop;
	}
}