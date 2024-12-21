include 'commands.alm'
include 'ez80.alm'

macro breakpoint?
	scf
	sbc hl,hl
	ld (hl),2
end macro
