
#ifndef __BOS_H__
#define __BOS_H__

#include <stdint.h>
#include <stdbool.h>

typedef struct __filesystem_device_t__ {
	uint8_t flags;
	uint8_t unused[3];
	// Called by the OS to open a file within this device as a filesystem.
	uint8_t fs_OpenFileJP;
	void *(*fs_OpenFile)(char *path);
	// Called by the OS to create a file within this device as a filesystem.
	uint8_t fs_CreateFileJP;
	void *(*fs_CreateFile)(char *path, int flags);
	// Called by the OS to delete a file within this device as a filesystem.
	uint8_t fs_DeleteFileJP;
	void *(*fs_DeleteFile)(char *path);
	// Called by the OS to read from a file within this device as a filesystem. Data is a physical address where data is read into.
	uint8_t fs_ReadJP;
	unsigned int (*fs_Read)(void *data, unsigned int len, uint8_t count, void *fd);
	// Called by the OS to write to a file within this device as a filesystem. Data is a physical address where data is written from.
	uint8_t fs_WriteJP;
	unsigned int (*fs_Write)(void *data, unsigned int len, uint8_t count, void *fd);
} filesystem_device_t;

typedef struct __device_t__ {
	uint8_t header;
	uint8_t flags;
	uint8_t type;
	uint8_t version;
	uint8_t intSource;
	filesystem_device_t *fs;
	// Initialize the device.
	uint8_t initjp;
	uint8_t (*init)(void);
	// De-initialize the device.
	uint8_t deinitjp;
	uint8_t (*deinit)(void);
	// Read from the device. Dest is a physical address, src is a device-side address.
	uint8_t readjp;
	unsigned int (*read)(void *dest, void *src, unsigned int len);
	// Write to the device. Dest is a device-side address, src is a physical address.
	uint8_t writejp;
	unsigned int (*write)(void *dest, void *src, unsigned int len);
	// Return a physical address (DMA) for a given device-side address.
	uint8_t dmajp;
	void *(*getdma)(void *src);
	// Called by the OS to handle interrupts this device responds to.
	uint8_t interrupthandlerjp;
	uint8_t (*interruptHandler)(void);
} device_t;


/**
 * Initialize a device and return its device_t structure.
 * @param path Path to device file.
 * @return Device structure, or -1 if failed.
 */
device_t sys_OpenDevice(const char *path);

/**
 * Execute a given file, not preserving current program state.
 * @param path Path to file to execute.
 * @param args Pointer to arguments string.
 * @note Only call this if your program runs from flash or if calling a flash executable \
that doesn't clobber usermem or run ram executables, otherwise unexpected behaviour may result.
 */
int sys_ExecuteFile(const char *path, char *args);

/**
 * Get OS info/version string.
 * @return OS info/version string.
 */
const char *os_GetOSInfo(void);

/**
 * Open a file, returning a pointer to it's file descriptor.
 * @param path Path to file.
 * @return Pointer to file descriptor.
 */
void *fs_OpenFile(const char *path);

/**
 * Get pointer to file data given a file descriptor
 * @param fd File descriptor.
 * @return Pointer to file data, or -1 if failed.
 */
void *fs_GetFDPtr(const void *fd);

/**
 * Get length of file data given a file descriptor
 * @param fd File descriptor.
 * @return Length of file data.
 */
unsigned int fs_GetFDLen(const void *fd);

/**
 * Get the memory address of a given filesystem sector.
 * @param sector Filesystem sector number.
 * @return Pointer to filesystem sector.
 * @note This routine only uses the low 16 bits of sector.
 */
void *fs_GetSectorAddress(int sector);

/**
 * Check if a directory exists and is a directory.
 * @param path Path to directory to check.
 * @return True if path exists and is a directory.
 */
bool fs_CheckDirExists(const char *path);

/**
 * Get a pointer to the file name of a path.
 * @param path Path to get file name from.
 * @return Pointer to file name.
 * @note Basically the same as python's os.path.basename(path).
 */
char *fs_BaseName(const char *path);

/**
 * Copy a file name from a file descriptor.
 * @param fd File descriptor to read file name from.
 * @return Pointer to file name.
 */
