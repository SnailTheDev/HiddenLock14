TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = HiddenLockPreferences

HiddenLockPreferences_FILES = HLPRootListController.m
HiddenLockPreferences_FRAMEWORKS = UIKit
HiddenLockPreferences_PRIVATE_FRAMEWORKS = Preferences
HiddenLockPreferences_INSTALL_PATH = /Library/PreferenceBundles
HiddenLockPreferences_CFLAGS = -fobjc-arc
HiddenLockPreferences_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)