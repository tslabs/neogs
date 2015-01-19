

	CPU	Z80UNDOC
	RELAXED	ON

	include	"ports.inc"

	org	0x4000

	di
	im	0
	
	ld	a,M_NOROM+C_24MHZ+M_EXPAG
	out	(GSCFG0),a

	
	
	ld	a,0xC3 ; JP
	ld	(0x28),a
	ld	(0x30),a
	
	ld	hl,MP3_INT
	ld	(0x29),hl
	ld	hl,SD_INT
	ld	(0x31),hl
	
	ld	a,0x7F
	out	(INTENA),a
	out	(INTREQ),a
	ld	a,0x86
	out	(INTENA),a
	
	
	xor	a
	ld	(fin),a
	ld	(fout),a

	ld	a,0x81
	ld	(flags),a
	
	call	check
	ei
	
hloop
	halt
	jp	hloop

	
SD_INT
	ld	hl,fin
	inc	(hl)

	ld	hl,flags
	call	check_sd
	bit	7,(hl)
	call	nz,check_mp3
	ei
	ret

	
MP3_INT
	ld	hl,fout
	inc	(hl)
	
	ld	hl,flags
	call	check_mp3
	bit	0,(hl)
	call	nz,check_sd
	ei
	ret
	
	
check	
	ld	hl,flags
	
	bit	0,(hl)
	call	nz,check_sd
	
	bit	7,(hl)
	call	nz,check_mp3
	ret

check_sd
	ld	a,(fout)
	ld	c,a
	ld	a,(fin)
	ld	b,a
	sub	c
	cp	128
	jr	c,sd_start
	
	set	0,(hl)
	ret
	
sd_start	
	ld	a,C_DMA_SD
	out	(DMA_MOD),a
	ld	a,1
	out	(DMA_HAD),a
	ld	a,b
	add	a,a
	out	(DMA_MAD),a
	xor	a
	out	(DMA_LAD),a
	ld	a,0x80
	out	(DMA_CST),a
	
	res	0,(hl)
	ret

	
	
check_mp3
	ld	a,(fout)
	ld	c,a
	ld	a,(fin)
	ld	b,a
	sub	c
	jr	nz,mp3_start
	
	set	7,(hl)
	ret
	
mp3_start	
	ld	a,C_DMA_MP3
	out	(DMA_MOD),a
	ld	a,1
	out	(DMA_HAD),a
	ld	a,c
	add	a,a
	out	(DMA_MAD),a
	xor	a
	out	(DMA_LAD),a
	ld	a,0x80
	out	(DMA_CST),a

	res	7,(hl)
	ret
	
	
	
	
	
	

llloop
	ld	a,C_DMA_SD
	out	(DMA_MOD),a

	ld	a,1
	out	(DMA_HAD),a
	xor	a
	out	(DMA_MAD),a
	out	(DMA_LAD),a

	ld	a,0x80
	out	(DMA_CST),a

	in	a,(DMA_CST)
	and	0x80
	jr	nz,$-4

	
	
	ld	a,C_DMA_MP3
	out	(DMA_MOD),a
	
	ld	a,1
	out	(DMA_HAD),a
	xor	a
	out	(DMA_MAD),a
	out	(DMA_LAD),a

	ld	a,0x80
	out	(DMA_CST),a
	
	in	a,(DMA_CST)
	and	0x80
	jr	nz,$-4
	
	
	
	jp	llloop

fin	db	0
fout	db	0
flags	db	0
	