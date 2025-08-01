
#ifndef __BOS_H__
#define __BOS_H__

#include <stdint.h>
#include <stdbool.h>

typedef struct __device_t__ {
	uint8_t header;
	uint8_t flags;
	uint8_t type;
	uint8_t version;
	uint8_t intSource;
	uint8_t fsdevflags;
	uint16_t version_minor;
	// Generic device jump table
	// Initialize the device.
	uint8_t initJP;
	uint8_t (*init)(void);
	// De-initialize the device.
	uint8_t deinitJP;
	uint8_t (*deinit)(void);
	// Read from the device. Dest is a physical address, src is a device-side address.
	uint8_t readJP;
	unsigned int (*read)(void *dest, void *src, unsigned int len);
	// Write to the device. Dest is a device-side address, src is a physical address.
	uint8_t writeJP;
	unsigned int (*write)(void *dest, void *src, unsigned int len);
	// Return a physical address (DMA) for a given device-side address.
	uint8_t dmaJP;
	void *(*getdma)(void *src);
	// Called by the OS to handle interrupts this device responds to.
	uint8_t interrupthandlerJP;
	uint8_t (*interruptHandler)(void);

	// Filesystem device jump table
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

} device_t;

/**
 * --- Stateful file I/O functions ---
 * Note: When opening a "device" file, these functions will use callbacks defined in the device file for read/write/data/etc operations.
 */

/**
 * Open a file, returning a file handle.
 * @param path Path to file.
 * @param mode File open mode. "r" -> read, "w" -> write, "r+" -> read+write, "w+" -> write+read.
 * @return file handle, otherwise 0.
 */
void **fsd_OpenFile(const char *path, const char* mode);

/**
 * Close a file handle, writing data to flash if opened as writeable and data is in ram.
 * @param fd file handle.
 */
void fsd_Close(void** fd);

/**
 * Write a file to archive. (flash)
 * @param fd file handle.
 */
void fsd_Archive(void** fd);

/**
 * Write a file to ram.
 * @param fd file handle.
 */
void fsd_UnArchive(void** fd);

/**
 * Check if a file is open, returning the first open handle if it is.
 * @param path file path.
 * @return file handle, otherwise 0.
 */
void** fsd_CheckOpen(const char* path);

/**
 * Check if a file is open, returning the first open handle if it is.
 * @param fd file descriptor. (*filesystem* file descriptor)
 * @return file handle, otherwise 0.
 */
void** fsd_CheckOpenFD(void** fd);

/**
 * Close all open files.
 */
void fsd_CloseAll();

/**
 * Close a file without writing data to flash.
 * @param fd file handle.
 */
void fsd_ForceClose(void** fd);

/**
 * Return a pointer to the data of an open file handle.
 * @param fd file handle.
 * @return pointer to data, 0 if failed.
 */
void* fsd_GetDataPtr(void** fd);

/**
 * Return the size of the data of an open file.
 * @param fd file handle.
 * @return file handle, otherwise 0.
 */
size_t fsd_GetSize(void** fd);


/**
 * Check if a file is in RAM or Flash.
 * @param fd file handle.
 * @return true if in RAM, false if in Flash (filesystem)
 */
bool fsd_InRam(void** fd);

/**
 * Read data from a file handle.
 * @param ptr buffer to read into.
 * @param len length to read per section.
 * @param count number of sections to read.
 * @param fd file handle.
 * @return number of sections read.
 */
size_t fsd_Read(void* ptr, size_t len, size_t count, void** fd);

/**
 * Write data to a file handle.
 * @param ptr buffer to write from.
 * @param len length to write per section.
 * @param count number of sections to write.
 * @param fd file handle.
 * @return number of sections written.
 */
size_t fsd_Write(void* ptr, size_t len, size_t count, void** fd);

/**
 * Write a data string to a file handle, not including the null terminator.
 * @param str string to write.
 * @param fd file handle.
 * @return number of bytes written.
 */
size_t fsd_WriteStr(const char* str, void** fd);

