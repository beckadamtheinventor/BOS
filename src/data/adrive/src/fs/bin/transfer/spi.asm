	private	ti.bSpiTxFifoBytes
	private	ti.bmSpiChipEn
	private	ti.mpSpiCtrl2
	private	ti.spiData
	private	ti.spiStatus
include 'ti84pceg.inc'

	section	.text
	public	_spi_write
_spi_write:
	pop	hl,de
	push	de,hl
	ld	hl,ti.mpSpiCtrl2 or ti.bmSpiChipEn shl 8
	ld	(hl),h
	ld	a,(de)
	ld	c,a
virtual
	or	a,0
 load .or_a: byte from $$
end virtual
	db	.or_a
.loop:
	scf
	inc	de
	ld	a,(de)
	ld	l,ti.spiData
	ld	b,3
.shift:
	rla
	rla
	rla
	ld	(hl),a
	djnz	.shift
	ld	l,ti.spiStatus+1
.wait:
	bit	ti.bSpiTxFifoBytes+3-8,(hl)
	jq	nz,.wait
.enter:
	dec	c
	jq	nz,.loop
	ret
