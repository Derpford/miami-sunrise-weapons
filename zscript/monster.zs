class MiamiMonster : Actor
{
	// Base class for Miami Sunrise enemies.

	double charge, chargemax;

	bool laser;
	Property laser : laser;

	double wobble; // How far the monster's aim wobbles.
	Property wobble: wobble;

	double range; // optimal range in map units

	int nextPause; // When are we gonna stop to look around, and how long?

	int numShieldBonus; // how many shield bonuses to drop on special kill
	int numScoreBonus;
	name scoreBonus; // what item(s) to drop on special kill (why don't we have array props yet?)

	string chargesound, readysound;

	Property charge : chargemax;
	Property range : range;
	Property sounds : chargesound, readysound;

	Property bonus : scoreBonus, numScoreBonus, numShieldBonus;

	default
	{
		MONSTER;
		+MISSILEMORE;
		MiamiMonster.charge 35.;
		MiamiMonster.range 512;
		MiamiMonster.bonus "CashBundle", 1, 1;
		MiamiMonster.sounds "weapons/plasmaf", "weapons/i_pkup";
		MiamiMonster.laser true;
		MiamiMonster.wobble 0.7;
	}

	void SpawnLaser()
	{
		FLineTraceData data;
		float dist = 512;
		LineTrace(angle,dist,pitch,offsetz:32,data:data);
		Vector3 spawnpos = pos;
		spawnpos.z += 32;
		for(int i = 0; i<data.distance; i++)
		{
			Vector3 newpartpos = data.HitDir*i;
			A_SpawnParticle("FF1111",SPF_FULLBRIGHT,1,1+(2*(i/dist)),0,newpartpos.x,newpartpos.y,newpartpos.z+32,startalphaf:(dist-i)/dist);
		}
	}

	action void A_MiamiFire(String missile, Vector3 pos = (0,0,0),double ang = 0, double pit = 0)
	{
		/*
		// Pitch calculation.
		if(invoker.target)
		{
			double dist = invoker.Vec2To(invoker.target).Length();
			double heightdiff = invoker.target.pos.z - invoker.pos.z;
			invoker.pitch = atan2(heightdiff,dist);	
			//console.printf("Shot pitch: "..invoker.pitch);
		}
		*/
		if(pos == (0,0,0))
		{
			pos = invoker.Vec3Angle(8,invoker.angle,32);
		}
		let it = Spawn(missile,pos);
		if(it)
		{
			//console.printf("Fired successfully");
			it.target = invoker;
			it.angle = invoker.angle+ang;
			it.pitch = invoker.pitch+pit;
			it.Vel3DFromAngle(it.speed,it.angle,it.pitch);
		}
	}

	action void A_SetWanderTics()
	{
		int len = 4;
		if(getAge()>invoker.nextPause)
		{
			len = invoker.nextPause/2;
			invoker.nextPause = GetAge()+len+random(35,105);
		}
		A_SetTics(len);
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		nextPause = random(70,105);
		charge = 0;
	}

	override void Tick()
	{
		Super.tick();

		// Aim wobble.

		angle += frandom(-wobble,wobble);
		double pitchfac = pitch/90.; // should produce a value between -1 and 1
		double wobblefac = -pitchfac * wobble; // up to 2x wobble in the right direction
		pitch += frandom(-wobble+wobblefac,wobble+wobblefac);

		if(InStateSequence(curstate,ResolveState("Spawn")))
		{
			A_Look();
		}
		//charge = clamp(0,charge-1,chargemax);

		if(!self.bCORPSE && target)
		{
			SpawnLaser();
		}

		if(!isFrozen())
		{
			if(A_ChargeCheck(0))
			{
				A_StartSound("weapons/idlec",2,CHANF_NOSTOP);
			}

			if(target && Vec2To(target).length()<range)
			{
				bFRIGHTENED = true;
			}
			else
			{
				bFRIGHTENED = false;
			}
		}
	}

	virtual bool SpecialDeath()
	{
		// returns true if we get a special death bonus.
		return false;
	}

	override void Die(Actor src, Actor inf, int flags, Name mod)
	{
		charge = 0;
		if(SpecialDeath())
		{
			for(int i = 0; i < numShieldBonus; i++)
			{
				A_SpawnItemEX("ShieldBonus",xvel:frandom(-3,3),yvel:frandom(-3,3),zvel:frandom(8,12));
			}

			for(int i = 0; i < numScoreBonus; i++)
			{
				A_SpawnItemEX(scoreBonus,xvel:frandom(-3,3),yvel:frandom(-3,3),zvel:frandom(8,12));
			}
		}	
		Super.Die(src,inf,flags,mod);
	}

	action void A_Charge(double amt = 1.)
	{
		invoker.charge += amt;
		A_StartSound(invoker.chargesound,1,CHANF_NOSTOP);
		//console.printf("Charge: "..invoker.charge);
	}

	action void A_Discharge(double amt = 1.)
	{
		invoker.charge = clamp(0,invoker.charge-amt,invoker.charge);
	}

	action bool A_ChargeReady()
	{
		return invoker.charge >= invoker.chargemax;
	}

	action bool A_ChargeCheck(double amt = -1)
	{
		if(amt >= 0)
		{
			return invoker.charge > amt;
		}
		else
		{
			return invoker.charge > invoker.chargemax;
		}
	}

	action void A_ChargeOrFire(double min = -1, bool see = false)
	{
		if(A_ChargeCheck(min))
		{
			invoker.A_StartSound(invoker.readysound,1);
			if(!see)
			{
				invoker.SetState(invoker.ResolveState("Fire"));
			}
			else
			{
				invoker.SetState(invoker.ResolveState("See"));
			}
		}
		else
		{
			invoker.SetState(invoker.ResolveState("Charge"));
		}
	}
}