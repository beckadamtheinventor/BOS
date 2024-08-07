include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib "fs"
export_ptr bos.fs_OpenFile, "OpenFile"
export_ptr bos.fs_GetSectorAddress, "GetSectorAddress"
export_ptr bos.fs_CheckDirExists, "CheckDirExists"
export_ptr bos.fs_CeilDivBySector, "CeilDivBySector"
export_ptr bos.fs_CopyFileName, "CopyFileName"
export_ptr bos.fs_Read, "Read"
export_ptr bos.fs_Write, "Write"
export_ptr bos.fs_CreateRamFile, "CreateRamFile"
export_ptr bos.fs_AllocRam, "AllocRam"
export_ptr bos.fs_CreateFile, "CreateFile"
export_ptr bos.fs_AbsPath, "AbsPath"
export_ptr bos.fs_MultByBytesPerSector, "MultByBytesPerSector"
export_ptr bos.fs_OpenFileInDir, "OpenFileInDir"
export_ptr bos.fs_SetSize, "SetSize"
export_ptr bos.fs_WriteFile, "WriteFile"
export_ptr bos.fs_DeleteFile, "DeleteFile"
export_ptr bos.fs_InitClusterMap, "InitClusterMap"
export_ptr bos.fs_PathLen, "PathLen"
export_ptr bos.fs_ParentDir, "ParentDir"
export_ptr bos.fs_StrToFileEntry, "StrToFileEntry"
export_ptr bos.fs_DirList, "DirList"
export_ptr bos.fs_CopyFile, "CopyFile"
export_ptr bos.fs_GetSector, "GetSector"
export_ptr bos.fs_WriteByte, "WriteByte"
export_ptr bos.fs_RenameFile, "RenameFile"
export_ptr bos.fs_CreateDir, "CreateDir"
export_ptr bos.fs_SanityCheck, "SanityCheck"
export_ptr bos.fs_GetFilePtrRaw, "GetFilePtrRaw"
export_ptr bos.fs_GarbageCollect, "GarbageCollect"
export_ptr bos.fs_WriteNewFile, "WriteNewFile"
export_ptr bos.fs_GetFreeSpace, "GetFreeSpace"
export_ptr bos.fs_GetFDPtrRaw, "GetFDPtrRaw"
export_ptr bos.fs_GetFDLenRaw, "GetFDLenRaw"
export_ptr bos.fs_JoinPath, "JoinPath"
export_ptr bos.fs_BaseName, "BaseName"
export_ptr bos.fs_MoveFile, "MoveFile"
export_ptr bos.fs_WriteDirectly, "WriteDirectly"
export_ptr bos.fs_GetFilePtr, "GetFilePtr"
export_ptr bos.fs_GetFDPtr, "GetFDPtr"
export_ptr bos.fs_GetFDLen, "GetFDLen"
export_ptr bos.fs_ArcUnarcFD, "ArcUnarcFD"
export_ptr bos.fs_Rename, "Rename"
export_ptr bos.fs_AllocChk, "AllocChk"
end syscalllib