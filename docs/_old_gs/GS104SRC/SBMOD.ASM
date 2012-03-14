;
;       ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
;       º                                               º
TITLE   º SOUNDBLASTER MODPLAYER  (SB/SBPRO/16 & COMP.) º
;       º                                               º
;       ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
;
; THIS MODULE PLAYER WAS CODED IN EARLY 1994
;
;                        BY SILVIO TURELLO (FRONTMAN/CREW242)
;
; IT IS A COMPLETELY REVISED VERSION OF THE MODLIB
;
;                        BY SERGE HUBER (NUMERUS/IMPHOBIA)
;
; PC-CONVERSION OF AMIGA PROTRACKER CODE (FOR SUPER PRO PLAY > MODLIB)
;
;                        BY JOSHUA C. JENSEN (CYBERSTRIKE/FORM. RENAISSANCE)
;
; ORIGIN SOURCE CODE CAME FROM THE PROTRACKER V2.1A
;
;                        BY LARS "ZAP" HAMRE (AMIGA FREELANCERS)
;
; FEATURES: 4/8-CHANNEL-MODS (M.K./FLT4/FLT8/8CHN), MIXINGRATE 10000-22222 HZ
;
;           1/2-FX-CHANNELS, FULL MOD-FX SUPPORT EXCEPT FILTER & REVERSE FUNK
;
;           STEREO FOR SBPRO&16, ONLY 10% (APPROX.) PERFORMANCE REDUCTION
;
;           544 KB EMS-MEMORY SUPPORT FOR FX
;
DOSSEG
.MODEL TINY
STACKLENGTH     = 0100H
ASSUME CS:DGROUP, DS:DGROUP; SS:DGROUP
;=============================================================================
MAX_CHAN_NUMB	= 8
IRQ1            = 20H
IRQ2		= 21H
IRQ3		=0A0H
IRQ4		=0A1H
TIMER0		= 40H
PIT1            = 43H
UHR_INDEX	= 70H
UHR_PORT	= 71H
UHR_STATA	= 0AH
UHR_STATB	= 0BH
UHR_STATC	= 0CH
;-----------------------------------------------------------------------------
.DATA
PROG_START_SEG  DW 0
PROG_END_SEG    DW 0
SYSTEM		DB 0
IRQCOUNT	DB 56
SBPRO_FLAG	DB 0		;0=SB, 1= SBPRO
SB_TYP		DB 1		;0=GUS, 1=SBPRO, 2=SB, 3=NO_SOUND
SB_MODUS	DB 0		;0=MUSIC&FX 1=MUSIC 2=FX 3=NO_SOUND
SAM_FLAG	DB 0		;FLIP SAMPLE CHANNEL
SAMPLE_RATE	DW 22222
SBP_MIXERI	DW 0224H
SBP_MIXERD	DW 0225H
SB_RESET	DW 0226H
SB_READ		DW 022AH
SB_WRITE	DW 022CH
SB_RSTAT	DW 022EH
IRQ_NUMBER	DB 7
DMA_CHANNEL	DB 1
DMA_RATE	DB 211
DMA_PAGE	DB 0
DMA_POFF	DW 0
DMA_DATA	DB 87H,83H,81H,82H
MAINFREQ	DD 41236
DMA_CX		DW 434
DMA_MORE	DW 434*4
DMA_MAX		DW 434*16
DMA_NEWPTR	DW 0
DMA_PTR		DW 0
DMA_SEG		DW 0
DMA_OFFSET	DW 0
MIXMUL_OFFSET	DW 0
COMP_SPEED2     DW 0106H
COMP_SPEED3     DW 4006H
COMP_SPEED4     DW 0
COMP_SPEED5     DW 1165
HOLD70  LABEL   DWORD
		DW OFFSET TIMER_HANDLER, 0
HOLDSB  LABEL   DWORD
		DW OFFSET SBIRQ_HANDLER, 0
STEREO_PANNING	DW 2,-2,0,2,0,-2,0,2,0
;-----------------------------------------------------------------------------
GDDLENGTH	DD 0
GDDREST		DW 0
GDDHANDLE	DW 0
;GDDMIN		DW -1
;GDDNEW		DW 0
;GDDPOSL	DW 0
;GDDPOSH	DW 0
GDDZEIG		DB 0
;-----------------------------------------------------------------------------
ERROR1_TEXT	DB "MOD ERROR",13,10,"$"
ERROR2_TEXT	DB "FX ERROR",13,10,"$"
ERROR3_TEXT	DB "SB ERROR",13,10,"$"
OUT_TEXT	DB "+/- VOLUME",13,10
		DB "1   PLAY SAMPLE",13,10
		DB "9   INIT REPEAT",13,10
		DB "0   MUSIC MODE",13,10,"$"
SAMPLE_NAME	DB "SAMPLE1.SAM",0
CONFIG_NAME     DB "SS.CFG",0
VOL_NAME        DB "FM.VOL",0
CFG_TEXT1       DB "DEFAULT MUSIC SYSTEM = ",0
CFG_TEXT2       DB "DEFAULT MUSIC MODE = ",0
CFG_TEXT3       DB "SOUNDCARD BASE PORT = ",0
CFG_TEXT4       DB "SOUNDCARD IRQ NUMBER = ",0
CFG_TEXT5       DB "SOUNDCARD DMA NUMBER = ",0
CFG_TEXT6       DB "DEFAULT SAMPLINGRATE = ",0
CFG_TEXT7       DB "SYSTEM COMPATIBILITY = ",0
;-----------------------------------------------------------------------------
; PLAYER - CONTROL STRUCTURES
;-----------------------------------------------------------------------------
ALIGN 2
MUSIC_VOL	DB 255
MUSIC_VOLUME	DB 255
FX_VOL		DB 255
FX_VOLUME	DB 255
MASTER_VOLUME	DB 255
MOD_STAT	DB 0
BPM_COUNT	DB 1
BPM_SPEED	DB 20
CH_NUMB		DW 4
QUEUE_BUFFER	LABEL	WORD		;256 BYTES
NOTE		DW MAX_CHAN_NUMB DUP(0)
CMD		DB MAX_CHAN_NUMB DUP(0)
CMDLO		DB MAX_CHAN_NUMB DUP(0)
START		DW MAX_CHAN_NUMB DUP(0)
LENGTHI		DW MAX_CHAN_NUMB DUP(0)
LOOPSTART	DW MAX_CHAN_NUMB DUP(0)
REPLEN		DW MAX_CHAN_NUMB DUP(0)
PERIOD		DW MAX_CHAN_NUMB DUP(0)
FINETUNE	DB MAX_CHAN_NUMB DUP(0)
VOLUME		DB MAX_CHAN_NUMB DUP(0)
TONEPORTDIREC	DB MAX_CHAN_NUMB DUP(1)
TONEPORTSPEED	DB MAX_CHAN_NUMB DUP(0)
WANTEDPERIOD	DW MAX_CHAN_NUMB DUP(0)
VIBRATOCMD	DB MAX_CHAN_NUMB DUP(0)
VIBRATOPOS	DB MAX_CHAN_NUMB DUP(0)
TREMOLOCMD	DB MAX_CHAN_NUMB DUP(0)
TREMOLOPOS	DB MAX_CHAN_NUMB DUP(0)
WAVECONTROL	DB MAX_CHAN_NUMB DUP(0)
GLISSFUNK	DB MAX_CHAN_NUMB DUP(0)
SAMPLEOFFSET	DB MAX_CHAN_NUMB DUP(0)
PATTPOS		DB MAX_CHAN_NUMB DUP(0)
LOOPCOUNT	DB MAX_CHAN_NUMB DUP(0)

MFREQ		DW MAX_CHAN_NUMB DUP(0)
MOFLOW		DB MAX_CHAN_NUMB DUP(0)
SONG_DATA	LABEL	BYTE		;128 BYTES
MVOL		DB MAX_CHAN_NUMB DUP(0)
MSEG		DW MAX_CHAN_NUMB DUP(0)
MOFS		DW MAX_CHAN_NUMB DUP(0)
MREPEAT		DW MAX_CHAN_NUMB DUP(0)
MREPLEN		DW MAX_CHAN_NUMB DUP(0)
MMAXREP		DW MAX_CHAN_NUMB DUP(0)
MOD_NAME	DB 40 DUP(0)
;-----------------------------------------------------------------------------
; Seg                           Stores the segment of the current sample.  If
;                               the segment is zero, then there is no sample
;                               begin played.
; Offset                        The current offset of the sample being played
;                               in the segment specified.
; MaxRep                        The offset of the place in the sample to
;                               repeat from (i.e. the end of the sample).
; Freq                          The frequency to be played out the output
;                               device.  It is actually a playback period,
;                               the upper byte determining the number of
;                               bytes to be added to the sample offset each
;                               interrupt, and the lower byte to be added
;                               over and over to generate carry flags to be
;                               added to additional offsets.
; Vol                           The actual volume to multiply the frequency
;                               by.
; Repeat                        The place to repeat from when the end of the
;                               loop is found.
; RepLen                        The number of bytes from Repeat to go to.
;                               When the end of this is found, it goes back
;                               to Repeat.
; OFlow                         The overflow variable used to generate the
;                               carry flags.
;-----------------------------------------------------------------------------
; PROTRACKER VARIABLES
;-----------------------------------------------------------------------------
ALIGN 2
MT_SPEED                DB 6
MT_COUNTER              DB 0
MT_PATTERNPOS           DW 0
MT_SONGPOS              DB 0
MT_PATTDELAYTIME2       DB 0
MT_PATTDELAYTIME        DB 0
MT_PBREAKFLAG           DB 0
MT_PBREAKPOS            DB 0
MT_POSJUMPFLAG          DB 0
MT_LOWMASK              DB 0FFH

ALIGN 2
Effect_Jump_Table1	LABEL	WORD
DW OFFSET Go_Arpeggio, OFFSET Go_PortaUp, OFFSET Go_PortaDown
DW OFFSET Go_TonePortamento, OFFSET Go_vibrato, OFFSET Go_TonePlusVolSlide
DW OFFSET Go_VibratoPlusVolSlide, OFFSET Go_Tremolo, OFFSET Go_Return
DW OFFSET Go_Return, OFFSET Go_VolumeSlide, OFFSET Go_Return, OFFSET Go_Return
DW OFFSET Go_Return, OFFSET Go_E_Commands, OFFSET Go_Return

Effect_Jump_Table2	LABEL	WORD
DW OFFSET Go_PerNop, OFFSET Go_PerNop, OFFSET Go_PerNop
DW OFFSET Go_PerNop, OFFSET Go_PerNop, OFFSET Go_PerNop
DW OFFSET Go_PerNop, OFFSET Go_PerNop, OFFSET Go_PerNop
DW OFFSET Go_SampleOffset, OFFSET Go_PerNop, OFFSET Go_PositionJump
DW OFFSET Go_VolumeChange, OFFSET Go_PatternBreak
DW OFFSET Go_E_Commands, OFFSET Go_SetSpeed

Effect_Jump_Table3	LABEL	WORD
DW OFFSET Go_Return, OFFSET Go_FinePortaUp, OFFSET Go_FinePortaDown
DW OFFSET Go_SetGlissControl, OFFSET Go_SetVibratoControl
DW OFFSET Go_SeTFineTune, OFFSET Go_JumpLoop, OFFSET Go_SetTremoloControl
DW OFFSET Go_Return, OFFSET Go_RetrigNote, OFFSET Go_VolumeFineUp
DW OFFSET Go_VolumeFineDown, OFFSET Go_NoteCut, OFFSET Go_NoteDelay
DW OFFSET Go_PatternDelay, OFFSET Go_Return

ALIGN 2
MT_VIBRATOTABLE		DB   0, 24, 49, 74, 97,120,141,161
                        DB 180,197,212,224,235,244,250,253
                        DB 255,253,250,244,235,224,212,197
                        DB 180,161,141,120, 97, 74, 49, 24

ALIGN 2
MT_PERIODTABLE	LABEL	WORD
DW 856,808,762,720,678,640,604,570,538,508,480,453 ;C-1 to H-1 Finetune +0.
DW 428,404,381,360,339,320,302,285,269,254,240,226 ;C-2 to H-2 Finetune +0.
DW 214,202,190,180,170,160,151,143,135,127,120,113 ;C-3 to H-3 Finetune +0.
DW 107,101, 95, 90, 85, 80, 75, 71, 67, 63, 60, 56 ;C-4 to H-4 Finetune +0.

DW 850,802,757,715,674,637,601,567,535,505,477,450 ;C-1 to H-1 Finetune +1.
DW 425,401,379,357,337,318,300,284,268,253,239,225 ;C-2 to H-2 Finetune +1.
DW 213,201,189,179,169,159,150,142,134,126,119,113 ;C-3 to H-3 Finetune +1.
DW 106,100, 94, 89, 84, 79, 75, 71, 67, 83, 59, 56 ;C-4 to H-4 Finetune +1.

DW 844,796,752,709,670,632,597,563,532,502,474,447 ;C-1 to H-1 Finetune +2.
DW 422,398,376,355,335,316,298,282,266,251,237,224 ;C-2 to H-2 Finetune +2.
DW 211,199,188,177,167,158,149,141,133,125,118,112 ;C-3 to H-3 Finetune +2.
DW 105, 99, 94, 88, 83, 79, 74, 70, 66, 62, 59, 56 ;C-4 to H-4 Finetune +2.

DW 838,791,746,704,665,628,592,559,528,498,470,444 ;C-1 to H-1 Finetune +3.
DW 419,395,373,352,332,314,296,280,264,249,235,222 ;C-2 to H-2 Finetune +3.
DW 209,198,187,176,166,157,148,140,132,125,118,111 ;C-3 to H-3 Finetune +3.
DW 104, 99, 93, 88, 83, 78, 74, 70, 66, 62, 59, 55 ;C-4 to H-4 Finetune +3.

DW 832,785,741,699,660,623,588,555,524,495,467,441 ;C-1 to H-1 Finetune +4.
DW 416,392,370,350,330,312,294,278,262,247,233,220 ;C-2 to H-2 Finetune +4.
DW 208,196,185,175,165,156,147,139,131,124,117,110 ;C-3 to H-3 Finetune +4.
DW 104, 98, 92, 87, 82, 78, 73, 69, 65, 62, 58, 55 ;C-4 to H-4 Finetune +4.

DW 826,779,736,694,655,619,584,551,520,491,463,437 ;C-1 to H-1 Finetune +5.
DW 413,390,368,347,328,309,292,276,260,245,232,219 ;C-2 to H-2 Finetune +5.
DW 206,195,184,174,164,155,146,138,130,123,116,109 ;C-3 to H-3 Finetune +5.
DW 103, 97, 92, 87, 82, 77, 73, 69, 65, 61, 58, 54 ;C-4 to H-4 Finetune +5.

DW 820,774,730,689,651,614,580,547,516,487,460,434 ;C-1 to H-1 Finetune +6.
DW 410,387,365,345,325,307,290,274,258,244,230,217 ;C-2 to H-2 Finetune +6.
DW 205,193,183,172,163,154,145,137,129,122,115,109 ;C-3 to H-3 Finetune +6.
DW 102, 96, 91, 86, 81, 77, 72, 68, 64, 61, 57, 54 ;C-4 to H-4 Finetune +6.

DW 814,768,725,684,646,610,575,543,513,484,457,431 ;C-1 to H-1 Finetune +7.
DW 407,384,363,342,323,305,288,272,256,242,228,216 ;C-2 to H-2 Finetune +7.
DW 204,192,181,171,161,152,144,136,128,121,114,108 ;C-3 to H-3 Finetune +7.
DW 102, 96, 90, 85, 80, 76, 72, 68, 64, 60, 57, 54 ;C-4 to H-4 Finetune +7.

DW 907,856,808,762,720,678,640,604,570,538,504,480 ;C-1 to H-1 Finetune -8.
DW 453,428,404,381,360,339,320,302,285,269,254,240 ;C-2 to H-2 Finetune -8.
DW 226,214,202,190,180,170,160,151,143,135,127,120 ;C-3 to H-3 Finetune -8.
DW 113,107,101, 95, 90, 85, 80, 75, 71, 67, 63, 60 ;C-4 to H-4 Finetune -8.

