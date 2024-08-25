
boot_os:
	; ld a,$8C
	; out0 ($24),a
	; in0 a,($06)
	; set 2,a
	; out0 ($06),a
	; ld a,4
	; out0 ($28),a
	call sys_FlashUnlock

	ld a,$05 ;set privleged code end address to $050000 (up until the first non-os filesystem sector)
	out0 ($1F),a
	xor a,a
	out0 ($1D),a
	out0 ($1E),a
	
	; ld a,($3F0000)
	; inc a
	; ld a,$3F
	; call nz,sys_EraseFlashSector ; erase this sector if it contains data
	
	call sys_FlashLock

	call sys_GetRandomAddress
	ld (random_source_ptr),hl

os_return:
	ld sp,ti.stackTop
	im 1 ; set interrupt mode 1
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
	; ld a,2
	; ld (running_process_id),a
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
	ld de,os_on_interrupt_handler
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
	ld (hl),2
	EnableThreading
	jq th_HandleNextThread.nosave

handle_interrupt:
	ld bc,$5015
	in a,(bc)
	or a,a
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
handle_interrupt_2:
	ld c,$14
	in a,(bc)
	or a,a
	jr z,handle_interrupt_3
	ld c,$08
	rra
	jq c,low_bit_0_int ; On interrupt
	rra
	jq c,low_bit_1_int
	rra
	jq c,low_bit_2_int
	rra
	jq c,low_bit_3_int
	rra
	jq c,low_bit_4_int ; OS timer interrupt
	ld a,$FF
	out (bc),a
handle_interrupt_3:
	ld c,$16
	in a,(bc)
	jr z,return_from_interrupt
	ld c,$0A
	rra
	jq c,byte_3_bit_0_int
	rra
	rra
	rra
	jq c,byte_3_bit_3_int
	ld a,$FF
	out (bc),a
	jr return_from_interrupt
check_bad_interrupt:
	ld hl,12
	add hl,sp
	ld hl,(hl)
	ld a,(hl)
	inc a
	call z,handle_bad_interrupt
return_from_interrupt:
	; ld iy,ti.flags
	; res 6,(iy+ti.apdFlags2)
	pop hl
	pop iy,ix
.exx_reti:
	exx
	exaf
	ei
	reti

low_bit_0_int: ; On interrupt
	ld a,1 shl 0
	out (bc),a
	ld c,4
	in a,(bc)
	res 0,a
	out (bc),a
	call on_interrupt_handler
	jr return_from_interrupt
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
byte_3_bit_0_int:
	ld a,1 shl 0
	out (bc),a
	ld c,6
	in a,(bc)
	res 0,a
	out (bc),a
	jq return_from_interrupt
byte_3_bit_3_int:
	ld a,1 shl 3
	out (bc),a
	ld c,6
	in a,(bc)
	res 3,a
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

os_on_interrupt_handler:
	call sys_AnyKey
	ret z
	call sys_GetKey
	cp a,ti.skYequ
	jp z,os_recovery_menu
	cp a,ti.skClear
	ret nz
	ld sp,ti.stackTop
	jp os_return_soft

handle_offsetinstruction:
.offset_inst_temp := -20
	ld (offset_inst_hl_temp),hl ; save original value of hl
	push de,iy,af ; save de, iy, af
	ld iy,9
	add iy,sp ; grab pointer to arguments
	ld hl,(iy) ; grab pointer to caller
	ld a,(hl)
	call .check_opcode_is_call ; returns cf if not a call instruction
	jq c,.offset_non_call_instruction
.offset_call_instruction:
	lea de,iy + -3 + .offset_inst_temp ; grab pointer to 23 bytes of stack space below the current stack pointer
	ld (offset_inst_sp_temp),de
	ld a,(hl)
	inc hl
	ld (iy + .offset_inst_temp),a ; first opcode byte
	call .resolve_argument ; load &caller[argument] or lib entry point
	ld (iy + .offset_inst_temp + 1),hl ; load relocated argument
	ld a,$C9   ; ret opcode
	ld (iy + .offset_inst_temp + 4),a

	ld hl,(offset_inst_sp_temp)
	ld de,.return_here ; return here after running a recursive offset instruction
	ld (hl),de
	lea hl,iy + .offset_inst_temp ; location of relocated code
	jq .jump_to_offset_inst

.offset_non_call_instruction:
	lea de,iy+3 ; pop caller off the stack because we jump to it instead of returning to it
	ld (offset_inst_sp_temp),de
	ld iy,ti.OP4
	ld a,(hl)
	inc hl
	ld (iy),a ; first opcode byte
	cp a,$DD ; two byte instruction
	jr z,.isa2binstruction
	cp a,$ED ; two byte instruction
	jr z,.isa2binstruction
	cp a,$FD ; two byte instruction
	jr nz,.isnota2binstruction
