; Input:
;  (ix+6) = endpoint
; Output:
;  zf = enough memory
;  hl = transfer
;  iy = (ix+6)
_CreateDummyTransfer:
	ld	yendpoint,(ix+6)
.enter:
	call	_Alloc32Align32
	ret	nz
	setmsk	transfer.status,hl
	ld	(hl),transfer.status.halted
	resmsk	transfer.status,hl
	ld	(hl),1
	ret
