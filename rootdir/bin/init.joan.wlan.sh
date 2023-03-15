#!/vendor/bin/sh
# Copyright (c) 2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

#
# This script is intended to be run under the qti_init_shell
# context, but can be relabeled if necessary.
#
# LGE's cnss-daemon checks <persist-lg dir>/wifi/qcom/*
# for firmware images.
# This is a symlink in LGE's implementation, presumably so the same 
# vendor BSP source can be used on multiple devices without 
# worrying about system-as-root, treble etc.
# Let's point it to the right place.
#

LGE_PERSIST_ROOT=/mnt/vendor/persist-lg

LGE_PERSIST_WIFI_DIR=${LGE_PERSIST_ROOT}/wifi

LGE_PERSIST_WIFI_QCOM_DIR=${LGE_PERSIST_WIFI_DIR}/qcom

# Verify that persist-lg/wifi folder exists
if [[ ! -d ${LGE_PERSIST_WIFI_DIR} ]]; then
    mkdir ${LGE_PERSIST_WIFI_DIR}
    chmod -hR 0775 ${LGE_PERSIST_WIFI_DIR}
fi

# LGE has multiple configurations for different SOC vendors.
# On joan there is only qca_cld, so that is all that is implemented here.

LGE_PERSIST_WIFI_QCOM_DIR=${LGE_PERSIST_WIFI_DIR}/qcom

# Verify that persist-lg/wifi/qcom folder exists
if [[ ! -d ${LGE_PERSIST_WIFI_QCOM_DIR} ]]; then
    mkdir ${LGE_PERSIST_WIFI_QCOM_DIR}
    chmod -hR 0775 ${LGE_PERSIST_WIFI_QCOM_DIR}
fi

#
# create symlinks!
# For devices using qcacld-3.0 driver, we need these following files,
# which joan keeps in /vendor.
# files to symlink:
# - /vendor/etc/wifi/WCNSS_qcom_cfg.ini :   ${LGE_PERSIST_WIFI_QCOM_DIR}/WCNSS_qcom_cache_cfg.ini
# - /vendor/etc/wifi/bdwlan.bin         :   ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_cache.bin
# - /vendor/etc/wifi/bdwlan_ch0.bin     :   ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_ch0_cache.bin
# - /vendor/etc/wifi/bdwlan_ch1.bin     :   ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_ch1_cache.bin
#

ln -sf /vendor/etc/wifi/WCNSS_qcom_cfg.ini ${LGE_PERSIST_WIFI_QCOM_DIR}/WCNSS_qcom_cache_cfg.ini
ln -sf /vendor/etc/wifi/bdwlan.bin ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_cache.bin
ln -sf /vendor/etc/wifi/bdwlan_ch0.bin ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_ch0_cache.bin
ln -sf /vendor/etc/wifi/bdwlan_ch1.bin ${LGE_PERSIST_WIFI_QCOM_DIR}/bdwlan_ch1_cache.bin
