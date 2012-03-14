@ECHO OFF

..\..\tools\asw\asw -cpu z80undoc -U -L flasher.a80
..\..\tools\asw\p2bin flasher.p flasher.rom -r $-$ -k
..\tools\mhmt -mlz fatall.rom fatall_pack.rom

..\..\tools\asw\asw -cpu z80undoc -U -L flasher4hobeta.a80
..\..\tools\asw\p2bin flasher4hobeta.p FLASHNGS.$C -r $-$ -k

pause