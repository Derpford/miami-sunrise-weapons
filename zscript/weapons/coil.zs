class Coilgun : EMWeapon replaces PlasmaRifle
{
	// A railgun which provides long-distance firepower.
	// Can be held in a ready state, but only at about 50% effectiveness.

	default
	{
		Weapon.SlotNumber 4;
		Inventory.PickupMessage "Snagged a Coilgun! Pierce the heavens.";
		EMWeapon.Charge 60, 1.5;
		EMWeapon.ChargeDecay 1., 1.;
		EMWeapon.ChargeSustain 30;
		EMWeapon.Heat 8.0, 5.0, 0.1;
	}

	action void A_FireSniper()
	{
		if(A_CheckHeat())
		{
			double shotcharge = invoker.charge/invoker.maxcharge;
			A_Discharge(60);
			A_OffsetKick((0,50,0.2),false);
			A_GunFlash();
			A_Heat();
			A_StartSound("weapons/coilf",1);
			// Projectile fired here.
			let bolt = EMCoilBolt(A_FireProjectile("EMCoilBolt"));
			bolt.chargebonus = clamp(0.5,shotcharge,1.0);
		}
	}

	states
	{
		Spawn:
			COLI A -1;
			Stop;

		Select:
			COLG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			COLG A 1 A_DampedLower(35);
			Loop;

		Ready:
			COLG A 1 A_EMReady();
			Loop;

		Fire:
			COLG B 3 A_FireSniper();
			COLG C 4;
			COLG D 10;
			COLG EF 2;
			COLG G 3;
			COLG H 4;
			COLG I 3;
			COLG JK 5;
			Goto Ready;

		AltFire:
			COLG EF 3 A_Charge();
		AltHold:
			COLG JJKKFFEEAA 1
			{
				A_Charge();
				//A_SetTics(1+ceil((invoker.maxcharge-invoker.charge)/20.)); 
				A_EMReady(WRF_NOSWITCH|WRF_NOSECONDARY);
			}
			COLG D 0 A_EMReady(WRF_NOSWITCH);
			COLG D 0 A_UnCharge();
			COLG JK 2;
			Goto Ready;
	}
}

class EMCoilBolt : EMShot
{
	// Long shot, high power.
	double chargebonus;

	default
	{
		EMShot.Spread .03, .1;
		EMShot.Time 10;
		Speed 80;
		DamageFunction (100+random(0,20))*chargebonus;
	}
}