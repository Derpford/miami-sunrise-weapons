class EMPistol : EMWeapon replaces Pistol
{
	// Starting weapon, and a reliable one.
	default
	{
		Weapon.SlotNumber 1;
		EMWeapon.Charge 35, 3;
		EMWeapon.ChargeDecay 0.1, 0.2;
		EMWeapon.Heat 2, .5, 0.02;
		EMWeapon.ChargeSounds "weapons/plasmaf", "weapons/pisr", "weapons/idlec";
	}

	action void A_PistolShot()
	{
		if(A_CheckHeat())
		{
			A_GunFlash();
			A_OffsetVec((0,48,1.1));
			A_Heat();
			A_FireProjectile("EMShot",angle:frandom(-invoker.heat,invoker.heat),pitch:-2);
			A_Discharge(10);
			A_StartSound("weapons/pisf",1);
		}
	}

	states
	{
		Select:
			PISG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			PISG A 1 A_DampedLower(35);

			Loop;
		Ready:
			PISG A 1 A_EMReady();
			Loop;
		Fire:
			PISG B 2 A_PistolShot();
			PISG BCA 3;
			Goto Ready;
		AltFire:
			PISG B 1 A_Charge();
			PISG B 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			PISG B 0 A_UnCharge();
			Goto Ready;
		Flash:
			PISF A 2;
			Stop;
	}

}