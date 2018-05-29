# MakeFile function     :: MakeFile for compiling thermal test suite

top_srcdir              ?= ../../..

include $(top_srcdir)/include/mk/env_pre.mk

KERNEL_DIR		:= $(patsubst %/include,%,$(KERNEL_INC))
INSTALL_DIR             := testcases/bin/ddt_intel/thermal

FILTER_OUT_DIRS         := include

# We don't want to copy over the Makefile
UNWANTED_FILES          := Makefile

INSTALL_MODE            := 00755

#INSTALL_TARGETS         := $(filter-out $(UNWANTED_FILES),$(notdir $(patsubst $(abs_srcdir)/%,%,$(wildcard $(abs_srcdir)/*))))

CFLAGS          += -g -Wall -O1 -fomit-frame-pointer
LDFLAGS         += -g
INCLUDES        = -I ../utils/user


#List of source files- Update this on adding a new C file
SOURCES := \
        src/stress.c \
        ../utils/user/st_stress.c

MAKE_TARGETS            := stress

stress:
	$(CC) $(CFLAGS) $(LDFLAGS) -o stress ${INCLUDES} ${SOURCES} -lm

CLEAN_TARGETS += src/*.o src/*.d

include $(top_srcdir)/include/mk/generic_leaf_target.mk

