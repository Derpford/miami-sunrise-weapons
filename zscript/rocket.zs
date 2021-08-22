class MagLauncher : EMWeapon replaces RocketLauncher
{
	// Fires a single explosive projectile.
	// Can be overcharged at a heat cost.

	default
	{
		Weapon.SlotNumber 4;
		EMWeapon.Charge 40, 1.;
		EMWeapon.ChargeDecay 1.,0.1;
		EMWeapon.Heat 40.0,1.0,0.5;
		EMWeapon.ChargeSounds "weapons/plasmaf","weapons/rocklr","weapons/idlec";
	}

	action void A_FireRocket()
	{
		let rkt = EMRocket(A_FireProjectile("EMRocket")); // Heat does not affect accuracy.
		A_StartSound("weapons/rocklf",1);
		rkt.heatbonus = ceil(invoker.heat);
		invoker.chargestate = CS_Overheat;
		invoker.heat += 20.;
	}

	states
	{
		Spawn:
			MGUN A -1;
			Stop;

		Select:
			CHGG A 1 A_Raise(35);
			Loop;
		Deselect:
			CHGG A 1 A_Lower(35);
			Loop;

		Ready:
			CHGG A 1 A_EMReady();
			Loop;

		AltFire:
			CHGG AB 1
			{
				A_Charge();
				if(invoker.chargestate == CS_Ready)
				{
					A_Heat();
				}
				int newtics =(10+invoker.maxcharge - invoker.charge)/10 ;
				console.printf(""..newtics);
				A_SetTics(newtics);
				if(invoker.charge > invoker.maxcharge/2)
				{
					A_GunFlash();
				}
			}
			CHGG A 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			CHGG A 0 A_UnCharge();
			Goto Ready;

		Fire:
			CHGG A 2 A_FireRocket();
			CHGG B 3;
			CHGG AB 4;
			CHGG AB 5;
			Goto Ready;

		Flash:
			CHGF AB 1 Bright;
			Stop;

	}
}

class EMRocket : EMShot
{
	// Special EM burst that can scale up.
	int heatbonus; // bonus dmg

	default
	{
		DamageFunction 40+clamp(0,heatbonus,40);
		Radius 8;
		Height 8;
		EMShot.Spread .3,.2;
		EMSHot.Time 4;
		Scale 2;
		MissileType "MagTrail";
	}

	override void Tick()
	{
		super.tick();
		if(InStateSequence(curstate,ResolveState("Death")))
		{
			//Whoops!
			vel = (0,0,0);
		}
		else
		{
			Thrust(.3,angle+(90*sin(GetAge())));
		}
	}

	states
	{
		Spawn:
			PLSS AB 3 Bright;
			Loop;
		Death:
			PLSS C 1 Bright A_StartSound("weapons/rocklx");
			PLSS C 3 Bright A_Explode(40+heatbonus,2*(40+heatbonus),fulldamagedistance:40+heatbonus);
			PLSS D 5;
			PLSS E 6 Bright;
			TNT1 A -1;
			Stop;
	}
}

class MagTrail : EMTrail
{
	// Blue trail.

	states
	{
		Spawn:
			PLSS AB 3
			{
				A_FadeOut();
				A_SetScale(scale.x*0.9);
			}
	}
}