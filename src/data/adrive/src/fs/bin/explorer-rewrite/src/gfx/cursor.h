#ifndef cursor_include_file
#define cursor_include_file

#ifdef __cplusplus
extern "C" {
#endif

#define cursor_width 10
#define cursor_height 15
#define cursor_size 152
#define cursor ((gfx_sprite_t*)cursor_data)
extern unsigned char cursor_data[152];

#ifdef __cplusplus
}
#endif

#endif
