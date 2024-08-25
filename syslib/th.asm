include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib "th"
export_ptr bos.th_WaitKeyCycle, "WaitKeyCycle"
export_ptr bos.th_CreateThread, "CreateThread"
export_ptr bos.th_KillThread, "KillThread"
end syscalllib