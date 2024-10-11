
# common/os specific things copied from CE toolchain /meta/makefile.mk
ifeq ($(OS),Windows_NT)
SHELL      = cmd.exe
NATIVEPATH = $(subst /,\,$1)
DIRNAME    = $(filter-out %:,$(patsubst %\,%,$(dir $1)))
RM         = del /f 2>nul
RMDIR      = call && (if exist $1 rmdir /s /q $1)
MKDIR      = call && (if not exist $1 mkdir $1)
PREFIX    ?= C:
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = copy /y
EXMPL_DIR  = $(call NATIVEPATH,$(INSTALLLOC)/CEdev/examples)
CPDIR      = xcopy /e /i /q /r /y /b
CP_EXMPLS  = $(call MKDIR,$(EXMPL_DIR)) && $(CPDIR) $(call NATIVEPATH,$(CURDIR)/examples) $(EXMPL_DIR)
ARCH       = $(call MKDIR,release) && cd tools\installer && ISCC.exe /DAPP_VERSION=8.4 /DDIST_PATH=$(call NATIVEPATH,$(DESTDIR)$(PREFIX)/CEdev) installer.iss && \
             cd ..\.. && move /y tools\installer\CEdev.exe release\\
QUOTE_ARG  = "$(subst ",',$1)"#'
APPEND     = @echo.$(subst ",^",$(subst \,^\,$(subst &,^&,$(subst |,^|,$(subst >,^>,$(subst <,^<,$(subst ^,^^,$1))))))) >>$@
else
NATIVEPATH = $(subst \,/,$1)
DIRNAME    = $(patsubst %/,%,$(dir $1))
RM         = rm -f
RMDIR      = rm -rf $1
MKDIR      = mkdir -p $1
PREFIX    ?= $(HOME)
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = cp
CPDIR      = cp -r
CP_EXMPLS  = $(CPDIR) $(call NATIVEPATH,$(CURDIR)/examples) $(call NATIVEPATH,$(INSTALLLOC)/CEdev)
ARCH       = cd $(INSTALLLOC) && tar -czf $(RELEASE_NAME).tar.gz $(RELEASE_NAME) ; \
             cd $(CURDIR) && $(call MKDIR,release) && mv -f $(INSTALLLOC)/$(RELEASE_NAME).tar.gz release
CHMOD      = find $(BIN) -name "*.exe" -exec chmod +x {} \;
QUOTE_ARG  = '$(subst ','\'',$1)'#'
APPEND     = @echo $(call QUOTE_ARG,$1) >>$@
endif

