class MiamiUI : BaseStatusBar
{
	double size; // size of the bars

	double hpval, armval, heatval, chargeval; // fill percentage
	double armoramount, armormax; // armor details

	HUDFont mConFont; // Console font.

	override void Init()
	{
		// Set the size value here.
		size = 128.0;
		mConFont = HUDFont.Create("CONFONT");
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
		hpval = double(plr.health)/double(plr.maxhealth);
		[armoramount, armormax] = GetAmount("BasicArmor");
		let wpn = EMWeapon(plr.player.ReadyWeapon);
		let scr = plr.score;

		if(armoramount && armormax) { armval = double(armoramount)/double(100); }

		if(wpn) 
		{ 
			chargeval = wpn.charge/wpn.maxcharge; 
			heatval = wpn.heat/wpn.maxheat;
		}

		// Set up some common position flags.
		int leftbarf = DI_SCREEN_LEFT_BOTTOM | DI_ITEM_LEFT_BOTTOM;
		int rightbarf = DI_SCREEN_RIGHT_BOTTOM | DI_ITEM_RIGHT_BOTTOM;
		int centertxtf = DI_SCREEN_CENTER_BOTTOM | DI_ITEM_CENTER_BOTTOM | DI_TEXT_ALIGN_CENTER;

		// And now the fun part.
		beginHUD();

		// Left panel, health and armor.
		DrawImage("HUDBACK", (0,0), leftbarf);
		DrawHudBar("HUDBAR1", (0,0), size, 1.0, hpval, leftbarf);
		DrawHudBar("HUDBAR2", (0,0), size, 1.0, armval, leftbarf);

		// Right pannel, charge and heat.
		DrawImage("HUDBACK2", (0,0), rightbarf);
		DrawHudBar("HUDBAR4", (0,0), size, 1.0, chargeval, rightbarf);
		DrawHudBar("HUDBAR5", (0,0), size, 1.0, heatval, rightbarf);

		// Score.
		DrawString(mConFont, FormatNumber(scr,10,format:FNF_FILLZEROS), (0,-32), centertxtf, Font.CR_WHITE);

	}
}