.isa2binstruction:
	ld a,(hl)
	inc hl
	ld (iy + 1),a ; second opcode byte
	call .resolve_argument ; load &caller[argument] or lib entry point
	ld (iy + 2),hl ; load relocated argument
	jr .finish
.isnota2binstruction:
	call .resolve_argument ; load &caller[argument] or lib entry point
	ld (iy + 1),hl ; load relocated argument
	xor a,a
	ld (iy + 4),a
.finish:
	ld a,$C3   ; unconditional jp opcode
	ld (iy + 5),a
	ld (iy + 6),de ; instruction following that of the caller
	lea hl,iy ; location of relocated code
.jump_to_offset_inst:
	pop af,iy,de ; restore af, iy, de
	ld sp,(offset_inst_sp_temp)
	push hl ; push jump location
	ld hl,(offset_inst_hl_temp) ; restore original value of hl
	ret ; return to the routine, which will return to .return_here if an offset call instruction is being executed

.return_here:
	push af,hl
; set hl to sp when handle_offsetinstruction started
	ld hl, 6 - .offset_inst_temp ; relative to current sp
	add hl,sp
	ld (offset_inst_sp_temp),hl
	pop hl,af
	ld sp,(offset_inst_sp_temp)
	ret

; returns cf if A is not a call instruction
.check_opcode_is_call:
	cp a,$CD
	ret z
	sub a,$C4 ; lowest call opcode byte
	ret c
	and a,$F
	ret z
	cp a,8
	ret z
	scf
	ret

._osrt_lib_table := $04E000
.resolve_argument:
	ld de,(hl) ;grab argument from caller
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	; ld (iy),hl ; increment caller past the original instruction
	ex hl,de
	add hl,de
	inc a
	ret z
	bit 7,a
	ret z
	res 7,a
	ld l,a  ; a*=3
	add a,a ; a*2
	add a,l ; a*2 + a
	ld hl,._osrt_lib_table
	call sys_AddHLAndA
	ld hl,(hl)
	add hl,de
	ld a,(hl)
	cp a,$CD
	jr z,.jump
	cp a,$C3
	ret nz
.jump:
	jp (hl)

os_GetOSInfo:
	ld hl,string_os_info
os_DoNothing:
DONOTHING:
	ret

generate_boot_configs:
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
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	scf
	ret

os_return_soft:
	; ld hl,ti.mpIntMask
	; set ti.bIntOn,(hl)
	; set ti.bIntOSTmr,(hl)
	call gfx_Set8bpp
	xor a,a
	call gfx_SetDraw

	call os_check_recovery_key
	call sys_FreeAll

	call os_check_recovery_key
	call fs_SanityCheck

	call os_check_recovery_key
	call _ResetAndBuildVAT

	ld hl,str_DevNull
	call drv_InitDevice.entryhl

	ld hl,str_DevLcd
	call drv_InitDevice.entryhl

	ld hl,str_DevStdout
	push hl
	call drv_InitDevice.entryhl
	call nc,fs_OpenFile
	pop bc
	jr c,.nostdout
	call sys_SearchDeviceTable.entryhl
	jr nz,.hasstdout
	sbc hl,hl
.hasstdout:
	ld (stdout_fd_ptr),hl
.nostdout:

	; ld hl,str_AutoExtractOptFile
	; push hl
	; call fs_OpenFile
	; pop bc
	; jr c,.no_autoextractopt
	; ex hl,de
	; call sys_FlashUnlock
	; xor a,a
	; call sys_WriteFlashA
	; call sys_FlashLock
	; call fs_SanityCheck.extract_opt_binaries
; .no_autoextractopt:
	call os_check_recovery_key
	ld bc,str_BootConfigFile
	push bc
	call fs_OpenFile
	pop bc
	call c,generate_boot_configs
	jr nc,.run_boot_cmd
; if we can't find the boot config files and can't initialize them try to run the main gui
	ld bc,$FF0000
	push bc
	ld hl,str_ExplorerExecutable
	jr .exec_file_hl
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
	jr os_recovery_menu

boot_failed_critical:    ; if we can't locate/create the boot configs and we can't locate the main gui or the command interpreter
	ld hl,str_BootFailed ; then notify the user and open the recovery menu.
	call gui_DrawConsoleWindow
	call sys_WaitKeyCycle
	jr os_recovery_menu

os_check_recovery_key:
	call sys_GetKey
	cp a,53
	ret nz
os_recovery_menu:
	di
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

	ld hl,string_os_info
	call gui_DrawConsoleWindow
	ld hl,string_os_recovery_menu
	call gui_PrintLine
	call fs_IsOSBackupPresent
	ld hl,string_restore_os_option
	call nz,gui_PrintLine
