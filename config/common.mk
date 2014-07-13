PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/updraft/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/updraft/prebuilt/common/bin/50-slim.sh:system/addon.d/50-slim.sh \
    vendor/updraft/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/updraft/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# UPDRAFT-specific init file
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/etc/init.local.rc:root/init.updraft.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/lib/libjni_latinime.so:system/lib/libjni_latinime.so

# Copy libgif for Nova Launcher 3.0
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/lib/libgif.so:system/lib/libgif.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/etc/mkshrc:system/etc/mkshrc \
    vendor/updraft/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/updraft/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/updraft/prebuilt/common/bin/sysinit:system/bin/sysinit

# Embed SuperUser
SUPERUSER_EMBEDDED := true

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    SpareParts \
    Superuser \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic

# DSPManager
PRODUCT_PACKAGES += \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf

# Extra tools
PRODUCT_PACKAGES += \
    e2fsck \
    mke2fs \
    tune2fs

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/updraft/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/updraft/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/updraft/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

# Versioning System
# KitKat Updraft freeze code
PRODUCT_VERSION_MAJOR = 4.4.4
PRODUCT_VERSION_MINOR = build
PRODUCT_VERSION_MAINTENANCE = 6.4
ifdef UPDRAFT_BUILD_EXTRA
    UPDRAFT_POSTFIX := -$(UPDRAFT_BUILD_EXTRA)
endif
ifndef UPDRAFT_BUILD_TYPE
    UPDRAFT_BUILD_TYPE := UNOFFICIAL
    PLATFORM_VERSION_CODENAME := UNOFFICIAL
    UPDRAFT_POSTFIX := -$(shell date +"%Y%m%d-%H%M")
endif

# SlimIRC
# export INCLUDE_UPDRAFTIRC=1 for unofficial builds
ifneq ($(filter WEEKLY OFFICIAL,$(UPDRAFT_BUILD_TYPE)),)
    INCLUDE_UPDRAFTIRC = 1
endif

ifneq ($(INCLUDE_UPDRAFTIRC),)
    PRODUCT_PACKAGES += SlimIRC
endif

# Set all versions
UPDRAFT_VERSION := Updraft-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)-$(UPDRAFT_BUILD_TYPE)$(UPDRAFT_POSTFIX)
UPDRAFT_MOD_VERSION := Updraft-$(UPDRAFT_BUILD)-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)-$(UPDRAFT_BUILD_TYPE)$(UPDRAFT_POSTFIX)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    slim.ota.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE) \ # Keep this for now
    ro.slim.version=$(UPDRAFT_VERSION) \ # Keep this for now
    ro.modversion=$(UPDRAFT_MOD_VERSION) \ # Keep this for now
    ro.slim.buildtype=$(UPDRAFT_BUILD_TYPE) # Keep this for now

