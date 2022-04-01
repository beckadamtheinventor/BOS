;@DOES copy 18 bytes from HL to DE
_Mov18b:
	ld c,18
	jr _MovCb
;@DOES copy 11 bytes from HL to DE
_Mov11b:
	ld c,11
	jr _MovCb
;@DOES copy 10 bytes from HL to DE
_Mov10b:
	ld c,10
	jr _MovCb
;@DOES copy 9 bytes from OP1 then 9 bytes from OP2 into DE
_MovFROP1OP2:
	call _MovFROP1
	inc hl
	inc hl
	jr _Mov9b
_MovFROP1:
	ld hl,ti.OP1
;@DOES copy 9 bytes from HL to DE
_Mov9b:
	ld c,9
	jr _MovCb
;@DOES copy 8 bytes from HL to DE
_Mov8b:
	ld c,8
	jr _MovCb
;@DOES copy 7 bytes from HL to DE
_Mov7b:
	ld c,7
_MovCb:
	ld b,1
	mlt bc
	ldir
	ret
