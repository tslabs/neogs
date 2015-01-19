
	CPU	Z80UNDOC
	RELAXED	ON

	include	"ports.inc"




LFSR	MACRO

	;23bit lfsr, bits 22,17 -- 0100_0010__0000_0000__0000_0000
	;
	; regs BDE

	srl	b
	rr	d
	rr	e
	sbc	a,a
	and	0x42
	xor	b
	ld	b,a

	ENDM

TSTRAM4	MACRO

	push	bc
	push	de

.wrloop
	ld	a,ixl
	out	(c),a
	LFSR
	ld	(hl),a
	inc	ixl
	jr	nz,.wrloop


	pop	de
	pop	bc

.rdloop
	ld	a,ixl
	out	(c),a
	LFSR
	cp	(hl)
	jr	nz,.error
	inc	ixl
	jr	nz,.rdloop
	jr	.end

.error
	ld	a,3
	out	(WIN1),a
	ld	sp,0x8000
	jp	$+3
	jp	start2

.end
	ENDM


TSTRAM2	MACRO

	push	bc
	push	de

	ld	ixl,0
.wrloop
	ld	a,ixl
	out	(c),a
	LFSR
	ld	(hl),a
	inc	ixl
	ld	a,ixl
	add	a,a
	jr	nc,.wrloop


	pop	de
	pop	bc

	ld	ixl,0
.rdloop
	ld	a,ixl
	out	(c),a
	LFSR
	cp	(hl)
	jr	nz,.error
	inc	ixl
	ld	a,ixl
	add	a,a
	jr	nc,.rdloop
	jr	.end

.error
	inc	a
	out	(LEDCTR),a
	jr	.error

.end
	ENDM


TSTRM22	MACRO

	push	bc
	push	de

	ld	ixl,0
.wrloop
	ld	a,ixl
	rrca
	out	(c),a
	LFSR
	ld	(hl),a
	inc	ixl
	ld	a,ixl
	add	a,a
	jr	nc,.wrloop


	pop	de
	pop	bc

	ld	ixl,0
.rdloop
	ld	a,ixl
	rrca
	out	(c),a
	LFSR
	cp	(hl)
	jr	nz,.error
	inc	ixl
	ld	a,ixl
	add	a,a
	jr	nc,.rdloop
	jr	.end

.error
	inc	a
	out	(LEDCTR),a
	jr	.error

.end
	ENDM




	org	0x4000
; we are in 3rd 16k page now

	; norom, no ramro, 24mhz

	ld	a,M_NOROM+C_24MHZ+M_EXPAG
	out	(GSCFG0),a

	
	xor	a
	ld	(led),a

	ld	l,a
	ld	ixl,a

	ld	b,0xcc
	ld	de,0x5aa5

testloop
	ld	a,(led)
	inc	a
	ld	(led),a
	rrca
	rrca
	out	(LEDCTR),a


	ld	h,0xE0
	ld	c,WIN3
	TSTRAM4


	ld	h,0xA0
	ld	c,WIN2
	TSTRAM4


	ld	a,3
	out	(WIN2),a
	ld	sp,0xc000
	jp	$+0x4000+3

	ld	h,0x60
	ld	c,WIN1
	TSTRAM4
	
	ld	a,3
	out	(WIN1),a
	ld	sp,0x8000
	jp	$+3


	ld	h,0x20
	ld	c,WIN0
	TSTRAM4


	ld	h,0xA0
	ld	c,MPAG
	TSTRAM4

	ld	h,0xE0
	ld	c,MPAGEX
	TSTRAM4

	jp	testloop

start2
	xor	a
	ld	(led),a
	ld	l,a

loop2
	ld	a,(led)
	inc	a
	ld	(led),a
	rrca
	rrca
	rrca
	out	(LEDCTR),a

	ld	h,0xE0
	ld	c,WIN3
	TSTRAM2


	ld	h,0xA0
	ld	c,WIN2
	TSTRAM2


	ld	a,3
	out	(WIN2),a
	ld	sp,0xc000
	jp	$+0x4000+3

	ld	h,0x60
	ld	c,WIN1
	TSTRAM2
	
	ld	a,3
	out	(WIN1),a
	ld	sp,0x8000
	jp	$+3


	ld	h,0x20
	ld	c,WIN0
	TSTRAM2


	ld	h,0xA0
	ld	c,MPAG ;128 values for each port -- only 64 for mpag!!!
	TSTRM22

	ld	h,0xE0
	ld	c,MPAGEX
	TSTRM22

	jp	loop2



led	equ	$

