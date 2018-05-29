# MakeFile function     :: MakeFile for compiling I2C test suite

top_srcdir              ?= ../../..

include $(top_srcdir)/include/mk/env_pre.mk

KERNEL_DIR		:= $(patsubst %/include,%,$(KERNEL_INC))
INSTALL_DIR             := testcases/bin/ddt_intel/i2c

FILTER_OUT_DIRS         := include

# We don't want to copy over the Makefile
UNWANTED_FILES          := Makefile

INSTALL_MODE            := 00755

#INSTALL_TARGETS         := $(filter-out $(UNWANTED_FILES),$(notdir $(patsubst $(abs_srcdir)/%,%,$(wildcard $(abs_srcdir)/*))))

CFLAGS          += -g -Wall -O1 -fomit-frame-pointer
LDFLAGS         += -g
INCLUDES        = -I src/interface/common -I ../utils/user


#List of source files- Update this on adding a new C file
SOURCES := \
        ../utils/user/st_timer.c \
        ../utils/user/st_cpu_load.c \
        src/testcases/st_i2c_eeprom.c \
        src/interface/common/st_i2c_common.c \
        src/parser/st_i2c_parser.c

MAKE_TARGETS            := i2cdetect i2cdump i2cset i2cget i2c_tests

i2c_tests:
	$(CC) $(CFLAGS) $(LDFLAGS) -o i2c_tests ${INCLUDES} ${SOURCES}

TOOLS_DIR	:= tools
INCLUDE_DIR	:= include

TOOLS_CFLAGS	:= -Wstrict-prototypes -Wshadow -Wpointer-arith -Wcast-qual \
		   -Wcast-align -Wwrite-strings -Wnested-externs -Winline \
		   -W -Wundef -Wmissing-prototypes -Iinclude

i2cdetect: $(TOOLS_DIR)/i2cdetect.o $(TOOLS_DIR)/i2cbusses.o
	$(CC) $(LDFLAGS) -o $@ $^

i2cdump: $(TOOLS_DIR)/i2cdump.o $(TOOLS_DIR)/i2cbusses.o $(TOOLS_DIR)/util.o
	$(CC) $(LDFLAGS) -o $@ $^

i2cset: $(TOOLS_DIR)/i2cset.o $(TOOLS_DIR)/i2cbusses.o $(TOOLS_DIR)/util.o
	$(CC) $(LDFLAGS) -o $@ $^

i2cget: $(TOOLS_DIR)/i2cget.o $(TOOLS_DIR)/i2cbusses.o $(TOOLS_DIR)/util.o
	$(CC) $(LDFLAGS) -o $@ $^

$(TOOLS_DIR)/i2cdetect.o: $(TOOLS_DIR)/i2cdetect.c $(TOOLS_DIR)/i2cbusses.h $(TOOLS_DIR)/version.h $(INCLUDE_DIR)/linux/i2c-dev.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

$(TOOLS_DIR)/i2cdump.o: $(TOOLS_DIR)/i2cdump.c $(TOOLS_DIR)/i2cbusses.h $(TOOLS_DIR)/util.h $(TOOLS_DIR)/version.h $(INCLUDE_DIR)/linux/i2c-dev.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

$(TOOLS_DIR)/i2cset.o: $(TOOLS_DIR)/i2cset.c $(TOOLS_DIR)/i2cbusses.h $(TOOLS_DIR)/util.h $(TOOLS_DIR)/version.h $(INCLUDE_DIR)/linux/i2c-dev.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

$(TOOLS_DIR)/i2cget.o: $(TOOLS_DIR)/i2cget.c $(TOOLS_DIR)/i2cbusses.h $(TOOLS_DIR)/util.h $(TOOLS_DIR)/version.h $(INCLUDE_DIR)/linux/i2c-dev.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

$(TOOLS_DIR)/i2cbusses.o: $(TOOLS_DIR)/i2cbusses.c $(TOOLS_DIR)/i2cbusses.h $(INCLUDE_DIR)/linux/i2c-dev.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

$(TOOLS_DIR)/util.o: $(TOOLS_DIR)/util.c $(TOOLS_DIR)/util.h
	$(CC) $(CFLAGS) $(TOOLS_CFLAGS) -c $< -o $@

CLEAN_TARGETS += src/*.o src/*.d \
               src/interface/common/*.o src/interface/common/*.d \
               src/parser/*.o src/parser/*.d \
               src/testcases/*.o src/testcases/*.d \
               tools/*.o tools/*.d \
               ../utils/user/*.o ../utils/user/*.d

include $(top_srcdir)/include/mk/generic_leaf_target.mk

