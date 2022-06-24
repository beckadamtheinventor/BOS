/*
 *--------------------------------------
 * Program Name: TRANSFER
 * Author: Jacob "jacobly" Young
 * License: Public Domain
 * Description: File Transfer Program
 *--------------------------------------
 */

/* MTP Structure Forward Declarations */

typedef struct mtp_global mtp_global_t;
#define usb_callback_data_t mtp_global_t
#define usb_transfer_data_t mtp_global_t

/* Includes */
#include "font.h"
#include "ui.h"
#include "var.h"

#include <keypadc.h>
#include <fileioc.h>
#include <usbdrvce.h>

#include <debug.h>
#include <tice.h>

#include <inttypes.h>
#include <limits.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

/* Macros */

#define lengthof(array) (sizeof(array) / sizeof(*(array)))

#define charsof(literal) (lengthof(literal) - 1)

#define COUNT_EACH(...) +1

#define OBJECT_BUFFER \
    ((void *)((mtp_byte_t *)lcd_Ram + LCD_WIDTH * LCD_HEIGHT))

#define FOR_EACH_SUPP_OPR(X) \
    X(GET_DEVICE_INFO)       \
    X(OPEN_SESSION)          \
    X(CLOSE_SESSION)         \
    X(GET_STORAGE_IDS)       \
    X(GET_STORAGE_INFO)      \
    X(GET_NUM_OBJECTS)       \
    X(GET_OBJECT_HANDLES)    \
    X(GET_OBJECT_INFO)       \
    X(GET_OBJECT)            \
    X(DELETE_OBJECT)         \
    X(SEND_OBJECT_INFO)      \
    X(SEND_OBJECT)           \
    X(GET_DEVICE_PROP_DESC)  \
    X(GET_DEVICE_PROP_VALUE) \
    X(SET_DEVICE_PROP_VALUE) \
    X(MOVE_OBJECT)

#define FOR_EACH_SUPP_EVT(X) \
    X(OBJECT_ADDED)          \
    X(OBJECT_REMOVED)

#define FOR_EACH_SUPP_DP(X)        \
    X(uint8, BATTERY_LEVEL, RANGE) \
    X(datetime, DATE_TIME, NONE)   \
    X(uint32, PERCEIVED_DEVICE_TYPE, NONE)

#define FOR_EACH_SUPP_CF(X) \
    X(UNDEFINED)

#define FOR_EACH_SUPP_PF(X) \
    FOR_EACH_SUPP_CF(X)

#define FOR_EACH_STRING_DESCRIPTOR(X) \
    X(const, manufacturer)            \
    X(const, product)                 \
    X(     , serial_number)           \
    X(const, charging_cfg)            \
    X(const, mtp_interface)

#define DEFINE_STRING_DESCRIPTOR(const, name)     \
    static const usb_string_descriptor_t name = { \
        .bLength = sizeof(L##name),               \
        .bDescriptorType = USB_STRING_DESCRIPTOR, \
        .bString = L##name,                       \
    };

#define FOR_EACH_STORAGE(X) \
    X(ram)                  \
    X(arc)

#define FOR_EACH_STORAGE_NONE(X) \
    X(none)                      \
    FOR_EACH_STORAGE(X)

#define FOR_EACH_STORAGE_TOTAL(X) \
    FOR_EACH_STORAGE(X)           \
    X(total)

#define FOR_EACH_STORAGE_NONE_TOTAL(X) \
    X(none)                            \
    FOR_EACH_STORAGE(X)                \
    X(total)

#define get_ram_free_space_in_bytes \
    os_MemChk(NULL)
#define get_arc_free_space_in_bytes \
    (os_ArcChk(), os_TempFreeArc)

#define BATTERY_LEVEL_MIN  0
#define BATTERY_LEVEL_MAX  4
#define BATTERY_LEVEL_STEP 1
#define BATTERY_LEVEL_DEF  0
#define BATTERY_LEVEL_GET_SET 0
#define BATTERY_LEVEL_GET(current) \
    current = boot_GetBatteryStatus()
#define BATTERY_LEVEL_SET(new)

#define DATE_TIME_DEF {                        \
        .length = lengthof(Lfactory_datetime), \
        .string = Lfactory_datetime,           \
    }
#define DATE_TIME_GET_SET 1
#define DATE_TIME_GET(current) \
    get_datetime(&current)
#define DATE_TIME_SET(new)

#define PERCEIVED_DEVICE_TYPE_DEF 0
#define PERCEIVED_DEVICE_TYPE_GET_SET 0
#define PERCEIVED_DEVICE_TYPE_GET(current) \
    current = 5
#define PERCEIVED_DEVICE_TYPE_SET(new)

/* MTP Types */

typedef uint8_t mtp_byte_t;
typedef uint16_t mtp_version_t;
typedef uint16_t mtp_enum_t;
typedef uint32_t mtp_size_t;
typedef uint32_t mtp_id_t;
typedef uint32_t mtp_param_t;
typedef uint64_t mtp_uint64_t;
#define DECLARE_TRUNC_TYPE(name)     \
    typedef union mtp_trunc_##name { \
        mtp_##name##_t name;         \
        size_t word;                 \
        mtp_byte_t byte;             \
    } mtp_trunc_##name##_t;
DECLARE_TRUNC_TYPE(size)
DECLARE_TRUNC_TYPE(id)
DECLARE_TRUNC_TYPE(param)
DECLARE_TRUNC_TYPE(uint64)

typedef usb_error_t(*mtp_transaction_callback_t)(
        mtp_global_t global);

/* MTP Constants */

#define MTP_ROOT_OBJECT_HANDLE UINT32_C(0xFFFFFFFF)

#define Los_specific      L"MSFT100\1"
#define Lmtp_extensions   L"microsoft.com: 1.0;"
#define Lmanufacturer     L"Texas Instruments Incorporated"
#define Lproduct          L"TI-84 Plus CE"
#define Lproduct83        L"TI-83 Premium CE"
#define Ldevice_version   L"255.255.255.65535"
#define Lserial_number    L"0000000000000000"
#define Lcharging_cfg     L"Charging"
#define Lmtp_interface    L"MTP" /* magic string to aid detection */
#define Lram_storage_desc L"RAM"
#define Lram_volume_id    Lserial_number "R"
#define Larc_storage_desc L"Archive"
#define Larc_volume_id    Lserial_number "A"
#define Lfactory_datetime L"20150101T000000"

typedef enum string_id {
    Imissing,
#define DEFINE_STRING_DESCRIPTOR_ID(const, name) I##name,
    FOR_EACH_STRING_DESCRIPTOR(DEFINE_STRING_DESCRIPTOR_ID)
    Inum_strings,
} string_id_t;

#define Inone            UINT32_C(0x00000000)
#define Iram             UINT32_C(0x00010001)
#define Iarc             UINT32_C(0x00020001)
#define Itotal           UINT32_C(0xFFFFFFFF)
#define storage_count    2

#define storage_flag     0x80
#define reserved_flag    0x40

#define none_mask        0x00
#define ram_mask         0x80
#define arc_mask         0x80
#define total_mask       0x00

#define none_flag        0x80
#define ram_flag         0x00
#define arc_flag         0x80
#define total_flag       0x00

#define ram_max_capacity 0x0002577Fu
#define arc_max_capacity 0x002F0000u

#define MTP_EP_CONTROL         (0)
#define MTP_EP_DATA_IN         (USB_DEVICE_TO_HOST | 1)
#define MTP_EP_DATA_OUT        (USB_HOST_TO_DEVICE | 2)
#define MTP_EP_INT             (USB_DEVICE_TO_HOST | 3)
#define MTP_MAX_EVT_PARAMS     (3)
#define MTP_MAX_SOI_PARAMS     (3)
#define MTP_MAX_PARAMS         (5)
#define MTP_MAX_PENDING_EVENTS (2)
#define MTP_MAX_BULK_PKT_SZ    (0x40)
#define MTP_MAX_INT_PKT_SZ     (sizeof(mtp_event_t) + 1)

/* MTP Enumerations */

typedef enum mtp_request {
    GET_EXTENDED_EVENT_DATA = 0x65,
    DEVICE_RESET_REQUEST,
    GET_DEVICE_STATUS,
} mtp_request_t;

typedef enum mtp_block_type {
    MTP_BT_UNDEFINED,
    MTP_BT_COMMAND,
    MTP_BT_DATA,
    MTP_BT_RESPONSE,
    MTP_BT_EVENT,
} mtp_block_type_t;

typedef enum mtp_form {
    MTP_FORM_NONE,
    MTP_FORM_RANGE,
    MTP_FORM_ENUM,
    MTP_FORM_DATE_TIME,
    MTP_FORM_FIXED_LENGTH_ARRAY,
    MTP_FORM_REGULAR_EXPRESSION,
    MTP_FORM_BYTE_ARRAY,
    MTP_FORM_LONG_STRING = 0xFF,
} mtp_form_t;

typedef enum mtp_type_code {
    MTP_TC_undef    /* Undefined                          */ = 0x0000,
    MTP_TC_int8     /* Signed 8-bit integer               */ = 0x0001,
    MTP_TC_uint8    /* Unsigned 8-bit integer             */ = 0x0002,
    MTP_TC_int16    /* Signed 16-bit integer              */ = 0x0003,
    MTP_TC_uint16   /* Unsigned 16-bit integer            */ = 0x0004,
    MTP_TC_int32    /* Signed 32-bit integer              */ = 0x0005,
    MTP_TC_uint32   /* Unsigned 32-bit integer            */ = 0x0006,
    MTP_TC_int64    /* Signed 64-bit integer              */ = 0x0007,
    MTP_TC_uint64   /* Unsigned 64-bit integer            */ = 0x0008,
    MTP_TC_int128   /* Signed 128-bit integer             */ = 0x0009,
    MTP_TC_uint128  /* Unsigned 128-bit integer           */ = 0x000A,
    MTP_TC_aint8    /* Array of signed 8-bit integers     */ = 0x4001,
    MTP_TC_auint8   /* Array of unsigned 8-bit integers   */ = 0x4002,
    MTP_TC_aint16   /* Array of signed 16-bit integers    */ = 0x4003,
    MTP_TC_auint16  /* Array of unsigned 16-bit integers  */ = 0x4004,
    MTP_TC_aint32   /* Array of signed 32-bit integers    */ = 0x4005,
    MTP_TC_auint32  /* Array of unsigned 32-bit integers  */ = 0x4006,
    MTP_TC_aint64   /* Array of signed 64-bit integers    */ = 0x4007,
    MTP_TC_auint64  /* Array of unsigned 64-bit integers  */ = 0x4008,
    MTP_TC_aint128  /* Array of signed 128-bit integers   */ = 0x4009,
    MTP_TC_auint128 /* Array of unsigned 128-bit integers */ = 0x400A,
    MTP_TC_str      /* Variable-length Unicode string     */ = 0xFFFF,
    MTP_TC_datetime /* ISO 8601 Unicode string            */ = 0xFFFF,
} mtp_type_code_t;

typedef struct datetime {
    mtp_byte_t length;
    wchar_t string[lengthof(Lfactory_datetime)];
} datetime_t;

typedef enum mtp_functional_mode {
    MTP_MODE_STANDARD_MODE                                   = 0x0000,
    MTP_MODE_SLEEP_STATE                                     = 0x0001,
    MTP_MODE_NON_RESPONSIVE_PLAYBACK                         = 0xC001,
    MTP_MODE_RESPONSIVE_PLAYBACK                             = 0xC002,
} mtp_functional_mode_t;

typedef enum mtp_storage_type {
    MTP_ST_UNDEFINED                                         = 0x0000,
    MTP_ST_FIXED_ROM                                         = 0x0001,
    MTP_ST_REMOVABLE_ROM                                     = 0x0002,
    MTP_ST_FIXED_RAM                                         = 0x0003,
    MTP_ST_REMOVABLE_RAM                                     = 0x0004,
} mtp_storage_type_t;

typedef enum mtp_filesystem_type {
    MTP_FT_UNDEFINED                                         = 0x0000,
    MTP_FT_GENERIC_FLAT                                      = 0x0001,
    MTP_FT_GENERIC_HIERARCHICAL                              = 0x0002,
    MTP_FT_DCF                                               = 0x0003,
} mtp_filesystem_type_t;

typedef enum mtp_access_capability {
    MTP_AC_READ_WRITE                                        = 0x0000,
    MTP_AC_READ_ONLY_WITHOUT_OBJECT_DELETION                 = 0x0001,
    MTP_AC_READ_ONLY_WITH_OBJECT_DELETION                    = 0x0002,
} mtp_access_capability_t;

typedef enum mtp_protection_status {
    MTP_PS_NO_PROTECTION                                     = 0x0000,
    MTP_PS_READ_ONLY                                         = 0x0001,
    MTP_PS_READ_ONLY_DATA                                    = 0x8002,
    MTP_PS_NOT_TRANSFERABLE_DATA                             = 0x8003,
} mtp_protection_status_t;

