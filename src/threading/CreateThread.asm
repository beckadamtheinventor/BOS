
;@DOES spawn a thread
;@INPUT uint8_t th_CreateThread(void *pc, void *sp, const char *args);
;@OUTPUT thread id. 0 if failed
th_CreateThread:
	db $3E ;ld a,...
.noparent:
	xor a,a
	ld e,a
	call th_FindFreeThread
	ret z
	ld c,a
	set bThreadAlive,(hl)
	ld a,e
	or a,a
	jr z,._dontsetparent
if (thread_map shr 8) + 1 = (thread_parents shr 8)
	inc h
else
	ld h,$FF and (thread_parents shr 8)
end if
	ld a,(current_thread)
	ld (hl),a
._dontsetparent:
if (thread_map shr 8) and $FF = $FF
	or a,a
end if
	sbc hl,hl
	ld l,c
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,thread_temp_save
	add hl,bc
	ld iy,0
	add iy,sp
	ld de,(iy+3) ; void *pc
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld bc,(iy+9) ; const char *args
	push bc
	ld iy,(iy+6) ; void *sp
	ld bc,._thread_return_handler
	ld (iy-3),bc
	pop bc
	ld (iy-6),bc
	lea iy,iy-6
	ld (hl),iy
	ld bc,12-3
	add hl,bc
	ld (hl),de ; void *pc (initial pc)
	inc hl
	inc hl
	inc hl
	ld a,(running_process_id) ; malloc id
	ld (hl),a
	ret

._thread_return_handler:
	ld hl,thread_map
	ld a,(current_thread)
	ld l,a
if ~thread_map and $FF00
	ld (hl),h
else
	ld (hl),0
end if
if (thread_map shr 8) + 1 = (thread_parents shr 8)
	inc h
else
	ld h,$FF and (thread_parents shr 8)
end if
	ld a,(hl)
	or a,a
	jq z,._ranthread
	dec a ; guarantee the next thread processed is this thread's parent thread if it is a parented thread
	ld (current_thread),a
	call _WakeThread
._ranthread:
	pop bc
	push de,hl
	; call .normalize_lcd
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	call sys_FreeRunningProcessId ;free memory allocated by the program
	call sys_PrevProcessId
	pop hl,de
	jq th_HandleNextThread.nosave
