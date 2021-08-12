
boot_os:
	call sys_FlashUnlock
	ld a,$04 ;set privleged code end address to $040000 (up until the first filesystem sector)
	out0 ($1F),a
	xor a,a
	out0 ($1D),a
	out0 ($1E),a
	call sys_FlashLock
	call ti.boot.Set48MHzMode
	ld a,3           ;set flash wait states to 3, same as the CE C toolchain
	ld ($E00005),a

	call gfx_SetDefaultFont
	call gfx_Set8bpp

	ld hl,$000f00		; 0/Wait 15*256 APB cycles before scanning each row/Mode 0/
	ld (ti.DI_Mode),hl
	ld hl,$08080f		; (nb of columns,nb of row) to scan/Wait 15 APB cycles before each scan
	ld (ti.DI_Mode+3),hl
	ld a,1
	ld (running_process_id),a
	xor a,a
	ld (lcd_bg_color),a
	ld (lcd_text_bg),a
	ld (lcd_text_bg2),a
	dec a
	ld (lcd_text_fg),a
	ld a,7
	ld (lcd_text_fg2),a

	ld hl,bos_UserMem
	ld (bottom_of_RAM),hl
	ld (top_of_UserMem),hl
	ld hl,top_of_RAM-$010000
	ld (free_RAM_ptr),hl
	ld bc,-bos_UserMem
	add hl,bc
	ld (remaining_free_RAM),hl
	or a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,op_stack_top
	ld (op_stack_ptr),hl
	ld de,os_recovery_menu
	ld hl,on_interrupt_handler-1
	ld (hl),$C3 ;jp opcode byte
	inc hl
	ld (hl),de
	xor a,a
	ld (flashStatusByte),a
	inc a
	call gfx_SetDraw

	call fs_SanityCheck

	ld hl,current_working_dir
	ld (hl),'/'
	inc hl
	ld (hl),0

	call th_ResetThreadMemory
assert ~thread_temp_save and $FF
	ld hl,thread_temp_save
	ld de,os_return
	ld (hl),de
	ld de,ti.stackTop
	ld l,3
	ld (hl),de
	ld l,12
	ld (hl),1
	jq th_HandleNextThread.nosave

handle_interrupt:
	ld bc,$5015
	in a,(bc)
	jr z,handle_interrupt_2
	ld c,$09
	rla
	rla
	jq c,high_bit_6_int
	rla
	jq c,high_bit_5_int
	rla
	jq c,high_bit_4_int
	rla
	jq c,high_bit_3_int
	ld a,$FF
	out (bc),a
	jq return_from_interrupt
handle_interrupt_2:
	ld c,$14
	in a,(bc)
	jq z,return_from_interrupt
	ld c,$08
	rra
	jq c,low_bit_0_int
	rra
	jq c,low_bit_1_int
	rra
	jq c,low_bit_2_int
	rra
	jq c,low_bit_3_int
	rra
	jq c,low_bit_4_int
	ld a,$FF
	out (bc),a
return_from_interrupt:
	ld iy,$D00080
	res 6,(iy+$1B)
	pop hl
	pop iy,ix
	exx
	exaf
	ei
	reti

low_bit_0_int:
	ld a,1 shl 0
	out (bc),a
	ld c,4
	in a,(bc)
	res 0,a
	out (bc),a
	jq on_interrupt_handler-1
low_bit_1_int:
	ld a,1 shl 1
	out (bc),a
	ld c,4
	in a,(bc)
	res 1,a
	out (bc),a
	jq return_from_interrupt
low_bit_2_int:
	ld a,1 shl 2
	out (bc),a
	ld c,4
	in a,(bc)
	res 2,a
	out (bc),a
	jq return_from_interrupt
low_bit_3_int:
	ld a,1 shl 3
	out (bc),a
	ld c,4
	in a,(bc)
	res 3,a
	out (bc),a
	jq return_from_interrupt
low_bit_4_int: ;OS timer interrupt
	ld a,1 shl 4
	out (bc),a
	ld c,4
	in a,(bc)
	res 4,a
	out (bc),a
	jq return_from_interrupt
high_bit_3_int:
	ld a,1 shl 3
	out (bc),a
	ld c,5
	in a,(bc)
	res 3,a
	out (bc),a
	jq return_from_interrupt
high_bit_4_int:
	ld a,1 shl 4
	out (bc),a
	ld c,5
	in a,(bc)
	res 4,a
	out (bc),a
	jq return_from_interrupt
high_bit_5_int: ;USB interrupt
	ld a,1 shl 5
	out (bc),a
	ld c,5
	in a,(bc)
	res 5,a
	out (bc),a
	jq return_from_interrupt
high_bit_6_int:
	ld a,1 shl 6
	out (bc),a
	ld c,5
	in a,(bc)
	res 6,a
	out (bc),a
	jq return_from_interrupt


