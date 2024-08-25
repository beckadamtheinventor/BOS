include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib "os"
export_ptr bos.os_GetOSInfo, "GetOSInfo"
end syscalllib