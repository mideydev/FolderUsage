include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FolderUsagePrefs
FolderUsagePrefs_FILES = $(wildcard *.m)
FolderUsagePrefs_INSTALL_PATH = /Library/PreferenceBundles
FolderUsagePrefs_FRAMEWORKS = UIKit
FolderUsagePrefs_PRIVATE_FRAMEWORKS = Preferences
FolderUsagePrefs_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FolderUsagePrefs.plist$(ECHO_END)
