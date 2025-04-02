#PATH := /bin
TARGET := dwdebug




ifdef WINDIR
BINARY := $(TARGET).exe
else
BINARY := $(TARGET)
endif



SRCS :=
SRCS += src/dwdebug.c
SRCS += src/GlobalData.c
SRCS += src/system/system.c
SRCS += src/dwire/dwire.c
SRCS += src/commandline/commandline.c
SRCS += src/commands/commands.c
SRCS += src/gdbserver/gdbserver.c
SRCS += src/ui/ui.c

#OBJS := $(notdir $(SRCS:.c=.o))
OBJS := $(SRCS:.c=.o)


CC_OPTS :=
CC_OPTS += -Wno-implicit-function-declaration

$(info SRCS: $(SRCS))
$(info OBJS: $(OBJS))



ifndef TOOLCHAIN_DIR

CC = gcc

all: run

run: $(BINARY)
	./$(BINARY)

install:
	cp -p $(BINARY) /usr/local/bin

else

  # set variable TOOLCHAIN_DIR to cross compile
  # example: https://github.com/raspberrypi/tools
  # make TOOLCHAIN_DIR=<tools>/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf
  # this toolchain has package libusb-1.0-0-dev installed, but
  # we need files from the pi package libusb-dev (previous version):
  # /usr/include/usb.h => <toolchain_dir>/arm-linux-gnueabihf/sysroot/usr/include
  # /usr/lib/arm-linux-gnueabihf/libusb.a => <toolchain_dir>/arm-linux-gnueabihf/sysroot/lib
  CC := $(wildcard $(TOOLCHAIN_DIR)/bin/*-gcc)

endif



$(OBJS): $(SRCS) Makefile

%.o: %.c
	$(CC) -c -std=gnu99 -g -fno-pie -rdynamic -fPIC -Wall $(CC_OPTS) -o $(@) $(<)


#$(BINARY): */*/*.c */*.c Makefile
$(BINARY): $(OBJS)
ifdef WINDIR
	#i686-w64-mingw32-gcc -std=gnu99 -Wall -o $(BINARY) -Dwindows src/$(TARGET).c -lKernel32 -lWinmm -lComdlg32 -lWs2_32
	i686-w64-mingw32-gcc -std=gnu99 -Wall -o $(BINARY) -Dwindows $(OBJS) -lKernel32 -lWinmm -lComdlg32 -lWs2_32
else
	#$(CC) -std=gnu99 -g -fno-pie -rdynamic -fPIC -Wall -o $(BINARY) src/$(TARGET).c -lusb -ldl
	$(CC) -std=gnu99 -g -fno-pie -rdynamic -fPIC -Wall -o $(@) $(^) -lusb -ldl
endif
	ls -lap $(BINARY)


clean:
	-$(RM) $(OBJS)
	-$(RM) $(BINARY)
	-$(RM) *.map *.list
