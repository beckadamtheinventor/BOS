;@DOES Nothing.
;@OUTPUT Cf set, hl = 0
_RclAns:
	or a,a
	sbc hl,hl
	scf
	ret
