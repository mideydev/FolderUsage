include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FolderUsage
$(TWEAK_NAME)_FILES = $(wildcard *.xm *.m external/*/*.m)
$(TWEAK_NAME)_CFLAGS += -fobjc-arc

Tweak.xm_CFLAGS += -fno-objc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "rm -rf /tmp/FlipswitchCache/ ; killall -9 SpringBoard"

SUBPROJECTS += folderusageprefs
SUBPROJECTS += folderusageswitch

include $(THEOS_MAKE_PATH)/aggregate.mk
