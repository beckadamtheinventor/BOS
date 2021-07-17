#ifndef __NETWORK_H__
#define __NETWORK_H__

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include <string.h>

typedef struct {
	uint8_t control;
	uint8_t data[];
} packet_t;

enum net_mode_id {
	MODE_SERIAL,
	MODE_CEMU_PIPE
};

typedef struct {
	char *name;
	uint8_t *ptr;
	size_t len;
	void *fd;
	size_t current_len;
} file_header_t;

#define incoming_data_buffer_len 512
#define usb_process usb_HandleEvents

#define PS_STR(str) (str), 1+strlen(str)
#define PS_VAL(val) (&val), sizeof(val)
#define PS_ARR(arr) (arr), sizeof(arr)
#define PS_PTR(ptr, size) (ptr), (size)

// Inbound
void conn_HandleInput(packet_t *in_buff, size_t buff_size);

void malloc_error(void);

bool ntwk_init(void);
void ntwk_process(void);
bool ntwk_send(uint8_t ctrl, uint8_t *data, size_t len);
bool init_usb(void);

static usb_error_t handle_usb_event(usb_event_t event, void *event_data,
									usb_callback_data_t *callback_data);


void usb_write(void *buf, size_t size);
unsigned int usb_read_to_size(size_t size, unsigned int offset);

#endif
