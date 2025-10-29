;@DOES Sets the font to use for printing Unicode characters.
;@INPUT void unicode_SetFont(void* ptr);
unicode_SetFont:
    pop de
    ex (sp),hl
    ld (unicode_font_ptr),hl
    ex hl,de
    jp (hl)
