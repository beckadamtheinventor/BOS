
    jr hw_config_start
    db "FEX", 0
hw_config_start:
    breakpoint
    ld hl,-3
    call ti._frameset
    ld a,(ix+6)
    cp a,2
    jr c,.info
    call osrt.argv_1
    ld a,(hl)
    cp a,'-'
    jr nz,.is_set_operation
    inc hl
    ld a,(hl)
    cp a,'g'
    jr z,.is_get_operation
.is_set_operation:
    ld (ix-3),hl
    call osrt.argv_2
    push hl
    call osrt.intstr_to_int
    pop bc
    ld a,l
    ld hl,(ix-3)
    call .set_hardware_config
    jr .return_zero
.is_get_operation:
    call osrt.argv_2
    call .get_hardware_config
	ld hl,bos.return_code_flags
	set bos.bReturnNotError,(hl)
    or a,a
    sbc hl,hl
    ld l,a
    jr .done
.info:
    ld hl,.infostr
    call bos.gui_PrintLine
.return_zero:
    or a,a
    sbc hl,hl
.done:
    ld sp,ix
    pop ix
    ret

; input hl = hardware name
; return a = returned port value
; return cf set if failed
.get_hardware_config:
    call .search
    ret c
    inc hl
    inc hl
.jump:
    mlt bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    dec hl
    add hl,bc
    jp (hl)

; input hl = hardware name
; input a = port value
; overwrites (ix-1)
.set_hardware_config:
    ld (ix-1),a
    call .search
    ret c
    ld a,(ix-1)
    jr .jump

; input hl = search string
.search:
    push hl
    ld hl,.hardwares
.search_loop:
    push hl
    call ti._strcmp
    pop de
    add hl,bc
    xor a,a
    sbc hl,bc
    ex hl,de ; de -> hl
    ld c,a
    mlt bc
    push af
    cpir
    pop af
    pop bc
    ret z
    inc hl
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    or a,a
    scf
    ret z
    push bc
    jr .search_loop

.hardwares:
    db "bl",0
    dw .set_backlight - $
    dw .get_backlight - $
    db "cpu",0
    dw .set_cpu_speed - $
    dw .get_cpu_speed - $
    db 0

.set_backlight:
    ld bc,$B024
    out (bc),a
    ret

.get_backlight:
    ld bc,$B024
    in a,(bc)
    ret

.set_cpu_speed:
    and a,3
    ld c,a
    in0 a,($01)
    and a,$FC
    or a,c
    out0 ($01),a
    ret

.get_cpu_speed:
    in0 a,($01)
    and a,3
    ret

.infostr:
    db "-g",$9,"get a hardware status",$A
    db "Available hardwares",$a
    db "bl [0-255]",$9,"backlight level",$A
    db "cpu [0-3]",$9,"CPU speed. 0:6mhz,1:12mhz,2:24mhz,3:48mhz",$A
    db 0

