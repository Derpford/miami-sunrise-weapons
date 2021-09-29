class MagLauncher : EMWeapon replaces RocketLauncher
{
	// Fires a single explosive projectile.
	// Can be overcharged at a heat cost.

	default
	{
		Weapon.SlotNumber 5;
		Inventory.PickupMessage "Snagged an Electro-Mag Launcher! Let's fry some creeps!";
		EMWeapon.Charge 40, 1.;
		EMWeapon.ChargeDecay 1.,0.1;
		EMWeapon.Heat 40.0,.5,0.5;
		EMWeapon.ChargeSounds "weapons/plasmaf","weapons/rocklr","weapons/idlec";
	}

	action void A_FireRocket()
	{
		A_OffsetKick((0,10,0.9));
		let rkt = EMRocket(A_FireProjectile("EMRocket")); // Heat does not affect accuracy.
		A_StartSound("weapons/rocklf",1);
		rkt.heatbonus = ceil(invoker.heat);
		invoker.chargestate = CS_Overheat;
		invoker.heat += 20.;
	}

	states
	{
		Spawn:
			DEGL A -1;
			Stop;

		Select:
			DGLG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			DGLG A 1 A_DampedLower(35);
			Loop;

		Ready:
			DGLG A 1 A_EMReady();
			Loop;

		AltFire:
			DGLF AB 1
			{
				A_Charge();
				if(invoker.chargestate == CS_Ready)
				{
					A_Heat();
				}
				int newtics = (10+invoker.maxcharge - invoker.charge)/10 ;
				//console.printf(""..newtics);
				A_SetTics(newtics);
				if(invoker.charge > invoker.maxcharge/2)
				{
					A_GunFlash();
				}
			}
			DGLG A 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			DGLG A 0 A_UnCharge();
			Goto Ready;

		Fire:
			DGLF A 2 A_FireRocket();
			DGLF BCDE 3;
			DGLG ABC 4;
			DGLG CB 5;
			Goto Ready;

		//Flash:
		//	CHGF AB 1 Bright;
		//	Stop;

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
			PLSS C 1 Bright { A_StartSound("weapons/rocklx"); invoker.vel = (0,0,0); }
			PLSS C 3 Bright A_Explode(80+heatbonus,2*(80+heatbonus),fulldamagedistance:80+heatbonus);
			PLSS D 5 Bright;
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
			PLSS AB 3 Bright;
			Loop;
	}
}