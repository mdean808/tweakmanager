include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TMGRHook
TMGRHook_FILES = Tweak.xm
TMGRHook_LIBRARIES = activator
ARCHS = arm64 arm64e
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
