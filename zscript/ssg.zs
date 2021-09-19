class EMShredder : EMWeapon replaces SuperShotgun
{
	// A powerful close-range weapon with a serious overheating issue.

	default
	{
		Weapon.SlotNumber 2;
		EMWeapon.Charge 35., 4.;	
		EMWeapon.ChargeDecay 1.,2.;
		EMWeapon.Heat 35., 35., 1.;
		EMWeapon.ChargeSounds "weapons/ssgc", "weapons/ssgr", "weapons/idlec";
	}

	action void A_FireShredder()
	{
		A_Heat();
		A_GunFlash();
		A_OffsetKick((0,0,0.3));
		A_StartSound("weapons/ssgf",1);
		// Left side.
		for(int i = 15; i > 0; i--)
		{
			A_FireProjectile("EMShredPellet",frandom(-invoker.heat/2.,0),pitch:frandom(-1,-4));
		}
		// Right side.
		for(int i = 15; i > 0; i--)
		{
			A_FireProjectile("EMShredPellet",frandom(invoker.heat/2.,0),pitch:frandom(-1,-4));
		}
		// Middle.
		for(int i = 5; i > 0; i--)
		{
			A_FireProjectile("EMShredPellet",frandom(invoker.heat/3.,-invoker.heat/3.),pitch:frandom(-1,-4));
		}
		A_Discharge();
	}

	states
	{
		Spawn:
			SGN2 A -1;
			Stop;

		Select:
			SHT2 C 1 A_DampedRaise(35);
			Loop;
		Deselect:
			SHT2 ABC 1 A_DampedLower(35);
		DesLoop:
			SHT2 C 1 A_DampedLower(35);
			Loop;

		Ready:
			SHT2 CBA 4;
		RealReady:
			SHT2 A 1 A_EMReady();
			Loop;

		AltFire:
			SHT2 A 1 A_Charge();
			SHT2 A 0 A_EMReady(WRF_NOSWITCH|WRF_NOBOB);
			SHT2 A 0 A_UnCharge();
			Goto RealReady;

		Fire:
			SHT2 A 1 A_FireShredder();
			SHT2 A 2;
			SHT2 B 3;
			SHT2 C 7;
			SHT2 D 12;
			SHT2 CCC 4 A_StartSound("misc/i_pkup");
			Goto Ready;

		Flash:
			SHT2 I 1;
			SHT2 J 2;
			Stop;
	}
}

class EMShredPellet : EMPellet
{
	// Smaller, but way more numerous. Also spreads way earlier.
	default
	{
		DamageFunction 5+random(0,5);
		EMShot.Time 0;
		EMShot.Spread .4, .1;
		Speed 30;
		MissileType "ShredTrail";
	}
}

class ShredTrail : EMTrail
{
	states
	{
		Spawn:
			PUFF A 2 Bright;
			Loop;
	}
}