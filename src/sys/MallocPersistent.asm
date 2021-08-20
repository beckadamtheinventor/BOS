;@DOES Allocate memory to be treated as persistent
;@INPUT same as sys_Malloc
;@OUTPUT same as sys_Malloc
sys_MallocPersistent:
	pop bc,de
	push de,bc
	ld hl,running_process_id
	ld c,(hl)
	ld (hl),1
	push bc,de
	call sys_Malloc
	pop bc,bc
	ld a,c
	ld (running_process_id),a
	ret
