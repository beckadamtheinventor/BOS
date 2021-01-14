
#ifndef __zxgfxlib__
#define __zxgfxlib__


/** Initialize the library
* @param ramspace pointer to scrap ram used to apply sprite shaders
* @note If you don't know what this means, use ZGX_DEFAULT_RAMSPACE.
*/
void zgx_Init(void *ramspace);

/** Extract a graphics asset from an asset pack
* @param pack pointer to asset pack
* @param asset name of asset to extract
*/
gfx_sprite_t *zgx_Extract(zgx_pack_t *pack, const char *asset);


#endif

