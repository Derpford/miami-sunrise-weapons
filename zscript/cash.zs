class CashItem : ScoreItem
{
	// Some random piece of junk, jewelry, cash or card that can be stolen.
	// These replace most ammunition types.	

	override string PickupMessage()
	{
		return super.PickupMessage().." [$"..amount.."]";
	}
}

class CashBundle : CashItem replaces Clip
{
	default
	{
		Inventory.Amount 30;
		Inventory.PickupMessage "A bundle of cash!";
	}

	states
	{
		Spawn:
			CASH A -1;
			Stop;
	}
}

class CreditCard : RandomSpawner replaces Shell
{
	// Drops random credit cards.
	default
	{
		DropItem "RedCredit";
		DropItem "YellowCredit";
		DropItem "BlueCredit";
	}
}

class RedCredit : CashItem
{
	default
	{
		Inventory.Amount 25;
		Inventory.PickupMessage "A credit card!";
	}

	states
	{
		Spawn:
			CARR A -1;
			Stop;
	}
}

class YellowCredit : CashItem
{
	default
	{
		Inventory.Amount 50;
		Inventory.PickupMessage "A gold credit card!";
	}

	states
	{
		Spawn:
			CARY A -1;
			Stop;
	}
}

class BlueCredit : CashItem
{
	default
	{
		Inventory.Amount 75;
		Inventory.PickupMessage "Diamond Express credit card!";
	}

	states
	{
		Spawn:
			CARB A -1;
			Stop;
	}
}

class Chems : RandomSpawner replaces RocketAmmo
{
	// Random bottles of various chemicals.
	default
	{
		DropItem "ChemA";
		DropItem "ChemB";
		DropItem "ChemC";
	}
}

class ChemA : CashItem
{
	default
	{
		Inventory.Amount 50;
		Inventory.PickupMessage "Cleaning chems!";
	}

	states
	{
		Spawn:
			CHEM A -1;
			Stop;
	}
}

class ChemB : CashItem
{
	default
	{
		Inventory.Amount 100;
		Inventory.PickupMessage "Concentrated chems!";
	}

	states
	{
		Spawn:
			CHEM B -1;
			Stop;
	}
}

class ChemC : CashItem
{
	default
	{
		Inventory.Amount 150;
		Inventory.PickupMessage "Explosive chems!";
	}

	states
	{
		Spawn:
			CHEM C -1;
			Stop;
	}
}

class Gems : RandomSpawner replaces Cell
{
	// Random gemstones.
	default
	{
		DropItem "Ruby";
		DropItem "Sapphire";
		DropItem "Diamond";
	}
}

class Ruby : CashItem
{
	default
	{
		Inventory.Amount 100;
		Inventory.PickupMessage "A ruby!";
		Scale 0.5;
	}

	states
	{
		Spawn:
			KGZR B -1;
			Stop;
	}
}

class Sapphire : CashItem
{
	default
	{
		Inventory.Amount 200;
		Inventory.PickupMessage "A sapphire!";
		Scale 0.5;
	}

	states
	{
		Spawn:
			KGZB B -1;
			Stop;
	}
}

class Diamond : CashItem
{
	default
	{
		Inventory.Amount 300;
		Inventory.PickupMessage "A diamond!";
		Scale 0.5;
	}

	states
	{
		Spawn:
			KGZS B -1;
			Stop;
	}
}