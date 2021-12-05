; ----------------------
; Edited specifically for BOS and is *not* for generic use

macro os_private
	local os
	element os.base
	os.start = $020000
 	macro os_rom?
		macro end?.os_rom?
			os.end = $
			os.size = $-$$
			load os.full_code:$-$$ from $$
			end virtual
			virtual at $020000
				db $80,$0F
				dd (os.end-$20006) bswap dword
				db $80,$12,$13,$00
				db $80,$21,$05
				db $80,$32,$25,$00
				db $80,$A1,$07
				db $80,$C2,$01,$00
				db $80,$D6,$00,$03,$05,$00,$03,$05
				db $80,$E6,$00,$03,$05,$00,$03,$05
				db $00,$0D,$CF,$CF dup 0
				db $80,$7F
				dd (os.size) bswap dword
				db $5a,$a5,$ff,$ff
				jp os.end
				load os.header_code: $-$$ from $$
			end virtual
			virtual
				db os.header_code
				db os.full_code
				db $02,$3E,$01,$00
				load os.full_binary: $-$$ from $$
				os.full_binary_len = $-$$
			end virtual
			purge end?.os_rom?
		end macro
		virtual at $020108
	end macro
	
	macro os_create? final_sector
		di
		call	.create
if defined INSTALLER8XP
		rst 0
else
		ret
end if
.create:
		ld	a,$d1
		ld	mb,a
		ld.sis	sp,$987e
		call.is	.unlock and $ffff
; setup our OS
		ld a,2
		call .sectorerase
		ld a,3
		call .sectorerase

		ld	hl,os.source
		ld	de,$020000
		ld	bc,os.full_binary_len
		call	$2E0 ;WriteFlash
		ld	hl,0
	os_second_binary:=$-3
		ld	de,$020000 + os.full_binary_len
		ld	bc,0
	os_second_binary.len:=$-3
		ld a,c
		or a,b
		call	nz, $2E0 ;WriteFlash
		ld	a,$04
.erase:
		push	af
		call	.sectorerase
		pop	af
		inc	a
		cp	a,final_sector
		jr	nz,.erase
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
;		jp	0

	end macro

	macro write_os_binary?
		os.source:
			db os.full_binary
	end macro
end macro

; ----------------------

os_private
purge os_private