.keywait:
	call sys_WaitKeyCycle
	cp a,ti.skYequ
	jp z,0
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
	jr z,.tryruncmd
	cp a,ti.sk7
	jq z,.turn_off

	cp a,ti.skStat
	jq nz,.keywait
	call fs_IsOSBackupPresent
	jq z,.keywait

.reinstall_from_backup:
	call .confirm
.reinstall_from_backup_start:
	ld de,bos_UserMem
	push de
	ld hl,data_reinstall_backup_program
	ld bc,data_reinstall_backup_program.len
	ldir
	xor a,a
	jp sys_FlashUnlock


.turn_off:
	call sys_TurnOff
	jq os_recovery_menu

.tryruncmd:
	ld hl,str_CmdExecutable
	ld de,$FF0000
	push de,hl
	call sys_ExecuteFile
	ld hl,(ExecutingFileFd)
	inc hl
	add hl,de
	or a,a
	sbc hl,de
	jr nz,.successfulyrancmd
	ld hl,str_CmdExecutableNotFound
	call gui_PrintLine
	call sys_WaitKeyCycle
.successfulyrancmd:
	jq os_recovery_menu

.reset_fs:
	call .confirm
	call fs_Format
	jq boot_os

.uninstall:
	call .confirm
	call gfx_Set16bpp
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
	push hl,de
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,' '
	cpir
	ex hl,de
	pop hl
	call sys_ExecuteFileFD
	jr .emergencyshell


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


; Backup reinstaller
virtual at ti.userMem
; reset sectors needed to store backed up OS
data_reinstall_backup_program.begin:
	ld a,$02
data_reinstall_backup_program.loop:
	push af
	call data_reinstall_backup_program.sectorerase
	pop af
	inc a
	cp a,$02+$3B-(fs_os_backup_location shr 16)
	jq nz,data_reinstall_backup_program.loop
; copy backup to OS area
	ld hl,fs_os_backup_location
	ld de,$020000
	ld bc,$3B0000-fs_os_backup_location
	call sys_WriteFlash ; (bootcode routine)
; reset other sectors
	ld a,$02+$3B-(fs_os_backup_location shr 16)
data_reinstall_backup_program.loop2:
	push af
	call data_reinstall_backup_program.sectorerase
	pop af
	inc a
	cp a,$3B
	jq nz,data_reinstall_backup_program.loop2
; clear BOS's cluster map from the certificate sector
assert fs_cluster_map > $3B0000
	ld hl,$3B0000
	ld de,LCD_BUFFER
	ld bc,fs_cluster_map-$3B0000
	push bc,de,hl
	ldir
	ld a,$3B
	call data_reinstall_backup_program.sectorerase
	pop de,hl,bc
	call sys_WriteFlash ; (bootcode routine)
; full restart because TIOS *probably* wouldn't like to be jumped to without it
	rst 0
data_reinstall_backup_program.sectorerase:
	ld bc,$F8
	push bc
	jp $2DC ; bootcode routine
	load data_reinstall_backup_program.data:$-$$ from $$
end virtual

data_reinstall_backup_program:
	db data_reinstall_backup_program.data
.len:=$-.

handle_bad_interrupt:
	ld hl,threading_enabled
	ld a,(hl)
	push af
	ld (hl),0
	ld a,(ti.mpLcdCtrl)
	push af
	call gfx_Set8bpp
	ld hl,str_BadInterrupt
	call gui_DrawConsoleWindow
	jr handle_unimplemented.terminateorcontinue

handle_unimplemented:
	ld hl,threading_enabled
	ld a,(hl)
	push af
	ld (hl),0
	ld a,(ti.mpLcdCtrl)
	push af
	call gfx_Set8bpp
	ld hl,str_UnimplementedOSCall
	call gui_DrawConsoleWindow
	ld hl,str_Address0x
	call gui_PrintString
	pop af
	pop hl ; af->hl
	ex (sp),hl ; hl->af, (sp)->hl
	dec hl ; account for pc increment by the address that called us
	dec hl
	dec hl
	dec hl
	push af
	call gui_PrintHexInt
.terminateorcontinue:
	call gui_NewLine
	ld hl,str_TerminateOrContinue
	call gui_PrintLine
.keywait:
	call sys_WaitKeyCycle
	cp a,15
	jr z,.pop_lcd_state_threading_state
	cp a,9
	jr nz,.keywait
	jq os_return
.pop_lcd_state_threading_state:
	pop af
	cp a,ti.lcdBpp8
	jr z,.pop_threading_state
	ld (ti.mpLcdCtrl),a
	call ti.boot.ClearVRAM
.pop_threading_state:
	pop af
	ld (threading_enabled),a
	ret