typedef enum mtp_operation_code {
    MTP_OPR_GET_DEVICE_INFO                                  = 0x1001,
    MTP_OPR_OPEN_SESSION                                     = 0x1002,
    MTP_OPR_CLOSE_SESSION                                    = 0x1003,
    MTP_OPR_GET_STORAGE_IDS                                  = 0x1004,
    MTP_OPR_GET_STORAGE_INFO                                 = 0x1005,
    MTP_OPR_GET_NUM_OBJECTS                                  = 0x1006,
    MTP_OPR_GET_OBJECT_HANDLES                               = 0x1007,
    MTP_OPR_GET_OBJECT_INFO                                  = 0x1008,
    MTP_OPR_GET_OBJECT                                       = 0x1009,
    MTP_OPR_GET_THUMB                                        = 0x100A,
    MTP_OPR_DELETE_OBJECT                                    = 0x100B,
    MTP_OPR_SEND_OBJECT_INFO                                 = 0x100C,
    MTP_OPR_SEND_OBJECT                                      = 0x100D,
    MTP_OPR_INITIATE_CAPTURE                                 = 0x100E,
    MTP_OPR_FORMAT_STORE                                     = 0x100F,
    MTP_OPR_RESET_DEVICE                                     = 0x1010,
    MTP_OPR_SELF_TEST                                        = 0x1011,
    MTP_OPR_SET_OBJECT_PROTECTION                            = 0x1012,
    MTP_OPR_POWER_DOWN                                       = 0x1013,
    MTP_OPR_GET_DEVICE_PROP_DESC                             = 0x1014,
    MTP_OPR_GET_DEVICE_PROP_VALUE                            = 0x1015,
    MTP_OPR_SET_DEVICE_PROP_VALUE                            = 0x1016,
    MTP_OPR_RESET_DEVICE_PROP_VALUE                          = 0x1017,
    MTP_OPR_TERMINATE_OPEN_CAPTURE                           = 0x1018,
    MTP_OPR_MOVE_OBJECT                                      = 0x1019,
    MTP_OPR_COPY_OBJECT                                      = 0x101A,
    MTP_OPR_GET_PARTIAL_OBJECT                               = 0x101B,
    MTP_OPR_INITIATE_OPEN_CAPTURE                            = 0x101C,
    MTP_OPR_GET_OBJECT_PROPS_SUPPORTED                       = 0x9801,
    MTP_OPR_GET_OBJECT_PROP_DESC                             = 0x9802,
    MTP_OPR_GET_OBJECT_PROP_VALUE                            = 0x9803,
    MTP_OPR_SET_OBJECT_PROP_VALUE                            = 0x9804,
    MTP_OPR_GET_OBJECT_PROP_LIST                             = 0x9805,
    MTP_OPR_SET_OBJECT_PROP_LIST                             = 0x9806,
    MTP_OPR_GET_INTERDEPENDENT_PROP_DESC                     = 0x9807,
    MTP_OPR_SEND_OBJECT_PROP_LIST                            = 0x9808,
    MTP_OPR_GET_OBJECT_REFERENCES                            = 0x9810,
    MTP_OPR_SET_OBJECT_REFERENCES                            = 0x9811,
    MTP_OPR_SKIP                                             = 0x9820,
} mtp_operation_code_t;

typedef enum mtp_response_code {
    MTP_RSP_UNDEFINED                                        = 0x2000,
    MTP_RSP_OK                                               = 0x2001,
    MTP_RSP_GENERAL_ERROR                                    = 0x2002,
    MTP_RSP_SESSION_NOT_OPEN                                 = 0x2003,
    MTP_RSP_INVALID_TRANSACTION_ID                           = 0x2004,
    MTP_RSP_OPERATION_NOT_SUPPORTED                          = 0x2005,
    MTP_RSP_PARAMETER_NOT_SUPPORTED                          = 0x2006,
    MTP_RSP_INCOMPLETE_TRANSFER                              = 0x2007,
    MTP_RSP_INVALID_STORAGE_ID                               = 0x2008,
    MTP_RSP_INVALID_OBJECT_HANDLE                            = 0x2009,
    MTP_RSP_DEVICE_PROP_NOT_SUPPORTED                        = 0x200A,
    MTP_RSP_INVALID_OBJECT_FORMAT_CODE                       = 0x200B,
    MTP_RSP_STORE_FULL                                       = 0x200C,
    MTP_RSP_OBJECT_WRITE_PROTECTED                           = 0x200D,
    MTP_RSP_STORE_READ_ONLY                                  = 0x200E,
    MTP_RSP_ACCESS_DENIED                                    = 0x200F,
    MTP_RSP_NO_THUMBNAIL_PRESENT                             = 0x2010,
    MTP_RSP_SELF_TEST_FAILED                                 = 0x2011,
    MTP_RSP_PARTIAL_DELETION                                 = 0x2012,
    MTP_RSP_STORE_NOT_AVAILABLE                              = 0x2013,
    MTP_RSP_SPECIFICATION_BY_FORMAT_UNSUPPORTED              = 0x2014,
    MTP_RSP_NO_VALID_OBJECT_INFO                             = 0x2015,
    MTP_RSP_INVALID_CODE_FORMAT                              = 0x2016,
    MTP_RSP_UNKNOWN_VENDOR_CODE                              = 0x2017,
    MTP_RSP_CAPTURE_ALREADY_TERMINATED                       = 0x2018,
    MTP_RSP_DEVICE_BUSY                                      = 0x2019,
    MTP_RSP_INVALID_PARENT_OBJECT                            = 0x201A,
    MTP_RSP_INVALID_DEVICE_PROP_FORMAT                       = 0x201B,
    MTP_RSP_INVALID_DEVICE_PROP_VALUE                        = 0x201C,
    MTP_RSP_INVALID_PARAMETER                                = 0x201D,
    MTP_RSP_SESSION_ALREADY_OPEN                             = 0x201E,
    MTP_RSP_TRANSACTION_CANCELLED                            = 0x201F,
    MTP_RSP_SPECIFICATION_OF_DESTINATION_UNSUPPORTED         = 0x2020,
    MTP_RSP_INVALID_OBJECT_PROPCODE                          = 0xA801,
    MTP_RSP_INVALID_OBJECT_PROP_FORMAT                       = 0xA802,
    MTP_RSP_INVALID_OBJECT_PROP_VALUE                        = 0xA803,
    MTP_RSP_INVALID_OBJECT_REFERENCE                         = 0xA804,
    MTP_RSP_GROUP_NOT_SUPPORTED                              = 0xA805,
    MTP_RSP_INVALID_DATASET                                  = 0xA806,
    MTP_RSP_SPECIFICATION_BY_GROUP_UNSUPPORTED               = 0xA807,
    MTP_RSP_SPECIFICATION_BY_DEPTH_UNSUPPORTED               = 0xA808,
    MTP_RSP_OBJECT_TOO_LARGE                                 = 0xA809,
    MTP_RSP_OBJECT_PROP_NOT_SUPPORTED                        = 0xA80A,
} mtp_response_code_t;

typedef enum mtp_object_format_code {
    MTP_OF_UNDEFINED                                         = 0x3000,
    MTP_OF_ASSOCIATION                                       = 0x3001,
} mtp_object_format_code_t;

typedef enum mtp_event_code {
    MTP_EVT_UNDEFINED                                        = 0x4000,
    MTP_EVT_CANCEL_TRANSACTION                               = 0x4001,
    MTP_EVT_OBJECT_ADDED                                     = 0x4002,
    MTP_EVT_OBJECT_REMOVED                                   = 0x4003,
    MTP_EVT_STORE_ADDED                                      = 0x4004,
    MTP_EVT_STORE_REMOVED                                    = 0x4005,
    MTP_EVT_DEVICE_PROP_CHANGED                              = 0x4006,
    MTP_EVT_OBJECT_INFO_CHANGED                              = 0x4007,
    MTP_EVT_DEVICE_INFO_CHANGED                              = 0x4008,
    MTP_EVT_REQUEST_OBJECT_TRANSFER                          = 0x4009,
    MTP_EVT_STORE_FULL                                       = 0x400A,
    MTP_EVT_DEVICE_RESET                                     = 0x400B,
    MTP_EVT_STORAGE_INFO_CHANGED                             = 0x400C,
    MTP_EVT_CAPTURE_COMPLETE                                 = 0x400D,
    MTP_EVT_UNREPORTED_STATUS                                = 0x400E,
    MTP_EVT_OBJECT_PROP_CHANGED                              = 0xC801,
    MTP_EVT_OBJECT_PROP_DESC_CHANGED                         = 0xC802,
    MTP_EVT_OBJECT_REFERENCES_CHANGED                        = 0xC803,
} mtp_event_code_t;

typedef enum mtp_device_property_code {
    MTP_DP_UNDEFINED                                         = 0x5000,
    MTP_DP_BATTERY_LEVEL                                     = 0x5001,
    MTP_DP_FUNCTIONAL_MODE                                   = 0x5002,
    MTP_DP_IMAGE_SIZE                                        = 0x5003,
    MTP_DP_COMPRESSION_SETTING                               = 0x5004,
    MTP_DP_WHITE_BALANCE                                     = 0x5005,
    MTP_DP_RGB_GAIN                                          = 0x5006,
    MTP_DP_F_NUMBER                                          = 0x5007,
    MTP_DP_FOCAL_LENGTH                                      = 0x5008,
    MTP_DP_FOCUS_DISTANCE                                    = 0x5009,
    MTP_DP_FOCUS_MODE                                        = 0x500A,
    MTP_DP_EXPOSURE_METERING_MODE                            = 0x500B,
    MTP_DP_FLASH_MODE                                        = 0x500C,
    MTP_DP_EXPOSURE_TIME                                     = 0x500D,
    MTP_DP_EXPOSURE_PROGRAM_MODE                             = 0x500E,
    MTP_DP_EXPOSURE_INDEX                                    = 0x500F,
    MTP_DP_EXPOSURE_BIAS_COMPENSATION                        = 0x5010,
    MTP_DP_DATE_TIME                                         = 0x5011,
    MTP_DP_CAPTURE_DELAY                                     = 0x5012,
    MTP_DP_STILL_CAPTURE_MODE                                = 0x5013,
    MTP_DP_CONTRAST                                          = 0x5014,
    MTP_DP_SHARPNESS                                         = 0x5015,
    MTP_DP_DIGITAL_ZOOM                                      = 0x5016,
    MTP_DP_EFFECT_MODE                                       = 0x5017,
    MTP_DP_BURST_NUMBER                                      = 0x5018,
    MTP_DP_BURST_INTERVAL                                    = 0x5019,
    MTP_DP_TIMELAPSE_NUMBER                                  = 0x501A,
    MTP_DP_TIMELAPSE_INTERVAL                                = 0x501B,
    MTP_DP_FOCUS_METERING_MODE                               = 0x501C,
    MTP_DP_UPLOAD_URL                                        = 0x501D,
    MTP_DP_ARTIST                                            = 0x501E,
    MTP_DP_COPYRIGHT_INFO                                    = 0x501F,
    MTP_DP_SYNCHRONIZATION_PARTNER                           = 0xD401,
    MTP_DP_DEVICE_FRIENDLY_NAME                              = 0xD402,
    MTP_DP_VOLUME                                            = 0xD403,
    MTP_DP_SUPPORTED_FORMATSORDERED                          = 0xD404,
    MTP_DP_DEVICE_ICON                                       = 0xD405,
    MTP_DP_PLAYBACK_RATE                                     = 0xD410,
    MTP_DP_PLAYBACK_OBJECT                                   = 0xD411,
    MTP_DP_PLAYBACK_CONTAINER_INDEX                          = 0xD412,
    MTP_DP_SESSION_INITIATOR_VERSION_INFO                    = 0xD406,
    MTP_DP_PERCEIVED_DEVICE_TYPE                             = 0xD407,
} mtp_device_property_code_t;

