@ECHO OFF

..\..\tools\asw\asw -cpu z80undoc -U -L flasher.a80
..\..\tools\asw\p2bin flasher.p flasher.rom -r $-$ -k
..\..\tools\mhmt\mhmt -mlz flasher.rom flasher_pack.rom

..\..\tools\asw\asw -cpu z80undoc -U -L make_flasher2scl.a80
..\..\tools\asw\p2bin make_flasher2scl.p flasher2scl.rom -r $-$ -k

..\..\tools\csum32\csum32 flasher2scl.rom
copy /B /Y flasher2scl.rom+csum32.bin flasher.scl

del flasher2scl.rom
del csum32.bin

pause