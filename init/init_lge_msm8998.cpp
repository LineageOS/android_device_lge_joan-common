/*
    Copyright (C) 2007, The Android Open Source Project
    Copyright (c) 2016, The CyanogenMod Project
    Copyright (c) 2017-2024, The LineageOS Project

    SPDX-License-Identifier: BSD-3-Clause
 */

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include "vendor_init.h"
#include "property_service.h"

#include "libinit_utils.h"
#include "libinit_variant.h"

using android::base::Trim;
using android::base::GetProperty;

#define PROPERTY_LGE_MODEL "ro.boot.vendor.lge.model.name"

static const variant_info_t joan_global_com_info = {
    .brand = "lge",
    .device = "joan",
    .build_fingerprint = "lge/joan_global_com/joan:8.0.0/OPR1.170623.026/181381736b4e9:user/release-keys",
};

static const variant_info_t joan_kddi_jp_info = {
    .brand = "KDDI",
    .device = "joan",
    .build_fingerprint = "KDDI/joan_kddi_jp/joan:9/PKQ1.190414.001/2007610508923:user/release-keys",
};

static const variant_info_t joan_dcm_jp_info = {
    .brand = "lge",
    .device = "L-01K",
    .build_fingerprint = "lge/joan_dcm_jp/L-01K:9/PKQ1.190414.001/20072184679ed:user/release-keys",
};

void init_target_properties()
{
    std::string model;
    variant_info_t* variant;

    if(parse_cmdline("lge.dsds") == "dsds")
    {
        property_override("persist.radio.multisim.config", "dsds");
    }

    model = GetProperty("ro.boot.vendor.lge.model.name", "UNKNOWN");
    if(model == "LGV35")
        variant = joan_kddi_jp_info;
    else if (model == "L-01K")
        variant = joan_dcm_jp_info;
    else
        variant = joan_global_com_info;

    variant->model = model;
    set_variant_props(&variant);
}

void vendor_load_properties() {
    LOG(INFO) << "Loading vendor specific properties";
    init_target_properties();
}
