include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = TweakManager
TweakManager_FILES = main.m TMRAppDelegate.m TweakManager.m TMRRootViewController.m TMRTweakListViewController.m TMRGlobalData.m TMRTweakageEditViewController.m
TweakManager_FRAMEWORKS = UIKit CoreGraphics
ARCHES=armv7 arm64 arm64e
include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"TweakManager\" && killall -9 SpringBoard" || true
