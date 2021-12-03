
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

FSOBJ ?= $(call NATIVEPATH,src/data/adrive/obj)
FSSRC ?= $(call NATIVEPATH,src/data/adrive/src)

#build rules

all: objdirs include_dirs filesystem bosos bosbin bos8xp bosrom

# Rule to build OS data
bosos:
	fasmg $(call NATIVEPATH,src/main.asm) $(call NATIVEPATH,obj/bosos.bin)

# Rule to build documentation
documentation:
	python build_docs.py

# Rule to build include files
includes:
	python build_bos_inc.py
	python build_bos_src.py

# Rule to create object and binary directories
objdirs:
	$(call MKDIR,bin)
	$(call MKDIR,obj)
	$(call MKDIR,$(call NATIVEPATH,noti-ez80/bin))
	$(call MKDIR,$(call NATIVEPATH,src/data/adrive/obj))

include_dirs: includes
	$(CP) bos.inc $(call NATIVEPATH,src/include/bos.inc)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/include)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/fs/bin/include)
	$(CPDIR) $(call NATIVEPATH,src/include) $(call NATIVEPATH,$(FSSRC)/fs/lib/include)


# LibLoad Library build rules

$(call NATIVEPATH,$(FSOBJ)/libload.bin): $(call NATIVEPATH,$(FSSRC)/fs/lib/libload/bos_libload.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/lib/libload/bos_libload.asm) $(call NATIVEPATH,$(FSOBJ)/libload.bin)

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
$(call NATIVEPATH,$(FSOBJ)/explorer.bin): $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/explorer.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/explorer.asm) $(call NATIVEPATH,$(FSOBJ)/explorer.bin)

$(call NATIVEPATH,$(FSOBJ)/memedit.bin): $(call NATIVEPATH,$(FSSRC)/fs/bin/memedit.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/bin/memedit.asm) $(call NATIVEPATH,$(FSOBJ)/memedit.bin)

$(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/bosbin/CEDIT.bin): $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/src/main.c)
	$(Q)make -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/bosbin/CEDIT.bin) -o $(call NATIVEPATH,$(FSOBJ)/CEDIT.zx7.bin) -j bin -k bin -c zx7

$(call NATIVEPATH,$(FSSRC)/fs/bin/msd/bosbin/MSD.bin): $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/src/main.c)
	$(Q)make -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/bosbin/MSD.bin) -o $(call NATIVEPATH,$(FSOBJ)/MSD.zx7.bin) -j bin -k bin -c zx7

# filesystem var build rules
$(call NATIVEPATH,$(FSOBJ)/LIB.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/LIB.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/LIB.asm) $(call NATIVEPATH,$(FSOBJ)/LIB.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/LIB.bin) -o $(call NATIVEPATH,$(FSOBJ)/LIB.zx7.bin) -j bin -k bin -c zx7
	
$(call NATIVEPATH,$(FSOBJ)/PATH.bin): $(call NATIVEPATH,$(FSSRC)/fs/var/PATH.asm)
	fasmg $(call NATIVEPATH,$(FSSRC)/fs/var/PATH.asm) $(call NATIVEPATH,$(FSOBJ)/PATH.bin)
	convbin -i $(call NATIVEPATH,$(FSOBJ)/PATH.bin) -o $(call NATIVEPATH,$(FSOBJ)/PATH.zx7.bin) -j bin -k bin -c zx7