typedef enum mtp_object_property_code {
    MTP_OP_STORAGE_ID                                        = 0xDC01,
    MTP_OP_OBJECT_FORMAT                                     = 0xDC02,
    MTP_OP_PROTECTION_STATUS                                 = 0xDC03,
    MTP_OP_OBJECT_SIZE                                       = 0xDC04,
    MTP_OP_ASSOCIATION_TYPE                                  = 0xDC05,
    MTP_OP_ASSOCIATION_DESC                                  = 0xDC06,
    MTP_OP_OBJECT_FILE_NAME                                  = 0xDC07,
    MTP_OP_DATE_CREATED                                      = 0xDC08,
    MTP_OP_DATE_MODIFIED                                     = 0xDC09,
    MTP_OP_KEYWORDS                                          = 0xDC0A,
    MTP_OP_PARENT_OBJECT                                     = 0xDC0B,
    MTP_OP_ALLOWED_FOLDER_CONTENTS                           = 0xDC0C,
    MTP_OP_HIDDEN                                            = 0xDC0D,
    MTP_OP_SYSTEM_OBJECT                                     = 0xDC0E,
    MTP_OP_PERSISTENT_UNIQUE_OBJECT_IDENTIFIER               = 0xDC41,
    MTP_OP_SYNC_ID                                           = 0xDC42,
    MTP_OP_PROPERTY_BAG                                      = 0xDC43,
    MTP_OP_NAME                                              = 0xDC44,
    MTP_OP_CREATED_BY                                        = 0xDC45,
    MTP_OP_ARTIST                                            = 0xDC46,
    MTP_OP_DATE_AUTHORED                                     = 0xDC47,
    MTP_OP_DESCRIPTION                                       = 0xDC48,
    MTP_OP_URL_REFERENCE                                     = 0xDC49,
    MTP_OP_LANGUAGE_LOCALE                                   = 0xDC4A,
    MTP_OP_COPYRIGHT_INFORMATION                             = 0xDC4B,
    MTP_OP_SOURCE                                            = 0xDC4C,
    MTP_OP_ORIGIN_LOCATION                                   = 0xDC4D,
    MTP_OP_DATE_ADDED                                        = 0xDC4E,
    MTP_OP_NON_CONSUMABLE                                    = 0xDC4F,
    MTP_OP_CORRUPT_UNPLAYABLE                                = 0xDC50,
    MTP_OP_PRODUCER_SERIAL_NUMBER                            = 0xDC51,
    MTP_OP_REPRESENTATIVE_SAMPLE_FORMAT                      = 0xDC81,
    MTP_OP_REPRESENTATIVE_SAMPLE_SIZE                        = 0xDC82,
    MTP_OP_REPRESENTATIVE_SAMPLE_HEIGHT                      = 0xDC83,
    MTP_OP_REPRESENTATIVE_SAMPLE_WIDTH                       = 0xDC84,
    MTP_OP_REPRESENTATIVE_SAMPLE_DURATION                    = 0xDC85,
    MTP_OP_REPRESENTATIVE_SAMPLE_DATA                        = 0xDC86,
    MTP_OP_WIDTH                                             = 0xDC87,
    MTP_OP_HEIGHT                                            = 0xDC88,
    MTP_OP_DURATION                                          = 0xDC89,
    MTP_OP_RATING                                            = 0xDC8A,
    MTP_OP_TRACK                                             = 0xDC8B,
    MTP_OP_GENRE                                             = 0xDC8C,
    MTP_OP_CREDITS                                           = 0xDC8D,
    MTP_OP_LYRICS                                            = 0xDC8E,
    MTP_OP_SUBSCRIPTION_CONTENT_ID                           = 0xDC8F,
    MTP_OP_PRODUCED_BY                                       = 0xDC90,
    MTP_OP_USE_COUNT                                         = 0xDC91,
    MTP_OP_SKIP_COUNT                                        = 0xDC92,
    MTP_OP_LAST_ACCESSED                                     = 0xDC93,
    MTP_OP_PARENTAL_RATING                                   = 0xDC94,
    MTP_OP_META_GENRE                                        = 0xDC95,
    MTP_OP_COMPOSER                                          = 0xDC96,
    MTP_OP_EFFECTIVE_RATING                                  = 0xDC97,
    MTP_OP_SUBTITLE                                          = 0xDC98,
    MTP_OP_ORIGINAL_RELEASE_DATE                             = 0xDC99,
    MTP_OP_ALBUM_NAME                                        = 0xDC9A,
    MTP_OP_ALBUM_ARTIST                                      = 0xDC9B,
    MTP_OP_MOOD                                              = 0xDC9C,
    MTP_OP_DRM_STATUS                                        = 0xDC9D,
    MTP_OP_SUB_DESCRIPTION                                   = 0xDC9E,
    MTP_OP_IS_CROPPED                                        = 0xDCD1,
    MTP_OP_IS_COLOUR_CORRECTED                               = 0xDCD2,
    MTP_OP_IMAGE_BIT_DEPTH                                   = 0xDCD3,
    MTP_OP_F_NUMBER                                          = 0xDCD4,
    MTP_OP_EXPOSURE_TIME                                     = 0xDCD5,
    MTP_OP_EXPOSURE_INDEX                                    = 0xDCD6,
    MTP_OP_TOTAL_BIT_RATE                                    = 0xDE91,
    MTP_OP_BIT_RATE_TYPE                                     = 0xDE92,
    MTP_OP_SAMPLE_RATE                                       = 0xDE93,
    MTP_OP_NUMBER_OF_CHANNELS                                = 0xDE94,
    MTP_OP_AUDIO_BIT_DEPTH                                   = 0xDE95,
    MTP_OP_SCAN_TYPE                                         = 0xDE97,
    MTP_OP_AUDIO_WAVE_CODEC                                  = 0xDE99,
    MTP_OP_AUDIO_BIT_RATE                                    = 0xDE9A,
    MTP_OP_VIDEO_FOURCC_CODEC                                = 0xDE9B,
    MTP_OP_VIDEO_BIT_RATE                                    = 0xDE9C,
    MTP_OP_FRAMES_PER_THOUSAND_SECONDS                       = 0xDE9D,
    MTP_OP_KEY_FRAME_DISTANCE                                = 0xDE9E,
    MTP_OP_BUFFER_SIZE                                       = 0xDE9F,
    MTP_OP_ENCODING_QUALITY                                  = 0xDEA0,
    MTP_OP_ENCODING_PROFILE                                  = 0xDEA1,
    MTP_OP_DISPLAY_NAME                                      = 0xDCE0,
    MTP_OP_BODY_TEXT                                         = 0xDCE1,
    MTP_OP_SUBJECT                                           = 0xDCE2,
    MTP_OP_PRIORITY                                          = 0xDCE3,
    MTP_OP_GIVEN_NAME                                        = 0xDD00,
    MTP_OP_MIDDLE_NAMES                                      = 0xDD01,
    MTP_OP_FAMILY_NAME                                       = 0xDD02,
    MTP_OP_PREFIX                                            = 0xDD03,
    MTP_OP_SUFFIX                                            = 0xDD04,
    MTP_OP_PHONETIC_GIVEN_NAME                               = 0xDD05,
    MTP_OP_PHONETIC_FAMILY_NAME                              = 0xDD06,
    MTP_OP_EMAIL_PRIMARY                                     = 0xDD07,
    MTP_OP_EMAIL_PERSONAL_1                                  = 0xDD08,
    MTP_OP_EMAIL_PERSONAL_2                                  = 0xDD09,
    MTP_OP_EMAIL_BUSINESS_1                                  = 0xDD0A,
    MTP_OP_EMAIL_BUSINESS_2                                  = 0xDD0B,
    MTP_OP_EMAIL_OTHERS                                      = 0xDD0C,
    MTP_OP_PHONE_NUMBER_PRIMARY                              = 0xDD0D,
    MTP_OP_PHONE_NUMBER_PERSONAL                             = 0xDD0E,
    MTP_OP_PHONE_NUMBER_PERSONAL_2                           = 0xDD0F,
    MTP_OP_PHONE_NUMBER_BUSINESS                             = 0xDD10,
    MTP_OP_PHONE_NUMBER_BUSINESS_2                           = 0xDD11,
    MTP_OP_PHONE_NUMBER_MOBILE                               = 0xDD12,
    MTP_OP_PHONE_NUMBER_MOBILE_2                             = 0xDD13,
    MTP_OP_FAX_NUMBER_PRIMARY                                = 0xDD14,
    MTP_OP_FAX_NUMBER_PERSONAL                               = 0xDD15,
    MTP_OP_FAX_NUMBER_BUSINESS                               = 0xDD16,
    MTP_OP_PAGER_NUMBER                                      = 0xDD17,
    MTP_OP_PHONE_NUMBER_OTHERS                               = 0xDD18,
    MTP_OP_PRIMARY_WEB_ADDRESS                               = 0xDD19,
    MTP_OP_PERSONAL_WEB_ADDRESS                              = 0xDD1A,
    MTP_OP_BUSINESS_WEB_ADDRESS                              = 0xDD1B,
    MTP_OP_INSTANT_MESSENGER_ADDRESS                         = 0xDD1C,
    MTP_OP_INSTANT_MESSENGER_ADDRESS_2                       = 0xDD1D,
    MTP_OP_INSTANT_MESSENGER_ADDRESS_3                       = 0xDD1E,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_FULL                      = 0xDD1F,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_LINE_1                    = 0xDD20,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_LINE_2                    = 0xDD21,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_CITY                      = 0xDD22,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_REGION                    = 0xDD23,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_POSTAL_CODE               = 0xDD24,
    MTP_OP_POSTAL_ADDRESS_PERSONAL_COUNTRY                   = 0xDD25,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_FULL                      = 0xDD26,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_LINE_1                    = 0xDD27,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_LINE_2                    = 0xDD28,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_CITY                      = 0xDD29,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_REGION                    = 0xDD2A,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_POSTAL_CODE               = 0xDD2B,
    MTP_OP_POSTAL_ADDRESS_BUSINESS_COUNTRY                   = 0xDD2C,
    MTP_OP_POSTAL_ADDRESS_OTHER_FULL                         = 0xDD2D,
    MTP_OP_POSTAL_ADDRESS_OTHER_LINE_1                       = 0xDD2E,
    MTP_OP_POSTAL_ADDRESS_OTHER_LINE_2                       = 0xDD2F,
    MTP_OP_POSTAL_ADDRESS_OTHER_CITY                         = 0xDD30,
    MTP_OP_POSTAL_ADDRESS_OTHER_REGION                       = 0xDD31,
    MTP_OP_POSTAL_ADDRESS_OTHER_POSTAL_CODE                  = 0xDD32,
    MTP_OP_POSTAL_ADDRESS_OTHER_COUNTRY                      = 0xDD33,
    MTP_OP_ORGANIZATION_NAME                                 = 0xDD34,
    MTP_OP_PHONETIC_ORGANIZATION_NAME                        = 0xDD35,
    MTP_OP_ROLE                                              = 0xDD36,
    MTP_OP_BIRTHDATE                                         = 0xDD37,
    MTP_OP_MESSAGE_TO                                        = 0xDD40,
    MTP_OP_MESSAGE_CC                                        = 0xDD41,
    MTP_OP_MESSAGE_BCC                                       = 0xDD42,
    MTP_OP_MESSAGE_READ                                      = 0xDD43,
    MTP_OP_MESSAGE_RECEIVED_TIME                             = 0xDD44,
    MTP_OP_MESSAGE_SENDER                                    = 0xDD45,
    MTP_OP_ACTIVITY_BEGIN_TIME                               = 0xDD50,
    MTP_OP_ACTIVITY_END_TIME                                 = 0xDD51,
    MTP_OP_ACTIVITY_LOCATION                                 = 0xDD52,
    MTP_OP_ACTIVITY_REQUIRED_ATTENDEES                       = 0xDD54,
    MTP_OP_ACTIVITY_OPTIONAL_ATTENDEES                       = 0xDD55,
    MTP_OP_ACTIVITY_RESOURCES                                = 0xDD56,
    MTP_OP_ACTIVITY_ACCEPTED                                 = 0xDD57,
    MTP_OP_ACTIVITY_TENTATIVE                                = 0xDD58,
    MTP_OP_ACTIVITY_DECLINED                                 = 0xDD59,
    MTP_OP_ACTIVITY_REMINDER_TIME                            = 0xDD5A,
    MTP_OP_ACTIVITY_OWNER                                    = 0xDD5B,
    MTP_OP_ACTIVITY_STATUS                                   = 0xDD5C,
    MTP_OP_OWNER                                             = 0xDD5D,
    MTP_OP_EDITOR                                            = 0xDD5E,
    MTP_OP_WEBMASTER                                         = 0xDD5F,
    MTP_OP_URL_SOURCE                                        = 0xDD60,
    MTP_OP_URL_DESTINATION                                   = 0xDD61,
    MTP_OP_TIME_BOOKMARK                                     = 0xDD62,
    MTP_OP_OBJECT_BOOKMARK                                   = 0xDD63,
    MTP_OP_BYTE_BOOKMARK                                     = 0xDD64,
    MTP_OP_LAST_BUILD_DATE                                   = 0xDD70,
    MTP_OP_TIME_TO_LIVE                                      = 0xDD71,
    MTP_OP_MEDIA_GUID                                        = 0xDD72,
} mtp_object_property_code_t;

/* MTP Structures */

typedef struct mtp_object_info_header {
    mtp_trunc_id_t storage_id;
    mtp_enum_t object_format;
    mtp_enum_t protection_status;
    mtp_size_t object_compressed_size;
    mtp_enum_t thumb_format;
    mtp_size_t thumb_compressed_size;
    mtp_size_t thumb_pix_width;
    mtp_size_t thumb_pix_height;
    mtp_size_t image_pix_width;
    mtp_size_t image_pix_height;
    mtp_size_t image_bit_depth;
    mtp_id_t parent_object;
    mtp_enum_t association_type;
    mtp_id_t association_description;
    mtp_size_t sequence_number;
} mtp_object_info_header_t;

#define DECLARE_OBJECT_INFO(name, file_name_alloc) \
    typedef struct mtp_object_info_##name {        \
        mtp_object_info_header_t header;           \
        mtp_byte_t file_name_length;               \
        wchar_t file_name[file_name_alloc];        \
        mtp_byte_t date_created_length;            \
        wchar_t date_created[0];                   \
        mtp_byte_t date_modified_length;           \
        wchar_t date_modified[0];                  \
        mtp_byte_t keywords_length;                \
        wchar_t keywords[0];                       \
    } mtp_object_info_##name##_t;
