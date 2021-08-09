#include <stdarg.h>
#include <usbdrvce.h>
#include <srldrvce.h>
#include "network.h"

srl_device_t srl;
uint8_t srl_buf[1024];
uint8_t net_buf[513];
extern bool network_up;
file_header_t incoming_file;
file_header_t outgoing_file;
uint8_t *incoming_data = 0;
bool network_up = false;

void ntwk_process(void) {
	usb_process();

	/* Only read if the device is connected */
	if(network_up) {
		size_t len;
		if (usb_read_to_size(3)){
			len = *(unsigned int *)&net_buf;
			len = usb_read_to_size(len);
			if (len > 0){
				conn_HandleInput(&net_buf, len);
			}
		}
	}
}

bool ntwk_send(uint8_t ctrl, uint8_t *data, size_t len) {
	uint8_t i;
	unsigned int total_len;

	if(!network_up) return false;

	total_len = len + (sizeof(len)) + (sizeof(ctrl));
	usb_write(&total_len, (sizeof(total_len)));
	usb_write(&ctrl, (sizeof(ctrl)));
	usb_write(data, len);
	return true;
}

void conn_HandleInput(packet_t *in_buff, size_t buff_size) {
	uint8_t *data = &in_buff->data;
	size_t data_size = buff_size-1;
	char *file_name;
	unsigned int len;
	if (!incoming_data){
		incoming_data = sys_Malloc(incoming_data_buffer_len);
	}
	switch (in_buff->control) {
		case 0: // incoming message
			gui_PrintLine(data);
			break;
		case 1: // incoming file header
			sys_Free(incoming_file.name);
			file_name = data;
			incoming_file.len = *(unsigned int *)&data[(len = strlen(file_name) + 1)];
			incoming_file.current_len = 0;
			if (!(incoming_file.name = sys_Malloc(len))){
				malloc_error();
			} else {
				memcpy(incoming_file.name, file_name, len);
				if (!(incoming_file.fd = fs_OpenFile(incoming_file.name))){
					fs_CreateFile(incoming_file.name, 0, incoming_file.len);
				}
			}
			break;
		case 2: // incoming file data section
			len = incoming_file.current_len + incoming_data_buffer_len > incoming_file.len ? incoming_file.len - incoming_file.current_len : incoming_data_buffer_len;
			fs_Write(data, incoming_data_buffer_len, 1, incoming_file.fd, len);
			incoming_file.current_len += len;
		case 3: // request file header
			sys_Free(outgoing_file.name);
			file_name = data;
			outgoing_file.len = *(unsigned int *)&data[(len = strlen(file_name) + 1)];
			outgoing_file.current_len = 0;
			if (!(outgoing_file.name = sys_Malloc(len))){
				malloc_error();
			} else {
				uint8_t *tmp;
				memcpy(outgoing_file.name, file_name, len);
				if (!(outgoing_file.fd = fs_OpenFile(outgoing_file.name))){
					gui_PrintLine("Error: Requested outgoing file not found. Aborting transfer.");
					ntwk_send(0, PS_STR("Error: File not found."));
				}
				outgoing_file.ptr = fs_GetFDPtr(outgoing_file.fd);
				outgoing_file.len = fs_GetFDLen(outgoing_file.fd);
				if (!(tmp = sys_Malloc((len = strlen(outgoing_file.name)+4)))){
					malloc_error();
					break;
				}
				ntwk_send(1, PS_PTR(tmp, len));
				do {
					memcpy(incoming_data, outgoing_file.ptr, incoming_data_buffer_len);
					outgoing_file.ptr += incoming_data_buffer_len;
					ntwk_send(2, PS_PTR(incoming_data, incoming_data_buffer_len));
					len = outgoing_file.current_len + incoming_data_buffer_len > outgoing_file.len ? outgoing_file.len - outgoing_file.current_len : incoming_data_buffer_len;
					outgoing_file.current_len += len;
				} while (outgoing_file.current_len < outgoing_file.len);
			}
			break;
		default:
			gui_PrintLine("Unknown/invalid packet recieved.");
			ntwk_send(0, PS_STR("Unknown/invalid packet recieved."));
			break;
	}
}

void malloc_error(void) {
	const char *str = "Error: Out of malloc memory. Aborting transfer.";
	gui_PrintLine(str);
	ntwk_send(0, PS_STR(str));
}

bool init_usb(void) {
	usb_error_t usb_error;
	network_up = false;
	usb_error = usb_Init(handle_usb_event, NULL, srl_GetCDCStandardDescriptors(), USB_DEFAULT_INIT_FLAGS);
	return !usb_error;
}

/* Handle USB events */
static usb_error_t handle_usb_event(usb_event_t event, void *event_data,
									usb_callback_data_t *callback_data) {
	srl_error_t srl_error;
	/* When a device is connected, or when connected to a computer */
	if ((event == USB_DEVICE_CONNECTED_EVENT && !(usb_GetRole() & USB_ROLE_DEVICE)) || event == USB_HOST_CONFIGURE_EVENT) {
		usb_device_t device = event_data;
		if (!(srl_error = srl_Init(&srl, device, srl_buf, (sizeof(srl_buf)), SRL_INTERFACE_ANY))) {
			srl_SetRate(&srl, 115200);
			network_up = true;
		}
	}

	/* When a device is disconnected */
	if(event == USB_DEVICE_DISCONNECTED_EVENT) {
		network_up = false;
	}

	return USB_SUCCESS;
}

bool usb_read_to_size(size_t size) {
	static bytes_read = 0;
	bytes_read += srl_Read(&srl, &net_buf[bytes_read], size - bytes_read);
	if(bytes_read >= size) {bytes_read = 0; return true;}
	else return false;
}

void usb_write(void *buf, size_t size) {
	srl_Write(&srl, buf, size);
}
