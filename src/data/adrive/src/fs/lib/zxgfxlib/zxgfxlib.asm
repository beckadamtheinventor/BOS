;-------------------------------------------------------------------------------
include '../include/library.inc'
include '../include/include_library.inc'
;-------------------------------------------------------------------------------

library 'ZXGFXLIB', 0

;-------------------------------------------------------------------------------
; Dependencies
;-------------------------------------------------------------------------------
include_library '../graphx/graphx.asm'

;-------------------------------------------------------------------------------
; v0 functions
;-------------------------------------------------------------------------------

	export zgx_Init
	export zgx_Extract
	export zgx_Sprite
	export zgx_ScaledSprite




;-------------------------------------------------------------------------------
; macros
;-------------------------------------------------------------------------------

macro setSmcBytes name*
	local addr, data
	postpone
		virtual at addr
			irpv each, name
				if % = 1
					db %%
				end if
				assert each >= addr + 1 + 2*%%
				dw each - $ - 2
			end irpv
			load data: $-$$ from $$
		end virtual
	end postpone

	call	_SetSmcBytes
addr	db	data
end macro

macro setSmcBytesFast name*
	local temp, list
	postpone
		temp equ each
		irpv each, name
			temp equ temp, each
		end irpv
		list equ temp
	end postpone

	pop	de			; de = return vetor
	ex	(sp),hl			; l = byte
	ld	a,l			; a = byte
	match expand, list
		iterate expand
			if % = 1
				ld	hl,each
				ld	c,(hl)
				ld	(hl),a
			else
				ld	(each),a
			end if
		end iterate
	end match
	ld	a,c			; a = old byte
	ex	de,hl			; hl = return vector
	jp	(hl)
end macro

macro smcByte name*, addr: $-1
	local link
	link := addr
	name equ link
end macro

virtual at 0
	Z_ASSET_SPRITE: rb 1
	Z_ASSET_TILEMAP: rb 1
	Z_ASSET_FONTSPRITE: rb 1
	Z_ASSET_1BPPSPRITE: rb 1
	Z_ASSET_2BPPSPRITE: rb 1
	Z_ASSET_4BPPSPRITE: rb 1
	Z_ASSET_COMPRESSEDSPRITE: rb 1
	Z_ASSET_RLETSPRITE: rb 1

	Z_ASSET_LAST := $-1
end virtual


;-------------------------------------------------------------------------------
; code
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
; void zgx_Init(void *ramspace);
;	arg 0: pointer 
zgx_Init:
	pop bc,hl
	push hl,bc
	SetSMCBytes ramspace
	ret

;-------------------------------------------------------------------------------
; gfx_sprite_t *zgx_Extract(gfx_sprite_t *dest, zgx_pack_t *pack, const char *asset);
;	arg 0: pointer to destination sprite
;	arg 1: pointer to asset pack
;	arg 2: title of asset to extract
;	return 0 if destination sprite dimensions are not the same as the asset sprite dimensions
;	return -1 if asset sprite not found
;	return -2 if asset pack invalid
;	return -3 if asset type invalid
zgx_Extract:
	call ti._frameset0

	ld iy,(ix+9)
	ld hl,(iy)
	ld a,(iy+4)
	db $11,"ZGX"
	or a,a
	jq nz,util_return_negtwo
	sbc hl,de
	
	
	ld bc,(iy+16) ;number of assets in pack
	ld a,c
	or a,b
	jq z,util_return_negone

	ld de,(ix+12) ;asset name to search for
	ld hl,(ix+6)
	push hl,iy
	lea ix,iy+18 ;item array
.find_asset_loop:
	push bc
	ld bc,8
	push bc,de
	push ix
	call ti._strncmp
	pop ix,de,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.found_asset
	lea ix,ix+16
	ld a,c
	or a,b
	dec bc
	jq nz,.find_asset_loop

util_retnull:
	or a,a
	db $3E ;dummify next instruction
util_return_negone:
	scf
	sbc hl,hl
	jq util_return

util_return_negthree:
	ld hl,-3
	jq util_return

util_return_negtwo:
	ld hl,-2
util_return:
	ld sp,ix
	pop ix
	ret

