CC		:= x86_64-elf-gcc
QEMU    := qemu-system-x86_64

KERNEL    := ArtemiX
KERNELELF := $(KERNEL).elf
KERNELIMG := $(KERNEL).img
SOURCEDIR := src

LIMINE_URL := https://github.com/limine-bootloader/limine.git
LIMINE_DIR := limine

CFILES    := $(shell find $(SOURCEDIR) -type f -name '*.c')
ASMFILES  := $(shell find $(SOURCEDIR) -type f -name '*.S')
OBJ       := $(CFILES:.c=.c.o) $(ASMFILES:.S=.S.o)

PREFIX = $(shell pwd)

BUILD_TIME := $(shell date)

CFLAGS :=							\
	-O2								\
	-Wall							\
	-Wextra							\
	-pedantic						\
	-Wshadow						\
	-Wfloat-equal					\
	-Wunreachable-code				\
	-Wswitch-enum					\
	-Wswitch-default				\
	-Wstrict-prototypes				\
	-Wpointer-arith					\
	-Wimplicit-function-declaration \
	-Winit-self						\
	-std=gnu17                      \
	-fno-pic                        \
	-mno-sse                        \
	-mno-sse2                       \
	-mno-mmx                        \
	-mno-80387                      \
	-mno-red-zone                   \
	-mcmodel=kernel                 \
	-ffreestanding                  \
	-fno-stack-protector            \
	-fno-omit-frame-pointer         \
	-DBUILD_TIME='"$(BUILD_TIME)"'  \
	-I$(SOURCEDIR)					\
	-I$(LIMINE_DIR)/stivale			\

LDFLAGS := 						\
	-nostdlib       			\
	-z max-page-size=0x1000		\
	-T $(SOURCEDIR)/linker.ld	\

.PHONY: all clean fclean run

%.c.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.S.o: %.S
	$(CC) $< -I$(SOURCEDIR) -f elf64 -o $@

all: $(KERNELELF)

image: $(KERNELIMG)

$(KERNELELF): $(LIMINE_DIR) $(OBJ) $(SOURCEDIR)/linker.ld
	$(CC) $(LDFLAGS) $(OBJ) -o $@

$(KERNELIMG): $(KERNELELF)
	$(RM) $(KERNELIMG)
	
	dd if=/dev/zero bs=1M count=0 seek=64 of=$@
	parted -s $@ mklabel msdos
	parted -s $@ mkpart primary 2048s 100%

	sudo losetup -Pf --show $@ > loopback_dev
	sudo partprobe `cat loopback_dev`
	sudo mkfs.ext2 `cat loopback_dev`p1
	mkdir mountpoint
	sudo mount `cat loopback_dev`p1 mountpoint

	sudo mkdir mountpoint/boot
	sudo cp $(KERNELELF) $(SOURCEDIR)/limine.cfg mountpoint/boot/

	sudo umount mountpoint
	sudo losetup -d `cat loopback_dev`
	$(RM) -r loopback_dev mountpoint

	$(LIMINE_DIR)/limine-install $(LIMINE_DIR)/limine.bin $@

$(LIMINE_DIR):
	git clone $(LIMINE_URL) $(LIMINE_DIR) --depth=1 --branch=v0.6.3
	$(MAKE) -C $(LIMINE_DIR) limine-install

clean:
	$(RM) -r $(OBJ) $(KERNELELF) $(KERNELIMG)

fclean: clean
	$(RM) -r $(LIMINE_DIR)

run: $(KERNELIMG)
	$(QEMU) -hda $(KERNELIMG) -m 2G