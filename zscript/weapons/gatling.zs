class MiamiSunset : EMWeapon replaces BFG9000
{
	// Your days are numbered. This enormous weapon is the ultimate in rapid fire death.

	default
	{
		Weapon.SlotNumber 5;
		Inventory.PickupMessage "The Miami Sunset. Their days are numbered.";
		EMWeapon.Charge 100, 2;
		EMWeapon.ChargeDecay 0.3,0.05;
		EMWeapon.Heat 50, 0.5, 0.1;
		EMWeapon.ChargeSounds "weapons/gatlc","weapons/gatlr","weapons/idlec";
		EMWeapon.Price 500;
		EMWeapon.SellMessage "How did you find TWO of these!?";
	}

	action void A_FireGatling()
	{
		if(A_CheckHeat())
		{
			double xspread = frandom(-5,5);
			A_OffsetKick((-xspread,10,0.2));
			A_Heat();
			A_FireProjectile("GatlingShot",xspread,pitch:frandom(0,-2));
			A_StartSound("weapons/gatlf");
		}
	}

	action void A_SetGatTics()
	{
		int newtics = (20+invoker.maxcharge - invoker.charge)/20 ;
		A_SetTics(newtics);
	}

	states
	{
		Spawn:
			DEGT A -1;
			Stop;

		Select:
			DGTG A 1 A_DampedRaise(35);
			Loop;

		Deselect:
			DGTG A 1 A_DampedLower(35);
			Loop;

		Ready:
			DGTG A 1 { A_EMReady(); }
			DGTG A 0
			{
				if(invoker.chargestate != CS_Ready)
				{
					return ResolveState("Ready");
				}
				else
				{
					return ResolveState(null);
				}
			}
			DGTG BCD 1 { A_EMReady(); }
			Loop;

		AltFire:
			DGTG A 0 A_StartSound("weapons/gatls",2);
			DGTG ABCD 1
			{
				A_Charge();
				invoker.heat = max(0, invoker.heat - 0.1);
				A_SetGatTics();
			}
			DGTG A 0 A_EMReady(WRF_NOSWITCH);
			DGTG A 0 A_Uncharge();
			Goto Ready;

		Fire:
			DGTF A 1 A_FireGatling();
			DGTF B 1;
			DGTG CD 1;
			DGTG A 0 A_EMReady(WRF_NOSWITCH);
			DGTG ABCD 2 A_SetGatTics();
			DGTG ABCD 3 A_SetGatTics();
			Goto Ready;
	}
}

class GatlingShot : EMShot
{
	// Big. Heavy. Slow. Painful.
	default
	{
		EMShot.Spread .3, .2;
		EMShot.Time 6;
		DamageFunction 20+random(0,40);
		Speed 50;
		Scale 1.5;
	}
}