char *fs_CopyFileName(void *fd);

/**
 * Read bytes from a file.
 * @param data Pointer to buffer to read into.
 * @param len Length of data to read.
 * @param count Number of lengths to read.
 * @param fd File descriptor to read from.
 * @param offset Offset of file to read data from.
 * @note reads len*count bytes.
 */
unsigned int fs_Read(void *data, size_t len, uint8_t count, void *fd, unsigned int offset);

/**
 * Write bytes to a file.
 * @param data Pointer to data to write to file.
 * @param len Length of data to write.
 * @param count Number of lengths to write.
 * @param fd File descriptor to write to.
 * @param offset Offset of file to write data to.
 * @return New file descriptor, or -1 if failed.
 * @note writes len*count bytes from data.
 */
void *fs_Write(void *data, size_t len, uint8_t count, void *fd, unsigned int offset);

/**
 * Write bytes to a file without reallocating the file.
 * @param data Pointer to data to write to file.
 * @param len Length of data to write.
 * @param count Number of lengths to write.
 * @param fd File descriptor to write to.
 * @param offset Offset of file to write data to.
 * @return New file descriptor, or -1 if failed.
 * @note Only the amount of bytes allocated to the file can be written, this routine fails otherwise.
 *       This routine will also fail if the data can't be written correctly. (ANDed with existing data)
 */
void *fs_WriteRaw(void *data, size_t len, uint8_t count, void *fd, unsigned int offset);
#define fs_WriteDirectly fs_WriteRaw


/**
 * Scan the keypad, checking if a key was pressed.
 * @return True if a key was pressed.
 */
bool sys_AnyKey(void);

/**
 * Free all malloc'd memory.
 * @note Chances are you shouldn't call this.
 */
void sys_FreeAll(void);

/**
 * Check how much RAM is available to Malloc.
 * @return Amount of free Malloc RAM in bytes.
 */
int sys_CheckMallocRAM(void);

/**
 * Scan the keypad and return a scan code.
 * @return Scan code of pressed key. 0 if no keys pressed.
 */
uint8_t sys_GetKey(void);

/**
 * Scan the keypad, updating keypad registers.
 */
void sys_KbScan(void);

/**
 * Allocate memory.
 * @param bytes Number of bytes to allocate.
 * @return Pointer to allocated memory. 0 if failed to malloc.
 */
void *sys_Malloc(unsigned int bytes);

/**
 * Allocate persistent memory.
 * @param bytes Number of bytes to allocate persistently.
 * @return Pointer to persistent allocated memory. 0 if failed to malloc.
 */
void *MallocPersistent(unsigned int bytes);

/**
 * Wait until a key is pressed and return a scan code.
 * @return Scan code of pressed key.
 */
uint8_t sys_WaitKey(void);

/**
 * Wait until a key is pressed and released, returning a scan code.
 * @return Scan code of pressed key.
 */
uint8_t sys_WaitKeyCycle(void);

/**
 * Get user input.
 * @param buffer Pointer to input buffer.
 * @param len Length of input buffer - 1.
 * @return 0 if user exit, 1 if user enter, 9/12 if user presses down/up arrow key.
 */
uint8_t gui_Input(char *buffer, unsigned int len);

/**
 * Clear the screen and print a line.
 */
void gui_DrawConsoleWindow(const char *str);

/**
 * Print a string to the screen advancing the current draw collumn, but not advancing the current line.
 * @param str Pointer to string to print.
 */
void gui_Print(const char *str);

/**
 * Print a character to the screen, advancing the current draw collumn.
 * @param str Pointer to string to print.
 */
void gui_PrintChar(const char *str);

/**
 * Print a string to the screen and advance the current draw line.
 * @param str Pointer to string to print.
 */
void gui_PrintLine(const char *str);

/**
 * Print an integer to the screen and advance the current draw collumn.
 * @param num integer to print.
 */
void gui_PrintInt(int num);

/**
 * Blit the back buffer to the LCD.
 */
void bosgfx_BlitBuffer(void);

/**
 * Print a string to the current text draw position.
 * @param str Pointer to string to print.
 */
void bosgfx_PrintString(const char *str);

