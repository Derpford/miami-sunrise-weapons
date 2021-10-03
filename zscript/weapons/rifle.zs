class EMRifle : EMWeapon replaces Chaingun
{
	// Fires rapidly. Heats rapidly.
	// Best used in short, controlled bursts.

	default
	{
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "Grabbed an EM Rifle!";
		EMWeapon.Charge 30, 2;
		EMWeapon.ChargeDecay 0.2, 0.1;
		EMWeapon.Heat 8, 0.7, 0.1;
		EMWeapon.ChargeSounds "weapons/riflec", "weapons/rifler", "weapons/idlec";
	}

	action void A_RifleShot()
	{
		if(A_CheckHeat())
		{
			A_OffsetKick((0,10,0.1),true);
			A_GunFlash();
			A_Heat();
			double spread = invoker.heat/2.;
			A_FireProjectile("EMRifleShot",angle:frandom(-spread,spread),pitch:frandom(-1,-spread));
			//A_Discharge(1);
			A_StartSound("weapons/riflef",1);
		}
	}

	states
	{
		Spawn:
			DEPG A -1;
			Stop;
		Select:
			DPGG D 1 A_DampedRaise(35);
			Loop;
		Deselect:
			DPGG ABCD 5 A_DampedLower(35);
		DesLoop:
			DPGG D 1 A_DampedLower(35);
			Loop;
		Ready:
			DPGG CBA 4;
		ReadyLoop:
			DPGG A 1 A_EMReady();
			Loop;
		Fire:
			DPGF A 1 A_RifleShot();
			DPGF BC 1;
			DPGG B 2;
			DPGG B 0 A_Refire();
			DPGG B 1 A_OffsetKick((5,15,0.1));
			DPGG C 5;
			Goto Ready;
		AltFire:
			DPGG C 1 A_Charge();
			DPGG B 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			DPGG B 2 A_UnCharge;
			DPGG A 1;
			Goto ReadyLoop;
		//Flash:
		//	PLSF A 1 Bright;
		//	PLSF B 2 Bright;
		//	Stop;
	}
}

class EMRifleShot : EMShot
{
	// Fast, deadly, deviates less but falls faster.

	default
	{
		EMShot.Spread .05, .1;
		EMShot.Time 1;
		Speed 60;
		DamageFunction 15+random(0,20);
	}
}