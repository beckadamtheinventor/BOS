include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib
export_ptr bos.util_Zx7Decompress, "D7", "Zx7Decompress"
export_ptr bos.util_Zx0Decompress, "D0", "Zx0Decompress"
export_ptr bos.util_Zx7Compress, "C7", "Zx7Compress"
end syscalllib