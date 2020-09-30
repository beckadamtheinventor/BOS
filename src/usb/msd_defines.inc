macro compare_hl_zero?
	add	hl,de
	or	a,a
	sbc	hl,de
end macro

macro compare_auhl_zero?
	compare_hl_zero
	jr	nz,$+3
	or	a,a
end macro

macro compare_hl_de?
	or	a,a
	sbc	hl,de
	add	hl,de
end macro

macro compare_bc_zero?
	push	hl
	sbc	hl,hl
	adc	hl,bc
	pop	hl
end macro

;-------------------------------------------------------------------------------
; memory structures
;-------------------------------------------------------------------------------
macro ?!
 macro assertpo2? value*
  local val
  val = value
  if ~val | val <> 1 shl bsr val
   err '"', `value, '" is not a power of two'
  end if
 end macro

 iterate op, bit, res, set
  macro op#msk? index*, value
   local idx, val, rest
   idx = index
   assertpo2 idx
   match @, value
    val equ value
   else
    val equ
    rest equ index
    while 1
     match car.cdr, rest
      match any, val
       val equ any.car
      else
       val equ car
      end match
      rest equ cdr
     else
      val equ (val)
      break
     end match
    end while
   end match
   match v, val
	op	bsr idx,v
   end match
  end macro
 end iterate

 macro struct? name*, parameters&
  macro end?.struct?!
    end namespace
   end struc
   iterate <base,prefix>, 0,, ix-name,x, iy-name,y
    virtual at base
	prefix#name	name
    end virtual
   end iterate
   purge end?.struct?
  end macro
  struc name parameters
   namespace .
 end macro

 ; copied from ez80.alm
 macro calminstruction?.isindirect? argument*
  unique done
  local isindirect
  match ( isindirect ), argument
  bno done
  match isindirect, isindirect, ()
  label done
 end macro

 calminstruction ld? lhs, mhs*, rhs
  match , rhs
  jyes plain
  isindirect lhs
  jyes store
  isindirect rhs
  jno errarguments
 load:
  execute =ld? mhs, (rhs)
  check mhs metadata 1 eq @ez80.wreg
  jyes loadword
 loadbyte:
  execute =ld? mhs, (rhs + =byte?)
  exit
 loadword:
  execute =ld? mhs, (rhs + =@ez80.=ws)
  exit
 store:
  execute =ld? (lhs), rhs
  check rhs metadata 1 eq @ez80.wreg
  jyes storeword
 storebyte:
  execute =ld? (lhs + =byte?), mhs
  exit
 storeword:
  execute =ld? (lhs + =@ez80.=ws), mhs
  exit
 plain:
  execute =ld? lhs, mhs
  exit
 errarguments:
  err 'invalid arguments'
 end calminstruction

 purge calminstruction?.isindirect?

 purge ?
end macro

; msd structures
struct packetCSW
	label .: 13
	signature rd 1
	tag rd 1
	residue rd 1
	status rb 1
end struct
struct packetCBD
	label .: 17
	len rb 1
	opcode rb 1
	data rb 15
end struct
struct packetCBW
	label .: 14+17
	signature rd 1
	tag rd 1
	len rd 1
	dir rb 1
	lun rb 1
	cbd packetCBD
end struct
struct msdDevice
	local size
	label .: size
	dev rl 1
	bulkinaddr rb 1
	bulkoutaddr rb 1
	configindex rb 1
	tag rl 1
	lba rd 1
	reserved rb 1	; technically part of block size
	blocksize rl 1
	interface rb 1
	maxlun rb 1
	flags rb 1
	lun rb 1
	buffer rl 1
	size := $-.
end struct

MSD_FLAG_IS_INIT := 0
MAX_FAT_FILES := 5
BIT_READ := 0
BIT_WRITE := 1
BIT_OPEN := 7

struct fatFile
	local size
	label .: size
	fat rl 1
	flags rb 1
	entry_sector rd 1
	first_cluster rd 1
	current_cluster rd 1
	file_size rd 1
	file_size_sectors rl 1
	fpossector rl 1
	cluster_sector rb 1
	current_sector rd 1
	working_buffer rl 1
	entry_pointer rl 1
	size := $-.
end struct
struct fatPartition
	local size
	label .: size
	lba rd 1
	msd rl 1
	size := $-.
end struct
struct fatType
	local size
	label .: size
	partition rl 1
	cluster_size rb 1
	clusters rd 1
	fat_size rl 1
	fat_pos rl 1
	fs_info rl 1
	fat_base_lba rd 1
	root_dir_pos rd 1
	data_region rd 1
	working_sector rd 1
	working_cluster rd 1
	working_next_cluster rd 1
	working_prev_cluster rd 1
	working_size rd 1
	working_pointer rl 1
	working_entry rl 1
	working_next_entry rl 1
	working_prev_entry rl 1
	size := $-.
end struct
struct fatDirEntry
	local size
	label .: size
	name rb 13
	attrib rb 1
	entrysize rd 1
	size := $-.
end struct

struct setuppkt, requestType: ?, request: ?, value: ?, index: ?, length: ?
	label .: 8
	bmRequestType db requestType
	bRequest db request
	wValue dw value
	wIndex dw index
	wLength dw length
end struct
struct scsipkt, dir: 0, length: 1, data: 0&
.:	iterate @, data
		dd 'USBC', 0, length
		db (dir) shl 7, 0, %%, data
		break
	end iterate
	rb 31 ; padding needed because some msd drives were built by idiots
end struct
struct scsipktrw, dir: 0, type: 0
.:	iterate @, data
		dd 'USBC', 0, 512
		db (dir) shl 7, 0, 10, type, 0
		break
	end iterate
	lba dd 0
	groupnum db 0
	len dw 1 bswap 2
	ctrl db 0
	rb 31 ; padding needed because some msd drives were built by idiots
end struct

struct descriptor
	label .: 2
	bLength rb 1
	bDescriptorType rb 1
end struct
struct deviceDescriptor
	label .: 18
	descriptor descriptor
	bcdUSB rw 1
	bDeviceClass rb 1
	bDeviceSubClass rb 1
	bDeviceProtocol rb 1
	bMaxPacketSize0 rb 1
	idVendor rw 1
	idProduct rw 1
	bcdDevice rw 1
	iManufacturer rb 1
	iProduct rb 1
	iSerialNumber rb 1
	bNumConfigurations rb 1
end struct
struct interfaceDescriptor
	label .: 9
	descriptor descriptor
	bInterfaceNumber rb 1
	bAlternateSetting rb 1
	bNumEndpoints rb 1
	bInterfaceClass rb 1
	bInterfaceSubClass rb 1
	bInterfaceProtocol rb 1
	iInterface rb 1
end struct
struct endpointDescriptor
	label .: 7
	descriptor descriptor
	bEndpointAddress rb 1
	bmAttributes rb 1
	wMaxPacketSize rw 1
	bInterval rb 1
end struct

; enum usb_transfer_direction
virtual at 0
	?HOST_TO_DEVICE rb 1 shl 7
	?DEVICE_TO_HOST rb 1 shl 7
end virtual

virtual at 0
	FAT_SUCCESS rb 1
	FAT_ERROR_INVALID_PARAM rb 1
	FAT_ERROR_USB_FAILED rb 1
	FAT_ERROR_NOT_SUPPORTED rb 1
	FAT_ERROR_INVALID_CLUSTER rb 1
	FAT_ERROR_EOF rb 1
	FAT_ERROR_EXISTS rb 1
	FAT_ERROR_INVALID_PATH rb 1
	FAT_ERROR_FAILED_ALLOC rb 1
	FAT_ERROR_CLUSTER_CHAIN rb 1
	FAT_ERROR_DIRECTORY_NOT_EMPTY rb 1
	FAT_ERROR_NO_VOLUME_LABEL rb 1
	FAT_ERROR_RDONLY rb 1
	FAT_ERROR_WRONLY rb 1
end virtual

virtual at 0
	MSD_SUCCESS rb 1
	MSD_ERROR_INVALID_PARAM rb 1
	MSD_ERROR_USB_FAILED rb 1
	MSD_ERROR_NOT_SUPPORTED rb 1
	MSD_ERROR_INVALID_DEVICE rb 1
	MSD_ERROR_NOT_INITIALIZED rb 1
end virtual

virtual at 0
	FAT_LIST_FILEONLY rb 1
	FAT_LIST_DIRONLY rb 1
	FAT_LIST_ALL rb 1
end virtual

; enum usb_descriptor_type
virtual at 1
	?DEVICE_DESCRIPTOR rb 1
	?CONFIGURATION_DESCRIPTOR rb 1
	?STRING_DESCRIPTOR rb 1
	?INTERFACE_DESCRIPTOR rb 1
	?ENDPOINT_DESCRIPTOR rb 1
end virtual

; enum usb_transfer_type
virtual at 0
	?CONTROL_TRANSFER rb 1
	?ISOCHRONOUS_TRANSFER rb 1
	?BULK_TRANSFER rb 1
	?INTERRUPT_TRANSFER rb 1
end virtual

struct tmp_data
	local size
	label .: size
	sensecount rb 1
	sensebuffer rb 512	; todo: evaluate if needed
	sectorbuffer rb 576	; todo: evaluate if user-supplied
	length rl 1
	descriptor rb 18
	msdstruct rl 1
	string rb 20
	csw packetCSW
	size := $-.
end struct

DEFAULT_RETRIES := 50

;-------------------------------------------------------------------------------
; memory locations
;-------------------------------------------------------------------------------
virtual at (saveSScreen+$FFFF) and not $FFFF
	cHeap			dbx (saveSScreen+21945) and not $FF - $: ?
end virtual
virtual at usbArea
				rb (-$) and 7
	?setupPacket		setup
				rb (-$) and $1F
	?rootHub		device
				rb (-$) and $FFF
; FIXME: 0xD141B2 is used by GetCSC :(
	?periodicList		dbx $400: ?
	?usbMem			dbx usbInited and not $FF - $: ?
				rb (-$) and $FF
	?dummyHead		endpoint
				rb (-$) and $1F
	?usedAddresses		dbx 128/8: ?
	?eventCallback		rl 1
	?eventCallback.data	rl 1
	?currentDescriptors	rl 1
	?selectedConfiguration	rb 1
	?deviceStatus		rb 1
	?tempEndpointStatus	rw 1
	?currentRole		rb 1
	?freeList32Align32	rl 1
	?freeList64Align256	rl 1
assert $+1 = cleanupListReady
				rb 1 ; clobber
	?cleanupListReady	rb 1
assert cleanupListReady+1 = cleanupListPending
	?cleanupListPending	rb 1
assert cleanupListPending+1 = $
				rb 1 ; always -1
	assert $ <= usbInited
end virtual
virtual at (ramCodeTop+$FF) and not $FF
	osHeap			dbx heapTop and not $FF - $: ?
end virtual
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; usb constants
;-------------------------------------------------------------------------------
; enum usb_error
virtual at 0
	USB_SUCCESS		rb 1
	USB_IGNORE		rb 1
	USB_ERROR_SYSTEM	rb 1
	USB_ERROR_INVALID_PARAM	rb 1
	USB_ERROR_SCHEDULE_FULL	rb 1
	USB_ERROR_NO_DEVICE	rb 1
	USB_ERROR_NO_MEMORY	rb 1
	USB_ERROR_NOT_SUPPORTED	rb 1
	USB_ERROR_TIMEOUT	rb 1
	USB_ERROR_FAILED	rb 1
end virtual

; enum usb_transfer_status
?USB_TRANSFER_COMPLETED		:= 0
?USB_TRANSFER_STALLED		:= 1 shl 0
?USB_TRANSFER_NO_DEVICE		:= 1 shl 1
?USB_TRANSFER_HOST_ERROR		:= 1 shl 2
?USB_TRANSFER_ERROR		:= 1 shl 3
?USB_TRANSFER_OVERFLOW		:= 1 shl 4
?USB_TRANSFER_BUS_ERROR		:= 1 shl 5
?USB_TRANSFER_FAILED		:= 1 shl 6
?USB_TRANSFER_CANCELLED		:= 1 shl 7

; enum usb_event
virtual at 0
	USB_ROLE_CHANGED_EVENT					rb 1
	USB_DEVICE_DISCONNECTED_EVENT				rb 1
	USB_DEVICE_CONNECTED_EVENT				rb 1
	USB_DEVICE_DISABLED_EVENT				rb 1
	USB_DEVICE_ENABLED_EVENT				rb 1
	USB_DEVICE_OVERCURRENT_DEACTIVATED_EVENT		rb 1
	USB_DEVICE_OVERCURRENT_ACTIVATED_EVENT			rb 1
	USB_DEFAULT_SETUP_EVENT					rb 1
	USB_HOST_CONFIGURE_EVENT				rb 1
	; Temp debug events:
	USB_DEVICE_INTERRUPT					rb 1
	USB_DEVICE_CONTROL_INTERRUPT				rb 1
	USB_DEVICE_DEVICE_INTERRUPT				rb 1
	USB_OTG_INTERRUPT					rb 1
	USB_HOST_INTERRUPT					rb 1
	USB_CONTROL_ERROR_INTERRUPT				rb 1
	USB_CONTROL_ABORT_INTERRUPT				rb 1
	USB_FIFO0_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO1_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO2_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO3_SHORT_PACKET_INTERRUPT			rb 1
	USB_DEVICE_SUSPEND_INTERRUPT				rb 1
	USB_DEVICE_RESUME_INTERRUPT				rb 1
	USB_DEVICE_ISOCHRONOUS_ERROR_INTERRUPT			rb 1
	USB_DEVICE_ISOCHRONOUS_ABORT_INTERRUPT			rb 1
	USB_DEVICE_DMA_FINISH_INTERRUPT				rb 1
	USB_DEVICE_DMA_ERROR_INTERRUPT				rb 1
	USB_DEVICE_IDLE_INTERRUPT				rb 1
	USB_DEVICE_WAKEUP_INTERRUPT				rb 1
	USB_B_SRP_COMPLETE_INTERRUPT				rb 1
	USB_A_SRP_DETECT_INTERRUPT				rb 1
	USB_A_VBUS_ERROR_INTERRUPT				rb 1
	USB_B_SESSION_END_INTERRUPT				rb 1
	USB_OVERCURRENT_INTERRUPT				rb 1
	USB_HOST_PORT_CONNECT_STATUS_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_ENABLE_DISABLE_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_OVERCURRENT_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_FORCE_PORT_RESUME_INTERRUPT		rb 1
	USB_HOST_FRAME_LIST_ROLLOVER_INTERRUPT			rb 1
	USB_HOST_SYSTEM_ERROR_INTERRUPT				rb 1
end virtual

; enum usb_find_flag
?IS_NONE		:= 0
?IS_DISABLED		:= 1 shl 0
?IS_ENABLED		:= 1 shl 1
?IS_DEVICE		:= 1 shl 2
?IS_HUB			:= 1 shl 3
?IS_ATTACHED		:= 1 shl 4

; enum usb_endpoint_flag
?MANUAL_TERMINATE	:= 0 shl 0
?AUTO_TERMINATE		:= 1 shl 0

; enum usb_internal_endpoint_flag
?PO2_MPS		:= 1 shl 0

; enum usb_role
virtual at 0
	?ROLE_HOST				rb 1 shl 4
	?ROLE_DEVICE				rb 1 shl 4
end virtual
virtual at 0
	?ROLE_A					rb 1 shl 5
	?ROLE_B					rb 1 shl 5
end virtual

define ydevice iy
;-------------------------------------------------------------------------------
; memory structures
;-------------------------------------------------------------------------------
struct transfer			; transfer structure
	label .: 32
	next		rd 1	; pointer to next transfer structure
 namespace next
	dummy		:= 1 shl 0
 end namespace
	altNext		rd 1	; pointer to alternate next transfer structure
	status		rb 1	; transfer status
 namespace status
	active		:= 1 shl 7
	halted		:= 1 shl 6
	bufErr		:= 1 shl 5
	babble		:= 1 shl 4
	xactErr		:= 1 shl 3
	ufMiss		:= 1 shl 2
	split		:= 1 shl 1
	stall		:= 1 shl 0
 end namespace
	type		rb 1
 namespace type
	ioc		:= 1 shl 7
	cpage		:= 7 shl 4
	cerr		:= 3 shl 2
	pid		:= 3 shl 0
 end namespace
	remaining	rw 1	; transfer remaining length
 namespace remaining
	?dt		:= 1 shl 15
 end namespace
	label buffers: 20	; transfer buffers
			rl 1
	length		rl 1	; original transfer length
	callback	rd 1	; user callback
	data		rd 1	; user callback data
	endpoint	rd 1	; pointer to endpoint structure
	padding		rb 1
	fifo		rb 1	; associated fifo mask
end struct
struct endpoint			; endpoint structure
	label base: 64
	label .: 62 at $+2
	next		rl 1	; link to next endpoint structure
	prev		rb 1	; link to prev endpoint structure
	addr		rb 1	; device addr or cancel shl 7
	info		rb 1	; ep or speed shl 4 or dtc shl 6
 namespace info
	head		:= 1 shl 7
	dtc		:= 1 shl 6
	eps		:= 3 shl 4
	ep		:= $F
 end namespace
	maxPktLen	rw 1	; max packet length or c shl 15 or 1 shl 16
 namespace maxPktLen
	control		:= 1 shl 11
 end namespace
	smask		rb 1	; micro-frame s-mask
	cmask		rb 1	; micro-frame c-mask
	hubInfo		rw 1	; hub addr or port num shl 7 or mult shl 14
	cur		rd 1	; current transfer pointer
	overlay		transfer; current transfer
	type		rb 1	; transfer type
	dir		rb 1	; transfer dir
	flags		rb 1	; endpoint flags
	internalFlags	rb 1	; internal endpoint flags
	first		rl 1	; pointer to first scheduled transfer
	last		rl 1	; pointer to last dummy transfer
	data		rl 1	; user data
	device		rl 1	; pointer to device
end struct
struct device			; device structure
	label .: 32
	endpoints	rl 1	; pointer to array of endpoints
	find		rb 1	; find flags
	refcount	rl 1	; reference count
	hubPorts	rb 1	; number of ports in this hub
	sibling		rl 1	; next device connected to the same hub
	speed		rb 1	; device speed shl 4
	back		rl 1	; update pointer to next pointer to self
			rb 1	; padding
	addr		rb 1	; device addr and $7F
	child		rl 1	; first device connected to this hub
	hub		rl 1	; hub this device is connected to
	info		rw 1	; hub addr or port number shl 7 or 1 shl 14
	data		rl 1	; user data
			rd 1
end struct
struct setup
	label .: 8
	bmRequestType	rb 1
	bRequest	rb 1
	wValue		rw 1
	wIndex		rw 1
	wLength		rw 1
end struct
struct standardDescriptors
	local size
	label .: size
	device		rl 1
	configurations	rl 1
	langids		rl 1
	numStrings	rb 1
	strings		rl 1
	size := $-.
end struct
struct descriptor
	label .: 2
	bLength			rb 1
	bDescriptorType		rb 1
end struct
struct deviceDescriptor
	label .: 18
	descriptor		descriptor
	bcdUSB			rw 1
	bDeviceClass		rb 1
	bDeviceSubClass		rb 1
	bDeviceProtocol		rb 1
	bMaxPacketSize0		rb 1
	idVendor		rw 1
	idProduct		rw 1
	bcdDevice		rw 1
	iManufacturer		rb 1
	iProduct		rb 1
	iSerialNumber		rb 1
	bNumConfigurations	rb 1
end struct
struct deviceQualifierDescriptor
	label .: 10
	descriptor		descriptor
	bcdUSB			rw 1
	bDeviceClass		rb 1
	bDeviceSubClass		rb 1
	bDeviceProtocol		rb 1
	bMaxPacketSize0		rb 1
	bNumConfigurations	rb 1
	bReserved		rb 1
end struct
struct configurationDescriptor
	label .: 9
	descriptor		descriptor
	wTotalLength		rw 1
	bNumInterfaces		rb 1
	bConfigurationValue	rb 1
	iConfiguration		rb 1
	bmAttributes		rb 1
	bMaxPower		rb 1
end struct
otherSpeedConfigurationDescriptor equ configurationDescriptor
struct interfaceDescriptor
	label .: 9
	descriptor		descriptor
	bInterfaceNumber	rb 1
	bAlternateSetting	rb 1
	bNumEndpoints		rb 1
	bInterfaceClass		rb 1
	bInterfaceSubClass	rb 1
	bInterfaceProtocol	rb 1
	iInterface		rb 1
end struct
struct endpointDescriptor
	label .: 7
	descriptor		descriptor
	bEndpointType		rb 1
	bmAttributes		rb 1
	wMaxPacketSize		rw 1
	bInterval		rb 1
end struct

;-------------------------------------------------------------------------------
; usb constants
;-------------------------------------------------------------------------------
; enum usb_error
virtual at 0
	USB_SUCCESS		rb 1
	USB_IGNORE		rb 1
	USB_ERROR_SYSTEM	rb 1
	USB_ERROR_INVALID_PARAM	rb 1
	USB_ERROR_SCHEDULE_FULL	rb 1
	USB_ERROR_NO_DEVICE	rb 1
	USB_ERROR_NO_MEMORY	rb 1
	USB_ERROR_NOT_SUPPORTED	rb 1
	USB_ERROR_TIMEOUT	rb 1
	USB_ERROR_FAILED	rb 1
end virtual

; enum usb_transfer_status
?USB_TRANSFER_COMPLETED		:= 0
?USB_TRANSFER_STALLED		:= 1 shl 0
?USB_TRANSFER_NO_DEVICE		:= 1 shl 1
?USB_TRANSFER_HOST_ERROR		:= 1 shl 2
?USB_TRANSFER_ERROR		:= 1 shl 3
?USB_TRANSFER_OVERFLOW		:= 1 shl 4
?USB_TRANSFER_BUS_ERROR		:= 1 shl 5
?USB_TRANSFER_FAILED		:= 1 shl 6
?USB_TRANSFER_CANCELLED		:= 1 shl 7

; enum usb_event
virtual at 0
	USB_ROLE_CHANGED_EVENT					rb 1
	USB_DEVICE_DISCONNECTED_EVENT				rb 1
	USB_DEVICE_CONNECTED_EVENT				rb 1
	USB_DEVICE_DISABLED_EVENT				rb 1
	USB_DEVICE_ENABLED_EVENT				rb 1
	USB_DEVICE_OVERCURRENT_DEACTIVATED_EVENT		rb 1
	USB_DEVICE_OVERCURRENT_ACTIVATED_EVENT			rb 1
	USB_DEFAULT_SETUP_EVENT					rb 1
	USB_HOST_CONFIGURE_EVENT				rb 1
	; Temp debug events:
	USB_DEVICE_INTERRUPT					rb 1
	USB_DEVICE_CONTROL_INTERRUPT				rb 1
	USB_DEVICE_DEVICE_INTERRUPT				rb 1
	USB_OTG_INTERRUPT					rb 1
	USB_HOST_INTERRUPT					rb 1
	USB_CONTROL_ERROR_INTERRUPT				rb 1
	USB_CONTROL_ABORT_INTERRUPT				rb 1
	USB_FIFO0_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO1_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO2_SHORT_PACKET_INTERRUPT			rb 1
	USB_FIFO3_SHORT_PACKET_INTERRUPT			rb 1
	USB_DEVICE_SUSPEND_INTERRUPT				rb 1
	USB_DEVICE_RESUME_INTERRUPT				rb 1
	USB_DEVICE_ISOCHRONOUS_ERROR_INTERRUPT			rb 1
	USB_DEVICE_ISOCHRONOUS_ABORT_INTERRUPT			rb 1
	USB_DEVICE_DMA_FINISH_INTERRUPT				rb 1
	USB_DEVICE_DMA_ERROR_INTERRUPT				rb 1
	USB_DEVICE_IDLE_INTERRUPT				rb 1
	USB_DEVICE_WAKEUP_INTERRUPT				rb 1
	USB_B_SRP_COMPLETE_INTERRUPT				rb 1
	USB_A_SRP_DETECT_INTERRUPT				rb 1
	USB_A_VBUS_ERROR_INTERRUPT				rb 1
	USB_B_SESSION_END_INTERRUPT				rb 1
	USB_OVERCURRENT_INTERRUPT				rb 1
	USB_HOST_PORT_CONNECT_STATUS_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_ENABLE_DISABLE_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_OVERCURRENT_CHANGE_INTERRUPT		rb 1
	USB_HOST_PORT_FORCE_PORT_RESUME_INTERRUPT		rb 1
	USB_HOST_FRAME_LIST_ROLLOVER_INTERRUPT			rb 1
	USB_HOST_SYSTEM_ERROR_INTERRUPT				rb 1
end virtual

; enum usb_find_flag
?IS_NONE		:= 0
?IS_DISABLED		:= 1 shl 0
?IS_ENABLED		:= 1 shl 1
?IS_DEVICE		:= 1 shl 2
?IS_HUB			:= 1 shl 3
?IS_ATTACHED		:= 1 shl 4

; enum usb_endpoint_flag
?MANUAL_TERMINATE	:= 0 shl 0
?AUTO_TERMINATE		:= 1 shl 0

; enum usb_internal_endpoint_flag
?PO2_MPS		:= 1 shl 0

; enum usb_role
virtual at 0
	?ROLE_HOST				rb 1 shl 4
	?ROLE_DEVICE				rb 1 shl 4
end virtual
virtual at 0
	?ROLE_A					rb 1 shl 5
	?ROLE_B					rb 1 shl 5
end virtual

; enum usb_transfer_direction
virtual at 0
	?HOST_TO_DEVICE				rb 1 shl 7
	?DEVICE_TO_HOST				rb 1 shl 7
end virtual

; enum usb_request_type
virtual at 0
	?STANDARD_REQUEST			rb 1 shl 5
	?CLASS_REQUEST				rb 1 shl 5
	?VENDOR_REQUEST				rb 1 shl 5
end virtual

; enum usb_recipient
virtual at 0
	?RECIPIENT_DEVICE			rb 1 shl 0
	?RECIPIENT_INTERFACE			rb 1 shl 0
	?RECIPIENT_ENDPOINT			rb 1 shl 0
	?RECIPIENT_OTHER			rb 1 shl 0
end virtual

; enum usb_request
virtual at 0
	?GET_STATUS				rb 1
	?CLEAR_FEATURE				rb 1
						rb 1
	?SET_FEATURE				rb 1
						rb 1
	?SET_ADDRESS				rb 1
	?GET_DESCRIPTOR				rb 1
	?SET_DESCRIPTOR				rb 1
	?GET_CONFIGURATION			rb 1
	?SET_CONFIGURATION			rb 1
	?GET_INTERFACE				rb 1
	?SET_INTERFACE				rb 1
	?SYNC_FRAME				rb 1
end virtual

; enum usb_feature
virtual at 0
	?ENDPOINT_HALT				rb 1
	?DEVICE_REMOTE_WAKEUP			rb 1
	?TEST_MODE				rb 1
end virtual

; enum usb_descriptor_type
virtual at 1
	?DEVICE_DESCRIPTOR			rb 1
	?CONFIGURATION_DESCRIPTOR		rb 1
	?STRING_DESCRIPTOR			rb 1
	?INTERFACE_DESCRIPTOR			rb 1
	?ENDPOINT_DESCRIPTOR			rb 1
end virtual

; enum usb_transfer_type
virtual at 0
	?CONTROL_TRANSFER			rb 1
	?ISOCHRONOUS_TRANSFER			rb 1
	?BULK_TRANSFER				rb 1
	?INTERRUPT_TRANSFER			rb 1
end virtual