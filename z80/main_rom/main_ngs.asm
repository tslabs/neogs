        RSEG CODE
;1720708

#include "macros.asm"
#include "ports_ngs.asm"
#include "equ_ngs.asm"

		ORG GSRomBaseL
		DI
		JP INIT

;---patched
		DEFB h'08			;LOW	(in BCD!)
		DEFB h'01			;HIGH	(in BCD!)
;---

ROMCRC	DEFW h'E428			;CRC from original rom, corrupted!?

		ORG GSRomBaseL+h'0030
		JP SGEN				;h'2030

		ORG GSRomBaseL+h'0038

INT8	EX AF,AF'
		PUSH DE
		LD E,A
		LD D,IXH
		LD A,(DE)
		INC D
		LD A,(DE)
		INC D
		LD A,(DE)
		INC D
		LD A,(DE)
		INC E
		JR Z,INT8_
		LD A,E
		POP DE
		EX AF,AF'
		EI
		RET

INT8_	JP QTDONE

		ORG GSRomBaseL+h'0066
NMILP	POP HL
		LD A,L
		OUT (ZXDATWR),A
NMILP2	IN A,(ZXSTAT)
		RLCA
		JR C,NMILP2
		LD A,H
		OUT (ZXDATWR),A
NMILP3	IN A,(ZXSTAT)
		RLCA
		JR C,NMILP3
		JP NMILP

		ORG GSRomBaseL+h'0080
		DEFB 'This is improved ROM Version 1.04 Beta. '
		DEFB 'Bugfixes by psb & Evgeny Muchkin, 2007.',0

		ORG GSRomBaseL+h'0100
		DEFB 'General  Sound (tm)  ROM'
		DEFB 'Copyright   1997 Stinger'
		DEFB 'Version 1.08            '

INIT	DI
		OUT (CLRCBIT),A
INIT_	XOR A
		OUT (ZXDATWR),A
;		LD L,A
;		LD H,A
;		LD BC,h'0004
;		LD SP,h'0008
;		JR INIT02

;INIT00
		OUT (MPAG),A
;		LD SP,h'C000
;		LD C,h'04
;		DEC A
;INIT01		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;INIT02		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;		POP DE
;		ADD HL,DE
;		DJNZ INIT01
;		DEC C
;		JR NZ,INIT01
;		OR A
;		JR Z,INIT00
;		LD DE,(ROMCRC)
;		SBC HL,DE
;		LD HL,RAMPG
;---patched
;		LD A,2
;CREATE_LIST_PAGE
;		LD (HL),A
;		INC HL
;		INC A
;		CP h'40
;		JR NZ,CREATE_LIST_PAGE
;		LD (HL),1
;		INC HL
;		LD (HL),0
		LD HL,h'8000
		LD A,h'7F
		OUT (MPAG),A
		LD (HL),h'AA
		LD A,h'3F
		OUT (MPAG),A
		LD (HL),h'55
		LD A,h'7F
		OUT (MPAG),A
		LD A,(HL)
		CP h'AA
		LD A,h'7E
		JR Z,CP_RAMPAGES
		LD A,h'3E
CP_RAMPAGES	LD (NUMPG),A
		OUT (ZXDATWR),A
		ADD A,2
		LD B,A
		LD HL,RAMPG
		LD A,2
CREATE_TABL	LD (HL),A
		INC HL
		INC A
		CP B
		JR C,CREATE_TABL
		LD (HL),1
		INC HL
		LD (HL),0
		LD SP,h'8000
		XOR A
		OUT (MPAG),A
		JP Patch5i3

		; DUPL GSRomBaseL + h'269 - $, 0
		DUPL 256, 0

		ORG GSRomBaseL + h'269

COMHZ	OUT (CLRCBIT),A
COMINT	LD SP,ISTACK		;h'026B
COMINT_	IN A,(ZXSTAT)
		RRCA
		JR C,COMINT1
 		LD A,(PROCESS)		;h'0273
		OR A
		JR Z,COMINT_
		LD A,(BUSY)
		OR A
		JR NZ,COMINT_
		IN A,(ZXSTAT)
		RRCA
		JR C,COMINT1
		LD A,h'FF
		LD (INGEN),A
		PUSH DE
		CALL ENGINE
		POP DE
		XOR A
		LD (INGEN),A
		JP COMINT_

COMINT1	IN A,(ZXCMD)
		CP h'20
		JR C,COMLOW
COMINT2	CP h'F0
		JR C,COMHIGH
		SUB h'D0
COMLOW	ADD A,A
		LD H,HIGH (COMTAB)
		LD L,A
		LD A,(HL)
		INC L
		LD H,(HL)
		LD L,A
		JP (HL)

COMHIGH	LD HL,COMINT_
		PUSH HL
		LD L,A
		LD H,HIGH (COMTABH)
		XOR A
		LD (CPAGE),A
		OUT (MPAG),A
		LD A,(HL)
		INC H
		LD H,(HL)
		LD L,A
		JP (HL)

WTDTL	IN A,(ZXSTAT)
		AND h'81
		JR Z,WTDTL
		IN A,(ZXDATRD)
		JP P,COMINT1
		JP (IY)

WTDTG	IN A,(ZXSTAT)
		OR A
		JP P,WTDTG
		IN A,(ZXDATRD)
		JP (IY)

		ALIGN256
#include "comtab.asm"

COMZ	OUT (CLRCBIT),A
		JP COMINT_

COM1E	EQU COMZ
COM1F	EQU COMZ

COMF1	EQU COMZ
COMF2	EQU COMZ

COMF8	EQU COMZ
COMF9	EQU COMZ

COMFB	EQU COMZ
COMFC	EQU COMZ
COMFD	EQU COMZ
COMFE	EQU COMZ
COMFF	EQU COMZ

;Reset flags
;Сбрасывает флаги Data bit и Command bit.
COM00	IN A,(ZXDATRD)
		OUT (CLRCBIT),A
		JP COMINT_

;Set silence (*)
;Выводит в ЦАПы всех каналов h'80. По сути устанавливает тишину.
COM01	OUT (CLRCBIT),A
		LD A,h'80
		LD HL,DAC0
		LD (HL),A
		LD B,(HL)
		INC H
		LD (HL),A
		LD B,(HL)
		INC H
		LD (HL),A
		LD B,(HL)
		INC H
		LD (HL),A
		LD B,(HL)
		JP COMINT_

;Set low volume (*)
;Устанавливает громкостx ЦАПов всех каналов в ноль.
COM02   OUT (CLRCBIT),A
        LD A,h'3F
        OUT (VOL1),A
        OUT (VOL2),A
        OUT (VOL3),A
        OUT (VOL4),A
        JP COMINT_

;Set high volume (*)
;Устанавливает громкость ЦАПов всех каналов в максимум.
COM03   OUT (CLRCBIT),A
        XOR A
        OUT (VOL1),A
        OUT (VOL2),A
        OUT (VOL3),A
        OUT (VOL4),A
        JP COMINT_

;Set 'E' 3bits (*)
;Устанавливает в 'E' регистре GS 3 младших бита в соответствии с  задан-
;ным значением (2  младших  бита  в  сущности  являются  номером  канала
;h'00-h'03).
COM04   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        AND h'07
        LD E,A
        JP COMINT_

;Out volume port (*)
;Устанавливает громкость канала, номер которого содержится в 'E', в ука-
;занное значение. (Команда срабатывает при условии,  что 'E' находится в
;пределах h'00-h'03)
COM05   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        LD A,E
        CP h'04
        JP NC,COMINT_
        ADD A,VOL1
        LD C,A
        OUT (C),B
        JP COMINT_

;Send to DAC (*)
;Выводит байт в ЦАП канала, указываемого по 'E'.
COM06   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        LD A,E
        CP h'04
        JP NC,COMINT_
        ADD A,HIGH (DAC0)
        LD H,A
        LD L,h'00
        LD (HL),B
        LD A,(HL)
        JP COMINT_

;Send to DAC and to volume port (*)
;Выводит байт в ЦАП ('E') с заданной громкостью.
COM07   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        LD A,E
        CP h'04
        JP NC,COMINT_
        ADD A,HIGH (DAC0)
        LD H,A
        LD L,h'00
        LD (HL),B
        SUB HIGH (DAC0)
        ADD A,VOL1
        LD C,A
        LD IY,COM07_1
        JP WTDTL

COM07_1 OUT (C),A
        LD A,(HL)
        JP COMINT_

