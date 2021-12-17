;@DOES Convert OP1 into a BOS file path in /tivars.
;@INPUT OP1 = Var type, Var name.
_OP1ToAbsPath:
	call _OP1ToPath
	ret c
	ld bc,str_tivars_dir
	push hl,bc
	call fs_JoinPath
	pop bc
	ex (sp),hl
	push af,hl
	call sys_Free
	pop bc,af,hl
	ret nc
	sbc hl,hl
	ret
