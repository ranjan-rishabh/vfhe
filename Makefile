#
# Makefile for HAL
#

RELIC_PTH=/usr/local
GMP_PTH=/usr/local
FLINT_PTH=/usr/local

DIR_PTH =.
IDIR=include
ODIR=obj
SDIR=src

CC=gcc

PREFIX=''

ifeq ($(PREFIX),'')
        PREFIX=/usr/local
endif

# Paths to internal directories

_UTIL_PTH=utils
_TEST_PTH=.
IUTIL_PTH=$(DIR_PTH)/$(IDIR)/$(_UTIL_PTH)
OUTIL_PTH=$(DIR_PTH)/$(ODIR)/$(_UTIL_PTH)
SUTIL_PTH=$(DIR_PTH)/$(SDIR)/$(_UTIL_PTH)

# CF13 scheme paths
_CF13_PTH=cf13
_CF13_TOOL_PTH=cf13/tools
ICF13_PTH=$(DIR_PTH)/$(IDIR)/$(_CF13_PTH)
ICF13_TOOL_PTH=$(DIR_PTH)/$(IDIR)/$(_CF13_TOOL_PTH)
OCF13_PTH=$(DIR_PTH)/$(ODIR)/$(_CF13_PTH)
OCF13_TOOL_PTH=$(DIR_PTH)/$(ODIR)/$(_CF13_TOOL_PTH)
SCF13_PTH=$(DIR_PTH)/$(SDIR)/$(_CF13_PTH)
SCF13_TOOL_PTH=$(DIR_PTH)/$(SDIR)/$(_CF13_TOOL_PTH)

# test examples paths
OTEST_PTH=test/obj
STEST_PTH=test
SFUNC_PTH=test/func


# Libraries
LIB_PTH = -L$(LCL_PTH)/lib -L$(GMP_PTH)/lib -L$(RELIC_PTH)/lib -L$(FLINT_PTH)/lib
LIBS = -lgmp -lrelic_s -lflint 
LFLAGS = $(LIB_PTH) $(LIBS) 

# Dependencies

# Libraries
_GMP_DEPS = gmp.h
_RELIC_DEPS = relic.h
_FLINT_DEPS = fmpz.h fmpz_poly.h fq.h fq_poly.h

GMP_DEPS = $( patsubst %, $(GMP_PTH)$(IDIR)/%, $(_GMP_DEPS) )
RELIC_DEPS = $( patsubst %, $(RELIC_PTH)$(IDIR)/%, $(_RELIC_DEPS) )
FLINT_DEPS = $( patsubst %, $(FLINT_PTH)$(IDIR)/flint/%, $(_FLINT_DEPS) )

# HAL utils
_UTIL_DEPS = utils.h types.h prf.h rng.h
UTIL_DEPS = $( patsubst %, $(IUTIL_PTH)/%, $(_UTIL_DEPS) )

# CF13 scheme deps
_CF13_DEPS = cf13_authenticate.h cf13_verify.h cf13_keygen.h cf13.h
_CF13_TOOL_DEPS = cf13_keys.h cf13_tag.h cf13_verification_keys.h cf13_tools.h cf13_msg.h cf13_prf.h
CF13_DEPS = $( patsubst %, $(ICF13_PTH)/%, $(_CF13_DEPS) )
CF13_TOOL_DEPS = $( patsubst %, $(ICF13_TOOL_PTH)%, $(_CF13_TOOL_DEPS) )

LIB_DEPS = $(UTIL_DEPS) $(CF13_DEPS) $(CF13_TOOL_DEPS)

DEPS = $(LIB_DEPS) $(GMP_DEPS) $(RELIC_DEPS) $(FLINT_DEPS) 

IFLAGS = -I$(GMP_PTH)/$(IDIR) -I$(FLINT_PTH)/$(IDIR)/flint -I$(RELIC_PTH)/$(IDIR)  -I$(IUTIL_PTH) -I$(ICF13_TOOL_PTH) -I$(ICF13_PTH)


# Object files

# test examples objects
_OBJ_CFSAMPLE_EXEC = cf_test.o

OBJ_CFSAMPLE_EXEC = $(patsubst %,$(OTEST_PTH)/%,$(_OBJ_CFSAMPLE_EXEC))

# HAL utils objects
_OBJ_UTIL = types.o prf.o rng.o
OBJ_UTIL = $(patsubst %,$(OUTIL_PTH)/%,$(_OBJ_UTIL))

# CF13 scheme objects
_OBJ_CF13 = cf13_authenticate.o cf13_verify.o cf13_keygen.o cf13.o
_OBJ_CF13_TOOL = cf13_keys.o cf13_tag.o cf13_verification_keys.o cf13_msg.o cf13_prf.o

OBJ_CF13 = $(patsubst %,$(OCF13_PTH)/%,$(_OBJ_CF13))
OBJ_CF13_TOOL = $(patsubst %,$(OCF13_TOOL_PTH)/%,$(_OBJ_CF13_TOOL))

OBJ_LIB = $(OBJ_UTIL) $(OBJ_CF13_TOOL) $(OBJ_CF13)


all : hal-crypto 

$(OUTIL_PTH)/%.o: $(SUTIL_PTH)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(IFLAGS) $(LFLAGS)

$(OCF13_TOOL_PTH)/%.o: $(SCF13_TOOL_PTH)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(IFLAGS) $(LFLAGS)

$(OCF13_PTH)/%.o: $(SCF13_PTH)/%.c $(DEPS)
	$(CC) -c -o $@ $< $(IFLAGS) $(LFLAGS)

$(OTEST_PTH)/cf_test.o: $(STEST_PTH)/cf_test.c
	$(CC) -c -o $@ $< $(IFLAGS) $(LFLAGS)

cftest: $(OBJ_CFSAMPLE_EXEC)
	$(CC) -o cfTest $(OBJ_CFSAMPLE_EXEC) -lhal-crypto -L/lib $(IFLAGS) $(LFLAGS)
	mv cfTest test

hal-crypto: $(LIB_DEPS) $(OBJ_LIB)


install:
	mkdir -p $(PREFIX)/include/hal-crypto
	mkdir -p $(PREFIX)/lib
	rm -f $(PREFIX)/include/hal-crypto/*.h
	rm -f $(PREFIX)/lib/libhal-crypto.a
	cp -v include/utils/*.h $(PREFIX)/include/hal-crypto/
	cp -v include/cf13/*.h $(PREFIX)/include/hal-crypto/
	cp -v include/cf13/tools/*.h $(PREFIX)/include/hal-crypto/
	cp -v lib/libhal-crypto.a $(PREFIX)/lib/

.PHONY: clean

clean:
	rm -f $(OTEST_PTH)/*.o $(OUTIL_PTH)/*.o $(OCF13_PTH)/*.o $(OCF13_TOOL_PTH)/*.o
	rm -f test/sampleTest test/sampleTest2 test/createFunction test/cfTest
	rm -f lib/libhal-crypto.a