;то же что и команда h'00
;Reset flags
;Сбрасывает флаги Data bit и Command bit.
COM08   EQU COMZ

;Sets one's byte volume. (*)
;Установка громкости канала, номер которого задан в 2х старших битах.
COM09   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        RLCA
        RLCA
        AND h'03
        ADD A,VOL1
        LD C,A
        LD A,B
        AND h'3F
        OUT (C),A
        JP COMINT_

;DAC output (*)
;Еще один непосредственный вывод в ЦАП.
COM0A   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        LD IY,COM0A_1
        JP WTDTL

COM0A_1 AND h'03
        ADD A,HIGH (DAC0)
        LD H,A
        LD L,h'00
        LD (HL),B
        LD A,(HL)
        JP COMINT_

;DAC and Volume output (*)
;И наконец последний вывод в ЦАП с установкой громкости.
COM0B   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD C,A
        LD IY,COM0B_1
        JP WTDTL

COM0B_1 LD B,A
        RLCA
        RLCA
        AND h'03
        ADD A,HIGH (DAC0)
        LD H,A
        LD L,h'00
        LD (HL),C
        SUB HIGH (DAC0)
        ADD A,VOL1
        LD C,A
        LD A,B
        AND h'3F
        OUT (C),A
        LD A,(HL)
        JP COMINT_

;Call SounDrive Covox mode (*)
;Вызывает режим четырехканального Ковокса,  последовательно копирует ре-
;гистр данных по каналам.  Выход из режима  автоматически  после  вывода
;четвертого байта.
COM0C   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD HL,DAC0
        LD (HL),A
        LD A,(HL)
        INC H
        LD IY,COM0C_1
        JP WTDTL

COM0C_1 LD (HL),A
        LD A,(HL)
        INC H
        LD IY,COM0C_2
        JP WTDTL

COM0C_2 LD (HL),A
        LD A,(HL)
        INC H
        LD IY,COM0C_3
        JP WTDTL

COM0C_3 LD (HL),A
        LD A,(HL)
        JP COMINT_

;Call Ultravox mode (*)
;Вызывает режим универсального Ковокса,   последовательно  копирует  ре-
;гистр данных по каналам,  число которых регулируется (1-4).В отличие от
;предыдущего варианта синхронизация не производится.  Выход также произ-
;водится автоматически по записи последнего байта.
COM0D   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        AND h'0F
        JP Z,COMINT_
        RLCA
        RLCA
        RLCA
        RLCA
        LD B,A
        LD HL,DAC0
        LD IY,COM0D_3
        JP COM0D_2

COM0D_3 LD (HL),A
        LD A,(HL)
        INC H
        JP COM0D_2

COM0D_1 JP Z,COMINT_
        INC H
COM0D_2 SLA B
        JR NC,COM0D_1
        JP WTDTL

;Go to LPT Covox mode
;Переходит в режим одноканального Ковокса,   напрямую  копирует  регистр
;данных в ЦАПы двух (правого и левого) каналов.  Выход из этого режима -
;запись h'00 в регистр команд.
COM0E   OUT (CLRCBIT),A
        LD HL,DAC0
        LD BC,DAC2
COM0E_1 IN A,(ZXDATRD)
        LD (HL),A
        LD (BC),A
        LD A,(HL)
        LD A,(BC)
        IN A,(ZXSTAT)
        RRCA
        JP NC,COM0E_1
        JP COMINT_

;Go in Profi Covox mode (*)
;Переходит в режим двухканального Ковокса,   напрямую  копирует  регистр
;данных в ЦАПы одного канала,  а регистр каманд в ЦАПы  второго  канала.
;Выход из этого режима - запись h'4Е в регистр данных,  затем  последова-
;тельно h'0F и h'AA в регистр команд.
COM0F   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CP 'Y'
        JP NZ,COMINT_
        LD HL,DAC0
        LD DE,DAC2
COM0F_1 IN A,(ZXDATRD)
        LD (HL),A
        IN A,(ZXCMD)
        LD (DE),A
        LD A,(HL)
        LD A,(DE)
        IN A,(ZXSTAT)
        OR A
        JP M,COM0F_1
        LD B,h'00
        OUT (CLRCBIT),A
COM0F_2 IN A,(ZXSTAT)
        AND h'81
        JR NZ,COM0F_1
        DJNZ COM0F_2
COM0F_3 IN A,(ZXSTAT)
        AND h'81
        JR Z,COM0F_3
        CP h'80
        JR NZ,COM0F_1
        IN A,(ZXDATRD)
        CP 'N'
        JP NZ,COM0F_1
COM0F_4 IN A,(ZXSTAT)
        AND h'81
        JR Z,COM0F_4
        CP h'01
        JR NZ,COM0F_1
        IN A,(ZXCMD)
        CP h'0F
        JP NZ,COM0F_1
        OUT (CLRCBIT),A
COM0F_5 IN A,(ZXSTAT)
        AND h'81
        JR Z,COM0F_5
        CP h'01
        JR NZ,COM0F_1
        IN A,(ZXCMD)
        CP h'AA
        JP NZ,COM0F_1
        OUT (CLRCBIT),A
        JP COMINT_

;Out to any port (*)
;Выводит байт вo внутренний порт GS (h'00-h'09).
COM10   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD C,A
        LD IY,COM10_1
        JP WTDTL

COM10_1 OUT (C),A
        JP COMINT_

;In from any port (*)
;читает байт из внутреннего порта GS (h'00-h'09).
COM11   IN A,(ZXDATRD)
        LD C,A
        IN A,(C)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

