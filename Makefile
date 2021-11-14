TARGET := iphone:clang:14.4:13.0
INSTALL_TARGET_PROCESSES = MobileSlideShow
ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
VERSION = 1.1
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HiddenLock14
HiddenLock14_FRAMEWORKS = UIKit LocalAuthentication Security
HiddenLock14_FILES = Tweak.x
HiddenLock14_CFLAGS = -fobjc-arc
HiddenLock14_EXTRA_FRAMEWORKS += Cephei

SUBPROJECTS += lighter
SUBPROJECTS += hiddenlockpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
