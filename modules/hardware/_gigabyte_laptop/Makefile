obj-m += aorus-laptop.o
KDIR ?= /lib/modules/$(shell uname -r)/build

default: modules
install: modules_install

modules modules_install clean:
	$(MAKE) -C $(KDIR) M=$(PWD) $@
