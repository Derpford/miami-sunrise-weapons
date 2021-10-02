class CashBox : HoldPoint replaces ClipBox
{
	// A box fulla cash.

	default
	{
		HoldPoint.CapReward "CashBundle", 5;
		HoldPoint.Barriers 2;
	}

	states
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}

class CardBox : HoldPoint replaces ShellBox
{
	// A box with a cache of stolen credit cards.

	default
	{
		HoldPoint.CapReward "CreditCard", 5;
		HoldPoint.Barriers 2;
	}

	states
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}

class ChemBox : HoldPoint replaces RocketBox
{
	// A box with some chemicals in it.

	default
	{
		HoldPoint.CapReward "Chems", 5;
		HoldPoint.Barriers 3;
		HoldPoint.CapMax 105.;
	}

	states
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}

class GemCase : HoldPoint replaces CellPack
{
	// A case of assorted gemstones.

	default
	{
		HoldPoint.CapReward "Gems", 5;
		HoldPoint.Barriers 2;
		HoldPoint.CapMax 105.;
	}

	states
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}