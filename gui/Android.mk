LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_CFLAGS := -fno-strict-aliasing -Wno-implicit-fallthrough

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    animation.cpp \
    object.cpp \
    slider.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp \
    mousecursor.cpp \
    scrolllist.cpp \
    patternpassword.cpp \
    textbox.cpp \
    terminal.cpp \
    twmsg.cpp

ifneq ($(TW_DELAY_TOUCH_INIT_MS),)
    LOCAL_CFLAGS += -DTW_DELAY_TOUCH_INIT_MS=$(TW_DELAY_TOUCH_INIT_MS)
endif

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
    LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
    LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

ifeq ($(AB_OTA_UPDATER),true)
    LOCAL_CFLAGS += -DAB_OTA_UPDATER
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++ libaosprecovery libselinux
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../otautil/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../twrpinstall/include
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26; echo $$?),0)
    LOCAL_SHARED_LIBRARIES += libziparchive
    LOCAL_STATIC_LIBRARIES += libotautil libtwrpinstall
    ifneq ($(TW_INCLUDE_CRYPTO),)
        LOCAL_C_INCLUDES += bootable/recovery/crypto/fscrypt
    endif
    ifeq ($(shell test $(PLATFORM_SDK_VERSION) -gt 28; echo $$?),0)
        LOCAL_C_INCLUDES += $(LOCAL_PATH)/../install/include \
            system/core/libziparchive/include/ \
            $(LOCAL_PATH)/../recovery_ui/include \
            $(LOCAL_PATH)/../fuse_sideload/include
        LOCAL_CFLAGS += -D_USE_SYSTEM_ZIPARCHIVE
    else
        LOCAL_C_INCLUDES += $(LOCAL_PATH)/../install28/ \
            $(LOCAL_PATH)/../fuse_sideload28/
        LOCAL_CFLAGS += -DUSE_28_INSTALL -DUSE_OTAUTIL_ZIPARCHIVE
    endif
else
    LOCAL_SHARED_LIBRARIES += libminzip
    LOCAL_CFLAGS += -DUSE_MINZIP
endif
ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
    ifeq ($(shell test $(PLATFORM_SDK_VERSION) -le 28; echo $$?),0)
        LOCAL_C_INCLUDES += system/extras/ext4_utils \
            system/extras/ext4_utils/include \
            $(LOCAL_PATH)/../crypto/ext4crypt
        LOCAL_SHARED_LIBRARIES += libext4_utils
    endif
endif

LOCAL_MODULE := libguitwrp

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
    LOCAL_CFLAGS += -D_EVENT_LOGGING
endif
ifneq ($(TW_USE_KEY_CODE_TOUCH_SYNC),)
    LOCAL_CFLAGS += -DTW_USE_KEY_CODE_TOUCH_SYNC=$(TW_USE_KEY_CODE_TOUCH_SYNC)
endif
ifneq ($(TW_OZIP_DECRYPT_KEY),)
    LOCAL_CFLAGS += -DTW_OZIP_DECRYPT_KEY=\"$(TW_OZIP_DECRYPT_KEY)\"
else
    LOCAL_CFLAGS += -DTW_OZIP_DECRYPT_KEY=0
endif
ifneq ($(TW_NO_SCREEN_BLANK),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
    LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(TW_OEM_BUILD), true)
    LOCAL_CFLAGS += -DTW_OEM_BUILD
endif
ifneq ($(TW_X_OFFSET),)
    LOCAL_CFLAGS += -DTW_X_OFFSET=$(TW_X_OFFSET)
endif
ifneq ($(TW_Y_OFFSET),)
    LOCAL_CFLAGS += -DTW_Y_OFFSET=$(TW_Y_OFFSET)
endif
ifneq ($(TW_W_OFFSET),)
    LOCAL_CFLAGS += -DTW_W_OFFSET=$(TW_W_OFFSET)
endif
ifneq ($(TW_H_OFFSET),)
    LOCAL_CFLAGS += -DTW_H_OFFSET=$(TW_H_OFFSET)
endif
ifeq ($(TW_ROUND_SCREEN), true)
    LOCAL_CFLAGS += -DTW_ROUND_SCREEN
endif
ifeq ($(TW_SCREEN_BLANK_ON_BOOT), true)
    LOCAL_CFLAGS += -DTW_SCREEN_BLANK_ON_BOOT
endif
ifneq ($(PB_TORCH_PATH),)
        LOCAL_CFLAGS += -DPB_TORCH_PATH=\"$(PB_TORCH_PATH)\"
endif
ifneq ($(PB_TORCH_MAX_BRIGHTNESS),)
	LOCAL_CFLAGS += -DPB_MAX_BRIGHT_VALUE=$(PB_TORCH_MAX_BRIGHTNESS)
endif

LOCAL_C_INCLUDES += \
    bionic \
    system/core/include \
    system/core/libpixelflinger/include \
    external/freetype/include

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -lt 23; echo $$?),0)
    LOCAL_C_INCLUDES += external/stlport/stlport
    LOCAL_CFLAGS += -DUSE_FUSE_SIDELOAD22
endif

LOCAL_CFLAGS += -DTWRES=\"$(TWRES_PATH)\"

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)

