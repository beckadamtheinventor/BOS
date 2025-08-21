;@DOES Return a handle to a file within a device file.
;@INPUT void *drv_OpenFile(device_t* ptr, const char* path);
;@INPUT ptr Pointer to device file data.
;@INPUT path File path.
;@OUTPUT handle, 0 if not applicable to the device or file not found.
drv_OpenFile:
    call ti._frameset0
    ld hl,(ix+6)
.entryhlde:
    call drv.common_check_is_filesystem_device
    jr z,drv.common_stack_exit
	ld bc,device_JumpOpenFile
drv.common_1_arg:
	add hl,bc
	ld a,(hl)
	cp a,$C3
	jr nz,drv.common_stack_exit
    jr drv.common_push_de_call_hl

; returns Zf set if *not* a filesystem device
drv.common_check_is_filesystem_device:
    push hl
    assert device_Type = 2
    inc hl
    inc hl
    ld a,(hl)
    and a,devtFS
    pop hl
    ret