# Rule to build Filesytem and compress it
filesystem: $(call NATIVEPATH,$(FSSRC)/main.asm) $(call NATIVEPATH,$(FSSRC)/fs/lib/libload/bos_libload.asm) $(call NATIVEPATH,$(FSSRC)/fs/lib/fatdrvce/fatdrvce.asm) \
$(call NATIVEPATH,$(FSSRC)/fs/lib/fileioc/fileioc.asm) $(call NATIVEPATH,$(FSSRC)/fs/lib/fontlibc/fontlibc.asm) \
$(call NATIVEPATH,$(FSSRC)/fs/lib/graphx/graphx.asm) $(call NATIVEPATH,$(FSSRC)/fs/lib/keypadc/keypadc.asm) $(call NATIVEPATH,$(FSSRC)/fs/lib/srldrvce/srldrvce.asm) \
$(call NATIVEPATH,$(FSSRC)/fs/lib/usbdrvce/usbdrvce.asm) $(call NATIVEPATH,$(FSSRC)/fs/bin/memedit.asm) $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/explorer.asm) \
$(call NATIVEPATH,$(FSOBJ)/libload.bin) $(call NATIVEPATH,$(FSOBJ)/fatdrvce.bin) $(call NATIVEPATH,$(FSOBJ)/fileioc.bin) $(call NATIVEPATH,$(FSOBJ)/fontlibc.bin) \
$(call NATIVEPATH,$(FSOBJ)/graphx.bin) $(call NATIVEPATH,$(FSOBJ)/keypadc.bin) $(call NATIVEPATH,$(FSOBJ)/srldrvce.bin) $(call NATIVEPATH,$(FSOBJ)/usbdrvce.bin) \
$(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/bosbin/CEDIT.bin) $(call NATIVEPATH,$(FSOBJ)/explorer.bin) $(call NATIVEPATH,$(FSOBJ)/memedit.bin) \
$(call NATIVEPATH,$(FSOBJ)/msddrvce.bin) $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/bosbin/MSD.bin) $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/config.asm) \
$(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/data.asm) $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/display.asm) $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/files.asm) \
$(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/libloader.asm) $(call NATIVEPATH,$(FSSRC)/fs/bin/explorer/loadconfig.asm) $(call NATIVEPATH,$(FSOBJ)/PATH.bin) \
$(call NATIVEPATH,$(FSSRC)/fs/var/PATH.asm) $(call NATIVEPATH,$(FSOBJ)/LIB.bin) $(call NATIVEPATH,$(FSSRC)/fs/var/LIB.asm)
	convbin -i $(call NATIVEPATH,$(FSSRC)/fs/etc/fontlibc/DrMono.dat) -o $(call NATIVEPATH,$(FSOBJ)/DrMono.zx7.dat) -j bin -k bin -c zx7
	fasmg $(call NATIVEPATH,$(FSSRC)/main.asm) $(call NATIVEPATH,src/data/adrive/main.bin)
	convbin -i $(call NATIVEPATH,src/data/adrive/main.bin) -o $(call NATIVEPATH,src/data/adrive/data.bin) -j bin -k bin -c zx7
	convbin -i $(call NATIVEPATH,src/data/adrive/data.bin) -o $(call NATIVEPATH,bin/BOSOSpt2.8xv) -j bin -k 8xv -n BOSOSpt2
	$(CP) $(call NATIVEPATH,src/data/adrive/data.bin) $(call NATIVEPATH,bin/BOSOSPT2.BIN)

# Rule to build noti-ez80 submodule required for standalone ROM image
$(call NATIVEPATH,noti-ez80/bin/NOTI.rom):
	fasmg $(call NATIVEPATH,noti-ez80/src/main.asm) $(call NATIVEPATH,noti-ez80/bin/NOTI.rom)

# Rule to build Updater binary
bosbin:
	fasmg $(call NATIVEPATH,src/updater.asm) $(call NATIVEPATH,bin/BOSUPDTR.BIN)

# Rule to build Installer 8xp
bos8xp:
	fasmg $(call NATIVEPATH,src/installer8xp.asm) $(call NATIVEPATH,bin/BOSOS.8xp)

# Rule to build ROM image
bosrom: $(call NATIVEPATH,noti-ez80/bin/NOTI.rom)
	fasmg $(call NATIVEPATH,src/rom.asm) $(call NATIVEPATH,bin/BOSOS.rom)

clean-cedit:
	$(Q)make clean -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	$(Q)echo Removed CEdit objects and binaries.

clean-msd:
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	$(Q)echo Removed MSD objects and binaries.

#make clean
clean:
	$(call RMDIR,bin)
	$(call RMDIR,obj)
	$(call RMDIR,$(call NATIVEPATH,noti-ez80/bin))
	$(call RMDIR,$(call NATIVEPATH,src/data/adrive/obj))
	$(RM) $(call NATIVEPATH,src/data/adrive/data.bin)
	$(RM) $(call NATIVEPATH,src/data/adrive/main.bin)
	$(Q)make clean -f bos.makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/cedit/)
	$(Q)make clean -f makefile -C $(call NATIVEPATH,$(FSSRC)/fs/bin/msd/)
	$(Q)echo Removed objects and binaries.
