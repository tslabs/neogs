        ; HIGH ROM INCLUDES
	; PHASE GSRomBaseH
        ; ORG GSRomBaseH - h'8000

        ; ASEG h'4000

;INCLUDE "INIT_H.a80"

INITVAR DI
;---patched
        CALL Patch5i1
;---
        EX AF,AF'
        LD A,(NUMPG)
        LD SP,h'8000
        LD HL,h'8080
        LD B,h'00
INITV00 PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        DJNZ INITV00
        LD HL,h'0000
        LD B,h'FE
INITV01 PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        PUSH HL
        DJNZ INITV01
        LD SP,ISTACK
        LD (NUMPG),A
        EX AF,AF'
;---patched
        CALL Patch5i2
;---
        LD A,h'00
        LD (INFO),A
        XOR A
        LD (ROMPG),A
        LD HL,DAC0
        LD A,(HL)
        INC H
        LD A,(HL)
        INC H
        LD A,(HL)
        INC H
        LD A,(HL)
        LD A,h'3F
        OUT (VOL1),A
        OUT (VOL2),A
        OUT (VOL3),A
        OUT (VOL4),A
        LD HL,CHNVOL
        LD DE,CHNVOL+1
        LD BC,h'0007
        LD (HL),h'BF
        LDIR
        LD A,HIGH (INTTAB)
        LD I,A
        LD HL,INT7
        LD DE,INTAREA
        LD BC,h'0017
        LDIR
        EX DE,HL
        LD (HL),h'C3
        INC L
        LD (HL),LOW (INT7)
        INC L
        LD (HL),HIGH (INT7)
        LD HL,QTMAP
        LD (QTFREE),HL
        LD (QTBUSY),HL
        LD DE,QTMAP+1
        LD BC,h'001F
        LD (HL),B
        LDIR
        LD HL,VOLTAB
        LD DE,VOLTAB+1
        LD BC,h'001F
        LD (HL),h'3F
        LDIR
        LD HL,VOLRQTB
        LD DE,VOLRQTB+1
        LD BC,h'0007
        LD (HL),h'3F
        LDIR
        LD A,h'0F
        LD (GSCHNS),A
        LD (MTCHNS),A
        LD A,h'40
        LD (MODVOL),A
        LD (FXMVOL),A
        LD (FXVOL),A
        LD A,%11000011
        LD (MTSTAT),A
        XOR A
        LD (MODUL),A
        LD A,(NUMPG)
        SRL A
        LD B,A
        LD HL,h'8000
        RR H
        LD A,B
        LD (RAMTOP),HL
        LD (RAMTOP+2),A
        LD (PTRC),HL
        LD (PTRC+2),A
        LD (PTRB),HL
        LD (PTRB+2),A
        LD (PTRA),HL
        LD (PTRA+2),A
        LD (PTR9),HL
        LD (PTR9+2),A
        LD (PTR8),HL
        LD (PTR8+2),A
        LD (PTR7),HL
        LD (PTR7+2),A
        LD (PTR6),HL
        LD (PTR6+2),A
        LD (PTR5),HL
        LD (PTR5+2),A
        LD (MEMTOP),HL
        LD (MEMTOP+2),A
        LD (PTR4),HL
        LD (PTR4+2),A
        LD IY,CHANSFX
        LD (CURCHAN),IY
        LD BC,h'0801
        LD DE,CHANLEN
INITV03 LD (IY+CHSTAT),h'40
        LD (IY+CHRDR),C
        LD (IY+CHRDRI),C
        LD A,h'08
        SUB B
        LD (IY+CHRDN),A
        AND h'02
        JR Z,INITV05
        SET 5,(IY+CHSTAT)
INITV05 LD (IY+CHFLAGS),h'00
        LD (IY+CHPORT),h'01
        LD (IY+CHVIBCM),h'11
        LD (IY+CHTRMCM),h'11
        LD (IY+CHOFFST),h'01
        LD (IY+CHWNT),h'7F
        LD (IY+CHOLDV),h'80
        LD (IY+CHEPAN),h'20
        LD (IY+CHEVOL),h'40
        RLC C
        ADD IY,DE
        DJNZ INITV03
        LD IY,CHANS
        LD B,h'08
INITV04 LD (IY+CHSTAT),h'00
        LD (IY+CHFLAGS),h'00
        LD (IY+CHPORT),h'01
        LD (IY+CHVIBCM),h'11
        LD (IY+CHTRMCM),h'11
        LD (IY+CHOFFST),h'01
        LD (IY+CHWNT),h'7F
        LD (IY+CHOLDV),h'80
        LD (IY+CHEPAN),h'20
        LD (IY+CHEVOL),h'40
        ADD IY,DE
        DJNZ INITV04
        LD IY,CHANS
        LD (IY+CHSTAT),h'00
        LD (IY+CHRDR),h'01
        LD (IY+CHRDRI),h'01
        LD (IY+CHRDN),h'00
        ADD IY,DE
        LD (IY+CHSTAT),h'20
        LD (IY+CHRDR),h'04
        LD (IY+CHRDRI),h'04
        LD (IY+CHRDN),h'02
        ADD IY,DE
        LD (IY+CHSTAT),h'20
        LD (IY+CHRDR),h'08
        LD (IY+CHRDRI),h'08
        LD (IY+CHRDN),h'03
        ADD IY,DE
        LD (IY+CHSTAT),h'00
        LD (IY+CHRDR),h'02
        LD (IY+CHRDRI),h'02
        LD (IY+CHRDN),h'01
        LD HL,750
        LD (TICKLEN),HL
        LD (TCKLEFT),HL
        LD (FXTICK),HL
        LD (FXTCLEN),HL
        LD IXH,h'80
        LD DE,h'0000
        IN A,(ZXDATRD)
        JP COMINT

; B - NUMBER OF CHANNELS

