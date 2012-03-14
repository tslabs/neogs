@ECHO OFF

..\..\tools\asw\asw -cpu z80undoc -U -L main_ngs.a80
..\..\tools\asw\p2bin main_ngs.p neogs.rom -r $-$ -k
rem ..\..\tools\sjasmplus\sjasmplus -isrc make_rom.a80

rem ..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_rom.a80

rem if %errorlevel% neq 0 goto end

rem copy /B /Y gsroml+gsromh gs105a.rom
rem del gsroml
rem del gsromh

pause
