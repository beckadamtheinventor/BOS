include "../../src/include/ez80.inc"
include "../../src/include/ti84pceg.inc"
include "../../src/include/bos.inc"
include "../../src/include/ezf.inc"

ezf

public _printsomething, "printsomething"
section _printsomething, ezsec.execany
  pop bc
  ex (sp),hl
  push bc,hl
  call bos.gui_Print
  call ti._strlen
  pop bc
  ret
end section

end ezf