/**
 * Resize a file handle.
 * @param len new file size in bytes.
 * @param fd file handle.
 * @return new file size in bytes, or 0 if failed.
 */
size_t fsd_Resize(size_t len, void** fd);

/**
 * Seek the read/write offset of a file handle.
 * @param offset offset to seek to.
 * @param whence where to start from: 0 -> from start, 1 -> from current, 2 -> from end.
 */
void fsd_Seek(int len, void** fd);

/**
 * Return the read/write offset of a file handle.
 * @param fd file handle.
 * @return read/write offset, or 0 if failed.
 */
size_t fsd_Tell(void** fd);



/**
 * --- Filesystem functions ---
 * Note: these functions read/write directly to the filesystem and do not keep a state.
 * Use the handle-based "fsd" functions if you need to keep state such as a read/write offset
 * and direct memory access.
 */

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
 * @note this routine allocates memory
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
 * Check if a given block of flash memory can be allocated.
 * @param len number of bytes to check for.
 * @return sector number that would be allocated, or -1 if failed.
 */
unsigned int fs_AllocChk(unsigned int len);

/**
 * Allocate ram in usermem following the executing program.
 * @param len number of bytes to allocate.
 * @return pointer to memory, or 0 if failed.
 * @note Use sys_AllocHeap instead; this is for allocating files in ram.
 */
void* fs_AllocRam(size_t len);

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
 * @note You probably don't need to call this.
 */
void fs_SanityCheck(void);

/**
 * Get a pointer to a given file's data section.
 * @param path Path to file.
 * @return Pointer to file data section.
 */
void *fs_GetFilePtr(const char *path);

/**
 * [re]Initialize filesystem cluster map / clean filesystem
 * @note You probably don't need to call this.
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
size_t fs_GetFreeSpace(void);

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
 * --- Device file functions ---
 */

/**
 * Return a pointer to a device structure.
 * @param path Path to device file.
 * @return Device structure, or -1 if failed. (or if file is not a valid device file)
 */
device_t* drv_OpenDevice(const char* path);

/**
 * Return a pointer to a device structure given a file descriptor.
 * @param fd File Descriptor.
 * @return Device structure, or -1 if failed. (or if file is not a valid device file)
 */
device_t* drv_OpenDeviceFD(void* fd);

/**
 * Initialize a device given a device structure.
 * @param ptr Device file data / device structure.
 * @return Depends on device, usually non-zero if failed.
 */
int drv_InitDevice(device_t* ptr);

/**
 * Return a pointer to a device's physical memory address, if applicable.
 * @param ptr Device file data / device structure.
 * @return Pointer to physical memory address, 0 if N/A.
 */
void* drv_GetDMA(device_t* ptr);

/**
 * Read a character from a device.
 * @param ptr Device file data / device structure.
 * @return Character read.
 */
int drv_GetChar(device_t* ptr);

/**
 * Write a character to a device.
 * @param ptr Device file data / device structure.
 * @param c Character to write.
 * @return Depends on device, usually number of bytes written.
 */
int drv_PutChar(device_t* ptr, int c);

/**
 * Read some data from a device.
 * @param ptr Device file data / device structure.
 * @param buffer Pointer to buffer to read data into.
 * @param len Number of bytes to read.
 * @param offset Offset to read data from.
 * @return Depends on device, usually number of bytes read.
 */
int drv_Read(device_t* ptr, void* buffer, size_t len, size_t offset);

/**
 * Write some data to a device.
 * @param ptr Device file data / device structure.
 * @param buffer Pointer to data to write.
 * @param len Number of bytes to write.
 * @param offset Offset to write data to.
 * @return Depends on device, usually number of bytes written.
 */
int drv_Write(device_t* ptr, void* buffer, size_t len, size_t offset);

/**
 * Uninitialize a device.
 * @param ptr Device file data / device structure.
 * @return Depends on device, usually non-zero if failed.
 */
int drv_Deinit(device_t* ptr);



/**
 * --- User interface, graphics and input functions ---
 */

