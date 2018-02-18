include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FolderUsageSwitch
FolderUsageSwitch_FILES = Switch.xm
FolderUsageSwitch_FRAMEWORKS = UIKit
FolderUsageSwitch_LIBRARIES = flipswitch
FolderUsageSwitch_INSTALL_PATH = /Library/Switches
FolderUsageSwitch_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FolderUsageSwitch; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FolderUsageSwitch/; fi$(ECHO_END)

after-install::
	install.exec "rm -rf /tmp/FlipswitchCache/ ; killall -9 SpringBoard"
