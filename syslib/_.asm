include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib "_"
export_ptr bos._MemClear, "MemClear"
export_ptr bos._PushOP1, "PushOP1"
export_ptr bos._PopOP1, "PopOP1"
export_ptr bos._Mov9ToOP1, "Mov9ToOP1"
export_ptr bos._CpHLDE, "CpHLDE"
export_ptr bos._Mov8b, "Mov8b"
export_ptr bos._ChkFindSym, "ChkFindSym"
export_ptr bos._LoadDEInd_s, "LoadDEInd_s"
export_ptr bos._EnoughMem, "EnoughMem"
export_ptr bos._InsertMem, "InsertMem"
export_ptr bos._SetHLUTo0, "SetHLUTo0"
export_ptr bos._PutS, "PutS"
export_ptr bos._GetCSC, "GetCSC"
export_ptr bos._NewLine, "NewLine"
export_ptr bos._ClrScrn, "ClrScrn"
export_ptr bos._HomeUp, "HomeUp"
export_ptr bos._ErrMemory, "ErrMemory"
export_ptr bos._DrawStatusBar, "DrawStatusBar"
export_ptr bos._UsbPowerVbus, "UsbPowerVbus"
export_ptr bos._UsbUnpowerVbus, "UsbUnpowerVbus"
export_ptr bos._LoadLibraryOP1, "LoadLibraryOP1"
export_ptr bos._DelVar, "DelVar"
export_ptr bos._CreateVar, "CreateVar"
export_ptr bos._SetCursorPos, "SetCursorPos"
export_ptr bos._OP1ToPath, "OP1ToPath"
export_ptr bos._UnpackUpdates, "UnpackUpdates"
export_ptr bos._SearchSymTable, "SearchSymTable"
end syscalllib