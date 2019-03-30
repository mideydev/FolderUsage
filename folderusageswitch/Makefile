include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FolderUsageSwitch
$(BUNDLE_NAME)_FILES = Switch.xm
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_LIBRARIES = flipswitch
$(BUNDLE_NAME)_INSTALL_PATH = /Library/Switches
$(BUNDLE_NAME)_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME); cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME)/; fi$(ECHO_END)

after-install::
	install.exec "rm -rf /tmp/FlipswitchCache/ ; killall -9 SpringBoard"
