..\..\tools\asl\asw -cpu z80undoc -L %1.asm
..\..\tools\asl\p2hex -r $-$ -F Intel %1.p
..\..\tools\asl\p2bin -r $-$ -l 0xFF %1.p

