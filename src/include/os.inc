; ----------------------

macro os_private
	local os
	element os.base

 	postpone
		os.size = $% - os.start_off
		os.end = os.size + $20100
	end postpone

 	macro os_rom?
		os.start = $
		os.start_off = $%
		org $20100
		db $5a,$a5,$ff,$ff
		jp os.end
	end macro
	
	macro os_create?
		di
		call	.create
		jp	.continue
.create:
		ld	a,$d1
		ld	mb,a
		ld.sis	sp,$987e
		call.is	.unlock and $ffff
		
		ld	a,$2F

; save TIOS
.erase1:
		push	af
		call	.sectorerase
		pop	af
		inc	a
		cp	a,$3B
		jr	nz,.erase1
		ld	de,$20100
		ld	hl,($20105)
		or a,a
		sbc hl,de
		push hl
		pop bc
		ld	hl,$2F0000
		ex hl,de
		call $2E0

; setup our OS
		ld	a,$02
.erase:
		push	af
		call	.sectorerase
		pop	af
		inc	a
		cp	a,$0C
		jr	nz,.erase

		ld	hl,os.start
		ld	de,$20100
		ld	bc,os.size
		call	$2e0

		call.is	.lock and $ffff
		ld	a,$d0
		ld	mb,a
		xor	a,a
		ret

.sectorerase:
		ld	bc,$f8
		push	bc
		jp	$2dc

		assume	adl = 0

.unlock:
		ld	a,$8c
		out0	($24),a
		ld	c,4
		in0	a,(6)
		or	c
		out0	(6),a
		out0	($28),c
		ret.l
.lock:	
		xor	a
		out0	($28),a
		in0	a,(6)
		res	2,a
		out0	(6),a
		ld	a,$88
		out0	($24),a
		ret.l

		assume adl = 1
.continue:
		jp	0
	end macro
	
end macro

; ----------------------

os_private
purge os_private
