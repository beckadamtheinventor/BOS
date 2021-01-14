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
; gfx_sprite_t *zgx_Extract(zgx_pack_t *pack, const char *asset);
;	arg 0: pointer to asset pack
;	arg 1: title of asset to extract
zgx_Extract:
	call ti._frameset0
	
	ramspace







