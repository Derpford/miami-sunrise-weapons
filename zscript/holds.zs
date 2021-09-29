class HoldPoint : Actor
{
	// An object that you have to stand next to for a bit to activate.
	double CapRadius;
	double CapMax;
	double CapCharge;
	double CapDecay;
	double Cap;
	int CapDrops;
	string CapReward;

	Property CapRadius: CapRadius;
	Property CapCharge: CapCharge, CapDecay;
	Property CapMax: CapMax;
	Property CapReward: CapReward, CapDrops;



	default
	{
		HoldPoint.CapRadius 128.;
		HoldPoint.CapCharge 1.,.5;
		HoldPoint.CapMax 70.;
	}

	override void Tick()
	{
		string col = "HoldSparkle";
		let it = ThinkerIterator.Create("MiamiPlayer");
		int count = 0;
		Actor plr;


		while(plr = Actor(it.next()))
		{
			if(Vec2To(plr).length()>CapRadius) { break; }
			// We can check player details here, but for now, just increment the capture level.
			count++;
		}
		if(count > 0)
		{
			col = "CapSparkle";
			for(int i = 0; i < count; i++)
			{
				Cap = clamp(0,Cap+CapCharge,CapMax);
			}
		}
		else
		{
			Cap = clamp(0,Cap-CapDecay,Cap);
		}

		for(int i = 0; i < 360; i+=10)
		{
			A_SpawnItemEX(col,ceil(CapRadius),zofs:16,angle:(i+GetAge())%360);
			//console.printf("Tick!");
		}

		if(Cap >= CapMax)
		{
			for(int i = 0; i < CapDrops; i++)
			{
				A_SpawnItemEX(CapReward,xvel:frandom(-2,2),yvel:frandom(-2,2),zvel:frandom(0,2));
			}
			Die(self,self,0,"MDK");
		}


		Super.Tick();

	}
}

class HoldSparkle : Actor
{
	default
	{
		+NOINTERACTION;
		RenderStyle "Add";
	}

	states
	{
		Spawn:
			PLS2 A 2;
			Stop;
	}
}

class CapSparkle : Actor
{
	default
	{
		+NOINTERACTION;
		RenderStyle "Add";
	}

	states
	{
		Spawn:
			PLSS A 2;
			Stop;
	}
}

class CashBox : HoldPoint replaces ClipBox
{
	// A box fulla cash.

	default
	{
		HoldPoint.CapReward "CashBundle", 5;
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
	}

	states
	{
		Spawn:
			AMMO A -1;
			Stop;
	}
}