INITCHN LD HL,(h'EC60)
        LD (IY+CHPERL),L  ; C-4
        LD (IY+CHPERH),H
        LD HL,(h'E060)
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        LD (IY+CHNOTE),48
        LD (IY+CHFLAGS),h'00
        LD (IY+CHREAL),h'7F
        LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'00
        LD (IY+CHINS),h'00
        LD (IY+CHSMP),h'00
        LD (IY+CHCOM),h'00
        LD (IY+CHPARM),h'00
        LD (IY+CHVIBPS),h'00
        LD (IY+CHTRMPS),h'00
        LD (IY+CHPATPS),h'00
        LD (IY+CHLPCNT),h'00
        LD A,B
        LD BC,CHANLEN
        ADD IY,BC
        LD B,A
        DJNZ INITCHN
        RET

;INCLUDE "COM_H.a80"

HGET    IN A,(ZXSTAT)
        AND h'81
        JR Z,HGET
        IN A,(ZXDATRD)
        RET M
        JP COMINT

HSEND   IN A,(ZXSTAT)
        OR A
        RET P
        RRCA
        JP NC,HSEND
        JP COMINT

HTAIL   LD HL,HTAIL2
HTAIL2  IN A,(ZXSTAT)
        AND h'81
        JR Z,HTAIL2
        RRCA
        JR C,HTAIL3
        IN A,(ZXDATRD)
        JP (HL)
HTAIL3  IN A,(ZXCMD)
        CP h'E0
        JP NC,COMINT
        CP h'D0
        JP C,COMINT
        JR Z,HTAIL5
        CP h'D1
        JR Z,HTAIL6
        XOR A
HTAIL4  OUT (ZXDATWR),A
        IN A,(ZXDATRD)
HTAIL6  OUT (CLRCBIT),A
        JP (HL)
HTAIL5  LD A,(ERRCODE)
        JR HTAIL4

ERR30
ERR20
ERR10   LD A,h'10        ;NOT ENOUGH FREE SPACE
        JR ERR

ERR11   LD A,h'11        ;NOT ENOUGH FREE ENTRIES
        JR ERR

ERR     LD (ERRCODE),A
        JP COMINT

;Get total RAM
;Получить общий объем доступной памяти на GS. (В базовой версии это 112к)
COM20   LD DE,(RAMBOT)
        LD A,(RAMBOT+2)
        LD C,A
        LD HL,(RAMTOP)
        LD A,(RAMTOP+2)
        OR A
        SBC HL,DE
        SBC A,C
        LD C,A
        LD A,L
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        CALL HSEND
        LD A,H
        OUT (ZXDATWR),A
        CALL HSEND
        LD A,C
        OUT (ZXDATWR),A
        RET

;Get free RAM
;Получить общий об'ем свободной памяти на GS.
COM21   LD DE,(MEMBOT)
        LD A,(MEMBOT+2)
        LD C,A
        LD HL,(MEMTOP)
        LD A,(MEMTOP+2)
        OR A
        SBC HL,DE
        SBC A,C
        LD C,A
        LD A,L
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        XOR A
        LD (ERRCODE),A
        CALL HSEND
        LD A,H
        OUT (ZXDATWR),A
        CALL HSEND
        LD A,C
        OUT (ZXDATWR),A
        RET

;Get free RAM
;Получить общий об'ем свободной памяти на GS.
COM22   IN A,(ZXDATRD)
        LD E,A
        LD D,HIGH (RAMPG)
        LD A,(DE)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Get number of RAM Pages
;Получить число страниц на  GS.
COM23   LD A,(NUMPG)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Set Module Master Volume
;Установить громкость проигрывания модулей.
COM2A   LD A,(MODVOL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CP h'40
        JR C,COM2A_
        LD A,h'40
COM2A_  LD (MODVOL),A
        LD IY,CHANS
        LD B,h'08
        LD DE,CHANLEN
COM2A__ SET 0,(IY+CHSTAT)
        ADD IY,DE
        DJNZ COM2A__
        RET

;Set FX Master Volume
;Установить громкость проигрывания эффектов.
COM2B   LD A,(FXVOL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CP h'40
        JR C,COM2B_
        LD A,h'40
COM2B_  LD (FXVOL),A
        LD IY,CHANSFX
        LD B,h'08
        LD DE,CHANLEN
COM2B__ SET 0,(IY+CHSTAT)
        ADD IY,DE
        DJNZ COM2B__
        RET

COM2C   LD A,(CURMOD)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        OR A
        JR Z,COM2C_
        LD B,A
        LD A,(CNTMOD)
        CP B
        JR C,COM2C__
        LD A,B
        LD (CURMOD),A
        RET

COM2C_  LD A,(CNTMOD)
        LD (CURMOD),A
        RET

COM2C__ XOR A
        LD (CURMOD),A
        RET

COM2D   LD A,(CURSMP)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        OR A
        JR Z,COM2D_
        LD B,A
        LD A,(CNTSMP)
        CP B
        JR C,COM2D__
        LD A,B
        LD (CURSMP),A
        RET

COM2D_  LD A,(CNTSMP)
        LD (CURSMP),A
        RET

COM2D__ XOR A
        LD (CURSMP),A
        RET

;Set Current FX
;Установить текущий эффект. Просто присваивает переменной CURFX это зна-
;чение. Если какая-либо команда требует номер сэмпла (sample handle), то
;можно вместо этого номера подать ей h'00 и интерпретатор подставит вмес-
;то этого нуля значение переменной CURFX. (См. команды h'38, h'39, h'40-h'4F
;для понимания вышеизложенного.)
COM2E   LD A,(CURFX)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        OR A
        JR Z,COM2E_
        LD B,A
        LD A,(CNTFX)
        CP B
        JR C,COM2E__
        LD A,B
        LD (CURFX),A
        RET

COM2E_  LD A,(CNTFX)
        LD (CURFX),A
        RET

COM2E__ XOR A
        LD (CURFX),A
        RET

COM2F   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD E,A
        CALL HGET
        LD D,A
        OR E
        JR Z,COM2F_
        LD HL,(CNTTRK)
        SBC HL,DE
        JR C,COM2F__
        LD (CURTRK),DE
        RET

COM2F_  LD HL,(CNTTRK)
        LD (CURTRK),HL
        RET

COM2F__ LD HL,h'0000
        LD (CURTRK),HL
        RET

;Load Module
;Загрузка модуля в память.
COM30   LD A,(CNTMOD)
        OR A
        JP NZ,INITVAR
        INC A
	LD (CNTMOD),A
        LD (CURMOD),A
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD C,h'00
        CALL LOAD
LDMOD   LD A,h'00		;h'C3F8
        LD (CONVERT),A
;---patched
        CALL Patch5x
;---
        RET

;Jump to position (*)
;Делает переход на заданную позицию.
COM65   IN A,(ZXDATRD)
        LD C,A
        LD A,(CURMOD)
        LD B,A
        JP COM65_

;Play module
;Проигрывание модуля.
COM31   IN A,(ZXDATRD)
        OR A
        JR NZ,COM31_
        LD A,(CURMOD)
        OR A
        JP Z,COM31_1
COM31_  LD B,A
        LD A,(CNTMOD)
        CP B
        JP C,COM31_2
        LD A,B
        LD C,h'00
COM65_  OUT (ZXDATWR),A
        OUT (CLRCBIT),A
PLAYMOD	LD A,(BUSY)		;h'C426
        PUSH AF
        LD A,h'FF
        LD (BUSY),A
        LD A,B
        LD (MODUL),A
        LD (CURMOD),A
        LD A,%00000011
        LD (MTSTAT),A
        LD A,h'06
        LD (MTSPEED),A
        LD A,C
        LD (MTSNGPS),A
        XOR A
        LD (MTFLAGS),A
        LD (MTCOUNT),A
        LD (MTPATPS),A
        LD (MTPDT),A
        LD (MTPDT2),A
        LD (MTBRKFL),A
        LD (MTBRKPS),A
        LD (MTJMPFL),A
        INC A
        LD (MTTYPE),A
        LD A,h'40
        LD (MTVOL),A
        DEC A
        LD (MTROWS),A
        LD A,125
        CALL FXF
        LD IY,CHANS
        LD B,h'08
        LD DE,CHANLEN
COM31__ RES 7,(IY+CHSTAT)
        SET 0,(IY+CHSTAT)
        LD (IY+CHVOL),h'40
        LD (IY+CHMVOL),h'40
        ADD IY,DE
        DJNZ COM31__
        CALL INITPAT
        CALL EFXGTNT
        LD A,h'FF
        LD (PROCESS),A
        POP AF
        LD (BUSY),A
        RET

COM31_1
COM31_2 XOR A
        LD (CURMOD),A
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Stop module
;Остановить проигрывание модуля.
COM32   LD A,(MODUL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
STOPMOD	LD HL,MTSTAT		;h'C4AE
        SET 7,(HL)
        RET

;Continue module
;Продолжить проигрывание модуля после остановки.
COM33   LD A,(MODUL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
CONTMOD	LD A,(MODUL)		;h'C4BD
        OR A
        RET Z
        LD HL,MTSTAT
        BIT 6,(HL)
        RET NZ
        LD A,h'FF
        LD (PROCESS),A
        RES 7,(HL)
        LD (PROCESS),A
        RET

COM34   LD A,(MODFADE)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (MODFADE),A
        RET

;Set Module Volume
;Установить громкость проигрывания модулей.
COM35   LD A,(MTVOL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CP h'40
        JR C,COM35_
        LD A,h'40
COM35_  LD (MTVOL),A
        LD IY,CHANS
        LD B,h'08
        LD DE,CHANLEN
COM35__ SET 0,(IY+CHSTAT)
        ADD IY,DE
        DJNZ COM35__
        RET

;Data on (*)
;Устанавливает регистр данных в h'FF.
COM36   LD A,h'FF
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Reinitialisation (*)
;Переустанавливает внутренние переменные в исходное состояние.
COM37   OUT (CLRCBIT),A
        LD HL,MTSTAT
        SET 7,(HL)
        LD HL,h'0000
        XOR A
        LD (CURADR),HL
        LD (CURADR+2),A
        LD (MEMBOT),HL
        LD (MEMBOT+2),A
        LD (CURMOD),A
        LD (CNTMOD),A
        LD (MODUL),A
        RET

;Load FX (Extended version)
;Загрузка сэмпла эффекта в память. Позволяет загружать сэмплы со знаком.
COM3E   IN A,(ZXDATRD)
        CP h'01
        JR Z,COM38
        LD IXL,h'80
        OR A
        JR Z,COM38_
        XOR A
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        RET

;Load FX
;Загрузка сэмпла эффекта в память. Загружает беззнаковые сэмплы (PC type)
COM38   LD IXL,h'00
COM38_  LD A,(CNTFX)
        CP 60
        JP NC,COM38_9
        INC A
        OUT (ZXDATWR),A
        PUSH AF
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        POP AF
        LD (CNTFX),A
        LD (CURFX),A
        CALL GETFX
        PUSH HL
        POP IY
        LD E,L
        LD D,H
        INC DE
        LD BC,h'003F
        LD (HL),B
        LDIR
        LD HL,(CURADR)
        LD A,(CURADR+2)
        LD (IY+8),L
        LD (IY+9),H
        LD (IY+10),A
        LD C,IXL
        CALL LOAD
        LD A,(CURADR)
        SUB (IY+8)
        LD (IY+11),A
        LD (IY+17),A
        LD A,(CURADR+1)
        SBC A,(IY+9)
        LD (IY+12),A
        LD (IY+18),A
        LD A,(CURADR+2)
        SBC A,(IY+10)
        LD (IY+13),A
        LD (IY+19),A
        LD (IY+16),h'FF
        LD (IY+20),h'40
        LD (IY+23),h'80
        LD (IY+24),h'0F
        LD (IY+25),h'0F
        LD (IY+26),h'80
        LD (IY+27),h'FF
        LD (IY+28),h'FF
        LD (IY+31),60
        LD E,60
        CALL GETPER
        LD (IY+54),L
        LD (IY+55),H
        CALL GETFRQ
        LD (IY+56),L
        LD (IY+57),H
        RET

COM38_9 XOR A
        OUT (ZXDATWR),A
        LD (CURFX),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        RET

GETFX   DEC A
        CP h'20
        JR C,GETFX2
        SUB h'20
        LD H,h'00
        ADD A,A
        ADD A,A
        ADD A,A
        RL H
        ADD A,A
        RL H
        ADD A,A
        RL H
        ADD A,A
        RL H
        LD L,A
        LD A,H
        ADD A,HIGH (BUFFER)+1
        LD H,A
        PUSH HL
        POP IY
        RET

GETFX2  LD H,h'00
        ADD A,A
        ADD A,A
        ADD A,A
        RL H
        ADD A,A
        RL H
        ADD A,A
        RL H
        ADD A,A
        RL H
        LD L,A
        LD A,H
        ADD A,HIGH (SMPADR)
        LD H,A
        PUSH HL
        POP IY
        RET

;Play FX
;Проигрывание эффекта.
COM39   IN A,(ZXDATRD)
        OR A
        JR NZ,COM39_1
        LD A,(CURFX)
COM39_1 LD (CURFX),A
        LD B,A
        LD A,(CNTFX)
        CP B
        JP C,COM39_9
        XOR A
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        LD A,(CURFX)
        CALL GETFX
        LD A,(BUSY)
        PUSH AF
        LD A,h'FF
        LD (BUSY),A
        PUSH HL
        POP IY
        CALL PLAYFX
        POP AF
        LD (BUSY),A
        RET

COM39_9 LD A,h'FF
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

COM3B
COM3C   LD A,(FXFADE)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (FXFADE),A
        RET

;Set FX Volume
;Установить громкость проигрывания эффектов.
COM3D   LD A,(FXMVOL)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CP h'40
        JR C,COM3D_
        LD A,h'40
COM3D_  LD (FXMVOL),A
        LD IY,CHANSFX
        LD B,h'08
        LD DE,CHANLEN
COM3D__ SET 0,(IY+CHSTAT)
        ADD IY,DE
        DJNZ COM3D__
        RET

COM3F

;Set FX Sample Playing Note
;Установка ноты по умолчанию для текущего эффекта.
COM40   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD E,A
        LD A,(CURFX)
        OR A
        RET Z
        CALL GETFX
        LD A,E
        CP 96
        JR C,COM40_
        LD E,95
COM40_  LD (IY+31),E
        CALL GETPER
        LD (IY+54),L
        LD (IY+55),H
        CALL GETFRQ
        LD (IY+56),L
        LD (IY+57),H
        RET

;Set FX Sample Volume
;Установка громкости по умолчанию для текущего эффекта.
COM41   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD E,A
        LD A,(CURFX)
        OR A
        RET Z
        CALL GETFX
        LD A,E
        CP h'41
        JR C,COM41_
        LD E,h'40
COM41_  LD (IY+20),E
        RET

;Set FX Sample Finetune
;Установка Finetune по умолчанию для текущего эффекта.
COM42   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        LD A,(IY+21)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+21),A
        RET

;Set FX Sample Priority
;Установка приоритета для текущего эффекта. (См. команду h'39)
COM45   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        LD A,(IY+26)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+26),A
        RET

;Set FX Sample Seek First parameter
;Установка параметра Seek First для текущего эффекта. (См. команду h'39)
COM46   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        LD A,(IY+24)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+24),A
        RET

;Set FX Sample Seek Last parameter
;Установка параметра Seek Last для текущего эффекта. (См. команду h'39)
COM47   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        LD A,(IY+25)
        OUT (ZXDATWR),A
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+25),A
        RET

;Set FX Sample Loop Begin (*)
;Установка начала цикла для текущего эффекта.
COM48   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+14),A
        CALL HGET
        LD (IY+15),A
        CALL HGET
        LD (IY+16),A
        RET

;Set FX Sample Loop End (*)
;Установка конца цикла для текущего эффекта.
COM49   LD A,(CURFX)
        CALL GETFX
        PUSH HL
        POP IY
        IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (IY+17),A
        CALL HGET
        LD (IY+18),A
        CALL HGET
        LD (IY+19),A
        RET

COM58   LD B,h'00
        OUT (ZXDATWR),A
        JP COM50_

COM50   IN A,(ZXDATRD)
        LD B,A
COM50_  IN A,(ZXCMD)
        OUT (CLRCBIT),A
        AND h'07
        LD E,A
        CALL HGET
        LD L,A
        LD A,E
        CP h'04
        CALL NC,HGET
        LD H,A
        LD A,E
        CP h'07
        CALL Z,HGET
        LD D,A
        LD A,B
        OR A
        JR NZ,C50_00
        LD A,(LSTCHN)
        OR A
        JP Z,ERR20
C50_00  LD B,A
        LD C,h'01
        LD IY,CHANSFX
C50_01  LD A,B
        AND C
        JR NZ,C50_02
        RLC C
        LD A,IYL
        ADD A,LOW (CHANLEN)
        LD IYL,A
        LD A,IYH
        ADC A,h'00
        LD IYH,A
        JP C50_01

C50_02  LD A,E
        OR A
        JP Z,C50_80
        CP h'02
        JP Z,C50_A0
        CP h'04
        JP Z,C50_C0
        CP h'05
        JP Z,C50_D0
        CP h'06
        JP Z,C50_E0
        CP h'07
        JP Z,C50_F0
C50_LP
C50_80  SET 7,(IY+CHSTAT)
        LD A,L
        AND h'7F
        CP 96
        JP NC,C50_LP
C50_81  LD A,(IY+CHSMP)
        OR A
        JP Z,C50_LP
        PUSH DE
        PUSH BC
        PUSH HL
        LD E,L
        RES 7,E
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        CALL GETPER
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        BIT 7,(IY+CHSTAT)
        JR NZ,C50_82
        LD A,(IY+CHNOTE)
        CP E
        JR Z,C50_83
        LD (IY+CHNOTE),E
C50_82  LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'00
C50_83  POP HL
        PUSH HL
        BIT 7,(IY+CHSTAT)
        JR NZ,C50_84
        BIT 7,L
C50_84  POP HL
        POP BC
        POP DE
        JP C50_LP

C50_90  LD A,L
        CP h'40
        JR C,C50_91
        LD L,h'40
C50_91  LD (IY+CHVOL),A
        LD (IY+CHMVOL),A
        JP C50_LP

C50_A0  LD (IY+CHFINE),L
        JP C50_LP

C50_B0  LD (IY+CHPAN),L
        JP C50_LP

C50_C0  LD A,H
        OR A
        JR NZ,C50_C1
        OR L
        JR NZ,C50_C1
        LD L,h'01
C50_C1  LD A,H
        CP h'20
        JR C,C50_C2
        LD HL,h'1FFF
C50_C2  LD A,(IY+CHSTAT)
        SET 7,(IY+CHSTAT)
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'00
        LD (IY+CHSTAT),A
        JP C50_LP

C50_D0  LD A,H
        OR A
        JR NZ,C50_D1
        OR L
        JR NZ,C50_D1
        LD L,h'01
C50_D1  LD A,H
        CP h'80
        JR C,C50_D2
        LD HL,h'7FFF
C50_D2  LD A,(IY+CHSTAT)
        SET 7,(IY+CHSTAT)
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'00
        LD (IY+CHSTAT),A
        JP C50_LP

C50_E0
C50_F0

;Get Song Position
;Получение значения переменной Song_Position в текущем модуле.
COM60   LD A,(MTSNGPS)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Get Pattern Position
;Получение значения переменной Pattern_Position в текущем модуле.
COM61   LD A,(MTPATPS)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Get Mixed Position
;Получить значение Pattern_Position, немного смешанной с Song_Position.
COM62   LD A,(MTSNGPS)
        RRCA
        RRCA
        AND h'C0
        LD B,A
        LD A,(MTPATPS)
        AND h'3F
        OR B
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Get Channel Volumes
;Получить громкости всех каналов модуля.
COM64   LD HL,CHANS+CHMVOL
        JP COM64_

COM63   LD HL,CHANS+CHREAL
COM64_  LD DE,CHANLEN
        LD B,h'04
        LD A,(HL)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COM63__

;Get Channel Notes
;Получить ноты всех каналов модуля.
COM63_  LD A,(HL)
        OUT (ZXDATWR),A
COM63__ SET 7,(HL)
        CALL HSEND
        ADD HL,DE
        DJNZ COM63_
        RET

;Set speed/tempo (*)
;Установка скорости в пределах h'01-h'1F. При значениях h'20-h'FF устанавли-
;вается темп проигрывания. Значения темпа соответствуют оригинальным при
;скорости равной h'06.
COM66   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CALL FXF
        RET

;Get speed value (*)
;Чтение текущей скорости.
COM67   LD A,(MTSPEED)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Get tempo value (*)
;Чтение текущего темпа.
COM68   LD A,(MTBPM)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        RET

;Process Sound (*)
;Переход на следующий кварк (или тик) в процессе проигрывания звука.
COM69   LD A,h'FF
        LD (INGEN),A
        CALL ENGINE
        XOR A
        LD (INGEN),A
        OUT (CLRCBIT),A
        RET

;Stop FX in channels
;установка проигрывания эффектов в заданных каналах,  которые указывают-
;ся в маске каналов (Channel Mask).  В ней единица в n-ном  бите  указы-
;вает на то, что эффект в n-ном канале требуется остановить
COM3A   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD C,A
        CPL
        LD B,A
        LD A,(FXCHNS)
        AND B
        LD (FXCHNS),A
        LD IY,CHANSFX
        LD DE,CHANLEN
        SLA C
        JR NC,COM3A_2
COM3A_1 RES 7,(IY+CHSTAT)
COM3A_2 ADD IY,DE
        SLA C
        JR C,COM3A_1
        JP NZ,COM3A_2
        RET

;Direct Play FX Sample (h'80..h'83)
;Проигрывание сэмпла в заданном канале.
COM80   IN A,(ZXDATRD)
        OR A
        JR NZ,COM80_1
        LD A,(CURFX)
COM80_1 LD (CURFX),A
        LD C,A
        LD A,(CNTFX)
        CP C
        JP C,COM39_9
        IN A,(ZXCMD)
        OUT (CLRCBIT),A
        LD B,A
        BIT 3,B
        CALL NZ,HGET
        LD E,A
        BIT 4,B
        CALL NZ,HGET
        LD D,A
        LD A,C
        CALL GETFX
        PUSH DE
        PUSH BC
        CALL COM80_2
        POP  BC
        POP  DE
        PUSH HL
        POP  IY
        BIT 4,B
        JR Z,COM80_4
        LD (IY+CHVOL),D
        LD (IY+CHMVOL),D
COM80_4 BIT 3,B
        RET Z
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        CALL GETPER
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        RET

COM80_2 PUSH IY
        LD IY,CHANSFX
        LD DE,CHANLEN
        LD A,B
        AND h'07
COM80_3 JP Z,PLFX_12
        ADD IY,DE
        DEC A
        JP COM80_3

COMA0   IN A,(ZXDATRD)
        LD C,A
        IN A,(ZXCMD)
        OUT (CLRCBIT),A
        LD B,A
        LD IY,CHANSFX
        LD DE,CHANLEN
        AND h'07
COMA0_1 JR Z,COMA0_2
        ADD IY,DE
        DEC A
        JP NZ,COMA0_1
COMA0_2 BIT 3,B
        JR NZ,COMA0_3
        LD E,C
        CALL GETPER
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RET

COMA0_3 LD (IY+CHVOL),C
        LD (IY+CHMVOL),C
        SET 0,(IY+CHSTAT)
        RET

; INPUT : E=NOTE,IY=CHANNEL
; OUTPUT: HL=PERIOD OR FREQUENCY
; USED  : HL,D,BC,A

GETPER  LD HL,AMFRQTB   ; FOR AMIGA FREQUENCY
        JR GETFRQ_

GETFRQ  LD HL,GSFRQTB
GETFRQ_ LD A,(IY+CHFINE)
        RRA
        AND h'0F
        JR Z,GETFRQ2
        LD C,A
        ADD A,A
        ADD A,C
        ADD A,A
        ADD A,A
        ADD A,A
        LD B,0
        RL B
        ADD A,A
        RL B
        ADD A,A
        RL B
        LD C,A
        ADD HL,BC
        ADD HL,BC
GETFRQ2 LD D,0
        LD A,E
        CP 96
        JR C,GETFRQ3
        LD E,95
GETFRQ3 SLA E
        ADD HL,DE
        LD E,(HL)
        INC HL
        LD D,(HL)
        EX DE,HL
        LD E,A
        BIT 0,(IY+CHFINE)
        RET Z
        RET

PLAYFX  LD C,h'00
        LD A,(MTSTAT)
        OR A
        JP M,PLFX_03
        LD A,(MODUL)
        OR A
        JR Z,PLFX_03
        LD IY,CHANS
        LD DE,CHANLEN
        LD B,h'04
PLFX_00 BIT 7,(IY+CHSTAT)
        JR Z,PLFX_01
        LD A,(IY+CHMVOL)
        OR A
        JR Z,PLFX_01
        LD A,C
        OR (IY+CHRDR)
        LD C,A
PLFX_01 ADD IY,DE
        DJNZ  PLFX_00
PLFX_03 PUSH HL
        POP IY
        LD HL,GSCHNS
        LD A,(HL)
        OR A
        SCF
        RET Z
        LD A,(FXCHNS)
        OR C
        CPL
        AND (HL)
        LD C,A
        AND (IY+24)
        JR NZ,PLFX_10
        LD A,(IY+26)
        CP h'40
        JR NC,PLFX_04
        LD A,C
        AND (IY+25)
        JR NZ,PLFX_10
        JP PLFX_05

PLFX_04 LD A,(FXCHNS)
        CPL
        AND (HL)
        AND (IY+24)
        JR NZ,PLFX_10
        LD A,(FXCHNS)
        CPL
        AND (HL)
        AND (IY+25)
        JR NZ,PLFX_10
PLFX_05 LD A,(FXCHNS)
        LD B,A
        LD A,(GSCHNS)
        AND B
        LD B,A
        PUSH IY
        LD IY,CHANSFX
        LD L,A
        LD H,h'FF
        LD DE,CHANLEN
        SRL B
        JP C,PLFX_06
        JP NZ,PLFX_07
        JP PLFX_08

PLFX_06 LD A,(IY+CHPRIOR)
        CP H
        JR NC,PLFX_07
        LD H,A
        LD L,(IY+CHRDR)
PLFX_07 ADD IY,DE
        SRL B
        JP C,PLFX_06
        JP NZ,PLFX_07
PLFX_08 POP IY
        LD A,L
        OR A
        SCF
        RET Z
        LD A,H
        CP (IY+26)
        LD A,L
        JR C,PLFX_10
        SCF
        RET

PLFX_10 LD B,A
        PUSH IY
        LD IY,CHANSFX
        LD DE,CHANLEN
        SRL B
        JP C,PLFX_12
PLFX_11 ADD IY,DE
        SRL B
        JP NC,PLFX_11
PLFX_12 LD A,(FXCHNS)
        OR (IY+CHRDR)
        LD (FXCHNS),A
        EX (SP),IY
        LD E,(IY+8)
        LD D,(IY+9)
        LD A,(IY+10)
        DEFB h'CB,h'32;SLI D
        RLA
        RRC D
        EX (SP),IY
        LD (IY+CHCURP),A
        LD (IY+CHCURL),E
        LD (IY+CHCURH),D
        EX (SP),IY
        LD A,(IY+8)
        ADD A,(IY+11)
        LD E,A
        LD A,(IY+9)
        ADC A,(IY+12)
        LD D,A
        LD A,(IY+10)
        ADC A,(IY+13)
        DEFB h'CB,h'32;SLI D
        RLA
        RRC D
        EX (SP),IY
        LD (IY+CHENDP),A
        LD (IY+CHENDL),E
        LD (IY+CHENDH),D
        LD (IY+CHLPBP),h'FF
        EX (SP),IY
        LD A,(IY+16)
        INC A
        JR Z,PLFX_13
        LD A,(IY+8)
        ADD A,(IY+14)
        LD E,A
        LD A,(IY+9)
        ADC A,(IY+15)
        LD D,A
        LD A,(IY+10)
        ADC A,(IY+16)
        DEFB h'CB,h'32;SLI D
        RLA
        RRC D
        EX (SP),IY
        LD (IY+CHLPBP),A
        LD (IY+CHLPBL),E
        LD (IY+CHLPBH),D
        EX (SP),IY
        LD A,(IY+8)
        ADD A,(IY+17)
        LD E,A
        LD A,(IY+9)
        ADC A,(IY+18)
        LD D,A
        LD A,(IY+10)
        ADC A,(IY+19)
        DEFB h'CB,h'32;SLI D
        RLA
        RRC D
        EX (SP),IY
        LD (IY+CHLPEP),A
        LD (IY+CHLPEL),E
        LD (IY+CHLPEH),D
        EX (SP),IY
PLFX_13 LD E,(IY+20)
        LD D,(IY+21)
        LD B,(IY+31)
        LD C,(IY+23)
        LD L,(IY+22)
        LD H,(IY+6)
        EX (SP),IY
        LD (IY+CHVOL),E
        LD (IY+CHMVOL),E
        LD (IY+CHFINE),D
        LD (IY+CHNOTE),B
        LD (IY+CHPAN),C
        LD (IY+CHRLNT),L
        LD (IY+CHSQZ),H
        EX (SP),IY
        LD E,(IY+54)
        LD D,(IY+55)
        LD L,(IY+56)
        LD H,(IY+57)
        LD C,(IY+26)
        EX (SP),IY
        SRL D
        RR E
        SRL D
        RR E
        LD (IY+CHPERL),E
        LD (IY+CHPERH),D
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        LD (IY+CHPRIOR),C
        LD (IY+CHFADVH),h'FF
        LD (IY+CHFADVL),h'FF
        LD (IY+CHDELVH),h'FF
        LD (IY+CHDELVL),h'FF
        LD (IY+CHEPAN),h'20
        LD (IY+CHEVOL),h'40
        LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'00
        LD (IY+CHVOL),h'40
        LD (IY+CHPAN),h'80
        SET 7,(IY+CHSTAT)
        SET 0,(IY+CHSTAT)
        PUSH IY
        POP HL
        POP IY
        LD A,h'FF
        LD (PROCESS),A
        RET

;INCLUDE "MEM_H.a80"
;MEMORY MOVEMENT MODULE - HIGH PART

;PROCEDURE: MOVE MEMORY
;INPUT    : B ,HL  - SOURCE START LOGICAL ADRESS
;           C ,DE  - SOURCE END LOGICAL ADRESS
;           B',HL' - DESTINATION LOGICAL ADRESS
;OUTPUT   : C ,DE  = DEST-START
;USES     : TYPE 1 REGS,RAMPG,CPAGE,BUFFER,SYSTEM
;EFFECT   : MOVES MEMORY REGION {START,END-1} TO DEST
;           ALL ADRESSES IS LOGICAL

MOVMEM  XOR A
        LD (SYSTEM),A
        PUSH HL
        LD A,B
        EXX
        POP DE
        PUSH HL
        PUSH BC
        LD C,A
        OR A
        SBC HL,DE
        LD A,B
        SBC A,C
        EX DE,HL
        POP BC
        POP HL
        LD C,A
        OR E
        OR D
        RET Z
        EXX
        EX DE,HL
        SBC HL,DE
        LD A,C
        SBC A,B
        LD IXL,A
        OR L
        OR H
        EXX
        RET Z
        PUSH DE
        PUSH BC
        BIT 7,C
        LD A,B
        EXX
        JR NZ,MOVL
        CP C
        JP C,MOVH
        JR NZ,MOVL
        EXX
        LD A,H
        EXX
        CP D
        JP C,MOVH
        JR NZ,MOVL
        EXX
        LD A,L
        EXX
        CP E
        JP C,MOVH
MOVL    DEFB h'CB,h'32;SLI D
        RL B
        RRC D
        PUSH DE
        EXX
        EX DE,HL
        POP HL
        DEFB h'CB,h'32;SLI D
        RL B
        RRC D
        LD A,B
        LD BC,h'0000
        EXX
        LD C,A
ML1     EXX
        LD A,H
        CP D
        JR C,ML3
        JR NZ,ML2
        LD A,L
        CP E
        JR C,ML3
ML2     LD A,C
        SUB L
        LD C,A
        LD A,B
        SBC A,H
        JR ML4
ML3     LD A,C
        SUB E
        LD C,A
        LD A,B
        SBC A,D
ML4     LD B,A
        LD A,IXL
        OR A
        JR NZ,ML6
        LD A,B
        EXX
        CP H
        JR C,ML7
        JR NZ,ML5
        EXX
        LD A,C
        EXX
        CP L
        JR C,ML7
ML5     PUSH HL
        EXX
        POP BC
ML6     EXX
ML7     LD D,HIGH (RAMPG)
        LD A,B
        CP C
        JR NZ,ML9
        LD E,B
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        PUSH BC
ML8     LD A,C
        CALL MLDI
        JP PE,ML8
        JR MLD

ML9     EXX
        PUSH BC
MLA     PUSH BC
        PUSH DE
        EXX
        LD E,B
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        LD DE,BUFFER
        LD A,C
        CALL MLDI
        POP DE
        POP BC
        PUSH HL
        EXX
        LD E,C
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        LD HL,BUFFER
        LD A,C
        CALL MLDI
        POP HL
        JP PE,MLA
MLD     BIT 7,H
        JR NZ,MLB
        SET 7,H
        EXX
        INC B
        JP MLC

MLB     SET 7,D
        EXX
        INC C
MLC     POP DE
        OR A
        SBC HL,DE
        LD A,IXL
        SBC A,h'00
        LD IXL,A
        OR L
        OR H
        JP NZ,ML1
        POP BC
        POP DE
        RET

MOVH    LD A,L
        OR H
        JR NZ,MH0
        DEC IXL
MH0     DEC HL
        EX DE,HL
        ADD HL,DE
        LD A,B
        ADC A,IXL
        DEFB h'CB,h'34;SLI H
        RLA
        RRC H
        LD B,A
        PUSH HL
        PUSH DE
        INC DE
        LD A,E
        OR D
        LD A,IXL
        JR NZ,MHF
        INC IXL
MHF     EX DE,HL
        EXX
        POP DE
        ADD HL,DE
        ADC A,B
        DEFB h'CB,h'34;SLI H
        RLA
        RRC H
        EX DE,HL
        POP HL
        EXX
        LD C,A
MH1     EXX
        LD A,H
        CP D
        JR C,MH3
        JR NZ,MH2
        LD A,L
        CP E
        JR C,MH3
MH2     LD C,E
        LD B,D
        JR MH4

MH3     LD C,L
        LD B,H
MH4     RES 7,B
        INC BC
        LD A,IXL
        OR A
        JR NZ,MH6
        LD A,B
        EXX
        CP H
        JR C,MH7
        JR NZ,MH5
        EXX
        LD A,C
        EXX
        CP L
        JR C,MH7
MH5     PUSH HL
        EXX
        POP BC
MH6     EXX
MH7     LD D,HIGH (RAMPG)
        LD A,B
        CP C
        JR NZ,MH9
        LD E,B
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        PUSH BC
MH8     LD A,C
        CALL MLDD
        JP PE,MH8
        JR MHD

MH9     EXX
        PUSH BC
MHA     PUSH BC
        PUSH DE
        EXX
        LD E,B
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        LD DE,BUFFER+h'00FF
        LD A,C
        CALL MLDD
        POP DE
        POP BC
        PUSH HL
        EXX
        LD E,C
        LD A,(DE)
        LD (SDPAGE),A
        EXX
        LD HL,BUFFER+h'00FF
        LD A,C
        CALL MLDD
        POP HL
        JP PE,MHA
MHD     BIT 7,H
        JR NZ,MHB
        SET 7,H
        EXX
        DEC B
        JP MHC
MHB     SET 7,D
        EXX
        DEC C
MHC     POP DE
        OR A
        SBC HL,DE
        LD A,IXL
        SBC A,h'00
        LD IXL,A
        OR L
        OR H
        JP NZ,MH1
        POP BC
        POP DE
        RET

;PROCEDURE: LOAD MEMORY BLOCK
;INPUT    : A,HL  - SOURCE LOGICAL ADRESS
;           DE    - DESTINATION PHISICAL ADRESS (LOW RAM)
;           BC    - BLOCK LENGTH
;USES     : TYPE 2 REGS,RAMPG,CPAGE,SYSTEM
;EFFECT   : MOVES MEMORY BLOCK FROM HIGH MEMORY TO LOW
;               SWITCH TO PAGE 0

LDMEM   DEFB h'CB,h'34;SLI H
        RLA
        RRC H
LM1     LD IXL,A
        PUSH HL
        LD L,A
        LD H,HIGH (RAMPG)
        LD A,(HL)
        POP HL
        LD (SDPAGE),A
        ADD HL,BC
        JR NC,LM2
        JR NZ,LM4
LM2     SBC HL,BC
LM3     LD A,C
        CALL MLDI
        JP PE,LM3
        RET

LM4     XOR A
        SBC HL,BC
LM5     LD A,L
        NEG
        CALL MLDI
        BIT 7,H
        JP NZ,LM5
        SET 7,H
        LD A,IXL
        INC A
        JP  LM1

;PROCEDURE: SAVE MEMORY BLOCK
;INPUT    : A,DE  - DESTINATION LOGICAL ADRESS
;           HL    - SOURCE PHISICAL ADRESS (LOW RAM)
;           BC    - BLOCK LENGTH
;USES     : TYPE 2 REGS,RAMPG,CPAGE,SYSTEM
;EFFECT   : MOVES MEMORY BLOCK FROM LOW MEMORY TO HIGH
;               SWITCH TO PAGE 0

SVMEM   DEFB h'CB,h'32;SLI D
        RLA
        RRC D
SM1     LD IXL,A
        PUSH HL
        LD L,A
        LD H,HIGH (RAMPG)
        LD A,(HL)
        POP HL
        LD (SDPAGE),A
        EX DE,HL
        ADD HL,BC
        JR NC,SM2
        JR NZ,SM4
SM2     SBC HL,BC
        EX DE,HL
SM3     LD A,C
        CALL MLDI
        JP PE,SM3
        RET

SM4     XOR A
        SBC HL,BC
        EX DE,HL
SM5     LD A,E
        NEG
        CALL MLDI
        BIT 7,D
        JP NZ,SM5
        SET 7,D
        LD A,IXL
        INC A
        JP  SM1

;INCLUDE "ENGINE_L.a80"
ENGINE  LD HL,(QTFREE)
        LD H,HIGH (QTMAP)
        LD A,L
        AND h'1C
        LD L,A
        LD (QTFREE),HL
        LD A,(HL)
        OR A
        JP NZ,ENG_FUL
        LD A,(CHANSFX+h'000)
        RLCA
        RR C
        LD A,(CHANSFX+h'040)
        RLCA
        RR C
        LD A,(CHANSFX+h'080)
        RLCA
        RR C
        LD A,(CHANSFX+h'0C0)
        RLCA
        RR C
        LD A,(CHANSFX+h'100)
        RLCA
        RR C
        LD A,(CHANSFX+h'140)
        RLCA
        RR C
        LD A,(CHANSFX+h'180)
        RLCA
        RR C
        LD A,(CHANSFX+h'1C0)
        RLCA
        RR C
        LD A,(GSCHNS)
        AND C
        LD C,A
        LD (FXCHNS),A
        JR NZ,ENG_01
        LD A,(MTSTAT)
        BIT 6,A
        RET NZ
        OR A
        JP M,ENG_00
        LD A,(MODUL)
        OR A
        JR NZ,ENG_01
ENG_00  XOR A
        LD (PROCESS),A
        RET

ENG_01  LD A,(MODSWCH)
        OR A
        JR NZ,ENG_03
        LD A,(MODUL)
        OR A
        JR Z,ENG_03
        LD A,h'01
        LD (SGENOFF),A
        LD A,(TCKLEFT+1)
        CP h'02
        JR NC,ENG_05
        OR A
        LD A,(TCKLEFT)
        JR Z,ENG_04
        SUB h'80
        JR NC,ENG_05
        JP ENG_04

ENG_03  LD A,h'01
        LD (SGENOFF),A
        LD A,(FXTICK+1)
        CP h'02
        JR NC,ENG_05
        OR A
        LD A,(FXTICK)
        JR Z,ENG_04
        SUB h'80
        JR NC,ENG_05
ENG_04  NEG
        LD (SGENOFF),A
ENG_05  XOR A
        LD (CHANNEL),A
        OR C
        JR Z,ENG_07
        LD IY,CHANSFX
        SRL C
ENG_06  PUSH BC
        CALL C,GEN
        LD BC,CHANLEN
        ADD IY,BC
        POP BC
        SRL C
        JR C,ENG_06
        JR NZ,ENG_06

ENG_07  CALL QUANTUM
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        RET

ENG_80  LD A,(SGENOFF)
        LD E,A
        LD D,h'00
        LD HL,(FXTICK)
        OR A
        SBC HL,DE
        JR Z,ENG_81
        JR C,ENG_81
        LD (FXTICK),HL
        JP ENG_82

ENG_81
ENG_82  LD A,(MODSWCH)
        OR A
        JR NZ,$
        LD A,(MODUL)
        OR A
        JR Z,$
        LD HL,(TCKLEFT)
        SBC HL,DE
        LD (TCKLEFT),HL
        JR NZ,ENG_83
ENG_83
ENG_FUL LD A,(PLAYING)
        OR A
        RET NZ
        DI
        XOR A
        LD (FILLALL),A
        CALL QTPLAY
        RET

;INCLUDE "FX_H.a80"

FXCHK_  LD HL,FXJP2
        JP FXCHK__

FXCHK   LD HL,FXJP1
FXCHK__ LD A,(IY+CHCOM)
        AND h'1F
        ADD A,A
        ADD A,L
        LD L,A
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        LD A,(IY+CHPARM)
        JP (HL)

FXE_    LD HL,FXEJP2
        JP FXE__

FXE     LD HL,FXEJP1
FXE__   RRCA
        RRCA
        RRCA
        RRCA
        AND h'0F
        ADD A,A
        ADD A,L
        LD L,A
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        LD A,(IY+CHPARM)
        AND h'0F
        JP (HL)

FXRET   RET

FXNOP   LD L,(IY+CHPERL)
        LD H,(IY+CHPERH)
EFXNOP2 CALL EFXCNV
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RET

;---patched
EFXCNV  LD A,H
        CP h'04
        JR NC,EFXCNV1
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        ADD HL,HL
        LD A,H
        ADD A,h'F8
        LD H,A
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        RET

EFXCNV1 PUSH HL
        LD E,L
        LD D,H
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE
        XOR A	;HL A
        LD C,A	;DE C
        SRL D		;/2
        RR E
        RR C
        ADD A,C
        ADC HL,DE		;+/2
        SRL D		;/4
        RR E
        RR C
        SRL D		;/8
        RR E
        RR C
        ADD A,C
        ADC HL,DE		;+/8
        SRL D		;/16
        RR E
        RR C
        SRL D		;/32
        RR E
        RR C
        SRL D		;/64
        RR E
        RR C
        SRL D		;/128
        RR E
        RR C
        SRL D		;/256
        RR E
        RR C
        ADD A,C
        ADC HL,DE		;+/256
        SRL E		;/512
        RR C
        ADD A,C
        ADC HL,DE		;+/512
        SRL E		;/1024
        RR C
        ADD A,C
        ADC HL,DE		;+/1024
        SRL E		;/2048
        RR C
        SRL E		;/4096
        RR C
        ADD A,C
        ADC HL,DE		;+/4096
        SRL H
        RR L
        SRL H
        RR L
        SRL H
        RR L
        JR NC,EFXCNV2
        INC HL
EFXCNV2 POP DE
        ADD HL,DE
        ADD HL,DE
        RET

	INC A
	RR L
	JR NC,TUT00
	INC HL
TUT00	POP DE
	ADD HL,DE
	ADD HL,DE
	RET

ARPTAB  DEFB 0,1,2,0,1,2,0,1,2,0
	DEFB 1,2,0,1,2,0,1,2,0,1,2
        DEFB 0,1,2,0,1,2,0,1,2,0
        DEFB 1,2,0,1,2,0,1,2,0,1,2

FX0     OR A
        JP Z,FXNOP
        LD B,A
        LD A,(MTCOUNT)
        LD HL,ARPTAB
        ADD A,L
        LD L,A
        LD A,H
        ADC A,h'00
        LD H,A
        LD A,(HL)
        OR A
        JP Z,FXNOP
        PUSH AF
        PUSH BC
        CALL NOTEFND
        POP BC
        POP AF
        DEC A
        LD A,B
        JR NZ,FX0_2
        RRCA
        RRCA
        RRCA
        RRCA
FX0_2   AND h'0F
        ADD A,E
        LD E,A
        CP 96
        RET NC
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RET

FX1     LD E,A
        LD D,h'00
        LD L,(IY+CHPERL)
        LD H,(IY+CHPERH)
        OR A
        SBC HL,DE
        JR NC,FX1_2
        LD HL,h'0000
FX1_2   PUSH HL
        LD HL,113
FX1_8   POP DE
        OR A
        SBC HL,DE
        JR C,FX1_9
        ADD HL,DE
        EX DE,HL
FX1_9   SET 7,(IY+CHFLAGS)
        LD (IY+CHPERL),E
        LD (IY+CHPERH),D
        PUSH DE
        EX DE,HL
        CALL EFXCNV
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        POP DE
        CALL NOTEFND
        LD (IY+CHREAL),A
        RET NC
        LD (IY+CHNOTE),A
        RES 7,(IY+CHFLAGS)
        RET

FX2     LD E,A
        LD D,h'00
        LD L,(IY+CHPERL)
        LD H,(IY+CHPERH)
        ADD HL,DE
        JR NC,FX2_2
        LD HL,h'FFFF
FX2_2   PUSH HL
        LD HL,856
FX2_8   POP DE
        OR A
        SBC HL,DE
        JR NC,FX2_9
        ADD HL,DE
        EX DE,HL
FX2_9   SET 7,(IY+CHFLAGS)
        LD (IY+CHPERL),E
        LD (IY+CHPERH),D
        PUSH DE
        EX DE,HL
        CALL EFXCNV
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        POP DE
        CALL NOTEFND
        LD (IY+CHREAL),A
        RET NC
        LD (IY+CHNOTE),A
        RES 7,(IY+CHFLAGS)
        RET

FX3     OR A
        JR Z,FX3_1
        LD (IY+CHPORT),A
FX3_1   LD A,(IY+CHWNT)
        CP 96
        RET NC
        LD E,A
        CALL GETPER
        EX DE,HL
        LD L,(IY+CHPERL)
        LD H,(IY+CHPERH)
        OR A
        SBC HL,DE
        JR Z,FX3_9
        ADD HL,DE
        LD C,(IY+CHPORT)
        LD B,h'00
        JR C,FX3_5
        SBC HL,BC
        JR C,FX3_9
        SBC HL,DE
        JR C,FX3_9
FX3_2   ADD HL,DE
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        BIT 2,(IY+CHFLAGS)
        CALL Z,EFXCNV
        BIT 2,(IY+CHFLAGS)
        JR Z,FX3_3
        EX DE,HL
        CALL NOTEFND
        LD E,A
        CALL GETFRQ
FX3_3   LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RET

FX3_5   ADD HL,BC
        JR C,FX3_9
        SBC HL,DE
        JR C,FX3_2
FX3_9   LD E,(IY+CHWNT)
        LD (IY+CHNOTE),E
        LD (IY+CHREAL),E
        CALL GETPER
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RES 7,(IY+CHFLAGS)
        LD (IY+CHCOM),h'00
        LD (IY+CHPARM),h'00
        LD (IY+CHWNT),h'7F
        RET

FX3_    RET

FX4     PUSH DE
        PUSH BC
        OR A
        JR Z,FX4_3
        LD L,A
        LD H,(IY+CHVIBCM)
        AND h'0F
        JR Z,FX4_1
        XOR H
        AND h'0F
        XOR H
        LD H,A
FX4_1   LD A,L
        AND h'F0
        JR Z,FX4_2
        XOR H
        AND h'F0
        XOR H
        LD H,A
FX4_2   LD (IY+CHVIBCM),H
FX4_3   LD D,(IY+CHVIBPS)
        LD A,D
        AND h'03
        JR Z,FX4_5
        CP h'03
        JR NZ,FX4_A
        LD A,R
        AND h'03
        JR Z,FX4_5
        CP h'03
        JR Z,FX4_5
FX4_A   DEC A
        JR Z,FX4_4
        LD E,h'FF
        JP FX4_6

FX4_4   LD A,D
        AND h'7C
        RLCA
        LD E,A
        BIT 7,D
        JR NZ,FX4_6
        LD A,h'F8
        SUB E
        LD E,A
        JP FX4_6

FX4_5   LD A,D
        RRCA
        RRCA
        AND h'1F
        LD HL,VIBTB
        ADD A,L
        LD L,A
        LD E,(HL)
FX4_6   LD A,(IY+CHVIBCM)
        AND h'0F
        JR Z,FX4_9
        LD B,A
        LD HL,h'0000
        LD D,H
FX4_7   ADD HL,DE
        DJNZ FX4_7
        LD B,h'07
        LD A,L
FX4_8   SRL H
        RRA
        DJNZ FX4_8
        ADC A,D
        LD L,A
        LD H,h'00
        BIT 7,(IY+CHVIBPS)
        JR Z,FX4_9
        DEC H
        CPL
        LD L,A
        INC HL
FX4_9   LD E,(IY+CHPERL)
        LD D,(IY+CHPERH)
        ADD HL,DE
        CALL EFXNOP2
        LD A,(IY+CHVIBCM)
        AND h'F0
        RRCA
        RRCA
        ADD A,(IY+CHVIBPS)
        LD (IY+CHVIBPS),A
        POP BC
        POP DE
        RET

FX5     CALL FXA
        JP FX3_1

FX6     CALL FXA
        PUSH DE
        PUSH BC
        JP FX4_3

FX7     PUSH DE
        PUSH BC
        OR A
        JR Z,FX7_3
        LD L,A
        LD H,(IY+CHTRMCM)
        AND h'0F
        JR Z,FX7_1
        XOR H
        AND h'0F
        XOR H
        LD H,A
FX7_1   LD A,L
        AND h'F0
        JR Z,FX7_2
        XOR H
        AND h'F0
        XOR H
        LD H,A
FX7_2   LD (IY+CHTRMCM),H
FX7_3   LD D,(IY+CHTRMPS)
        LD A,D
        AND h'03
        JR Z,FX7_5
        CP h'03
        JR NZ,FX7_A
        LD A,R
        AND h'03
        JR Z,FX7_5
        CP h'03
        JR Z,FX7_5
FX7_A   DEC A
        JR Z,FX7_4
        LD E,h'FF
        JP FX7_6

FX7_4   LD A,D
        AND h'7C
        RLCA
        LD E,A
        BIT 7,D
        JR NZ,FX7_6
        LD A,h'F8
        SUB E
        LD E,A
        JP FX7_6

FX7_5   LD A,D
        RRCA
        RRCA
        AND h'1F
        LD HL,VIBTB
        ADD A,L
        LD L,A
        LD E,(HL)
FX7_6   LD A,(IY+CHTRMCM)
        AND h'0F
        JR Z,FX7_9
        LD B,A
        LD HL,h'0000
        LD D,H
FX7_7   ADD HL,DE
        DJNZ FX7_7
        LD B,h'06
        LD A,L
FX7_8   SRL H
        RRA
        DJNZ FX7_8
        ADC A,D
        BIT 7,(IY+CHTRMPS)
        JR Z,FX7_9
        LD L,A
        LD A,(IY+CHVOL)
        SUB L
        JR NC,FX7_B
        XOR A
        JP FX7_B

FX7_9   ADD A,(IY+CHVOL)
        CP h'40
        JR C,FX7_B
        LD A,h'40
FX7_B   CP (IY+CHMVOL)
        LD (IY+CHMVOL),A
        JR Z,FX7_C
        SET 0,(IY+CHSTAT)
FX7_C   LD A,(IY+CHTRMCM)
        AND h'F0
        RRCA
        RRCA
        ADD A,(IY+CHTRMPS)
        LD (IY+CHTRMPS),A
        POP BC
        POP DE
        RET

FX9     OR A
        RET

        JR Z,FX9_1
        LD (IY+CHOFFST),A
FX9_1   LD H,(IY+CHOFFST)
        LD L,h'00
FXA     OR A
        RET Z
        LD L,A
        LD A,(IY+CHVOL)
        LD H,A
        LD A,L
        AND h'F0
        JR Z,FXA_1
        RRCA
        RRCA
        RRCA
        RRCA
        ADD A,H
        CP h'40
        JR C,FXA_2
        LD A,h'40
        JP FXA_2

FXA_1   LD A,H
        SUB L
        JR NC,FXA_2
        LD A,h'00
        LD (IY+CHCOM),A
        LD (IY+CHPARM),A
FXA_2   LD (IY+CHVOL),A
        CP (IY+CHMVOL)
        LD (IY+CHMVOL),A
        RET Z
        SET 0,(IY+CHSTAT)
        RET

FXB     DEC A
        LD (MTSNGPS),A
        ;CALL CP_END_MOD
        XOR A
        LD (MTBRKPS),A
        INC A
        LD (MTJMPFL),A
        RET

FXC     CP h'40
        JR C,FXC_1
        LD A,h'40
FXC_1   LD (IY+CHVOL),A
        CP (IY+CHMVOL)
        LD (IY+CHMVOL),A
        RET Z
        SET 0,(IY+CHSTAT)
        RET

FXD     LD L,A
        AND h'F0
        RRCA
        LD H,A
        RRCA
        RRCA
        ADD A,H
        LD H,A
        LD A,L
        AND h'0F
        ADD A,H
        CP h'40
        JR C,FXD_1
        XOR A
FXD_1   LD (MTBRKPS),A
        LD A,h'01
        LD (MTJMPFL),A
        RET

FXF     OR A
        JR Z,FXF_5
        CP h'20
        JR NC,FXF_1
FXF_0   LD (MTSPEED),A
        RET

FXF_1   LD (MTBPM),A
        SUB h'20
        LD HL,BPMTAB
        ADD A,A
        JR NC,FXF_3
        INC H
FXF_3   ADD A,L
        LD L,A
        JR NC,FXF_4
        INC H
FXF_4   LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD (TICKLEN),HL
        LD (TCKLEFT),HL
        RET

FXF_5
;LD HL,MTSTAT
;---patched
        JP Patch2x
;---
        SET 7,(HL)
        RET

FXE0    AND h'01
        LD (MTFILTR),A
        RET

FXE3    RES 2,(IY+CHFLAGS)
        OR A
        RET Z
        SET 2,(IY+CHFLAGS)
        RET

FXE4    RES 1,(IY+CHFLAGS)
        BIT 2,A
        JR Z,FXE4_2
        SET 1,(IY+CHFLAGS)
FXE4_2  AND h'03
        LD L,A
        LD A,(IY+CHVIBPS)
        AND h'FC
        OR L
        LD (IY+CHVIBPS),A
        RET

FXE5    ADD A,A
        LD (IY+CHFINE),A
        RET

FXE6    OR A
        JR Z,FXE6_3
        INC (IY+CHLPCNT)
        DEC (IY+CHLPCNT)
        JR Z,FXE6_2
        DEC (IY+CHLPCNT)
        RET Z
FXE6_1  LD A,(IY+CHPATPS)
        LD (MTBRKPS),A
        LD A,h'01
        LD (MTBRKFL),A
        RET

FXE6_2  LD (IY+CHLPCNT),A
        JP FXE6_1

FXE6_3  LD A,(MTPATPS)
        LD (IY+CHPATPS),A
        RET

FXE7    RES 0,(IY+CHFLAGS)
        BIT 2,A
        JR Z,FXE7_2
        SET 0,(IY+CHFLAGS)
FXE7_2  AND h'03
        LD L,A
        LD A,(IY+CHTRMPS)
        AND h'FC
        OR L
        LD (IY+CHTRMPS),A
        RET

FXE9    OR A
        RET Z
        LD L,A
        LD A,(MTCOUNT)
FXE9_1  SUB L
        JR NC,FXE9_1
        ADD A,L
        RET NZ
        CALL GETSMP
        RET

FXEA    RLCA
        RLCA
        RLCA
        RLCA
        JP FXA

FXEC    LD HL,MTCOUNT
        CP (HL)
        RET NZ
        XOR A
        LD (IY+CHVOL),A
        CP (IY+CHMVOL)
        LD (IY+CHMVOL),A
        RET Z
        SET 0,(IY+CHSTAT)
        RET

FXED    LD HL,MTCOUNT
        CP (HL)
        RET NZ
        CALL GETSMP
        RET

FXEE    LD HL,MTPDT2
        INC (HL)
        DEC (HL)
        RET NZ
        INC A
        LD (MTPDT),A
        RET

;INCLUDE "VOL_H.a80"

;VOLUME CALCULATION FOR MODULES AND FX

CALCVOL RES 0,(IY+CHSTAT)
        LD DE,h'FC00
        LD A,(IY+CHMVOL)
        AND h'7F
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        LD A,(IY+CHEVOL)
        OR A
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        LD A,(IY+CHFADVH)
        SRL A
        SRL A
        ADC A,h'00
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        BIT 6,(IY+CHSTAT)
        JP Z,CALCV_N
        LD A,(FXVOL)
        OR A
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        LD A,(FXMVOL)
        OR A
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        JP CALCV_X

CALCV_N LD A,(MTVOL)
        OR A
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
        LD A,(MODVOL)
        OR A
        JP Z,CALCV_Z
        CP h'40
        CALL C,MUL64
CALCV_X LD C,(IY+CHPAN)
        LD A,(IY+CHEPAN)
        SUB h'20
        JR Z,CALCV_V
        JR NC,CALCV_I
        NEG
CALCV_I CP h'20
        JR C,CALCV_U
        LD H,(IY+CHPAN)
        LD A,H
        OR A
        JP P,CALCV_Q
        NEG
        LD H,A
        JP CALCV_Q

CALCV_U RLCA
        RLCA
        RLCA
        LD L,A
        LD A,(IY+CHPAN)
        OR A
        JP P,CALCV_T
        NEG
CALCV_T LD B,A
        XOR A
        JP CALCV_M

CALCV_R ADD A,B
CALCV_E SRL B
CALCV_M SLA L
        JR C,CALCV_R
        JR NZ,CALCV_E
        SRL A
        LD H,A
CALCV_Q LD A,(IY+CHEPAN)
        CP h'20
        JR C,CALCV_P
        LD A,C
        ADD A,H
        LD C,A
        JR NC,CALCV_V
        LD C,h'FF
        JP CALCV_W
CALCV_P LD A,C
        SUB H
        LD C,h'00
        JR C,CALCV_O
        LD C,A
CALCV_V LD A,C
        CP h'80
        JR Z,CALCV_Y
        OR A
        JP M,CALCV_W
CALCV_O BIT 5,(IY+CHSTAT)
        JR Z,CALCV_Y
        SRL A
        CALL MUL64
        JP CALCV_Y

CALCV_W BIT 5,(IY+CHSTAT)
        JR NZ,CALCV_Y
        NEG
        SRL A
        CALL MUL64
CALCV_Y LD A,D
        SRL A
        SRL A
        ADC A,h'00
CALCV_Z LD C,A
        LD HL,VOLRQTB
        LD A,L
        ADD A,(IY+CHRDN)
        LD L,A
        LD (HL),C
        RET

MUL64   LD B,A
        LD HL,h'0000
        AND h'0F
        JR Z,MUL64_F
        SLA B
        SLA B
        JP MUL64_E

MUL64_A ADD HL,DE
MUL64_E SRL D
        RR E
        SLA B
        JP C,MUL64_A
        JP NZ,MUL64_E
        EX DE,HL
        RET

MUL64_F LD A,B
        OR A
        JR Z,MUL64_S
        SRL D
        RR E
        CP h'20
        RET Z
        LD L,E
        LD H,D
        SRL D
        RR E
        CP h'10
        RET Z
        ADD HL,DE
MUL64_S EX DE,HL
        RET

;INCLUDE "TEST_H.a80"

TCOM    IN A,(ZXSTAT)
        RRCA
        JR NC,TCOM
TCOM_   IN A,(ZXCMD)
        CP h'20
        JP NC,COMINT2
        CP h'01
        JR Z,TCOM
        OUT (CLRCBIT),A
        LD HL,TCOMTB
        ADD A,A
        ADD A,L
        LD L,A
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        JP (HL)

TCOM2   LD HL,DAC0
        LD A,h'3F
        OUT (VOL1),A
TCOMDAC LD (HL),0
        LD A,(HL)
        LD IY,TCONT1
        JP TWAIT

TCONT1  LD (HL),h'FF
        LD A,(HL)
        LD IY,TCOMDAC
        JP TWAIT

TCOM3   LD HL,DAC1
        LD A,h'3F
        OUT (VOL2),A
        JR TCOMDAC

TCOM4   LD HL,DAC2
        LD A,h'3F
        OUT (VOL3),A
        JR TCOMDAC

TCOM5   LD HL,DAC3
        LD A,h'3F
        OUT (VOL4),A
        JR TCOMDAC

TCOM6   XOR A
        OUT (ZXDATWR),A
        LD IY,TCONT2
        JP TWAIT

TCONT2  LD A,h'FF
        OUT (ZXDATWR),A
        LD IY,TCOM6
        JP TWAIT

TCOM7   LD C,VOL1
        LD HL,DAC0
        LD (HL),h'FF
        LD A,(HL)
TCOMVOL LD A,h'00
        OUT (C),A
        LD IY,TCONT3
        JP TWAIT

TCONT3  LD A,h'FF
        OUT (C),A
        LD IY,TCOMVOL
        JP TWAIT

TCOM8   LD C,VOL2
        LD HL,DAC1
        LD (HL),h'FF
        LD A,(HL)
        JR TCOMVOL

TCOM9   LD C,VOL3
        LD HL,DAC2
        LD (HL),h'FF
        LD A,(HL)
        JR TCOMVOL

TCOMA   LD C,VOL4
        LD HL,DAC3
        LD (HL),h'FF
        LD A,(HL)
        JR TCOMVOL

TCOMB   LD HL,DAC0
        LD C,VOL1
TCOMTST LD B,h'3F
TCOMT4  OUT (C),B
        LD D,114
TCOMT5  LD (HL),h'00
        LD A,(HL)
        XOR A
TCOMT6  DEC A
        JR NZ,TCOMT6
        LD (HL),h'FF
        LD A,(HL)
        XOR A
TCOMT7  DEC A
        JR NZ,TCOMT7
        DEC D
        JR NZ,TCOMT5
        DEC B
        JP P,TCOMT4
        IN A,(ZXSTAT)
        RRCA
        JR NC,TCOMTST
        JP TCOM_

TCOMC   LD HL,DAC1
        LD C,VOL2
        JP TCOMTST

TCOMD   LD HL,DAC2
        LD C,VOL3
        JP TCOMTST

TCOME   LD HL,DAC3
        LD C,VOL4
        JP TCOMTST

TCOMF   LD A,h'3F
        OUT (VOL1),A
        OUT (VOL2),A
        OUT (VOL3),A
        OUT (VOL4),A
        LD B,h'00
        LD L,B
TCONT8  LD H,HIGH (DAC0)
        LD (HL),B
        LD A,(HL)
        INC H
        LD (HL),B
        LD A,(HL)
        INC H
        LD (HL),B
        LD A,(HL)
        INC H
        LD (HL),B
        LD A,(HL)
        DJNZ TCONT8
        IN A,(ZXSTAT)
        RRCA
        JP NC,TCONT8
        JP TCOM_

TCOM10  IN A,(ZXDATRD)
        OUT (ZXDATWR),A
        JP TCOM_

TCOM11  IN A,(ZXDATRD)
        JP TCOM_

TCOM12  LD HL,DAC0
TCONT9  LD A,h'3F
        OUT (VOL1),A
        OUT (VOL2),A
        OUT (VOL3),A
        OUT (VOL4),A
TCONTA  IN A,(ZXDATRD)
        LD (HL),A
        LD A,(HL)
TCONTB  DJNZ TCONTB
        LD (HL),h'00
        LD A,(HL)
TCONTC  DJNZ TCONTC
        IN A,(ZXSTAT)
        RRCA
        JP C,TCOM_
        JP TCONTA

TCOM13  LD HL,DAC1
        JR TCONT9

TCOM14  LD HL,DAC2
        JR TCONT9

TCOM15  LD HL,DAC3
        JR TCONT9

TWAIT   LD B,h'04
TWAIT1  LD DE,38686
TWAIT2  IN A,(ZXSTAT)
        RRCA
        JP C,TCOM_
        DEC DE
        LD A,D
        OR E
        JR NZ,TWAIT2
        DJNZ TWAIT2
        JP (IY)

;INCLUDE "TABLES_H.a80"

        org ($ & h'FF00) + h'100

VIBTB	DEFB h'00,h'18,h'31,h'4A,h'61,h'78,h'8D,h'A1
	DEFB h'B4,h'C5,h'D4,h'E0,h'EB,h'F4,h'FA,h'FD
	DEFB h'FF,h'FD,h'FA,h'F4,h'EB,h'E0,h'D4,h'C5
	DEFB h'B4,h'A1,h'8D,h'78,h'61,h'4A,h'31,h'18

COMTABH DEFB LOW (COM20),LOW (COM21),LOW (COM22),LOW (COM23),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'20
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COM2A),LOW (COM2B),LOW (COM2C),LOW (COM2D),LOW (COM2E),LOW (COM2F)  ;h'28
        DEFB LOW (COM30),LOW (COM31),LOW (COM32),LOW (COM33),LOW (COM34),LOW (COM35),LOW (COM36),LOW (COM37)  ;h'30
        DEFB LOW (COM38),LOW (COM39),LOW (COM3A),LOW (COM3B),LOW (COM3C),LOW (COM3D),LOW (COM3E),LOW (COM3F)  ;h'38
        DEFB LOW (COM40),LOW (COM41),LOW (COM42),LOW (COMHZ),LOW (COMHZ),LOW (COM45),LOW (COM46),LOW (COM47)  ;h'40
        DEFB LOW (COM48),LOW (COM49),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'48
        DEFB LOW (COM50),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'50
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'58
        DEFB LOW (COM60),LOW (COM61),LOW (COM62),LOW (COM63),LOW (COM64),LOW (COM65),LOW (COM66),LOW (COM67)  ;h'60
        DEFB LOW (COM68),LOW (COM69),LOW (COM6A),LOW (COM6B),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'68 patched
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'70
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'78
        DEFB LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80)  ;h'80
        DEFB LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80)  ;h'88
        DEFB LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80)  ;h'90
        DEFB LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80),LOW (COM80)  ;h'98
        DEFB LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0)  ;h'A0
        DEFB LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0),LOW (COMA0)  ;h'A8
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'B0
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'B8
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'C0
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'C8
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'D0
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'D8
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'E0
        DEFB LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ),LOW (COMHZ)  ;h'E8

        DUPL h'10,0
        DUPL h'20,0

	DEFB HIGH (COM20),HIGH (COM21),HIGH (COM22),HIGH (COM23),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'20
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COM2A),HIGH (COM2B),HIGH (COM2C),HIGH (COM2D),HIGH (COM2E),HIGH (COM2F)  ;h'28
        DEFB HIGH (COM30),HIGH (COM31),HIGH (COM32),HIGH (COM33),HIGH (COM34),HIGH (COM35),HIGH (COM36),HIGH (COM37)  ;h'30
        DEFB HIGH (COM38),HIGH (COM39),HIGH (COM3A),HIGH (COM3B),HIGH (COM3C),HIGH (COM3D),HIGH (COM3E),HIGH (COM3F)  ;h'38
        DEFB HIGH (COM40),HIGH (COM41),HIGH (COM42),HIGH (COMHZ),HIGH (COMHZ),HIGH (COM45),HIGH (COM46),HIGH (COM47)  ;h'40
        DEFB HIGH (COM48),HIGH (COM49),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'48
        DEFB HIGH (COM50),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'50
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'58
        DEFB HIGH (COM60),HIGH (COM61),HIGH (COM62),HIGH (COM63),HIGH (COM64),HIGH (COM65),HIGH (COM66),HIGH (COM67)  ;h'60
        DEFB HIGH (COM68),HIGH (COM69),HIGH (COM6A),HIGH (COM6B),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'68 patched
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'70
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'78
        DEFB HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80)  ;h'80
        DEFB HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80)  ;h'88
        DEFB HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80)  ;h'90
        DEFB HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80),HIGH (COM80)  ;h'98
        DEFB HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0)  ;h'A0
        DEFB HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0),HIGH (COMA0)  ;h'A8
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'B0
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'B8
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'C0
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'C8
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'D0
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'D8
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'E0
        DEFB HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ),HIGH (COMHZ)  ;h'E8

        DUPL h'10,0

