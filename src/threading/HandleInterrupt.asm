
;end the current thread, jumping to the next one
th_EndThread:
assert ~thread_map and $FF
	ld a,(current_thread)
	ld hl,thread_map
	ld l,a
	res bThreadAlive,(hl) ;end the current thread
	jq th_HandleNextThread.nosave

; th_HandleInterrupt:
	; exx
	; exaf
th_HandleNextThread:
	; ld a,(threading_enabled)
	; or a,a
	; ret z
	; ld a,(thread_control)
	; or a,a
	; ret z
	ld a,(current_thread)
	or a,a
	sbc hl,hl
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,thread_temp_save
	add hl,bc
	push ix
	ex (sp),hl
	pop ix
	ld (ix+6),hl ;save ix
	ld (ix+9),iy ;save iy
	pop hl
	ld (ix),hl ; save pc
	or a,a
	sbc hl,hl
	add hl,sp
	ld (ix+3),hl ; save sp
	ld a,(running_process_id)
	ld (ix+15),a

.nosave:
	call th_FindNextThread
	ld (current_thread),a
	sbc hl,hl
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,thread_temp_save
	add hl,bc

.load_from_hl:
	push hl
	pop ix
	ld hl,(ix+3) ;restore sp
	ld sp,hl
	ld hl,(ix) ;location to jump to
	; ld bc,$5004
	; in a,(bc)
	; or a,1 shl 2
	; out (bc),a
	ld a,(ix+15) ;restore running_process_id
	ld (running_process_id),a
	ld iy,(ix+9) ;restore ix
	ld ix,(ix+6) ;restore iy
	jp (hl)
	; ei
	; reti

th_FindFreeThread:
	ld hl,thread_map
	set bThreadAlive,(hl) ;thread 0 is always active
	xor a,a
	ld b,a
.search_loop:
	bit bThreadAlive,(hl)
	jr z,.found_thread
	inc l
	djnz .search_loop
	ld l,b
.found_thread:
	or a,l
	ret

th_FindNextThread:
	ld a,(current_thread)
assert ~thread_map and $FF
assert ~thread_parents and $FF
	ld hl,thread_map
	set bThreadAlive,(hl) ;thread 0 is always alive
	ld b,l
	ld l,a
; if (thread_map shr 8) + 1 <> (thread_parents shr 8)
	; ld d,h
; end if
.search_loop:
	inc l
	bit bThreadSleeping,(hl) ;check if thread is sleeping
	jr nz,.search_next
; assert thread_parents shr 16 = thread_map shr 16
; if (thread_map shr 8) + 1 = (thread_parents shr 8)
	; inc h
; else
	; ld h,$FF and (thread_parents shr 8)
; end if
	; ld a,l
	; ld l,(hl) ;get parent thread ID
; if (thread_map shr 8) + 1 = (thread_parents shr 8)
	; dec h
; else
	; ld h,d
; end if
	; bit bThreadSleeping,(hl) ;check if parent thread is sleeping
	; jq nz,.search_next
	bit bThreadAlive,(hl)
	jr nz,.found_thread
.search_next:
	; ld l,a
	djnz .search_loop
; we will only get here after 256 search iterations, which will end up being the same thread ID as the running thread.
	bit bThreadAlive,(hl) ;check if currently running thread is actually running, if it isn't then run thread ID 0
	ld a,l
	ret nz ; continue the currently running thread I suppose
	xor a,a ; run thread ID 0
	ret
.found_thread:
	ld a,l
	ret

th_ResetThreadMemory:
	ld hl,thread_map
	xor a,a
	ld b,a
.loop:
	ld (hl),a
	inc l
	djnz .loop
if ~(thread_map shr 8) + 1 = (thread_parents shr 8)
	ld h,$FF and (thread_parents shr 8)
end if
.loop2:
	ld (hl),a
	inc l
	djnz .loop2
	ld (current_thread),a
	ret

