setup.msdreset          setuppkt        $21,$ff,0,0,0
setup.msdmaxlun         setuppkt        $a1,$fe,0,0,1

scsi.inquiry            scsipkt         1,$0005,  $12, $00,$00,$00,$05,$00
scsi.testunitready      scsipkt         0,$0000,  $00, $00,$00,$00,$00,$00
scsi.modesense6         scsipkt         1,$00fc,  $1a, $00,$3f,$00,$fc,$00
scsi.requestsense       scsipkt         1,$0012,  $03, $00,$00,$00,$12,$00
scsi.readcapacity       scsipkt         1,$0008,  $25, $00,$00,$00,$00,$00,$00,$00,$00,$00
scsi.read10             scsipktrw       1,$28
scsi.write10            scsipktrw       0,$2a

tmp tmp_data

fatFile0 fatFile
fatFile1 fatFile
fatFile2 fatFile
fatFile3 fatFile
fatFile4 fatFile

_DefaultControlEndpointDescriptor:
	db 7, ENDPOINT_DESCRIPTOR, 0, 0
	dw 8
	db 0
_GetDeviceDescriptor8:
	db DEVICE_TO_HOST or STANDARD_REQUEST or RECIPIENT_DEVICE, GET_DESCRIPTOR, 0, DEVICE_DESCRIPTOR
	dw 0, 8
_DefaultStandardDescriptors:
	dl .device, .configurations, .langids
	db 2
	dl .strings
.device emit $12: $1201000200000040510408E0200201020003 bswap $12
.configurations dl .configuration1, .configuration2, .configuration3
.configuration1 emit $23: $0902230001010080FA0904000002FF0100000705810240000007050202400000030903 bswap $23
.configuration2 emit $23: $09022300010200C0000904000002FF0100000705810240000007050202400000030903 bswap $23
.configuration3 emit $23: $0902230001030080320904000002FF0100000705810240000007050202400000030903 bswap $23
.langids dw $0304, $0409
.strings dl .string1
.model dl .string84
.string1 dw $033E, 'T','e','x','a','s',' ','I','n','s','t','r','u','m','e','n','t','s',' ','I','n','c','o','r','p','o','r','a','t','e','d'
.string83 dw $0322, 'T','I','-','8','3',' ','P','r','e','m','i','u','m',' ','C','E'
.string84 dw $031C, 'T','I','-','8','4',' ','P','l','u','s',' ','C','E'
