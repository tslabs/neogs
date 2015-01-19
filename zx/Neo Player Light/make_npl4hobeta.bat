@ECHO OFF

..\..\tools\asw\asw -U -L play4ngs.a80
..\..\tools\asw\p2bin play4ngs.p play4ngs.rom -r $-$ -k

..\..\tools\mhmt\mhmt -mlz play4ngs.rom play4ngs_pack.rom

..\..\tools\asw\asw -U -L play_ngs.a80
..\..\tools\asw\p2bin play_ngs.p npl.rom -r $-$ -k

..\..\tools\mhmt\mhmt -mlz npl.rom npl_pack.rom

..\..\tools\asw\asw -U -L make_npl4hobeta.a80
..\..\tools\asw\p2bin make_npl4hobeta.p NPL.$C -r $-$ -k

pause