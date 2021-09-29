class ShieldPoints : Inventory
{
	// How much shielding can you have?
	// Shields absorb damage and then recharge. Each hit they absorb removes a percentage of your shielding.

	default
	{
		Inventory.MaxAmount 300;
	}
}

class ShieldPointsGiver : Inventory
{
	override bool TryPickup(in out Actor touch)
	{
		touch.A_GiveInventory("ShieldPoints",amount);
		GoAwayAndDie(); // wow rude lmao
		return true;
		// This *should* make children of ShieldPointsGiver give ShieldPoints instead of themselves.
	}
}


class GreenShield : ShieldPointsGiver replaces GreenArmor
{
	default
	{
		Inventory.Amount 20;
		Inventory.PickupMessage "Got a class II shield vest.";
	}

	states
	{
		Spawn:
			ARM1 A 5 Bright;
			ARM1 B 5 Bright;
			Loop;
	}
}

class BlueShield : ShieldPointsGiver replaces BlueArmor
{
	default
	{
		Inventory.Amount 50;
		Inventory.PickupMessage "Got a class V shield vest.";
	}

	states
	{
		Spawn:
			ARM2 A 5 Bright;
			ARM2 B 5 Bright;
			Loop;
	}
}

class ShieldBonus : ShieldPointsGiver replaces ArmorBonus
{
	default
	{
		Inventory.Amount 2;
		Inventory.PickupMessage "Found a shield battery.";
	}

	states
	{
		Spawn:
			CELL A -1;
			Stop;
	}
}


