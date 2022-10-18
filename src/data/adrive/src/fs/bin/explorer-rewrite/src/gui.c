
#include <stdint.h>
#include <stdbool.h>
#include <graphx.h>
#include "gui.h"

void guiDrawWindow(window_t *window) {
	gfx_SetColor(WINDOW_FILL_COLOR);
	if (window->type == WIN_BORDERLESS) {
		gfx_FillRectangle(window->x, window->y, window->width, window->height);
	} else {
		gfx_FillRectangle(window->x + 1, window->y + 1, window->width - 2, window->height - 2);
		gfx_SetColor(WINDOW_BORDER_COLOR);
		gfx_Rectangle(window->x, window->y, window->width, window->height);
	}
	gfx_SetTextBGColor(WINDOW_FILL_COLOR);
	gfx_SetTextFGColor(WINDOW_TEXT_COLOR);
	if (window->icon != NULL) {
		gfx_Sprite(window->icon, window->x + 1, window->y + 1);
	}
	if (window->title != NULL) {
		gfx_HorizLine(window->x + 1, window->y + 10, window->width - 2);
		if (window->icon != NULL)
			guiDrawStringXY(window->title, (window->x + 2 + window->icon->width), window->y + 2, (window->width - 4 + window->icon->height), 9);
		else
			guiDrawStringXY(window->title, window->x + 2, window->y + 2, window->width - 4, 9);
	}
	if (window->content != NULL) {
		guiDrawStringXY(window->content, window->x + 2, window->y + (window->title != NULL ? LINE_HEIGHT + 3 : 2), window->width - 4, window->height - 4);
	}
}

void guiDrawStringXY(const char *str, int minx, int miny, int w, int h) {
	char c;
	int maxx, maxy;
	int x = minx;
	int y = miny;
	if (w == 0)
		maxx = LCD_WIDTH;
	else
		maxx = x + w;
	if (h == 0)
		maxy = LCD_HEIGHT;
	else
		maxy = y + h;

	gfx_SetTextXY(x, y);
	while ((c = *str++)) {
		if ((unsigned)c < 0x80) {
			uint8_t cw = gfx_GetCharWidth(c);
			if (c == 0xA || x + cw >= maxx) {
				x = minx;
				y += LINE_HEIGHT;
			}
			if (y >= maxy)
				break;
			if (c == 0xA)
				continue;
			gfx_SetTextXY(x, y);
			gfx_PrintChar(c);
			x += cw;
		}
	}
	
}
