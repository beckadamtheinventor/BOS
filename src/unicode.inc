
; BOS Unicode routines
; to be decided

if defined BOS_UNICODE_SUPPORT

include 'unicode/GetCharacterBitmap.asm'
include 'unicode/PrintChar.asm'
include 'unicode/SetFont.asm'

include 'unicode/utf-8/CodepointToUTF8.asm'
include 'unicode/utf-8/UTF8ToCodepoint.asm'
include 'unicode/utf-8/PrintUTF8String.asm'

else

unicode_GetCharacterBitmap    := DONOTHING
unicode_PrintChar             := DONOTHING
unicode_SetFont               := DONOTHING

unicode_CodepointToUTF8       := DONOTHING
unicode_UTF8ToCodepoint       := DONOTHING
unicode_PrintUTF8String       := DONOTHING

end if
