
# Points to the root of Google Test, relative to where this file is.
GTEST_DIR = googletest/googletest
# Points to the root of Google Mock, relative to where this file is.
GMOCK_DIR = googletest/googlemock

# Flags passed to the preprocessor.
# Set Google Test and Google Mock's header directories as system
# directories, such that the compiler doesn't generate warnings in
# these headers.
CPPFLAGS += -isystem $(GTEST_DIR)/include -I$(GTEST_DIR)
#-isystem $(GTEST_DIR)/include -isystem $(GMOCK_DIR)/include

# Flags passed to the C++ compiler.
CXXFLAGS += -g -Wall -Wextra -pthread


# All Google Test headers.
GTEST_HEADERS = $(GTEST_DIR)/src/*.h \
                $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

# All Google Mock headers. Note that all Google Test headers are
# included here too, as they are #included by Google Mock headers.
GMOCK_HEADERS = $(GMOCK_DIR)/include/gmock/*.h \
                $(GMOCK_DIR)/include/gmock/internal/*.h \
                $(GTEST_HEADERS)


GTEST_SRCS = $(GTEST_DIR)/src/*.cc
GTEST_MAIN = $(GTEST_DIR)/src/gtest_main.cc
GTEST_ALL = $(GTEST_DIR)/src/gtest-all.cc

GMOCK_SRCS = $(GMOCK_DIR)/src/*.cc
GMOCK_MAIN = $(GMOCK_DIR)/src/gmock_main.cc
GMOCK_ALL = $(GMOCK_DIR)/src/gmock-all.cc


TARGETS := gtest gtest_main gmock gmock_main
LIB_PREFIX := lib
AR_EXT := .a
DLL_EXT := .so
ARCHIVES := $(addprefix $(LIB_PREFIX),$(addsuffix $(AR_EXT),$(TARGETS)))
LIBRARIES := $(addprefix $(LIB_PREFIX),$(addsuffix $(DLL_EXT),$(TARGETS)))


RM := rm -rf
CP := cp -r


## Rules for targets

.PHONY:  all
all :  includes libs


# Builds libgtest.a, libgtest_main.a, libgmock.a and libgmock_main.a.
# These libraries contain both Google Mock and Google Test.
# A test should link with either gmock.a or gmock_main.a, depending 
# on whether it defines its own main() function.
# It's fine if your test only uses features from Google
# Test (and not Google Mock).
.PHONY:  archives libraries
archives :  $(ARCHIVES)
libraries :  $(LIBRARIES)


.PHONY:  includes libs
includes :  
	$(CP) -t . $(GTEST_DIR)/include $(GMOCK_DIR)/include
	find ./include \( -name internal -o -name '*.pump' \) -exec rm -rf {} +

## TODO: WARNING: Libraries need object files build with -fPIC flag
##                but objects will not be rebuilded. 
libs :  $(ARCHIVES) $(LIBRARIES)
	install -d lib
	install -t lib $^


.PHONY:  clean
clean :
	$(RM) *.o *$(AR_EXT) *$(DLL_EXT) include/ lib/


# Compile to object

%.o :  
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $<

gtest-all.o :  $(GTEST_ALL) $(GTEST_SRCS) $(GTEST_HEADERS)
gtest_main.o :  $(GTEST_MAIN) $(GTEST_HEADERS)

gmock-all.o :  $(GMOCK_ALL) $(GMOCK_SRCS) $(GMOCK_HEADERS)
gmock_main.o :  $(GMOCK_MAIN) $(GMOCK_HEADERS)
gmock_main.o gmock-all.o :  CPPFLAGS += -isystem $(GMOCK_DIR)/include -I$(GMOCK_DIR)


# Creating archives

%.a :
	$(AR) $(ARFLAGS) $@ $^

libgtest.a      :  gtest-all.o
libgtest_main.a :  gtest-all.o gtest_main.o
libgmock.a      :  gtest-all.o gmock-all.o
libgmock_main.a :  gtest-all.o gmock-all.o gmock_main.o


# Creating libraries

## TODO: -fPIC should be removed from CXXFLAGS while building library
%.so :  CXXFLAGS += -fPIC
%.so :
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -shared -Wl,-soname,$@ -o $@ $^

libgtest.so      :  gtest-all.o
libgtest_main.so :  gtest-all.o gtest_main.o
libgmock.so      :  gtest-all.o gmock-all.o
libgmock_main.so :  gtest-all.o gmock-all.o gmock_main.o