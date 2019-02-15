# Include project-specific make options
include ./build/options.mk

# Local-only definitions
CC       = $(CROSS)gcc
CXX      = $(CROSS)g++
OBJCOPY  = $(CROSS)objcopy
ECHO     = echo
INC_DIRS = $(LINUX_INC)
GREP     = grep
SED      = sed
CAT      = cat
DTC      = dtc

TEST_APP_SRCS  = ./test_fpc.cpp
TEST_APP_SRCS += ./XilinxFpcDevice.cpp
TEST_APP_SRCS += ./DemoBoard.cpp

TEST_APP_OBJS = $(TEST_APP_SRCS:%.cpp=%.o)

# Default target
all: test_fpc

# Xilinx PCI Fast Partial Configuration test application binary
test_fpc: $(TEST_APP_OBJS)
	$(CXX) $(CPPFLAGS) $(LIB_DIRS:%=-L %) -o $@ $^ $(LINK_LIBS:%=-l%) $(LDFLAGS)

# C++ compilation rule
%.o:%.cpp
	$(CXX) $(CPPFLAGS) $(INC_DIRS:%=-I %) -c -o $@ $<

%.d:%.cpp
	$(CXX) $(CPPFLAGS) $(INC_DIRS:%=-I %) -MM -o $@ $<

clean: 
	rm -f test_fpc *.o *.gdb *.d

# Build and include dependency files for each of the source modules
-include ${TEST_APP_SRCS:%.cpp=%.d}
