
SGENTBE DEFW S0,S1,S2,S3,S4,S5,S6,S7,S8

SGENTBF DEFW SGEN1,SGEN2,SGEN3,SGEN4,SGEN5,SGEN6,SGEN7,SGEN8,SGEN9

        DUPL 12,0

SGEN	EXX
        INC D
        DEC D
        JP Z,SGEN_
        LD C,A
        LD A,D
        DEC A
        CP h'09
        JP NC,SGEN__
        ADD A,A
        ADD A, LOW (SGENTBF)
        LD L,A
        LD H, HIGH (SGENTBF)
        LD A, (HL)
        INC L
        LD H, (HL)
        LD L, A
        LD A, C
        JP (HL)

SGEN1   EXX
        ADD A, (HL)
        RRA
        LD (DE), A
        INC E
        EXX
        JP SGEN_

SGEN2   EXX
        SUB (HL)
        EXX
        LD H, HIGH (DIVTAB3)
        JP NC, SGEN2_2
        INC H
SGEN2_2 LD L, A
        LD A, (HL)
        EXX
        ADD A, (HL)
        LD (DE), A
        INC E
        ADD A, (HL)
        RRA
        LD (DE), A
        INC E
        EXX
        JP SGEN_

SGEN3   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN4   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN5   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN6   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN7   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        LD H,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        EXX
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        EXX
        LD H,A
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN8   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        LD H,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        EXX
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        EXX
        LD H,A
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN9   EXX
        ADD A,(HL)
        RRA
        EXX
        LD L,A
        ADD A,C
        RRA
        LD H,A
        ADD A,C
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        EXX
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,L
        EXX
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        EXX
        LD H,A
        ADD A,L
        RRA
        EXX
        LD (DE),A
        INC E
        EXX
        LD A,H
        EXX
        LD (DE),A
        INC E
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        EXX
        JP SGEN_

SGEN__  JP SGEN_

SGEN_   LD A,E
        CP h'09
        JR NC,S9
        ADD A,A
        LD L,A
        LD H,HIGH (SGENTBE)
        LD A,(HL)
        INC L
        LD H,(HL)
        LD L,A
        JP (HL)

S9      EXX
        LD C,h'FF
        EXX
        LD D,h'08
        JP S8

S0      EXX
        LD C,h'00
        EXX
        LD D,h'01
        JP S1

S3      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S3_
S_RET   LD IYL,E
        LD E,D
        LD D,IYL
        PUSH DE
        EXX
        POP BC
        RET

S4      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S4_
        JP S_RET

S5      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S5_
        JP S_RET

S6      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S6_
        JP S_RET

S7      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S7_
        JP S_RET

S8      EXX
        PUSH BC
        EXX
        POP HL
        LD B,E
        LD E,H
        LD C,L
        CALL S8_
        JP S_RET

;INCLUDE "SGEN1_L.asm"
S1      EXX
        SLA C
        JR C,S1_6
        LD A,IXL
        INC A
        JR Z,S1_2
        DEC A
        ADD A,E
        JR Z,S1_4
        JR C,S1_2
        BIT 7,C
        JR Z,S1_4
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S1_4
        JR NC,S1_4
S1_2    DEFB h'CB,h'30;SLI B
        JR NC,S1_3
        LD A,E
        AND h'03
        JP Z,S11L0_1
        DEC A
        JP Z,S11L1_1
        DEC A
        JP Z,S11L2_1
        JP S11L3
S1_3    LD A,E
        AND h'03
        JP Z,S11H0_1
        DEC A
        JP Z,S11H1_1
        DEC A
        JP Z,S11H2_1
        JP S11H3
S1_4    DEFB h'CB,h'30;SLI B
        JR NC,S1_5
        LD A,E
        AND h'03
        JP Z,S12L0_1
        DEC A
        JP Z,S12L1_1
        DEC A
        JP Z,S12L2_1
        JP S12L3
S1_5    LD A,E
        AND h'03
        JP Z,S12H0_1
        DEC A
        JP Z,S12H1_1
        DEC A
        JP Z,S12H2_1
        JP S12H3

S1_6    LD A,IXL
        INC A
        JR Z,S1_7
        DEC A
        SRL A
        ADD A,IXL
        JR Z,S1_9
        JR C,S1_7
        ADD A,E
        JR C,S1_7
        BIT 7,C
        JR Z,S1_9
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S1_9
        JR NC,S1_9
S1_7    DEFB h'CB,h'30;SLI B
        JR C,S1_8
        LD A,E
        AND h'03
        JP Z,S13L0
        DEC A
        JP Z,S13L1
        DEC A
        JP Z,S13L2
        JP S13L3
S1_8    LD A,E
        AND h'03
        JP Z,S13H0
        DEC A
        JP Z,S13H1
        DEC A
        JP Z,S13H2
        JP S13H3
S1_9    DEFB h'CB,h'30;SLI B
        JR C,S1_A
        LD A,E
        AND h'03
        JP Z,S14L0
        DEC A
        JP Z,S14L1
        DEC A
        JP Z,S14L2
        JP S14L3