DECLARE_OBJECT_INFO(min, 0)
DECLARE_OBJECT_INFO(max, MAX_FILE_NAME_LENGTH)

#define DECLARE_STORAGE_INFO_TYPE(name)            \
    typedef struct name##_mtp_storage_info {       \
        mtp_enum_t storage_type;                   \
        mtp_enum_t filesystem_type;                \
        mtp_enum_t access_capability;              \
        mtp_trunc_uint64_t max_capacity;           \
        mtp_trunc_uint64_t free_space_in_bytes;    \
        mtp_size_t free_space_in_objects;          \
        mtp_byte_t storage_description_length;     \
        wchar_t storage_description[               \
                lengthof(L##name##_storage_desc)]; \
        mtp_byte_t volume_identifier_length;       \
        wchar_t volume_identifier[                 \
                lengthof(L##name##_volume_id)];    \
    } name##_mtp_storage_info_t;
FOR_EACH_STORAGE(DECLARE_STORAGE_INFO_TYPE)

typedef struct mtp_device_info {
    mtp_version_t standard_version;
    mtp_id_t mtp_vendor_extension_id;
    mtp_version_t mtp_version;
    mtp_byte_t mtp_extensions_length;
    wchar_t mtp_extensions[lengthof(Lmtp_extensions)];
    mtp_enum_t functional_mode;
    mtp_size_t operations_supported_length;
    mtp_enum_t operations_supported[0 FOR_EACH_SUPP_OPR(COUNT_EACH)];
    mtp_size_t events_supported_length;
    mtp_enum_t events_supported[0 FOR_EACH_SUPP_EVT(COUNT_EACH)];
    mtp_size_t device_properties_length;
    mtp_enum_t device_properties[0 FOR_EACH_SUPP_DP(COUNT_EACH)];
    mtp_size_t capture_formats_length;
    mtp_enum_t capture_formats[0 FOR_EACH_SUPP_CF(COUNT_EACH)];
    mtp_size_t playback_formats_length;
    mtp_enum_t playback_formats[0 FOR_EACH_SUPP_PF(COUNT_EACH)];
    mtp_byte_t manufacturer_length;
    wchar_t manufacturer[lengthof(Lmanufacturer)];
    mtp_byte_t model_length;
    wchar_t model[lengthof(Lproduct) > lengthof(Lproduct83) ?
                  lengthof(Lproduct) : lengthof(Lproduct83)];
    mtp_byte_t device_version_length;
    wchar_t device_version[lengthof(Ldevice_version)];
    mtp_byte_t serial_number_length;
    wchar_t serial_number[lengthof(Lserial_number Lserial_number)];
} mtp_device_info_t;

typedef struct mtp_container {
    mtp_trunc_size_t length;
    mtp_enum_t type, code;
    mtp_id_t transaction;
} mtp_container_t;

typedef union mtp_transaction_payload {
    mtp_param_t params[MTP_MAX_PARAMS];
    mtp_byte_t buffer[MTP_MAX_BULK_PKT_SZ];
    mtp_size_t count;
    mtp_id_t handles[MTP_MAX_BULK_PKT_SZ /
                     sizeof(mtp_id_t)];
    mtp_object_info_header_t object_info;
} mtp_transaction_payload_t;

enum mtp_send_object_info_state {
    SEND_OBJECT_INFO_CONTAINER_STATE,
    SEND_OBJECT_INFO_DATA_STATE,
    SEND_OBJECT_INFO_REST_STATE,
} mtp_send_object_info_state_t;

typedef union mtp_transaction_state {
    struct {
        size_t id;
        mtp_byte_t mask;
        mtp_byte_t flag;
    } get_object_handles;
    struct {
        mtp_byte_t *data;
        size_t remaining;
        unsigned checksum;
    } get_object;
    struct {
        mtp_byte_t state;
        mtp_enum_t response;
        mtp_param_t params[MTP_MAX_SOI_PARAMS];
    } send_object_info;
    struct {
        mtp_byte_t extra;
        mtp_enum_t response;
    } send_object;
} mtp_transaction_state_t;

typedef struct mtp_transaction_pending {
    struct {
        mtp_byte_t flag;
        mtp_byte_t mask;
        size_t handle;
    } send_object;
} mtp_transaction_pending_t;

typedef struct mtp_transaction {
    mtp_container_t container;
    mtp_transaction_payload_t payload;
    mtp_transaction_state_t state;
    mtp_transaction_pending_t pending;
} mtp_transaction_t;

typedef struct mtp_event {
    mtp_container_t container;
    mtp_param_t params[MTP_MAX_EVT_PARAMS];
} mtp_event_t;

struct mtp_global {
    /* Other State */
    bool exiting;
    /* MTP State */
    bool reset;
    mtp_id_t session;
    mtp_transaction_t transaction;
    mtp_event_t events[MTP_MAX_PENDING_EVENTS];
    /* MTP Info */
    size_t device_info_size;
    const mtp_device_info_t *device_info;
#define DECLARE_STORAGE_INFO(name) \
    name##_mtp_storage_info_t *name##_storage_info;
    FOR_EACH_STORAGE(DECLARE_STORAGE_INFO)
    /* Name List */
#define DECLARE_STORAGE_NAME_COUNT(name) \
    mtp_trunc_param_t name##_name_count;
    FOR_EACH_STORAGE_NONE_TOTAL(DECLARE_STORAGE_NAME_COUNT)
    size_t max_name_id, free_name;
    var_name_t var_names[5000];
};

/* MTP Forward Function Declarations */

#define DECLARE_CALLBACK(name)            \
    static usb_error_t name##_complete(   \
            usb_endpoint_t endpoint,      \
            usb_transfer_status_t status, \
            size_t transferred,           \
            mtp_global_t *global)
DECLARE_CALLBACK(control);
DECLARE_CALLBACK(command);
DECLARE_CALLBACK(get_object_handles);
DECLARE_CALLBACK(get_object);
DECLARE_CALLBACK(send_object_info);
DECLARE_CALLBACK(send_object_container);
DECLARE_CALLBACK(send_object);
DECLARE_CALLBACK(zlp_data_in);
DECLARE_CALLBACK(final_data_in);
DECLARE_CALLBACK(response);
DECLARE_CALLBACK(event);

/* Other Forward Function Declarations */
usb_error_t wait_for_usb(mtp_global_t *global);

/* MTP Function Definitions */

static usb_endpoint_t get_endpoint(
        usb_endpoint_t endpoint,
        mtp_byte_t address) {
    return usb_GetDeviceEndpoint(
            usb_GetEndpointDevice(endpoint),
            address);
}

static usb_error_t stall_data_endpoints(
        usb_endpoint_t endpoint) {
    printf("stalling data endpoints\n");
    usb_error_t error = usb_SetEndpointHalt(
            get_endpoint(endpoint, MTP_EP_DATA_IN));
    if (error == USB_SUCCESS)
        error = usb_SetEndpointHalt(
                get_endpoint(endpoint, MTP_EP_DATA_OUT));
    return error;
}

static usb_error_t schedule_event(
        usb_endpoint_t endpoint,
        mtp_event_code_t code,
        mtp_param_t *params,
        mtp_byte_t param_count,
        mtp_global_t *global) {
    usb_error_t error = USB_SUCCESS;
    bool notified = false;
    while (!global->exiting && error == USB_SUCCESS) {
        for (mtp_byte_t i = 0;
             i != MTP_MAX_PENDING_EVENTS; ++i) {
            if (global->events[i].container.length.byte)
                continue;
            mtp_byte_t params_size =
                param_count * sizeof(mtp_param_t);
            mtp_byte_t block_size =
                sizeof(mtp_container_t) +
                params_size;
            global->events[i].container.length.byte =
                block_size;
            global->events[i].container.code = code;
            global->events[i].container.transaction =
                global->transaction.container.transaction;
            memcpy(global->events[i].params,
                   params, params_size);
            return usb_ScheduleInterruptTransfer(
                    get_endpoint(endpoint, MTP_EP_INT),
                    &global->events[i], block_size,
                    event_complete,
                    (mtp_global_t *)&global->events[i]);
        }
        if (!notified) {
            printf("event queue full");
            notified = true;
        }
        error = wait_for_usb(global);
    }
    return error;
}

static usb_error_t schedule_command(
        usb_endpoint_t endpoint,
        mtp_global_t *global) {
    global->transaction.container.transaction = 0;
    return usb_ScheduleBulkTransfer(
            get_endpoint(
                    endpoint,
                    MTP_EP_DATA_OUT),
            &global->transaction,
            MTP_MAX_BULK_PKT_SZ,
            command_complete,
            global);
}

static usb_error_t schedule_response(
        usb_endpoint_t endpoint,
        mtp_enum_t code,
        mtp_param_t *params,
        mtp_byte_t param_count,
        mtp_global_t *global) {
    mtp_byte_t params_size =
        param_count *
        sizeof(mtp_param_t);
    mtp_byte_t container_size =
        sizeof(mtp_container_t) +
        params_size;
    global->transaction.container.length.size =
        container_size;
    global->transaction.container.type =
        MTP_BT_RESPONSE;
    global->transaction.container.code = code;
    memcpy(global->transaction.payload.params,
           params,
           params_size);
    if (code != MTP_RSP_OK)
        printf("response: %04X\n", code);
    return usb_ScheduleBulkTransfer(
            get_endpoint(endpoint, MTP_EP_DATA_IN),
            &global->transaction,
            container_size,
            response_complete,
            global);
}

static usb_error_t schedule_error_response(
        usb_endpoint_t endpoint,
        mtp_enum_t code,
        mtp_global_t *global) {
    return schedule_response(
            endpoint, code, NULL, 0, global);
}

static usb_error_t schedule_ok_response(
        usb_endpoint_t endpoint,
        mtp_param_t *params,
        mtp_byte_t param_count,
        mtp_global_t *global) {
    return schedule_response(
            endpoint, MTP_RSP_OK,
            params, param_count, global);
}

static usb_error_t schedule_data_in(
        usb_endpoint_t endpoint,
        size_t data_size,
        usb_transfer_callback_t complete,
        mtp_global_t *global) {
    global->transaction.container.length.size =
        sizeof(mtp_container_t) +
        data_size;
    global->transaction.container.type =
        MTP_BT_DATA;
    return usb_ScheduleBulkTransfer(
            get_endpoint(endpoint,
                         MTP_EP_DATA_IN),
            &global->transaction,
            sizeof(mtp_container_t),
            complete,
            global);
}

static usb_error_t schedule_data_in_response(
        usb_endpoint_t endpoint,
        const void *data,
        size_t data_size,
        mtp_global_t *global) {
    usb_error_t error = schedule_data_in(
            endpoint, data_size, NULL, global);
    if (error == USB_SUCCESS)
        error = usb_ScheduleBulkTransfer(
            get_endpoint(endpoint,
                         MTP_EP_DATA_IN),
            (void *)data,
            data_size,
            data_size &&
            !(data_size % MTP_MAX_BULK_PKT_SZ)
            ? zlp_data_in_complete
            : final_data_in_complete,
            global);
    return error;
}

static usb_error_t status_error(
        usb_transfer_status_t status) {
    printf("transfer status = %02X\n", status);
    return USB_SUCCESS;
}

static mtp_id_t alloc_object_handle(
        mtp_global_t *global) {
    mtp_id_t handle = global->free_name;
    if (handle)
        global->free_name =
            global->var_names[handle - 1].next;
    else if ((handle = ++global->max_name_id) >
                 lengthof(global->var_names))
        return --global->max_name_id, 0;
    return handle;
}

static void free_object_handle(
        mtp_id_t handle,
        var_name_t *var_name,
        mtp_global_t *global) {
    if (!(var_name->type & reserved_flag)) {
        --*(var_name->type & storage_flag
            ? &global->arc_name_count.word
            : &global->ram_name_count.word);
        --global->total_name_count.word;
    }
    var_name->type = 0;
    var_name->valid = '\0';
    var_name->next = global->free_name;
    global->free_name = handle;
}

static var_name_t *lookup_object_handle(
        mtp_id_t handle,
        mtp_global_t *global) {
    if (!handle || handle > global->max_name_id)
        return NULL;
    var_name_t *var_name =
        &global->var_names[handle - 1];
    return var_name->valid ? var_name : NULL;
}

static uint16_t compute_checksum(
        const void *data,
        size_t size) {
    unsigned sum = 0;
    const uint8_t *pointer = data;
    while (size--)
        sum += *pointer++;
    return sum;
}

static void get_datetime(
        datetime_t *result) {
    uint16_t year;
    uint8_t month, day, hour, minute, second;
    char string[lengthof(Lfactory_datetime)];
    boot_GetDate(&day, &month, &year);
    boot_GetTime(&second, &minute, &hour);
    int count =
        snprintf(string, lengthof(string),
                 "%04u%02u%02uT%02u%02u%02u",
                 year, month, day, hour, minute, second);
    result->length = count <= 0 ? 0 : count + 1;
    for (mtp_byte_t i = 0; i != result->length; ++i)
        result->string[i] = string[i];
}

static int delete_object(
        usb_endpoint_t endpoint,
        mtp_id_t handle,
        mtp_global_t *global) {
    var_name_t *var_name =
        lookup_object_handle(handle, global);
    if (!var_name)
        return MTP_RSP_INVALID_OBJECT_HANDLE;
    if (var_name->type & reserved_flag) {
        free_object_handle(
                handle, var_name, global);
        return MTP_RSP_OK;
    }
    switch (delete_var(var_name)) {
        case DELETE_VAR_NOT_DELETED:
            return MTP_RSP_ACCESS_DENIED;
        case DELETE_VAR_DELETED:
        case DELETE_VAR_TRUNCATED:
            free_object_handle(
                    handle, var_name, global);
            break;
        case DELETE_VAR_ZEROED: {
            usb_error_t error = schedule_event(
                    endpoint, MTP_EVT_OBJECT_ADDED,
                    &handle, 1, global);
            if (error != USB_SUCCESS)
                return error;
            break;
        }
    }
    return MTP_RSP_OK;
}

static int send_object(
        usb_endpoint_t endpoint,
        mtp_id_t handle,
        size_t size,
        mtp_global_t *global) {
    size += global->transaction.state
        .send_object.extra;
    const var_file_header_t *header = OBJECT_BUFFER;
    if (size <=
            offsetof(var_file_header_t, entry.data) +
            sizeof(uint16_t) ||
        memcmp(header->signature,
               VAR_FILE_SIGNATURE,
               sizeof(header->signature)))
        return MTP_RSP_INCOMPLETE_TRANSFER;
    const mtp_byte_t *pointer =
        (const mtp_byte_t *)&header->entry;
    size -= offsetof(var_file_header_t, entry) +
        sizeof(uint16_t);
    if (header->file_data_length != size ||
        compute_checksum(pointer, size) !=
            *(uint16_t *)&pointer[size])
        return MTP_RSP_INCOMPLETE_TRANSFER;
    size_t count = 0;
    while (size) {
        const var_entry_t *entry =
            (const var_entry_t *)pointer;
        if (size < offsetof(var_entry_t, data) -
                sizeof(entry->version) -
                sizeof(entry->flag) ||
            entry->var_data_length_1 < 2)
            return MTP_RSP_INCOMPLETE_TRANSFER;
        size_t entry_size =
            sizeof(entry->var_header_length) +
            sizeof(entry->var_data_length_1) +
            entry->var_header_length +
            entry->var_data_length_1;
        switch (entry->var_header_length) {
            case offsetof(var_entry_t, data) -
                sizeof(entry->var_header_length) -
                sizeof(entry->var_data_length_1) -
                sizeof(entry->version) -
                sizeof(entry->flag):
                break;
            case offsetof(var_entry_t, data) -
                sizeof(entry->var_header_length) -
                sizeof(entry->var_data_length_1):
                if (entry->flag & ~storage_flag)
                    return MTP_RSP_INCOMPLETE_TRANSFER;
                break;
            default:
                return MTP_RSP_INCOMPLETE_TRANSFER;
        }
        if (size < entry_size ||
            *(const uint16_t *)&pointer[
                    sizeof(entry->var_header_length) +
                    sizeof(entry->var_data_length_1) +
                    entry->var_header_length -
                    sizeof(entry->var_data_length_2)] !=
                entry->var_data_length_1)
            return MTP_RSP_INCOMPLETE_TRANSFER;
        pointer += entry_size;
        size -= entry_size;
        ++count;
    }
    pointer = (const mtp_byte_t *)&header->entry;
    bool first = true;
    do {
        const var_entry_t *entry =
            (const var_entry_t *)pointer;
        pointer +=
            sizeof(entry->var_header_length) +
            sizeof(entry->var_data_length_1) +
            entry->var_header_length;
        mtp_byte_t version = 0, flag = 0;
        if (entry->var_header_length ==
                offsetof(var_entry_t, data) -
                sizeof(entry->var_header_length) -
                sizeof(entry->var_data_length_1)) {
            version = entry->version;
            flag = entry->flag;
        }
        (void)version;
        flag &= global->transaction.pending
            .send_object.mask;
        flag |= global->transaction.pending
            .send_object.flag;
        usb_error_t error;
        switch (create_var(&entry->var_name, pointer,
                           entry->var_data_length_1)) {
            case CREATE_VAR_NOT_CREATED:
                break;
            case CREATE_VAR_RECREATED:
                for (mtp_id_t id = 0;
                     id != global->max_name_id; ) {
                    var_name_t *var_name =
                        &global->var_names[id++];
                    if (!(var_name->type &
                              reserved_flag) &&
                        !var_name_cmp(
                                &entry->var_name,
                                var_name)) {
                        free_object_handle(
                                id, var_name, global);
                        if ((error = schedule_event(
                                     endpoint,
                                     MTP_EVT_OBJECT_REMOVED,
                                     &id, 1, global)) !=
                                USB_SUCCESS)
                            return error;
                        break;
                    }
                }
                __attribute__((fallthrough));
            case CREATE_VAR_CREATED: {
                if (first)
                    first = false; /* TODO: maybe update info? */
                else if (!(handle = alloc_object_handle(
                                   global)))
                    return MTP_RSP_OK;
                else if ((error = schedule_event(
                                      endpoint,
                                      MTP_EVT_OBJECT_ADDED,
                                      &handle, 1, global)) !=
                             USB_SUCCESS)
                    return error;
                var_name_t *var_name =
                    &global->var_names[handle - 1];
                --*(var_name->type & storage_flag
                    ? &global->arc_name_count.word
                    : &global->ram_name_count.word);
                memcpy(var_name,
                       &entry->var_name,
                       sizeof(entry->var_name));
                var_name->type &= type_mask;
                if (flag && !arc_unarc_var(var_name))
                    var_name->type |= flag;
                ++*(var_name->type & storage_flag
                    ? &global->arc_name_count.word
                    : &global->ram_name_count.word);
                break;
            }
        }
        pointer += entry->var_data_length_1;
    } while (--count);
    return first
        ? MTP_RSP_INCOMPLETE_TRANSFER
        : MTP_RSP_OK;
}

#define DEFINE_CALLBACK(name)             \
    static usb_error_t name##_complete(   \
            usb_endpoint_t endpoint,      \
            usb_transfer_status_t status, \
            size_t transferred,           \
            mtp_global_t *global)

DEFINE_CALLBACK(control) {
    (void)endpoint;
    (void)transferred;
    (void)global;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    return USB_SUCCESS;
}

DEFINE_CALLBACK(command) {
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    global->reset = false;
    if (transferred < sizeof(mtp_container_t) ||
        global->transaction.container
            .length.size != transferred ||
        global->transaction.container.type !=
            MTP_BT_COMMAND)
        return stall_data_endpoints(endpoint);
    if (!global->session &&
        global->transaction.container.code >
            MTP_OPR_OPEN_SESSION)
        return schedule_error_response(
                endpoint,
                MTP_RSP_SESSION_NOT_OPEN,
                global);
    mtp_byte_t params_size =
        transferred - sizeof(mtp_container_t);
    if (params_size % sizeof(mtp_param_t) ||
        params_size > MTP_MAX_PARAMS * sizeof(mtp_param_t))
        return stall_data_endpoints(endpoint);
    memset(&global->transaction.payload.params[
                   params_size / sizeof(mtp_param_t)], 0,
           MTP_MAX_PARAMS * sizeof(mtp_param_t) - params_size);
    size_t pending_handle =
        global->transaction.pending
            .send_object.handle;
    global->transaction.pending
        .send_object.handle = 0;
    switch (global->transaction.container.code) {
#define MAX_PARAMS(max)                                        \
        do                                                     \
            for (mtp_byte_t i = max; i != MTP_MAX_PARAMS; ++i) \
                if (global->transaction.payload.params[i])     \
                    return schedule_error_response(            \
                            endpoint,                          \
                            MTP_RSP_PARAMETER_NOT_SUPPORTED,   \
                            global);                           \
        while (0)
    case MTP_OPR_GET_DEVICE_INFO:
        MAX_PARAMS(0);
        return schedule_data_in_response(
                endpoint, global->device_info,
                global->device_info_size, global);
    case MTP_OPR_OPEN_SESSION:
        MAX_PARAMS(1);
        if (!global->transaction.payload.params[0])
            return schedule_error_response(
                    endpoint, MTP_RSP_INVALID_PARAMETER,
                    global);
        if (global->session)
            return schedule_response(
                    endpoint, MTP_RSP_SESSION_ALREADY_OPEN,
                    &global->session, 1, global);
        global->session =
            global->transaction.payload.params[0];
        return schedule_ok_response(
                endpoint, NULL, 0, global);
    case MTP_OPR_CLOSE_SESSION:
        MAX_PARAMS(0);
        global->session = 0;
        return schedule_ok_response(
                endpoint, NULL, 0, global);
    case MTP_OPR_GET_STORAGE_IDS: {
        static const mtp_id_t storage_ids[] = {
            storage_count,
#define LIST_STORAGE_ID(name) I##name,
            FOR_EACH_STORAGE(LIST_STORAGE_ID)
        };
        MAX_PARAMS(0);
        return schedule_data_in_response(
                endpoint, storage_ids,
                sizeof(storage_ids), global);
    }
    case MTP_OPR_GET_STORAGE_INFO:
        MAX_PARAMS(1);
#define GET_STORAGE_INFO_RESPONSE(name)                             \
        if (global->transaction.payload.params[0] == I##name) {     \
            global->name##_storage_info->free_space_in_bytes.word = \
                get_##name##_free_space_in_bytes;                   \
            return schedule_data_in_response(                       \
                    endpoint, global->name##_storage_info,          \
                    sizeof(name##_mtp_storage_info_t), global);     \
        }
        FOR_EACH_STORAGE(GET_STORAGE_INFO_RESPONSE)
        return schedule_error_response(
                endpoint,
                MTP_RSP_INVALID_STORAGE_ID,
                global);
    case MTP_OPR_GET_NUM_OBJECTS:
        MAX_PARAMS(3);
        if (global->transaction.payload.params[1] &&
            global->transaction.payload.params[1] !=
                MTP_OF_UNDEFINED)
            return schedule_ok_response(
                    endpoint,
                    &global->none_name_count.param, 1,
                    global);
        if (global->transaction.payload.params[2] &&
            global->transaction.payload.params[2] !=
                MTP_ROOT_OBJECT_HANDLE)
            return schedule_error_response(
                    endpoint,
                    lookup_object_handle(
                            global->transaction.payload.params[2],
                            global)
                    ? MTP_RSP_INVALID_PARENT_OBJECT
                    : MTP_RSP_INVALID_OBJECT_HANDLE,
                    global);
#define GET_NUM_OBJECTS_RESPONSE(name)                \
        if (global->transaction.payload.params[0] ==  \
                I##name)                              \
            return schedule_ok_response(              \
                    endpoint,                         \
                    &global->name##_name_count.param, \
                    1, global);
        FOR_EACH_STORAGE_TOTAL(GET_NUM_OBJECTS_RESPONSE)
        return schedule_error_response(
                endpoint,
                MTP_RSP_INVALID_STORAGE_ID,
                global);
    case MTP_OPR_GET_OBJECT_HANDLES: {
        MAX_PARAMS(3);
        global->transaction.state.get_object_handles.id = 0;
        if (global->transaction.payload.params[2] &&
            global->transaction.payload.params[2] !=
                MTP_ROOT_OBJECT_HANDLE)
            return schedule_error_response(
                    endpoint,
                    lookup_object_handle(
                            global->transaction.payload.params[2],
                            global)
                    ? MTP_RSP_INVALID_PARENT_OBJECT
                    : MTP_RSP_INVALID_OBJECT_HANDLE,
                    global);
#define GET_OBJECT_HANDLES_RESPONSE(name)                \
        if (global->transaction.payload.params[0] ==     \
                I##name) {                               \
            size_t name_count =                          \
                global->name##_name_count.word;          \
            global->transaction.state                    \
                .get_object_handles.mask = name##_mask;  \
            global->transaction.state                    \
                .get_object_handles.flag = name##_flag;  \
            if (global->transaction.payload.params[1] && \
                global->transaction.payload.params[1] != \
                    MTP_OF_UNDEFINED) {                  \
                name_count = 0;                          \
                global->transaction.state.               \
                    get_object_handles.mask = none_mask; \
                global->transaction.state.               \
                    get_object_handles.flag = none_flag; \
            }                                            \
            global->transaction.payload.count =          \
                name_count;                              \
            return schedule_data_in(                     \
                    endpoint, sizeof(mtp_size_t) +       \
                    name_count * sizeof(mtp_id_t),       \
                    get_object_handles_complete,         \
                    global);                             \
        }
        FOR_EACH_STORAGE_TOTAL(GET_OBJECT_HANDLES_RESPONSE)
        return schedule_error_response(
                endpoint,
                MTP_RSP_INVALID_STORAGE_ID,
                global);
    }
    case MTP_OPR_GET_OBJECT_INFO: {
        static mtp_object_info_max_t object_info;
        MAX_PARAMS(1);
        var_name_t *var_name = lookup_object_handle(
                global->transaction.payload.params[0],
                global);
        if (!var_name)
            return schedule_error_response(
                    endpoint,
                    MTP_RSP_INVALID_OBJECT_HANDLE,
                    global);
        object_info.header.storage_id.word =
            var_name->type & storage_flag ? Iarc : Iram;
        object_info.header.object_format = MTP_OF_UNDEFINED;
        object_info.header.object_compressed_size = 0;
        mtp_byte_t file_name_length = 0;
        memset(object_info.file_name, 0,
               sizeof(object_info.file_name));
        if (!(var_name->type & reserved_flag)) {
            object_info.header.object_compressed_size =
                offsetof(var_file_header_t, entry.data) +
                get_var_data_size(var_name) +
                sizeof(uint16_t);
            file_name_length = get_var_file_name(
                    var_name,
                    object_info.file_name);
        }
        object_info.file_name_length =
            file_name_length;
        return schedule_data_in_response(
                endpoint,
                &object_info,
                sizeof(object_info) -
                sizeof(object_info.file_name) +
                file_name_length *
                sizeof(*object_info.file_name),
                global);
    }
    case MTP_OPR_GET_OBJECT: {
        static var_file_header_t header = {
            .signature = VAR_FILE_SIGNATURE,
            .global_version = 0,
            .comment = VAR_FILE_COMMENT,
            .file_data_length = 0,
            .entry = {
                .var_header_length = 
                offsetof(var_file_header_t,
                         entry.var_data_length_2) -
                offsetof(var_file_header_t,
                         entry.var_data_length_1),
                .var_data_length_1 = 0,
                .var_name = {
                    .type = 0,
                    .name = "",
                },
                .version = 0,
                .flag = 0,
                .var_data_length_2 = 0,
                .data = {},
            },
        };
        usb_error_t error;
        mtp_byte_t *data, size;
        size_t remaining;
        unsigned checksum = 0;
        MAX_PARAMS(1);
        var_name_t *var_name = lookup_object_handle(
                global->transaction.payload.params[0],
                global);
        if (!var_name)
            return schedule_error_response(
                    endpoint,
                    MTP_RSP_INVALID_OBJECT_HANDLE,
                    global);
        if (var_name->type & reserved_flag)
            return schedule_data_in(
                    endpoint, 0,
                    final_data_in_complete,
                    global);
        remaining = get_var_data_size(var_name);
        error = schedule_data_in(
                endpoint,
                offsetof(var_file_header_t,
                         entry.data) +
                    remaining +
                    sizeof(uint16_t),
                NULL, global);
        if (error != USB_SUCCESS) return error;
        data = get_var_data_ptr(var_name);
        header.file_data_length = remaining +
            offsetof(var_entry_t, data);
        header.entry.var_name.type =
            var_name->type & type_mask;
        memcpy(header.entry.var_name.name,
               var_name->name,
               sizeof(header.entry.var_name.name));
        header.entry.version =
            ((mtp_byte_t *)get_var_vat_ptr(var_name))[-2];
        header.entry.flag =
            var_name->type & storage_flag;
        header.entry.var_data_length_1 =
            header.entry.var_data_length_2 =
                remaining;
        if (remaining < sizeof(header.entry.data))
            size = remaining;
        else
            size = sizeof(header.entry.data);
        memcpy(header.entry.data, data, size);
        global->transaction.state
            .get_object.data = data + size;
        checksum += compute_checksum(
                &header.entry,
                offsetof(var_entry_t, data) +
                size);
        global->transaction.state
            .get_object.checksum = checksum;
        remaining -= size - sizeof(uint16_t);
        if (remaining == 2 &&
            size < sizeof(header.entry.data)) {
            header.entry.data[size++] =
                checksum >> 0;
            --remaining;
        }
        if (remaining == 1 &&
            size < sizeof(header.entry.data)) {
            header.entry.data[size++] =
                checksum >> 8;
            --remaining;
        }
        global->transaction.state
            .get_object.remaining = remaining;
        return usb_ScheduleBulkTransfer(
                get_endpoint(endpoint,
                             MTP_EP_DATA_IN),
                &header,
                offsetof(var_file_header_t,
                         entry.data) + size,
                size == sizeof(header.entry.data)
                ? get_object_complete
                : final_data_in_complete,
                global);
    }
    case MTP_OPR_GET_THUMB:
        printf("GetThumb");
        break;
    case MTP_OPR_DELETE_OBJECT: {
        int response = MTP_RSP_OK;
        if (global->transaction.payload.params[0] !=
                MTP_ROOT_OBJECT_HANDLE) {
            MAX_PARAMS(1);
            response = delete_object(
                    endpoint,
                    global->transaction.payload.params[0],
                    global);
            if (response < MTP_RSP_UNDEFINED)
                return response;
        } else {
            MAX_PARAMS(2);
            if (!global->transaction.payload.params[1] ||
                global->transaction.payload.params[1] ==
                    MTP_OF_UNDEFINED)
                for (size_t id = 0; id++ != global->max_name_id &&
                         response >= MTP_RSP_UNDEFINED; ) {
                    int result = delete_object(
                            endpoint, id, global);
                    if (result < MTP_RSP_UNDEFINED)
                        return result;
                    else if (result == MTP_RSP_ACCESS_DENIED)
                        response = MTP_RSP_PARTIAL_DELETION;
                }
        }
        return schedule_response(
                endpoint, response, NULL, 0, global);
    }
    case MTP_OPR_SEND_OBJECT_INFO:
        global->transaction.pending
            .send_object.handle = pending_handle;
        global->transaction.state
            .send_object_info.state =
            SEND_OBJECT_INFO_CONTAINER_STATE;
        global->transaction.state
            .send_object_info.response = MTP_RSP_OK;
        for (mtp_byte_t i = 2; i != MTP_MAX_PARAMS; ++i)
            if (global->transaction.payload.params[i])
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_PARAMETER_NOT_SUPPORTED;
#define SEND_OBJECT_INFO_IS_STORAGE(name)   \
        if (global->transaction.payload     \
            .params[0] == I##name) {        \
            global->transaction.pending     \
                .send_object.flag =         \
                name##_flag & name##_mask;  \
            global->transaction.pending     \
                .send_object.mask =         \
                name##_mask ^ storage_flag; \
        } else
        FOR_EACH_STORAGE_NONE(SEND_OBJECT_INFO_IS_STORAGE)
        if (global->transaction.state
                     .send_object_info.response ==
                     MTP_RSP_OK)
            global->transaction.state
                     .send_object_info.response =
                MTP_RSP_INVALID_STORAGE_ID;
        if (global->transaction.state
                .send_object_info.response ==
                MTP_RSP_OK &&
            global->transaction.payload.params[1] &&
            global->transaction.payload.params[1] !=
                MTP_ROOT_OBJECT_HANDLE)
            global->transaction.state
                .send_object_info.response =
                    lookup_object_handle(
                            global->transaction.payload.params[1],
                            global)
                    ? MTP_RSP_INVALID_PARENT_OBJECT
                    : MTP_RSP_INVALID_OBJECT_HANDLE;
        global->transaction.state
            .send_object_info.params[0] =
            global->transaction.payload.params[0] == Inone
            ? Iram : global->transaction.payload.params[0];
        global->transaction.state
            .send_object_info.params[1] =
            MTP_ROOT_OBJECT_HANDLE;
        return usb_ScheduleBulkTransfer(
                endpoint,
                &global->transaction,
                MTP_MAX_BULK_PKT_SZ,
                send_object_info_complete,
                global);
    case MTP_OPR_SEND_OBJECT:
        global->transaction.pending
            .send_object.handle = pending_handle;
        global->transaction.state
            .send_object.response = MTP_RSP_OK;
        for (mtp_byte_t i = 0; i != MTP_MAX_PARAMS; ++i)
            if (global->transaction.payload.params[i])
                global->transaction.state
                    .send_object.response =
                    MTP_RSP_PARAMETER_NOT_SUPPORTED;
        if (global->transaction.state
                .send_object.response ==
                MTP_RSP_OK &&
            !global->transaction.pending
                .send_object.handle)
            global->transaction.state
                .send_object.response =
                MTP_RSP_NO_VALID_OBJECT_INFO;
        return usb_ScheduleBulkTransfer(
                endpoint,
                &global->transaction,
                MTP_MAX_BULK_PKT_SZ,
                send_object_container_complete,
                global);
    case MTP_OPR_INITIATE_CAPTURE:
        printf("InitiateCapture");
        break;
    case MTP_OPR_FORMAT_STORE:
        printf("FormatStore");
        break;
    case MTP_OPR_RESET_DEVICE:
        printf("ResetDevice");
        break;
    case MTP_OPR_SELF_TEST:
        printf("SelfTest");
        break;
    case MTP_OPR_SET_OBJECT_PROTECTION:
        printf("SetObjectProtection");
        break;
    case MTP_OPR_POWER_DOWN:
        printf("PowerDown");
        break;
    case MTP_OPR_GET_DEVICE_PROP_DESC:
        MAX_PARAMS(1);
#define DECLARE_FORM_NONE(type)
#define DECLARE_FORM_RANGE(type) \
        type##_t minimum_value;  \
        type##_t maximum_value;  \
        type##_t step_size;
#define DEFINE_FORM_NONE(name)
#define DEFINE_FORM_RANGE(name)      \
        .minimum_value = name##_MIN, \
        .maximum_value = name##_MAX, \
        .step_size = name##_STEP,
#define GET_DEVICE_PROP_DESC_RESPONSE(type, name, form) \
        if (global->transaction.payload.params[0] ==    \
                MTP_DP_##name) {                        \
            static struct name##_DESC {                 \
                mtp_enum_t device_property_code;        \
                mtp_enum_t datatype;                    \
                mtp_byte_t get_set;                     \
                type##_t factory_default_value;         \
                type##_t current_value;                 \
                mtp_byte_t form_flag;                   \
                DECLARE_FORM_##form(type)               \
            } name = {                                  \
                .device_property_code = MTP_DP_##name,  \
                .datatype = MTP_TC_##type,              \
                .get_set = name##_GET_SET,              \
                .factory_default_value = name##_DEF,    \
                .current_value = name##_DEF,            \
                .form_flag = MTP_FORM_##form,           \
                DEFINE_FORM_##form(name)                \
            };                                          \
            name##_GET(name.current_value);             \
            return schedule_data_in_response(           \
                    endpoint, &name,                    \
                    sizeof(name), global);              \
        }
        FOR_EACH_SUPP_DP(GET_DEVICE_PROP_DESC_RESPONSE)
        return schedule_error_response(
                endpoint,
                MTP_RSP_DEVICE_PROP_NOT_SUPPORTED,
                global);
    case MTP_OPR_GET_DEVICE_PROP_VALUE:
        MAX_PARAMS(1);
#define GET_DEVICE_PROP_VALUE_RESPONSE(type, name, form) \
        if (global->transaction.payload.params[0] ==     \
                MTP_DP_##name) {                         \
            type##_t current;                            \
            name##_GET(current);                         \
            return schedule_data_in_response(            \
                    endpoint, &current,                  \
                    sizeof(current), global);            \
        }
        FOR_EACH_SUPP_DP(GET_DEVICE_PROP_VALUE_RESPONSE)
        return schedule_error_response(
                endpoint,
                MTP_RSP_DEVICE_PROP_NOT_SUPPORTED,
                global);
    case MTP_OPR_SET_DEVICE_PROP_VALUE:
        MAX_PARAMS(1);
        usb_ScheduleBulkTransfer(
                endpoint,
                &global->transaction.payload,
                MTP_MAX_BULK_PKT_SZ,
                NULL,
                global);
        return schedule_error_response(
                endpoint,
                MTP_RSP_ACCESS_DENIED,
                global);
    case MTP_OPR_RESET_DEVICE_PROP_VALUE:
        printf("ResetDevicePropValue");
        break;
    case MTP_OPR_TERMINATE_OPEN_CAPTURE:
        printf("TerminateOpenCapture");
        break;
    case MTP_OPR_MOVE_OBJECT: {
        mtp_enum_t response = MTP_RSP_INVALID_STORAGE_ID;
        MAX_PARAMS(3);
        var_name_t *var_name = lookup_object_handle(
                global->transaction.payload.params[0],
                global);
        if (!var_name)
            response = MTP_RSP_INVALID_OBJECT_HANDLE;
        else if (global->transaction.payload.params[2])
            response = lookup_object_handle(
                    global->transaction.payload.params[2],
                    global)
                ? MTP_RSP_INVALID_PARENT_OBJECT
                : MTP_RSP_INVALID_OBJECT_HANDLE;
#define MOVE_OBJECT_RESPONSE(name)                           \
        else if (global->transaction.payload.params[1] ==    \
                     I##name)                                \
            response =                                       \
                (var_name->type & name##_mask) !=            \
                    name##_flag &&                           \
                !arc_unarc_var(var_name)                     \
                ? var_name->type ^= storage_flag, MTP_RSP_OK \
                : MTP_RSP_STORE_FULL;
        FOR_EACH_STORAGE(MOVE_OBJECT_RESPONSE)
        return schedule_response(
                endpoint, response,
                NULL, 0, global);
    }
    case MTP_OPR_COPY_OBJECT:
        printf("CopyObject");
        break;
    case MTP_OPR_GET_PARTIAL_OBJECT:
        printf("GetPartialObject");
        break;
    case MTP_OPR_INITIATE_OPEN_CAPTURE:
        printf("InitiateOpenCapture");
        break;
    case MTP_OPR_GET_OBJECT_PROPS_SUPPORTED:
        printf("GetObjectPropsSupported");
        break;
    case MTP_OPR_GET_OBJECT_PROP_DESC:
        printf("GetObjectPropDesc");
        break;
    case MTP_OPR_GET_OBJECT_PROP_VALUE:
        printf("GetObjectPropValue");
        break;
    case MTP_OPR_SET_OBJECT_PROP_VALUE:
        printf("SetObjectPropValue");
        break;
    case MTP_OPR_GET_OBJECT_REFERENCES:
        printf("GetObjectReferences");
        break;
    case MTP_OPR_SET_OBJECT_REFERENCES:
        printf("SetObjectReferences");
        break;
    case MTP_OPR_SKIP:
        printf("Skip");
        break;
    }
    printf(": (%08" PRIX32 ")",
           global->transaction.container.length.size);
    for (mtp_byte_t i = 0; params_size -= 4; ++i)
        printf(" %08" PRIX32,
               global->transaction.payload.params[i]);
    printf("\n");
    return schedule_error_response(
            endpoint,
            MTP_RSP_OPERATION_NOT_SUPPORTED,
            global);
}

DEFINE_CALLBACK(get_object_handles) {
    mtp_id_t *handles =
        global->transaction.payload.handles;
    mtp_byte_t size = 0;
    size_t id =
        global->transaction.state
            .get_object_handles.id;
    mtp_byte_t mask =
        global->transaction.state
            .get_object_handles.mask;
    mtp_byte_t flag =
        global->transaction.state
            .get_object_handles.flag;
    (void)transferred;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    if (!id) {
        ++handles;
        size = sizeof(mtp_size_t);
    }
    while (size != MTP_MAX_BULK_PKT_SZ &&
           id != global->max_name_id) {
        var_name_t *name = &global->var_names[id++];
        if (name->valid && (name->type & mask) == flag) {
            *handles++ = id;
            size += sizeof(mtp_id_t);
        }
    }
    global->transaction.state
        .get_object_handles.id = id;
    return usb_ScheduleBulkTransfer(
            endpoint,
            &global->transaction.payload,
            size,
            size == MTP_MAX_BULK_PKT_SZ
            ? get_object_handles_complete
            : final_data_in_complete,
            global);
}

DEFINE_CALLBACK(get_object) {
    size_t remaining =
        global->transaction.state
            .get_object.remaining;
    unsigned checksum =
        global->transaction.state
            .get_object.checksum;
    mtp_byte_t size;
    (void)transferred;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    if (remaining <= 2)
        size = 0;
    else if (remaining <= MTP_MAX_BULK_PKT_SZ + 2)
        size = remaining - sizeof(uint16_t);
    else
        size = MTP_MAX_BULK_PKT_SZ;
    memcpy(global->transaction.payload.buffer,
           global->transaction.state
               .get_object.data,
           size);
    global->transaction.state
        .get_object.data += size;
    checksum += compute_checksum(
            global->transaction.payload.buffer,
            size);
    global->transaction.state
        .get_object.checksum = checksum;
    remaining -= size;
    if (remaining == 2 &&
        size < MTP_MAX_BULK_PKT_SZ) {
        global->transaction.payload.buffer[size++] =
            checksum >> 0;
        --remaining;
    }
    if (remaining == 1 &&
        size < MTP_MAX_BULK_PKT_SZ) {
        global->transaction.payload.buffer[size++] =
            checksum >> 8;
        --remaining;
    }
    global->transaction.state
        .get_object.remaining = remaining;
    return usb_ScheduleBulkTransfer(
            endpoint,
            &global->transaction.payload,
            size,
            size == MTP_MAX_BULK_PKT_SZ
            ? get_object_complete
            : final_data_in_complete,
            global);
}

DEFINE_CALLBACK(send_object_info) {
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    mtp_byte_t object_info_size = transferred;
    switch (global->transaction.state
                .send_object_info.state) {
        case SEND_OBJECT_INFO_CONTAINER_STATE:
            if ((transferred != sizeof(mtp_container_t) &&
                 transferred != MTP_MAX_BULK_PKT_SZ) ||
                global->transaction.container.length.size <
                    sizeof(mtp_container_t) +
                    sizeof(mtp_object_info_min_t) ||
                global->transaction.container.type !=
                    MTP_BT_DATA ||
                global->transaction.container.code !=
                    MTP_OPR_SEND_OBJECT_INFO)
                return stall_data_endpoints(endpoint);
            global->transaction.state
                .send_object_info.state =
                SEND_OBJECT_INFO_DATA_STATE;
            if (!(object_info_size -=
                      sizeof(mtp_container_t))) {
                transferred = MTP_MAX_BULK_PKT_SZ;
                break;
            }
            __attribute__((fallthrough));
        case SEND_OBJECT_INFO_DATA_STATE:
            if (global->transaction.state
                  .send_object_info.response !=
                MTP_RSP_OK);
            else if (object_info_size <
                         sizeof(mtp_object_info_header_t))
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_INVALID_DATASET;
            else if (global->transaction.payload
                         .object_info.object_format !=
                         MTP_OF_UNDEFINED)
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_INVALID_OBJECT_FORMAT_CODE;
            else if (global->transaction.payload.object_info
                         .object_compressed_size &&
                     global->transaction.payload.object_info
                         .object_compressed_size <
                         offsetof(var_file_header_t,
                                  entry.data) +
                         sizeof(uint16_t))
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_INVALID_DATASET;
            else if (global->transaction.payload.object_info
                         .object_compressed_size >
                     offsetof(var_file_header_t,
                              entry.data) +
                         0xFFFF + sizeof(uint16_t))
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_OBJECT_TOO_LARGE;
            else if (global->transaction.pending
                         .send_object.handle)
                global->transaction.state
                    .send_object_info.params[2] =
                    global->transaction.pending
                        .send_object.handle;
            else if (!(global->transaction.state
                           .send_object_info.params[2] =
                           alloc_object_handle(global)))
                global->transaction.state
                    .send_object_info.response =
                    MTP_RSP_STORE_FULL;
            else {
                var_name_t *var_name = &global->var_names[
                        global->transaction.state
                            .send_object_info.params[2] - 1];
                var_name->type =
                    global->transaction.pending
                        .send_object.flag | reserved_flag;
                var_name->valid = 1;
                ++*(var_name->type & storage_flag
                    ? &global->arc_name_count.word
                    : &global->ram_name_count.word);
                ++global->total_name_count.word;
            }
            global->transaction.state
                .send_object_info.state =
                SEND_OBJECT_INFO_REST_STATE;
            __attribute__((fallthrough));
        case SEND_OBJECT_INFO_REST_STATE:
            break;
    }
    if (transferred == MTP_MAX_BULK_PKT_SZ)
        return usb_ScheduleBulkTransfer(
                endpoint,
                &global->transaction.payload,
                MTP_MAX_BULK_PKT_SZ,
                send_object_info_complete,
                global);
    if (global->transaction.state
            .send_object_info.response !=
            MTP_RSP_OK)
        return schedule_error_response(
                endpoint,
                global->transaction.state
                    .send_object_info.response,
                global);
    global->transaction.pending
        .send_object.handle =
        global->transaction.state
            .send_object_info.params[2];
    return schedule_ok_response(
            endpoint,
            global->transaction.state
                .send_object_info.params,
            lengthof(global->transaction.state
                         .send_object_info.params),
            global);
}

DEFINE_CALLBACK(send_object_container) {
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    if (transferred < sizeof(mtp_container_t) ||
        global->transaction.container.length.size >
            sizeof(mtp_container_t) +
            offsetof(var_file_header_t,
                     entry.data) +
            0xFFFF + sizeof(uint16_t) ||
        global->transaction.container.length.word <
            transferred ||
        (transferred != sizeof(mtp_container_t) &&
         transferred != MTP_MAX_BULK_PKT_SZ &&
         transferred != global->transaction
             .container.length.word) ||
        global->transaction.container.type !=
            MTP_BT_DATA ||
        global->transaction.container.code !=
            MTP_OPR_SEND_OBJECT)
        return stall_data_endpoints(endpoint);
    if (global->transaction.container.length.word ==
            sizeof(mtp_container_t))
        return schedule_ok_response(
                endpoint,
                NULL, 0, global);
    mtp_byte_t extra =
        global->transaction.state
            .send_object.extra =
        transferred -
            sizeof(mtp_container_t);
    memcpy(OBJECT_BUFFER,
           global->transaction.payload.buffer,
           extra);
    if (extra && transferred != MTP_MAX_BULK_PKT_SZ)
        return send_object_complete(
                endpoint, status, extra, global);
    return usb_ScheduleBulkTransfer(
            endpoint,
            OBJECT_BUFFER + extra,
            global->transaction.container.length.word -
                sizeof(mtp_container_t) - extra,
            send_object_complete,
            global);
}

DEFINE_CALLBACK(send_object) {
    size_t handle =
        global->transaction.pending
            .send_object.handle;
    global->transaction.pending
        .send_object.handle = 0;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    mtp_enum_t response =
        global->transaction.state
            .send_object.response;
    if (response == MTP_RSP_OK)
        response = send_object(
                endpoint, handle,
                transferred, global);
    if (response < MTP_RSP_UNDEFINED)
        return response;
    return schedule_response(
            endpoint, response, NULL, 0, global);
}

DEFINE_CALLBACK(zlp_data_in) {
    (void)transferred;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    return usb_ScheduleBulkTransfer(
            endpoint, NULL, 0,
            final_data_in_complete,
            global);
}

DEFINE_CALLBACK(final_data_in) {
    (void)transferred;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    if (global->reset)
        return schedule_command(endpoint, global);
    return schedule_ok_response(endpoint, NULL, 0, global);
}

DEFINE_CALLBACK(response) {
    (void)transferred;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    return schedule_command(endpoint, global);
}

DEFINE_CALLBACK(event) {
    (void)endpoint;
    (void)transferred;
    ((mtp_event_t *)global)->container.length.byte = 0;
    if (status != USB_TRANSFER_COMPLETED)
        return status_error(status);
    printf("event complete\n");
    return USB_SUCCESS;
}

static usb_error_t usb_event(usb_event_t event,
                             void *event_data,
                             mtp_global_t *global) {
    usb_error_t error = USB_SUCCESS;
    if (!(usb_GetRole() & USB_ROLE_DEVICE))
        return error;
    usb_endpoint_t control = usb_GetDeviceEndpoint(
            usb_FindDevice(NULL, NULL, USB_SKIP_HUBS),
            MTP_EP_CONTROL);
    if (event < USB_DEFAULT_SETUP_EVENT)
        printf("event: %d\n", event);
    if (event == 99)
        printf("debug: %06X\n", (unsigned)event_data);
    switch (event) {
    case USB_DEFAULT_SETUP_EVENT: {
        usb_control_setup_t *setup = event_data;
        if (setup->bmRequestType ==
              (USB_DEVICE_TO_HOST |
               USB_STANDARD_REQUEST |
               USB_RECIPIENT_DEVICE) &&
            setup->bRequest == USB_GET_DESCRIPTOR_REQUEST &&
            setup->wValue == 0x03EE && !setup->wIndex) {
            DEFINE_STRING_DESCRIPTOR(const, os_specific);
            error = usb_ScheduleTransfer(
                    control, (void *)&os_specific,
                    sizeof(os_specific),
                    control_complete, global);
        } else if (setup->bmRequestType ==
                       (USB_DEVICE_TO_HOST |
                        USB_VENDOR_REQUEST |
                        USB_RECIPIENT_DEVICE) &&
                   setup->bRequest == 1 &&
                   !setup->wValue &&
                   setup->wIndex == 4) {
            static const usb_descriptor_t control_message = {
                .bLength = sizeof(control_message),
                .bDescriptorType = 0,
                .data = {
                    0x00, 0x00, 0x00, 0x01,
                    0x04, 0x00, 0x01, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x01,
                    0x4D, 0x54, 0x50, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00
                },
            };
            error = usb_ScheduleTransfer(
                    control, (void *)&control_message,
                    sizeof(control_message),
                    control_complete, global);
        } else if (setup->bmRequestType << 1 ==
                     (USB_CLASS_REQUEST |
                      USB_RECIPIENT_INTERFACE) << 1 &&
                   !setup->wValue && !setup->wIndex) {
            if (!(setup->bmRequestType & USB_DEVICE_TO_HOST)) {
                if (setup->bRequest != DEVICE_RESET_REQUEST ||
                    setup->wLength)
                    break;
                global->reset = true;
                global->session = 0;
                error = usb_ScheduleTransfer(
                        control, NULL, 0,
                        control_complete, global);
            } else if (setup->bRequest == GET_EXTENDED_EVENT_DATA) {
                printf("GET_EXTENDED_EVENT_DATA\n");
                break;
            } else if (setup->bRequest == GET_DEVICE_STATUS) {
                printf("GET_DEVICE_STATUS\n");
                break;
            } else break;
        } else break;
        if (error == USB_SUCCESS)
            error = USB_IGNORE;
        break;
    }
    case USB_HOST_CONFIGURE_EVENT:
        global->session = 0;
        error = schedule_command(control, global);
        break;
    default:
        break;
    }
    return error;
}

int main(void) {
    static mtp_global_t global;
    usb_error_t error;
    ui_Init();
#define CENTER(string)                    \
    printf("%*s%.*s",                     \
           (LCD_WIDTH / FONT_WIDTH +      \
            charsof(string)) / 2,         \
           string,                        \
           charsof(string) %              \
           (LCD_WIDTH / FONT_WIDTH) != 0, \
           "\n");
    CENTER("TRANSFER " VERSION);
    CENTER("Connect USB to PC.");
    CENTER("Press [clear] to exit.");
    CENTER("--------------------------------");
    ui_Lock();
    static mtp_device_info_t device_info = {
        .standard_version = 100, /* 1.00 */
        .mtp_vendor_extension_id = 6,
        .mtp_version = 101, /* 1.01 */
        .mtp_extensions_length = lengthof(device_info.mtp_extensions),
        .mtp_extensions = Lmtp_extensions,
        .functional_mode = MTP_MODE_STANDARD_MODE,
        .operations_supported_length =
            lengthof(device_info.operations_supported),
        .operations_supported = {
#define LIST_SUPP_OPR(name) \
            MTP_OPR_##name,
            FOR_EACH_SUPP_OPR(LIST_SUPP_OPR)
        },
        .events_supported_length = lengthof(device_info.events_supported),
        .events_supported = {
#define LIST_SUPP_EVT(name) \
            MTP_EVT_##name,
            FOR_EACH_SUPP_EVT(LIST_SUPP_EVT)
        },
        .device_properties_length = lengthof(device_info.device_properties),
        .device_properties = {
#define LIST_SUPP_DP(type, name, form) \
            MTP_DP_##name,
            FOR_EACH_SUPP_DP(LIST_SUPP_DP)
        },
        .capture_formats_length = lengthof(device_info.capture_formats),
        .capture_formats = {
#define LIST_SUPP_CF(name) \
            MTP_OF_##name,
            FOR_EACH_SUPP_CF(LIST_SUPP_CF)
        },
        .playback_formats_length = lengthof(device_info.playback_formats),
        .playback_formats = {
#define LIST_SUPP_PF(name) \
            MTP_OF_##name,
            FOR_EACH_SUPP_PF(LIST_SUPP_PF)
        },
        .manufacturer_length = lengthof(device_info.manufacturer),
        .manufacturer = Lmanufacturer,
    };
#define DEFINE_STORAGE_INFO(name)                            \
    static name##_mtp_storage_info_t name##_storage_info = { \
        .storage_type = MTP_ST_FIXED_RAM,                    \
        .filesystem_type = MTP_FT_GENERIC_FLAT,              \
        .access_capability = MTP_AC_READ_WRITE,              \
        .max_capacity = { .uint64 = name##_max_capacity },   \
        .free_space_in_bytes = { .uint64 = 0 },              \
        .free_space_in_objects = UINT32_MAX,                 \
        .storage_description_length =                        \
            lengthof(L##name##_storage_desc),                \
        .storage_description = L##name##_storage_desc,       \
        .volume_identifier_length =                          \
            lengthof(L##name##_volume_id),                   \
        .volume_identifier = L##name##_volume_id,            \
    };
    FOR_EACH_STORAGE(DEFINE_STORAGE_INFO)
    /* Standard USB Descriptors */
    FOR_EACH_STRING_DESCRIPTOR(DEFINE_STRING_DESCRIPTOR)
    DEFINE_STRING_DESCRIPTOR(const, product83)
    const static usb_string_descriptor_t *strings[] = {
#define ADDRESSOF_STRING_DESCRIPTOR(const, name) &name,
        FOR_EACH_STRING_DESCRIPTOR(ADDRESSOF_STRING_DESCRIPTOR)
    };
    static const usb_string_descriptor_t langids = {
        .bLength = sizeof(langids) + sizeof(wchar_t) * 1,
        .bDescriptorType = USB_STRING_DESCRIPTOR,
        .bString = {
            [0] = 0x0409u,
        },
    };
    static const struct configuration1 {
        usb_configuration_descriptor_t configuration;
        struct configuration1_interface0 {
            usb_interface_descriptor_t interface;
            usb_endpoint_descriptor_t endpoints[3];
        } interface0;
    } configuration1 = {
        .configuration = {
            .bLength = sizeof(configuration1.configuration),
            .bDescriptorType = USB_CONFIGURATION_DESCRIPTOR,
            .wTotalLength = sizeof(configuration1),
            .bNumInterfaces = 1u,
            .bConfigurationValue = 1u,
            .iConfiguration = Icharging_cfg,
            .bmAttributes = USB_CONFIGURATION_ATTRIBUTES |
                               USB_SELF_POWERED | USB_NO_REMOTE_WAKEUP,
            .bMaxPower = 500u / 2u,
        },
        .interface0 = {
            .interface = {
                .bLength = sizeof(configuration1.interface0.interface),
                .bDescriptorType = USB_INTERFACE_DESCRIPTOR,
                .bInterfaceNumber = 0u,
                .bAlternateSetting = 0u,
                .bNumEndpoints = lengthof(configuration1.interface0.endpoints),
                .bInterfaceClass = USB_IMAGE_CLASS,
                .bInterfaceSubClass = 1u,
                .bInterfaceProtocol = 1u,
                .iInterface = Imtp_interface,
            },
            .endpoints = {
                [0] = {
                    .bLength = sizeof(configuration1.interface0.endpoints[0]),
                    .bDescriptorType = USB_ENDPOINT_DESCRIPTOR,
                    .bEndpointAddress = MTP_EP_DATA_IN,
                    .bmAttributes = USB_BULK_TRANSFER,
                    .wMaxPacketSize = MTP_MAX_BULK_PKT_SZ,
                    .bInterval = 0u,
                },
                [1] = {
                    .bLength = sizeof(configuration1.interface0.endpoints[1]),
                    .bDescriptorType = USB_ENDPOINT_DESCRIPTOR,
                    .bEndpointAddress = MTP_EP_DATA_OUT,
                    .bmAttributes = USB_BULK_TRANSFER,
                    .wMaxPacketSize = MTP_MAX_BULK_PKT_SZ,
                    .bInterval = 0u,
                },
                [2] = {
                    .bLength = sizeof(configuration1.interface0.endpoints[2]),
                    .bDescriptorType = USB_ENDPOINT_DESCRIPTOR,
                    .bEndpointAddress = MTP_EP_INT,
                    .bmAttributes = USB_INTERRUPT_TRANSFER,
                    .wMaxPacketSize = MTP_MAX_INT_PKT_SZ,
                    .bInterval = 6u,
                },
            },
        },
    };
    static const usb_configuration_descriptor_t *configurations[] = {
        [0] = &configuration1.configuration
    };
    static usb_device_descriptor_t device = {
        .bLength = sizeof(device),
        .bDescriptorType = USB_DEVICE_DESCRIPTOR,
        .bcdUSB = 0x200u, /* 2.00 */
        .bDeviceClass = USB_INTERFACE_SPECIFIC_CLASS,
        .bDeviceSubClass = 0u,
        .bDeviceProtocol = 0u,
        .bMaxPacketSize0 = 0x40u,
        .idVendor = 0x0451u,
        .idProduct = 0xE010u,
        .bcdDevice = 0x240u, /* 2.40 */
        .iManufacturer = Imanufacturer,
        .iProduct = Iproduct,
        .iSerialNumber = Iserial_number,
        .bNumConfigurations = lengthof(configurations),
    };
    static const usb_standard_descriptors_t descriptors = {
        .device = &device,
        .configurations = configurations,
        .langids = &langids,
        .numStrings = Inum_strings,
        .strings = strings,
    };
    const system_info_t *info = os_GetSystemInfo();
    for (mtp_byte_t i = 0; i != MTP_MAX_PENDING_EVENTS; ++i)
        global.events[i].container.type = MTP_BT_EVENT;
    mtp_byte_t *device_info_strings = &device_info.model_length;
    if (info->hardwareType & 1) {
        *device_info_strings++ =
            lengthof(Lproduct83);
        memcpy(device_info_strings,
               Lproduct83,
               sizeof(Lproduct83));
        device_info_strings +=
            sizeof(Lproduct83);
        *(mtp_byte_t *)&device.bcdDevice =
            0x60; /* 2.60 */
        strings[Iproduct - 1] = &product83;
        var_extensions[0x23][0] = 'p';
    } else {
        *device_info_strings++ =
            lengthof(Lproduct);
        memcpy(device_info_strings,
               Lproduct,
               sizeof(Lproduct));
        device_info_strings +=
            sizeof(Lproduct);
    }
    {
        char version[lengthof(Ldevice_version)];
        int count =
            snprintf(version, lengthof(version),
                     "%u.%u.%u.%04u",
                     info->osMajorVersion,
                     info->osMinorVersion,
                     info->osRevisionVersion,
                     info->osBuildVersion);
        mtp_byte_t size = count <= 0 ? 0 : count + 1;
        *device_info_strings++ = size;
        for (mtp_byte_t i = 0; i != size; ++i) {
            *device_info_strings++ = version[i];
            device_info_strings++;
        }
    }
    *device_info_strings++ =
        lengthof(Lserial_number Lserial_number);
    memcpy(device_info_strings,
           Lserial_number,
           sizeof(Lserial_number) -
           sizeof(L'\0'));
    device_info_strings +=
        sizeof(Lserial_number Lserial_number);
    global.device_info = &device_info;
    global.device_info_size =
        device_info_strings -
        (mtp_byte_t *)&device_info;
#define SET_STORAGE_INFO_PTR(name) \
    global.name##_storage_info = &name##_storage_info;
    FOR_EACH_STORAGE(SET_STORAGE_INFO_PTR)
    wchar_t *serial_numbers[] = {
        &serial_number.bString[2 * lengthof(info->calcid)],
        (wchar_t *)device_info_strings - 1,
#define LIST_STORAGE_INFO_SERIAL(name) \
        &name##_storage_info.volume_identifier[2 * lengthof(info->calcid)],
        FOR_EACH_STORAGE(LIST_STORAGE_INFO_SERIAL)
    };
    for (mtp_byte_t i = 2 * lengthof(info->calcid); i; ) {
        mtp_byte_t nibble = info->calcid[--i >> 1];
        if (!(i & 1))
            nibble >>= 4;
        nibble &= 0xF;
        if (nibble >= 10)
            nibble += 'A' - '0' - 10;
        nibble += '0';
        for (mtp_byte_t j = lengthof(serial_numbers); j; )
            *--serial_numbers[--j] = nibble;
    }
    {
        void *entry = os_GetSymTablePtr(), *data;
        uint24_t type, name_length;
        char name[9];
        var_name_t *var_name = global.var_names;
        do {
            entry = os_NextSymEntry(
                    entry, &type, &name_length,
                    name, &data);
            if ((type &= type_mask) == TI_EQU_TYPE &&
                !((equ_t *)data)->len)
                continue;
            if (data >= (void *)os_RamStart) {
                var_name->type = type | ram_flag;
                ++global.ram_name_count.word;
            } else {
                var_name->type = type | arc_flag;
                ++global.arc_name_count.word;
            }
            memcpy(var_name->name, name, name_length);
            ++var_name;
            if (++global.max_name_id ==
                    lengthof(global.var_names))
                break;
        } while (entry);
        global.total_name_count.word =
            global.max_name_id;
    }
    do {
        if (usb_Init(usb_event, &global, &descriptors,
                     USB_DEFAULT_INIT_FLAGS) != USB_SUCCESS)
            break;
        do
            error = wait_for_usb(&global);
        while (!global.exiting && error == USB_SUCCESS);
        if (error != USB_SUCCESS)
            printf("error: %06X\n", error);
    } while (!global.exiting);
    usb_Cleanup();
    ui_Cleanup();
    return 0;
}

usb_error_t wait_for_usb(mtp_global_t *global) {
    usb_error_t error;
    kb_SetMode(MODE_2_SINGLE);
    do
        if ((error = usb_HandleEvents()) != USB_SUCCESS)
            return error;
    while (kb_GetMode() != MODE_0_IDLE);
    if (kb_IsDown(kb_KeyClear))
        global->exiting = true;
    if (kb_IsDown(kb_KeyGraphVar)) {
        var_name_t var_name = {
            .type = TI_REAL_TYPE,
            .name = "A",
        };
        mtp_byte_t *vat = get_var_vat_ptr(&var_name);
        mtp_byte_t *data = get_var_data_ptr(&var_name);
        size_t size = get_var_data_size(&var_name);
        printf("vat");
        for (int i = -9; i <= 0; ++i)
            printf(" %02X", vat[i]);
        printf("\ndata");
        for (size_t i = 0; i != size; ++i)
            printf(" %02X", data[i]);
        printf("\n");
    }
    return USB_SUCCESS;
}