/**
 * Print a string at x,y.
 * @param str Pointer to string to print.
 * @param x X coordinate to print at.
 * @param y Y coordinate to print at.
 */
void bosgfx_PrintStringXY(const char *str, int x, uint8_t y);

/**
 * Set the text draw position to collumn, row
 * @param collumn zero indexed collumn number.
 * @param row zero indexed row number.
 */
void bosgfx_SetTextPos(uint8_t collumn, uint8_t row);

/**
 * Set the text foreground color.
 * @param color 8bpp color byte.
 * @return old color.
 */
uint8_t bosgfx_SetTextFGColor(uint8_t color);

/**
 * Set the text background color.
 * @param color 8bpp color byte.
 * @return old color.
 */
uint8_t bosgfx_SetTextBGColor(uint8_t color);


/**
 * Scan the keypad and return a scan code.
 * @return Scan code of pressed key. 0 if no key pressed.
 */
uint8_t _GetCSC(void);

/**
 * Set text draw to next line, zero collumn, scrolling if necessary.
 */
void _NewLine(void);

/**
 * Clear the LCD.
 */
void _ClrScrn(void);

/**
 * Zero the text draw position.
 */
void _HomeUp(void);

/**
 * Print a memory error.
 */
void _ErrMemory(void);

/**
 * Draw the status bar.
 * @note Does absolutely nothing at the moment.
 */
void _DrawStatusBar(void);

/**
 * Get OS info/version string.
 * @return pointer to OS info/version string
 */
const char *_os_GetSystemInfo(void);

/**
 * Included for compatibility with usbdrvce.
 */
void _UsbPowerVbus(void);

/**
 * Included for compatibility with usbdrvce.
 */
void _UsbUnpowerVbus(void);

/**
 * Unlock flash if flash is locked.
 */
void sys_FlashUnlock(void);

/**
 * Lock flash unless flash is set to stay unlocked.
 */
void sys_FlashLock(void);

/**
 * Create a file.
 * @param path Path to file to be created.
 * @param flags File attribute byte.
 * @param len Length to allocate for new file.
 * @return New file descriptor, or 0 if failed.
 */
void *fs_CreateFile(const char *path, uint8_t flags, unsigned int len);

/**
 * Create a file in ram.
 * @param path Path to file to be created.
 * @param flags File attribute byte.
 * @param ptr pointer to file data.
 * @param len Length of file data.
 * @return New file descriptor, or 0 if failed.
 * @note File data in ram must be 32-bit aligned.
 */
void *fs_CreateRamFile(const char *path, uint8_t flags, void *ptr, unsigned int len);

/**
 * Allocate ram in usermem
 * @param len number of bytes to allocate.
 * @return pointer to memory, or -1 if failed.
 * @note If success, the returned data will be 32-bit aligned.
 */
void *fs_AllocRam(unsigned int len);

/**
 * Convert OP1 into a BOS file name and return it.
 * @return BOS file name.
 */
char *_OP1ToPath(void);

/**
 * Copy into OP1 and convert into a BOS file name.
 * @param name Variable name.
 * @param type Variable type.
 * @return BOS file name.
 */
char *TIVarToPath(const char *name, const uint8_t type);

/**
 * Get the absolute path of argument.
 * @param path Path to get absolute version of.
 * @return Absolute path. -1 if failed.
 * @note This basically joins the current working directory with the argument unless \
it is already an absolute path.
 */
char *fs_AbsPath(const char *path);

/**
 * Join paths p1 and p2.
 * @param p1 String representing a filesystem path.
 * @param p2 String representing a filesystem path.
 * @return Joined path.
 */
char *fs_JoinPath(const char *p1, const char *p2);

/**
 * Open a file within a given directory.
 * @param path Path within directory to open.
 * @param dir File descriptor of directory to search in.
 */
void *fs_OpenFileInDir(char *path, void *dir);

/**
 * Set the size of a given file.
 * @param len New size for file.
 * @param fd File descriptor of file to set size of.
 * @return New file descriptor, or -1 if failed.
 */
void *fs_SetSize(int len, void *fd);

