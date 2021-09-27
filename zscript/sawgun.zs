class Maelstrom : EMWeapon replaces Chainsaw
{
	// What is best in guns?
	// To gib your enemies?
	// To see the timing before you?
	// Or to hear the salty chat messages as they ragequit?
	// This weapon fires automatically shortly after being loaded.
	// You cannot change the timing. It's like a mini-BFG.
	// It also pierces targets.

	default
	{
		Weapon.SlotNumber 2;
		EMWeapon.Charge 12, 1;
		EMWeapon.ChargeDecay 0, 0;
		EMWeapon.Heat 35, 45, 1;
		EMWeapon.ChargeSounds "weapons/ssgr", "weapons/pisr", "weapons/idlec";
	}

	action void A_SuperShot()
	{
		if(A_CheckHeat())
		{
			//A_GunFlash();
			A_OffsetKick((0,30,0.8));
			A_Overlay(-1,"Flash");
			A_Heat();
			A_StartSound("weapons/ssgf",1);
			if(A_CheckHeat())
			{
				A_FireProjectile("SuperBolt",angle:0,pitch:frandom(-1,-3));
			}
			A_Discharge(15);
		}
	}

	states
	{
		Select:
			REVG A 1 A_DampedRaise(35);
			Loop;
		Deselect:
			REVG A 1 A_DampedLower(35);
			Loop;
		Fire:
			REVG A 1; // Dummy fire state!
			Goto Ready;
		Ready:
			REVG A 1 A_EMReady(); 
			Loop;
		AltFire:
			REVG B 1 A_Charge();
			REVG B 0 {
				if(invoker.chargestate == CS_Ready)
				{
					return ResolveState("RealFire");
				}
				else if(invoker.chargestate == CS_Overheat)
				{
					return ResolveState("Ready");
				}
				else
				{
					return ResolveState(null);
				}
			}
			Loop;
		RealFire:
			REVG B 1 A_SuperShot();
			REVG C 2;
			REVG D 6;
			REVG C 10;
			REVG B 12;
			REVG A 1;
			Goto Ready;

		Flash:
			MUZL ABC 2 Bright;
			Stop;
	}
}

class SuperBolt : EMShot
{
	default
	{
		EMShot.Spread 0.20, 0.2;
		EMShot.Time 1;
		Speed 60;
		DamageFunction 50+random(0,25);
		+RIPPER;
	}
}