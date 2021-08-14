class EMShotgun : EMWeapon replaces Shotgun
{
	// Big Chonky Gun. Can be pre-charged.

	default
	{
		EMWeapon.Charge 60, 2.5;
		EMWeapon.ChargeDecay 0.5, 0;
		EMWeapon.Heat 6.0, 2.5, 0.1;
	}

	action void A_FireShotty()
	{
		A_Discharge(30);
		A_GunFlash();
		A_Heat();
		for(int i = 0; i < 5; i++)
		{
			A_FireProjectile("EMPellet",angle:frandom(-invoker.heat,invoker.heat));
		}
	}

	states
	{
		Select:
			SHTG A 1 A_Raise(35);
			Loop;
		Deselect:
			SHTG A 1 A_Lower(35);
			Loop;

		Ready:
			SHTG A 1 { A_UnCharge(); A_EMReady(); }
			Loop;

		Fire:
			SHTG A 3 A_FireShotty();
			SHTG B 4; 
			SHTG C 4 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			SHTG D 5;
			SHTG CB 4;
			Goto Ready;
		AltFire:
			SHTG BC 3;
		AltHold:
			SHTG D 1 A_Charge();
			SHTG D 0 A_Refire();
			SHTG CB 2;
			Goto Ready;

		Flash:
			SHTF A 2 Bright;
			SHTF B 1 Bright;
			Stop;
	}
}

class EMPellet : EMShot
{
	// A slightly faster, slightly less dangerous EM round.
	default
	{
		Speed 70;
		DamageFunction 10+random(0,10);
		EMShot.Spread .2, .1;
		EMShot.Time 5;
	}
}