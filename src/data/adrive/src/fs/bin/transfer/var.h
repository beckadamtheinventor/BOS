#ifndef VAR_H
#define VAR_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum { MAX_FILE_NAME_LENGTH = 8+1+3+1 };

enum { type_mask = 0x3F };

#define VAR_FILE_SIGNATURE "**TI83F*\x1A\xA"
#define VAR_FILE_COMMENT "Created by prgmTRANSFER."

typedef struct var_name var_name_t;
struct var_name {
    uint8_t type;
    union {
        char name[8];
        struct {
            uint8_t valid;
            size_t next;
        };
    };
};
typedef struct var_entry {
    uint16_t var_header_length;
    uint16_t var_data_length_1;
    var_name_t var_name;
    uint8_t version;
    uint8_t flag;
    uint16_t var_data_length_2;
    uint8_t data[0x80 - 0x48];
} var_entry_t;
typedef struct var_file_header {
    char signature[10];
    uint8_t global_version;
    char comment[42];
    uint16_t file_data_length;
    var_entry_t entry;
} var_file_header_t;

enum {
    DELETE_VAR_NOT_DELETED,
    DELETE_VAR_DELETED,
    DELETE_VAR_TRUNCATED,
    DELETE_VAR_ZEROED,
};

enum {
    CREATE_VAR_NOT_CREATED,
    CREATE_VAR_RECREATED,
    CREATE_VAR_CREATED,
};

extern char var_extensions[0x40][2];
const extern uint8_t var_codepoints[4][0x100];

int8_t var_name_cmp(const var_name_t *var_name_1,
                    const var_name_t *var_name_2);
void *get_var_vat_ptr(const var_name_t *var_name);
void *get_var_data_ptr(const var_name_t *var_name);
size_t get_var_data_size(const var_name_t *var_name);
uint8_t delete_var(const var_name_t *var_name);
uint8_t create_var(const var_name_t *var_name,
                   const void *data, size_t size);
uint8_t arc_unarc_var(const var_name_t *var_name);
uint8_t get_var_file_name(const var_name_t *var_name,
                          wchar_t file_name[MAX_FILE_NAME_LENGTH]);
    
#ifdef __cplusplus
}
#endif

#endif
