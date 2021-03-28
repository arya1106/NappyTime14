export TARGET := iphone:clang:latest:12.0
INSTALL_TARGET_PROCESSES = MobileTimer SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NappyTime14
export ARCHS= arm64 arm64e

NappyTime14_FILES = Tweak.xm
NappyTime14_CFLAGS = -fobjc-arc
NappyTime14_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += nappytime14prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