/**
 * Overwrite file contents.
 * @param data Pointer to data to write to file.
 * @param len Length of data to write.
 * @param count Multiplied by len to get actual write length.
 * @param fd File descriptor to write to.
 * @param offset File offset to write to.
 * @return New file descriptor, or -1 if failed.
 */
void *fs_WriteFile(void *data, unsigned int len, uint8_t count, void *fd, unsigned int offset);

/**
 * Delete a file / directory.
 * @param path Path to file to be deleted.
 * @return true if success, false if failed.
 */
bool fs_DeleteFile(const char *path);

/**
 * Get user input.
 * @param buffer Pointer to input buffer.
 * @param len Length of input buffer - 1.
 * @return Pointer to input buffer.
 */
char *gui_InputNoClear(char *buffer, unsigned int len);

/**
 * [re]Initialize filesystem cluster map / clean filesystem
 * @note You probably won't need to call this.
 */
void fs_InitClusterMap(void);

/**
 * Get the parent directory of a given path.
 * @param path Path to get parent of.
 * @return Parent directory of path.
 */
char *fs_ParentDir(const char *path);

/**
 * Convert an 8.3 file name string to a file entry.
 * @param dest Buffer to write entry to.
 * @param name File name to convert.
 * @return Pointer to dest.
 * @note dest should be allocated at least 16 bytes.
 */
char *fs_StrToFileEntry(char *dest, const char *name);

/**
 * List items in a given directory.
 * @param buffer Pointer to buffer to write file descriptors to.
 * @param path Path of directory to list.
 * @param num Number of entries to list.
 * @param skip Number of entries to skip.
 * @return Number of entries read into buffer
 * @note buffer should be allocated at least 3*num bytes.
 */
unsigned int fs_DirList(void **buffer, const char *path, unsigned int num, unsigned int skip);

/**
 * Check how much space is free in the filesystem.
 * @return Number of bytes free.
 */
int fs_GetFreeSpace(void);

/**
 * Free memory allocated by sys_Malloc.
 * @param ptr Pointer to memory to free.
 */
void sys_Free(void *ptr);

/**
 * Initialize a device.
 * @param path Path to device file.
 * @return File descriptor.
 */
void *sys_InitDevice(const char *path);

/**
 * Deinitialize a device.
 * @param fd Pointer to file descriptor.
 */
int sys_DeinitDevice(void *fd);

/**
 * Not yet documented.
 */
void *sys_GetDeviceAddress(void *dest, void *src, size_t len, void *fd);

/**
 * Read bytes from a device.
 * @param dest Destination to read bytes into.
 * @param src Source to read bytes from.
 * @param len Number of bytes to read.
 * @param fd Pointer to device file descriptor.
 */
int sys_ReadDevice(void *dest, void *src, size_t len, void *fd);

/**
 * Write bytes to a device.
 * @param dest Destination to write bytes to.
 * @param src Source to read bytes from.
 * @param len Number of bytes to write.
 * @param fd Pointer to device file descriptor.
 */
int sys_WriteDevice(void *dest, void *src, size_t len, void *fd);

/**
 * Get the filesystem sector a given address lies within.
 * @param address Address to check.
 * @return Filesystem sector containing Address.
 */
int fs_GetSector(void *address);

/**
 * Write a byte to a file.
 * @param byte Byte to write to file.
 * @param fd Pointer to file descriptor.
 * @param offset File offset to write to.
 * @return New file descriptor, or -1 if failed.
 */
void *fs_WriteByte(uint8_t byte, void *fd, int offset);

/**
 * Rename a file.
 * @param directory Path to parent directory of file to be renamed.
 * @param old_name Old file name.
 * @param new_name New file name.
 * @return New file descriptor, or 0 if failed.
 */
void *fs_RenameFile(const char *directory, const char *old_name, const char *new_name);

/**
 * Rename/move a file.
 * @param old_name Old file path.
 * @param new_name New file path.
 * @return New file descriptor, or 0 if failed.
 */
void *fs_Rename(const char *old_name, const char *new_name);

/**
 * Create a directory.
 * @param path Path to file to create.
 * @param flags File properties byte.
 * @return New file descriptor, or -1 if failed.
 * @note flags byte should have fsbit_subdir set.
 */