;-------------------------------------------------------------------------------
; Draws a zgx-format compressed sprite to the current lcd buffer
; void zgx_Sprite(void *data, int x, int y);
zgx_Sprite:
	ld hl,-6
	call ti._frameset
	ld hl,(ix+6)
	ld (.pallette),hl
	ld bc,8
	add hl,bc
	ld (ix-3),hl
	call gfx_GetDraw
	ld hl,(ti.mpLcdUpBase)
	or a,a
	jq z,.setbuffer
	ld a,(ti.mpLcdUpBase+2)
	ld hl,$D52C00
	cp a,$D4
	jq z,.setbuffer
	ld hl,$D40000
.setbuffer:
	ld (ix-6),hl
	ex hl,de
	ld hl,(ix-3)
	ld b,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld (ix-3),hl
	ld a,b
	ld (.spritewidth),a
.outerloop:
	push de
.loop:
	push bc
	ld hl,(ix-3)
	ld a,(hl)
	ld c,a
	rlca
	rlca
	and a,3
	ld b,a
	inc b
.inner_loop:
	ld a,c
	push bc
	call .draw
	pop bc
	djnz .inner_loop
	pop bc
	djnz .loop
	ld b,0
.spritewidth:=$-1
	pop de
	ld hl,320
	add hl,de
	dec c
	jq nz,.outerloop
	ret
.draw:
	and a,7
	ld (.lowernibble),a
	ld a,(hl)
	inc hl
	ld (ix-3),hl
	rrca
	rrca
	rrca
	and a,7
	ld hl,0
.palette:=$-3
	ld bc,0
	ld c,a
	add hl,bc
	ld a,(hl)
	ld (de),a
	inc de
	sbc hl,bc
	ld c,0
.lowernibble:=$-1
	add hl,bc
	ld a,(hl)
	ld (de),a
	inc de
	ret

;-------------------------------------------------------------------------------
zgx_Extract.found_asset:
	pop de,hl ;de = asset pack, hl = destination sprite

	ld a,(ix+8)
	cp a,Z_ASSET_SPRITE
	jq z,util_extract_sprite
	cp a,Z_ASSET_COMPRESSEDSPRITE
	jq nz,util_return_negthree

	push hl,de
	ld hl,(ix+9)
	ex.s hl,de
	pop hl
	add hl,de
	ex (sp),hl
	push hl
	call util_decompress
	pop hl,bc
	jq util_return


;-------------------------------------------------------------------------------
; helper functions
;-------------------------------------------------------------------------------

util_extract_sprite:
	push hl,de
	ld hl,(ix+9)
	ex.s hl,de
	pop hl
	add hl,de
	pop de
	ld bc,(hl)
	mlt bc
	push de
	ldir
	pop hl
	jq util_return



; Code from CE Toolchain by Einar Saukas & Urusergi
util_decompress:
        pop     bc
        pop     de
        pop     hl
        push    hl
        push    de
        push    bc

        ld      a, 128

zx7t_copy_byte_loop:

        ldi                             ; copy literal byte

zx7t_main_loop:

        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        jr      nc, zx7t_copy_byte_loop ; next bit indicates either literal or sequence

; determine number of bits used for length (Elias gamma coding)

        push    de
        ld      de, 0
        ld      bc, 1

zx7t_len_size_loop:

        inc     d
        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        jr      nc, zx7t_len_size_loop
        jp      zx7t_len_value_start

; determine length

zx7t_len_value_loop:

        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        rl      c
        rl      b
        jr      c, zx7t_exit           ; check end marker

zx7t_len_value_start:

        dec     d
        jr      nz, zx7t_len_value_loop
        inc     bc                      ; adjust length

; determine offset

        ld      e, (hl)                 ; load offset flag (1 bit) + offset value (7 bits)
        inc     hl

        sla e
        inc e

        jr      nc, zx7t_offset_end    ; if offset flag is set, load 4 extra bits
        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        rl      d                       ; insert first bit into D
        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        rl      d                       ; insert second bit into D
        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        rl      d                       ; insert third bit into D
        add     a, a                    ; check next bit
        call    z, zx7t_load_bits      ; no more bits left?
        ccf
        jr      c, zx7t_offset_end
        inc     d                       ; equivalent to adding 128 to DE

zx7t_offset_end:

        rr      e                       ; insert inverted fourth bit into E

; copy previous sequence

        ex      (sp), hl                ; store source, restore destination
        push    hl                      ; store destination
        sbc     hl, de                  ; HL = destination - offset - 1
        pop     de                      ; DE = destination
        ldir

zx7t_exit:

        pop     hl                      ; restore source address (compressed data)
        jp      nc, zx7t_main_loop

zx7t_load_bits:

        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
        ret


