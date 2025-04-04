
; BOS filesystem functions

include 'fs/IsOSBackupPresent.asm'
include 'fs/AllocSmall.asm'
include 'fs/AllocRam.asm'
include 'fs/ChkFreeRam.asm'
include 'fs/AllocVar.asm'
include 'fs/ArcUnarcFD.asm'
include 'fs/PathLen.asm'
include 'fs/JoinPath.asm'
include 'fs/AbsPath.asm'
include 'fs/Alloc.asm'
include 'fs/AllocChk.asm'
include 'fs/AllocDescriptor.asm'
include 'fs/BaseName.asm'
include 'fs/CeilDivBySector.asm'
include 'fs/CheckDirExists.asm'
include 'fs/CopyFileName.asm'
include 'fs/CopyFile.asm'
include 'fs/CreateRamFile.asm'
include 'fs/CreateDir.asm'
include 'fs/CreateLongFileName.asm'
include 'fs/CreateFile.asm'
include 'fs/CreateFileEntry.asm'
include 'fs/DeleteFileFD.asm'
include 'fs/DeleteFile.asm'
include 'fs/DirList.asm'
include 'fs/ExtractOSBinaries.asm'
include 'fs/ExtractOSOptBinaries.asm'
include 'fs/ExtractRootDir.asm'
include 'fs/Format.asm'
include 'fs/Free.asm'
include 'fs/GarbageCollect.asm'
include 'fs/GetDirSizeFD.asm'
include 'fs/GetDirSize.asm'
include 'fs/GetFilePtr.asm'
include 'fs/GetFilePtrRaw.asm'
include 'fs/GetFDLen.asm'
include 'fs/GetFDLenRaw.asm'
include 'fs/GetFDPtr.asm'
include 'fs/GetFDPtrRaw.asm'
include 'fs/GetSectorAddress.asm'
include 'fs/GetFreeSpace.asm'
include 'fs/GetSector.asm'
; include 'fs/HashFile.asm'
include 'fs/InitClusterMap.asm'
include 'fs/MoveFile.asm'
include 'fs/MultByBytesPerSector.asm'
include 'fs/OpenFile.asm'
include 'fs/OpenFileInDir.asm'
include 'fs/ParentDir.asm'
include 'fs/Read.asm'
include 'fs/Rename.asm'
include 'fs/RenameFile.asm'
include 'fs/SanityCheck.asm'
include 'fs/SetSize.asm'
include 'fs/StrToFileEntry.asm'
include 'fs/Write.asm'
include 'fs/WriteDirectly.asm'
include 'fs/WriteByte.asm'
include 'fs/WriteFile.asm'
include 'fs/WriteNewFile.asm'
include 'fs/GetFDAttr.asm'
include 'fs/DirCleanup.asm'
