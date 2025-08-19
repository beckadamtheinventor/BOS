include "../include/ez80.inc"
include "../include/ti84pceg.inc"
include "../include/bos.inc"

; TODO
; 4bpp graphics routines

syscalllib "gfx4"
    export gfx4_Init, "init", "_gfx4_Init", "void gfx4_Init();"
    export gfx4_InitPalette, "init_pal", "_gfx4_InitPalette", "void gfx4_InitPalette(); // init grayscale palette"
    export gfx4_SetPalette, "set_pal", "_gfx4_SetPalette", "void gfx4_SetPalette(uint16_t* pal); // 16x rgb565 words"
    export gfx4_ClearScreen, "clear", "_gfx4_ClearScreen", "void gfx4_ClearScreen();"
    export gfx4_FillScreen, "fill", "_gfx4_FillScreen", "void gfx4_FillScreen();"

gfx4_Init:
    call bos.gfx_ZeroVRAM
	ld	a,ti.lcdBpp4 ; operate in 4bpp
	ld	(ti.mpLcdCtrl), a
gfx4_InitPalette:
    ld hl,gfx4_palette_grayscale
    db $01 ; dummify pop bc / ex (sp), hl / push bc
gfx4_SetPalette:
    pop bc
    ex (sp),hl
    push bc
    ld de,ti.mpLcdPalette
    ret
gfx4_ClearScreen:
    xor a,a
    jr gfx4_fill_current_buffer
gfx4_FillScreen:
    pop bc
    ex (sp),hl
    push bc
    ld a,l
gfx4_fill_current_buffer:
    ld hl,(bos.cur_lcd_buffer)
gfx4_fill_buffer_hl:
    push hl
    pop de
    inc de
gfx4_copy_buffer_hl_de:
    ld bc,320*240/2-1
    ldir
    ret

gfx4_TextXY:
    ld iy,0
    add iy,sp
    ld hl,(iy+9)
    ld e,(iy+12)
    call gfx4_compute

; input HL = x, E = y
gfx4_compute:
    or a,a
    sra h
    rr l
    ld d,120
    mlt de
    add hl,de
    ld de,(bos.cur_lcd_buffer)
    add hl,de
    ret

gfx4_palette_grayscale:
    dw $1082, $2104, $3186, $4208, $528a, $630c, $738e, $8410, $9492, $a514, $b596, $c618, $d69a, $e71c, $f79e, $ffff

end syscalllib