handle_safeop:
	ld (ScrapMem),hl
	ld hl,safeRAM
	or a,a
	sbc hl,de
	jq c,.fail
	ld hl,ti.vRam + 320*240*2 - safeRAM
	or a,a
	sbc hl,de
	jq c,.fail
	pop hl
	push hl
	push af
	ld a,(hl)
	or a,a
	jq z,._ldi_0
	dec a
	jq z,._ldi
.done:
	pop af
.fail:
	ld hl,(ScrapMem)
	ret
._ldi_0:
	ld (de),a
	inc de
	jq .done
._ldi:
	ld hl,(ScrapMem)
	ldi
	pop af
	ret

handle_offsetcall:
	push hl,af,de,bc
	ld hl,12
	add hl,sp
	ld de,(hl) ;grab pointer to caller
	ex hl,de
	ld bc,(hl) ;grab argument from caller
	ex hl,de
	inc de
	inc de
	inc de
	ld (hl),de ;advance pointer to caller by 3 bytes so we return to caller+3
	ld hl,(running_program_ptr) ;pointer to currently running program
	add hl,bc ;jump to &running_program[offset]
	pop bc,de,af
	ex (sp),hl ;push jump location, restore HL
	ret

os_GetOSInfo:
	ld hl,string_os_info
os_DoNothing:
DONOTHING:
	ret

os_return:
	call sys_GetKey
	cp a,53
	jq z,os_recovery_menu
	call gfx_Set8bpp
	ld bc,$FF0000
	ld hl,str_StartupProgram
	push bc,hl
	call sys_ExecuteFile
	pop bc,bc

	call th_EndAllThreads
; check if recovery key was pressed
	ld a,(last_keypress)
	cp a,53
	jq nz,os_return

	ld sp,ti.stackTop
os_recovery_menu:
	xor a,a
	ld (lcd_bg_color),a
	ld (lcd_text_bg),a
	ld (lcd_text_bg2),a
	dec a
	ld (lcd_text_fg),a
	ld a,7
	ld (lcd_text_fg2),a
	ld hl,string_os_recovery_menu
	call gui_DrawConsoleWindow
.keywait:
	call sys_WaitKeyCycle
	cp a,55
	jq z,.reset_fs
	cp a,54
	jq z,.turn_off
	cp a,9
	jq z,.attempt_recovery
	cp a,56
	jq z,.uninstall
	cp a,15
	jq z,boot_os
	cp a,39
	jq z,.reinstalltios
	
	jq .keywait

.reset_fs:
	ld hl,string_press_enter_confirm
	call gui_Print
	call sys_WaitKeyCycle
	cp a,9
	jq nz,os_recovery_menu
	call fs_Format
	jq boot_os

.turn_off:
	call sys_TurnOff
	jq boot_os

.attempt_recovery:
	call fs_SanityCheck
	jq os_recovery_menu

.uninstall:
	ld hl,string_press_enter_confirm
	call gui_Print
	call sys_WaitKeyCycle
	cp a,9
	jq nz,os_recovery_menu
	ld hl,bos_UserMem
	push hl ;return to usermem which immediately tells the calc to invalidate the OS and reboot
	ld (hl),$CD
	inc hl
	ld de,ti.MarkOSInvalid
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),$CF ;rst $08
	ld hl,flashStatusByte
	set bKeepFlashUnlocked,(hl)
	call sys_FlashUnlock
	ld a,2
	jq sys_EraseFlashSector ;erase first OS sector, bootcode will handle the rest

.reinstalltios:
	ld hl,string_press_enter_confirm
	call gui_Print
	call sys_WaitKeyCycle
	cp a,9
	jq nz,os_recovery_menu
	ld a,($0401FF)
	inc a
	jq nz,.reinstalltios_start
	ld hl,string_failed_to_reinstall
	call gui_DrawConsoleWindow
	call sys_WaitKeyCycle
	jq os_recovery_menu
.reinstalltios_start:
	ld de,bos_UserMem
	push de
	ld hl,data_reinstall_tios_program
	ld bc,data_reinstall_tios_program.len
	ldir
	jp sys_FlashUnlock


;tios reinstaller
virtual at ti.userMem
	ld a,$02
data_reinstall_tios_program.loop:
	push af
	call data_reinstall_tios_program.sectorerase
	pop af
	inc a
	cp a,$12
	jq nz,data_reinstall_tios_program.loop
	ld hl,$2B0000
	ld de,$020000
	ld bc,$120000
	call sys_WriteFlash
	ld a,$12
data_reinstall_tios_program.loop2:
	push af
	call data_reinstall_tios_program.sectorerase
	pop af
	inc a
	cp a,$3B
	jq nz,data_reinstall_tios_program.loop2
	rst 0
data_reinstall_tios_program.sectorerase:
	ld bc,$F8
	push bc
	jp $2DC
	load data_reinstall_tios_program.data:$-$$ from $$
end virtual

data_reinstall_tios_program:
	db data_reinstall_tios_program.data
.len:=$-.