S1_A    LD A,E
        AND h'03
        JP Z,S14H0
        DEC A
        JP Z,S14H1
        DEC A
        JP Z,S14H2
        JP S14H3

S11M0   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
S11L2_1 LD A,B
S11L2_2 LDI
        INC C
        ADD A,C
        LD B,A
        JP NC,S11L3
        ADD A,C
        JP C,S11M3
S11G3   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S11R1
        LDI
        INC C
S11H1_1 LD A,B
S11H1_2 LDI
        INC C
        ADD A,C
        JP NC,S11H2_2
        LDI
        INC C
        ADD A,C
        LD B,A
        JP NC,S11L3
        ADD A,C
        JP C,S11M3
        JP S11G3

S11R1   LD IYL,A
        LD A,B
        SUB C
        LD B,A
        SRL B
        LD C,h'00
        LD A,IYL
        RET

S11M1   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
S11L3   LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S11R2
        LD A,B
        ADD A,C
        JP NC,S11L0_2
        ADD A,C
        JR C,S11M0
S11G0   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
S11H2_1 LD A,B
S11H2_2 LDI
        INC C
        ADD A,C
        LD B,A
        JP NC,S11H3
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S11R2
        LD A,B
        ADD A,C
        JP NC,S11L0_2
        ADD A,C
        JP C,S11M0
        JP S11G0

S11R2   LD IYL,A
        LD A,B
        ADD A,C
        LD B,A
        JR NC,S11R2_2
        LD C,h'01
        SRL B
        LD A,IYL
        RET
S11R2_2 LD C,h'00
        RRC B
        LD A,IYL
        RET

S11M2   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S11R3
S11L0_1 LD A,B
S11L0_2 LDI
        INC C
        ADD A,C
        JP NC,S11L1_2
        ADD A,C
        JR C,S11M1
S11G1   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
S11H3   LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S11R4
        LD A,B
        ADD A,C
        JP NC,S11H0_2
        LDI
        INC C
        ADD A,C
        JP NC,S11L1_2
        ADD A,C
        JP C,S11M1
        JP S11G1

S11R3   LD C,h'00
        RRC B
        RET

S11R4   LD IYL,A
        LD A,B
        ADD A,C
        LD B,A
        JR NC,S11R4_2
        LD C,h'00
        RRC B
        LD A,IYL
        RET
S11R4_2 LD C,h'00
        SRL B
        LD A,IYL
        RET

S11R5   LD IYL,A
        LD A,B
        SUB C
        LD B,A
        LD C,h'00
        SRL B
        LD A,IYL
        RET

S11M3   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S11R5
        LDI
        INC C
S11L1_1 LD A,B
S11L1_2 LDI
        INC C
        ADD A,C
        JP NC,S11L2_2
        ADD A,C
        JR C,S11M2
S11G2   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S11R6
S11H0_1 LD A,B
S11H0_2 LDI
        INC C
        ADD A,C
        JP NC,S11H1_2
        LDI
        INC C
        ADD A,C
        JP NC,S11L2_2
        ADD A,C
        JP C,S11M2
        JP S11G2

S11R6   LD C,h'00
        SRL B
        RET

S12M0   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
        DEC IXL
        JR Z,S12R3_3
S12L2_1 LD A,B
S12L2_2 LDI
        INC C
        DEC IXL
        JR Z,S12R2_5
        ADD A,C
        LD B,A
        JP NC,S12L3
        ADD A,C
        JP C,S12M3
S12G3   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S12R1
        LDI
        INC C
        DEC IXL
        JR Z,S12R6_3
S12H1_1 LD A,B
S12H1_2 LDI
        INC C
        DEC IXL
        JR Z,S12R4_4
        ADD A,C
        JP NC,S12H2_2
        LDI
        INC C
        DEC IXL
        JR Z,S12R2_5
        ADD A,C
        LD B,A
        JP NC,S12L3
        ADD A,C
        JP C,S12M3
        JP S12G3

S12R2_5 JR S12R2_3
S12R6_3 JP S12R6_2

S12R1   LD IYL,A
        LD A,B
        SUB C
        LD B,A
        SRL B
        LD C,h'00
        LD A,IYL
        RET

S12R3_3 DEC HL
        LD A,(HL)
        INC HL
        LD C,h'00
        RRC B
        RET

S12R4_4 JP S12R4_3

S12M1   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
        DEC IXL
        JR Z,S12R3_3
S12L3   LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S12R2
        DEC IXL
        JR Z,S12R2
        LD A,B
        ADD A,C
        JP NC,S12L0_2
        ADD A,C
        JP C,S12M0
S12G0   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
        DEC IXL
        JR Z,S12R6_3
S12H2_1 LD A,B
S12H2_2 LDI
        INC C
        DEC IXL
        JR Z,S12R4_4
        ADD A,C
        LD B,A
        JP NC,S12H3
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S12R2
        DEC IXL
        JR Z,S12R2
        LD A,B
        ADD A,C
        JP NC,S12L0_2
        ADD A,C
        JP C,S12M0
        JP S12G0

