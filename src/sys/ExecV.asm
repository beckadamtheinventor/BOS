;@DOES Execute a program with argc/argv.
;@INPUT int sys_ExecV(const char *program, int argc, char *const argv[]);
;@OUTPUT process exit code.
sys_ExecV:
	call ti._frameset0
	ld hl,(ix+6)
	ld a,(hl)
	cp a,'A' ; Check if path is uppercase alpha. If it is, check the VAT for the file first.
	jr c,.execute_file
	cp a,'Z'+1
	jr nc,.execute_file
	dec hl
	call ti.Mov9ToOP1
	ld a,$FF
	ld (ti.OP1),a ; set the type byte as a wildcard
	call _SearchSymTable ; just search the symbol table
	jr c,.execute_file ; if the file wasn't found in the VAT, attempt to run it normally.
	cp a,ti.ProgObj
	jr z,.execute_file
	cp a,ti.ProtProgObj
	jr z,.execute_file
	cp a,ti.AppVarObj
	jr z,.parse_string
	cp a,ti.StrngObj
	jr z,.parse_string
	cp a,ti.EquObj
	jr z,.parse_string
	cp a,ti.RealObj
	jr nz,.unimplemented_error
	ex hl,de
	ld a,(hl)
	inc hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld c,(hl)
	ex hl,de
	or a,a
	jr .unimplemented_error
	; jr nz,.unimplemented_error
	; ld de,11
	; push bc,hl,de
	; call sys_Malloc
	; ex (sp),hl
	; call osrt.long_to_str
	; pop bc,bc,bc
	; jr .parse_string_hl
; .parse_float:
	; call ti.ftoa
	; call .print_string_hl
	; db $3E
.parse_string:
	ex hl,de
.parse_string_hl:
	ld a,1 shl bReturnData or 1 shl bReturnNotError
.return_value:
	ld (return_code_flags),a
	ld (LastCommandResult),hl
.return:
	; ld sp,ix
	pop ix
	ret
.unimplemented_error:
	call ti.ErrDataType
	jr .return
.execute_file:
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	call c,sys_OpenFileInPath
	pop bc
	; call existing file not found fail routine
	; so we update bos.ExecutingFileFD
	; this routine always returns Cf set, hl == -1
	call c, sys_ExecuteFile.fail_file_not_found
	jr c,.return
	; execute the file given a descriptor and argc/argv
	ld bc,(ix+9)
	ld de,(ix+12)
	xor a,a
	ld (fsOP5+10),a
	call sys_ExecuteFile.entryfd_argcargv
	; copy exit code to command result
	ld hl,LastExitCode
	ld de,LastCommandResult
	ld bc,4
	ldir
	jr .return
