class EMPistol : EMWeapon replaces Pistol
{
	// Starting weapon, and a reliable one.
	default
	{
		Weapon.SlotNumber 2;
		Inventory.PickupMessage "Grabbed a pistol!";
		EMWeapon.Charge 35, 3;
		EMWeapon.ChargeDecay 0.1, 0.2;
		EMWeapon.ChargeSustain 10;
		EMWeapon.Heat 2, .5, 0.02;
		EMWeapon.ChargeSounds "weapons/plasmaf", "weapons/pisr", "weapons/idlec";
		EMWeapon.Price 50;
		EMWeapon.SellMessage "Sold a pistol.";
	}

	action void A_PistolShot()
	{
		if(A_CheckHeat())
		{
			A_GunFlash();
			A_OffsetKick((0,16,0.1));
			A_Heat();
			A_FireProjectile("EMShot",angle:frandom(-invoker.heat,invoker.heat),pitch:-2);
			A_Discharge(10);
			A_StartSound("weapons/pisf",1);
		}
	}

	states
	{
		Spawn:
			DEPI A -1;
			Stop;
		Select:
			DPIG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			DPIG A 1 A_DampedLower(35);

			Loop;
		Ready:
			DPIG A 1 A_EMReady();
			Loop;
		Fire:
			DPIF A 2 A_PistolShot();
			DPIG BCA 3;
			Goto Ready;
		AltFire:
			DPIG B 1 A_Charge();
			DPIG B 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			DPIG B 0 A_UnCharge();
			Goto Ready;
		//Flash:
		//	PISF A 2;
		//	Stop;
	}

}