S12R2_3 DEC HL
        LD A,(HL)
        INC HL
S12R2   LD IYL,A
        LD A,B
        ADD A,C
        LD B,A
        JR NC,S12R2_2
        LD C,h'01
        SRL B
        LD A,IYL
        RET
S12R2_2 LD C,h'00
        RRC B
        LD A,IYL
        RET

S12M2   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S12R3
        DEC IXL
        JR Z,S12R3
S12L0_1 LD A,B
S12L0_2 LDI
        INC C
        DEC IXL
        JR Z,S12R2_3
        ADD A,C
        JP NC,S12L1_2
        ADD A,C
        JP C,S12M1
S12G1   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LDI
        INC C
        DEC IXL
        JR Z,S12R6_5
S12H3   LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S12R4
        DEC IXL
        JR Z,S12R4
        LD A,B
        ADD A,C
        JP NC,S12H0_2
        LDI
        INC C
        DEC IXL
        JR Z,S12R2_3
        ADD A,C
        JP NC,S12L1_2
        ADD A,C
        JP C,S12M1
        JP S12G1

S12R6_5 JP S12R6_2

S12R3_2 DEC HL
        LD A,(HL)
        INC HL
S12R3   LD C,h'00
        RRC B
        RET

S12R4_3 DEC HL
        LD A,(HL)
        INC HL
S12R4   LD IYL,A
        LD A,B
        ADD A,C
        LD B,A
        JR NC,S12R4_2
        LD C,h'00
        RRC B
        LD A,IYL
        RET
S12R4_2 LD C,h'00
        SRL B
        LD A,IYL
        RET

S12R5   LD IYL,A
        LD A,B
        SUB C
        LD B,A
        LD C,h'00
        SRL B
        LD A,IYL
        RET

S12M3   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S12R5
        LDI
        INC C
        DEC IXL
        JR Z,S12R3_2
S12L1_1 LD A,B
S12L1_2 LDI
        INC C
        DEC IXL
        JR Z,S12R2_4
        ADD A,C
        JP NC,S12L2_2
        ADD A,C
        JP C,S12M2
S12G2   LD B,A
        DEC HL
        LD A,(HL)
        INC HL
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S12R6
        DEC IXL
        JR Z,S12R6
S12H0_1 LD A,B
S12H0_2 LDI
        INC C
        DEC IXL
        JR Z,S12R4_3
        ADD A,C
        JP NC,S12H1_2
        LDI
        INC C
        DEC IXL
        JR Z,S12R2_4
        ADD A,C
        JP NC,S12L2_2
        ADD A,C
        JP C,S12M2
        JP S12G2

S12R6_2 DEC HL
        LD A,(HL)
        INC HL
S12R6   LD C,h'00
        SRL B
        RET

S12R2_4 JP S12R2_3

S13R1   JR NC,S13R1_2
        SRL B
        LD C,h'01
        RET
S13R1_2 RRC B
        LD C,h'00
        RET
S13R2   SRL B
        LD C,h'00
        RET

S13J0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13J2
S13K2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S13R1
        JP C,S13K0
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S13K1
S13J1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13J3
S13K3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S13R2
S13L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13K1
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S13K2
S13J2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S13R3
        JP C,S13J0
S13K0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13K2
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S13K3
S13J3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S13R4
S13H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13J1
S13K1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S13L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S13K3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S13R5
        JP NC,S13K0
        JP S13J0

S13R3   LD C,h'01
        JR NC,S13R3_2
        RRC B
        RET

S13R3_2 SRL B
        RET

S13R4   RRC B
        LD C,h'00
        RET

S13R5   LD C,h'01
        JR NC,S13R5_2
        RRC B
        RET

S13R5_2 SRL B
        RET

S14R5_3 JP S14R5

S14R1   JR NC,S14R1_2
        SRL B
        LD C,h'01
        RET

S14R1_2 RRC B
        LD C,h'00
        RET

S14R2   SRL B
        LD C,h'00
        RET

S14J0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5_3
        JP C,S14J2
S14K2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S14R1
        DEC IXL
        JR Z,S14R1
        JP C,S14K0
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5_3
        JP NC,S14K1
S14J1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5_3
        JP C,S14J3
S14K3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S14R2
S14L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R1
        JP C,S14K1
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5
        JP NC,S14K2
S14J2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S14R5
        DEC IXL
        JR Z,S14R5
        JP C,S14J0
S14K0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R1_3
        JP C,S14K2
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5
        JP NC,S14K3
S14J3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S14R4
S14H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R5
        JP C,S14J1
S14K1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S14L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S14R1_3
        JP C,S14K3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S14R5
        DEC IXL
        JR Z,S14R5
        JP NC,S14K0
        JP S14J0

S14R5   LD C,h'01
        JR NC,S14R5_2
        RRC B
        RET

S14R5_2 SRL B
        RET

S14R4   RRC B
        LD C,h'00
        RET

