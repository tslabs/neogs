@ECHO OFF

copy /B /Y ..\loader_ngs\loader_ngs.rom
copy /B /Y ..\main_rom\neogs.rom
addcrc loader_ngs.rom
ren crc.bin loader.crc
addcrc fpga.bin
ren crc.bin fpga.crc
addcrc neogs.rom
ren crc.bin neogs.crc

..\..\tools\asw\asw -cpu z80undoc -U -L create_update.a80
..\..\tools\asw\p2bin create_update.p ngs_rom.upd -r $-$ -k

del loader_ngs.rom
del neogs.rom
del loader.crc
del fpga.crc
del neogs.crc
del crc.bin

pause