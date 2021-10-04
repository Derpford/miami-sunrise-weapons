class MiamiMonster : Actor
{
	// Base class for Miami Sunrise enemies.

	double charge, chargemax;

	double range; // optimal range in map units

	int numShieldBonus; // how many shield bonuses to drop on special kill
	int numScoreBonus;
	name scoreBonus; // what item(s) to drop on special kill (why don't we have array props yet?)

	Property charge : chargemax;
	Property range : range;

	Property bonus : scoreBonus, numScoreBonus, numShieldBonus;

	default
	{
		MONSTER;
		+MISSILEMORE;
		MiamiMonster.charge 35.;
		MiamiMonster.range 512;
		MiamiMonster.bonus "CashBundle", 1, 1;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		charge = 0;
	}

	override void Tick()
	{
		Super.tick();
		//charge = clamp(0,charge-1,chargemax);

		if(target && Vec2To(target).length()<range)
		{
			bFRIGHTENED = true;
		}
		else
		{
			bFRIGHTENED = false;
		}
	}

	virtual bool SpecialDeath()
	{
		// returns true if we get a special death bonus.
		return false;
	}

	override void Die(Actor src, Actor inf, int flags, Name mod)
	{
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

	action void A_ChargeOrFire(double min = -1)
	{
		if(A_ChargeCheck(min))
		{
			invoker.SetState(invoker.ResolveState("Fire"));
		}
		else
		{
			invoker.SetState(invoker.ResolveState("Charge"));
		}
	}
}