S14R1_3 JP S14R1

;INCLUDE "SGEN2_L.asm"
S2      LD H,HIGH (DIVTAB3)
        LD D,H
        INC D
        EXX
        SLA C
        JR C,S2_6
        LD A,IXL
        ADD A,A
        JR C,S2_2
        ADD A,E
        JR Z,S2_4
        JR C,S2_2
        BIT 7,C
        JR Z,S2_4
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S2_4
        JR NC,S2_4
S2_2    DEFB h'CB,h'30;SLI B
        JR NC,S2_3
        LD A,E
        AND h'03
        JP Z,S21L0
        DEC A
        JP Z,S21L1
        DEC A
        JP Z,S21L2
        JP S21L3
S2_3    LD A,E
        AND h'03
        JP Z,S21H0
        DEC A
        JP Z,S21H1
        DEC A
        JP Z,S21H2
        JP S21H3
S2_4    DEFB h'CB,h'30;SLI B
        JR NC,S2_5
        LD A,E
        AND h'03
        JP Z,S22L0
        DEC A
        JP Z,S22L1
        DEC A
        JP Z,S22L2
        JP S22L3
S2_5    LD A,E
        AND h'03
        JP Z,S22H0
        DEC A
        JP Z,S22H1
        DEC A
        JP Z,S22H2
        JP S22H3

S2_6    LD A,IXL
        ADD A,A
        JR C,S2_7
        LD IYL,A
        LD A,IXL
        SRL A
        ADD A,IYL
        JR C,S2_7
        ADD A,E
        JR Z,S2_9
        JR C,S2_7
        BIT 7,C
        JR Z,S2_9
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S2_9
        JR NC,S2_9
S2_7    DEFB h'CB,h'30;SLI B
        JR C,S2_8
        LD A,E
        AND h'03
        JP Z,S23L0
        DEC A
        JP Z,S23L1
        DEC A
        JP Z,S23L2
        JP S23L3
S2_8    LD A,E
        AND h'03
        JP Z,S23H0
        DEC A
        JP Z,S23H1
        DEC A
        JP Z,S23H2
        JP S23H3
S2_9    DEFB h'CB,h'30;SLI B
        JR C,S2_A
        LD A,E
        AND h'03
        JP Z,S24L0
        DEC A
        JP Z,S24L1
        DEC A
        JP Z,S24L2
        JP S24L3
S2_A    LD A,E
        AND h'03
        JP Z,S24H0
        DEC A
        JP Z,S24H1
        DEC A
        JP Z,S24H2
        JP S24H3

S21G0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
S21J1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21J3
S21K3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S21R1
S21L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21K1
        SUB (HL)
        EXX
        JP C,S21G1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S21R2
        JP C,S21K0
        JP S21J0

S21R1   LD C,h'00
        RRC B
        RET

S21R2   LD C,h'01
        JR NC,S21R2_2
        RRC B
        RET

S21R2_2 SRL B
        RET

S21G1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
S21J2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S21R2
        JP NC,S21J0
S21K0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21K2
        SUB (HL)
        EXX
        JP C,S21G2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S21R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S21K1
        JP S21J1

S21R3   LD C,h'00
        SRL B
        RET

S21G2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
S21J3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S21R3
S21H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21J1
S21K1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21K3
        SUB (HL)
        EXX
        JP C,S21G3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S21R4
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S21K2
        JP S21J2

S21R4   LD C,h'01
        SRL B
        RET

S21G3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S21R4
S21J0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S21J2
S21K2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S21L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S21R5
        JP NC,S21K0
        SUB (HL)
        EXX
        JP C,S21G0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S21K3
        JP S21J3

S21R5   JR NC,S21R5_2
        LD C,h'02
        SRL B
        RET

S21R5_2 LD C,h'01
        RRC B
        RET

S22G0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
S22J1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2
        JP NC,S22J3
S22K3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S22R1
S22L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R5_3
        JP NC,S22K1
        SUB (HL)
        EXX
        JP C,S22G1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S22R2
        DEC IXL
        JR Z,S22R2
        JP C,S22K0
        JP S22J0

S22R1   LD C,h'00
        RRC B
        RET

S22R2   LD C,h'01
        JR NC,S22R2_2
        RRC B
        RET

S22R2_2 SRL B
        RET

S22R5_3 JP S22R5

S22G1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E

S22J2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S22R2
        DEC IXL
        JR Z,S22R2
        JP NC,S22J0
S22K0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R5_3
        JP NC,S22K2
        SUB (HL)
        EXX
        JP C,S22G2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S22R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2
        JP C,S22K1
        JP S22J1

S22R3   LD C,h'00
        SRL B
        RET

S22G2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
S22J3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S22R3
S22H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2
        JP NC,S22J1
S22K1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R5
        JP NC,S22K3
        SUB (HL)
        EXX
        JP C,S22G3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S22R4
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2_3
        JP C,S22K2
        JP S22J2

S22G3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S22R4
S22J0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2_3
        JP NC,S22J2
