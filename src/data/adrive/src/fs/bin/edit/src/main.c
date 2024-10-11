
/** A simple text editor for BOS, titled "edit" for convenience
* Author: Adam "beckadamtheinventor" Beckingham
* License: GPL, see BOS LICENSE for details
*/

#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include <graphx.h>
#include <bos.h>
#include <tice.h>

#define LINE_FEED 0x0A
#define HORIZ_TAB 0x09
#define MARGIN_LEFT 10
#define MARGIN_RIGHT 310
#define MARGIN_TOP 20
#define MARGIN_BOTTOM 230
#define MAX_DRAW_LINES ((unsigned int)((MARGIN_BOTTOM - MARGIN_TOP)/LINE_HEIGHT))
#define LINE_HEIGHT 9
#define CHAR_WIDTH 8
#define TAB_WIDTH 4

#define SAFE_RAM_BUFFER (0xD031F6+0x400)
#define SAFE_RAM_BUFFER_LEN 65536
#define MAX_LINES 1024

typedef struct _estate {
	struct {
		bool needs_save : 1;
		bool inserting : 1;
		bool redraw : 1;
		bool redraw_line : 1;
	};
	uint8_t charset;
	char* fname;
	char* buffer;
	unsigned int buffer_len;
	unsigned int draw_start_line;
	unsigned int cursor_line_no;
	unsigned int cursor_line_offset_start;
	unsigned int cursor_line_offset;
	unsigned int last_line_no;
	unsigned int file_len;
	unsigned int* line_offsets;
	unsigned int offset_left;
	unsigned int offset_right;
	unsigned int line_offset_left;
	unsigned int line_offset_right;
} estate;

const char* overtypes = "aA1x";

estate ed;

void init_editor();
void load_empty();
void load_file(char* fname);
void draw_text(bool one_line);
void type_char(char c);


int main(int argc, char** argv) {
	gfx_Begin();
	init_editor();
	if (argc > 1) {
		load_file(argv[1]);
	} else {
		load_empty();
		ed.fname = NULL;
	}
	uint8_t key;
	ed.redraw = true;
	do {
		if (ed.redraw) {
			draw_text(false);
		} else if (ed.redraw_line) {
			draw_text(true);
		}
		key = sys_WaitKeyCycle();
		if (key == sk_Enter) {
			type_char(LINE_FEED);
		} else if (key == sk_2nd) {
			;
		}
		
	} while (key != sk_Clear);
	gfx_End();
	return 0;
}

void init_editor() {
	ed.buffer = SAFE_RAM_BUFFER;
	ed.buffer_len = SAFE_RAM_BUFFER_LEN;
	ed.draw_start_line = 0;
	ed.cursor_line_no = 0;
	ed.cursor_line_offset = 0;
	ed.cursor_line_offset_start = 0;
	ed.last_line_no = 0;
	ed.offset_left = 0;
	ed.offset_right = ed.buffer_len - 1;
	ed.line_offsets = malloc(sizeof(unsigned int)*MAX_LINES);
	memset(ed.line_offsets, 0, sizeof(unsigned int)*MAX_LINES);
	ed.line_offset_left = 0;
	ed.line_offset_right = MAX_LINES - 1;
}

void load_empty() {
	memset(ed.buffer, 0, ed.buffer_len);
}

void load_file(char* fname) {
	void* fd = fs_OpenFile(fname);
	ed.fname = fname;
	load_empty();
	if (fd == -1) {
		ed.needs_save = true;
	} else {
		ed.needs_save = false;
		fs_Read(ed.buffer, fs_GetFDLen(fd), 1, fd, 0);
	}
}

unsigned int* get_line_offset_ptr(unsigned int lno) {
	if (lno <= ed.line_offset_left) {
		return &ed.line_offsets[lno];
	}
	return &ed.line_offsets[lno + ed.line_offset_right - ed.line_offset_left];
}

#define get_line_offset(l) (*get_line_offset_ptr(l))

char* get_buffer_ptr(unsigned int offset) {
	if (offset <= ed.offset_left) {
		return &ed.buffer[offset];
	}
	return &ed.buffer[offset+ed.offset_right-ed.offset_left];
}

#define get_char_from_buffer(o) (*get_buffer_ptr(o))

