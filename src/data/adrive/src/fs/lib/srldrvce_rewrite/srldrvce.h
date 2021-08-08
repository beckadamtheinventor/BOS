/**
 * @file
 * @brief USB Serial Driver
 *
 * (todo: description)
 *
 * @author John "commandblockguy" Cesarz
 */

#ifndef H_SRLDRVCE
#define H_SRLDRVCE

#include <stdint.h>
#include <stdbool.h>
#include <usbdrvce.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
    SRL_TYPE_UNKNOWN, /**< Incompatible or non-serial device */
    SRL_TYPE_HOST,    /**< Calc is acting as a device */
    SRL_TYPE_CDC,     /**< CDC device */
    SRL_TYPE_FTDI,    /**< FTDI device */
    SRL_TYPE_PL2303   /**< PL2303 device */
};

typedef uint8_t srl_device_type_t;

enum {
    SRL_SUBTYPE_FTDI_UNKNOWN = 0,
    SRL_SUBTYPE_SIO,
    SRL_SUBTYPE_FT8U232AM,
    SRL_SUBTYPE_FT232BM,
    SRL_SUBTYPE_FT2232C,
    SRL_SUBTYPE_FT232RL,
    SRL_SUBTYPE_FTX,
    SRL_SUBTYPE_FT2232H,
    SRL_SUBTYPE_FT4232H,
    SRL_SUBTYPE_FT232H,
};

enum {
    SRL_SUBTYPE_PL2303_01 = 0,
    SRL_SUBTYPE_PL2303_HX,
};

typedef uint8_t srl_device_subtype_t;

typedef struct {
    void *buf_start;
    void *buf_end;
    void *data_start;
    void *data_break;
    void *data_end;
    bool dma_active;
} ring_buf_ctrl_t;

typedef struct {
    usb_device_t dev; /**< USB device */
    /**< An OUT endpoint if in device mode, an IN endpoint otherwise */
    uint8_t rx_addr;
    /**< An IN endpoint if in device mode, an OUT endpoint otherwise */
    uint8_t tx_addr;
    srl_device_type_t type;
    srl_device_subtype_t subtype;
    ring_buf_ctrl_t rx_buf;
    ring_buf_ctrl_t tx_buf;
} srl_device_t;

typedef enum {
    SRL_SUCCESS = 0,
    SRL_ERROR_INVALID_PARAM,
    SRL_ERROR_USB_FAILED,
    SRL_ERROR_NOT_SUPPORTED,
    SRL_ERROR_INVALID_DEVICE,
    SRL_ERROR_INVALID_INTERFACE,
    SRL_ERROR_NO_MEMORY
} srl_error_t;

#define SRL_INTERFACE_ANY 0xFF

/**
 * Initialize a USB connected serial device. Checks if the device is
 * a valid serial device. Will perform all necessary initialization.
 * A user-supplied buffer is needed for internal library use. This buffer must
 * be at least 128 bytes in size. It should not be the same buffer used
 * by other devices and/or functions.
 * @warning Do not call from a USB event handler.
 * @param srl Serial device structure.
 * @param dev USB device to initialize.
 * @param buffer The buffer's address. (must be at least @param size bytes).
 * @param size The size of the buffer. Must be divisible by 2 and at least 128,
 *        but a size of 512 is recommended.
 * @param interface The USB interface number to use, or SRL_INTERFACE_ANY for
 *        the first available interface.
 * @param rate The baud rate to set the device to.
 * @return SRL_SUCCESS on success, otherwise error if
 *         initialization failed.
 */
srl_error_t srl_Open(srl_device_t *srl,
                     usb_device_t dev,
                     void *buffer,
                     size_t size,
                     uint8_t interface,
                     uint24_t rate);

/**
 * Closes and deinitializes a serial device. This function should be
 * called on the \c USB_DEVICE_DISCONNECTED_EVENT in the USB handler callback.
 * @param srl SRL device structure.
 */
void srl_Close(srl_device_t *srl);

/**
 * Reads data from a serial device.
 * This is a non-blocking buffered read - if there are less that @param length
 * bytes available in the buffer, all of the bytes in the buffer will be read.
 * @param srl SRL device structure.
 * @param data Buffer to read into.
          Should be at least @param length bytes long.
 * @param length Number of bytes to read.
 * @return The number of bytes read, or 0 upon error.
 */
size_t srl_Read(srl_device_t *srl,
                void *data,
                size_t length);

/**
 * Writes data to a serial device.
 * This is a non-blocking buffered write - if there is less than @param length
 * bytes of space in the output buffer, not all of the data may be written.
 * @param srl SRL device structure.
 * @param data Data to write to serial.
 * @param length Number of bytes to write.
 * @return The number of bytes written, or 0 upon error.
 */
size_t srl_Write(srl_device_t *srl,
                 const void *data,
                 size_t length);

/**
 * Returns a pointer to CDC ACM descriptors, to be used with usb_Init.
 */
const usb_standard_descriptors_t *srl_GetCDCStandardDescriptors(void);

#ifdef __cplusplus
}
#endif

#endif