FXJP1   DEFW FXNOP,FXNOP,FXNOP,FXNOP,FXNOP,FXNOP,FXNOP,FXNOP
        DEFW FXNOP,FXNOP,FXNOP,FXB  ,FXC  ,FXD  ,FXE  ,FXF

        DEFW FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET
        DEFW FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET

FXJP2   DEFW FX0  ,FX1  ,FX2  ,FX3  ,FX4  ,FX5  ,FX6  ,FX7
        DEFW FXRET,FXRET,FXA  ,FXRET,FXRET,FXRET,FXE_ ,FXRET

        DEFW FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET
        DEFW FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET

FXEJP1  DEFW FXE0,FX1,FX2,FXE3,FXE4,FXE5,FXE6,FXE7
        DEFW FXRET,FXE9,FXEA,FXA,FXEC,FXED,FXEE,FXRET

FXEJP2  DEFW FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET,FXRET
        DEFW FXRET,FXE9,FXRET,FXRET,FXEC,FXED,FXRET,FXRET

TCOMTB  DEFW TCOM,TCOM,TCOM2,TCOM3,TCOM4,TCOM5,TCOM6,TCOM7
        DEFW TCOM8,TCOM9,TCOMA,TCOMB,TCOMC,TCOMD,TCOME,TCOMF
        DEFW TCOM10,TCOM11,TCOM12,TCOM13,TCOM14,TCOM15,TCOM,TCOM
        DEFW TCOM,TCOM,TCOM,TCOM,TCOM,TCOM,TCOM,TCOM