S22K2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S22L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S22R5
        DEC IXL
        JR Z,S22R5
        JP NC,S22K0
        SUB (HL)
        EXX
        JP C,S22G0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S22R2_3
        JP C,S22K3
        JP S22J3

S22R2_3 JP S22R2

S22R5   JR NC,S22R5_2
        LD C,h'02
        SRL B
        RET

S22R5_2 LD C,h'01
        RRC B
        RET

S22R4   LD C,h'01
        SRL B
        RET

S23J0   SUB (HL)
        EXX
        JP C,S23P0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J3
        JP S23K3

S23P0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J3
S23K3   SUB (HL)
        EXX
        JP C,S23I3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S23R1
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K2
        JP S23G2

S23I3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S23R1
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K2
S23G2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S23R2
        JP NC,S23K0
        JP S23J0

S23R1   LD C,h'01
        SRL B
        RET

S23R2   LD C,h'02
        JR NC,S23R2_2
        RRC B
        RET

S23R2_2 SRL B
        RET

S23J1   SUB (HL)
        EXX
        JP C,S23P1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S23R2
        JP C,S23J0
        JP S23K0

S23P1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S23R2
        JP C,S23J0
S23K0   SUB (HL)
        EXX
        JP C,S23I0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K3
        JP S23G3

S23I0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K3
S23G3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S23R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S23K1
        JP S23J1

S23R3   LD C,h'00
        RRC B
        RET

S23J2   SUB (HL)
        EXX
        JP C,S23P2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S23R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J1
        JP S23K1

S23P2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S23R3
S23H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J1
S23K1   SUB (HL)
        EXX
        JP C,S23I1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S23R4
        JP C,S23K0
        JP S23G0

S23I1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S23R4
        JP C,S23K0

S23G0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S23K2
        JP S23J2

S23R4   JR C,S23R4_2
        LD C,h'01
        RRC B
        RET

S23R4_2 LD C,h'02
        SRL B
        RET

S23R5   LD C,h'01
        RRC B
        RET

S23J3   SUB (HL)
        EXX
        JP C,S23P3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S23R5
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J2
        JP S23K2

S23P3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S23R5
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S23H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23J2
S23K2   SUB (HL)
        EXX
        JP C,S23I2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S23R6
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K1
        JP S23G1

S23I2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S23R6
S23L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S23K1
S23G1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S23K3
        JP S23J3

S23R6   LD C,h'00
        SRL B
        RET

S24J0   SUB (HL)
        EXX
        JP C,S24P0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2
        JP C,S24J3
        JP S24K3

S24P0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24H2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2
        JP C,S24J3
S24K3   SUB (HL)
        EXX
        JP C,S24I3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S24R1
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4_3
        JP C,S24K2
        JP S24G2

S24I3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S24R1
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24L1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4_3
        JP C,S24K2

S24G2   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S24R2
        DEC IXL
        JR Z,S24R2
        JP NC,S24K0
        JP S24J0

S24R1   LD C,h'01
        SRL B
        RET

S24R2   LD C,h'02
        JR NC,S24R2_2
        RRC B
        RET

S24R2_2 SRL B
        RET

S24R4_3 JP S24R4

S24J1   SUB (HL)
        EXX
        JP C,S24P1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S24R2
        DEC IXL
        JR Z,S24R2
        JP C,S24J0
        JP S24K0

S24P1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24H3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S24R2
        DEC IXL
        JR Z,S24R2
        JP C,S24J0
S24K0   SUB (HL)
        EXX
        JP C,S24I0
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4_3
        JP C,S24K3
        JP S24G3

S24I0   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24L2   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4_3
        JP C,S24K3
S24G3   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S24R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_5
        JP NC,S24K1
        JP S24J1

S24R2_5 JP S24R2

S24R3   LD C,h'00
        RRC B
        RET

S24J2   SUB (HL)
        EXX
        JP C,S24P2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S24R3
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_3
        JP C,S24J1
        JP S24K1

S24P2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S24R3
S24H0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_3
        JP C,S24J1
S24K1   SUB (HL)
        EXX
        JP C,S24I1
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S24R4
        DEC IXL
        JR Z,S24R4
        JP C,S24K0
        JP S24G0

S24I1   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24L3   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JR Z,S24R4
        DEC IXL
        JR Z,S24R4
        JP C,S24K0

S24G0   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_3
        JP NC,S24K2
        JP S24J2

S24R4   JR C,S24R4_2
        LD C,h'01
        RRC B
        RET

S24R4_2 LD C,h'02
        SRL B
        RET

S24R2_3 JP S24R2

S24R5   LD C,h'01
        RRC B
        RET

S24J3   SUB (HL)
        EXX
        JP C,S24P3
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S24R5
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_3
        JP C,S24J2
        JP S24K2

S24P3   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        JR Z,S24R5
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
S24H1   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_3
        JP C,S24J2
S24K2   SUB (HL)
        EXX
        JP C,S24I2
        LD L,A
        LD A,(HL)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S24R6
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4
        JP C,S24K1
        JP S24G1