# The extra blank line before *** is intentional to ensure it ends up on its own line
define TW_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_THEME: $(TW_THEME)
  Set TARGET_SCREEN_WIDTH and TARGET_SCREEN_HEIGHT to automatically select
  an appropriate theme, or set TW_THEME to one of the following:
    $(notdir $(wildcard $(LOCAL_PATH)/theme/*_*))
****************************************************************************
endef
define TW_CUSTOM_THEME_WARNING_MSG

****************************************************************************
  Could not find ui.xml for TW_CUSTOM_THEME: $(TW_CUSTOM_THEME)
  Expected to find custom theme's ui.xml at:
    $(TWRP_THEME_LOC)/ui.xml
  Please fix this or set TW_THEME to one of the following:
    $(notdir $(wildcard $(LOCAL_PATH)/theme/*_*))
****************************************************************************
endef
define PB_UNSUPPORTED_RESOLUTION_ERR

****************************************************************************
  PitchBlack TWRP is not yet supported for $(TW_THEME) resolution variants
****************************************************************************
endef

TWRP_RES := $(LOCAL_PATH)/theme/common/fonts
TWRP_RES += $(LOCAL_PATH)/theme/common/lang_en/languages
ifeq ($(PB_ENGLISH),)
TWRP_RES += $(LOCAL_PATH)/theme/common/lang_full/languages
endif

ifeq ($(TW_CUSTOM_THEME),)
    ifeq ($(TW_THEME),)
        ifeq ($(DEVICE_RESOLUTION),)
            GUI_WIDTH := $(TARGET_SCREEN_WIDTH)
            GUI_HEIGHT := $(TARGET_SCREEN_HEIGHT)
        else
            SPLIT_DEVICE_RESOLUTION := $(subst x, ,$(DEVICE_RESOLUTION))
            GUI_WIDTH := $(word 1, $(SPLIT_DEVICE_RESOLUTION))
            GUI_HEIGHT := $(word 2, $(SPLIT_DEVICE_RESOLUTION))
        endif

        # Minimum resolution of 100x100
        # This also ensures GUI_WIDTH and GUI_HEIGHT are numbers
        ifeq ($(shell test $(GUI_WIDTH) -ge 100; echo $$?),0)
        ifeq ($(shell test $(GUI_HEIGHT) -ge 100; echo $$?),0)
            ifeq ($(shell test $(GUI_WIDTH) -gt $(GUI_HEIGHT); echo $$?),0)
                ifeq ($(shell test $(GUI_WIDTH) -ge 1280; echo $$?),0)
                    TW_THEME := landscape_hdpi
                    $(error $(PB_UNSUPPORTED_RESOLUTION_ERR))
                else
                    TW_THEME := landscape_mdpi
                    $(error $(PB_UNSUPPORTED_RESOLUTION_ERR))
                endif
            else ifeq ($(shell test $(GUI_WIDTH) -lt $(GUI_HEIGHT); echo $$?),0)
                ifeq ($(shell test $(GUI_WIDTH) -ge 720; echo $$?),0)
                    TW_THEME := portrait_hdpi
                else
                    TW_THEME := portrait_mdpi
                endif
            else ifeq ($(shell test $(GUI_WIDTH) -eq $(GUI_HEIGHT); echo $$?),0)
                # watch_hdpi does not yet exist
                TW_THEME := watch_mdpi
                $(error $(PB_UNSUPPORTED_RESOLUTION_ERR))
            endif
        endif
        endif
    endif

	TWRP_THEME_LOC := $(LOCAL_PATH)/theme/$(TW_THEME)
    TWRP_RES += $(LOCAL_PATH)/theme/common/$(word 1,$(subst _, ,$(TW_THEME))).xml
    ifeq ($(wildcard $(TWRP_THEME_LOC)/ui.xml),)
        $(warning $(TW_THEME_WARNING_MSG))
        $(error Theme selection failed; exiting)
    endif

    #TWRP_RES += $(LOCAL_PATH)/theme/common/$(word 1,$(subst _, ,$(TW_THEME))).xml
    # for future copying of used include xmls and fonts:
    # UI_XML := $(TWRP_THEME_LOC)/ui.xml
    # TWRP_INCLUDE_XMLS := $(shell xmllint --xpath '/recovery/include/xmlfile/@name' $(UI_XML)|sed -n 's/[^\"]*\"\([^\"]*\)\"[^\"]*/\1\n/gp'|sort|uniq)
    # TWRP_FONTS_TTF := $(shell xmllint --xpath '/recovery/resources/font/@filename' $(UI_XML)|sed -n 's/[^\"]*\"\([^\"]*\)\"[^\"]*/\1\n/gp'|sort|uniq)niq)
else
    TWRP_THEME_LOC := $(TW_CUSTOM_THEME)
    ifeq ($(wildcard $(TWRP_THEME_LOC)/ui.xml),)
        $(warning $(TW_CUSTOM_THEME_WARNING_MSG))
        $(error Theme selection failed; exiting)
    endif
endif

TWRP_RES += $(TW_ADDITIONAL_RES)

TWRP_RES_GEN := $(intermediates)/twrp
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_RES) $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)
	cp -fr $(TWRP_THEME_LOC)/* $(TARGET_RECOVERY_ROOT_OUT)$(TWRES_PATH)

LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)