;OUT to 0 port (*)
;Выводит байт в порт кофигурации GS (h'00).
COM12   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        OUT (MPAG),A
        JP COMINT_

;Jump to Address (*)
;Передает управление по заданному адресу.
COM13   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD L,A
        LD IY,COM13_1
        JP WTDTL

COM13_1 LD H,A
        JP (HL)

;Load memory block (*)
;Загрузка блока кодов по указанному адресу с заданной длиной.
; 70+27*WAIT PER LOOP : 171K,123K,96K PER SECOND MAX
COM14   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        CPL
        LD C,A
        LD HL,WTDTL
        LD IY,COM14_1
        JP (HL)

COM14_1 CPL
        LD B,A
        INC BC
        LD IY,COM14_2
        JP (HL)

COM14_2 LD E,A
        LD IY,COM14_3
        JP (HL)

COM14_3 LD D,A
        LD A,B
        OR C
        JP Z,COMINT_
        LD IXL,B
        LD B,h'81
        BIT 0,C
        JR NZ,COM14_7
COM14_6 IN A,(ZXSTAT)
        AND B
        JR Z,COM14_6
        IN A,(ZXDATRD)
        JP P,COMINT1
        LD (DE),A
        INC DE
        INC C
COM14_7 IN A,(ZXSTAT)
        AND B
        JR Z,COM14_7
        IN A,(ZXDATRD)
        JP P,COMINT1
        LD (DE),A
        INC DE
        INC C
        JP NZ,COM14_6
	INC IXL
        JP NZ,COM14_6
        JP COMINT_

;Get memory block (*)
;Выгрузка блока кодов по указанному адресу с заданной длиной.
COM15   IN A,(ZXDATRD)	;ошибка-не сбрасывается команд бит
        CPL
        LD C,A
        LD IY,COM15_1
        JP WTDTG

COM15_1 CPL
        LD B,A
        INC BC
        LD IY,COM15_2
        JP WTDTG

COM15_2 LD E,A
        LD IY,COM15_3
        JP WTDTG

COM15_3 LD D,A
        LD A,B
        OR C
        JP Z,COMINT_
        LD IXL,B
        LD B,h'81
        LD A,(DE)
        INC DE
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        LD HL,COM15_4
        INC C
        JP NZ,COM15_4
        INC IXL
        JP Z,COMINT_
COM15_4 IN A,(ZXSTAT)
        AND B
        JR Z,COM15_5
        JP P,COMINT1
        IN A,(ZXSTAT)
        AND B
        JR Z,COM15_5
        JP P,COMINT1
        IN A,(ZXSTAT)
        AND B
        JR Z,COM15_5
        JP P,COMINT1
        IN A,(ZXSTAT)
        AND B
        JR Z,COM15_5
        JP P,COMINT1
        JP (HL)

COM15_5 LD A,(DE)
        OUT (ZXDATWR),A
        INC DE
        INC C
        JP NZ,COM15_4
COM15_7 INC IXL
        JP NZ,COM15_4
        JP COMINT_

;Poke to address (*)
;Записывает единичный байт по указанному адресу.
COM16   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD B,A
        LD IY,COM16_1
        JP WTDTL

COM16_1 LD L,A
        LD IY,COM16_2
        JP WTDTL

COM16_2 LD H,A
        LD (HL),B
        JP COMINT_

;Peek from address (*)
;Считывает единичный байт из указанного адреса.
COM17   IN A,(ZXDATRD)
        LD L,A
        LD IY,COM17_1
        JP WTDTL

COM17_1 LD H,A
        LD A,(HL)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

;Load DE Pair (*)
;Загружает регистовую пару DE (относящуюся к GS,  не путать с  одноимен-
;ной парой Main CPU) указанным словом.
COM18   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD E,A
        LD IY,COM18_1
        JP WTDTL

COM18_1 LD D,A
        JP COMINT_

;Poke to (DE) address (*)
;Записывает байт по адресу указанному в DE.
COM19   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD (DE),A
        JP COMINT_

;Peek from (DE) address (*)
;Считывает содержимое адреса, указываемого по DE.
COM1A   LD A,(DE)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

;Increment of DE Pair (*)
;Увеличивает пару DE на единичку.
COM1B   OUT (CLRCBIT),A
        INC DE
        JP COMINT_

;Poke to (h'2h'X) address (*)
;Записывает байт по адресу, старший байт которого равен h'20.
COM1C   IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        LD L,A
        LD IY,COM1C_1
        JP WTDTL

COM1C_1 LD H,h'20
        LD (HL),A
        JP COMINT_

;Peek from (h'2h'X) address (*)
;читает байт с адреса, старший байт которого равен h'20.
COM1D   IN A,(ZXDATRD)
        LD L,A
        LD H,h'20
        LD A,(HL)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

COMF0   LD A,(ERRCODE)  ; GET STATUS
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

;Warm restart
;Сбрасывает полностью GS,  но пропускает  этапы  определения  количества
;страниц памяти и их провеки,  что очень сильно ускоряет процесс инициа-
;лизации.
COMF3   OUT (CLRCBIT),A
        JP INITVAR

;Cold restart
;Полный перезапуск GS со всеми проверками. По сути, JP h'0000.
COMF4   OUT (CLRCBIT),A
        JP h'0000

;Busy on
;Устанавливает флаг занятости в h'FF
COMF5   OUT (CLRCBIT),A
        LD A,IXH
        AND h'80
        JP NZ,COMF5_1
        LD A,h'FF
        LD (BUSY),A
        JP COMINT_

COMF5_1 OR h'40
        LD IXH,A
        JP COMINT_

;Busy off
;Устанавливает флаг занятости в h'00
COMF6   OUT (CLRCBIT),A
        LD A,IXH
        AND h'80
        JP NZ,COMF6_1
        XOR A
        LD (BUSY),A
        JP COMINT_

COMF6_1 LD IXH,A
        JP COMINT_

;Get IXH Register (*)
;Получить содержимое регистра IXH (GS)
;IXH участвует в обработке флага Busy.
COMF7   LD A,IXH
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP COMINT_

;Out zero_to_zero
;Вывод нуля в нулевой (конфигурационный) порт GS.   Делает  приостановку
;звучания музыки до следующего чтения из к.л. порта.
COMFA   OUT (CLRCBIT),A
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        JP TCOM

;MEMORY MOVEMENT MODULE - LOW PART
	ALIGN256

LDITAB  REPT h'100
        DEFB h'ED, h'A0
        ENDR

        RET C
        LD A,(SYSTEM)
        LD (CPAGE),A
        OUT (MPAG),A
        RET

MLDI    NEG
        ADD A,A
        LD IYL,A
        LD A,HIGH (LDITAB)
        ADC A,h'00
        LD IYH,A
        LD A,(SDPAGE)
        LD (CPAGE),A
        OUT (MPAG),A
        JP (IY)

TLDI    NEG
        ADD A,A
        LD IYL,A
        LD A,HIGH (LDITAB)
        ADC A,h'00
        LD IYH,A
        SCF
        JP (IY)

MLDD    NEG
        ADD A,A
        LD IYL,A
        LD A,HIGH (LDDTAB)
        ADC A,h'00
        LD IYH,A
        LD A,(SDPAGE)
        LD (CPAGE),A
        OUT (MPAG),A
        JP (IY)

	ALIGN256

LDDTAB  REPT h'100
        DEFB h'ED, h'A8
        ENDR

        LD A,(SYSTEM)
        LD (CPAGE),A
        OUT (MPAG),A
        RET


; RET B,DE - OLD CURADR
;h'0C09

LOAD    LD B,h'81
        LD HL,(CURADR)
        LD A,(CURADR+2)
        SCF
        RL H
        RLA
        RRC H
        LD E,A
        LD D,HIGH (RAMPG)
LOAD_   LD A,(DE)
        OR A
        JP Z,LOADEFWT3
        LD (CPAGE),A
        OUT (MPAG),A
        LD A,(NUMPG)
        CP E
        JR NZ,LOADEFWT
        LD A,H
        CP h'C0
        JR C,LOADEFWT2
        JP LOADEFWT3

LOADEFWT
        IN A,(ZXSTAT)
        AND B
        JR Z,LOADEFWT
        RRCA
        IN A,(ZXDATRD)
        JR C,LOADCM
        ADD A,C
        LD (HL),A
        INC L
        JP NZ,LOADEFWT
        INC H
        JP NZ,LOADEFWT
        INC E
        LD HL,h'8000
        JP LOAD_

LOADCM  IN A,(ZXCMD)
        CP h'F3
        JP Z,COMF3
        CP h'F4
        JP Z,COMF4
        OUT (CLRCBIT),A
        CP h'D2
        JP Z,LOAD3
        JP LOADEFWT

LOADEFWT2
        IN A,(ZXSTAT)
        AND B
        JR Z,LOADEFWT2
        RRCA
        IN A,(ZXDATRD)
        JR C,LOADCM2
        LD (HL),A
        INC L
        JP NZ,LOADEFWT2
        INC H
        BIT 6,H
        JP Z,LOADEFWT2
LOADEFWT3
        IN A,(ZXSTAT)
        AND B
        JR Z,LOADEFWT3
        RRCA
        IN A,(ZXDATRD)
        JP NC,LOADEFWT3
        IN A,(ZXCMD)
        CP h'F3
        JP Z,COMF3
        CP h'F4
        JP Z,COMF4
        OUT (CLRCBIT),A
        CP h'D2
        JR Z,LOAD3
        JP LOADEFWT3

LOADCM2 IN A,(ZXCMD)
        CP h'F3
        JP Z,COMF3
        CP h'F4
        JP Z,COMF4
        OUT (CLRCBIT),A
        CP h'D2
        JR Z,LOAD3
        JP LOADEFWT2

LOAD3   LD A,E
        RL H
        SRL A
        RR H
        LD (CURADR),HL
        LD (CURADR+2),A
        LD (MEMBOT),HL
        LD (MEMBOT+2),A
        LD E,A
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        LD A,E
        RET

PLAYMD  LD A,(RAMPG)		;h'0CC9
        OUT (MPAG),A
        LD IY,CHANS
        LD DE,CHANLEN
        LD B,h'04
RDLP1
;---patched
        CALL Patch4
        NOP
;---
        LD (IY+CHCNTH),h'00
        LD (IY+CHOLDV),h'80
        LD (IY+CHSTAT),h'01
        LD (IY+CHLPCNT),h'00
        LD (IY+CHPATPS),h'00
        LD (IY+CHTRMPS),h'00
        LD (IY+CHVIBPS),h'00
        LD (IY+CHVOL),h'40
        LD (IY+CHMVOL),h'40
        LD (IY+CHINS),h'00
        LD (IY+CHSMP),h'00
        LD (IY+CHPAN),h'80
        LD (IY+CHEPAN),h'20
        LD (IY+CHEVOL),h'40
        LD (IY+CHFADVL),h'FF
        LD (IY+CHFADVH),h'FF
        ADD IY,DE
        DJNZ RDLP1
        LD IXL,h'FF
        LD A,(h'8000+1080)	;определение сигнатуры заголовка
        CP 'M'
        JR Z,TTY1
        CP '4'
        JR Z,TTY1
        CP 'F'
        JR Z,TTY1
        LD IXL,h'00
        JP TTY0
TTY1    LD A,(h'8000+1081)
        CP '.'
        JR Z,TTY2
        CP 'L'
        JR Z,TTY2
        CP '!'
        JR Z,TTY2
        CP 'C'
        JR Z,TTY2
        LD IXL,h'00
        JP TTY0
TTY2    LD A,(h'8000+1082)
        CP 'K'
        JR Z,TTY0
        CP 'T'
        JR Z,TTY0
        CP 'H'
        JR Z,TTY0
        LD IXL,h'00
TTY0    LD A,IXL
        LD (MODTP),A
        LD HL,h'8000+952
        OR A
;---patched
        LD DE,h'0000+1084
        JR NZ,TTY10
        LD DE,h'0000+600		;размер заголовка файла
        LD HL,h'8000+472		;смещение до таблицы патернов
TTY10   LD B,h'80		;сканирование таблицы патернов
        SUB A
FDF2    CP (HL)
        JR NC,FDF
        LD A,(HL)
FDF     INC HL
        DJNZ FDF2
        INC A
        LD (PATTS),A		;количество патернов
        LD L,A
        LD H,B
        ADD HL,HL
        ADD HL,HL		;HL=кол-во патернов*4
        LD A,H
        LD H,L
        LD L,B
        ADD HL,DE
        ADC A,B
        DEFB h'CB,h'34;SLI H
        RLA
        RRC H
        LD E,A
        LD (SMPS),HL
        LD (SMPS+2),A
        DUPL 3,0
;---
        LD A,IXL
        OR A
        LD BC,h'8000+950
        JR NZ,TTT11
        LD BC,h'8000+470
TTT11   LD A,(BC)
	DEC A
        LD (MTSNGSZ),A
        INC BC
        LD A,(BC)
        LD (MTSNGLP),A
        LD IX,h'5400
        LD IY,h'8000+20		;начало сэмплов
        LD B,31
        LD C,E
RDLP3   PUSH BC
        LD (IX+SMPBEG),C
        LD (IX+SMPBEG+1),L
        LD (IX+SMPBEG+2),H
        LD A,(IY+28)
        OR A
        JR NZ,LPL
        LD A,(IY+29)
        CP h'02
        JP C,NLPL
LPL     PUSH HL
        PUSH BC
        LD L,(IY+27)
        LD H,(IY+26)
        LD E,(IY+23)
        LD D,(IY+22)
        SBC HL,DE
        POP BC
        POP HL
        JP NC,NLPL
        PUSH HL
        PUSH BC
        LD E,(IY+27)
        LD D,(IY+26)
        EX DE,HL
        ADD HL,HL
        EX DE,HL
        LD B,0
        RL B
        SRL C
        RL H
        RRC H
        ADD HL,DE
        LD A,C
        ADC A,B
        LD C,A
        DEFB h'CB,h'34;SLI H
        RL C
        RRC H
        LD (IX+SMPLPB),C
        LD (IX+SMPLPB+1),L
        LD (IX+SMPLPB+2),H
        SRL C
        RL H
        RRC H
        LD E,(IY+29)
        LD D,(IY+28)
        EX DE,HL
        ADD HL,HL
        EX DE,HL
        LD B,0
        RL B
        ADD HL,DE
        LD A,C
        ADC A,B
        LD C,A
        DEFB h'CB,h'34;SLI H
        RL C
        RRC H
        LD (IX+SMPLPE),C
        LD (IX+SMPLPE+1),L
        LD (IX+SMPLPE+2),H
        POP BC
        POP HL
        LD E,(IY+23)
        LD D,(IY+22)
        EX DE,HL
        ADD HL,HL
        EX DE,HL
        LD B,h'00
        RL B
        SRL C
        RL H
        RRC H
        ADD HL,DE
        LD A,C
        ADC A,B
        LD C,A
        DEFB h'CB,h'34;SLI H
        RL C
        RRC H
        JP LPL2

        LD A,(IX+SMPLPE)
        CP C
        JR C,LPL2
        JR NZ,LPL1
        LD A,(IX+SMPLPE+2)
        CP H
        JR C,LPL2
        JR NZ,LPL1
        LD A,(IX+SMPLPE+1)
        CP L
        JR C,LPL2
LPL1    LD A,(IX+SMPEND)
        LD (IX+SMPLPE),A
        LD A,(IX+SMPEND+1)
        LD (IX+SMPLPE+1),A
        LD A,(IX+SMPEND+2)
        LD (IX+SMPLPE+2),A
        JP LPCNT

LPL2    LD A,(IX+SMPLPE)
        LD (IX+SMPEND),A
        LD A,(IX+SMPLPE+1)
        LD (IX+SMPEND+1),A
        LD A,(IX+SMPLPE+2)
        LD (IX+SMPEND+2),A
        JP LPCNT

NLPL    LD (IX+SMPLPB),h'FF
        LD E,(IY+23)
        LD D,(IY+22)
        EX DE,HL
        ADD HL,HL
        EX DE,HL
        LD B,h'00
        RL B
        SRL C
        RL H
        RRC H
        ADD HL,DE
        LD A,C
        ADC A,B
        LD C,A
        DEFB h'CB,h'34;SLI H
        RL C
        RRC H
RDLP2   LD (IX+SMPEND+1),L
        LD (IX+SMPEND+2),H
        LD (IX+SMPEND),C
LPCNT   LD A,(IY+24)
        ADD A,A
        LD (IX+SMPFT),A
        LD A,(IY+25)
        LD (IX+SMPVOL),A
        LD DE,h'0010
        ADD IX,DE
        LD DE,30
        ADD IY,DE
        LD A,C
        POP BC
        LD C,A
        DEC B
        JP NZ,RDLP3
        LD HL,CONVERT
        LD A,(HL)
        OR A
        JR NZ,NOCONV
        LD (HL),h'FF
        LD HL,(SMPS)
        LD A,(SMPS+2)
        LD E,A
        LD D,HIGH (RAMPG)
        ; LD A,(NUMPG)
        LD A,(MEMBOT+2)	; No obsolete memory abusing patch (TSL)
		ADD A,3			; patch end
        SUB E
        LD B,A
SMPMD2  LD A,(DE)
        OUT (MPAG),A
SMPMD1  LD A,(HL)		;начало ADD A,h'80
        ADD A,h'80
        LD (HL),A
        INC L
        JP NZ,SMPMD1
        INC H
        JP NZ,SMPMD1
        LD H,h'80
        INC E
        DJNZ SMPMD2
        LD A,(DE)
        OUT (MPAG),A
        OR A
        JR Z,SMPMD4
SMPMD3  LD A,(HL)
        ADD A,h'80
        LD (HL),A
        INC L
        JP NZ,SMPMD3
        INC H
        BIT 6,H
        JP Z,SMPMD3
SMPMD4
NOCONV  XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        RET

INITPAT LD A,(MTSNGPS)
        LD E,A
        LD D,0
        LD A,(MODTP)
        INC A
        LD HL,h'8000+952
        JR Z,TTT13
        LD HL,h'8000+472
TTT13   ADD HL,DE
        LD A,(RAMPG)
        OUT (MPAG),A
;---patched
        JP Patch11
;---
        LD E,D
        LD D,A
        LD A,(MODTP)
        INC A
        LD HL,h'0000+1084
        JR Z,TTT15
        LD HL,h'0000+600
TTT15   XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        ADD HL,DE
        LD DE,h'5000
        LD BC,h'400
        CALL LDMEM
        XOR A
        OUT (MPAG),A
        RET

;**************************************************************
;* QUANTUM PROCEDURE                                          *
;**************************************************************

QUANTUM LD A,(FXCHNS)
        CPL
        LD C,A
        LD A,(GSCHNS)
        AND C
        LD C,A
        LD IY,CHANS     ;CHANNELS
        LD A,(MTSTAT)
        AND h'C0
        JR NZ,L221
L204    LD A,C
        AND (IY+CHRDR)
        JR Z,L205
        BIT 7,(IY+CHSTAT)
        JR Z,L205
        PUSH BC
        CALL GEN
        POP BC
L205    LD A,IYL
        ADD A,h'40
        LD IYL,A
        JP NC,L204
        JP L221

L221    XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        LD HL,VOLRQTB
        LD A,(QTFREE)
        ADD A,LOW (VOLTAB)
        LD E,A
        LD D,HIGH (VOLTAB)
        LDI
        LDI
        LDI
        LDI
        LD HL,(QTFREE)
        LD B,L
        INC L
        PUSH BC
        PUSH HL
        LD A,(CHANNEL)
        AND h'0F
        LD HL,INTTB
        ADD A,A
        ADD A,L
        LD L,A
        LD A,H
        ADC A,h'00
        LD H,A
        LD C,(HL)
        INC HL
        LD B,(HL)
        LD A,(CHANNEL)
        AND h'0F
        LD HL,INTOFF
        ADD A,L
        LD L,A
        LD A,H
        ADC A,h'00
        LD H,A
        LD A,(QTFREE)
        ADD A,h'60
        ADD A,(HL)
        POP HL
        LD (HL),A
        INC L
        LD (HL),C
        INC L
        LD (HL),B
        POP BC
        INC L
        RES 5,L
        LD (QTFREE),HL
        LD L,B
        LD A,(SGENOFF)
        LD (HL),A
        LD A,(PLAYING)
        OR A
        JP NZ,L224
        LD (QTBUSY),HL
        CALL QTPLAY
L224    LD A,(SGENOFF)
        NEG
        LD C,A
        LD B,0
        LD A,(MTSTAT)
        AND h'C0
        RET NZ
        LD HL,(TCKLEFT)
        OR A
        SBC HL,BC
        JR Z,EFXINT
        LD (TCKLEFT),HL
        RET

EFXINT  LD A,(MODUL)
        OR A
        RET Z
        LD HL,(TICKLEN)
        LD (TCKLEFT),HL
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        LD IY,CHANS
        LD B,h'04
        LD A,(MTCOUNT)
        INC A
        LD (MTCOUNT),A
        LD HL,MTSPEED
        CP (HL)
        JR C,EFXNONT    ;NO NEW NOTE
        XOR A
        LD (MTCOUNT),A
        LD A,(MTPDT2)
        OR A
        JR Z,EFXGTNT    ;GET NEW NOTE
        CALL EFXNONT
        JP EFXSKIP

EFXNONT LD IY,CHANS
        LD B,h'04
EFXNON1 PUSH BC
        LD A,(IY+CHCOM)
        OR (IY+CHPARM)
        JR NZ,EFXNON2
        CALL FXNOP
        JP EFXNON3

EFXNON2 CALL FXCHK_
EFXNON3 LD BC,CHANLEN
        ADD IY,BC
        POP BC
        DJNZ EFXNON1
        RET

EFXNOP  LD L,(IY+CHPERL)	;;not used!
        LD H,(IY+CHPERL)	;;bug!
        CALL EFXCNV
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        RET

EFXGTNT
;LD IY,CHANS
;---patched
        JP Patch3
        DEFB h'46
;---
        XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        LD (CURCHN),A
COMM1   XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        CALL GETROWS
        LD (IY+CHCOM),B
        LD (IY+CHPARM),C
        LD A,E
        OR A
        JR Z,COMM2
        LD (IY+CHINS),E
        PUSH DE
        PUSH BC
        CALL EFXNEWI
        POP BC
        POP DE
COMM2   LD A,D
        CP h'7F
        JP Z,COMM5
        LD A,B
        CP h'03
        JP Z,COMM4
        CP h'05
        JP Z,COMM4
        CP h'0E
        JR NZ,COMM3
        LD A,C
        AND h'F0
        CP h'50
        JR Z,COMM5_
        LD (IY+CHNOTE),D
        LD (IY+CHREAL),D
        CP h'D0
        JR Z,COMM3__
        JP COMM3

COMM5_  LD A,C
        AND h'0F
        SLA A
        LD (IY+CHFINE),A
COMM3   LD (IY+CHNOTE),D
        LD (IY+CHREAL),D
        CALL GETSMP
COMM3__ LD E,(IY+CHNOTE)
        CALL GETPER
        LD (IY+CHPERL),L
        LD (IY+CHPERH),H
        LD E,(IY+CHNOTE)
        CALL GETFRQ
        LD (IY+CHFRQL),L
        LD (IY+CHFRQH),H
        LD A,(IY+CHCOM)
        CP h'09
        JP NZ,COMM5
        LD A,(IY+CHPARM)
        OR A
        JR NZ,FX9_
        LD A,(IY+CHOFFST)
FX9_    LD (IY+CHOFFST),A
        LD H,A
        LD L,h'00
        XOR A
        ADC A,A
        EX DE,HL
        LD L,(IY+CHCURL)
        LD H,(IY+CHCURH)
        LD B,(IY+CHCURP)
        RL H
        SRL B
        RR H
        ADD HL,DE
        ADC A,B
        DEFB h'CB,h'34;SLI H
        RLA
        RRC H
        LD (IY+CHCURL),L
        LD (IY+CHCURH),H
        LD (IY+CHCURP),A
        CP (IY+CHENDP)
        JP C,COMM5
        JR NZ,COMM3_
        LD A,H
        CP (IY+CHENDH)
        JP C,COMM5
        JR NZ,COMM3_
        LD A,L
        CP (IY+CHENDL)
        JP C,COMM5
COMM3_  RES 7,(IY+CHSTAT)
        JP COMM5

COMM4   LD (IY+CHWNT),D
COMM5   XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        CALL FXCHK
COMM6   LD BC,CHANLEN
        ADD IY,BC
        LD A,(CURCHN)
        INC A
        LD (CURCHN),A
        CP h'04
        JP NZ,COMM1
EFXSKIP LD HL,MTPATPS
        INC (HL)
        LD A,(MTPDT)
        OR A
        JR Z,EFXSKP2
        LD (MTPDT2),A
        XOR A
        LD (MTPDT),A
EFXSKP2 LD A,(MTPDT2)
        OR A
        JR Z,EFXSKP3
        DEC A
        LD (MTPDT2),A
        JR Z,EFXSKP3
        DEC (HL)
EFXSKP3 LD A,(MTBRKFL)
        OR A
        JR Z,EFXSKP4
        LD A,(MTBRKPS)
        LD (HL),A
        XOR A
        LD (MTBRKPS),A
        LD (MTBRKFL),A
        JP EFXSKP5

EFXSKP4 LD A,(HL)
        OR A
        JR NZ,EFXSKP5
        LD A,(MTPDT2)
        OR A
        JR Z,EFXSKP6
EFXSKP5 LD A,(MTROWS)
        CP (HL)
        JR NC,EFXSKPX
EFXSKP6 LD A,(MTBRKPS)
        LD (MTPATPS),A
        XOR A
        LD (MTBRKPS),A
        LD (MTJMPFL),A
        LD HL,MTSNGPS
        INC (HL)
        JR Z,EFXSKP7
        LD A,(MTSNGSZ)
        CP (HL)
        JP NC,INITPAT
EFXSKP7 LD A,(MTSNGSZ)
        LD HL,MTSNGLP
        CP (HL)
        LD A,h'00
        JR C,EFXSKP8
        LD A,(HL)
EFXSKP8 LD (MTSNGPS),A

        LD A,6
	DUPL 3,0	;LD (MTSPEED),A
        LD HL,750
        DUPL 3,0	;LD (TICKLEN),HL
        DUPL 3,0	;LD (TCKLEFT),HL
        ;CALL STOPMOD

        XOR A
        LD (MTBRKPS),A
        LD (MTJMPFL),A
        LD (MTBRKFL),A
        LD (MTPDT),A
        LD (MTPDT2),A
        JP INITPAT

EFXSKPX LD A,(MTJMPFL)
        OR A
        JP NZ,EFXSKP6
        RET

GETSMP  SET 7,(IY+CHSTAT)
        LD A,(IY+CHINS)
        OR A
        JR Z,GETSMP2
        DEC A
        ADD A,A
        ADD A,A
        ADD A,A
        ADD A,A
        LD E,A
        LD A,h'54
        ADC A,h'00
        LD D,A
        LD A,(DE)
        LD (IY+CHCURP),A
        INC DE
        LD A,(DE)
        LD (IY+CHCURL),A
        INC DE
        LD A,(DE)
        LD (IY+CHCURH),A
        INC (IY+CHCURL)
        CALL Z,GETSMP3
        INC (IY+CHCURL)
        CALL Z,GETSMP3
        INC DE
        LD A,(DE)
        LD (IY+CHENDP),A
        INC DE
        LD A,(DE)
        LD (IY+CHENDL),A
        INC DE
        LD A,(DE)
        LD (IY+CHENDH),A
        INC DE
        INC DE
        INC DE
        LD A,(DE)
        LD (IY+CHLPBP),A
        INC DE
        LD A,(DE)
        LD (IY+CHLPBL),A
        INC DE
        LD A,(DE)
        LD (IY+CHLPBH),A
        INC DE
        LD A,(DE)
        LD (IY+CHLPEP),A
        INC DE
        LD A,(DE)
        LD (IY+CHLPEL),A
        INC DE
        LD A,(DE)
        LD (IY+CHLPEH),A
        LD (IY+CHCNTL),h'00
        LD (IY+CHCNTH),h'07
        LD A,(IY+CHCURP)
        CP (IY+CHENDP)
        RET C
        JP NZ,GETSMP2
        LD A,(IY+CHCURH)
        CP (IY+CHENDH)
        RET C
        JP NZ,GETSMP2
        LD A,(IY+CHCURL)
        CP (IY+CHENDL)
        RET C
GETSMP2 RES 7,(IY+CHSTAT)
        RET
GETSMP3 INC (IY+CHCURH)
        RET NZ
        LD (IY+CHCURH),h'80
        INC (IY+CHCURP)
        RET

EFXNEWI LD A,(IY+CHINS)
        DEC A
        ADD A,A
        ADD A,A
        ADD A,A
        ADD A,A
        LD E,A
        LD A,h'54
        ADC A,h'00
        LD D,A
        INC DE
        INC DE
        INC DE
        INC DE
        INC DE
        INC DE
        LD A,(DE)
        LD (IY+CHFINE),A
        INC DE
        LD A,(DE)
        CP h'40
        JR C,GETSMP1
        LD A,h'40
GETSMP1 LD (IY+CHVOL),A
        CP (IY+CHMVOL)
        LD (IY+CHMVOL),A
        RET Z
        SET 0,(IY+CHSTAT)
        RET

GETROWS LD A,(MTPATPS)
        AND h'3F
        ADD A,A
        ADD A,A
        LD L,A
        LD H,h'00
        ADD HL,HL
        ADD HL,HL
        LD A,(CURCHN)
        ADD A,A
        ADD A,A
        ADD A,L
        LD L,A
        LD A,H
        ADC A,h'50
        LD H,A
        LD A,(HL)
        AND h'10
        PUSH AF
        LD A,(HL)
        AND h'0F
        LD D,A
        INC HL
        LD E,(HL)
        OR E
        LD A,h'7F
        JR Z,GETRWS2
        PUSH HL
        CALL NOTEID
        POP HL
GETRWS2 INC HL
        POP BC
        LD D,A
        LD A,(HL)
        AND h'F0
        RRCA
        RRCA
        RRCA
        RRCA
        OR B
        LD E,A
        LD A,(HL)
        AND h'0F
        LD B,A
        INC HL
        LD C,(HL)
        RET

;***********************************************************
;* INTERRUPT HANDLING PROCEDURES                           *
;***********************************************************

        ALIGN256

INTZ    RET

INT0    EX AF,AF'
        INC A
        JR Z,INT0_
        EX AF,AF'
        EI
        RET
        DUPL 11,0
        RET

INT0_   PUSH DE
        JP QTDONE

INT1    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC E
        JR Z,INT1_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET
        DUPL 4,0
        RET

        PUSH DE
INT1_   JP QTDONE

INT2    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        LD A,(DE)
        INC E
        JR Z,INT2_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        DUPL 2,0
        RET

        PUSH DE
INT2_   JP QTDONE

INT3    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        INC D
        LD A,(DE)
        INC E
        JR Z,INT3_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        DUPL 1,0
        RET

        PUSH DE
INT3_   JP QTDONE

INT4    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        LD A,(DE)
        INC D
        LD A,(DE)
        INC E
        JR Z,INT4_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        RET

        PUSH DE
INT4_   JP QTDONE

INT5    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        INC D
        INC D
        LD A,(DE)
        INC E
        JR Z,INT5_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        RET

        PUSH DE
INT5_   JP QTDONE

INT6    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        LD A,(DE)
        INC D
        INC D
        LD A,(DE)
        INC E
        JR Z,INT6_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        PUSH DE
INT6_   JP QTDONE

INT7    EX AF,AF'
        PUSH DE
        LD E,A
        LD D,IXH
        LD A,(DE)
        INC D
        INC D
        LD A,(DE)
        INC D
        LD A,(DE)
        INC E
        JR Z,INT7_
        LD A,E
        POP DE
        EX AF,AF'
        EI
        RET

        PUSH DE
INT7_   JP QTDONE

QTFAULT LD DE,(QTBUSY)
        LD (DE),A
        LD (PLAYING),A
        POP DE
        EX AF,AF'
        RET

INT_IM1 IM 1
        EI
        EX DE,HL
        LD HL,(QTBUSY)
        LD (HL),A
        LD A,L
        ADD A,h'04
        AND h'1C
        LD L,A
        LD (QTBUSY),HL
        SET 5,L
        LD A,(HL)
        OUT (VOL1),A
        INC L
        LD A,(HL)
        OUT (VOL2),A
        INC L
        LD A,(HL)
        OUT (VOL3),A
        INC L
        LD A,(HL)
        OUT (VOL4),A
        POP AF
        POP HL
        EX DE,HL
        RET

QTDONE  LD A,(QTBUSY)
        ADD A,h'04
        AND h'1C
        LD E,A
        LD D,HIGH (QTMAP)
        LD A,(DE)
        OR A
        JR Z,QTFAULT
        EX AF,AF'
        PUSH AF
        INC E
        LD A,(DE)
        LD IXH,A
        INC E
        LD A,(DE)
        OR A
        JR Z,INT_IM1
        IM 2
        EX DE,HL
        LD HL,INTAREA+h'18
        CP (HL)
        JR Z,INT_I1
        LD (HL),A
        LD HL,h'1518
        LD (INTAREA),HL
        EI
        DEC A
        JR Z,INT_I0
        ADD A,h'03
        LD L,A
        LD H,HIGH (INT0)
        PUSH DE
        PUSH BC
        LD DE,INTAREA+2
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LDI
        LD HL,h'D508
        LD (INTAREA),HL
        POP BC
        POP DE
        LD HL,(QTBUSY)
        LD (HL),h'00
        LD A,L
        ADD A,h'04
        AND h'1C
        LD L,A
        LD (QTBUSY),HL
        SET 5,L
        LD A,(HL)
        OUT (VOL1),A
        INC L
        LD A,(HL)
        OUT (VOL2),A
        INC L
        LD A,(HL)
        OUT (VOL3),A
        INC L
        LD A,(HL)
        OUT (VOL4),A
        POP AF
        POP HL
        EX DE,HL
        RET

INT_I1  EI
        LD A,h'04
        LD HL,(QTBUSY)
        LD (HL),h'00
        ADD A,L
        AND h'1C
        LD L,A
        LD (QTBUSY),HL
        SET 5,L
        LD A,(HL)
        OUT (VOL1),A
        INC L
        LD A,(HL)
        OUT (VOL2),A
        INC L
        LD A,(HL)
        OUT (VOL3),A
        INC L
        LD A,(HL)
        OUT (VOL4),A
        POP AF
        POP HL
        EX DE,HL
        RET

INT_I0  LD HL,INT0+2
        PUSH DE
        PUSH BC
        LD DE,INTAREA+2
        LDI
        LDI
        LDI
        LDI
        LDI
        LD HL,h'3C08
        LD (INTAREA),HL
        POP BC
        POP DE
        LD HL,(QTBUSY)
        LD (HL),A
        LD A,L
        ADD A,h'04
        AND h'1C
        LD L,A
        LD (QTBUSY),HL
        SET 5,L
        LD A,(HL)
        OUT (VOL1),A
        INC L
        LD A,(HL)
        OUT (VOL2),A
        INC L
        LD A,(HL)
        OUT (VOL3),A
        INC L
        LD A,(HL)
        OUT (VOL4),A
        POP AF
        POP HL
        EX DE,HL
        RET

QTPLAY  DI
        LD A,h'FF
        LD (PLAYING),A
        LD HL,(QTBUSY)
        LD A,(HL)
        EX AF,AF'
        INC L
        LD A,(HL)
        LD IXH,A
        INC L
        LD A,(HL)
        IM 1
        OR A
        JR Z,QTPLAY_
        IM 2
        LD HL,INTAREA+h'18
        CP (HL)
        JR Z,QTPLAY_
        LD (HL),A
        LD L,A
        LD H,HIGH (INT0)
        LD DE,INTAREA
        LD BC,h'0012
        LDIR
QTPLAY_ LD HL,(QTBUSY)
        SET 5,L
        LD A,(HL)
        OUT (VOL1),A
        INC L
        LD A,(HL)
        OUT (VOL2),A
        INC L
        LD A,(HL)
        OUT (VOL3),A
        INC L
        LD A,(HL)
        OUT (VOL4),A
        EI
        RET

WTCM    IN A,(ZXSTAT)
        RRCA
        JR NC,WTCM
        IN A,(ZXCMD)
        CP h'12
        JR Z,CM12
        CP h'18
        JR Z,CM18
        CP h'1A
        JR Z,CM1A
        CP h'1B
        JR Z,CM1B
        CP h'20
        JR Z,CM20
        OUT (CLRCBIT),A
        JP WTCM

CM12    IN A,(ZXDATRD)
        OUT (CLRCBIT),A
        OUT (MPAG),A
        JP WTCM

CM18    IN A,(ZXDATRD)
        LD E,A
        OUT (CLRCBIT),A
CM18_1  IN A,(ZXSTAT)
        OR A
        JP P,CM18_1
        IN A,(ZXDATRD)
        LD D,A
        JP WTCM

CM1A    LD A,(DE)
        OUT (ZXDATWR),A
        OUT (CLRCBIT),A
        JP WTCM

CM1B    INC DE
        OUT (CLRCBIT),A
        JP WTCM

CM20    OUT (CLRCBIT),A
        RET

GEN     LD A,(QTFREE)
        ADD A,HIGH (DAC0)
        ADD A,(IY+CHRDN)
        LD D,A
        LD A,(SGENOFF)
        LD E,A
        LD A,(CHANNEL)
        OR (IY+CHRDR)
        LD (CHANNEL),A
GEN_    LD L,(IY+CHCURL)
        LD H,(IY+CHCURH)
        LD B,(IY+CHCNTL)
GENLP   EXX
        LD H,HIGH (RAMPG)
        LD L,(IY+CHCURP)
        LD D,(IY+CHCNTH)
        LD E,(IY+CHFRQH)
        LD B,(HL)
        LD A,B
        LD (CPAGE),A
        OUT (MPAG),A
        LD A,L
        EXX
        CP (IY+CHENDP)
        JP C,GENTP
        PUSH DE
        EX DE,HL
        LD L,(IY+CHENDL)
        LD H,(IY+CHENDH)
        DEC HL
        SBC HL,DE
        INC HL
        EX DE,HL
        LD IXL,E
        LD A,D
        POP DE
        JR C,GENCHK
        OR A
        JR Z,GENENT
        LD IXL,h'FF
        JP GENENT

GENCHK  RES 7,(IY+CHSTAT)
        LD A,(IY+CHLPBP)
        INC A
        JP Z,GENCHK2
        DEC A
        LD (IY+CHCURP),A
        LD L,(IY+CHLPBL)
        LD H,(IY+CHLPBH)
        LD A,(IY+CHLPEP)
        LD (IY+CHENDP),A
        LD A,(IY+CHLPEL)
        LD (IY+CHENDL),A
        LD A,(IY+CHLPEH)
        LD (IY+CHENDH),A
        SET 7,(IY+CHSTAT)
        JP GENLP

GENCHK2 LD (IY+CHREAL),h'7F
        BIT 6,(IY+CHSTAT)
        JP Z,GENZERO
        PUSH IY
        PUSH DE
        LD IY,CHANS
        LD B,h'08
        LD DE,CHANLEN
GENCHK3 SET 0,(IY+CHSTAT)
        ADD IY,DE
        DJNZ GENCHK3
        POP DE
        POP IY
        JP GENZERO

GENTP   LD IXL,h'FF
        LD A,H
        INC A
        JP M,GENENT
        OR L
        JR Z,GENENT
        NEG
        LD IXL,A
GENENT  LD C,(IY+CHFRQL)
        LD A,(IY+CHOLDV)
        PUSH IY
        CALL h'2030
        POP  IY
        LD (IY+CHOLDV),A
        LD (IY+CHCNTH),C
        LD A,H
        OR A
        JP M,GENJ2
        LD H,h'80
        INC (IY+CHCURP)
GENJ2   LD A,E
        OR A
        JP Z,GENRET
        BIT 7,(IY+CHSTAT)
        JP NZ,GENLP
        JP GENZERO

GENRET  LD (IY+CHCURL),L
        LD (IY+CHCURH),H
        LD (IY+CHCNTL),B
        JP  GENEXT

GENZERO LD A,E
        CP h'FF
        JR NC,GENZENT
        LD B,(IY+CHOLDV)
        LD C,h'80
        CP h'FD
        JR NC,GENZ_1
        CP h'F9
        JR NC,GENZ_2
        LD A,C
        ADD A,B
        RRA
        LD H,A
        ADD A,B
        RRA
        LD L,A
        ADD A,B
        RRA
        LD (DE),A
        INC E
        LD A,L
        LD (DE),A
        INC E
        ADD A,H
        RRA
        LD (DE),A
        INC E
        LD A,H
        LD (DE),A
        INC E
        ADD A,C
        RRA
        LD L,A
        ADD A,H
        RRA
        LD (DE),A
        INC E
        LD A,L
        LD (DE),A
        INC E
        ADD A,C
        RRA
        LD (DE),A
        INC E
        JP GENZENT

GENZ_2  LD A,C
        ADD A,B
        RRA
        LD H,A
        ADD A,B
        RRA
        LD (DE),A
        INC E
        LD A,H
        LD (DE),A
        INC E
        ADD A,C
        RRA
        LD (DE),A
        INC E
        JP GENZENT

GENZ_1  LD A,B
        ADD A,C
        RRA
        LD (DE),A
        INC E
GENZENT LD A,h'80
        BIT 0,E
        JR Z,GENZJP1
        LD (DE),A
        INC E
        JR Z,GENZEXT
GENZJP1 BIT 1,E
        JR Z,GENZJP2
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        JR Z,GENZEXT
GENZJP2 BIT 2,E
        JR Z,GENZLP
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        JR Z,GENZEXT
GENZLP  LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        JP NZ,GENZLP
GENZEXT LD A,(QTFREE)
        ADD A,HIGH (DAC0)
        ADD A,(IY+CHRDN)
        LD D,A
        LD E,h'FF
        LD A,h'80
        LD (DE),A
GENEXT  XOR A
        LD (CPAGE),A
        OUT (MPAG),A
        BIT 0,(IY+CHSTAT)
        RET Z
        JP CALCVOL


        ALIGN256
#include "tables_l.asm"


Free1
;---patched
Patch11
	LD H,(HL)
        LD L,D
        ADD HL,HL
        ADD HL,HL
	JR NC,$+3
	INC D
        LD A,(MODTP)
        INC A
        LD BC,h'0000+1084
        JR Z,TTT15x
        LD BC,h'0000+600
TTT15x  ADD HL,BC
	JR NC,$+3
	INC D
	XOR A
        LD (CPAGE),A
        OUT (MPAG),A
	LD A,D
        LD DE,h'5000
        LD BC,h'400
        CALL LDMEM
        XOR A
        OUT (h'00),A
        RET

; new cmd h'6A - Set player mode
COM6A	LD A,(PlMode)	;command
	OUT (ZXDATWR),A
	IN A,(ZXDATRD)
	OUT (CLRCBIT),A
	LD (PlMode),A
	RET

Patch2x	LD A,(PlMode)
	OR A
	RET NZ
	LD HL,MTSTAT
        SET 7,(HL)
        RET

; last note speed
Patch3	LD A,(MTSNGPS)
		OR A
		JR NZ,Patch3e	;1st pattern
	LD A,(MTPATPS)
		OR A
		JR NZ,Patch3e	;1st row
        LD A,6		;init speed at start of MOD
        LD (MTSPEED),A
        LD HL,750
        LD (TICKLEN),HL
        LD (TCKLEFT),HL
Patch3e	LD IY,CHANS
	JP EFXGTNT+4

; initial note
Patch4	LD (IY+CHCNTL),h'00
	LD (IY+CHREAL),h'7F
	RET

;MOD relooper
; new cmd h'6B - Set minimal loop length (turn on relooper)

COM6B	IN A,(ZXDATRD)
		LD L,A
	OUT (CLRCBIT),A
	IN A,(ZXSTAT)
	AND h'81
	JR Z,$-4
	JP P,Patch5s
	IN A,(ZXDATRD)
	LD H,A
	LD DE,16385
	OR A
	SBC HL,DE
	ADD HL,DE
	JR C,Patch5s+3
Patch5s	LD HL,h'0200
	LD (MODLLEN),HL
	RET

;reconstruct MOD after load
Patch5x	CALL PLAYMD		;init MOD
	LD HL,(MODLLEN)
	LD A,H
	OR L
	RET Z	;relooper off
	LD A,(MODTP)
	OR A
	LD A,31
	LD HL,1084
	JR NZ,$+7
	LD A,15
	LD HL,600
	LD (MODSMPS),A
	LD (MODPTST),HL
	CALL CHIP
    JP PLAYMD		;init MOD again

;-----(c)Evgeny Muchkin

;MODSMPS	equ h'5000
;MODPTST	equ h'5001
;ChipSP_	equ h'5005
;CHIP246 equ h'5007
;TOcip_	equ h'5009
;CHIPLN  equ h'5010	; НА4АЛО СЕМПЛОВ (pointer)
;CHIPPP  equ h'5013	; ДЛИНА МОДУЛЯ
;CIP1    equ h'5016	; ОТКУДА ПЕРЕНОСИТЬ
;CIP2    equ h'5019	; КУДА ПЕРЕНОСИТЬ
;CIP3    equ h'501c	; КОНЕЦ БЛОКА

CHIP    DI
        LD A,(RAMPG)
        OUT (MPAG),A
        LD DE,(MODPTST)	;patts data!
        LD A,(PATTS)
        LD L,A
        LD H,B
        ADD HL,HL
        ADD HL,HL
        LD A,H
        LD H,L
        LD L,B
        ADD HL,DE
        ADC A,B
        LD (CHIPLN),HL
        LD (CHIPLN+2),A
        LD (ChipSP_),SP
        LD HL,CHIPLN
        LD DE,CHIPPP
        PUSH DE
        LDI
        LDI
        LDI
        POP IY
        LD A,(MODSMPS)
        LD B,A		;smps!
        LD DE,30
        LD IX,h'8014
ChIp    LD H,(IX+22)	;len
        LD L,(IX+23)
        CALL TOCip
        ADD IX,DE
        DJNZ ChIp
        LD IX,h'802A
        LD A,(MODSMPS)
        LD B,A		;smps!
CHIP1   LD A,(RAMPG)
        OUT (MPAG),A
        LD H,(IX+6)     ;loop len
        LD L,(IX+7)
        LD (CHIP246),HL
        LD A,(IX+0)	;len
        OR (IX+1)
        JP Z,CHIP2	;skip if no smp
        LD DE,2
        CALL CP_DDE
        JP C,CHIP2	;skip if loop len <2
LUP_LEN LD DE,(MODLLEN)
        CALL CP_DDE
        JP NC,CHIP2	;skip if loop len>=LUP_LEN
        PUSH BC
        LD B,H
        LD C,L
        EXX
        LD BC,0		;reloop counter
CHIP3   EXX
        ADD HL,BC
        CALL CP_DDE
        EXX
        INC BC
        JR C,CHIP3
        PUSH BC
        EXX
;!!!!!!!!!!!!!!!!!!!!!!!!!!
        PUSH HL		;new loop len
        LD B,(IX+6)	;loop len
        LD C,(IX+7)
        AND A
        SBC HL,BC
        LD DE,CHIPPP
        LD (TOcip_),DE
        LD IY,CIP1
        CALL TOCIP
        LD DE,CHIPLN
        LD (TOcip_),DE
        LD B,3		;check if free mem
        LD DE,CIP1+2
        LD HL,RAMTOP+2
ChipLP  LD A,(DE)
        CP (HL)
        DEC HL
        DEC DE
        JR C,ChipOK
        JP NZ,ChipSP
        DJNZ ChipLP
ChipOK  POP HL
        EX DE,HL	;DE=new loop len
        LD H,(IX+0)	;len
        LD L,(IX+1)
        LD B,(IX+6)	;loop len
        LD C,(IX+7)
        AND A
        SBC HL,BC
        ADD HL,DE
        LD (IX+0),H	;new smp len
        LD (IX+1),L
        LD (IX+6),D	;new loop len
        LD (IX+7),E
        LD IY,CIP1
        LD H,(IX+4)	;loop start
        LD L,(IX+5)
        PUSH HL
        PUSH HL
        PUSH HL
        ADD HL,BC
        CALL TOCIP
        LD IY,CIP2
        POP HL
        ADD HL,DE
        CALL TOCIP
        LD HL,CHIPPP
        LD DE,CIP3
        LDI
        LDI
        LDI
        CALL DIRER
        LD IY,CIP1
        POP HL
        CALL TOCIP
        POP HL
CHIP4   LD DE,(CHIP246)	;orig loop len
        ADD HL,DE
        LD IY,CIP2
        CALL TOCIP
        LD HL,CIP2
        LD DE,CIP3
        LDI
        LDI
        LDI
        POP BC
CHIP5   PUSH BC
        CALL DIRER
CHIP6   LD HL,(CHIP246)	;orig loop len
        LD IY,CIP2
        CALL TOCip
        POP BC
        DEC BC
        LD A,B
        OR C
        JR NZ,CHIP5
        POP BC
CHIP2   LD DE,(CHIP246)	;orig loop len
        LD A,(RAMPG)
        OUT (MPAG),A
        LD H,(IX+6)	;new loop len
        LD L,(IX+7)
        AND A
        SBC HL,DE
        LD IY,CHIPPP	;corr mod len
        CALL TOCip
        LD H,(IX+0)
        LD L,(IX+1)
        LD IY,CHIPLN	;add pointer
        CALL TOCip
        LD DE,30
        ADD IX,DE
        DEC B
        JP NZ,CHIP1
ChipSP  LD SP,(ChipSP_)
        EI
	RET

DIRER   LD IY,CIP1
        LD L,(IY+3)
        LD H,(IY+4)
        LD B,(IY+5)
        EXX
        LD L,(IY+0)
        LD H,(IY+1)
        LD B,(IY+2)
        LD E,(IY+6)
        LD D,(IY+7)
        LD C,(IY+8)
        PUSH IX
        CALL RESI10_
        POP IX
        RET

TOCIP   PUSH HL
	PUSH DE
        PUSH IY
        POP DE
TOcip   LD HL,(TOcip_)	;CHIPLN
        LDI
        LDI
        LDI
        POP DE
        POP HL
TOCip   CALL ADD_IY
ADD_IY  LD A,(IY+0)
        ADD A,L
        LD (IY+0),A
        LD A,(IY+1)
        ADC A,H
        LD (IY+1),A
        LD A,(IY+2)
        ADC A,0
        LD (IY+2),A
        RET

CP_DDE  PUSH HL
        AND A
        SBC HL,DE
        POP HL
        RET

;RESID10 ; MOVE BLOCK IN GS
;          BHL - FROM
;          CDE - END
;         'BHL - TO

RESI10_	SUB A
		OUT (MPAG),A
		LD (SYSTEM),A
		LD A,B
		PUSH HL
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
		EXX
		JP NZ,MOVL
		JP MOVH
;-----

;store settings
Patch5i1	LD A,(PlMode)
		LD C,A
		LD DE,(MODLLEN)
		LD A,(ERRCODE)
		RET

;restore settings
Patch5i2	LD (ERRCODE),A
		LD A,C
		LD (PlMode),A
		LD (MODLLEN),DE
		RET

;clear vars after full reset!
Patch5i3	XOR A
		LD H,A
		LD L,A
		LD (PlMode),A
		LD (MODLLEN),HL
		JP INITVAR

CP_END_MOD
	;LD HL,MTSNGPS
	;INC (HL)
	;CP (HL)
	;CALL C,STOPMOD
	;LD (MTSNGPS),A
	;RET

;	display $
;---
;emptyobl1

;	ORG GSRomBaseL+h'1D00

;	IN A,(ZXDATRD)
;	OUT (CLRCBIT),A
;	LD A,h'7F
;	OUT (ZXDATWR),A
;	JP COMINT_

;WDY	IN A,(ZXSTAT)
;	RLA
;	JR NC,$-3
;	RET

;WDN	IN A,(ZXSTAT)
;	RLA
;	JR C,$-3
;	RET

        ORG GSRomBaseL+h'2000
#include "sgen.asm"

        ORG GSRomBaseL+h'3E00
#include "divtab3.asm"				;	h'10*h'20=h'200

 	    ORG GSRomBaseH+h'2000
#include "gsfrqtb.asm"

        ORG GSRomBaseH
#include "high_ngs.asm"

    end
