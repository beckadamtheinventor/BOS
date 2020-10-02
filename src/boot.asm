
boot_os:
	call flash_unlock
	ld a,$08 ;set privleged code address to $080000
	out0 ($1F),a
	xor a,a
	out0 ($1D),a
	out0 ($1E),a
	call flash_lock
	ld hl,bos_UserMem
	ld (bottom_of_RAM),hl
	ld hl,top_of_RAM
	ld (free_RAM_ptr),hl
	ld bc,-bos_UserMem
	add hl,bc
	ld (remaining_free_RAM),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	or a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,op_stack_top
	ld (op_stack_ptr),hl
	call gfx_SetDefaultFont
	call gfx_Set8bpp
	call fs_SanityCheck
	ld hl,current_working_dir
	db $01 ;ld bc,...
	db "C:/"
	ld (hl),bc
	inc hl
	inc hl
	inc hl
	ld (hl),0
os_return:
	call gfx_Set8bpp
	ld hl,str_StartupProgram
	push hl
	call sys_ExecuteFile
	pop bc
os_main:
	ld bc,$500C
	ld a,$FF
	out (bc),a
	inc c
	out (bc),a
	ld bc,$5005
	xor a,a
	out (bc),a
	dec c
	inc a
	out (bc),a
	ei
enter_input:
	ld bc,255
	push bc
	ld bc,InputBuffer
	push bc
	call gui_Input
	or a,a
	jr z,.exit
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	ld a,' '
	cpir
	jr nz,.noargs
	dec hl
	ld (hl),0 ;replace the space with null so the file is easier to open
	inc hl ;bypass the space lol
.noargs:
	ex (sp),hl ;args
	push hl ;path
	call sys_ExecuteFile
	pop bc,bc
	jr c,.fail
	ld (ScrapMem),hl
	ld a,(ScrapMem+2)
	or a,h
	or a,l
	jr z,.exit
	push hl
	call gfx_BlitBuffer
	pop hl
	call gui_PrintInt
	call gui_NewLine
	or a,$FF
.exit:
	call z,gfx_BlitBuffer
	pop bc,bc
	jq os_main
.fail:
	ld hl,str_CouldNotLocateExecutable
	call gui_Print
	jr .exit

handle_interrupt:
	ld bc,$5001
	in a,(bc)
	jq z,.check_interrupt_low
	rla
	rla
	rla
	jq c,handle_usb_interrupt
	
	jq .reset_int
.check_interrupt_low:

.reset_int:
	ld a,$FF
	ld bc,$5008
	out (bc),a
	inc c
	out (bc),a
return_from_interrupt:
	pop hl
	pop iy,ix
	exx
	exaf
	ei
	reti

handle_usb_interrupt:
	jq return_from_interrupt