/**
 * Scan the keypad, checking if a key was pressed.
 * @return True if a key was pressed.
 */
bool sys_AnyKey(void);

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
 * Get user input.
 * @param buffer Pointer to input buffer.
 * @param len Length of input buffer - 1.
 * @return Pointer to input buffer.
 */
char *gui_InputNoClear(char *buffer, unsigned int len);

/**
 * Convert a keycode from sys_GetKey to a text character.
 * @param charset character set number to pick from.
 * @param keycode keycode from sys_GetKey or similar.
 * @return character corresponding to the given charset and keycode; 0 if out of bounds or N/A.
 */
char gui_CharFromCode(uint8_t charset, uint8_t keycode);

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
 * Print a character to the screen advancing the current draw position.
 * @param c character to print.
 */
void gui_PrintChar(char c);

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
 * --- Misc system functions ---
 */

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
 * Free all malloc'd memory.
 * @note Chances are you shouldn't call this.
 */
void sys_FreeAll(void);

/**
 * Free memory allocated by sys_Malloc.
 * @param ptr Pointer to memory to free.
 */
void sys_Free(void *ptr);

/**
 * Check how much RAM is available to Malloc.
 * @return Amount of free Malloc RAM in bytes.
 */
int sys_CheckMallocRAM(void);

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
void *sys_MallocPersistent(unsigned int bytes);

/**
 * Set a routine to be called when the on key is pressed.
 * @param handler Routine to be called when the on key is pressed.
 * @return Pointer to old routine.
 */
void *sys_SetOnInterruptHandler(void (*handler)(void));

/**
 * Allocate ram in usermem following the executing program, updating asm_prgm_size.
 * @param len number of bytes to allocate.
 * @return pointer to memory, or 0 if failed.
 */
void* sys_AllocHeap(size_t len);

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
 * Open a file, searching in directories listed within another file.
 * @param path Path to search for.
 * @param var Name of file containing directories to search in.
 * @return pointer to file descriptor.
 */
void *sys_OpenFileInVar(const char *path, const char *var);



/**
 * --- Utility functions ---
 */

/**
 * Decompress a block of zx7-compressed memory.
 * @param dest Pointer to write to.
 * @param src Pointer to compressed data.
 * @return pointer to byte following last byte written to dest.
 */
void *util_Zx7Decompress(void *dest, void *src);

/**
 * Decompress a block of zx0-compressed memory.
 * @param dest Pointer to write to.
 * @param src Pointer to compressed data.
 * @return pointer to byte following last byte written to dest.
 */
void *util_Zx0Decompress(void *dest, void *src);

/**
 * Compress a block memory using zx7.
 * @param dest Pointer to write compressed data to.
 * @param src Pointer to data.
 * @param len Number of bytes to compress.
 * @param progress_callback callback function to indicate progress to the user.
 * @return Number of bytes written.
 * @note NOT YET FUNCTIONAL.
 */
//int util_Zx7Compress(void *dest, void *src, int len, void (*progress_callback)(int src_offset));

/**
 * Relocate code in data offsetting 24-bit values (offsets of data) by origin_delta.
 * @param data Code/data to be relocated.
 * @param offsets Pointer to offsets of data needing to be offset.
 * @param origin_delta Value to offset by.
 * @note relocates data in place. Data MUST be stored in RAM, otherwise this will crash. @p offsets should be terminated by 0xffffff.
 */
void util_Relocate(void *data, unsigned int *offsets, int origin_delta);

/** 
 * Compute a SHA256 hash for a block of data
 * @param buffer 32-byte buffer to write hash to.
 * @param data Pointer to data to hash.
 * @param len Number of bytes to hash.
 * @note UNTESTED; USES SHA256 HARDWARE.
 */
void util_SHA256(void* buffer, void* data, unsigned int len);



/**
 * --- Compatibility functions ---
 */

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
 * Convert OP1 into a BOS file name and return it.
 * @return BOS file name.
 */
char *_OP1ToPath(void);



/**
 * --- co-operative multitasking functions ---
 * Note: incomplete and not yet functional.
 */

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
