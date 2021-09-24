class EMShotgun : EMWeapon replaces Shotgun
{
	// Big Chonky Gun. Can be pre-charged.

	default
	{
		Weapon.SlotNumber 2;
		EMWeapon.Charge 60, 2.5;
		EMWeapon.ChargeDecay 1.5, 0;
		EMWeapon.Heat 6.0, 2.5, 0.1;
		EMWeapon.ChargeSounds "weapons/shotgc", "weapons/shotgr", "weapons/idlec";
	}

	action void A_FireShotty()
	{
		if(A_CheckHeat())
		{
			A_Discharge(20);
			A_OffsetKick((0,40,0.2),false);
			A_GunFlash();
			A_Heat();
			A_StartSound("weapons/shotgf",1);
			for(int i = 0; i < 5; i++)
			{
				A_FireProjectile("EMPellet",angle:frandom(-invoker.heat,invoker.heat),pitch:frandom(-1,-3));
			}
		}
	}

	states
	{
		Spawn:
			SHOT A -1;
			Stop;
		Select:
			SHTG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			SHTG A 1 A_DampedLower(35);
			Loop;

		Ready:
			SHTG A 1 A_EMReady();
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
			SHTG D 0 A_UnCharge();
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