S24I2   LD E,A
        LD A,(DE)
        EXX
        ADD A,(HL)
        LD (DE),A
        INC E
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S24R6
S24L0   LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R4_4
        JP C,S24K1
S24G1   ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        LD A,B
        ADD A,C
        LD B,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        DEC IXL
        JR Z,S24R2_4
        JP NC,S24K3
        JP S24J3

S24R2_4 JP S24R2

S24R4_4 JP S24R4

S24R6   LD C,h'00
        SRL B
        RET

;INCLUDE "SGEN3.asm"
S3_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S31     SLA B
        JP C,S318

S310    LD A,IXL
        ADD A,A
        JP C,S311
        ADD A,IXL
        JP C,S311
        ADD A,E
        JR Z,S310_
        JP C,S311
        BIT 7,B
        JR Z,S310_
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S310_
        JP C,S311
S310_   DEFB h'CB,h'31;SLI C
        JP C,S3101
        JP S3100

S3102   JR Z,S3104
S310A   INC E
        JR Z,S3105
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31052
        LD (DE),A
        INC E
        JR Z,S31053
S3100   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S3102
        JR Z,S3106
        INC E
        JR Z,S3107
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S3109
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S31092
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JP NZ,S3101
        JP S31093

S3103   JR Z,S3108
        INC E
        JR Z,S3109
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31092
        LD (DE),A
        INC E
        JR Z,S31093
S3101   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S3103
        JP NZ,S310A
S3104   INC E
S3105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S31052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S31053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S3106   INC E
S3107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3108   INC E
S3109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S31092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S31093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S311    DEFB h'CB,h'31;SLI C
        JP C,S3111
        JR S3110

S3112   JR Z,S3114
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31141
        LD (DE),A
        INC E
        JR Z,S31142
S3110   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S3112
        JR Z,S3115
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S31151
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S3116
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JP NZ,S3111
        JP S31162

S3113   JR Z,S31151
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S3116
        LD (DE),A
        INC E
        JR Z,S31162
S3111   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP NC,S3113
        JP NZ,S3112
        SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S31141  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S31142  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S3114   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S3115   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S31151  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S3116   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S31162  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S318    LD A,IXL
        ADD A,A
        JP C,S319
        ADD A,IXL
        JP C,S319
        LD IYL,A
        LD A,IXL
        SRL A
        ADD A,IYL
        JP C,S319
        ADD A,E
        JR Z,S318_
        JP C,S319
        BIT 7,B
        JR Z,S318_
        LD IYL,A
        LD A,IXL
        SRL A
        SRL A
        ADD A,IYL
        JR Z,S318_
        JP C,S319
S318_   DEFB h'CB,h'31;SLI C
        JP NC,S3180
        JP S3181

S3184   INC E
S3185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3182   JR Z,S3184
        INC E
S31822  JR Z,S3185
S318222 LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S3186
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S31866
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31867
S3181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S3182
        JR Z,S31871
        INC E
        JR Z,S31891
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S3189
        LD (DE),A
        INC E
        JP NZ,S3180
        JP S31892

S31871  INC E
S31891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S3183   JR Z,S3187
        INC E
        JR Z,S3188
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S31891
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S3189
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31892
S3180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S3183
        JR Z,S31844
        INC E
        JP NZ,S318222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S31866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        RET

S31867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        DEC D
        RET

S31844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3187   INC E
S3188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3189   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        RET

S31892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        DEC D
        RET

S319    DEFB h'CB,h'31;SLI C
        JP NC,S3190
        JP S3191

S3195   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3192   JR Z,S3195
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S3196
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S31966
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31967
S3191   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S3192
        JR Z,S3199
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31993
        LD (DE),A
        INC E
        JP NZ,S3190
        JP S31994

S3193   JR Z,S3198
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S3199
S31933  LD A,IYH
        LD (DE),A
        INC E
        JR Z,S31993
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S31994
S3190   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        LD (DE),A
        INC E
        JP C,S3193
        JP NZ,S3192
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3196   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S31966  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        RET

S31967  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        DEC D
        RET

S3198   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S3199   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        RET

S31993  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        RET

S31994  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        DEC D
        DEC D
        DEC D
        RET

;INCLUDE "SGEN4.asm"
S4_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S41     SLA B
        JP C,S418
        DEFB h'CB,h'31;SLI C
        LD IYH,B
        JP C,S4101
        JP S4100

S4102   JR Z,S4104
S410A   INC E
        JR Z,S4105
        LD B,A
        ADD A,(HL)
        RRA
        LD IYL,A
        ADD A,B
        RRA
        LD (DE),A
        INC E
        JR Z,S41052
        LD A,IYL
        LD (DE),A
        INC E
        JR Z,S41053
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41054
S4100   LD A,C
        ADD A,IYH
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S4102
        JR Z,S4106
        INC E
        JR Z,S4107
        LD (DE),A
        INC E
        JP NZ,S41033
        JP S4109
S4103   JR Z,S4108
        INC E
        JR Z,S4109
