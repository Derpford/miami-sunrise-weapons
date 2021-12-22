class SMGThug : MiamiMonster replaces ChaingunGuy
{
	// Slightly more of a threat. Fires in 3 to 5 round bursts.
	default
	{
		Health 45;
		Height 48;
		Speed 9;
		+MISSILEEVENMORE;
		DropItem "CreditCard";
		DropItem "CreditCard", 192;
		DropItem "EMRifle";
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "%o was given a lead transfusion.";
		MiamiMonster.charge 30;	
		MiamiMonster.sounds "weapons/riflec", "weapons/rifler";
	}

	bool ischarged;
	double spread;
	int burst;

	action void A_RifleShot()
	{
		invoker.spread = clamp(0,invoker.spread+0.7,8);
		A_MiamiFire("EMRifleShot",(0,0,0),frandom(-invoker.spread, invoker.spread),frandom(0,-invoker.spread));
		A_StartSound("weapons/riflef",1);
	}

	override void Tick()
	{
		Super.Tick();
		if(A_ChargeCheck())
		{
			ischarged = true;
		}

		if(!A_ChargeCheck(0))
		{
			ischarged = false;
		}

		if(ischarged)
		{
			charge -= 0.1;
		}

		spread -= 0.1;
	}

	states
	{
		Spawn:
			ZSMG ABCD 4
			{
				A_SetWanderTics();
				A_Wander();
 				A_Look();
			}
			Loop;

		See:
			ZSMG ABCD 3 A_Chase();
			Loop;

		Missile:
			ZSMG E 4 
			{ 
				if(!ischarged) 
				{ 
					A_ChargeOrFire(); 
					return ResolveState(null);
				}
				else
				{
					return ResolveState("Fire");
				}
			}
			Goto See;

		Charge:
			ZSMG E 1 
			{
				A_Charge(2);
				A_FaceTarget(15,15);
			}
			ZSMG E 0 A_ChargeOrFire();
			Loop;

		Fire:
			ZSMG E 4 { A_FaceTarget(10,10); invoker.burst = random(3,5); }
		FireLoop:
			ZSMG F 2 A_RifleShot();
			ZSMG E 3;
			ZSMG E 6
			{
				invoker.burst -= 1;
				A_FaceTarget(2,2);
				if(!A_ChargeCheck(0) || invoker.burst < 1 || invoker.spread >= 8)
				{
					return ResolveState(null);
				}

				if(random(0,1)<1 || CheckLOF())
				{
					return ResolveState("FireLoop");
				}
				else
				{
					return ResolveState(null);
				}
			}
			Goto See;

		Pain:
			ZSMG G 4 A_Pain();
			ZSMG DC 3;
			Goto See;

		Death:
			ZSMG H 4 A_ScreamAndUnblock();
			ZSMG I 3 A_SetTics(random(3,12));
			ZSMG JK 4;
			ZSMG L -1;
			Stop;

		XDeath:
			ZSMG MNOPQRSTU 4;
			ZSMG U -1;
			Stop;

	}
}