;INCLUDE "DIHO.a80"
;RETURN: E - NOTE

NOTEID  LD HL,AMINOTE
        CALL DIH
        LD E,A
        RET

;RETURN: E - NOTE

NOTEGET LD E,(IY+CHNOTE)
        LD A,E
        INC A
        RET NZ
NOTEFND LD HL,AMFRQTB
        LD A,(IY+CHFINE)
        RRA
        AND h'0F
        JR Z,NOTEFN1
        LD C,A
        ADD A,A
        ADD A,C
        ADD A,A
        ADD A,A
        ADD A,A
        LD B,0
        RL B
        ADD A,A
        RL B
        ADD A,A
        RL B
        LD C,A
        ADD HL,BC
NOTEFN1 LD E,(IY+CHPERL)
        LD D,(IY+CHPERH)
        CALL DIH
        LD E,A
        RET

DIH     LD BC,h'005F
        PUSH HL
        INC HL
        LD A,(HL)
        DEC HL
        CP D
        JR C,DIHRGR
        JR NZ,DIH2
        LD A,(HL)
        CP E
        JR C,DIHRGR
        JR NZ,DIH2
        POP HL
        XOR A
        SCF
        RET

DIHRGR  LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        XOR A
        RET

DIH2    LD A,h'BF
        ADD A,L
        LD L,A
        LD A,H
        ADC A,B
        LD H,A
        LD A,(HL)
        DEC HL
        CP D
        JR C,DIH3
        JR NZ,DIHRLO
        LD A,(HL)
        CP E
        JR C,DIH3
        JR NZ,DIHRLO
        POP HL
        LD A,C
        SCF
        RET