void draw_text(bool one_line) {
	char c;
	int x;
	int y = MARGIN_TOP;
	unsigned int lno = ed.draw_start_line;
	unsigned int offset = get_line_offset(lno) + ed.cursor_line_offset_start;
	if (one_line) {
		lno = ed.cursor_line_no;
	}
	for (unsigned int l = 0; l < MAX_DRAW_LINES; l++) {
		// handle drawing lines wider than the screen by offsetting the draw start
		if (lno++ == ed.cursor_line_no) {
			offset += ed.cursor_line_offset_start;
		}
		gfx_PrintStringXY(":", 1, y);
		// start drawing here
		x = MARGIN_LEFT;
		do {
			if (offset >= ed.file_len) {
				return;
			}
			c = get_char_from_buffer(offset++);
			if (c == LINE_FEED) {
				break;
			} else if (c == HORIZ_TAB) {
				x += CHAR_WIDTH * TAB_WIDTH;
			} else {
				gfx_SetTextXY(x, y);
				gfx_PrintChar(c);
			}
		} while (true);
		if (one_line) {
			return;
		}
		y += LINE_HEIGHT;
	}
}

void dec_buffer_offsets() {
	ed.buffer[--ed.offset_right] = ed.buffer[ed.offset_left--];
}

void inc_buffer_offsets() {
	ed.buffer[ed.offset_right++] = ed.buffer[++ed.offset_left];
}

void type_char(char c) {
	ed.needs_save = true;
	*get_buffer_ptr(ed.offset_left) = c;
	ed.offset_left++;
	if (c == LINE_FEED) {
		ed.redraw = true;
	}
	ed.redraw_line = true;
	if (!ed.inserting) {
		if (ed.offset_right >= ed.buffer_len) {
			return;
		}
		ed.offset_right++;
	}
}

void del_char() {
	ed.needs_save = true;
	if (ed.inserting) {
		ed.offset_right++;
	} else {
		ed.offset_left--;
	}
}

unsigned int cur_line_len() {
	unsigned int len = 0;
	unsigned int ptr = get_line_offset(ed.cursor_line_no);
	while (get_char_from_buffer(ptr++) != LINE_FEED) len++;
	return len;
}

void move_cursor_to_eol() {
	unsigned int ptr = get_line_offset(ed.cursor_line_no) + ed.cursor_line_offset;
	while (get_char_from_buffer(++ptr) != LINE_FEED);
}

void zero_cursor_offset() {
	ed.cursor_line_offset = 0;
	ed.cursor_line_offset_start = 0;
}

void move_cursor_up(bool only_move_draw) {
	unsigned int cll;
	// don't seek before first line
	if (ed.cursor_line_no == 0) {
		return;
	}
	if (only_move_draw) {
		if (ed.draw_start_line == 0) {
			return;
		}
		ed.draw_start_line--;
		ed.redraw = true;
		return;
	}
	// seeking above draw start requires redraw
	if (ed.cursor_line_no <= ed.draw_start_line) {
		ed.draw_start_line--;
		ed.redraw = true;
	}
	// move cursor up a line
	ed.cursor_line_no--;
	// get the length of the line we just seeked to
	cll = cur_line_len();
	// move the cursor if it's offset is ahead of the end of the line
	if (ed.cursor_line_offset >= cll) {
		ed.cursor_line_offset = cll - 1;
		ed.cursor_line_offset_start = 0;
	}
}

void move_cursor_down(bool only_move_draw) {
	if (only_move_draw) {
		if (ed.draw_start_line >= ed.last_line_no) {
			return;
		}
		ed.draw_start_line++;
		return;
	}
	if (ed.cursor_line_no >= ed.last_line_no) {
		return;
	}
	if (ed.cursor_line_no >= ed.draw_start_line + MAX_DRAW_LINES) {
		ed.draw_start_line++;
		ed.redraw = true;
	}
}

void move_cursor_left() {
	if (ed.cursor_line_offset == 0) {
		move_cursor_up(false);
		move_cursor_to_eol();
		return;
	} else if (ed.cursor_line_offset <= ed.cursor_line_offset_start) {
		ed.cursor_line_offset_start--;
		ed.redraw = true;
	}
	ed.cursor_line_offset--;
}

void move_cursor_right() {
	char c = get_char_from_buffer(get_line_offset(ed.cursor_line_no) + ed.cursor_line_offset);
	if (c == LINE_FEED) {
		zero_cursor_offset();
		move_cursor_down(false);
		return;
	}
}