class SpecOps : SMGThug replaces HellKnight
{
	// Aggressive, fast, and deadly.
	// Tosses grenades.

	int grenades;

	bool fastchase;
	int chasestop; // time in ticks when we stop dodging.

	Property maxGrenades : grenades;

	default
	{
		Health 100;
		Height 48;
		Speed 10;
		SeeSound "ZSec/sight";
		PainSound "ZSec/pain";
		DeathSound "ZSec/death";
		ActiveSound "ZSec/active";
		MiamiMonster.bonus "GrenadeToss", 2, 2; // TODO: Grenade item
		SpecOps.maxGrenades 3;
	}

	override bool SpecialDeath()
	{
		return grenades > 0;
	}

	action void A_ThrowGrenade()
	{
		if(invoker.grenades>0)
		{
			A_SpawnProjectile("EMGrenade",flags:CMF_OFFSETPITCH,pitch:-10);
			invoker.grenades -= 1;
		}
	}

	states
	{
		Spawn:
			ZSEC ABCD 4 A_Look();
			Loop;

		See:
			ZSEC ABCD 3
			{
				if(!fastchase)
				{
					A_Chase();	
				}
				else
				{
					A_FastChase();
					if(GetAge() > chasestop)
					{
						fastchase = false;
					}
				}
			}
			Loop;

		Missile:
			ZSEC E 4;
			ZSEC E 1
			{
				if(grenades>0 && random(0,1)>0)
				{
					return ResolveState("Grenade");
				}
				else
				{
					return ResolveState(null);
				}
			}
			ZSEC E 1
			{
				if(!ischarged)
				{
					A_ChargeOrFire();
					return ResolveState(null);
				}
				else if(CheckLOF() || random(0,2)<2)
				{
					 return ResolveState("Fire");
				}
				else
				{
					return ResolveState("See");
				}
			}
			Loop;

		Charge:
			ZSEC E 1 A_Charge(2);
			ZSEC E 1 A_ChargeOrFire(see: true);
			Loop;

		Fire:
			ZSEC E 4 { A_FaceTarget(); invoker.burst = random(2,8); }
		FireLoop:
			ZSEC F 2 A_RifleShot();
			ZSEC E 3;
			ZSEC E 6
			{
				invoker.burst -= 1;
				if(!A_ChargeCheck(0) || invoker.burst < 1 || invoker.spread >= 8)
				{
					return ResolveState(null);
				}

				if(random(0,2)<2 || CheckLOF())
				{
					return ResolveState("FireLoop");
				}
				else
				{
					return ResolveState(null);
				}
			}
			Goto Missile;

		Grenade:
			ZSEC G 4 A_StartSound("Zsec/active");
			ZSEC ED 3;
			ZSEC C 2 A_StartSound("Zsec/pain");
			ZSEC B 5 A_ThrowGrenade();
			Goto See;

		Pain:
			ZSEC G 3 A_Pain();
			ZSEC D 3 { fastchase = true; chasestop = GetAge() + random(35,105); }
			ZSEC C 3;
			Goto See;

		Death:
			ZSDI A 4 A_ScreamAndUnblock();
			ZSDI BCDE 3;
			ZSDI E -1;
			Stop;
	}
}