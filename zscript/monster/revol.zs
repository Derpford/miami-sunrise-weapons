class RevolverThug : PistolThug replaces DoomImp
{
	// A tougher thug with a bigger gun.
	int hitAge;

	default
	{
		Health 35;
		Translation "128:151=@35[255,0,0]";
		MiamiMonster.charge 15;
		DropItem "CashBundle";
		DropItem "CashBundle";
		DropItem "CreditCard", 128;
		Obituary "%o found out about reloading during a battle.";
		MiamiMonster.bonus "CreditCard", 1, 1;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		hitAge = -1;
	}

	action void A_RevoShot()
	{
		A_SpawnProjectile("EMShot",32,0,frandom(-16,16));
		A_Discharge(15.);
		A_StartSound("weapons/ssgf",1);
	}

	override int DamageMobj(Actor src, Actor inf, int dmg, Name mod, int flags, double ang)
	{
		if(hitAge<0) { hitAge = GetAge(); }
		return Super.DamageMobj(src,inf,dmg,mod,flags,ang);
	}

	override bool SpecialDeath()
	{
		return abs(GetAge()-hitAge)<=35;
	}

	states
	{
		Charge:
			MGPS E 1
			{
				A_Charge(1);	
				A_StartSound("weapons/ssgr",1,CHANF_NOSTOP);
			}
			MGPS E 0
			{
				if(A_ChargeReady())
				{
					bMISSILEEVENMORE = true;
					A_StartSound("weapons/pisr",1);
					return ResolveState("Fire");
				}
				else 
				{
					return ResolveState(null);
				}
			}
			Loop;

		Fire:
			MGPS E 4 A_FaceTarget();
			MGPS F 3 A_RevoShot();
			MGPS E 3 A_SetTics(random(3,12));
			MGPS D 2
			{
				bMISSILEEVENMORE = false;
			}
			Goto See;
	}
}