
; /dev/stdout device type memory, writable, version 2, handling no interrupts.
device_file devtMemory, mDeviceWritable, 2, deviceIntNone
	export device_JumpWrite,      dev_stdout_write
dev_stdout_write:
	call ti._frameset0
	ld hl,(ix+6) ; buffer
	ld bc,(ix+9) ; len
	pop ix
.loop:
	push bc
	ld a,(hl)
	call bos.gui_PrintChar
	pop bc
	cpi
	ret po
	jr .loop

; saves hl
; stdout_putchar:
; assert stdout_curcol = stdout_currow+1
	; ld de,(stdout_currow)
	; ld a,e ; a = currow
	; ld e,9
	; mlt de ; curcol * 9
	; ld (lcd_x),de
	; ld e,a ; e = currow
	; add a,a ; x2
	; add a,a ; x4
	; add a,a ; x8
	; add a,e ; x9
	; ld (lcd_y),a
	; push hl
	; ld a,(hl)
	; call bos.gfx_PrintChar
	; jr c,.controlcode
; .advance:
	; ld a,(stdout_curcol)
; .advance_entry:
	; cp a,40
	; jr nc,.advance_new_line
	; inc a
	; ld (curcol),a
	; pop hl
	; ret
; .advance_new_line:
	; xor a,a
	; sbc hl,hl
	; ld (lcd_x),hl
	; ld (stdout_curcol),a
	; ld a,(stdout_currow)
	; cp a,25
	; jr nc,.scroll
	; inc a
	; ld (stdout_currow),a
	; jr .done
; .scroll:
	; push hl
	; call bos.gui_Scroll
	; pop hl
; .done:
	; call bos.gfx_BlitBuffer
	; pop hl
	; ret

; .controlcode:
	; or a,a
	; jr z,.nextline
	; cp a,$0A ;LF
	; jr z,.nextline
	; cp a,$09 ;TAB
	; jr nz,.advance
; .tab:
	; ld a,(stdout_curcol)
	; inc a
	; inc a
	; jr .advance_entry
; .nextline:
	; ld a,(stdout_currow)
	; cp a,25
	; jq nc,.scroll
	; inc a
	; ld (stdout_currow),a
	; call bos.gfx_BlitBuffer
	; jr .advance

end device_file
