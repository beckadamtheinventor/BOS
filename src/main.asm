
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
include 'include/defines.inc'

org $020108

include 'table.asm'
include 'boot.asm'
include 'threading.inc'
include 'gfx.inc'
include 'str.inc'
include 'sys.inc'
include 'util.inc'
include 'fs.inc'
include 'gui.inc'
include 'data.inc'
include 'compatibility.inc'

DONOTHING:
	ret

macro exaf
	db $08 ;why does the comma in ex af,af' have to screw with things? >_>
end macro
