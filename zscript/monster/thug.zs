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
		DropItem "EMPistol";
		DropItem "CashBundle", 128;
		MiamiMonster.sounds "weapons/plasmaf", "weapons/pisr";
	}

	action void A_PistolShot()
	{
		A_MiamiFire("EMShot",(0,0,0),frandom(-16,16));
		A_Discharge(10.);
		A_StartSound("weapons/pisf",1);
	}

	override bool SpecialDeath()
	{
		return charge > 0;
	}

	states
	{
		Spawn:
			MGPS ABCD 4 
			{
				A_SetWanderTics();
				A_Wander();
				A_Look();
			}
			Loop;

		See:
			MGPS ABCD 3 A_Chase();
			Loop;

		Missile:
			MGPS A 2 A_ChargeOrFire();
			Goto See;

		Charge:
			MGPS E 1
			{
				A_Charge(3);	
				A_FaceTarget(10,5);
				A_StartSound("weapons/plasmaf",1,CHANF_NOSTOP);
			}
			MGPS E 0
			{
				if(A_ChargeReady())
				{
					bMISSILEEVENMORE = true;
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
			MGPS E 4 A_FaceTarget(15,15);
		RealFire:
			MGPS F 3 { A_FaceTarget(5,5); A_PistolShot(); }
			MGPS E 3 A_SetTics(random(3,12));
			MGPS D 2
			{
				if(invoker.charge > 0 && frandom(0,1)>0.4)
				{
					return ResolveState("Fire");
				}
				else
				{
					bMISSILEEVENMORE = false;
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