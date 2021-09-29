class MiamiPlayer : DoomPlayer
{
	double shield;
	int shieldTimer;

	default
	{
		Player.StartItem "MiamiHands";
		Player.StartItem "EMPistol";
		Player.StartItem "ShieldPoints", 5;
		Player.MaxHealth 100;
		//Player.JumpZ 12;
	}

	override void Tick()
	{
		super.Tick();
		if(shieldTimer < 1)
		{
			if(shield < CountInv("ShieldPoints"))
			{
				double newshield = CountInv("ShieldPoints")/70.;
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
		// Shields take 2 points of damage for every 1 point prevented.
		int sdmg = dmg * 2;
		if(shield > 0)
		{
			// Shields absorb all damage, even at the moment of breaking.
			if(sdmg > shield)
			{
				A_StartSound("misc/sbreak",4);
			}
			shield = max(0, shield-sdmg);
			shieldTimer = 105;
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