DIHRLO  LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        LD A,C
        OR A
        RET

DIH3    POP HL
DIHLP   PUSH HL
        LD A,B
        ADD A,C
        AND h'FE
        ADD A,L
        LD L,A
        LD A,H
        ADC A,h'00
        LD H,A
        INC HL
        LD A,(HL)
        DEC HL
        CP D
        JR C,DIHGR
        JR NZ,DIHLO
        LD A,(HL)
        CP E
        JR C,DIHGR
        JR NZ,DIHLO
        POP HL
        LD A,B
        ADD A,C
        SRL A
        SCF
        RET

DIHGR   LD A,B
        ADD A,C
        SRL A
        LD C,A
        POP HL
        JP DIHLP

DIHLO   LD A,B
        ADD A,C
        SRL A
        CP B
        LD B,A
        JR Z,DIHMID
        POP HL
        JP DIHLP

DIHMID  PUSH HL
        PUSH BC
        LD A,(HL)
        INC HL
        SUB E
        LD C,A
        LD A,(HL)
        INC HL
        SBC A,D
        LD B,A
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        EX DE,HL
        OR A
        SBC HL,DE
        LD A,H
        CP B
        JR C,DIHFLO
        JR NZ,DIHFGR
        LD A,L
        CP C
        JR C,DIHFLO
        JR NZ,DIHFGR