S41033  LD B,A
        ADD A,(HL)
        RRA
        LD IYL,A
        ADD A,B
        RRA
        LD (DE),A
        INC E
        JR Z,S41092
        LD A,IYL
        LD (DE),A
        INC E
        JR Z,S41093
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41094
S4101   LD A,C
        ADD A,IYH
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S4103
        JP NZ,S410A
S4104   INC E
S4105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S41052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S41053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S41054  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S4106   INC E
S4107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S4108   INC E
S4109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S41092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S41093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S41094  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S418    DEFB h'CB,h'31;SLI C
        JP NC,S4180
        JP S4181

S4184   INC E
S4185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S41844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S4182   JR Z,S4184
        INC E
S41822  JR Z,S4185
S418222 LD (DE),A
        INC E
        JR Z,S4186
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41866
        LD (DE),A
        INC E
        JR Z,S41867
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41868
S4181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S4182
        JR Z,S41871
        JP S41831
S4183   JR Z,S4187
        INC E
        JR Z,S4188
        LD (DE),A
S41831  INC E
        JR Z,S4189
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41891
        LD (DE),A
        INC E
        JR Z,S41892
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S41893
S4180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S4183
        JR Z,S41844
        INC E
        JP NZ,S418222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S4186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S41866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S41867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S41868  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S4187   INC E
S4188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S4189   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S41871  INC E
S41891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S41892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S41893  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

;INCLUDE "SGEN5.asm"
S5_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S51     SLA B
        JP C,S518
        DEFB h'CB,h'31;SLI C
        JP C,S5101
        JP S5100

S5102   JR Z,S5104
S510A   INC E
        JR Z,S5105
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S51052
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S51053
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51054
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51055
S5100   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S5102
        JR Z,S5106
        INC E
        JR Z,S5107
        LD (DE),A
        DEC E
        INC E
S5103   JR Z,S5108
        INC E
        JR Z,S5109
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S51092
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S51093
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51094
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51095
S5101   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S5103
        JP NZ,S510A
S5104   INC E
S5105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S51052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S51053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S51054  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S51055  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S5106   INC E
S5107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S5108   INC E
S5109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S51092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S51093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S51094  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S51095  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S518    DEFB h'CB,h'31;SLI C
        JP NC,S5180
        JP S5181

S5184   INC E
S5185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S5186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S51866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S51867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S51868  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S51869  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S5182   JR Z,S5184
        INC E
S51822  JR Z,S5185
S518222 LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S5186
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S51866
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S51867
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51868
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51869
S5181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S5182
        JR Z,S51871
        JP S51831
S5183   JR Z,S5187
        INC E
        JR Z,S5188
        LD (DE),A
S51831  INC E
        JR Z,S5189
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S51891
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S51892
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51893
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S51894
S5180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S5183
        JR Z,S51844
        INC E
        JP NZ,S518222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S51844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S5187   INC E
S5188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S5189   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S51871  INC E
S51891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S51892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S51893  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S51894  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

;INCLUDE "SGEN6.asm"
S6_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S61     SLA B
        JP C,S618
        DEFB h'CB,h'31;SLI C
        JP C,S6101
        JP S6100

S61052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S61053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S61054  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S61055  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S61056  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S6102   JR Z,S6104
S610A   INC E
        JR Z,S6105
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S61052
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S61053
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S61054
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61055
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61056
S6100   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S6102
        JR Z,S6106
        INC E
        JR Z,S6107
        LD (DE),A
        DEC E
        INC E
S6103   JR Z,S6108
        INC E
        JR Z,S6109
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S61092
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S61093
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S61094
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61095
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61096
S6101   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S6103
        JP NZ,S610A
S6104   INC E
S6105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S6106   INC E
S6107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S6108   INC E
S6109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S61092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S61093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S61094  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S61095  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S61096  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S618    DEFB h'CB,h'31;SLI C
        JP NC,S6180
        JP S6181

S6184   INC E
S6185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S6186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S61866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S61867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S61868  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S61869  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S6186A  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S6182   JR Z,S6184
        INC E
S61822  JR Z,S6185
S618222 LD (DE),A
        INC E
        JR Z,S6186
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S61866
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S61867
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S61868
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61869
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S6186A
S6181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S6182
        JR Z,S61871
        JP S61831
S6183   JR Z,S6187
        INC E
        JR Z,S6188
        LD (DE),A
S61831  INC E
        JR Z,S6189
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S61891
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S61892
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S61893
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61894
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S61895
S6180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S6183
        JR Z,S61844
        INC E
        JP NZ,S618222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S61844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S6187   INC E
S6188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S6189    SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S61871  INC E
S61891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S61892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S61893  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S61894  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S61895  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

;INCLUDE "SGEN7.asm"
S7_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S71     SLA B
        JP C,S718
        DEFB h'CB,h'31;SLI C
        JP C,S7101
        JP S7100

