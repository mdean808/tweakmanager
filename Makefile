include $(THEOS)/makefiles/common.mk


APPLICATION_NAME = TweakManager
TweakManager_FILES = $(wildcard src/*.m)
TweakManager_FRAMEWORKS = UIKit CoreGraphics
ARCHES=armv7 arm64 arm64e
#SUBPROJECTS += tmgrhook

include $(THEOS_MAKE_PATH)/application.mk

after-stage::
	ldid -STweakManager.entitlements $(THEOS_STAGING_DIR)/Applications/TweakManager.app/TweakManager

after-install::
	install.exec "killall \"TweakManager\" || true && killall -9 SpringBoard" || true
include $(THEOS_MAKE_PATH)/aggregate.mk
