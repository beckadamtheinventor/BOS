
    jr hw_config_start
    db "FEX", 0
hw_config_start:
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
    ld a,1
    jr c,.return_a
    jr .return_zero
.is_get_operation:
    call osrt.argv_2
    call .get_hardware_config
.return_result:
	ld hl,bos.return_code_flags
	set bos.bReturnNotError,(hl)
.return_a:
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
    jr c,.info
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
    jr c,.info
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

; set routines input 8-bit value in A
; get routines return 8-bit value in A
.hardwares:
    db "bl",0
    dw .set_backlight - $
    dw .get_backlight - $
    db "cpu",0
    dw .set_cpu_speed - $
    dw .get_cpu_speed - $
    db "wst",0
    dw .set_wait_states - $
    dw .get_wait_states - $
    db 0

.set_backlight:
    cp a,128
    ret c
    ld bc,$B024
    out (bc),a

.get_backlight:
    ld bc,$B024
    in a,(bc)
    or a,a
    ret

.set_cpu_speed:
    and a,3
    ld c,a
    in0 a,($01)
    and a,$FC
    or a,c
    out0 ($01),a

.get_cpu_speed:
    in0 a,($01)
    and a,3
    ret

.set_wait_states:
    cp a,1
    ret c
    cp a,16
    ccf
    ret c
    ld ($E00005),a

.get_wait_states:
    ld a,($E00005)
    or a,a
    ret

.infostr:
    db "hw name value  (set)",$A
    db "hw -g name     (get)",$A
    db "Available:",$a
    db "bl [128-255] backlight",$A
    db "cpu [0-3]  CPU speed. 0:6mhz,1:12,2:24,3:48",$A
    db "wst [1-15]  wait states",$A
    db $A
    db "Ex. hw -g bl",$A
    db "return 0 if success",$A
    db 0

