### REFERENCE (TO BE REMOVED) ###

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
rdwildcard=$(sort $(dir $(call rwildcard,$1,$2)))

#rsubsuffix: $(call rsubsuffix,.cpp .c,.o,names..)
rsubsuffix=$(sort $(filter-out $(addprefix %,$1),$(foreach s,$1,$(patsubst $(addprefix %,$s),$(addprefix %,$2),$3))))

SRC:= $(call rwildcard,$(SRCD),$(addprefix *,$(FNEXT)))
OBJ:= $(call rsubsuffix,$(FNEXT),.o,$(addprefix $(BUILD)/,$(notdir $(SRC))))

test:
	read -p "Enter something: " my_var; echo "$$my_var"
	

# detect platform independently if gcc is installed
ifeq ($(shell ${WHICH} gcc 2>${DEVNUL}),)
$(error "gcc is not in your system PATH")
else
$(info "gcc found")
endif

readtest=read -p "$1" my_var; $(call $2,$$my_var)
mkdirtest=mkdir $1

test2:
	$(call readtest,test prompt, mkdirtest)

### END REFERENCE (TO BE REMOVED) ###



GITIGNORE +=.o
GITIGNORE +=\n.exe
GITIGNORE +=\n.dll
GITIGNORE +=\n.lib
GITIGNORE +=\n.so
GITIGNORE +=\n.a
GITIGNORE +=\n.log
GITIGNORE +=\n$(BUILD_PATH)/
GITIGNORE +=\n$(BIN_PATH)/
GITIGNORE +=\n$(3RDPARTY_PATH)/


