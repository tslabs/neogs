@ECHO OFF

..\..\tools\asw\asw -cpu z80undoc -U -L loader_ngs.a80
..\..\tools\asw\p2bin loader_ngs.p loader_ngs.rom -r $-$ -k
REM ..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_loader_ngs.a80

pause