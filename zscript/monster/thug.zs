class PistolThug : MiamiMonster replaces ZombieMan
{
	// A random guy with a pistol. Still theoretically dangerous.
	default
	{
		Health 25;
		Height 48;
		Speed 8;
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "%o had a cap popped in %h.";
		DropItem "CashBundle";
		DropItem "CashBundle", 128;
	}

	action void A_PistolShot()
	{
		A_SpawnProjectile("EMShot",32,0,frandom(-16,16));
		A_Discharge(10.);
		A_StartSound("weapons/pisf",1);
	}

	states
	{
		Spawn:
			MGPS AB 4 A_Look();
			Loop;

		See:
			MGPS ABCD 3 A_Chase();
			Loop;

		Missile:
			MGPS A 2
			{
				if(invoker.charge>random(0,10))
				{
					return ResolveState("Fire");
				}
				else
				{
					return ResolveState("Charge");
				}
			}
			Goto See;

		Charge:
			MGPS E 1
			{
				A_Charge(3);	
				A_StartSound("weapons/plasmaf",1,CHANF_NOSTOP);
			}
			MGPS E 0
			{
				if(A_ChargeReady())
				{
					bMISSILEMORE = true;
					A_StartSound("weapons/pisr",1);
					return ResolveState("See");
				}
				else 
				{
					return ResolveState(null);
				}
			}
			Loop;

		Fire:
			MGPS E 4 A_FaceTarget();
			MGPS F 3 A_PistolShot();
			MGPS E 3 A_SetTics(random(3,12));
			MGPS D 2
			{
				if(invoker.charge > 0 && frandom(0,1)>0.4)
				{
					return ResolveState("Fire");
				}
				else
				{
					bMISSILEMORE = false;
					return ResolveState(null);
				}
			}
			Goto See;

		Pain:
			MGPS G 4;
			MGPS DC 3;
			Goto See;

		Death:
		XDeath:
			MGPS GH 4;
			MGPS V 3 A_ScreamAndUnblock();
			MGPS WX 4;
			MGPS X 8 A_SetTics(random(6,10));
			MGPS Y 5;
			MGPS Z -1;
			Stop;
	}
}