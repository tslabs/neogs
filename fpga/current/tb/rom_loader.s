	CPU	Z80UNDOC
	RELAXED	ON

	include	"ports.inc"

	org	0

	ld	sp,0x8000

	ld	hl,code
	ld	de,0x4000
	push	de
	ld	bc,ecode-code
	ldir
	ret

code	
	;binclude	"timer_test.bin"
	include	"tmp.s"
ecode

