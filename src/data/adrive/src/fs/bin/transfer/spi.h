#ifndef SPI_H
#define SPI_H

#include <stdint.h>

enum {
    SPI_CMD_NOP              = 0x00,
    SPI_CMD_SOFTWARE_RESET   = 0x01,
    SPI_CMD_SLEEP_MODE_ON    = 0x10,
    SPI_CMD_SLEEP_MODE_OFF   = 0x11,
    SPI_CMD_PARTIAL_MODE_ON  = 0x12,
    SPI_CMD_PARTIAL_MODE_OFF = 0x13,
    SPI_CMD_INVERT_MODE_OFF  = 0x20,
    SPI_CMD_INVERT_MODE_ON   = 0x21,
    SPI_CMD_DISPLAY_OFF      = 0x28,
    SPI_CMD_DISPLAY_ON       = 0x29,
    SPI_CMD_SET_COL_ADDR     = 0x2A,
    SPI_CMD_SET_PAGE_ADDR    = 0x2B,
    SPI_CMD_MEM_ACC_CTL      = 0x36,
};

typedef struct spi_command {
    uint8_t size, command, params[];
} spi_command_t;

void spi_write(const spi_command_t *command);

#define spi16(value)       \
    ((value) >> 8 & 0xFF), \
    ((value) >> 0 & 0xFF)

#define spi(cmd, ...)                                         \
    do {                                                      \
        static const spi_command_t spi_cmd = {                \
            .size = 1 + sizeof((uint8_t []) { __VA_ARGS__ }), \
            .command = SPI_CMD_##cmd,                         \
            .params = { __VA_ARGS__ },                        \
        };                                                    \
        spi_write(&spi_cmd);                                  \
    } while (0)

#endif
