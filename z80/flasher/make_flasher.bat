@ECHO OFF

..\..\tools\asw\asw -cpu z80undoc -U -L flasher.a80
..\..\tools\asw\p2bin flasher.p flasher.rom -r $-$ -k
rem ..\sjasmplus --sym=sym.log --lst=dump.log -isrc make_flasher.a80

..\..\tools\mhmt\mhmt -mlz flasher.rom flasher_pack.rom

pause