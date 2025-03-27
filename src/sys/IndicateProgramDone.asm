;@DOES Shows a done message and waits for the user to press a key.
sys_IndicateProgramDone:
    call gfx_Ensure8bpp
    call sys_WaitKeyUnpress
    ld hl,str_ProgramDoneIndicatorMessage
    call gui_PrintLine
    jq sys_WaitKeyCycle

