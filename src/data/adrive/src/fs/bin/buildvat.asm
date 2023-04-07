
	jr _buildvat_main
	db "FEX", 0
_buildvat_main:
	call bos._BuildVAT
	sbc hl,hl
	ret
