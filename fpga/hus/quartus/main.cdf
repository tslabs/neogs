/* Quartus II Version 9.0 Build 132 02/25/2009 SJ Full Version */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(EP1K30T144) Path("obj") File("main.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(EPM3064A) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