# source: http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html
rwildcard = $(strip $(foreach d,$(wildcard $1/*),$(call rwildcard,$d,$2) $(filter $(subst %%,%,%$(subst *,%,$2)),$d)))

FSOBJ ?= $(call NATIVEPATH,src/data/adrive/obj)
FSSRC ?= $(call NATIVEPATH,src/data/adrive/src)

#build rules

all: objdirs includes noti filesystem bosos bosbin bos8xp bosrom

artifact:
	python buildutil.py artifact

version:
	python buildutil.py version add 0.0.1

version-minor:
	python buildutil.py version add 0.0.100

version-major:
	python buildutil.py version add 0.1.0

# Rule to build OS data
bosos: $(call rwildcard,src,*.asm) $(call rwildcard,src,*.inc)
	fasmg $(call NATIVEPATH,src/main.asm) $(call NATIVEPATH,obj/bosos.bin)

# Rule to build documentation
documentation:
	python build_docs.py

# Rule to build syscall libs (optional)
syslibs: $(call rwildcard,syslib,*.asm)
	python build_syslibs.py
	$(call MKDIR,$(call NATIVEPATH,obj/syslib))
	fasmg syslib/fs.asm obj/syslib/fs.bin
	fasmg syslib/gfx.asm obj/syslib/gfx.bin
	fasmg syslib/gui.asm obj/syslib/gui.bin
	fasmg syslib/os.asm obj/syslib/os.bin
	fasmg syslib/sys.asm obj/syslib/sys.bin
	fasmg syslib/str.asm obj/syslib/str.bin
	fasmg syslib/th.asm obj/syslib/th.bin
	fasmg syslib/util.asm obj/syslib/util.bin
	python add_file_to_rom.py --rom bin/BOSOSInited.rom obj/syslib/fs.bin /sys/fs obj/syslib/gfx.bin /sys/gfx obj/syslib/gui.bin /sys/gui obj/syslib/os.bin /sys/os obj/syslib/str.bin /sys/str obj/syslib/sys.bin /sys/sys obj/syslib/th.bin /sys/th obj/syslib/util.bin /sys/util

# Rule to build include files
includes:
	python build_bos_inc.py
	$(CP) bos.inc $(call NATIVEPATH,src/include)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/include)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/fs/bin/include)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/fs/lib/include)
	fasmg $(call NATIVEPATH,src/data/adrive/osrt.asm) $(call NATIVEPATH,src/data/adrive/osrt.tmp)
	$(CP) $(call NATIVEPATH,src/data/adrive/osrt.inc) $(call NATIVEPATH,src/include/osrt.inc)
	$(CP) $(call NATIVEPATH,src/data/adrive/osrt.inc) $(call NATIVEPATH,$(FSSRC)/include/osrt.inc)
	$(CP) $(call NATIVEPATH,src/data/adrive/osrt.inc) $(call NATIVEPATH,$(FSSRC)/fs/bin/include/osrt.inc)
	$(CP) $(call NATIVEPATH,src/data/adrive/osrt.inc) $(call NATIVEPATH,$(FSSRC)/fs/lib/include/osrt.inc)
	python build_bos_src.py
	python build_bos_internal_inc.py

# Rule to create object and binary directories
objdirs:
	$(call MKDIR,bin)
	$(call MKDIR,obj)
	$(call MKDIR,$(call NATIVEPATH,noti-ez80/bin))
	$(call MKDIR,$(call NATIVEPATH,src/data/adrive/obj))

# LibLoad Library build rules

$(call NATIVEPATH,$(FSOBJ)/libload.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/libload/libload.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/libload/libload.asm) $(call NATIVEPATH,$(FSOBJ)/libload.bin)

$(call NATIVEPATH,$(FSOBJ)/fatdrvce.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/fatdrvce/fatdrvce.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/fatdrvce/fatdrvce.asm) $(call NATIVEPATH,$(FSOBJ)/fatdrvce.bin)

$(call NATIVEPATH,$(FSOBJ)/fileioc.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/fileioc/fileioc.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/fileioc/fileioc.asm) $(call NATIVEPATH,$(FSOBJ)/fileioc.bin)

$(call NATIVEPATH,$(FSOBJ)/fontlibc.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/fontlibc/fontlibc.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/fontlibc/fontlibc.asm) $(call NATIVEPATH,$(FSOBJ)/fontlibc.bin)

$(call NATIVEPATH,$(FSOBJ)/graphx.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/graphx/graphx.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/graphx/graphx.asm) $(call NATIVEPATH,$(FSOBJ)/graphx.bin)

$(call NATIVEPATH,$(FSOBJ)/keypadc.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/keypadc/keypadc.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/keypadc/keypadc.asm) $(call NATIVEPATH,$(FSOBJ)/keypadc.bin)

$(call NATIVEPATH,$(FSOBJ)/msddrvce.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/msddrvce/msddrvce.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/msddrvce/msddrvce.asm) $(call NATIVEPATH,$(FSOBJ)/msddrvce.bin)

$(call NATIVEPATH,$(FSOBJ)/srldrvce.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/srldrvce/srldrvce.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/srldrvce/srldrvce.asm) $(call NATIVEPATH,$(FSOBJ)/srldrvce.bin)

$(call NATIVEPATH,$(FSOBJ)/usbdrvce.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/usbdrvce/usbdrvce.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/usbdrvce/usbdrvce.asm) $(call NATIVEPATH,$(FSOBJ)/usbdrvce.bin)


# OS Files build rules
$(call NATIVEPATH,$(FSOBJ)/explorer.bin): $(call rwildcard,$(call NATIVEPATH,$(FSSRC)/fs/bin/explorer),*.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/explorer.asm) $(call NATIVEPATH,$(FSOBJ)/explorer.bin)

$(call NATIVEPATH,$(FSOBJ)/memedit.bin): $(call NATIVEPATH,$(FSSRC)/fs/bin/memedit.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/bin/memedit.asm) $(call NATIVEPATH,$(FSOBJ)/memedit.bin)

#$(call NATIVEPATH,$(FSOBJ)/cfg.bin): $(call NATIVEPATH,$(FSSRC)/fs/sys/cfg.asm)
#	fasmg $(call NATIVEPATH,$(FSSRC)/fs/sys/cfg.asm) $(call NATIVEPATH,$(FSOBJ)/cfg.bin)
#	convbin -i $(call NATIVEPATH,$(FSOBJ)/cfg.bin) -o $(call NATIVEPATH,$(FSOBJ)/cfg.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/cedit.zx7.bin): $(call rwildcard,$(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/src),*)
	$(Q)make -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/bosbin/CEDIT.bin) -o $(call NATIVEPATH,$(FSOBJ)/cedit.zx7.bin) -j bin -k bin -c zx7

#$(call NATIVEPATH,$(FSOBJ)/edit.zx7.bin): $(call rwildcard,$(call NATIVEPATH,$(FSSRC)/fs/bin/edit/src),*)
#	$(Q)make -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/edit/)
#	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/edit/bosbin/edit.bin) -o $(call NATIVEPATH,$(FSOBJ)/edit.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/msd.zx7.bin): $(call rwildcard,$(call NATIVEPATH,$(FSSRC)/fs/bin/msd/src),*)
	$(Q)make -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/bosbin/MSD.bin) -o $(call NATIVEPATH,$(FSOBJ)/msd.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/serial.zx7.bin): $(call rwildcard,$(call NATIVEPATH,$(FSSRC)/fs/bin/serial/src),*)
	$(Q)make -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/serial/)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/serial/bosbin/serial.bin) -o $(call NATIVEPATH,$(FSOBJ)/serial.zx7.bin) -j bin -k bin -c zx7

# filesystem var build rules
$(call NATIVEPATH,$(FSOBJ)/LIB.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/LIB.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/LIB.asm) $(call NATIVEPATH,$(FSOBJ)/LIB.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/LIB.bin) -o $(call NATIVEPATH,$(FSOBJ)/LIB.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/PATH.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/PATH.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/PATH.asm) $(call NATIVEPATH,$(FSOBJ)/PATH.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/PATH.bin) -o $(call NATIVEPATH,$(FSOBJ)/PATH.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/TIVARS.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/TIVARS.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/TIVARS.asm) $(call NATIVEPATH,$(FSOBJ)/TIVARS.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/TIVARS.bin) -o $(call NATIVEPATH,$(FSOBJ)/TIVARS.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSOBJ)/SYSCALLS.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/SYSCALLS.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/SYSCALLS.asm) $(call NATIVEPATH,$(FSOBJ)/SYSCALLS.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/SYSCALLS.bin) -o $(call NATIVEPATH,$(FSOBJ)/SYSCALLS.zx7.bin) -j bin -k bin -c zx7

# Rule to build Filesytem and compress it
filesystem: $(call rwildcard,$(call NATIVEPATH,$(FSSRC)),*) $(call NATIVEPATH,$(FSOBJ)/libload.bin) $(call NATIVEPATH,$(FSOBJ)/fontlibc.bin) \
$(call NATIVEPATH,$(FSOBJ)/fatdrvce.bin) $(call NATIVEPATH,$(FSOBJ)/fileioc.bin) $(call NATIVEPATH,$(FSOBJ)/graphx.bin) \
$(call NATIVEPATH,$(FSOBJ)/keypadc.bin) $(call NATIVEPATH,$(FSOBJ)/msddrvce.bin) $(call NATIVEPATH,$(FSOBJ)/srldrvce.bin) \
$(call NATIVEPATH,$(FSOBJ)/usbdrvce.bin) $(call NATIVEPATH,$(FSOBJ)/memedit.bin) $(call NATIVEPATH,$(FSOBJ)/cedit.zx7.bin) \
$(call NATIVEPATH,$(FSOBJ)/LIB.bin) $(call NATIVEPATH,$(FSOBJ)/msd.zx7.bin) \
$(call NATIVEPATH,$(FSOBJ)/serial.zx7.bin) $(call NATIVEPATH,$(FSOBJ)/PATH.bin) \
$(call NATIVEPATH,$(FSOBJ)/TIVARS.bin) $(call NATIVEPATH,$(FSOBJ)/SYSCALLS.bin) $(call NATIVEPATH,$(FSOBJ)/explorer.bin)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/etc/fontlibc/DrMono.dat) -o $(call NATIVEPATH,$(FSOBJ)/DrMono.zx7.dat) -j bin -k bin -c zx7
	fasmg $(call NATIVEPATH,$(FSSRC)/main.asm) $(call NATIVEPATH,src/data/adrive/main.bin)
	convbin -i $(call NATIVEPATH,src/data/adrive/main.bin) -o $(call NATIVEPATH,src/data/adrive/data.bin) -j bin -k bin -c zx7
	convbin -i $(call NATIVEPATH,src/data/adrive/data.bin) -o $(call NATIVEPATH,bin/BOSOSpt2.8xv) -j bin -k 8xv -n BOSOSpt2
	$(CP) $(call NATIVEPATH,src/data/adrive/data.bin) $(call NATIVEPATH,bin/BOSOSPT2.BIN)

# Rule to build noti-ez80 submodule required for standalone ROM image
noti: $(call NATIVEPATH,noti-ez80/bin/NOTI.rom)

$(call NATIVEPATH,noti-ez80/bin/NOTI.rom): $(call rwildcard,$(call NATIVEPATH,noti-ez80/src),*)
	$(Q)make autostart -f makefile -C $(call NATIVEPATH,noti-ez80/)

# Rule to build Updater binary
bosbin:
	fasmg $(call NATIVEPATH,src/updater.asm) $(call NATIVEPATH,bin/BOSUPDTR.BIN)

# Rule to build Installer 8xp
bos8xp:
	fasmg $(call NATIVEPATH,src/installer8xp.asm) $(call NATIVEPATH,bin/BOSOS.8xp)

# Rule to build ROM image
bosrom: $(call NATIVEPATH,noti-ez80/bin/NOTI.rom)
	fasmg $(call NATIVEPATH,src/rom.asm) $(call NATIVEPATH,bin/BOSOS.rom)

# Rule to clean noti-ez80 submodule
clean-noti:
	$(Q)make clean -f makefile -C $(call NATIVEPATH,noti-ez80/)

# Rule to clean cedit submodule
clean-cedit:
	$(Q)make clean -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	$(Q)echo Removed CEdit objects and binaries.

# Rule to clean edit submodule
clean-edit:
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/edit/)
	$(Q)echo Removed Edit objects and binaries.

# Rule to clean msd program
clean-msd:
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	$(Q)echo Removed msd objects and binaries.

# Rule to clean serial program
clean-serial:
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/serial/)
	$(Q)echo Removed serial objects and binaries.

clean-libs:
	$(RM) $(call NATIVEPATH,$(FSOBJ)/libload.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/fontlibc.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/fatdrvce.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/fileioc.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/graphx.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/keypadc.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/msddrvce.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/srldrvce.bin)
	$(RM) $(call NATIVEPATH,$(FSOBJ)/usbdrvce.bin)

#make clean
clean:
	$(call RMDIR,bin)
	$(call RMDIR,obj)
	$(call RMDIR,$(call NATIVEPATH,src/data/adrive/obj))
	$(RM) $(call NATIVEPATH,src/data/adrive/data.bin)
	$(RM) $(call NATIVEPATH,src/data/adrive/main.bin)
	$(Q)make clean -f makefile -C $(call NATIVEPATH,noti-ez80/)
	$(Q)make clean -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	$(Q)make clean -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/edit/)
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/serial/)
	$(Q)echo Removed objects and binaries.
