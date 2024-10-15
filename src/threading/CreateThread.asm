
;@DOES spawn a thread
;@INPUT uint8_t th_CreateThread(void *pc, void *sp, int argc, char **argv);
;@OUTPUT thread id. 0 if failed
;@NOTE void *sp must be allocated at least 12 bytes behind it. If void *sp is 0, it will use the sp from the caller, minus 24 bytes.
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
assert thread_parents and $FF
	set 6,l
	ld a,(current_thread)
	ld (hl),a
._dontsetparent:
if (thread_map shr 8) and $FF = $FF
	or a,a
end if
	sbc hl,hl
	ld l,c
	ld a,c
	push af
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,thread_temp_save
	add hl,bc
	ld iy,0
	add iy,sp
	ld de,(iy+6) ; void *pc
	ld (hl),de
	inc hl
	inc hl
	inc hl
	push hl
	ld hl,(iy+9) ; void *sp
	ld a,(iy+11)
	or a,h
	or a,l
	jr nz,.non_zero_sp
	ld hl,-24
	add hl,sp
.non_zero_sp:
	ex (sp),hl ; save new sp, restore thread save area
	ex (sp),ix ; save ix, restore new sp into ix
	ld bc,(iy+15) ; int argv
	ld (ix-3),bc
	ld bc,(iy+12) ; int argc
	ld (ix-6),bc
	ld bc,._thread_return_handler
	ld (ix-9),bc ; set return address
	lea ix,ix-9
	ld (hl),ix ; set thread saved sp
	pop ix ; restore ix
	ld bc,12-3
	add hl,bc
	ld (hl),de ; void *pc (initial pc)
	inc hl
	inc hl
	inc hl
	ld a,(running_process_id) ; malloc id
	ld (hl),a
	pop af
	ret

._thread_return_handler:
	ld (LastExitCode),hl
	ld a,e
	ld (LastExitCode+3),a
	ld hl,thread_map
	ld a,(current_thread)
	ld l,a
if thread_map and $FF00
	ld (hl),0
else
	ld (hl),h
end if
assert thread_parents and $40
	set 6,l
	ld a,(hl)
	or a,a
	jq z,._ranthread
	ld (current_thread),a
	call _WakeThread
	ld hl,current_thread
	dec (hl) ; guarantee the next thread processed is this thread's parent thread if it is a parented thread
._ranthread:
	pop bc
	; push de,hl
	; call .normalize_lcd
	; call sys_FreeRunningProcessId ;free memory allocated by the thread
	; pop hl,de
	jq th_HandleNextThread.nosave
