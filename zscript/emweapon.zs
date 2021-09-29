class EMWeapon : Weapon
{
	// Base class for EM weapons.
	// All EM weapons have a heat meter, a charge level,
	// and charge speed.
	// Heat affects accuracy and then disables the gun if you reach max heat.
	// Charge is necessary to fire the gun.

	mixin DampedSpringWep;

	enum ChargeStates
	{
		CS_Idle = 0,
		CS_Charging = 1,
		CS_Ready = 2,
		CS_Overheat = 3
	};

	double charge; double maxcharge; double chargespeed;
	double chargedecay; double readydecay;
	double chargesustain;

	double heat; double maxheat; double heatspeed; double heatdecay;

	double heatframes; // set when heating up, delays heat decay

	int chargestate; // charging, charged, overheat?

	property Charge : maxcharge, chargespeed;
	property ChargeDecay : chargedecay, readydecay;
	property ChargeSustain : chargesustain;
	property Heat : maxheat, heatspeed, heatdecay;

	string readysound; // Play this when the gun's ready to fire.
	string chargesound; // Play this when the gun is charging.
	string idlechargesound; // Play this while the gun is charged.

	property ChargeSounds: chargesound, readysound, idlechargesound;

	default
	{
		EMWeapon.Charge 35, 1;
		EMWeapon.ChargeDecay 0, 1;
		EMWeapon.ChargeSustain 0;
		EMWeapon.Heat 2.5, 0.5, 0.1;
		EMWeapon.ChargeSounds "weapons/plasmaf","misc/i_pkup", "weapons/idlec";
	}

	action bool A_CheckHeat()
	{
		return invoker.chargestate != CS_Overheat;
	}

	action void A_Charge()
	{
		if(invoker.chargestate != CS_Ready && invoker.chargestate != CS_Overheat)
		{
			A_StartSound(invoker.chargesound,1,CHANF_NOSTOP);
			invoker.chargestate = CS_Charging;
		}
	}

	action void A_UnCharge()
	{
		//A_StopSound(1);
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
		invoker.heatframes = invoker.heatspeed;
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
		// Some stuff only needs to happen while this weapon is active.
		if(owner.player.readyweapon == self)
		{
			A_OffsetTick();
			if(chargestate == CS_Overheat || GetAge()%5 == 0)
			{
				for(double i = 0.; i < heat; i+=heatspeed*random(2,4))
				{
					vector3 newpos = (0,0,36);
					double dangle, dpitch;
					dangle = owner.angle+frandom(-5,5);
					dpitch = owner.pitch+frandom(-1,5);
					let it = owner.Spawn("HeatSteam",owner.pos+newpos);
					it.Vel3DFromAngle(16,dangle,dpitch);
					it.SetOrigin(it.pos+it.vel, false);
					it.Vel3DFromAngle(GetDefaultSpeed("HeatSteam"),dangle,dpitch);
				}
			}

			if(chargestate == CS_Ready)
			{
				double vol = charge/maxcharge;
				owner.A_StartSound(idlechargesound,5,CHANF_NOSTOP);
				owner.A_SoundVolume(5,vol);
			}
			else
			{
				owner.A_StopSound(5);
			}

		}

		if(heat >= maxheat)
		{
			chargestate = CS_Overheat;
		}

		if(chargestate != CS_Overheat)
		{
			if(charge >= maxcharge && chargestate != CS_Ready)
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

		if(heatframes <= 0)
		{
			heat = max(0,heat-heatdecay);
		}
		else
		{
			heatframes = max(0,heatframes-heatdecay);
		}

		switch(chargestate)
		{
			case CS_Overheat:
				charge = max(0,charge-chargedecay);
				break;
			case CS_Idle:
				charge = max(0,charge-chargedecay);
				break;
			case CS_Charging:
				charge += chargespeed;
				break;
			case CS_Ready:
				charge = max(chargesustain,charge-readydecay);
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
		MissileType "EMTrail";
		MissileHeight 8;
		Radius 4;
		Height 4;
		Decal "RedPlasmaScorch";
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
			PLS2 AB 3 Bright;
			Loop;
		Death:
		XDeath:
		Crash:
			PLS2 CDE 5 Bright;
			TNT1 A -1;
			Stop;
	}
}

class EMTrail : Actor
{
	// A visual-only trail for EM shots.
	default
	{
		+NOINTERACTION;
		RenderStyle "Add";
		Scale 0.5;
	}

	override void Tick()
	{
		super.Tick();
		A_FadeOut();
		A_SetScale(scale.x*0.9);
	}

	states
	{
		Spawn:
			PLS2 AB 3 Bright;
			Loop;
	}
}

class HeatSteam : Actor
{
	// Non-interactible actor for visually representing steam.

	bool fade;

	default
	{
		+NOINTERACTION;
		RenderStyle "Add";
		scale 0.5;
		Alpha 0.3;
		Speed 5;
	}

	override void Tick()
	{
		vel.z += 0.05;
		super.Tick();
	}

	action void A_FadeInOut()
	{
		// Fade in, then out.
		if(invoker.fade)
		{
			A_FadeOut();
		}
		else
		{
			invoker.alpha += 0.1;
			if(invoker.alpha >= 1.)
			{
				invoker.fade = true;
			}
		}
	}


	states
	{
		Spawn:
			PUFF CDE 5 { A_SetScale(scale.x*1.1); A_FadeInOut(); }
		FadeLoop:
			PUFF E 1 { A_SetScale(scale.x*1.1); A_FadeInOut(); }
			Loop;
	}
}