DW 900,850,802,757,715,675,636,601,567,535,505,477 ;C-1 to H-1 Finetune -7.
DW 450,425,401,379,357,337,318,300,284,268,253,238 ;C-2 to H-2 Finetune -7.
DW 225,212,200,189,179,169,159,150,142,134,126,119 ;C-3 to H-3 Finetune -7.
DW 112,106,100, 94, 89, 84, 79, 75, 71, 67, 63, 59 ;C-4 to H-4 Finetune -7.

DW 894,844,796,752,709,670,632,597,563,532,502,474 ;C-1 to H-1 Finetune -6.
DW 447,422,398,376,355,335,316,298,282,266,251,237 ;C-2 to H-2 Finetune -6.
DW 223,211,199,188,177,167,158,149,141,133,125,118 ;C-3 to H-3 Finetune -6.
DW 111,105, 99, 94, 88, 83, 79, 74, 70, 66, 62, 59 ;C-4 to H-4 Finetune -6.

DW 887,838,791,746,704,665,628,592,559,528,498,470 ;C-1 to H-1 Finetune -5.
DW 444,419,395,373,352,332,314,296,280,264,249,235 ;C-2 to H-2 Finetune -5.
DW 222,209,198,187,176,166,157,148,140,132,125,118 ;C-3 to H-3 Finetune -5.
DW 111,104, 99, 93, 88, 83, 78, 74, 70, 66, 62, 59 ;C-4 to H-4 Finetune -5.

DW 881,832,785,741,699,660,623,588,555,524,494,467 ;C-1 to H-1 Finetune -4.
DW 441,416,392,370,350,330,312,294,278,262,247,233 ;C-2 to H-2 Finetune -4.
DW 220,208,196,185,175,165,156,147,139,131,123,117 ;C-3 to H-3 Finetune -4.
DW 110,104, 98, 92, 87, 82, 78, 73, 69, 65, 61, 58 ;C-4 to H-4 Finetune -4.

DW 875,826,779,736,694,655,619,584,551,520,491,463 ;C-1 to H-1 Finetune -3.
DW 437,413,390,368,347,338,309,292,276,260,245,232 ;C-2 to H-2 Finetune -3.
DW 219,206,195,184,174,164,155,146,138,130,123,116 ;C-3 to H-3 Finetune -3.
DW 109,103, 97, 92, 87, 82, 77, 73, 69, 65, 61, 58 ;C-4 to H-4 Finetune -3.

DW 868,820,774,730,689,651,614,580,547,516,487,460 ;C-1 to H-1 Finetune -2.
DW 434,410,387,365,345,325,307,290,274,258,244,230 ;C-2 to H-2 Finetune -2.
DW 217,205,193,183,172,163,154,145,137,129,122,115 ;C-3 to H-3 Finetune -2.
DW 108,102, 96, 91, 86, 81, 77, 72, 68, 64, 61, 57 ;C-4 to H-4 Finetune -2.

DW 862,814,768,725,684,646,610,575,543,513,484,457 ;C-1 to H-1 Finetune -1.
DW 431,407,384,363,342,323,305,288,272,256,242,228 ;C-2 to H-2 Finetune -1.
DW 216,203,192,181,171,161,152,144,136,128,121,114 ;C-3 to H-3 Finetune -1.
DW 108,101, 96, 90, 85, 80, 76, 72, 68, 64, 60, 57 ;C-4 to H-4 Finetune -1.
;-----------------------------------------------------------------------------
; MTM - TRACK STRUCTURE
;-----------------------------------------------------------------------------
ALIGN 2
TRACK_NUMBER	DW 0
TRACK_INFO	DB 8 DUP(0)
TRACK_SEG	DW 0
TRACKS_OFFSET	DW OFFSET TRACK1_DATA, OFFSET TRACK2_DATA, OFFSET TRACK3_DATA
		DW OFFSET TRACK4_DATA, OFFSET TRACK5_DATA, OFFSET TRACK6_DATA
		DW OFFSET TRACK7_DATA, OFFSET TRACK8_DATA
TRACK1_DATA	DB 128 DUP(0)
TRACK2_DATA	DB 128 DUP(0)
TRACK3_DATA	DB 128 DUP(0)
TRACK4_DATA	DB 128 DUP(0)
TRACK5_DATA	DB 128 DUP(0)
TRACK6_DATA	DB 128 DUP(0)
TRACK7_DATA	DB 128 DUP(0)
TRACK8_DATA	DB 128 DUP(0)
;-----------------------------------------------------------------------------
; MOD - FILE STRUCTURE
;-----------------------------------------------------------------------------
ALIGN 2
SAMPLE_SIZE	DW 0
PATTERN_SIZE	DW 0
PATTERN_SEG	DW 0
PATTERN_NUMBER	DW 0
PATTERN_CURRENT	DW 0
ISIZE		DW 31 DUP(0)
IVOL_FINETUNE	DW 31 DUP(0)
ILOOP_START	DW 31 DUP(0)
ILOOP_SIZE	DW 31 DUP(0)
SONG_SIZE	DB 0
SONG_LOOP	DB 0
MOD_SIGN	DD 0
SAMPLE_SEG	DW 31 DUP(0)
;-----------------------------------------------------------------------------
; SINGLE SAMPLE VARIABLES
;-----------------------------------------------------------------------------
SAMPLE_ZEIG	DW 0
SAMPLE_MEM	DW 48 DUP(0)
SAMPLE_BIG	DW 48 DUP(0)
EMS_SEG		DW 0
EMS_OFFSET	DW 0
EMS_HANDLE	DW 0
SAM_SEG1	DW 0
SAM_SEG2	DW 0
SAM_OFS1	DD 0
SAM_OFS2	DD 0
SAM_FRQ1	DW 0
SAM_FRQ2	DW 0
SAM_OFL1	DB 0
SAM_OFL2	DB 0
SAM_MAX1	DW 0
SAM_MAX2	DW 0
;-----------------------------------------------------------------------------
PROG_END        LABEL   BYTE    ;THIS MUST BE THE LAST ROW IN DATA SEGMENT!
;-----------------------------------------------------------------------------



.386
.CODE 
ORG 100H
;=============================================================================
MAIN PROC NEAR
	JMP	MAIN_CONT		;0100
	RETF
	CALL	CONFIG_INIT		;0104
	RETF
	CALL	LOAD_MOD		;0108
	RETF
	CALL	PLAY_MUSIC		;010C
	RETF
	CALL	STOP_MUSIC		;0110
	RETF
	CALL	END_MUSIC		;0114
	RETF
	CALL	LOAD_SAMPLE		;0118
	RETF
	CALL	PLAY_SAMPLE		;011C
	RETF
	CALL	END_SAMPLE		;0120
	RETF
	CALL	SET_SAMPLERATE		;0124
	RETF
	CALL	GET_VOLUME		;0128
	RETF
	CALL	SET_VOLUME		;012C
	RETF
	CALL	SET_SONGLOOP		;0130
	RETF
	CALL	GET_SONGPOSITION	;0134
	RETF
	CALL	SET_SONGPOSITION	;0138
	RETF
	CALL	GET_SONGMOD		;013C
	RETF
	CALL	SET_SONGMOD		;0140
	RETF
	CALL	DSP_OFF			;0144
	RETF
	CALL	DSP_RESET		;0148
	RETF
	CALL	DSP_RESET		;014C/FREE
	RETF
	CALL	DSP_RESET		;0150/FREE
	RETF
MAIN ENDP
;=============================================================================
;
; MOD ROUTINES
;
;=============================================================================
; Format of a note: (ORIGINALLY MOD)
;
;                   0 0          0 0          0 0           0 0
;                   | |          | |          | |           | |
;                  /   \        / /          /   \           \ \
;         MSB of Ins.     Note        LSB Ins.  Spec. Com.   Data for special
;
; Format of a note: (MODIFIED BY LOADER)
;
;                   0 0          0 0          0 0           0 0
;                   | |          | |          | |           | |
;                  / /          /   \         \ \           \ \
;            LSB NOTE   SPEC.COM.    MSB NOTE  INSTRUMENT    DATA FOR SPECIAL
;
;ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸
;³ DESCRIPTION: This procedure shouldn't need to be called by anything else  ³
;³              but the interrupt (ever).  It handles all note updating,     ³
;³              special effects, pointers, etc.                              ³
;³                                                                           ³
;³              *** This code came directly from the Amiga Protracker        ³
;³                  playback code, written by Lars "Zap" Hamre.  Give this   ³
;³                  guy a pat on the back for such excellent code.           ³
;³                                                                           ³
;³ BUGS       : Or rather, non-implementations.  Command EF - Funk it is     ³
;³              not all the way implemented.  Command E0 - Filter is not     ³
;³              implemented at all.  It is Amiga-specific, directly with     ³
;³              the Paula chip.                                              ³
;³                                                                           ³
;³ IMPROVEMENTS:    Optimized code for PC-architecure by the Frontman        ³
;³                                                                           ³
;ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾
CONTROL_CHANNELS PROC NEAR
	CMP	MOD_STAT,3
	JAE	Go_NoNewPosYet
	INC	MT_COUNTER
	MOV	AL,MT_COUNTER
	CMP	AL,MT_SPEED		; Does it match the current speed?
	JB	SHORT Go_NoNewNote	; No, just do fx.
	MOV	MT_COUNTER,0
	CMP	MT_PATTDELAYTIME2,0
	JE	SHORT Go_GetNewNote
        CALL	Go_CheckEfx		; Otherwise, just do fx only.
        JMP	Go_Dskip                ; Then, jump to update block values.
Go_NoNewNote:
	CALL	Go_CheckEfx		; Do fx.
        JMP	Go_NoNewPosYet		; We don't update block values
					; when we are just doing fx.
Go_GetNewNote:
	MOV	ES,TRACK_SEG
	XOR	SI,SI
Go_PlayVoice:
	PUSH	SI
	MOV	DI,SI
	SHL	DI,1
	MOVZX	BX,MT_SONGPOS		; BLOCK BEGINNING TO ES:BX
	ADD	BX,[TRACKS_OFFSET+DI]
	MOVZX	BX,[BX]
	XCHG	BL,BH			; MULTIPLY WITH 256 (TRACK-SIZE)
	ADD	BX,MT_PATTERNPOS
	CMP	[NOTE+DI],0		; See if there is a note.
	JNE	SHORT Go_plvskip	; No, go on.
	CMP	[CMD+SI],0
	JNE	SHORT Go_plvskip
	CMP	[CMDLO+SI],0
	JNE	SHORT Go_plvskip
	CALL	Go_PerNop		; Otherwise, figure out the frequency.
Go_plvskip:
	MOV	AX,ES:[BX]		; Load this channel's information
	MOV	[NOTE+DI],AX		; from the actual track block and
	AND	[NOTE+DI],0FFFH
	SHR	AH,4			; into our own internal structure
	MOV	[CMD+SI],AH		; to access it from.
	MOV	AX,ES:[BX+2]
	MOV	[CMDLO+SI],AH
	OR	AL,AL			; Instrument byte.  Is there an ins?
	JZ	SHORT Go_SetRegs
	DEC	AL
	MOVZX	BX,AL			; GET SAMPLE SEGMENT
	SHL	BX,1
	MOV	AX,[SAMPLE_SEG+BX]
	MOV	[START+DI],AX		; Store it in our structure.
	MOV	AX,[ISIZE+BX]		; Get the length.
	MOV	[LENGTHI+DI],AX		; Store it appropriately.
	MOV	[REPLEN+DI],AX
	MOV	AX,[IVOL_FINETUNE+BX]	; Get the instrument volume and fine tune.
	MOV	[VOLUME+SI],AL		; Store it appropriately.
	MOV	[FINETUNE+SI],AH
	MOV	[MVOL+SI],AL
	MOV	CX,[ILOOP_SIZE+BX]	; Get Repeat length
	CMP	CX,8			; If the length is less than four,
	JB	SHORT Go_NoLoop		; then there is no loop.
	MOV	AX,[ILOOP_START+BX]	; Get the Repeat start.
	MOV	[MREPEAT+DI],AX		; Move it into the appropriate
	MOV	[LOOPSTART+DI],AX	; structures and locations.
	MOV	[REPLEN+DI],CX		; Move the length into its storage.
	ADD	AX,CX			; We're figuring out the offset of
	MOV	[MREPLEN+DI],AX
	MOV	[MMAXREP+DI],AX		; where the repeat length breaks.
	JMP	SHORT Go_SetRegs	; Skip the no loop part.
Go_NoLoop:
	XOR	AX,AX			; Zero out AX.
	MOV	[MREPLEN+DI],AX		; Make sure that no loop exists and
	MOV	[MREPEAT+DI],AX
	MOV	[LOOPSTART+DI],AX
Go_SetRegs:
	CMP	[NOTE+DI],0		; Grab the note.
	JE	Go_CheckMore		; Check the fx.
	MOV	AH,[CMD+SI]		; Get the special fx command.
	MOV	AL,[CMDLO+SI]
	AND	AL,0F0H			; Mask out the bits we don't want.
	CMP	AX,0E50H		; Is there a fine tune command
	JE	SHORT Go_DoSetFineTune
	CMP	AH,3			; Is it a tone portamento?
	JE	SHORT Go_ChkTonePorta
	CMP	AH,5			; Is it a tone and volume slide?
	JE	SHORT Go_ChkTonePorta
	CMP	AH,9			; Is it a sample offset command?
	JNE	SHORT Go_SetPeriod	; If not, go do the actual note.
	PUSH	AX			; keep the command byte in mem
	CALL	Go_CheckMoreEfx
	POP	AX
	JMP	SHORT Go_SetPeriod	; Go do the actual note.
Go_ChkTonePorta:
	CALL	Go_SetTonePorta		; Do part of the tone portamento.
	JMP	Go_CheckMore		; Go do the fx.
Go_DoSetFineTune:
	PUSH	AX
	CALL	Go_SetFineTune		; Update the fine tune.
	POP	AX
;-----------------------------------------------------------------------------
; ÄÄÄÄ We are now going to find the note in the period table.  If it
; ÄÄÄÄ doesn't exist, then no fine tuning can be performed.  If it
; ÄÄÄÄ does, and fine tuning is specified, then we can update it.
;-----------------------------------------------------------------------------
Go_SetPeriod:
	MOV	CL,AH
	MOV	AX,[NOTE+DI]		; Get the note.
	DEC	AX
	MOV	BX,OFFSET MT_PERIODTABLE; Set pointer to beginning of table.
	CMP	CL,3
	JE	SHORT Seek_Period
	CMP	CL,5
	JNE	SHORT Go_ftufound
Seek_Period:
	INC	AX
	MOV	CX,36+12		; 36 periods to cycle through.
Go_ftuloop:
	CMP	AX,[BX]			; Check the note against the period.
	JAE	SHORT Go_Wizzyfound	; We found it!
	INC	BX
	INC	BX			; Otherwise, update the pointer and
	LOOP	Go_ftuloop		; keep looping.
	JMP	SHORT Go_Wizzyfound
Go_ftufound:
	ADD	BX,AX
Go_WizzyFound:
	MOV	AL,[FINETUNE+SI]	; Get the fine tune.
	MOV	CL,(36+12)*2		; The period table's size is 72.
	MUL	CL			; Multiply it by the fine tune.
	ADD	BX,AX			; Add it onto the pointer to point to
	MOV	AX,[BX]			; the new period and get it.
	MOV	[PERIOD+DI],AX		; Store it.
	MOV	AH,[CMD+SI]		; Get the special fx command.
	MOV	AL,[CMDLO+SI]
	AND	AL,0F0H			; Mask out the bits we don't want.
	CMP	AX,0ED0H
	JE	SHORT Go_delnoc
	MOV	AL,[WAVECONTROL+SI]	; Get the WaveControl.
	TEST	AL,00000100B		; Amiga: BTST #2,WaveControl.
	JZ	SHORT Go_vibnoc		; If it is zero, then skip.
	MOV	[VIBRATOPOS+SI],0
Go_vibnoc:
	TEST	AL,01000000B		; Amiga: BTST #6,WaveControl
	JZ	SHORT Go_trenoc		; If it is zero, then skip.
	MOV	[TREMOLOPOS+SI],0	; Zero the Tremolo offset.
Go_trenoc:
	MOV	AX,[START+DI]		; Get the start segment.
	MOV	[MSEG+DI],AX		; Store it to be updated.
	MOV	[MOFS+DI],0		; Set the offset to zero.
	MOV	[MOFLOW+SI],0
	MOV	AX,[LENGTHI+DI]
	MOV	[MMAXREP+DI],AX		; Store in MaxRepeat
	MOV	CX,[PERIOD+DI]
	CALL	Go_PerNop2
	JMP	SHORT Go_CheckMore
Go_delnoc:
	MOV	AX,[MMAXREP+DI]
	MOV	[MOFS+DI],AX
Go_CheckMore:
	CALL	Go_CheckMoreEfx
Go_DoNext:
	POP	SI			;SKIP TO NEXT CHANNEL
	INC	SI
	CMP	SI,CH_NUMB
	JB	Go_PlayVoice
;-----------------------------------------------------------------------------
Go_Dskip:
	ADD	MT_PATTERNPOS,4		; Increment position by one
	MOV	AL,MT_PATTDELAYTIME
	OR	AL,AL
	JZ	SHORT Go_dskc
	MOV	MT_PATTDELAYTIME2,AL
	MOV	MT_PATTDELAYTIME,0
Go_dskc:
	CMP	MT_PATTDELAYTIME2,0
	JE	SHORT Go_dska
	DEC	MT_PATTDELAYTIME2
	JZ	SHORT Go_dska
	SUB	MT_PATTERNPOS,4
Go_dska:
	CMP	MT_PBREAKFLAG,0
	JE	SHORT Go_nnpysk
	MOV	MT_PBREAKFLAG,0
	MOVZX	AX,MT_PBREAKPOS
	MOV	MT_PBREAKPOS,AH
	SHL	AX,2
	MOV	MT_PATTERNPOS,AX
Go_nnpysk:
	CMP	MT_PATTERNPOS,256
	JB	SHORT Go_NoNewPosYet
Go_NextPosition:
	MOVZX	AX,MT_PBREAKPOS
	SHL	AX,2
	MOV	MT_PATTERNPOS,AX
	MOV	MT_PBREAKPOS,0
	MOV	MT_POSJUMPFLAG,0
	MOV	AL,MT_SONGPOS
	INC	AL
	AND	AL,7FH
	CMP	AL,SONG_SIZE
	JB	SHORT Go_NoSongRestart
	MOV	AL,SONG_LOOP
	CMP	AL,SONG_SIZE
	JB	SHORT Go_NoSongRestart
	MOV	MOD_STAT,3
	XOR	AL,AL
Go_NoSongRestart:
	MOV	MT_SONGPOS,AL
Go_NoNewPosYet:
	CMP	MT_POSJUMPFLAG,0
	JNE	Go_NextPosition
	RET
CONTROL_CHANNELS ENDP
;=============================================================================
Go_CheckEfx PROC NEAR
	XOR	SI,SI
Go_DoEfx:
	PUSH	SI
	MOV	DI,SI
	SHL	DI,1
	MOV	BL,[CMD+SI]              ; Get the special command
	MOV	BH,[CMDLO+SI]
	OR	BX,BX
	JNZ	SHORT SetBack1
	CALL	Go_PerNop
	JMP	SHORT SetBack2
SetBack1:
	XOR	BH,BH
	SHL	BX,1
	CALL	[Effect_Jump_Table1+BX]
SetBack2:
	POP	SI
	INC	SI
	CMP	SI,CH_NUMB
	JB	Go_DoEfx
Go_Return:
	RET
;-----------------------------------------------------------------------------
Go_PerNop PROC NEAR
	MOV	CX,[PERIOD+DI]
Go_PerNop2 PROC NEAR
	XOR	AX,AX
	JCXZ	SHORT Go_DivZero
	MOV	AX,WORD PTR MAINFREQ
	MOV	DX,WORD PTR MAINFREQ+2
	DIV	CX
Go_DivZero:
	MOV	[MFREQ+DI],AX
	RET
Go_PerNop2 ENDP
Go_PerNop ENDP
Go_CheckEfx ENDP
;=============================================================================
;
; SI IS THE CHANNEL-BYTE-INDEX, DI IS THE CHANNEL-WORD-INDEX
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 0 -- Arpeggio
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_Arpeggio PROC NEAR
	MOVZX	AX,MT_COUNTER
	MOV	BL,3
	MOV	CX,[PERIOD+DI]
	DIV	BL
	OR	AH,AH
	JZ	SHORT Go_Arpeggio1
	MOV	AL,[CMDLO+SI]
	CMP	AH,2
	JE	SHORT Go_Arpeggio2
	SHR	AL,4
Go_Arpeggio2:
	AND	AL,0FH
	SHL	AL,1
	MOVZX	BX,AL
	MOV	AL,[FINETUNE+SI]
	MOV	DX,CX
	MOV	CL,(36+12)*2
	MUL	CL
	PUSH	DI
	MOV	DI,OFFSET MT_PERIODTABLE
	ADD	DI,AX
	MOV	AH,36+12
Go_arploop:
	MOV	CX,[BX+DI]
	CMP	DX,[DI]
	JAE	SHORT Go_arpafterloop
        INC	DI
	INC	DI
	DEC	AH
	JNZ	Go_arploop
	POP	DI
	RET
Go_arpafterloop:
	POP	DI
Go_Arpeggio1:
	CALL	Go_PerNop2
        RET
Go_Arpeggio ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 1 -- Portamento Up
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_PortaUp PROC NEAR
	MOVZX	AX,[CMDLO+SI]		; Number to slide up (was lo)
	AND	AL,MT_LOWMASK
	MOV	MT_LOWMASK,0FFH
	SUB	[PERIOD+DI],AX
	MOV	CX,[PERIOD+DI]
	CMP	CX,113
	JGE	SHORT Go_PortaUSkip
	MOV	CX,113
	MOV	[PERIOD+DI],CX
Go_PortaUSkip:
	CALL	Go_PerNop2
	RET
Go_PortaUp ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 2 -- Portamento Down
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_PortaDown PROC NEAR
	MOVZX	AX,[CMDLO+SI]		; Number to slide down
	AND	AL,MT_LOWMASK
	MOV	MT_LOWMASK,0FFH
	ADD	[PERIOD+DI],AX
	MOV	CX,[PERIOD+DI]
	CMP	CX,856
	JL	SHORT Go_PortaDSkip
	MOV	CX,856
	MOV	[PERIOD+DI],CX
Go_PortaDSkip:
	CALL	Go_PerNop2
	RET
Go_PortaDown ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 3 -- Tone Portamento
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_TonePortamento PROC NEAR
	MOV	AL,[CMDLO+SI]
	OR	AL,AL
	JZ	SHORT Go_TonePortNoChange
	MOV	[TONEPORTSPEED+SI],AL
	MOV	[CMDLO+SI],0
Go_TonePortNoChange:
	CMP	[WANTEDPERIOD+DI],0
	JZ	Go_Return
	MOVZX	DX,[TONEPORTSPEED+SI]
	MOV	CX,[PERIOD+DI]
	MOV	AX,[WANTEDPERIOD+DI]
	CMP	[TONEPORTDIREC+SI],0
	JNE	SHORT Go_TonePortaUp
Go_TonePortaDown:
	ADD	CX,DX
	CMP	AX,CX
	JG	SHORT Go_TonePortaSetPer
	JMP	SHORT Go_TonePortaEnd
Go_TonePortaUp:
	SUB	CX,DX
	CMP	AX,CX
	JL	SHORT Go_TonePortaSetPer
Go_TonePortaEnd:
	MOV	CX,AX
	MOV	[WANTEDPERIOD+DI],0
Go_TonePortaSetPer:
	MOV	[PERIOD+DI],CX
	MOV	AL,[GLISSFUNK+SI]
	AND	AL,0FH
	JZ	SHORT Go_GlissSkip
	MOV	AL,[FINETUNE+SI]
	MOV	BL,(36+12)*2
	MUL	BL
	PUSH	DI
	MOV	DI,OFFSET MT_PERIODTABLE
	ADD	DI,AX
	XOR	BX,BX
Go_GlissLoop:
	CMP	CX,[BX+DI]
	JAE	SHORT Go_GlissFound
	INC	BX
	INC	BX
	CMP	BX,(36+12)*2
	JB	Go_GlissLoop
	MOV	BX,(35+12)*2
Go_GlissFound:
	MOV	CX,[BX+DI]
	POP	DI
Go_GlissSkip:
	CALL	Go_PerNop2
	RET
Go_TonePortamento ENDP
;-----------------------------------------------------------------------------
Go_SetTonePorta PROC NEAR
	MOV	DX,[NOTE+DI]
	MOV	AL,[FINETUNE+SI]
	MOV	CL,48*2			;37
	MUL	CL
	PUSH	DI
	MOV	DI,OFFSET MT_PERIODTABLE
	ADD	DI,AX
	XOR	BX,BX
Go_StpLoop:
	CMP	DX,[BX+DI]
	JAE	SHORT Go_StpFound
	INC	BX
	INC	BX
	CMP	BX,48*2			;37
	JB	Go_StpLoop
	MOV	BX,47*2			;35
Go_StpFound:
	MOV	DL,[FINETUNE+SI]
	AND	DL,8
	JZ	SHORT Go_StpGoss
	OR	BX,BX
	JZ	SHORT Go_StpGoss
	DEC	BX
	DEC	BX
Go_StpGoss:
	MOV	DX,[BX+DI]
	POP	DI
	MOV	[WANTEDPERIOD+DI],DX
	MOV	AX,[PERIOD+DI]
	MOV	[TONEPORTDIREC+SI],0
	CMP	DX,AX
	JE	SHORT Go_ClearTonePorta
	JA	Go_Return
	INC	[TONEPORTDIREC+SI]
	RET
Go_ClearTonePorta:
	MOV	[WANTEDPERIOD+DI],0
	RET
Go_SetTonePorta ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 4 -- Vibrato
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_Vibrato PROC NEAR
	MOV	AL,[CMDLO+SI]
	OR	AL,AL
	JZ	SHORT Go_Vibrato2
	MOV	BL,[VIBRATOCMD+SI]
	AND	AL,0FH
	JZ	SHORT Go_vibskip
	AND	BL,0F0H
	OR	BL,AL
Go_vibskip:
	MOV	AL,[CMDLO+SI]
	AND	AL,0F0H
	JZ	SHORT Go_vibskip2
	AND	BL,0FH
	OR	BL,AL
Go_vibskip2:
	MOV	[VIBRATOCMD+SI],BL
Go_Vibrato2:
	MOV	AL,[VIBRATOPOS+SI]
	SHR	AL,2
	AND	AX,1FH
	MOV	BL,[WAVECONTROL+SI]
	AND	BL,3
	JZ	SHORT Go_vib_sine
	SHL	AL,3
	CMP	BL,1
	JE	SHORT Go_vib_rampdown
	MOV	BL,255
	JMP	SHORT Go_vib_set
Go_vib_rampdown:
	CMP	[VIBRATOPOS+SI],0
	JG	SHORT Go_vib_rampdown2
	MOV	BL,AL
	NOT	BL
	JMP	SHORT Go_vib_set
Go_vib_rampdown2:
	MOV	BL,AL
	JMP	SHORT Go_vib_set
Go_vib_sine:
	MOVZX	BX,AL
	MOV	BL,[MT_VIBRATOTABLE+BX]
Go_vib_set:
	MOV	AL,[VIBRATOCMD+SI]
	AND	AL,0FH
	MUL	BL
	SHR	AX,7
	MOV	BX,AX
	MOV	AX,[PERIOD+DI]
	CMP	[VIBRATOPOS+SI],0
	JG	SHORT Go_VibratoNeg	; BMI
	NEG	BX
Go_VibratoNeg:
	ADD	AX,BX
Go_Vibrato3:
	MOV	CX,AX
	CALL	Go_PerNop2
	MOV	AL,[VIBRATOCMD+SI]
	AND	AL,0F0H
	SHR	AL,2
	ADD	[VIBRATOPOS+SI],AL
	RET
Go_Vibrato ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 5 -- Tone and Volume Slide
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_TonePlusVolSlide PROC NEAR
	CALL	Go_TonePortNoChange
	JMP	Go_VolumeSlide
Go_TonePlusVolSlide ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 6 -- Vibrato and Volume Slide
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_VibratoPlusVolSlide PROC NEAR
	CALL	Go_Vibrato2		;was mt_vibrato2
	JMP	Go_VolumeSlide
Go_VibratoPlusVolSlide ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 7 -- Tremolo
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_Tremolo PROC NEAR
	MOV	AL,[CMDLO+SI]
	OR	AL,AL
	JZ	SHORT Go_Tremolo2
	MOV	BL,[TREMOLOCMD+SI]
	AND	AL,0FH
	JZ	SHORT Go_treskip
	AND	BL,0F0H
	OR	BL,AL
Go_treskip:
	MOV	AL,[CMDLO+SI]
	AND	AL,0F0H
	JZ	SHORT Go_treskip2
	AND	BL,0FH
	OR	BL,AL
Go_treskip2:
	MOV	[TREMOLOCMD+SI],BL
Go_Tremolo2:
	MOV	AL,[TREMOLOPOS+SI]
	SHR	AL,2
	AND	AX,1FH
	MOV	BL,[WAVECONTROL+SI]
	SHR	BL,4
	AND	BL,3
	JZ	SHORT Go_tre_sine
	SHL	AL,3
	CMP	BL,1
	JE	SHORT Go_tre_rampdown
	MOV	BL,255
	JMP	SHORT Go_tre_set
Go_tre_rampdown:
	CMP	[TREMOLOPOS+SI],0
	JG	SHORT Go_tre_rampdown2
	MOV	BL,AL
	NOT	BL
	JMP	SHORT Go_tre_set
Go_tre_rampdown2:
	MOV	BL,AL
	JMP	SHORT Go_tre_set
Go_tre_sine:
	MOVZX	BX,AL
	MOV	BL,[MT_VIBRATOTABLE+BX]
Go_tre_set:
	MOV	AL,[TREMOLOCMD+SI]
	AND	AL,0FH
	MUL	BL
	MOV	BX,AX
	SHR	BX,6
	MOV	AL,[VOLUME+SI]
	CMP	[TREMOLOPOS+SI],0
	JG	SHORT Go_TremoloNeg		; BMI  jns
	ADD	AL,BL
	JMP	SHORT Go_Tremolo3
Go_TremoloNeg:
	SUB	AL,BL
Go_Tremolo3:
	JNC	SHORT Go_TremoloSkip
	XOR	AX,AX
Go_TremoloSkip:
	CMP	AL,40H
	JBE	SHORT Go_TremoloOK		; BLS
	MOV	AL,40H
Go_TremoloOK:
	MOV	[MVOL+SI],AL			;was ah
	MOV	AL,[TREMOLOCMD+SI]
	AND	AL,0F0H
	SHR	AL,2
	ADD	[TREMOLOPOS+SI],AL
	RET
Go_Tremolo ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect 9 -- Sample Offset
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_SampleOffset PROC NEAR
	MOVZX	AX,[CMDLO+SI]
	OR	AL,AL
	JZ	SHORT Go_sononew
	MOV	[SAMPLEOFFSET+SI],AL
Go_sononew:
	MOVZX	AX,[SAMPLEOFFSET+SI]
	XCHG	AL,AH
	CMP	AX,[MMAXREP+DI]
	JAE	SHORT Go_sofskip
	MOV	[MOFS+DI],AX
	RET
Go_sofskip:
	MOV	AX,[MOFS+DI]
	MOV	[MMAXREP+DI],AX
	RET
Go_SampleOffset ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect A -- Volume Slide
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_VolumeSlide PROC NEAR
	MOV	AL,[CMDLO+SI]
	SHR	AL,4
	OR	AL,AL
	JZ	SHORT Go_VolSlideDown
Go_VolSlideUp:
	ADD	[VOLUME+SI],AL
	CMP	[VOLUME+SI],40H
	JBE	SHORT Go_vsdskip
	MOV	[VOLUME+SI],40H
	JMP	SHORT Go_vsdskip
Go_VolSlideDown:
	MOV	AL,[CMDLO+SI]
	AND	AL,0FH
Go_VolSlideDown2:
	SUB	[VOLUME+SI],AL
	JNC	SHORT Go_vsdskip
	MOV	[VOLUME+SI],0
Go_vsdskip:
	MOV	AL,[VOLUME+SI]
	MOV	[MVOL+SI],AL		;was ah
	RET
Go_VolumeSlide ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect B -- Position Jump
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_PositionJump PROC NEAR
	MOV	AL,[CMDLO+SI]		; Get where to jump
	DEC	AL			; Update the
	MOV	MT_SONGPOS,AL		; information.
Go_pj2:	MOV	MT_PBREAKPOS,0
	MOV	MT_POSJUMPFLAG,1
	RET
Go_PositionJump ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect C -- Volume Change
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_VolumeChange PROC NEAR
	MOV	AL,[CMDLO+SI]		; Get value for volume
	CMP	AL,40H			; Is it greater than 40h?
	JBE	SHORT Go_VolumeOK	; Nope
	MOV	AL,40H
Go_VolumeOK:
	MOV	[VOLUME+SI],AL
	MOV	[MVOL+SI],AL		;was ah
	RET
Go_VolumeChange ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect D -- Pattern Break
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_PatternBreak PROC NEAR
	MOV	AL,[CMDLO+SI]		; Break to where?
	MOV	BL,AL			; POSITION IS IN DECIMAL
	SHR	AL,4
	MOV	CL,10
	MUL	CL
	AND	BL,0FH
	ADD	AL,BL
	CMP	AL,63
	JG	Go_pj2
	MOV	MT_PBREAKPOS,AL
	MOV	MT_POSJUMPFLAG,1
	RET
Go_PatternBreak ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect F -- Set Speed
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_SetSpeed PROC NEAR
	MOV	AL,[CMDLO+SI]		; Get value for speed
	OR	AL,AL
	JZ	Go_Return
	CMP	AL,32			; Is it a BPM value ?
	JAE	SHORT Go_SetBPM
	MOV	MT_COUNTER,0
	MOV	MT_SPEED,AL
	RET
Go_SetBPM:
	MOVZX	CX,AL
	ADD	CX,100
	MOV	AX,4500
	XOR	DX,DX
	DIV	CX			; NORMAL BPM SPEED IS 125
	MOV	BPM_SPEED,AL
	RET
Go_SetSpeed ENDP
;=============================================================================
Go_CheckMoreEfx PROC NEAR
	MOVZX	BX,[CMD+SI]
	SHL	BL,1
	JMP	[Effect_Jump_Table2+BX]
Go_CheckMoreEfx ENDP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Effect E
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Go_E_Commands PROC NEAR
	MOVZX	BX,[CMDLO+SI]
	SHR	BL,4
	SHL	BL,1
	MOV	AL,[CMDLO+SI]
	AND	AL,0FH
	JMP	[Effect_Jump_Table3+BX]
;-----------------------------------------------------------------------------
; Effect 0 -- FilterOnOff
; Effect 1 -- Fine Porta Up
;-----------------------------------------------------------------------------
Go_FinePortaUp:
	CMP	MT_COUNTER,0
	JNE	Go_Return
	MOV	MT_LOWMASK,0FH
	JMP	Go_PortaUp
;-----------------------------------------------------------------------------
; Effect 2 -- Fine Porta Down
;-----------------------------------------------------------------------------
Go_FinePortaDown:
	CMP	MT_COUNTER,0
	JNE	Go_Return
	MOV	MT_LOWMASK,0FH
	JMP	Go_PortaDown
