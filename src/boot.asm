
boot_os:
	ld iy,iyflags
	ld hl,bos_UserMem
	ld (iy+flags.bottom_of_RAM),hl
	ld hl,top_of_RAM
	ld (iy+flags.free_RAM_ptr),hl
	ld bc,-bos_UserMem
	add hl,bc
	ld (iy+flags.remaining_free_RAM),hl
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
	ld bc,$5004
	in a,(bc)
	set 0,a
	out (bc),a
	inc c
	in a,(bc)
	set 5,a
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
	call gui_NewLine
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
	pop bc
	jr c,.fail
	ld (ScrapMem),hl
	ld a,(ScrapMem+2)
	or a,h
	or a,l
	jr z,.exit
	call gui_PrintInt
	call gui_NewLine
.exit:
	pop bc,bc
	jq os_main
.fail:
	ld hl,str_CouldNotLocateExecutable
	call gui_Print
	jr .exit

handle_interrupt:
	ld bc,$5015
	in a,(bc)
	jq z,.check_interrupt_low
	rla
	rla
	rla
	jq c,handle_usb_interrupt
	
	ld c,$09
	jq .reset_int
.check_interrupt_low:
	
	
	ld c,$0A
.reset_int:
	ld a,$FF
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
