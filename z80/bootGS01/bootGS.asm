	relaxed on



ramrun	equ	0x4000

ram8kb	equ	0x6000

		ORG	0
		phase	0

START:
		DI
		ld	sp,ram8kb

		ld	a,0x30	;10MHz Z80
		out	(0x0f),a

		xor	a
		out	(6),a
		out	(7),a
		out	(8),a
		out	(9),a
		out	(0x16),a
		out	(0x17),a
		out	(0x18),a
		out	(0x19),a

		ld	hl,ramcode
		ld	de,ramrun
		push	de
		ld	bc,ramcend-ramcode
		ldir
		ret


ramcode:
		phase	ramrun


		ld	hl,0x8000 ; move to the RAM page 0 mapped into 8000-FFFF

		ld	a,4; 32768/8192 - move gs105a by four blocks



mov1:
		ex	af,af'

		ld	a,0x30
		out	(0x0f),a
		ld	a,2
		out	(0),a

		push	hl
		ld	de,ram8kb
		ld	bc,8192
		ldir


		ld	a,0x31
		out	(0x0f),a
		ld	a,0
		out	(0),a

		pop	de
		ld	hl,ram8kb
		ld	bc,8192
		ldir

		ex	de,hl

		ex	af,af'
		dec	a
		jr	nz,mov1



		xor	a
		out	(0),a
		ld	a,0x13
		out	(0x0f),a

		jp	0








		dephase
ramcend:

