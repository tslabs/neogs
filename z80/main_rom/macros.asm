
DUPL	MACRO LEN,FILL
		REPT LEN
		DEFB FILL
		ENDR
		ENDM

ALIGN256    MACRO
        org (($ - 1) & h'FF00) + h'100
        ENDM