;-----------------------------------------------------------------------------
; Effect 3 -- Set Gliss Control
;-----------------------------------------------------------------------------
Go_SetGlissControl:
	AND	[GLISSFUNK+SI],0F0H
	OR	[GLISSFUNK+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect 4 -- Set Vibrato Control
;-----------------------------------------------------------------------------
Go_SetVibratoControl:
	AND	[WAVECONTROL+SI],0F0H
	OR	[WAVECONTROL+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect 5 -- Set Fine Tune
;-----------------------------------------------------------------------------
Go_SetFineTune:
	MOV	[FINETUNE+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect 6 -- Jump Loop
;-----------------------------------------------------------------------------
Go_JumpLoop:
	CMP	MT_COUNTER,0
	JNE	Go_Return
	OR	AL,AL
	JZ	SHORT Go_SetLoop
	CMP	[LOOPCOUNT+SI],0
	JE	SHORT Go_jumpcnt
	DEC	[LOOPCOUNT+SI]
	JZ	Go_Return
Go_jmploop:
	MOV	AL,[PATTPOS+SI]
	MOV	MT_PBREAKPOS,AL
	MOV	MT_PBREAKFLAG,1
	RET
Go_jumpcnt:
	MOV	[LOOPCOUNT+SI],AL
	JMP	Go_jmploop
Go_SetLoop:
	MOV	AX,MT_PATTERNPOS
	SHR	AX,2
	MOV	[PATTPOS+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect 7 -- Set Tremolo Control
;-----------------------------------------------------------------------------
Go_SetTremoloControl:
	SHL	AL,4
	AND	[WAVECONTROL+SI],0FH
	OR	[WAVECONTROL+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect 9 -- Retrig Note
;-----------------------------------------------------------------------------
Go_RetrigNote:
	MOV	BL,AL
	OR	BL,BL
	JZ	SHORT Go_rtnend
	MOVZX	AX,MT_COUNTER
	OR	AL,AL
	JNZ	SHORT Go_rtnskp
	CMP	[NOTE+DI],0
	JNE	SHORT Go_rtnskp
	MOV	MT_COUNTER,0
Go_rtnskp:
	DIV	BL
	XCHG	AL,AH
	OR	AL,AL
	JNZ	SHORT Go_rtnend
Go_DoRetrig:
	XOR	AX,AX
	MOV	[MOFS+DI],AX
	MOV	[MOFLOW+SI],AL
	MOV	AX,[LENGTHI+DI]
	MOV	[MMAXREP+DI],AX
	MOV	AX,[LOOPSTART+DI]
	MOV	[MREPEAT+DI],AX
	ADD	AX,[REPLEN+DI]
	MOV	[MREPLEN+DI],AX
Go_rtnend:
	RET
;-----------------------------------------------------------------------------
; Effect A -- Volume Fine Up
;-----------------------------------------------------------------------------
Go_VolumeFineUp:
	CMP	MT_COUNTER,0
	JNE	Go_Return
	JMP	Go_VolSlideUp
;-----------------------------------------------------------------------------
; Effect B -- Volume Fine Down
;-----------------------------------------------------------------------------
Go_VolumeFineDown:
	CMP	MT_COUNTER,0
	JNZ	Go_Return
	JMP	Go_VolSlideDown2
;-----------------------------------------------------------------------------
; Effect C -- Note Cut
;-----------------------------------------------------------------------------
Go_NoteCut:
	CMP	AL,MT_COUNTER
	JNE	Go_Return
	MOV	[VOLUME+SI],0
	MOV	[MVOL+SI],AL
	RET
;-----------------------------------------------------------------------------
; Effect D -- Note Delay
;-----------------------------------------------------------------------------
Go_NoteDelay:
	CMP	AL,MT_COUNTER
	JNE	Go_Return
	CMP	[NOTE+DI],0
	JE	Go_Return
	JMP	Go_DoRetrig
;-----------------------------------------------------------------------------
; Effect E -- Pattern Delay
;-----------------------------------------------------------------------------
Go_PatternDelay:
	CMP	MT_COUNTER,0
	JNE	Go_Return
	CMP	MT_PATTDELAYTIME2,0
	JNZ	Go_Return
	INC	AL
	MOV	MT_PATTDELAYTIME,AL
	RET
;-----------------------------------------------------------------------------
; Effect F -- Funk It
;-----------------------------------------------------------------------------
Go_E_Commands ENDP
;=============================================================================


;=============================================================================
MIXUP_CHANNELS PROC NEAR
	CMP	MOD_STAT,3		;MOD HAS FINISHED
	JB	SHORT GMX7
	XOR	AX,AX
	XOR	BX,BX
	MOV	CX,MAX_CHAN_NUMB
LMX4:	MOV	[MSEG+BX],AX
	INC	BX
	INC	BX
	LOOP	LMX4
GMX7:	MOV	CX,DMA_CX
	CMP	MOD_STAT,2
	JB	SHORT GMX3
	OUT	0CH,AL			;DMA FLIP-FLOP RESET
	MOVZX	DX,DMA_CHANNEL
	SHL	DL,1
	IN	AL,DX			;GET DMA POSITION
	XCHG	AL,AH
	IN	AL,DX
	XCHG	AL,AH
	SUB	AX,DMA_POFF		;AX IS OFFSET OF DMA-POS
	AND	AX,0FFFEH
	ADD	AX,DMA_MORE
	CMP	AX,DMA_MAX
	JB	SHORT GMX1
	SUB	AX,DMA_MAX
GMX1:	ADD	AX,DMA_OFFSET
	SUB	AX,DMA_PTR
	JNC	SHORT GMX2
	ADD	AX,DMA_MAX
GMX2:	MOV	CX,AX			;CX IS NUMBER OF BYTES TO CALCULATE
	ADD	AX,DMA_PTR
	SUB	AX,DMA_OFFSET
	SUB	AX,2000H
	JC	SHORT GMX3
	SUB	CX,AX
GMX3:	XOR	BX,BX
	XOR	DI,DI
	CLD
	SHR	CX,1
	JZ	SHORT GMX5
	TEST	SBPRO_FLAG,1
	JNZ	SHORT SBPRO_MIXING	;SB MONO-MIXING
	CALL	MIX_CHANNELA		;INIT BUFFER WITH FIRST CHANNEL
	INC	BX
	INC	DI
	INC	DI
	DEC	CH_NUMB
LMX1:	CALL	MIX_CHANNELM		;MIX CHANNELS
	INC	BX
	INC	DI
	INC	DI
	CMP	BX,CH_NUMB
	JB	LMX1
	INC	CH_NUMB
	CALL	MIX_CHANNELX		;END UP BUFFER WITH LAST CHANNEL
	CALL	MIX_CHANNELS		;SAMPLE1: MIDDLE CHANNEL
LMX2:	MOV	AX,DMA_NEWPTR		;CHECK DMA-BUFFER OVERFLOW
	MOV	SI,DMA_MAX		;ITS A RING BUFFER
	ADD	SI,DMA_OFFSET
	CMP	AX,SI
	JB	SHORT GMX4
	MOV	CX,AX
	MOV	DI,DMA_OFFSET
	SUB	CX,SI
	JZ	SHORT GMX6
	CLD
	SHR	CX,1
	PUSH	DS
	MOV	ES,DMA_SEG
	MOV	DS,DMA_SEG
	REP MOVSW			;MOVE OVERFLOW DATA
	POP	DS
GMX6:	MOV	AX,DI
GMX4:	MOV	DMA_PTR,AX		;START DSP OUTPUT
	CMP	MOD_STAT,1
	JNE	SHORT GMX5
	INC	MOD_STAT
	CALL	DSP_OUT
GMX5:	RET
SBPRO_MIXING:
	SHR	CX,1			;SBPRO STEREO-MIXING
	JZ	GMX5
	MOV	AX,[STEREO_PANNING+DI]
	ADD	DMA_PTR,AX
	CALL	MIX_CHANNELA		;INIT BUFFER WITH FIRST CHANNEL
	INC	BX
	INC	DI
	INC	DI
	MOV	AX,[STEREO_PANNING+DI]
	ADD	DMA_PTR,AX
	CALL	MIX_CHANNELA		;THIS CHANNEL SHOULD BE ON RIGHT
	INC	BX			;(OTHERWISE DMA_NEWPTR IS 2 TOO HIGH)
	INC	DI
	INC	DI
LMX3:	MOV	AX,[STEREO_PANNING+DI]
	ADD	DMA_PTR,AX
	CALL	MIX_CHANNELM		;MIX CHANNELS
	INC	BX
	INC	DI
	INC	DI
	CMP	BX,CH_NUMB
	JB	LMX3
	MOV	AX,[STEREO_PANNING+DI]
	ADD	DMA_PTR,AX
	PUSH	CX
	CALL	MIX_CHANNELS1		;SAMPLE1: LEFT CHANNEL
	POP	CX
	SUB	DMA_PTR,2
	PUSH	CX
	CALL	MIX_CHANNELS2		;SAMPLE2: RIGHT CHANNEL
	POP	CX
	CALL	FIXUP_CHANNELS		;END UP CHANNEL BY CONVERTING IT TO PC
	JMP	LMX2
MIXUP_CHANNELS ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELA PROC NEAR
	PUSH	CX BX DI
	MOV	SI,[MOFS+DI]		;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,[MFREQ+DI]		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,[MOFLOW+BX]		;ACTUAL AFTER FIXED POINT VALUE
	MOV	AL,[MVOL+BX]		;SAMPLE VOLUME
	MOV	BL,MUSIC_VOL		;MASTER VOLUME
	MUL	BL
	XOR	AL,AL
	ADD	AX,MIXMUL_OFFSET
	MOV	BX,AX			;DS:BX POINTS INTO MIXMUL_VOLUMETABLE
	MOV	ES,[MSEG+DI]
	MOV	AX,[MMAXREP+DI]		;SP IS OFFSET OF SAMPLE ENDING
	MOV	WORD PTR SELFM1+2,AX
	MOV	WORD PTR SELFM2+2,AX
	MOV	AL,2
CLEAR_PENT_PREF1:
	DEC	AL			;CLEAR ALSO PENTIUM PQ!!
	JNZ	CLEAR_PENT_PREF1
	JMP	SHORT CLEAR_PREF1	;CLEAR PREFETCH QUEUE!!!
CLEAR_PREF1:
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	MOV	AX,ES			;ES:SI IS SAMPLE-DATA POINTER
	OR	AX,AX
	JZ	SHORT SILENT_FILLA
MIX_LOOPA:
SELFM1:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLA
	MOV	AH,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
SELFM2:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLA
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	XLATB
	XCHG	AL,AH
	XLATB
	MOV	[DI],AX
SELFN1:	ADD	DI,2			;SELFMODIFYING CODE
	LOOP	MIX_LOOPA
MIX_ENDA:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,ES
	MOV	DMA_NEWPTR,DI
	POP	DI BX CX
	MOV	[MSEG+DI],AX
	MOV	[MOFLOW+BX],DH
	MOV	[MOFS+DI],SI
	RET
REST_FILLA:
	POP	SI
	PUSH	SI
	MOV	AX,CS:[MREPLEN+SI]
	OR	AX,AX
	JZ	SHORT SILENT_FILLA
	MOV	CS:[MMAXREP+SI],AX
	MOV	WORD PTR CS:SELFM1+2,AX
	MOV	WORD PTR CS:SELFM2+2,AX
	MOV	SI,CS:[MREPEAT+SI]
	JMP	MIX_LOOPA
SILENT_FILLA:
	MOV	BX,DS
	MOV	ES,BX
	TEST	CS:SBPRO_FLAG,1
	JNZ	SHORT SILENT_FILLB
	REP STOSW
	MOV	ES,AX
	JMP	MIX_ENDA
SILENT_FILLB:
	STOSW
	INC	DI
	INC	DI
	LOOP	SILENT_FILLB
	MOV	ES,AX
	JMP	MIX_ENDA
MIX_CHANNELA ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELM PROC NEAR
	PUSH	CX BX DI
	MOV	SI,[MOFS+DI]		;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,[MFREQ+DI]		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,[MOFLOW+BX]		;ACTUAL AFTER FIXED POINT VALUE
	MOV	AL,[MVOL+BX]		;SAMPLE VOLUME
	MOV	BL,MUSIC_VOL		;MASTER VOLUME
	MUL	BL
	XOR	AL,AL
	ADD	AX,MIXMUL_OFFSET
	MOV	BX,AX			;DS:BX POINTS INTO MIXMUL_VOLUMETABLE
	MOV	ES,[MSEG+DI]
	MOV	AX,[MMAXREP+DI]		;OFFSET OF SAMPLE ENDING
	MOV	WORD PTR SELFM3+2,AX
	MOV	WORD PTR SELFM4+2,AX
	MOV	AL,2
CLEAR_PENT_PREF2:
	DEC	AL			;CLEAR ALSO PENTIUM PQ!!
	JNZ	CLEAR_PENT_PREF2
	JMP	SHORT CLEAR_PREF2	;CLEAR PREFETCH QUEUE!!!
CLEAR_PREF2:
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	MOV	AX,ES
	OR	AX,AX
	JZ	SHORT MIX_ENDM
MIX_LOOPM:
SELFM3:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLM
	MOV	AH,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
SELFM4:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLM
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	XLATB
	XCHG	AL,AH
	XLATB
	ADD	[DI],AX
SELFN2:	ADD	DI,2			;SELFMODIFYING CODE
	LOOP	MIX_LOOPM
MIX_ENDM:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,ES
	POP	DI BX CX
	MOV	[MSEG+DI],AX
	MOV	[MOFLOW+BX],DH
	MOV	[MOFS+DI],SI
	RET
REST_FILLM:
	POP	SI
	PUSH	SI
	MOV	AX,CS:[MREPLEN+SI]
	OR	AX,AX
	JZ	SHORT SILENT_FILLM
	MOV	CS:[MMAXREP+SI],AX
	MOV	WORD PTR CS:SELFM3+2,AX
	MOV	WORD PTR CS:SELFM4+2,AX
	MOV	SI,CS:[MREPEAT+SI]
	JMP	MIX_LOOPM
SILENT_FILLM:
	MOV	ES,AX
	JMP	MIX_ENDM
MIX_CHANNELM ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELX PROC NEAR
	PUSH	CX BX DI
	MOV	SI,[MOFS+DI]		;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,[MFREQ+DI]		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,[MOFLOW+BX]		;ACTUAL AFTER FIXED POINT VALUE
	MOV	AL,[MVOL+BX]		;SAMPLE VOLUME
	MOV	BL,MUSIC_VOL		;MASTER VOLUME
	MUL	BL
	XOR	AL,AL
	ADD	AX,MIXMUL_OFFSET
	MOV	BX,AX			;DS:BX POINTS INTO MIXMUL_VOLUMETABLE
	MOV	ES,[MSEG+DI]
	MOV	AX,[MMAXREP+DI]		;SP IS OFFSET OF SAMPLE ENDING
	MOV	WORD PTR SELFM5+2,AX
	MOV	WORD PTR SELFM6+2,AX
	MOV	WORD PTR SELFM7+2,8080H
	CMP	SAM_SEG1,0
	JE	SHORT NO_SAMPLES
	MOV	WORD PTR SELFM7+2,0
NO_SAMPLES:
	MOV	AL,2
CLEAR_PENT_PREF3:
	DEC	AL			;CLEAR ALSO PENTIUM PQ!!
	JNZ	CLEAR_PENT_PREF3
	JMP	SHORT CLEAR_PREF3	;CLEAR PREFETCH QUEUE!!!
CLEAR_PREF3:
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	MOV	AX,ES			;ES:SI IS SAMPLE-DATA POINTER
	OR	AX,AX
	JZ	SHORT SILENT_FILLX
MIX_LOOPX:
SELFM5:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLX
	MOV	AH,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
SELFM6:	CMP	SI,0FFFFH		;SELFMODIFYING CODE
	JAE	SHORT REST_FILLX
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	XLATB
	XCHG	AL,AH
	XLATB
	ADD	[DI],AX
SELFM7:	XOR	WORD PTR [DI],8080H
	INC	DI
	INC	DI
	LOOP	MIX_LOOPX
MIX_ENDX:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AX,ES
	POP	DI BX CX
	MOV	[MSEG+DI],AX
	MOV	[MOFLOW+BX],DH
	MOV	[MOFS+DI],SI
	RET
REST_FILLX:
	POP	SI
	PUSH	SI
	MOV	AX,CS:[MREPLEN+SI]
	OR	AX,AX
	JZ	SHORT SILENT_FILLX
	MOV	CS:[MMAXREP+SI],AX
	MOV	WORD PTR CS:SELFM5+2,AX
	MOV	WORD PTR CS:SELFM6+2,AX
	MOV	SI,CS:[MREPEAT+SI]
	JMP	MIX_LOOPX
SILENT_FILLX:
	MOV	ES,AX
	CMP	CS:[SAM_SEG1],0
	JNE	MIX_ENDX
SILENT_FILLL:
	XOR	WORD PTR [DI],8080H
	INC	DI
	INC	DI
	LOOP	SILENT_FILLL
	JMP	MIX_ENDX
MIX_CHANNELX ENDP
;-----------------------------------------------------------------------------
FIXUP_CHANNELS PROC NEAR
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG
FIXUP_LOOP:
	XOR	DWORD PTR [DI],80808080H
	INC	DI
	ROL	WORD PTR [DI],8
	ADD	DI,3
	LOOP	FIXUP_LOOP
	MOV	AX,CS
	MOV	DS,AX
	RET
FIXUP_CHANNELS ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELS PROC NEAR
	CMP	SAM_SEG1,0
	JE	SHORT GO_BACKS
	CALL	EMS_SAVE
	PUSH	EAX
	MOV	EAX,SAM_OFS1
	CALL	EMS_PAGING
	POP	EAX
	MOV	SI,DI			;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,SAM_FRQ1		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,SAM_OFL1		;ACTUAL AFTER FIXED POINT VALUE
	MOV	BX,SAM_MAX1		;COUNTER FOR SAMPLE ENDING
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	PUSH	SI
MIX_LOOPS:
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT REST_FILLS
	JZ	SHORT REST_FILLS
	SAR	BYTE PTR [DI],1
	MOV	AH,ES:[SI]
	SAR	BYTE PTR [DI+1],1
	ADD	DH,DL
	ADC	SI,BP
	ADD	[DI],AX
	XOR	WORD PTR [DI],8080H
	INC	DI
	INC	DI
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT REST_FILLS
	JZ	SHORT REST_FILLS
	LOOP	MIX_LOOPS
MIX_ENDS:
	MOV	AX,CS
	MOV	DS,AX
	MOV	SAM_OFL1,DH
	POP	AX
	SUB	SI,AX
	PUSH	EAX
	MOVZX	EAX,SI
	ADD	SAM_OFS1,EAX
	POP	EAX
	MOV	SAM_MAX1,BX
	CALL	EMS_RESTORE
GO_BACKS:
	RET
REST_FILLS:
	MOV	CS:SAM_SEG1,0
SILENT_FILLS:
	XOR	WORD PTR [DI],8080H
	INC	DI
	INC	DI
	LOOP	SILENT_FILLS
	JMP	MIX_ENDS
MIX_CHANNELS ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELS1 PROC NEAR
	CMP	SAM_SEG1,0
	JE	SHORT GO_BACKS1
	CALL	EMS_SAVE
	PUSH	EAX
	MOV	EAX,SAM_OFS1
	CALL	EMS_PAGING
	POP	EAX
	MOV	SI,DI			;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,SAM_FRQ1		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,SAM_OFL1		;ACTUAL AFTER FIXED POINT VALUE
	MOV	BX,SAM_MAX1		;COUNTER FOR SAMPLE ENDING
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	PUSH	SI
MIX_LOOPS1:
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT MIX_ENDS1
	JZ	SHORT MIX_ENDS1
	SAR	BYTE PTR [DI],1
	MOV	AH,ES:[SI]
	SAR	BYTE PTR [DI+1],1
	ADD	DH,DL
	ADC	SI,BP
	ADD	[DI],AX
	ADD	DI,4
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT MIX_ENDS1
	JZ	SHORT MIX_ENDS1
	LOOP	MIX_LOOPS1
MIX_REST1:
	MOV	AX,CS
	MOV	DS,AX
	MOV	SAM_OFL1,DH
	POP	AX
	SUB	SI,AX
	PUSH	EAX
	MOVZX	EAX,SI
	ADD	SAM_OFS1,EAX
	POP	EAX
	MOV	SAM_MAX1,BX
	CALL	EMS_RESTORE
GO_BACKS1:
	RET
MIX_ENDS1:
	MOV	CS:SAM_SEG1,0
	JMP	MIX_REST1
MIX_CHANNELS1 ENDP
;-----------------------------------------------------------------------------
MIX_CHANNELS2 PROC NEAR
	CMP	SAM_SEG2,0
	JE	SHORT GO_BACKS2
	CALL	EMS_SAVE
	PUSH	EAX
	MOV	EAX,SAM_OFS2
	CALL	EMS_PAGING
	POP	EAX
	MOV	SI,DI			;GET OFFSET IN SAMPLE (START ALWAYS= 0)
	MOV	DX,SAM_FRQ2		;OFF ADD AFTER FIXED POINT (X/256)
	MOVZX	BP,DH			;OFF ADD BEFORE FIXED POINT
	MOV	DH,SAM_OFL2		;ACTUAL AFTER FIXED POINT VALUE
	MOV	BX,SAM_MAX2		;COUNTER FOR SAMPLE ENDING
	MOV	DI,DMA_PTR
	MOV	DS,DMA_SEG		;DS:DI IS DMA-BUFFER POINTER
	PUSH	SI
MIX_LOOPS2:
	MOV	AL,ES:[SI]
	ADD	DH,DL
	ADC	SI,BP
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT MIX_ENDS2
	JZ	SHORT MIX_ENDS2
	SAR	BYTE PTR [DI],1
	MOV	AH,ES:[SI]
	SAR	BYTE PTR [DI+1],1
	ADD	DH,DL
	ADC	SI,BP
	ADD	[DI],AX
	ADD	DI,4
	SUB	DH,DL
	ADD	DH,DL
	SBB	BX,BP
	JC	SHORT MIX_ENDS2
	JZ	SHORT MIX_ENDS2
	LOOP	MIX_LOOPS2
MIX_REST2:
	MOV	AX,CS
	MOV	DS,AX
	MOV	SAM_OFL2,DH
	POP	AX
	SUB	SI,AX
	PUSH	EAX
	MOVZX	EAX,SI
	ADD	SAM_OFS2,EAX
	POP	EAX
	MOV	SAM_MAX2,BX
	CALL	EMS_RESTORE
GO_BACKS2:
	RET
MIX_ENDS2:
	MOV	CS:SAM_SEG2,0
	JMP	MIX_REST2
MIX_CHANNELS2 ENDP
;-----------------------------------------------------------------------------
; SET EMS-PAGES
; IN:  EAX= EMS-OFFSET
; OUT: ES:DI= SEGMENT & OFFSET IN EMS PAGE
;-----------------------------------------------------------------------------
EMS_PAGING PROC NEAR
	MOV	DI,AX
	AND	DI,3FFFH
	MOV	ES,EMS_SEG
	PUSHA
	PUSH	EAX
	SHR	EAX,14
	MOV	BX,AX
	XOR	AL,AL
	MOV	DX,EMS_HANDLE
	MOV	AH,44H
	INT	67H
	INC	AL
	INC	BX
	MOV	AH,44H
	INT	67H
	INC	AL
	INC	BX
	MOV	AH,44H
	INT	67H
	INC	AL
	INC	BX
	MOV	AH,44H
	INT	67H
	POP	EAX
	POPA
	RET
EMS_PAGING ENDP
;-----------------------------------------------------------------------------
EMS_SAVE PROC NEAR
	PUSH	AX DX
	MOV	DX,EMS_HANDLE		;EMS MAPPING SAVE
	MOV	AH,47H
	INT	67H
	POP	DX AX
	RET
EMS_SAVE ENDP
;-----------------------------------------------------------------------------
EMS_RESTORE PROC NEAR
	PUSH	AX DX
	MOV	DX,EMS_HANDLE		;EMS MAPPING RESTORE
	MOV	AH,48H
	INT	67H
	POP	DX AX
	RET
EMS_RESTORE ENDP
;ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸
;³ DESCRIPTION: Calculates the values for the mixing multiplication table.   ³
;³              This table is used during 4/8-channel mixing to speed up the ³
;³              operation by avoiding 'mul' instructions.                    ³
;ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾
MAKE_MIXMUL_VOLUMETABLE PROC NEAR
	MOV	ES,DMA_SEG
	MOV	DI,MIXMUL_OFFSET
	CLD
	MOV	CX,CH_NUMB
	SHR	CL,3
	MOV	CH,SBPRO_FLAG
	XOR	BX,BX			; start with volume 0
	INC	BH
VOLUMELOOP:				; start with sample 0
SAMPLELOOP:
	MOV	AL,BL
	XCHG	CL,CH
	IMUL	BH
	OR	AH,AH			; ROUND UP
	JNS	SHORT GMK1
	OR	AL,AL
	JZ	SHORT GMK1
	INC	AH
GMK1:	SAL	AX,CL
	XCHG	CL,CH
	MOV	AL,AH
	SAR	AL,CL			; 8- CHANNEL MIXING
	STOSB
	INC	BL
	JNZ	SAMPLELOOP
	INC	BH
	CMP	BH,64
	JBE	VOLUMELOOP
	RET
MAKE_MIXMUL_VOLUMETABLE ENDP
;=============================================================================


;=============================================================================
;
; DOS ROUTINES
;
;=============================================================================
;-----------------------------------------------------------------------------
; TIMER-IRQ-HANDLER: 1024 HZ CALLING FREQUENCE
;-----------------------------------------------------------------------------
TIMER_HANDLER PROC FAR
	PUSH	AX
	CMP	CS:SYSTEM,0
	JNE	SHORT WT6
	MOV	AL,UHR_STATC
	OUT	UHR_INDEX,AL
	JMP	SHORT WT1
WT1:	JMP	SHORT WT2
WT2:	IN	AL,UHR_PORT
WT6:	MOV     AL,20H
	OUT     IRQ3,AL
	OUT	IRQ1,AL
	CMP	CS:MOD_STAT,0
	JE	SHORT WT3
	DEC	CS:BPM_COUNT		;1024/20= 50 HZ
	JNZ	SHORT WT3
	STI
	PUSHA
	PUSH	DS ES CS
	POP	DS
	MOV	AL,BPM_SPEED
	MOV	BPM_COUNT,AL
	CALL	CONTROL_CHANNELS
	CALL	MIXUP_CHANNELS
	TEST	SB_MODUS,2
	JZ	SHORT WT5
	MOV	MOD_STAT,4
	JMP	SHORT WT4
WT5:	CMP	MOD_STAT,4
	JB	SHORT WT4
	MOV	MOD_STAT,2
WT4:	POP	ES DS
	POPA
WT3:	POP	AX
	CMP	CS:SYSTEM,0
	JE	SHORT WT7
	DEC	CS:IRQCOUNT
	JNZ	SHORT WT7
	MOV	CS:IRQCOUNT,56
	JMP	DWORD PTR CS:[HOLD70]
WT7:	IRET
TIMER_HANDLER ENDP
;-----------------------------------------------------------------------------
; SOUNDBLASTER-IRQ-HANDLER
;-----------------------------------------------------------------------------
SBIRQ_HANDLER PROC FAR
	PUSH    AX CX DX
	MOV	DX,CS:SB_RSTAT		;CLEAR IRQ
	IN	AL,DX
	DEC	DX
	DEC	DX
	MOV	CX,1000H
WUV1:	IN	AL,DX
	OR	AL,AL
	JNS	SHORT WUW1
	LOOP	WUV1
WUW1:	CMP	CS:SBPRO_FLAG,1
	JE	SHORT WUV4
	MOV	AL,14H			;SB MONO
	OUT	DX,AL
	MOV	CX,1000H
WUV2:	IN	AL,DX			;WAIT UNTIL READY
	OR	AL,AL
	JNS	SHORT WUW2
	LOOP	WUV2
WUW2:	MOV	AL,0FFH			;SET MAX BLOCK SIZE
	OUT	DX,AL
	MOV	CX,1000H
WUV3:	IN	AL,DX			;WAIT UNTIL READY
	OR	AL,AL
	JNS	SHORT WUW3
	LOOP	WUV3
WUW3:	MOV	AL,0FFH
	OUT	DX,AL
	MOV	AL,20H
	OUT	IRQ1,AL
	POP	DX CX AX
	IRET
WUV4:	MOV	AL,48H			;SB STEREO
	OUT	DX,AL
	MOV	CX,1000H
WUV5:	IN	AL,DX			;WAIT UNTIL READY
	OR	AL,AL
	JNS	SHORT WUW5
	LOOP	WUV5
WUW5:	MOV	AL,0FFH			;SET MAX BLOCK SIZE
	OUT	DX,AL
	MOV	CX,1000H
WUV6:	IN	AL,DX			;WAIT UNTIL READY
	OR	AL,AL
	JNS	SHORT WUW6
	LOOP	WUV6
WUW6:	MOV	AL,0FFH
	OUT	DX,AL
	MOV	CX,1000H
WUV7:	IN	AL,DX			;WAIT UNTIL READY
	OR	AL,AL
	JNS	SHORT WUW7
	LOOP	WUV7
WUW7:	MOV	AL,91H			;START SBPRO
	OUT	DX,AL
	MOV	AL,20H
	OUT	IRQ1,AL
	POP	DX CX AX
	IRET
SBIRQ_HANDLER ENDP
;-----------------------------------------------------------------------------
; SERVICE IRQ SWAPPING; USES THE REAL-TIME-CLOCK OR TIMER IRQ
;-----------------------------------------------------------------------------
IRQ_INIT PROC NEAR
	CLI
	XOR     AX,AX
	MOV     ES,AX
	CMP	SYSTEM,0
	JNE	WU11
	MOV     AX,COMP_SPEED2		;XCHANGE INIT & STOP DATA FOR DOS
	MOV     DX,COMP_SPEED3
	MOV     COMP_SPEED2,DX
	MOV     COMP_SPEED3,AX
	MOV	AL,UHR_STATA		;SET CLOCK-IRQ-RATE (1024 HZ)
	OUT	UHR_INDEX,AL
	JMP	SHORT WU1
WU1:	JMP	SHORT WU2
WU2:	XCHG	AL,AH
	IN	AL,UHR_PORT
	AND	AL,0F0H
	OR	AL,DL
	XCHG	AL,AH
	OUT	UHR_INDEX,AL
	JMP	SHORT WU3
WU3:	JMP	SHORT WU4
WU4:	XCHG	AL,AH
	OUT	UHR_PORT,AL
	JMP	SHORT WU5
WU5:	JMP	SHORT WU6
WU6:	MOV	AL,UHR_STATB		;SET CLOCK-IRQ-MODUS
	OUT	UHR_INDEX,AL
	JMP	SHORT WU7
WU7:	JMP	SHORT WU8
WU8:	XCHG	AL,AH
	IN	AL,UHR_PORT
	AND	AL,08FH
	MOV	DL,DH
	AND	DL,40H
	OR	AL,DL
	XCHG	AL,AH
	OUT	UHR_INDEX,AL
	JMP	SHORT WU9
WU9:	JMP	SHORT WU10
WU10:	XCHG	AL,AH
	OUT	UHR_PORT,AL
	IN	AL,IRQ4			;IRQ8 DE-/MASK
	AND	AL,0FEH
	MOV	DL,DH
	AND	DL,1
	OR	AL,DL
	OUT	IRQ4,AL
	IN	AL,IRQ2			;SBIRQ DE-/MASK
	MOV	CL,IRQ_NUMBER
	SHL	DL,CL
	MOV	DH,0FEH
	ROL	DH,CL
	AND	AL,DH
	OR	AL,DL
	OUT	IRQ2,AL
	MOV     BX,4*70H                ;CLOCK-IRQ DETOUR
	MOV     EAX,ES:[BX]
	MOV     EDX,HOLD70
	MOV     ES:[BX],EDX
	MOV     HOLD70,EAX
	JMP	WU12
WU11:	MOV     AX,COMP_SPEED4		;FOR WINDOWS
	MOV     DX,COMP_SPEED5
	MOV     COMP_SPEED4,DX
	MOV     COMP_SPEED5,AX
	MOV     AL,00110110B            ;SET TIMER0 TO 1.024 KHZ
	OUT     PIT1,AL                 ;DIVIDER =1193
	MOV     AL,DL
	OUT     TIMER0,AL
	JMP     SHORT OUT40
OUT40:  MOV     AL,DH
	OUT     TIMER0,AL
	MOV     AX,COMP_SPEED2		;XCHANGE INIT & STOP DATA FOR DOS
	MOV     DX,COMP_SPEED3
	MOV     COMP_SPEED2,DX
	MOV     COMP_SPEED3,AX
	IN	AL,IRQ2			;SBIRQ DE-/MASK
	MOV	CL,IRQ_NUMBER
	SHL	DL,CL
	MOV	DH,0FEH
	ROL	DH,CL
	AND	AL,DH
	OR	AL,DL
	OUT	IRQ2,AL
	MOV     BX,4*8H                 ;TIMEOUT-IRQ DETOUR
	MOV     EAX,ES:[BX]
	MOV     EDX,HOLD70
	MOV     ES:[BX],EDX
	MOV     HOLD70,EAX
WU12:	MOV     BL,CL			;SOUNDBLASTER-IRQ DETOUR
	ADD	BL,8
	SHL	BL,2
	XOR	BH,BH
	MOV     EAX,ES:[BX]
	MOV     EDX,HOLDSB
	MOV     ES:[BX],EDX
	MOV     HOLDSB,EAX
	MOV	AL,20H
	OUT	IRQ3,AL
	OUT	IRQ1,AL
	STI
	RET
IRQ_INIT ENDP
;----------------------------------------------------------------------------
; ALLOCATES MEMORY FOR TRACKS, CARRY-FLAG 0=OK 1=ABBRUCH
;----------------------------------------------------------------------------
SET_TMEM PROC NEAR
	MOV     AH,48H
	MOV     BX,1000H                ;64K TRACK BUFFER (WILL BE RESIZED)
	INT     21H
	JC      SHORT STCM1
	MOV     TRACK_SEG,AX
	MOV	AH,48H
	MOV	BX,80H			;2K PATTERN BUFFER
	INT	21H
	JC	SHORT STCM1
	MOV	PATTERN_SEG,AX
STCM1:  RET
SET_TMEM ENDP
;----------------------------------------------------------------------------
; DEALLOCATES MEMORY OF TRACKS
;----------------------------------------------------------------------------
FREE_TMEM PROC NEAR
	MOV	AX,SAMPLE_SEG
	MOV	ES,AX
	MOV	AH,49H
	INT	21H
	MOV     AX,TRACK_SEG
	MOV     ES,AX
	MOV     AH,49H
	INT     21H
	RET
FREE_TMEM ENDP
;----------------------------------------------------------------------------
; ALLOCATES MEMORY OF DMA_BUFFER & MIXMUL_TABLE, CARRY 0=OK 1=ERROR
;----------------------------------------------------------------------------
SET_DMEM PROC NEAR
	MOV     AH,48H
	MOV     BX,0600H                ;24K BUFFER
	INT     21H
	JC      SHORT SDCM1
	MOV     DMA_SEG,AX
	MOV	DMA_OFFSET,0		;DMA_BUFFER CA.  8K
	MOV	MIXMUL_OFFSET,2000H	;MIXMUL_TAB CA. 16K
	AND	AX,0FFFH		;CHECK FOR 64K DMA PAGE
	CMP	AX,0E00H
	JB	SHORT SDCM2
	MOV	DMA_OFFSET,4000H
	MOV	MIXMUL_OFFSET,0
SDCM2:	CLC
SDCM1:  RET
SET_DMEM ENDP
;----------------------------------------------------------------------------
; DEALLOCATES MEMORY OF DMA & MIXMUL_VOLUMETABLE
;----------------------------------------------------------------------------
FREE_DMEM PROC NEAR
	MOV	AX,DMA_SEG
	MOV	ES,AX
	MOV	AH,49H
	INT	21H
	RET
FREE_DMEM ENDP
;-----------------------------------------------------------------------------
FREE_MEM PROC NEAR
	MOV     BX,PROG_END_SEG
	SUB     BX,PROG_START_SEG
	MOV     ES,PROG_START_SEG
	MOV     AH,4AH
	INT     21H
	RET
FREE_MEM ENDP
;=============================================================================



;=============================================================================
;
; SOUNDBLASTER HARDWARE ROUTINES
;
;=============================================================================
; SET MIXER IF PRESENT
;-----------------------------------------------------------------------------
MIXER_INIT PROC NEAR
	MOV	DX,SBP_MIXERI
COMMENT *				
	XOR	AL,AL			;RESET MIXER SWITCHED OFF
	OUT	DX,AL			;BECAUSE IT IS NOT WORKING PROPERLY
	MOV	CX,100			;WITH SB16 ASP (GAIN x2,x3,..)
	CALL	WAIT_TIME
	MOV	DX,SBP_MIXERD
	XOR	AL,AL
	OUT	DX,AL
	DEC	DX
	*
	MOV	AL,22H
	OUT	DX,AL
	INC	DX
	MOV	AL,255			;MAX MASTERVOLUME
	OUT	DX,AL
	DEC	DX
	MOV	AL,2
	OUT	DX,AL
	INC	DX
	MOV	AL,255			;MAX DSPVOLUME
	OUT	DX,AL
	DEC	DX
	MOV	AL,0EH
	OUT	DX,AL
	INC	DX
	MOV	AL,0H			;FILTER & MONO
	MOV	SBPRO_FLAG,AL
	CMP	SB_TYP,1		;SBPRO ENABLED?
	JNE	SHORT GMIX1
	MOV	SBPRO_FLAG,1
	MOV	AL,2H			;FILTER & STEREO
GMIX1:	OUT	DX,AL
	RET
MIXER_INIT ENDP
;-----------------------------------------------------------------------------
; SET DMA READY FOR TRANSFER WITH AUTOINIT
; IN: DX:BX= BLOCKPOINTER, CX= SIZE
;-----------------------------------------------------------------------------
DMA_INIT PROC NEAR
	MOV	AX,DX			;CONVERT ADDRESS TO PAGE AND OFFSET
	SHL	DX,4
	SHR	AH,4			;PAGE
	ADD	BX,DX			;OFFSET NEW
	ADC	AH,0
	MOV	DMA_PAGE,AH
	MOV	DMA_POFF,BX
	DEC	CX			;DMA SIZE= BLOCK SIZE -1
	MOV	AL,DMA_CHANNEL
	OR	AL,4
	OUT	0AH,AL			;DMA-CHANNEL MASK
	AND	AL,3
	OR	AL,01011000B
	OUT	0BH,AL			;DMA-MODUS FOR SB
	OUT	0CH,AL			;FLIP-FLOP CLEAR
	AND	AL,3
	MOVZX	DX,AL
	SHL	DL,1
	MOV	AL,BL			;DMA CHANNEL 1-4
	OUT	DX,AL			;OFFSET LOW
	MOV	AL,BH
	OUT	DX,AL			;OFFSET HIGH
	INC	DL
	MOV	AL,CL
	OUT	DX,AL			;SIZE LOW
	MOV	AL,CH
	OUT	DX,AL			;SIZE HIGH
	MOV	BX,DX
	SHR	BL,1
	MOV	DL,[DMA_DATA+BX]
	MOV	AL,AH
	OUT	DX,AL			;PAGE
	MOV	AL,BL
	OUT	0AH,AL			;DMA-CHANNEL DEMASK
	RET
DMA_INIT ENDP
;-----------------------------------------------------------------------------
; DSP SET SAMPLE RATE
; IN: AH= RATE (= 256-(1000000/FREQ))
;-----------------------------------------------------------------------------
DSP_RATE PROC NEAR
	PUSH	AX
	MOV	AH,40H
	CALL	DSP_WRITE
	POP	AX
	CALL	DSP_WRITE
	RET
DSP_RATE ENDP
;-----------------------------------------------------------------------------
; DSP OUT BLOCK
;-----------------------------------------------------------------------------
DSP_OUT PROC NEAR
	CMP	SBPRO_FLAG,1
	JE	SHORT GDSP1
	MOV	AH,14H			;MONO DMA-OUTPUT NEW
	CALL	DSP_WRITE
	MOV	AH,0FFH			;SIZE LOW
	CALL	DSP_WRITE
	MOV	AH,0FFH			;SIZE HIGH
	CALL	DSP_WRITE
	RET
GDSP1:	MOV	AH,48H			;STEREO DMA-OUTPUT NEW
	CALL	DSP_WRITE
	MOV	AH,0FFH			;SIZE LOW
	CALL	DSP_WRITE
	MOV	AH,0FFH			;SIZE HIGH
	CALL	DSP_WRITE
	MOV	AH,91H			;START
	CALL	DSP_WRITE
	RET
DSP_OUT ENDP
;-----------------------------------------------------------------------------
; DSP RESET
; OUT: CARRY 1= FAILURE
;-----------------------------------------------------------------------------
DSP_RESET PROC NEAR
	CALL	DSP_OFF
	OUT	0DH,AL			;DMA MASTER CLEAR
	CALL	MIXER_INIT
	MOV	DX,SB_RESET
	MOV	AL,1
	OUT	DX,AL			;SEND RESET COMMAND
	MOV	CX,4
	CALL	WAIT_TIME		;WAIT
	XOR	AL,AL
	OUT	DX,AL			;CLEAR RESET COMMAND
	MOV	CX,120
	CALL	WAIT_TIME		;WAIT
	MOV	DX,SB_RSTAT
	IN	AL,DX			;CHECK IF SUCCESSFUL
	OR	AL,AL
	JNS	SHORT GDRES1
	MOV	DX,SB_READ
	IN	AL,DX
	CMP	AL,0AAH
	JNE	SHORT GDRES1
	CALL	DSP_ON
	CLC				;RESET OK
	RET
GDRES1:	STC				;RESET FAILURE
	RET
DSP_RESET ENDP
;-----------------------------------------------------------------------------
; SPEAKER ON
;-----------------------------------------------------------------------------
DSP_ON PROC NEAR
	MOV	AH,0D1H			;SPEAKER ON
	CALL	DSP_WRITE
	MOV	CX,120
	CALL	WAIT_TIME		;WAIT
	RET
DSP_ON ENDP
;-----------------------------------------------------------------------------
; SPEAKER OFF
;-----------------------------------------------------------------------------
DSP_OFF PROC NEAR
	PUSH	CS
	POP	DS
	CMP	SB_TYP,1
	JE	SHORT GDSPF1		;SB
	MOV	AL,DMA_CHANNEL		;DMA DEMASK
	OUT	0AH,AL
	MOV	AH,0D0H			;DMA STOP
	CALL	DSP_WRITE
	MOV	AH,0D3H			;DSP OFF
	CALL	DSP_WRITE
	MOV	CX,240
	CALL	WAIT_TIME		;WAIT
	RET
GDSPF1:	MOV	DX,SBP_MIXERI		;SBPRO
	MOV	AL,22H
	OUT	DX,AL
	INC	DX
	MOV	AL,0			;MIN MASTERVOLUME
	OUT	DX,AL
	DEC	DX
	MOV	AL,2
	OUT	DX,AL
	INC	DX
	MOV	AL,0			;MIN DSPVOLUME
	OUT	DX,AL
	MOV	CX,240
	CALL	WAIT_TIME
	RET
DSP_OFF ENDP
;-----------------------------------------------------------------------------
; READ BYTE
; OUT: AL= BYTE
;-----------------------------------------------------------------------------
DSP_READ PROC NEAR
	MOV	DX,SB_READ
	MOV	CX,-1			;FAIL SAFE
LDRD1:	IN	AL,DX
	CMP	AL,0AAH
	JNE	SHORT LDRD2
	LOOP	LDRD1
LDRD2:	RET
DSP_READ ENDP
;-----------------------------------------------------------------------------
; WRITE BYTE
; IN: AH= BYTE
;-----------------------------------------------------------------------------
DSP_WRITE PROC NEAR
	MOV	DX,SB_WRITE
	MOV	CX,1000H		;FAIL SAFE
LDWR1:	IN	AL,DX
	OR	AL,AL
	JNS	SHORT LDWR2
	LOOP	LDWR1
LDWR2:	MOV	AL,AH
	OUT	DX,AL
	RET
DSP_WRITE ENDP
;-----------------------------------------------------------------------------
; WAIT TIME
; CX = XXX MILLISECONDS
;-----------------------------------------------------------------------------
WAIT_TIME PROC NEAR
	PUSH	AX BX EDX
LWT1:	IN	AL,TIMER0
	MOV	BL,AL
	IN	AL,TIMER0
	MOV	BH,AL
	MOV	EDX,500000		;FAIL SAFE
LWT2:	IN	AL,TIMER0		;1 MILLISEC WAIT
	XCHG	AL,AH
	IN	AL,TIMER0
	XCHG	AL,AH
	SUB	AX,BX
	NEG	AX
	DEC	EDX
	JZ	SHORT LWT3
	CMP	AX,1193
	JB	LWT2
LWT3:	LOOP	LWT1
	POP	EDX BX AX
	RET
WAIT_TIME ENDP
;=============================================================================


;=============================================================================
;
; MOD LOAD ROUTINES
;
;=============================================================================
; LOAD A MODFILE
; DS:DX= FILENAME
;-----------------------------------------------------------------------------
LOAD_MOD PROC NEAR
	MOV	AX,3D00H		;OPEN MOD
	INT	21H
	JC	GLDM1
	PUSH	CS
	POP	DS
	MOV	GDDHANDLE,AX
GLDM0:	CALL	SET_DMEM		;ALLOCATE DMA-BUFFER 
	CALL	SET_TMEM		;ALLOCATE TRACK-BUFFER
	MOV	BX,GDDHANDLE
	MOV	GDDZEIG,0
	MOV	CX,10			;GET SONG-NAME
LLDM1:	CALL	GET_QUEUE
	JC	GLDM2
	LOOP	LLDM1
	MOV	SAMPLE_SIZE,0
	XOR	SI,SI			;31 INSTRUMENTS
LLDM2:	MOV	AX,SAMPLE_SIZE
	MOV	[SAMPLE_SEG+SI],AX
	MOV	CX,11			;INSTRUMENT NAME
LLDM3:	CALL	GET_QUEUE	
	JC	GLDM2
	LOOP	LLDM3
	XOR	EAX,EAX
	CALL	GET_QUEUE		;INSTRUMENT SIZE
	XCHG	AL,AH
	CMP	AX,2
	JAE	SHORT GLDM20
	XOR	AX,AX
GLDM20:	SHL	AX,1
	MOV	[ISIZE+SI],AX		;NO MORE THAN 64K
	OR	EAX,EAX
	JZ	SHORT GLDM9
	SHR	EAX,4
	INC	AX
	ADD	SAMPLE_SIZE,AX
GLDM9:	CALL	GET_QUEUE		;IVOLUME & FINETUNE
	XCHG	AL,AH
	MOV	[IVOL_FINETUNE+SI],AX
	CALL	GET_QUEUE		;ILOOP_START
	XCHG	AL,AH
	SHL	AX,1
	MOV	[ILOOP_START+SI],AX
	CALL	GET_QUEUE		;ILOOP_SIZE
	XCHG	AL,AH
	SHL	AX,1
	MOV	[ILOOP_SIZE+SI],AX
	INC	SI
	INC	SI
	CMP	SI,62
	JB	LLDM2
	CALL	GET_QUEUE		;SONG_SIZE & LOOP_BYTE OR NOTHING
	JC	GLDM2
	MOV	SONG_SIZE,AL
	MOV	SONG_LOOP,AH
	XOR	DX,DX
	MOV	CX,64			;SONG_DATA
	MOV	DI,OFFSET SONG_DATA
LLDM4:	CALL	GET_QUEUE
	JC	GLDM2
	MOV	[DI],AX
	CMP	AL,DL			;FIND HIGHEST PATTERN NUMBER
	JBE	SHORT GLDM12
	MOV	DL,AL
GLDM12:	CMP	AH,DL
	JBE	SHORT GLDM13
	MOV	DL,AH
GLDM13:	INC	DI
	INC	DI
	LOOP	LLDM4
	INC	DL
	CLD
	MOV	PATTERN_NUMBER,DX
	CALL	GET_QUEUE
	PUSH	AX
	CALL	GET_QUEUE
	SHL	EAX,16
	POP	AX
	MOV	MOD_SIGN,EAX
	CMP	EAX,"NHC8"		;8CHN-MOD
	JE	SHORT GLDM3
	CMP	EAX,"8TLF"		;FLT8-MOD
	JE	SHORT GLDM3
	CMP	EAX,".K.M"		;M.K.-MOD
	JE	SHORT GLDM10
	CMP	EAX,"4TLF"		;FLT4-MOD
	JNE	GLDM2

GLDM10:	MOV	CH_NUMB,4		;4-CHANNEL-MOD
	MOV	PATTERN_SIZE,1024
	MOV	AH,0
	MOV	TRACK_INFO+4,AH
	MOV	TRACK_INFO+5,AH
	MOV	TRACK_INFO+6,AH
	MOV	TRACK_INFO+7,AH
	JMP	SHORT GLDM11
GLDM3:	MOV	CH_NUMB,8		;8-CHANNEL-MOD: GET-PATTERNS
	MOV	PATTERN_SIZE,2048
GLDM11:	MOV	PATTERN_CURRENT,0
	MOV	TRACK_NUMBER,0
LLDM7:	MOV	ES,PATTERN_SEG
	MOV	BX,GDDHANDLE
	XOR	DI,DI
LLDM6:	XOR	SI,SI
LLDM5:	CALL	GET_QUEUE		;GET PATTERNS AND SPLIT INTO TRACKS
	JC	GLDM2
	MOV	DX,AX
	CALL	GET_QUEUE
	JC	GLDM2
	ROL	AL,4			;MODIFY PATTERN DATA
	MOV	CL,AL			;LOOK AT PROTRACKER-CODE HEADER
	AND	AL,0FH
	AND	CL,0F0H	
	MOV	CH,DL
	AND	DL,0FH
	AND	CH,0F0H
	OR	AL,CH
	OR	DL,CL
	XCHG	DL,DH
	PUSH	DI
	ADD	DI,SI
	SHL	EAX,16
	MOV	AX,DX
	STOSD
	POP	DI
	ADD	SI,256
	CMP	SI,PATTERN_SIZE		;NEXT TRACK/CHANNEL
	JB	LLDM5
	ADD	DI,4			;NEXT NOTE
	CMP	DI,256
	JB	LLDM6
	CALL	SET_FREQUENCIES
	MOV	ES,TRACK_SEG		;INTEGRATE TRACK1-8
	MOV	DX,TRACK_NUMBER
	XCHG	DL,DH
	MOV	DS,PATTERN_SEG
	XOR	SI,SI
	XOR	BX,BX
LLDM8:	XOR	DI,DI
LLDM9:	CMP	DX,DI
	JBE	SHORT GLDM4
	PUSH	SI DI
	MOV	CX,256/4
	REPE CMPSD			;TRACK ALREADY EXISTS?
	POP	DI SI
	PUSHF
	ADD	DI,256
	POPF
	JNE	LLDM9
	JMP	SHORT GLDM5
GLDM4:	INC	DH			;NO, ADD TRACK TO BUFFER
	PUSH	SI
	MOV	CX,256/4
	REP MOVSD
	POP	SI
GLDM5:	MOV	AX,DI			;YES
	DEC	AH
	MOV	CS:[TRACK_INFO+BX],AH
	INC	BX
	ADD	SI,256
	CMP	BX,CS:CH_NUMB
	JB	LLDM8
	PUSH	CS
	POP	DS
	XCHG	DL,DH
	MOV	TRACK_NUMBER,DX
	XOR	BX,BX			;MAKE TRACKLISTE 
	MOV	AX,PATTERN_CURRENT
LLDM10:	CMP	[SONG_DATA+BX],AL
	JNE	SHORT GLDM6
	MOV	AH,TRACK_INFO
	MOV	[TRACK1_DATA+BX],AH
	MOV	AH,TRACK_INFO+1
	MOV	[TRACK2_DATA+BX],AH
	MOV	AH,TRACK_INFO+2
	MOV	[TRACK3_DATA+BX],AH
	MOV	AH,TRACK_INFO+3
	MOV	[TRACK4_DATA+BX],AH
	MOV	AH,TRACK_INFO+4
	MOV	[TRACK5_DATA+BX],AH
	MOV	AH,TRACK_INFO+5
	MOV	[TRACK6_DATA+BX],AH
	MOV	AH,TRACK_INFO+6
	MOV	[TRACK7_DATA+BX],AH
	MOV	AH,TRACK_INFO+7
	MOV	[TRACK8_DATA+BX],AH
GLDM6:	INC	BX
	CMP	BL,128
	JB	LLDM10
	INC	PATTERN_CURRENT		;GET NEXT PATTERN
	MOV	AX,PATTERN_CURRENT
	CMP	AX,PATTERN_NUMBER
	JB	LLDM7

GLDM7:	MOV	ES,PATTERN_SEG		;CLEAR PATTERN SEGMENT
	MOV	AH,49H
	INT	21H
	MOV	BX,TRACK_NUMBER		;TRACK SEGMENT RESIZE
	SHL	BX,4
	MOV	ES,TRACK_SEG
	MOV	AH,4AH
	INT	21H
	MOV	BX,SAMPLE_SIZE		;SAMPLE SEGMENT ALLOCATE
	MOV	AH,48H
	INT	21H
	XOR	BX,BX
LLDM11:	ADD	[SAMPLE_SEG+BX],AX
	INC	BX
	INC	BX
	CMP	BX,62
	JB	LLDM11
	MOV	BX,GDDHANDLE
	XOR	SI,SI			;LOAD SAMPLES
LLDM12:	MOV	CX,[ISIZE+SI]
	MOV	ES,[SAMPLE_SEG+SI]
	XOR	DI,DI
	SHR	CX,1
	JCXZ	SHORT GLDM8
LLDM13:	CALL	GET_QUEUE
	STOSW
	LOOP	LLDM13
GLDM8:	INC	SI
	INC	SI
	CMP	SI,62
	JB	LLDM12
	CLC
	JMP	SHORT GLDM15
GLDM2:	STC
GLDM15:	PUSHF
	MOV	AH,3EH
	INT	21H
	POPF
GLDM1:	RET
LOAD_MOD ENDP
;-----------------------------------------------------------------------------
; REPLACE MOST PERIODS WITH INDEX INTO PERIOD TABLE
;-----------------------------------------------------------------------------
SET_FREQUENCIES PROC NEAR
	XOR	DI,DI
SET_FREQ1:
	MOV	AX,ES:[DI]		;get fx
	MOV	DX,AX
	SHR	AH,4
	CMP	AH,3
	JE	SHORT SET_FREQ4
	CMP	AH,5
	JE	SHORT SET_FREQ4
	MOV	AX,DX
	AND	AX,0FFFH		; Mask out unwanted bits.
	JZ	SHORT SET_FREQ4
	XOR	BX,BX
	MOV	CX,48			; 36 periods to cycle through.
SET_FREQ2:
	CMP	AX,[MT_PERIODTABLE+BX]	; Check the note against the period.
	JAE	SHORT SET_FREQ3		; We found it!
	INC	BX			; Otherwise, update the pointer and
	INC	BX
	LOOP	SET_FREQ2		; keep looping.
SET_FREQ3:
	MOV	AX,DX			;recall the Note Value
	AND	AX,0F000H		;just keep fx
	INC	BX
	OR	AX,BX			;put in the new offset
	STOSW				;store it
	DEC	DI
	DEC	DI
SET_FREQ4:
	ADD	DI,4			;and go to next channel
	CMP	DI,PATTERN_SIZE
	JB	SET_FREQ1
	RET
SET_FREQUENCIES ENDP
;-----------------------------------------------------------------------------
; GET WORD FROM BUFFER
; IN: AX= WORD, BX= HANDLE
;-----------------------------------------------------------------------------
GET_QUEUE PROC NEAR
	CMP     GDDZEIG,0
	JNE     SHORT GTQ1
	PUSH	CX DX
	MOV     DX,OFFSET QUEUE_BUFFER
	MOV     CX,256
	MOV     AH,3FH
	INT     21H
	MOV	GDDREST,AX
	POP	DX CX
GTQ1:   PUSH	BX
	MOV     BL,GDDZEIG
	XOR     BH,BH
	CMP	BX,GDDREST
	JAE	SHORT GTQ2
	MOV     AX,[QUEUE_BUFFER+BX]
	ADD     GDDZEIG,2
	POP	BX
	CLC
	RET
GTQ2:	POP	BX
	STC
	RET
GET_QUEUE ENDP
;=============================================================================
; LOAD A SAMPLE
; INPUT: DS:DX= FILENAME, CL= 00H AMIGA-SAMPLE, 80H PC-SAMPLE
; OUTPUT: AX= SAMPLE-HANDLE FOR PLAYING
;-----------------------------------------------------------------------------
LOAD_SAMPLE PROC NEAR
	MOV	AX,3D00H		;OPEN SAMPLE
	INT	21H
	JC	GSMP1
	PUSH	CS
	POP	DS
	MOV	GDDHANDLE,AX
	MOV	BX,AX
	PUSH	CX
	CALL	GET_FILESIZE
	POP	CX
GSMP0:	AND	CL,80H
	MOV	SAM_FLAG,CL
	MOV	GDDZEIG,0
	MOV	CX,AX
	AND	CX,0FFFEH
	SHR	AX,4
	INC	AX
	MOV	BX,AX
	CMP	EMS_SEG,0
	JNE	SHORT GSMP3
	PUSHA
	XOR	SI,SI
	XOR	AX,AX			;CHECK FOR EMS-MANAGER
	MOV	ES,AX
	MOV	EMS_HANDLE,AX
	MOV	AX,ES:[4*67H+2]
	MOV	ES,AX
	CMP	ES:[10],"XMME"
	JNE	GSMP2
	CMP	ES:[14],"0XXX"
	JNE	GSMP2
	MOV	AH,42H
	INT	67H
	OR	AH,AH
	JNZ	GSMP2
	CMP	BX,34
	JB	GSMP2
	MOV	AH,41H
	INT	67H
	MOV	EMS_SEG,BX
	MOV	AH,43H			;ALLOCATE 544K EMS FOR FX
	MOV	BX,34
	INT	67H
	MOV	EMS_HANDLE,DX
	XOR	AX,AX
	MOV	EMS_OFFSET,AX
	MOV	SAMPLE_ZEIG,AX
	POPA
GSMP3:	MOV	AX,EMS_OFFSET
	MOV	SI,SAMPLE_ZEIG
	MOV	[SAMPLE_MEM+SI],AX
	MOV	[SAMPLE_BIG+SI],CX
	ADD	SAMPLE_ZEIG,2
	MOV	DI,CX
	SHR	DI,4
	INC	DI
	ADD	EMS_OFFSET,DI
	XOR	DI,DI
	CLD
	INC	CX
	SHR	CX,1
	MOV	DL,SAM_FLAG
	MOV	DH,DL
	MOVZX	BP,FX_VOL
	INC	BP
	AND	EAX,0FFFFH
	SHL	EAX,4
LSMP1:	PUSH	EAX
	OR	DI,DI
	JNZ	SHORT GSMP4
	CALL	EMS_PAGING
GSMP4:	MOV	BX,GDDHANDLE
	CALL	GET_QUEUE
	XOR	AX,DX
	SAR	AH,1
	SAR	AL,1
	PUSH	DX
	MOV	BL,AH
	CBW
	IMUL	BP
	MOV	AL,BL
	MOV	BL,AH
	CBW
	IMUL	BP
	MOV	AL,BL
	POP	DX
	STOSW
	POP	EAX
	INC	EAX
	INC	EAX
	LOOP	LSMP1
	CLC
GSMP2:	PUSHF
	MOV	BX,GDDHANDLE
	MOV	AH,3EH
	INT	21H
	MOV	AX,SI
	POPF
GSMP1:	RET
LOAD_SAMPLE ENDP
;-----------------------------------------------------------------------------
GET_FILESIZE PROC NEAR
	MOV	AX,4202H
	XOR	CX,CX
	XOR	DX,DX
	INT	21H
	PUSH	AX
	MOV	AX,4200H
	XOR	CX,CX
	XOR	DX,DX
	INT	21H
	POP	AX
	RET
GET_FILESIZE ENDP
;=============================================================================
; LOAD CONFIG DATA (PARSER)
;-----------------------------------------------------------------------------
CONFIG_INIT PROC NEAR
	MOV	AX,CS			;SAVE THE SEGMENT OF CODE
	MOV	DS,AX
	MOV	WORD PTR HOLD70+2,AX	;THIS LINE IS IMPORTANT
	MOV	WORD PTR HOLDSB+2,AX	;THIS LINE IS IMPORTANT
	MOV     DX,OFFSET CONFIG_NAME
	MOV     AH,3DH
	MOV     AL,80H
	INT     21H
	JC      GCFG1
	MOV     GDDHANDLE,AX
LCFG1:  XOR     SI,SI
	MOV     DX,OFFSET QUEUE_BUFFER
LCFG2:  MOV     AH,3FH
	MOV     BX,GDDHANDLE
	MOV     CX,1
	INT     21H
	JC      GCFG2
	OR      AX,AX
	JZ      GCFG2
	MOV     DI,DX
	CMP     BYTE PTR [DI],0AH
	JE      SHORT GCFG6
	INC     DX
	INC     SI
	CMP     SI,256
	JB      LCFG2
GCFG6:  MOV     BX,OFFSET CFG_TEXT1
	CALL    SEEK_LINE
	JNC     SHORT GCFG3
	LODSB
	AND     AL,3
	MOV	SB_TYP,AL
	JMP     LCFG1
GCFG3:  MOV     BX,OFFSET CFG_TEXT2
	CALL    SEEK_LINE
	JNC     SHORT GCFG4
	LODSB
	AND     AL,3
	MOV	SB_MODUS,AL
	JMP     LCFG1
GCFG4:  MOV     BX,OFFSET CFG_TEXT3
	CALL    SEEK_LINE
	JNC     SHORT GCFG5
	INC	SI
	LODSB
	DEC	AL
	AND	AL,7
	INC	AL
	SHL	AL,4
	MOV	AH,2
	ADD	AL,4
	MOV	SBP_MIXERI,AX
	INC	AX
	MOV	SBP_MIXERD,AX
	INC	AX
	MOV	SB_RESET,AX
	ADD	AX,4
	MOV	SB_READ,AX
	ADD	AX,2
	MOV	SB_WRITE,AX
	ADD	AX,2
	MOV	SB_RSTAT,AX
	JMP     LCFG1
GCFG5:  MOV     BX,OFFSET CFG_TEXT4
	CALL    SEEK_LINE
	JNC     SHORT GCFG7
	LODSW
	AND     AL,7
	AND	AH,7
	MOV	BH,AH
	MOV	BL,10
	MUL	BL
	ADD	AL,BH
	MOV	IRQ_NUMBER,AL
	JMP	LCFG1
GCFG7:  MOV     BX,OFFSET CFG_TEXT5
	CALL    SEEK_LINE
	JNC     SHORT GCFG8
	LODSB
	AND	AL,3
	MOV	DMA_CHANNEL,AL
	JMP	LCFG1
GCFG8:	MOV	BX,OFFSET CFG_TEXT6
	CALL	SEEK_LINE
	JNC	SHORT GCFG9
	XOR	BX,BX
	MOV	CX,5
LCFG3:	MOV	AX,BX
	MOV	DX,10
	MUL	DX
	MOV	BX,AX
	LODSB
	AND	AL,0FH
	XOR	AH,AH
	ADD	BX,AX
	LOOP	LCFG3
	MOV	SAMPLE_RATE,BX
	JMP     LCFG1
GCFG9:	MOV     BX,OFFSET CFG_TEXT7
	CALL    SEEK_LINE
	JNC     LCFG1
	LODSB
	AND     AL,1
	MOV     SYSTEM,AL
	JMP     LCFG1
GCFG2:  MOV     BX,GDDHANDLE
	MOV     AH,3EH
	INT     21H
GCFG1:  RET
CONFIG_INIT ENDP
;-----------------------------------------------------------------------------
SEEK_LINE PROC NEAR
	CLD
	MOV     SI,OFFSET QUEUE_BUFFER
LSKL1:  PUSH    BX
LSKL2:  CMP     BYTE PTR [BX],0
	JE      SHORT GSKL1
	CMP     SI,DX
	JAE     SHORT GSKL2
	LODSB
	CMP     AL,[BX]
	JNE     SHORT GSKL3
	INC     BX      
	JMP     LSKL2
GSKL3:  POP     BX
	JMP     LSKL1
GSKL2:  POP     BX
	CLC
	RET
GSKL1:  POP     BX
	STC
	RET
SEEK_LINE ENDP
;=============================================================================


;=============================================================================
PLAY_MUSIC PROC NEAR
	PUSH	CS
	POP	DS
	MOV	MOD_STAT,0		;DEACTIVATE IRQ-HANDLING
	CALL	DSP_RESET
	JC	GPM1
	CALL	MAKE_MIXMUL_VOLUMETABLE
	CALL	IRQ_INIT
	XOR	EDX,EDX
	MOV	EAX,1000000
	MOVZX	EBX,SAMPLE_RATE
	MOV	CL,SBPRO_FLAG
	DIV	EBX
	SHR	AL,CL
	NEG	AL
	MOV	DMA_RATE,AL
	XOR	EDX,EDX
	MOV	EAX,369E9400H		;1,193,180 * 300H FOR FREQ CALCS
	DIV	EBX
	MOV	MAINFREQ,EAX
	MOV	AX,BX
	MOV	BX,20			;AMIGA TIMING IS 50HZ (SCREEN-REFRESH)
	MUL	BX
	SHRD	AX,DX,10
	SHL	AX,CL
	MOV	DMA_CX,AX		;# OF BYTE/CYCLE (434 FOR 22222 HZ)
	SHL	AX,2			;4 TIMES FORWARD
	MOV	DMA_MORE,AX
	SHL	AX,2			;16 TIMES MAXIMUM (6944 FOR 22222 HZ)
	SHR	AX,CL
	SUB	AH,CL
	SUB	AH,CL
	MOV	DMA_MAX,AX
	MOV	AX,DMA_OFFSET
	MOV	DMA_PTR,AX
	MOV	DMA_NEWPTR,AX
	MOV	BPM_SPEED,20		;CLOCK-IRQ IS 1024HZ DIV 20 = 50HZ
	MOV	BPM_COUNT,1
	MOV	MT_SPEED,6		;DEFAULT PROTRACKER SPEED
	XOR	AX,AX
	MOV	MT_COUNTER,AL		;RESET PROTRACKER VARIABLES
	MOV	MT_PATTERNPOS,AX
	MOV	MT_SONGPOS,AL
	MOV	MT_PATTDELAYTIME2,AL
	MOV	MT_PATTDELAYTIME,AL
	MOV	MT_PBREAKFLAG,AL
	MOV	MT_PBREAKPOS,AL
	MOV	MT_POSJUMPFLAG,AL
	MOV	MT_LOWMASK,0FFH
	MOV	CX,43*8/2
	CLD
	PUSH	DS
	POP	ES
	MOV	DI,OFFSET NOTE
	REP STOSW
	INC	AL
	MOV	CX,MAX_CHAN_NUMB
	MOV	DI,OFFSET TONEPORTDIREC
	REP STOSB
	MOV	BYTE PTR SELFN1+2,2
	MOV	BYTE PTR SELFN2+2,2
	TEST	SBPRO_FLAG,1
	JZ	SHORT GPM2
	MOV	BYTE PTR SELFN1+2,4
	MOV	BYTE PTR SELFN2+2,4
GPM2:	MOV	CX,3			;PRECALCULATE SAMPLE DATA FOR INIT
LPM1:	PUSH	CX
	CALL	CONTROL_CHANNELS
	CALL	MIXUP_CHANNELS
	POP	CX
	LOOP	LPM1
	MOV	AH,DMA_RATE		;SET SB-SAMPLERATE
	CALL	DSP_RATE
	MOV	DX,DMA_SEG		;INITIALIZE DMA
	MOV	BX,DMA_OFFSET
	MOV	CX,DMA_MAX
	CALL	DMA_INIT
	MOV	MOD_STAT,1		;ACTIVATE IRQ-HANDLING
	CLC
GPM1:	RET
PLAY_MUSIC ENDP
;-----------------------------------------------------------------------------
STOP_MUSIC PROC NEAR
	PUSH	CS
	POP	DS
	MOV	MOD_STAT,0
	CALL	DSP_RESET
	CALL	IRQ_INIT
	MOV	IRQCOUNT,56
	RET
STOP_MUSIC ENDP
;-----------------------------------------------------------------------------
END_MUSIC PROC NEAR
	PUSH	CS
	POP	DS
	CALL	FREE_TMEM
	CALL	FREE_DMEM
	RET
END_MUSIC ENDP
;-----------------------------------------------------------------------------
GET_SONGMOD PROC NEAR
	MOV	AL,CS:SB_MODUS
	RET
GET_SONGMOD ENDP
;-----------------------------------------------------------------------------
SET_SONGMOD PROC NEAR
	AND	AL,3
	MOV	CS:SB_MODUS,AL
	RET
SET_SONGMOD ENDP
;-----------------------------------------------------------------------------
GET_SONGPOSITION PROC NEAR
	MOV	AL,CS:MT_SONGPOS
	RET
GET_SONGPOSITION ENDP
;-----------------------------------------------------------------------------
SET_SONGPOSITION PROC NEAR
	AND	AL,7FH
	MOV	CS:MT_SONGPOS,AL
	MOV	CS:MT_PATTERNPOS,0
	RET
SET_SONGPOSITION ENDP
;-----------------------------------------------------------------------------
SET_SONGLOOP PROC NEAR
	MOV	CS:SONG_LOOP,AL
	RET
SET_SONGLOOP ENDP
;-----------------------------------------------------------------------------
GET_VOLUME PROC NEAR
	MOV	AL,CS:MASTER_VOLUME	;0= MIN VOLUME, 255= MAX VOLUME
	MOV	BL,CS:MUSIC_VOLUME	;0= MIN VOLUME, 255= MAX VOLUME
	MOV	BH,CS:FX_VOLUME		;0= MIN VOLUME, 255= MAX VOLUME
	RET
GET_VOLUME ENDP
;-----------------------------------------------------------------------------
SET_VOLUME PROC NEAR
	MOV	CS:MASTER_VOLUME,AL	;0= MIN VOLUME, 255= MAX VOLUME
	MOV	CS:MUSIC_VOLUME,BL	;0= MIN VOLUME, 255= MAX VOLUME
	MOV	CS:FX_VOLUME,BH		;0= MIN VOLUME, 255= MAX VOLUME
	PUSH	AX DX
	MOVZX	DX,AL
	INC	DX
	PUSH	DX
	MOVZX	AX,BL
	MUL	DX
	MOV	CS:MUSIC_VOL,AH
	POP	DX
	MOVZX	AX,BH
	MUL	DX
	MOV	CS:FX_VOL,AH
	POP	DX AX
	RET
SET_VOLUME ENDP
;-----------------------------------------------------------------------------
SET_SAMPLERATE PROC NEAR
	CMP	AX,10000
	JAE	SHORT GSSR1
	MOV	AX,10000
GSSR1:	CMP	AX,22222
	JBE	SHORT GSSR2
	MOV	AX,22222
GSSR2:	MOV	CS:SAMPLE_RATE,AX	;BEST BETWEEN 10000 - 22222 Hz
	RET
SET_SAMPLERATE ENDP
;-----------------------------------------------------------------------------
; START FX SAMPLE
; BX= SAMPLE-HANDLE, CX= SAMPLERATE
;-----------------------------------------------------------------------------
PLAY_SAMPLE PROC NEAR
	PUSH	CS
	POP	DS
	TEST	SB_MODUS,1
	JNZ	GPSMP1
	CMP	EMS_SEG,0
	JE	GPSMP1
	MOVZX	EAX,CX	
	SHL	EAX,8
	MOVZX	ECX,SAMPLE_RATE
	XOR	EDX,EDX
	DIV	ECX
	OR	AX,AX
	JZ	SHORT GPSMP1
	CMP	SBPRO_FLAG,1
	JNE	SHORT GPSMP2
	XOR	SAM_FLAG,1
	TEST	SAM_FLAG,1
	JZ	SHORT GPSMP3
	CMP	SAM_SEG1,0
	JE	SHORT GPSMP2
	CMP	SAM_SEG2,0
	JNE	SHORT GPSMP2
GPSMP4:	CLI				;RIGHT CHANNEL SAMPLE
	MOV	SAM_FRQ2,AX
	MOV	AX,EMS_SEG
	MOV	SAM_SEG2,AX
	MOVZX	EAX,[SAMPLE_MEM+BX]
	SHL	EAX,4
	MOV	SAM_OFS2,EAX
	MOV	AX,[SAMPLE_BIG+BX]
	MOV	SAM_MAX2,AX
	MOV	SAM_OFL2,0
	STI
	RET
GPSMP3:	CMP	SAM_SEG2,0
	JE	GPSMP4
	CMP	SAM_SEG1,0
	JNE	GPSMP4
GPSMP2:	CLI				;LEFT CHANNEL SAMPLE
	MOV	SAM_FRQ1,AX
	MOV	AX,EMS_SEG
	MOV	SAM_SEG1,AX
	MOVZX	EAX,[SAMPLE_MEM+BX]
	SHL	EAX,4
	MOV	SAM_OFS1,EAX
	MOV	AX,[SAMPLE_BIG+BX]
	MOV	SAM_MAX1,AX
	MOV	SAM_OFL1,0
	STI
GPSMP1:	RET
PLAY_SAMPLE ENDP
;-----------------------------------------------------------------------------
END_SAMPLE PROC NEAR
	PUSH	CS
	POP	DS
	MOV	SAM_SEG1,0
	MOV	SAM_SEG2,0
	CMP	EMS_SEG,0
	JE	SHORT GEMP1
	MOV	AH,45H
	MOV	DX,EMS_HANDLE
	INT	67H
	MOV	EMS_SEG,0
GEMP1:	RET
END_SAMPLE ENDP
;=============================================================================


;=============================================================================
;
; MAIN ROUTINE
;
;=============================================================================
MAIN_CONT PROC NEAR
	MOV	AX,CS			;DS SET
	MOV	DS,AX
	MOV     PROG_START_SEG,ES       ;PROGRAMM START
	MOV     AX,SS                   ;AND -END SET
	MOV     BX,OFFSET PROG_END
	ADD     BX,STACKLENGTH
	MOV     SP,BX
	SHR     BX,4
	INC     BX
	ADD     AX,BX
	MOV     PROG_END_SEG,AX
	XOR	BX,BX
GL1:	MOV	AL,ES:[82H+BX]
	OR	AL,AL
	JZ	SHORT GL2
	CMP	AL,20H
	JE	SHORT GL2
	CMP	AL,0DH
	JE	SHORT GL2
	MOV	[MOD_NAME+BX],AL
	INC	BX
	CMP	BX,40H
	JB	GL1
GL2:	OR	BX,BX
	JZ	GMEND
	XOR	AL,AL
	MOV	[MOD_NAME+BX],0
	CALL	FREE_MEM
;-----------------------------------------------------------------------------
; INITIALIZING & STARTING
;	MOV	AX,22222		;SET MAXIMUM SAMPLERATE
;	CALL	SET_SAMPLERATE
;	MOV	AL,255			;SET MAXIMUM VOLUME
;	MOV	BL,AL
;	MOV	BH,AL
;	CALL	SET_VOLUME
	CALL	CONFIG_INIT		;GET CONFIG
	MOV	DX,OFFSET MOD_NAME	;FIRST, TRY LOADING
	CALL	LOAD_MOD
	JNC	SHORT GM1
	MOV	AH,9
	MOV	DX,OFFSET ERROR1_TEXT
	INT	21H
	JMP	SHORT GM4
GM1:	MOV	DX,OFFSET SAMPLE_NAME	;GET SAMPLE
	MOV	CL,80H			;PC-SAMPLE
	CALL	LOAD_SAMPLE
	JNC	SHORT GM2
	MOV	AH,9
	MOV	DX,OFFSET ERROR2_TEXT
	INT	21H
GM2:	CALL	PLAY_MUSIC		;TRY STARTING
	JNC	SHORT GM3
	MOV	AH,9
	MOV	DX,OFFSET ERROR3_TEXT
	INT	21H
	JMP	SHORT GM4
;-----------------------------------------------------------------------------
; THIS COULD BE THE MAIN ROUTINE
GM3:	MOV	AH,9
	MOV	DX,OFFSET OUT_TEXT
	INT	21H
LM1:	XOR	AH,AH
	INT	16H
	CMP	AL,27
	JE	SHORT GM5
	CMP	AL,"+"
	JNE	SHORT G1
	CALL	GET_VOLUME
	INC	AL
	CALL	SET_VOLUME
	JMP	LM1
G1:	CMP	AL,"-"
	JNE	SHORT G2
	CALL	GET_VOLUME
	DEC	AL
	CALL	SET_VOLUME
	JMP	LM1
G2:	CMP	AL,"9"
	JNE	SHORT G3
	MOV	AL,0
	CALL	SET_SONGLOOP
	JMP	LM1
G3:	CMP	AL,"0"
	JNE	SHORT G4
	INC	SB_MODUS
	AND	SB_MODUS,3
	JMP	LM1
G4:	CMP	AL,"1"
	JNE	LM1
	XOR	BX,BX			;HANDLE
	MOV	CX,22222		;FREQUENCE
	CALL	PLAY_SAMPLE
	JMP	LM1
;-----------------------------------------------------------------------------
; CUTTING OFF
GM5:	CALL	STOP_MUSIC		;STOP MUSIC
GM4:	CALL	END_SAMPLE		;UNLOAD SAMPLES
	CALL	END_MUSIC		;UNLOAD MUSIC
GMEND:	MOV     AX,4C00H                ;DOS
	INT     21H
MAIN_CONT ENDP
;=============================================================================

END MAIN