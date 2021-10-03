class RevolverThug : PistolThug replaces DoomImp
{
	// A tougher thug with a bigger gun.
	default
	{
		Health 35;
		Translation "128:151=@35[255,0,0]";
		MiamiMonster.charge 15;
		DropItem "CashBundle";
		DropItem "CashBundle";
		DropItem "CreditCard", 128;
		DropItem "ShieldBonus", 128;
		Obituary "%o found out about reloading during a battle.";
	}

	action void A_RevoShot()
	{
		A_SpawnProjectile("EMShot",32,0,frandom(-16,16));
		A_Discharge(15.);
		A_StartSound("weapons/ssgf",1);
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