DIHFLO  POP BC
        POP HL
        POP HL
        LD A,C
        OR A
        RET

DIHFGR  POP BC
        POP HL
        LD E,(HL)
        INC HL
        LD D,(HL)
        POP HL
        LD A,B
        RET

AMINOTE DEFW h'1AC0,h'1940,h'17D0,h'1680,h'1530,h'1400,h'12E0,h'11D0,h'10D0,h'0FE0,h'0F00,h'0E28;C-0
	DEFW h'0D60,h'0CA0,h'0BE8,h'0B40,h'0A98,h'0A00,h'0970,h'08E8,h'0868,h'07F0,h'0780,h'0714;C-1
	DEFW h'06B0,h'0650,h'05F4,h'05A0,h'054C,h'0500,h'04B8,h'0474,h'0434,h'03F8,h'03C0,h'038A;C-2
	DEFW h'0358,h'0328,h'02FA,h'02D0,h'02A6,h'0280,h'025C,h'023A,h'021A,h'01FC,h'01E0,h'01C5;C-3
	DEFW h'01AC,h'0194,h'017D,h'0168,h'0153,h'0140,h'012E,h'011D,h'010D,h'00FE,h'00F0,h'00E2;C-4
	DEFW h'00D6,h'00CA,h'00BE,h'00B4,h'00AA,h'00A0,h'0097,h'008F,h'0087,h'007F,h'0078,h'0071;C-5
	DEFW h'006B,h'0065,h'005F,h'005A,h'0055,h'0050,h'004B,h'0047,h'0043,h'003F,h'003C,h'0038;C-6
	DEFW h'0035,h'0032,h'002F,h'002D,h'002A,h'0028,h'0025,h'0023,h'0021,h'001F,h'001E,h'001C;C-7
___END

		; DUPL GSRomBaseH+h'2000-$,h'FF

	    ; PHASE GSRomBaseH+h'2000

