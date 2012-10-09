echo off

"%IAR%\az80.exe" main_ngs.asm -uu -o neogs.r01 -L
"%IAR%\xlink.exe" -Hff -f neogs.xcl -o neogs.rom -L -xehmisn neogs.r01

"..\..\tools\finesplit\finesplit.exe" neogs.rom
copy /b neogs.rom.00 + neogs.rom.03 neogs.rom
copy /b page0.bin + pageFF.bin + neogs.rom + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin + pageFF.bin+ page14.bin + pageFF.bin bootgs.rom

del neogs.rom.bat
del neogs.rom.00
del neogs.rom.01
del neogs.rom.02
del neogs.rom.03
del neogs.r01

pause
