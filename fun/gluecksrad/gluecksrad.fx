////                                                  \\
//||   Project: MTA - German ICE Reallife Gamemode    ||
//||   Gluecksrad - Texturersatz fuer das Radobjekt   ||
//\\                                                  //

texture gTexture;

sampler gSampler = sampler_state
{
	Texture   = ( gTexture );
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU  = Clamp;
	AddressV  = Clamp;
};

technique replaceTexture
{
	pass P0
	{
		Texture[0] = gTexture;
		AlphaBlendEnable = true;
		SrcBlend = SrcAlpha;
		DestBlend = InvSrcAlpha;
	}
}

// Falls die Grafikkarte den Effekt nicht unterstuetzt, bleibt das Objekt
// einfach unveraendert sichtbar statt komplett zu verschwinden.
technique fallback
{
	pass P0
	{
	}
}
