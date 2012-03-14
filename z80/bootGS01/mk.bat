asw -cpu z80 -L %1.asm
p2hex -r $-$ -F Intel %1.p
p2bin -r $-$ -l 0xFF %1.p

