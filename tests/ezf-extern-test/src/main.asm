include "../../src/include/ez80.inc"
include "../../src/include/ti84pceg.inc"
include "../../src/include/bos.inc"
include "../../src/include/ezf.inc"

ezf

extern _printsomething, "printsomething"

entrypoint _main
section _main, ezsec.execany
	ld hl,_str_HelloWorld
	push hl
	call _printsomething
	pop bc
	or a,a
	sbc hl,hl
	ret
end section

public _str_HelloWorld
section _str_HelloWorld, ezsec.rodat
	db "Hello World!",0
end section

end ezf