S71052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S71053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S71054  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S71055  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S71056  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S71057  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S7102   JR Z,S7104
S710A   INC E
        JR Z,S7105
        LD (DE),A
        INC E
        JR Z,S71052
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S71053
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S71054
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S71055
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71056
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71057
S7100   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S7102
        JR Z,S7106
        INC E
        JR Z,S7107
        LD (DE),A
        DEC E
        INC E
S7103   JR Z,S7108
        INC E
        JR Z,S7109
        LD (DE),A
        INC E
        JR Z,S71092
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S71093
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S71094
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S71095
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71096
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71097
S7101   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S7103
        JP NZ,S710A
S7104   INC E
S7105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S7106   INC E
S7107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S7108   INC E
S7109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S71092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S71093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S71094  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S71095  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S71096  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S71097  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S718    DEFB h'CB,h'31;SLI C
        JP NC,S7180
        JP S7181

S7184   INC E
S7185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S7186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S71866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S71867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S71868  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S71869  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S7186A  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S7186B  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S7182   JR Z,S7184
        INC E
S71822  JR Z,S7185
S718222 LD (DE),A
        INC E
        JR Z,S7186
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S71866
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S71867
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S71868
        LD (DE),A
        INC E
        JR Z,S71869
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S7186A
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S7186B
S7181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S7182
        JR Z,S71871
        JP S71831
S7183   JR Z,S7187
        INC E
        JR Z,S7188
        LD (DE),A
S71831  INC E
        JR Z,S7189
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S71891
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S71892
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S71893
        LD (DE),A
        INC E
        JR Z,S71894
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71895
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S71896
S7180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S7183
        JR Z,S71844
        INC E
        JP NZ,S718222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S71844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S7187   INC E
S7188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S7189   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S71871  INC E
S71891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S71892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S71893  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S71894  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S71895  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S71896  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

;INCLUDE "SGEN8.asm"
S8_     LD D,C
        PUSH DE
        LD D,B
        EXX
        POP BC
S81     SLA B
        JP C,S818
        DEFB h'CB,h'31;SLI C
        JP C,S8101
        JP S8100

S81052  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S81053  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S81054  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S81055  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S81056  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S81057  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S81058  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S8102   JP Z,S8104
S810A   INC E
        JP Z,S8105
        LD (DE),A
        INC E
        JR Z,S81052
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S81053
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S81054
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S81055
        LD (DE),A
        INC E
        JR Z,S81056
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81057
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81058
S8100   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S8102
        JR Z,S8106
        INC E
        JR Z,S8107
        LD (DE),A
        DEC E
        INC E
S8103   JR Z,S8108
        INC E
        JR Z,S8109
        LD (DE),A
        INC E
        JR Z,S81092
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S81093
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S81094
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S81095
        LD (DE),A
        INC E
        JR Z,S81096
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81097
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81098
S8101   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP NC,S8103
        JP NZ,S810A
S8104   INC E
S8105   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,7
        RET

S8106   INC E
S8107   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S8108   INC E
S8109   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,7
        RET

S81092  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S81093  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S81094  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S81095  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S81096  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S81097  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S81098  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S818    DEFB h'CB,h'31;SLI C
        JP NC,S8180
        JP S8181

S8184   INC E
S8185   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S8186   RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,7
        RET

S81866  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S81867  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S81868  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S81869  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S8186A  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S8186B  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S8186C  RRC C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET

S8182   JR Z,S8184
        INC E
S81822  JR Z,S8185
S818222 LD (DE),A
        INC E
        JR Z,S8186
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S81866
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S81867
        LD (DE),A
        INC E
        JR Z,S81868
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S81869
        LD (DE),A
        INC E
        JR Z,S8186A
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S8186B
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S8186C
S8181   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S8182
        JR Z,S81871
        JP S81831
S8183   JR Z,S8187
        INC E
        JR Z,S8188
        LD (DE),A
S81831  INC E
        JR Z,S8189
        LD IYL,A
        ADD A,(HL)
        RRA
        LD IYH,A
        ADD A,IYL
        RRA
        LD (DE),A
        INC E
        JR Z,S81891
        ADD A,IYH
        RRA
        LD (DE),A
        INC E
        JR Z,S81892
        LD (DE),A
        INC E
        JR Z,S81893
        LD A,IYH
        LD (DE),A
        INC E
        JR Z,S81894
        LD (DE),A
        INC E
        JR Z,S81895
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81896
        ADD A,(HL)
        RRA
        LD (DE),A
        INC E
        JR Z,S81897
S8180   LD A,C
        ADD A,B
        LD C,A
        LD A,(HL)
        INC HL
        DEC IXL
        LD (DE),A
        JP C,S8183
        JR Z,S81844
        INC E
        JP NZ,S818222
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S81844  INC E
        RRC C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S8187   INC E
S8188   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        RET

S8189   SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,7
        RET

S81871  INC E
S81891  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,6
        RET

S81892  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,5
        RET

S81893  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,4
        RET

S81894  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,3
        RET

S81895  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,2
        RET

S81896  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,1
        RET

S81897  SRL C
        LD IYL,C
        EXX
        LD E,IYL
        LD D,0
        RET
