class EMRifle : EMWeapon replaces Chaingun
{
	// Fires rapidly. Heats rapidly.
	// Best used in short, controlled bursts.

	default
	{
		Weapon.SlotNumber 3;
		EMWeapon.Charge 30, 2;
		EMWeapon.ChargeDecay 0.2, 0.1;
		EMWeapon.Heat 8, 0.7, 0.1;
		EMWeapon.ChargeSounds "weapons/riflec", "weapons/rifler", "weapons/idlec";
	}

	action void A_RifleShot()
	{
		if(A_CheckHeat())
		{
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
			PLAS A -1;
			Stop;
		Select:
			PLSG B 1 A_Raise(35);
			Loop;
		Deselect:
			PLSG B 1 A_Lower(35);
			Loop;
		Ready:
			PLSG A 1 A_EMReady();
			Loop;
		Fire:
			PLSG A 3 A_RifleShot();
			PLSG B 2;
			PLSG B 0 A_Refire();
			PLSG B 8;
			Goto Ready;
		AltFire:
			PLSG B 1 A_Charge();
			PLSG B 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			PLSG B 2 A_UnCharge;
			PLSG A 1;
			Goto Ready;
		Flash:
			PLSF A 1 Bright;
			PLSF B 2 Bright;
			Stop;
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