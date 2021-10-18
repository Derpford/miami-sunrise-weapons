class MiamiPlayer : DoomPlayer
{
	double shield;
	int shieldTimer;

	bool PutAwayWeapon;

	default
	{
		Player.StartItem "CasingHands";
		Player.StartItem "MiamiHands";
		Player.StartItem "EMPistol";
		Player.StartItem "ShieldPoints", 5;
		Player.MaxHealth 100;
		//Player.JumpZ 12;
		+NEVERTARGET; // Removed by CasingHands.
	}

	override bool CanTouchItem(Inventory item)
	{
		// Can't pick stuff up if we're in Casing Mode.
		if(bNEVERTARGET)
		{
			return false;
		}
		else
		{
			return super.CanTouchItem(item);
		}
	}

	override void Travelled()
	{
		super.Travelled();
		StartCasing();
	}

	override void PostBeginPlay()
	{
		super.PostBeginPlay();
		StartCasing();
	}

	void StartCasing()
	{
		console.printf("Starting...");
		// Select the CasingHands and set notarget.
		player.cheats |= CF_NOTARGET;
		bNEVERTARGET = true;
		//A_SelectWeapon("CasingHands");
		PutAwayWeapon = true;
	}

	override void Tick()
	{
		super.Tick();
		if(PutAwayWeapon)
		{
			// Workaround: Can't select weapons in PostBeginPlay for some reason.
			A_SelectWeapon("CasingHands");
			PutAwayWeapon = false;
		}
		if(shieldTimer < 1)
		{
			if(shield < CountInv("ShieldPoints"))
			{
				double newshield = CountInv("ShieldPoints")/35.;
				if(shield+newshield >= CountInv("ShieldPoints"))
				{
					A_StartSound("misc/smax",4);
				}
				shield = clamp(0,shield+newshield,CountInv("ShieldPoints"));
			}
		}
		else
		{
			shieldTimer -= 1;
			if(shieldTimer < 1)
			{
				A_StartSound("misc/scharge",4);
			}
		}
	}

	override int DamageMobj (Actor inf, Actor src, int dmg, Name mod, int flags, double ang)
	{
		// Shields take 1 points of damage for every 1 point prevented.
		int sdmg = dmg * 1;
		if(shield > 0)
		{
			// Shields absorb all damage, even at the moment of breaking.
			if(sdmg > shield)
			{
				A_StartSound("misc/sbreak",4);
			}
			shield = max(0, shield-sdmg);
			shieldTimer = 70;
			int shieldLoss = ceil(CountInv("ShieldPoints")*0.05);
			A_TakeInventory("ShieldPoints",shieldLoss);
			return 0;
		}
		else
		{
			return super.DamageMobj(inf,src,dmg,mod,flags,ang);
		}
	}
}