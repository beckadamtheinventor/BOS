
;@DOES Recursive function used to load EZF executable dependencies.
;@INPUT int sys_LoadEZFDependency(const char *fname);
;@OUTPUT -1 and Cf set if failed.
;@NOTE loads function from fname:func, searching in dirs listed within /var/LIBS if it could not be found directly.
;@DESTROYS All, OP1
sys_LoadEZFDependency:
	pop bc,hl
	push hl,bc
.loadfromfile:
	push hl
	call fs_GetFilePtr
	pop de
	jq nc,.loadfromptr
	ld bc,str_LibsVarName
	push bc,de
	call sys_OpenFileInVar
	pop de,de
	ret c
.loadfromptr:
	ld a,c
	or a,b
	jq z,.fail
	ld a,(hl)
	cp a,$7F
	jq nz,.fail
	inc hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	push hl
	db $21,"EZF"
	xor a,a
	sbc hl,de
	pop hl
	jq z,.fail
	or a,b
	jq nz,.atleastminsize
	ld a,c
	cp a,13
	jq nc,.atleastminsize
;less than minimum size
.fail:
	scf
	sbc hl,hl
	ret
.atleastminsize:
	push hl
	ex (sp),iy
	push iy
	ld (fsOP1),iy
	lea iy,iy-4
.dependencies_loop:
	lea iy,iy+8
	ld a,(iy)
	inc a
	jq z,.done_dependency_loop
	cp a,ezsec.extern - 1
	jq nz,.dependencies_loop
	ld de,(iy + 1)
	ex.s hl,de
	ld de,(fsOP1)
	add hl,de
	push iy,de,hl
	call sys_LoadEZFDependency ;load the dependency
	pop de,de,iy
	jq c,.fail_popiy ;fail if dependency could not be loaded
	ld (fsOP1),de
	jq .dependencies_loop
.done_dependency_loop:

.extract_loop:

.extractloopend:
	
	
	
	
	db $01
.fail_popiy:
	scf
	sbc hl,hl
	pop iy
	ret