void *fs_CreateDir(const char *path, uint8_t flags);

/**
 * Run a sanity check on the filesystem.
 */
void fs_SanityCheck(void);

/**
 * Get a pointer to a given file's data section.
 * @param path Path to file.
 * @return Pointer to file data section.
 */
void *fs_GetFilePtr(const char *path);

/**
 * Clear LCD buffer.
 */
void bosgfx_BufClear(void);

/**
 * Clear the LCD.
 */
void bosgfx_LcdClear(void);

/**
 * Swap text 1 and 2 colors.
 */
void bosgfx_SwapTextColors(void);

/**
 * Set Font to a provided data pointer.
 * @param data Pointer to new font data.
 * @return Pointer to old font data.
 * @note font data structure: uint8_t num_bitmaps, uint8_t spacing[], uint8_t data[]
 */
void *bosgfx_SetFont(void *data);

/**
 * Set Font to default
 */
void bosgfx_SetDefaultFont(void);

/**
 * Set the OS gfx/gui draw location.
 * @param loc 0 draws from vRam, 1 draws from vRam buffer
 */
void bosgfx_SetDraw(uint8_t loc);

/**
 * Turn off the calculator until the user presses the [ON] key
 */
void sys_TurnOff(void);

/**
 * Execute a file given a pointer to its data section.
 * @param ptr Pointer to file data section.
 * @param args Pointer to arguments string to be passed to the program.
 * @return Program exit code.
 */
int sys_ExecuteFileFromPtr(void *ptr, char *args);

/**
 * Increments current process/program ID.
 */
void sys_NextProcessId(void);

/**
 * Decrements current process/program ID.
 */
void sys_PrevProcessId(void);

/**
 * Free memory used by a given process/program ID.
 * @note Try not to use this on id 1.
 */
void sys_FreeProcessId(uint8_t id);

/**
 * Free memory used by the current process/program ID.
 * @note this frees all memory malloc'd by the program.
 */
void sys_FreeRunningProcessId(void);


/**
 * Do a garbage collect.
 */
void fs_GarbageCollect(void);

/**
 * Create a new file and write contents to it.
 * @param path Pointer to file path.
 * @param properties File attribute byte.
 * @param data Pointer to data to be written to the file.
 * @param len Length of data to be written to the file.
 * @return New file descriptor, or -1 if failed.
 */
void *fs_WriteNewFile(const char *path, uint8_t properties, void *data, int len);

/**
 * Decompress a block of zx7-compressed memory.
 * @param dest Pointer to write to.
 * @param src Pointer to compressed data.
 * @return pointer to byte following last byte written to dest.
 */
void *util_Zx7Decompress(void *dest, void *src);


/**
 * Open a file, searching in directories listed within another file.
 * @param path Path to search for.
 * @param var Name of file containing directories to search in.
 * @return pointer to file descriptor.
 */
void *sys_OpenFileInVar(const char *path, const char *var);


/**
 * Create a thread to be run the next time a thread switch is triggered.
 * @param pc Routine to run as a thread.
 * @param sp Pointer to initial routine stack pointer. (Note that the stack grows downwards,
 *           so you should pass the end of the memory you pass in.)
 * @return Thread ID or 0 if failed.
 * @note sp must be able to safely grow at least 12 bytes.
 *       If null is passed, the same sp as the caller will be used, which may produce unexpected results.
 */
uint8_t th_CreateThread(void (*pc)(int, char**), void *sp, int argc, char **argv);

/**
 * Kill a thread by ID.
 * @param id Thread ID to kill.
 * @return Thread ID killed if success, otherwise 0.
 */
uint8_t th_KillThread(uint8_t id);

/**
 * Handle the next available thread, continuing from here if there are no other threads to handle,
 * or once all other threads have been handled.
 */
inline void th_HandleNextThread(void) {asm("rst $10\npop bc");};

/**
 * End the currently running thread.
 */
inline void th_EndThread(void) {asm("rst $10\nret");};

/**
 * Sleep the currently running thread.
 */
inline void th_SleepThread(void) {asm("rst $10\nhalt");};


#endif
