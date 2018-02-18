include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FolderUsage
FolderUsage_FILES = Tweak.xm
FolderUsage_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
