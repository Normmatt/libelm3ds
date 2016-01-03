#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCE is the directory containing source code
# DATA is a list of directories containing data files
# INCLUDES is a list of directories containing header files
#---------------------------------------------------------------------------------
TARGET		:=	libelm3ds
BUILD		:=	build
SOURCE		:=	source
INCLUDES	:=	include

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ARCH	:=	-mthumb -mthumb-interwork

CFLAGS	:=	-g -Wall -Os -std=c11\
		-march=armv5te -mtune=arm946e-s \
		-fomit-frame-pointer -ffast-math \
		$(ARCH) -Iinclude

CFLAGS	+=	$(INCLUDE) -DARM9 -fno-dwarf2-cfi-asm 
CXXFLAGS	:= $(CFLAGS) -fno-rtti -fno-exceptions

LDFLAGS	=	-specs=ds_arm9.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)

GET_FILES	=	$(wildcard $(SOURCE)/*.$(1)) $(wildcard $(SOURCE)/**/*.$(1))
CFILES		:=	$(call GET_FILES,c)
SFILES		:=	$(call GET_FILES,s)
OFILES		:=	$(patsubst $(SOURCE)/%,$(BUILD)/%,$(CFILES:.c=.o) $(SFILES:.s=.o))

.PHONY: install clean

$(foreach f,$(BUILD)/$(TARGET).a $(OFILES),$(eval $f : | $(dir $f)/D))

$(BUILD)/$(TARGET).a	:	$(OFILES)

%/D:
	@[ -d $(dir $@) ] || mkdir -p $(dir $@)

install: $(BUILD)/$(TARGET).a include
	cp -R include $(DESTDIR)
	cp $(BUILD)/$(TARGET).a -t $(DESTDIR)/lib

clean:
	@echo clean ...
	@rm -fr $(BUILD) lib

DEPENDS	:=	$(OFILES:.o=.d)

$(BUILD)/%.o: source/%.s
	$(COMPILE.s) $(OUTPUT_OPTION) $<

$(BUILD)/%.o: source/%.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

-include $(DEPENDS)
