;@DOES Shows a done message and waits for the user to press a key.
sys_IndicateProgramDone:
    ld hl,str_ProgramDoneIndicatorMessage
    call gui_PrintLine
    jq sys_WaitKeyCycle

