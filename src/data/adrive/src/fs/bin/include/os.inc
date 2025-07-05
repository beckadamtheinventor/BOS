; ----------------------
; Edited specifically for BOS and is *not* for generic use

macro os_private baseaddr:$020000
	local os
	element os.base
	os.start = baseaddr
 	macro os_rom?
		macro end?.os_rom?
			os.end = $
			os.size = $-$$
			load os.full_code:$-$$ from $$
			end virtual
			virtual at os.start
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
		virtual at os.start + $108
	end macro
	
	macro os_create? final_sector
		di
		call	.create
		jp $020108
.create:
if defined INSTALLER8XP
		ld	a,$d1
		ld	mb,a
		ld.sis	sp,$987e
		call.is	.unlock and $ffff
	; smc'd to 1 if we should back up TIOS
		ld a,0
	backup_os_flag := $-1
		or a,a
		jr z,.setup
		ld a,fs_os_backup_location shr 16
	.backuperaseloop:
		push af
		call _sectorerase
		pop af
		inc a
		cp a,$3B
		jr c,.backuperaseloop
		
		; OSSize jump location
		ld hl,($020104+1)
		ld bc,$104-$020000
		add hl,bc
		push hl
		pop bc
		; bc = length of OS in bytes
		ld hl,$020000
		ld de,bos.fs_os_backup_location
		; write the OS backup
		call $2E0 ; WriteFlash

		; backup the installer data
		ld hl,$010000
		add hl,de
		ld l,0
		ld h,l
		ex hl,de
		ld hl,reinstaller_2_header
		ld bc,reinstaller_2_header.len
		call $2E0
		ld hl,(os_second_binary)
		ld bc,(os_second_binary.len)
		call $2E0 ; WriteFlash

		; backup the installer
		ld hl,$010000
		add hl,de
		ld l,0
		ld h,l
		ex hl,de
		ld hl,reinstaller_header
		ld bc,reinstaller_header.len
		call $2E0
		ld hl,ti.userMem
		ld bc,(ti.asm_prgm_size)
		call $2E0 ; WriteFlash

else
		call bos.sys_FlashUnlock
end if
; setup our OS
.setup:
		ld a,2
		call .sectorerase
		ld a,3
		call .sectorerase

		ld	hl,os.source
		ld	de,$020000
		ld	bc,os.full_binary_len
		call	$2E0 ; WriteFlash
		ld	hl,0
	os_second_binary:=$-3
		ld	de,$020000 + os.full_binary_len
		ld	bc,0
	os_second_binary.len:=$-3
		ld a,c
		or a,b
		call	nz, $2E0 ; WriteFlash
if defined INSTALLER8XP
		ld	a,$04
.erase:
		push	af
		call	.sectorerase
		pop	af
		inc	a
		cp	a,final_sector
	_final_sector_smc := $-1
		jr	nz,.erase

		; Write backup present marker
		ld a,(backup_os_flag)
		or a,a
		ld hl,(bos.fs_IsOSBackupPresent+1) ; load jump location for the routine
		inc hl ; get the marker byte location
		ex hl,de
		ld a,0 ; dont overwrite flags
		call nz,ti.WriteFlashA ; WriteFlashA

		call.is	.lock and $ffff
		ld	a,$d0
		ld	mb,a
		xor	a,a
		ret
else
		ld a,(bos._UnpackUpdates)
		cp a,$C3
		jp z,bos._UnpackUpdates ; jump to update extractor (updated earlier)
        ret
;		rst 0
end if

.sectorerase:
		ld	bc,$f8
		push	bc
		jp	$2dc

		assume	adl = 0

if defined INSTALLER8XP
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

	_sectorerase := .sectorerase
	_unlock := .unlock
	_lock := .lock

end if
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
