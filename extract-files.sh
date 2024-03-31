#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common)
            ONLY_COMMON=true
            ;;
        --only-target)
            ONLY_TARGET=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/lib64/lib-imscamera.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --add-needed libgui_shim.so "${2}"
            ;;
        system_ext/lib64/lib-imsvideocodec.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --add-needed libgui_shim.so "${2}"
            ${PATCHELF} --replace-needed libqdMetaData.so libqdMetaData.system.so "${2}"
            ;;
        vendor/lib/hw/camera.msm8998.so)
            [ "$2" = "" ] && return 0
            sed -i "s/libandroid\.so/libui_shim\.so/g" "${2}"
            ${PATCHELF} --remove-needed libsensor.so "${2}"
            ${PATCHELF} --remove-needed libgui.so "${2}"
            ${PATCHELF} --remove-needed libui.so "${2}"
            ;;
        vendor/lib/libarcsoft_beauty_picselfie.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --remove-needed libandroid.so "${2}"
            ${PATCHELF} --remove-needed libjnigraphics.so "${2}"
            ${PATCHELF} --replace-needed libstdc++.so libstdc++_vendor.so "${2}"
            ;;
        vendor/lib/libfilm_emulation.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --remove-needed libjnigraphics.so "${2}"
            ${PATCHELF} --replace-needed libstdc++.so libstdc++_vendor.so "${2}"
            ;;
        vendor/lib/libmmcamera_bokeh.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --replace-needed libui.so libui_shim.so "${2}"
            ;;
        vendor/lib/libmpbase.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --remove-needed libandroid.so "${2}"
            ${PATCHELF} --replace-needed libstdc++.so libstdc++_vendor.so "${2}"
            ;;
        vendor/lib/libAutoContrast.so | \
            vendor/lib/libSJFingerDetect.so | \
            vendor/lib/libSJVideoNR.so | \
            vendor/lib/libarcsoft_object_tracking.so | \
            vendor/lib/libarcsoft_picselfie_algorithm.so | \
            vendor/lib/libcinemaeffect.so | \
            vendor/lib/libfilm_emulation_symphony.so | \
            vendor/lib/liblghdri.so | \
            vendor/lib/liblgmda.so | \
            vendor/lib/libmorpho_image_stab31.so | \
            vendor/lib/libmorpho_superzoom.so)
            [ "$2" = "" ] && return 0
            ${PATCHELF} --replace-needed libstdc++.so libstdc++_vendor.so "${2}"
            ;;
        vendor/lib/sensors.ssc.so)
            [ "$2" = "" ] && return 0
            sed -i "s/\x11\xf0\x9e\xf8/\x4d\xd2\x00\xbf/" "${2}"
            ;;
        vendor/lib64/sensors.ssc.so)
            [ "$2" = "" ] && return 0
            sed -i "s/\xf2\x8b\xff\x97/\x2a\x00\x00\x14/" "${2}"
            ;;
	    vendor/lib64/libwvhidl.so)
            [ "$2" = "" ] && return 0
	        grep -q libcrypto_shim.so "${2}" || "${PATCHELF}" --add-needed "libcrypto_shim.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON:-$VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    extract "${MY_DIR}/proprietary-files_phoenix.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../../${VENDOR}/${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
