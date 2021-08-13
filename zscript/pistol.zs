class EMPistol : EMWeapon replaces Pistol
{

	default
	{
		Weapon.SlotNumber 1;
		EMWeapon.Charge 35, 3;
		EMWeapon.ChargeDecay 0.1, 0.2;
		EMWeapon.Heat 2, .5, 0.01;
	}

	action void A_PistolShot()
	{
		A_GunFlash();
		A_Heat();
		A_FireProjectile("EMShot",angle:frandom(-invoker.heat,invoker.heat));
		A_Discharge(10);
	}

	states
	{
		Select:
			PISG A 1 A_Raise(35);
			Loop;
		Deselect:
			PISG A 1 A_Lower(35);
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