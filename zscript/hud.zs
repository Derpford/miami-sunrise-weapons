class MiamiUI : BaseStatusBar
{
	double size; // size of the bars

	double hpval, armval, heatval, chargeval; // fill percentage
	double armoramount, armormax; // armor details
	int leftbarf, rightbarf, cbarf, ctextf, ltextf, rtextf;

	HUDFont mConFont; // Console font.

	override void Init()
	{
		// Set the size value here.
		size = 128.0;
		mConFont = HUDFont.Create("CONFONT");

		// Set up some common position flags.
		leftbarf = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM;
		rightbarf = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM;
		cbarf = DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER_BOTTOM;
		ctextf = DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER_BOTTOM | DI_TEXT_ALIGN_CENTER;
		ltextf = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM | DI_TEXT_ALIGN_LEFT;
		rtextf = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM | DI_TEXT_ALIGN_RIGHT;
	}

	void DrawHudBar(String img, Vector2 pos, double size, double xclip, double yclip, int flags)
	{
		// Draws a bar on the HUD, carefully.
		// Originally in cyberpunkshootout.

		int cx, cy, cw, ch; // save our current cliprect
		[cx,cy,cw,ch] = Screen.GetClipRect();

		Vector2 clipPos;
		int clipFlags;
		[clipPos, clipFlags] = AdjustPosition(pos, flags, size*xclip, size*yclip);
		SetClipRect(clipPos.x, clipPos.y, size*xclip, size*yclip, clipFlags);
		DrawImage(img,pos,flags);

		Screen.SetClipRect(cx,cy,cw,ch);//restore it
	}

	override void Draw(int state, double ticfrac)
	{
		super.draw(state,ticfrac);
		let plr = MiamiPlayer(CPlayer.mo);
		// Start by gathering all our numbers.
		hpval = clamp(0,double(plr.health),100)/double(plr.maxhealth);
		//[armoramount, armormax] = GetAmount("BasicArmor");
		armoramount = plr.shield;
		armormax = max(GetAmount("ShieldPoints"),1);
		let wpn = EMWeapon(plr.player.ReadyWeapon);
		let scr = plr.score;

		armval = double(armoramount)/double(armormax);

		if(wpn) 
		{ 
			chargeval = wpn.charge/wpn.maxcharge; 
			heatval = wpn.heat/wpn.maxheat;
		}

		// And now the fun part.
		beginHUD();

		// Left panel, health and armor.
		DrawImage("HUDBACK", (0,0), leftbarf);
		DrawHudBar("HUDBAR1", (0,0), size, 1.0, hpval, leftbarf);
		DrawHudBar("HUDBAR2", (0,0), size, 1.0, armval, leftbarf);
		DrawString(mConFont, FormatNumber(armormax,3,format:FNF_FILLZEROS),(44,-12),ltextf, Font.CR_CYAN);
		//DrawString(mConFont, FormatNumber(plr.health,3,format:FNF_FILLZEROS),(112,-16),ltextf, Font.CR_BRICK);

		// Right pannel, charge and heat.
		DrawImage("HUDBACK2", (0,0), rightbarf);
		DrawHudBar("HUDBAR4", (0,0), size, 1.0, chargeval, rightbarf);
		DrawHudBar("HUDBAR5", (0,0), size, 1.0, heatval, rightbarf);

		// Score.
		DrawString(mConFont, FormatNumber(scr,10,format:FNF_FILLZEROS), (0,-32), ctextf, Font.CR_WHITE);
		// Inventory icon.
		if(plr.invsel)
		{
			DrawInventoryIcon(plr.invsel, (-16,-16), rightbarf);
			DrawString(mConFont,FormatNumber(plr.invsel.Amount),(-8,-16), rtextf);
		}

		// Keys.
		String keySprites[6] =
		{
			"STKEYS2",
			"STKEYS0",
			"STKEYS1",
			"STKEYS5",
			"STKEYS3",
			"STKEYS4"
		};

		for(int i = 0; i < 6; i++)
		{
			if(plr.CheckKeys(i+1,false,true)) { DrawImage(keySprites[i],(-40+(16*i),-8),cbarf,scale:(2,2)); }
		}
	}
}