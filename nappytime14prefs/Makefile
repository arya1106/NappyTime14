
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NappyTime14Prefs

NappyTime14Prefs_FILES = $(wildcard *.m)
NappyTime14Prefs_FRAMEWORKS = UIKit
NappyTime14Prefs_PRIVATE_FRAMEWORKS = Preferences OnBoardingKit
NappyTime14Prefs_INSTALL_PATH = /Library/PreferenceBundles
NappyTime14Prefs_CFLAGS = -fobjc-arc 
NappyTime14Prefs_EXTRA_FRAMEWORKS +=Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk
