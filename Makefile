# Folders
INCLUDE :=  include
COMMANDS := commands
OBJ :=  obj
SRC :=  src
BIN :=  bin
LIB :=  lib


# Sub-Folders
ifeq ($(OS),Windows_NT)
MAIN	:= main.exe
SRCDIRS	:= $(SRC)
INCLUDEDIRS	:= $(INCLUDE)
LIBDIRS		:= $(LIB)
FIXPATH = $(subst /,\,$1)
RM			:= del /q /f
RMRF 		:= rmdir /s /q
MD	:= mkdir
else
MAIN	:= main
SRCDIRS	:= $(shell find $(SRC) -type d)
OBJDIRS		:= $(patsubst $(SRC)/%, $(OBJ)/%, $(SRCDIRS))
INCLUDEDIRS	:= $(shell find $(INCLUDE) -type d)
LIBDIRS		:= $(shell find $(LIB) -type d)
FIXPATH = $1
RM = rm -f
RMRF := rm -rf
MD	:= mkdir -p
endif

# Names
MAIN := main
MAIN_SRC := $(SRC)/$(MAIN).c
MAIN_BIN := $(BIN)/$(MAIN)

# Flags
INCLUDES_FLAG := $(patsubst %,-I%,$(INCLUDEDIRS:%/=%))
STD := c11
CC := clang
CFLAGS := $(INCLUDES_FLAG) -std=$(STD) -g -Wall -Wextra

# Files
LIBS := $(wildcard $(patsubst %,%/*, $(LIBDIRS)))
INCLUDES := $(wildcard $(patsubst %,%/*, $(INCLUDEDIRS)))
#SRCS := $(wildcard $(patsubst %,%/*.c,$(SRCDIRS)))
SRCS := $(wildcard $(SRC)/*.c)
OBJS := $(patsubst $(SRC)/%,$(OBJ)/%,$(SRCS:.c=.o))
JSONS := $(patsubst $(SRC)/%.c,$(COMMANDS)/%.json,$(SRCS))
# JSONS := $(patsubst $(SRC_DIR)/%.c,$(COMMANDS)/%.json,$(SRCS))
DB := compile_commands.json

# $(info SRCDIRS = [${SRCDIRS}])
# $(info SRCS = [${SRCS}])
# $(info JSONS = [${JSONS}])

.PHONY: all clean clean-json $(DB)

# Main Commands & "Routing"
all: $(BIN) $(MAIN_BIN)
	@echo Executing 'all' complete

$(BIN):
	$(MD) $(BIN)

$(COMMANDS):
	$(MD) $(COMMANDS)

run: all
	$(MAIN_BIN)

exec:
	$(MAIN_BIN)

# 1. Compile objects (.o) from sources
$(OBJ)/%.o: $(SRC)/%.c $(INCLUDES) | $(OBJDIRS)
	@echo "Compiling $< -> $@"
	$(CC) $(CFLAGS) -c $< -o $@

# 2. Compile main.o
$(OBJ)/$(MAIN).o: $(MAIN_SRC) $(INCLUDES) | $(OBJDIRS)
	@echo "Compiling main $< → $@"
	$(CC) $(CFLAGS) -c $< -o $@

# 3. Link the executable
$(MAIN_BIN): $(OBJS) $(LIBS)
	@echo "Linking → $@"
	$(CC) $(CFLAGS) $^ -o $@

# 4. Generate per-file JSON entries in one go alongside .o builds
$(COMMANDS)/%.json: $(SRC)/%.c | $(COMMANDS)
	@echo "Generating JSON entry for $<"
	$(CC) $(CFLAGS) -MJ $@ -c $< -o /dev/null

# 5. Merge all JSON snippets into compile_commands.json ($(DB))
$(DB): $(JSONS)
	@echo "Merging JSON snippets -> $@"
	@echo "[" > $@
	@find $(COMMANDS) -type f -name '*.json' -exec cat {} \; | sed '$$ s/,\s*$$//' >> $@
	@echo "]" >> $@

# For if bear actually works
bear-make:
	make clean; bear -- make

clean:
	rm -rf *.dSYM $(OBJ)/* $(BIN)/*

clean-json:
	@rm -rf $(COMMANDS)/*.json $(DB)
