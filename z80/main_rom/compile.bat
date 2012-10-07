echo off

"%IAR%\az80.exe" main_ngs.asm -uu -o neogs.r01 -l neogs.lst
"%IAR%\xlink.exe" -Hff -f neogs.xcl neogs.r01

"..\..\tools\finesplit\finesplit.exe" neogs.rom
copy /b neogs.rom.00 + neogs.rom.03 neogs.rom

del neogs.rom.bat
del neogs.rom.00
del neogs.rom.01
del neogs.rom.02
del neogs.rom.03
del neogs.r01

pause
