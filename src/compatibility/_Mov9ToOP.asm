;@DOES move 11 bytes from HL to OP1
_Mov11ToOP1:
	ld de,fsOP1
	jq _Mov11b
;@DOES move 9 bytes from HL to OP2
_Mov9ToOP2:
	ld de,fsOP2
	jq _Mov9b
;@DOES move 9 bytes from HL to OP1
_Mov9ToOP1:
	ld de,fsOP1
	jq _Mov9b
