
#ifndef __zxgfxlib__
#define __zxgfxlib__

/* Defines */

/* Default ram area used for executing and writing sprite shaders */
#define ZGX_DEFAULT_RAMSPACE 0xE30800


/* Enums */

typedef uint8_t zgx_asset_type_t;
enum __zgx_asset_types__ {
	Z_ASSET_SPRITE = 0,
	Z_ASSET_TILEMAP,
	Z_ASSET_FONTSPRITE,
	Z_ASSET_1BPPSPRITE,
	Z_ASSET_2BPPSPRITE,
	Z_ASSET_4BPPSPRITE,
	Z_ASSET_COMPRESSEDSPRITE,
	Z_ASSET_RLETSPRITE,
};

/* Structs */

/* zgx asset pack header structure */
typedef struct __zgx_pack_t__ {
	char header[4]; /* "ZGX\0" */
	char packname[12]; /* pack display name */
	uint16_t numitems; /* number of assets in the pack */
	zgx_item_t items[]; /* array of pack assets */
} zgx_pack_t;

/* zgx asset item structure */
typedef struct __zgx_item_t__ {
	char name[8]; /* asset name */
	zgx_asset_type_t type; /* asset type */
	uint16_t offset; /* offset of asset in pack file */
} zgx_item_t;


/* Library function macros */

/* Initialize library with default ramspace */
#define zgx_InitDefault() zgx_Init(ZGX_DEFAULT_RAMSPACE)

/* Extract a sprite from an asset pack into a malloc'd buffer */
#define zgx_ExtractMallocSprite(width, height, pack, asset) zgx_Extract(gfx_MallocSprite(width, height), pack, asset)

/* Library functions */

/** Initialize the library
* @param ramspace Pointer to scrap ram used for executing and writing sprite shaders.
* @note If you don't know what this means, use ZGX_DEFAULT_RAMSPACE.
*/
void zgx_Init(void *ramspace);

/** Extract a sprite from an asset pack
* @param dest Pointer to sprite in ram used to store the extracted sprite.
* @param pack Pointer to asset pack.
* @param asset Name of asset to extract.
* @note not yet implemented fully
*/
gfx_sprite_t *zgx_Extract(gfx_sprite_t *dest, zgx_pack_t *pack, const char *asset);

/** Draw a zgx-format compressed sprite to the current lcd buffer
 * @param data Pointer to sprite data.
 * @param x X position to draw sprite at
 * @param y Y position to draw sprite at
 */
void zgx_Sprite(void *data, int x, int y);

#endif

