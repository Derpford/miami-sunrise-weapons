class EMWeapon : Weapon
{
	// Base class for EM weapons.
	// All EM weapons have a heat meter, a charge level,
	// and charge speed.
	// Heat affects accuracy and then disables the gun if you reach max heat.
	// Charge is necessary to fire the gun.

	enum ChargeStates
	{
		CS_Idle = 0,
		CS_Charging = 1,
		CS_Ready = 2,
		CS_Overheat = 3
	};

	double charge; double maxcharge; double chargespeed;
	double chargedecay; double readydecay;

	double heat; double maxheat; double heatspeed; double heatdecay;

	int chargestate; // charging, charged, overheat?

	property Charge : maxcharge, chargespeed;
	property ChargeDecay : chargedecay, readydecay;
	property Heat : maxheat, heatspeed, heatdecay;

	string readysound; // Play this when the gun's ready to fire.
	string chargesound; // Play this when the gun is charging.

	property ChargeSounds: chargesound, readysound;

	default
	{
		EMWeapon.Charge 35, 1;
		EMWeapon.ChargeDecay 0, 1;
		EMWeapon.Heat 2.5, 0.5, 0.1;
		EMWeapon.ChargeSounds "weapons/plasmaf","misc/i_pkup";
	}

	action void A_Charge()
	{
		if(invoker.chargestate != CS_Ready && invoker.chargestate != CS_Overheat)
		{
			A_StartSound(invoker.chargesound,1);
			invoker.chargestate = CS_Charging;
		}
	}

	action void A_UnCharge()
	{
		A_StopSound(1);
		if(invoker.chargestate != CS_Ready && invoker.chargestate != CS_Overheat)
		{
			invoker.chargestate = CS_Idle;
		}
	}

	action void A_Discharge(int amt = 1)
	{
		invoker.charge -= amt;
	}

	action void A_Heat()
	{
		invoker.heat += invoker.heatspeed;
	}

	action void A_EMReady(int flags = 0)
	{
		if(invoker.chargestate != CS_Ready)
		{
			flags |= WRF_NOPRIMARY; 
		}

		A_WeaponReady(flags);
	}

	override void DoEffect()
	{
		console.printf("Heat:"..heat);

		if(heat >= maxheat)
		{
			chargestate = CS_Overheat;
		}

		if(chargestate != CS_Overheat)
		{
			if(charge >= maxcharge)
			{
				chargestate = CS_Ready;
				owner.A_StartSound(readysound,3);
			}

			if(charge < 1 && chargestate == CS_Ready)
			{
				chargestate = CS_Idle;
			}
		}
		else
		{
			if(heat <= 0)
			{
				chargestate = CS_Idle;
			}
		}

		heat = max(0,heat-heatdecay);

		switch(chargestate)
		{
			case CS_Overheat:
				break;
			case CS_Idle:
				charge -= chargedecay;
				break;
			case CS_Charging:
				charge += chargespeed;
				break;
			case CS_Ready:
				charge -= readydecay;
				break;
		}	
	}

	states
	{
		Fire:
			TNT1 A 1;
		Ready:
			TNT1 A 1 A_EMReady();
			Loop;
		Select:
			TNT1 A 1 A_Raise(35);
			Loop;
		Deselect:
			TNT1 A 1 A_Lower(35);
			Loop;
	}
}

class EMShot: FastProjectile
{
	// Flies straight for a given number of tics, then deviates left or right and starts falling.

	double dhorizontal; // Horizontal delta. This value is randomized later.
	int flytimer; // The number of tics that the projectile will fly straight for.
	double dgravity; // Vertical delta, or how fast the projectile will accelerate down once it stops flying straight.
	bool deviated; // Flips to true once we've done our deviation stuff.

	property Spread : dhorizontal, dgravity;
	property Time : flytimer;

	default
	{
		EMShot.Spread .15, 0.1;
		EMShot.Time 2;
		Speed 50;
		DamageFunction 20+random(0,10);
		RenderStyle "Add";
	}

	override void Tick()
	{
		if(InStateSequence(curstate,ResolveState("Death")))
		{
			// This projectile is currently dying.
		}
		else
		{
			if(flytimer > 0)
			{
				flytimer -= 1;
			}
			else
			{
				if(!deviated)
				{
					dhorizontal *= frandom(-1,1);
					deviated = true;
				}

				Thrust(dhorizontal,angle+90);
				vel.z -= dgravity;
			}

		}


		super.Tick();
	}

	states
	{
		// Mostly a placeholder.
		Spawn:
			BAL1 AB 3 Bright;
			Loop;
		Death:
		XDeath:
		Crash:
			BAL1 CDE 5 Bright;
			TNT1 A -1;
			Stop;
	}
}