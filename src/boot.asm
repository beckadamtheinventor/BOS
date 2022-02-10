
boot_os:
	call sys_FlashUnlock
	ld a,$05 ;set privleged code end address to $050000 (up until the first non-os filesystem sector)
	out0 ($1F),a
	xor a,a
	out0 ($1D),a
	out0 ($1E),a
	call sys_FlashLock

os_return:
	ld hl,ti.userMem
	ld (top_of_UserMem),hl
	ld hl,end_of_usermem - ti.userMem
	ld (remaining_free_RAM),hl
	or a,a
	sbc hl,hl
	ld (asm_prgm_size),hl

	call ti.boot.Set48MHzMode
	ld a,3           ;set flash wait states to 3, same as the CE C toolchain
	ld ($E00005),a

	ld hl,$000f00		; 0/Wait 15*256 APB cycles before scanning each row/Mode 0/
	ld (ti.DI_Mode),hl
	ld hl,$08080f		; (nb of columns,nb of row) to scan/Wait 15 APB cycles before each scan
	ld (ti.DI_Mode+3),hl
	ld a,2
	ld (running_process_id),a
	xor a,a
	ld (lcd_bg_color),a
	ld (lcd_text_bg),a
	ld (lcd_text_bg2),a
	dec a
	ld (lcd_text_fg),a
	ld a,7
	ld (lcd_text_fg2),a

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

	ld hl,current_working_dir
	ld (hl),'/'
	inc hl
	ld (hl),0

	DisableThreading
	call th_ResetThreadMemory
assert ~thread_temp_save and $FF
	ld hl,thread_temp_save
	ld de,os_return_soft
	ld (hl),de
	ld l,12
	ld (hl),de
	ld de,ti.stackTop
	ld l,3
	ld (hl),de
	ld l,15
	ld (hl),1
	EnableThreading
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
	inc hl
	ld bc,(hl) ;grab argument from caller
	ex hl,de
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

generate_boot_configs:
	push bc
	ld bc,str_EtcConfigDir
	ld e,1 shl fd_subdir
	push de,bc
	call fs_CreateDir
	ld hl,str_EtcConfigBootDir
	ex (sp),hl
	call fs_CreateDir
	pop bc
	ld hl,str_onbootconfig.len
	ex (sp),hl
	ld hl,str_onbootconfig
	ld e,0
	ld bc,str_BootConfigFile
	push hl,de,bc
	call fs_WriteNewFile
	pop bc,bc,bc,bc
	call sys_FreeAll
	call fs_OpenFile
	pop bc
	ret

os_return_soft:
	call os_check_recovery_key
	call sys_FreeAll

	call os_check_recovery_key
	call fs_SanityCheck

	call os_check_recovery_key
	call generate_boot_configs
	jq nc,.run_boot_cmd
; if we can't find the boot config files and can't initialize them try to run the main gui
	ld bc,$FF0000
	push bc
	ld hl,str_ExplorerExecutable
	jq .exec_file_hl
.run_boot_cmd:
	call os_check_recovery_key
	ld de,str_CmdArguments
	push de
	ld hl,str_CmdExecutable	
.exec_file_hl:
	push hl
	call fs_OpenFile
	jq c,boot_failed_critical
	call sys_ExecuteFile
	pop bc,bc
	jq os_recovery_menu

boot_failed_critical:    ; if we can't locate/create the boot configs and we can't locate the main gui or the command interpreter
	ld hl,str_BootFailed ; then notify the user and open the recovery menu. Eventually there will be an emergency command line.
	call gui_DrawConsoleWindow
	; todo: emergency command line
	call sys_WaitKeyCycle
	jq os_recovery_menu

os_check_recovery_key:
	call sys_GetKey
	cp a,53
	ret nz
os_recovery_menu:
	ld sp,ti.stackTop
	xor a,a
	ld (lcd_bg_color),a
	ld (lcd_text_bg),a
	ld (lcd_text_bg2),a
	dec a
	ld (lcd_text_fg),a
	ld a,7
	ld (lcd_text_fg2),a

	DisableThreading

	ld hl,string_os_recovery_menu
	call gui_DrawConsoleWindow
.keywait:
	call sys_WaitKeyCycle
	cp a,ti.skMode
	jq z,.reset_fs
	cp a,ti.skEnter
	jq z,.attempt_recovery
	cp a,ti.skDel
	jq z,.uninstall
	cp a,ti.skClear
	jq z,os_return
	; cp a,ti.skMatrix
	; jq z,.reinstalltios
	cp a,ti.skAlpha
	jq z,.emergencyshell
	; cp a,ti.sk6
	; jq z,.validate
	cp a,ti.sk2nd
	jq nz,.keywait

.turn_off:
	call sys_TurnOff
	rst 0

.reset_fs:
	call .confirm
	call fs_Format
	jq boot_os

