include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FolderUsage
FolderUsage_FILES = $(wildcard *.xm *.m external/*/*.m)
FolderUsage_CFLAGS += -fobjc-arc

Tweak.xm_CFLAGS += -fno-objc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "rm -rf /tmp/FlipswitchCache/ ; killall -9 SpringBoard"

SUBPROJECTS += folderusageprefs
SUBPROJECTS += folderusageswitch

include $(THEOS_MAKE_PATH)/aggregate.mk
