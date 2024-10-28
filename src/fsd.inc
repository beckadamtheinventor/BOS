; BOS stateful filesystem routines

; fsd open file structure (internal use)
fsd_OpenFlags        :=  -1
fsd_FileDesc         :=  0
fsd_DataPtr          :=  3
fsd_DataLen          :=  6
fsd_DataOffset       :=  9
fsd_StructureLen     := 13

; fsd open file descriptor flags (internal use)
fsd_bWrite           := 1
fsd_bRead            := 2
fsd_bOverwrite       := 3
fsd_bIsDevice        := 6
fsd_bNeedsFlush      := 7
fsd_mWrite           := 1 shl fsd_bWrite
fsd_mRead            := 1 shl fsd_bRead
fsd_mOverwrite       := 1 shl fsd_bOverwrite
fsd_mIsDevice        := 1 shl fsd_bIsDevice
fsd_mNeedsFlush      := 1 shl fsd_bNeedsFlush


include 'fsd/AppendOpenFileTable.asm'
include 'fsd/CheckOpen.asm'
include 'fsd/CheckOpenFD.asm'
include 'fsd/Open.asm'
include 'fsd/Close.asm'
include 'fsd/CloseAll.asm'
include 'fsd/ForceClose.asm'
include 'fsd/Read.asm'
include 'fsd/Write.asm'
include 'fsd/WriteStr.asm'
include 'fsd/Resize.asm'
include 'fsd/Tell.asm'
include 'fsd/Seek.asm'
include 'fsd/GetSize.asm'
include 'fsd/GetDataPtr.asm'
include 'fsd/InRam.asm'
include 'fsd/IsOpen.asm'
include 'fsd/Archive.asm'
include 'fsd/UnArchive.asm'
