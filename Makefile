include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FolderUsage
FolderUsage_FILES = $(wildcard *.xm *.m external/*/*.m)
FolderUsage_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += folderusageprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
