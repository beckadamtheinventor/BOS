;@DOES Erase flash sector
;@INPUT A sector to erase
;@DESTROYS All
;@NOTE calls boot routine $2DC
sys_EraseFlashSector:
	ld bc,$F8
	push bc
	jp $2DC
