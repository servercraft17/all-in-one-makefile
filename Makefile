### PROJECT CONFIGURATION ###
PRJName := project_name
#Options: exe, dll, lib
BinaryType ?= exec
CCPath ?= gcc
CVersion ?= c17

### PROJECT STRUCTURE ###
BUILD_PATH := build
BIN_PATH := $(BUILD_PATH)/bin
SOURCE_PATH := src
HEADER_PATH = $(SOURCE_PATH)
# For 3rd party depedencies for example SDL, or RayLib
3RDPARTY_PATH := ext
# For 3rd party header only depedencies for example STB, or nlohmann json
3RDPARTYINC_PATH := extinc

CFLAGS := \
	-std=$(CVersion) \

include := \
	-I $(SOURCE_PATH) \
	-I $(HEADER_PATH) \
	-I $(3RDPARTYINC_PATH) \

link := -L$(BUILD_PATH) \

### DIRECTORIES ###
define YOUR_DIRECTORIES_HERE

endef

### GITIGNORE ###
define YOUR_GITIGNORE_HERE
$(call IGNORE,.o)
$(call IGNORE,.exe)
$(call IGNORE,.dll)
$(call IGNORE,.lib)
$(call IGNORE,.so)
$(call IGNORE,.a)
$(call IGNORE,.log)
$(call IGNORE,$(BUILD_PATH)/)
$(call IGNORE,$(BIN_PATH)/)
$(call IGNORE,$(3RDPARTY_PATH)/)
endef
### Depedencies ###
# dep: runs a command of your choosing when downloading and preparing dependancies.
# deph: downloads and includes single header stuff like STB
# depc: downloads and includes single source file stuff, that ussually has only 1 .c file and 1 header file you add to your project.
# depl: downloads and links the library with the program. 
#		$1: library name (example: SDL3)
#		$2: link to download binaries and header files for the library. (example: https://github.com/libsdl-org/SDL/releases/download/release-3.4.18/SDL3-devel-3.4.18-mingw.tar.gz)
#		$3: filename of the archive downloaded from $2. (example: SDL3-devel-3.4.18-mingw.tar.gz)
#		$4: path to header files starting from the library directory. (example: x86_64-w64-mingw32/include)
#		$5: path to the binary or archive to be linked to the project. (example: x86_64-w64-mingw32/bin/SDL3.dll)
#			NOTE: on linux this only accepts files ending with '.so' as shared libraries but accepts both '.lib' and '.a' as static on all platforms. 
#	depc: Unfinished, TODO!
# download: downloads a file
# downloade: download and extracts an archive


#$(call depl,SDL3,https://github.com/libsdl-org/SDL/releases/download/release-3.4.18/SDL3-devel-3.4.18-mingw.tar.gz,SDL3-devel-3.4.18-mingw.tar.gz,x86_64-w64-mingw32/include,x86_64-w64-mingw32/bin/SDL3.dll)
#$(call deph,stb_image.h,https://raw.githubusercontent.com/nothings/stb/refs/heads/master/stb_image.h)
define YOUR_DEPENDENCIES_HERE

endef

### PROJECT CONFIGURATION END




define dep
.PHONY: $1
$1:
	@echo Dependancy: $1
	$2
DEPS+=$1
endef

define deph
.PHONY: $(3RDPARTYINC_PATH)/$1
$(3RDPARTYINC_PATH)/$1:
	@echo Dependancy: $(3RDPARTYINC_PATH)/$1
	$(call DOWNLOAD_CMD,$(3RDPARTYINC_PATH)/$1,$2) 
DEPS+=$(3RDPARTYINC_PATH)/$1
endef

define download
.PHONY: $1
$1:
	echo Dependancy: $1
	$(call DOWNLOAD_CMD,$1,$2) 
DEPS+=$1
endef

define downloade
.PHONY: $1
$1:
	@echo Dependancy: $1
	$(RMKDIR) $1
	$(call DOWNLOAD_CMD,$1/$3,$2)
ifeq ($(patsubst %.zip,,$(lastword $3)),)
	$(call EXTRACT_ZIP_CMD,$1/$3,$1)
else
	$(call EXTRACT_TAR_CMD,$1/$3,$1)
endif
DEPS+=$1
endef

define depl
.PHONY: $(3RDPARTY_PATH)/$1
$(3RDPARTY_PATH)/$1:
	@echo Dependancy: $(3RDPARTY_PATH)/$1
	$(RMKDIR) $(3RDPARTY_PATH)/$1
	$(call DOWNLOAD_CMD,$(3RDPARTY_PATH)/$1/$3,$2)
ifeq ($(patsubst %.zip,,$(lastword $3)),)
	$(call EXTRACT_ZIP_CMD,$(3RDPARTY_PATH)/$1/$3,$(3RDPARTY_PATH)/$1)
else
	$(call EXTRACT_TAR_CMD,$(3RDPARTY_PATH)/$1/$3,$(3RDPARTY_PATH)/$1)
endif
ifeq ($(patsubst %$(SHARED_CODE_EXTENTION),,$(lastword $5)),)
	$(COPYBIN) $(3RDPARTY_PATH)/$1/$5 $(BIN_PATH)
link+=-l:$(notdir $(BIN_PATH))/$(notdir $5)
else
	$(COPYBIN) $(3RDPARTY_PATH)/$1/$5 $(BUILD_PATH)
link+=$(BUILD_PATH)/$(notdir $5)
endif
include+=-I $(3RDPARTY_PATH)/$1/$4
DEPS+=$(3RDPARTY_PATH)/$1
endef

HASHTAG := \x23
ENTRYPOINT_BOILERPLATE =$(HASHTAG)include <stdio.h>\n\nint main(int argc, char** argv) {\n\n    return 0;\n}

ifeq ($(findstring cmd.exe,$(SHELL)),cmd.exe)
$(info "shell Windows cmd.exe")

DEVNUL   := NUL
WHICH    := where
MKDIR    := mkdir
RMKDIR   := mkdir
TOUCH    := type nul > 
COPY     := copy
COPYBIN  := copy /B
RMDIR    := rmdir
RM       := del /F

#USAGE: ifeq ($(call FUNCExists,somepath),) ... #does exist# else ... #does not exist#
FUNCExists=$(shell if not exist "$1" (echo DNE) 
FUNCMKDIR=mkdir $1
FUNCEmptyFile=type nul > $1
EXTRACT_ZIP_CMD=powershell -command "Expand-Archive -Path $1 -Destination $2"
EXTRACT_TAR_CMD=tar -xf $1 --strip-components=1 --directory=$2
else
$(info "shell Bash")

DEVNUL  := /dev/null
WHICH   := which
MKDIR   := mkdir
RMKDIR  := mkdir -p
TOUCH   := touch
COPY    := cp
COPYBIN := $(COPY)
RMDIR   := rmdir
RM      := rm -f 

FUNCExists    =
FUNCPrompt    =read -p "$1" prompt_var; $(call $2,$$prompt_var)
FUNCMKDIR     =mkdir $1
FUNCEmptyFile =touch $1
FUNCNewFile   =printf "$1" $3 > $2
EXTRACT_ZIP_CMD=unzip $1 -d $2
EXTRACT_TAR_CMD=tar -xf $1 --strip-components=1 --directory=$2
endif
DOWNLOAD_CMD=$(eval $(error attempt to download file was made, which failed because neither curl nor wget were found. DEST='$1' URL='$2'))
ifeq ($(shell ${WHICH} curl 2>${DEVNUL}),)
	$(info curl not found, checking for wget.)
	ifeq ($(shell ${WHICH} wget 2>${DEVNUL}),)
		$(error neither curl nor wget found.. Unable to download depedencies.)
	else
		$(info wget found!)
		DOWNLOAD_CMD=wget -O $1 '$2'
	endif
else
$(info curl found!)
DOWNLOAD_CMD=curl -L --output $1 "$2"
endif

ifeq ($(shell ${WHICH} bear 2>${DEVNUL}),)
$(info bear NOT FOUND!)
BEAR_CMD = 
else
BEAR_CMD = bear -- $(MAKE)
endif

# TODO: use the proper extensions for gcc, msvc, and clang.
ifeq ($(OS),Windows_NT)
	SHARED_CODE_EXTENTION=.dll
	ifeq ($(BinaryType),exec)
		OutputBinaryName :=$(PRJName).exe
	else
		ifeq ($(BinaryType),shared)
			OutputBinaryName :=$(PRJName)$(SHARED_CODE_EXTENTION)
		else
			ifeq ($(BinaryType),static)
				OutputBinaryName :=$(PRJName).lib									
			else
				$(error UNREACHABLE!!)
			endif
		endif
	endif
else # Linux
	SHARED_CODE_EXTENTION=.so
	ifeq ($(BinaryType),exec)
		OutputBinaryName :=$(PRJName)
	else
		ifeq ($(BinaryType),shared)
			OutputBinaryName :=$(PRJName)$(SHARED_CODE_EXTENTION)
		else
			ifeq ($(BinaryType),static)
				OutputBinaryName :=$(PRJName).a
			else
				$(error UNREACHABLE!!)
			endif
		endif
	endif
endif

default: $(BIN_PATH)/$(OutputBinaryName)
	@echo

#IGNORE=$(eval $(call _IGNORE,$1))
#DIR=$(eval $(call _DIR,$1))
DEPS=
DIRS=
GITIGNORE=
DIR=DIRS+=$1
IGNORE=GITIGNORE+=\n$1
$(eval $(YOUR_GITIGNORE_HERE))
$(eval $(call YOUR_DEPENDENCIES_HERE))
$(eval $(call YOUR_DIRECTORIES_HERE))

FUNCEmptySourceFile =$(TOUCH) $(SOURCE_PATH)/$1.c
FUNCEmptyHeaderFile =$(TOUCH) $(HEADER_PATH)/$1.h
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
rdwildcard=$(sort $(dir $(call rwildcard,$1,$2)))
rsubsuffix=$(sort $(filter-out $(addprefix %,$1),$(foreach s,$1,$(patsubst $(addprefix %,$s),$(addprefix %,$2),$3))))

OBJECTS = $(call rsubsuffix,.c,.o,$(subst $(SOURCE_PATH),$(BUILD_PATH),$(call rwildcard,$(SOURCE_PATH),*.c)))

$(BIN_PATH)/$(OutputBinaryName): $(OBJECTS)
	$(CCPath) $^ -o $@ $(link)

$(BUILD_PATH)/%.o: $(SOURCE_PATH)/%.c
	$(CCPath) -c $< -o $@ $(include) $(CFLAGS)

### PROJECT COMMANDS ###
.PHONY: makedirs
makedirs:
	@$(RMKDIR) $(BUILD_PATH) $(BIN_PATH) $(SOURCE_PATH) $(3RDPARTY_PATH) $(3RDPARTYINC_PATH) $(DIRS) $(HEADER_PATH) $(SOURCE_PATH)/$(3RDPARTY_PATH)

.PHONY: init
init: makedirs $(DEPS)
	@$(call FUNCNewFile,$(GITIGNORE),.gitignore)
	@$(call FUNCNewFile,$(ENTRYPOINT_BOILERPLATE),$(SOURCE_PATH)/$(PRJName).c)
	$(BEAR_CMD)

.PHONY: fetchdeps
fetchdeps: $(DEPS)
	@echo

.PHONY: updatecdb
updatecdb: clean
	$(BEAR_CMD)

.PHONY: asf
asf:
	$(call FUNCPrompt,Filename:,FUNCEmptySourceFile)

.PHONY: ash
ash:
	$(call FUNCPrompt,Filename:,FUNCEmptyHeaderFile)

.PHONY: asd
asd:
	$(call FUNCPrompt,Directory Name:,FUNCMKDIR)
	
.PHONY: clean
.PHONY: run
.PHONY: rerun
.PHONY: rebuild

clean:
	@$(RM) $(BIN_PATH)/$(OutputBinaryName) $(OBJECTS)

run: $(BIN_PATH)/$(OutputBinaryName)
	@$^

rerun: clean run
	@echo

rebuild: clean $(BUILD_PATH/$(OutputBinaryName)
	@echo 