.uninstall:
	call .confirm
	ld hl,bos_UserMem
	push hl ;return to usermem which immediately tells the calc to invalidate the OS and reboot
	ld (hl),$CD
	inc hl
	ld de,ti.MarkOSInvalid
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),$C7 ;rst 0
	ld hl,flashStatusByte
	set bKeepFlashUnlocked,(hl)
	call sys_FlashUnlock
	ld a,2
	jq sys_EraseFlashSector ;erase first OS sector, bootcode will handle the rest

; .reinstalltios:
	; call .confirm
	; ld a,($0401FF)
	; inc a
	; jq nz,.reinstalltios_start
	; ld hl,string_failed_to_reinstall
	; call gui_DrawConsoleWindow
	; call sys_WaitKeyCycle
	; jq os_recovery_menu
; .reinstalltios_start:
	; ld de,bos_UserMem
	; push de
	; ld hl,data_reinstall_tios_program
	; ld bc,data_reinstall_tios_program.len
	; ldir
	; jp sys_FlashUnlock

.attempt_recovery:
	call .confirm
	call fs_SanityCheck
	jq os_recovery_menu

; .validate:
	; call .confirm
	; ld hl,str_ValidatingOSFiles
	; call gui_DrawConsoleWindow
	; ld hl,safeRAM
	; push hl
; .validate_loop:
	; ld ix,fs_system_files
	; push ix
	; call fs_OpenFile
	; ex (sp),hl
	; call fs_HashFile
	; pop bc
	; lea hl,ix+32
	; ld de,safeRAM
	; ld b,32
; assert ~safeRAM and $FF
	; ld c,e
; .digest_loop:
	; ld a,(de)
	; cp a,(hl)
	; jq z,.match
	; inc c
; .digest_match:
	; djnz .digest_loop
	; ld a,c
	; or a,a
	; call nz,.verification_fail

	; lea ix,ix+64
	; ld a,(ix)
	; or a,a
	; jq nz,.validate_loop
	; pop bc
	
	; jq .keywait

; .verification_fail:
	; ld hl,str_VerificationFailed
	; call gui_Print
	; lea hl,ix
	; call gui_PrintLine
	; jq sys_WaitKeyCycle

.confirm:
	ld hl,string_press_enter_confirm
	call gui_Print
	call sys_WaitKeyCycle
	cp a,9
	jq nz,os_recovery_menu
	ret

.emergencyshell:
	ld hl,str_EmergencyShellInfo
	call gui_DrawConsoleWindow
	ld bc,256
	ld hl,InputBuffer
	push bc,hl
	call gui_Input
	pop hl,bc
	or a,a
	jq z,os_recovery_menu
	ld a,(hl)
	or a,a
	jr z,.emergencyshell
	ld de,emergency_shell_fs
	push de,hl
	call fs_OpenFileInDir
	pop de,bc
	jr c,.emergencyshell
	push de,hl
	call fs_GetFDPtr
	pop bc
	ex (sp),hl
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,' '
	cpir
	ex hl,de
	pop hl
	call sys_ExecuteFileFromPtr.entryhlde
	jq .emergencyshell


_UnpackUpdates:
	; db $3E ; smc'd into a nop once updates are unpacked
	; ret ; this will only be executed if updates are already unpacked
.extract:
	call gfx_SetDefaultFont
	call fs_ExtractOSBinaries
	jq fs_ExtractOSOptBinaries

	; call sys_FlashUnlock
	; xor a,a
	; ld de,_UnpackUpdates
	; call sys_WriteFlashA
	; jq sys_FlashLock


;tios reinstaller
; virtual at ti.userMem
	; ld a,$02
; data_reinstall_tios_program.loop:
	; push af
	; call data_reinstall_tios_program.sectorerase
	; pop af
	; inc a
	; cp a,$12
	; jq nz,data_reinstall_tios_program.loop
	; ld hl,$2B0000
	; ld de,$020000
	; ld bc,$120000
	; call sys_WriteFlash
	; ld a,$12
; data_reinstall_tios_program.loop2:
	; push af
	; call data_reinstall_tios_program.sectorerase
	; pop af
	; inc a
	; cp a,$3B
	; jq nz,data_reinstall_tios_program.loop2
	; rst 0
; data_reinstall_tios_program.sectorerase:
	; ld bc,$F8
	; push bc
	; jp $2DC
	; load data_reinstall_tios_program.data:$-$$ from $$
; end virtual

; data_reinstall_tios_program:
	; db data_reinstall_tios_program.data
; .len:=$-.

handle_unimplemented:
	DisableThreading
	call gfx_Set8bpp
	ld a,1
	call gfx_SetDraw
	ld hl,str_UnimplementedOSCall
	call gui_DrawConsoleWindow
	ld hl,str_Address0x
	call gui_PrintString
	pop hl
	dec hl ; account for pc increment by the address that called us
	dec hl
	dec hl
	dec hl
	call gui_PrintHexInt
	call gui_NewLine
.keywait:
	call sys_WaitKeyCycle
	cp a,15
	ret z
	cp a,9
	jq nz,.keywait
	jq os_return


