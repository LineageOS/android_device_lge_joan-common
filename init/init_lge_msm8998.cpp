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

using android::base::Trim;
using android::base::GetProperty;

void property_override(const std::string& name, const std::string& value)
{
    size_t valuelen = value.size();

    prop_info* pi = (prop_info*) __system_property_find(name.c_str());
    if (pi != nullptr) {
        __system_property_update(pi, value.c_str(), valuelen);
    }
    else {
        int rc = __system_property_add(name.c_str(), name.size(), value.c_str(), valuelen);
        if (rc < 0) {
            LOG(ERROR) << "property_set(\"" << name << "\", \"" << value << "\") failed: "
                       << "__system_property_add failed";
        }
    }
}

std::string parse_cmdline(std::string findstring)
{
    std::string cmdline;
    android::base::ReadFileToString("/proc/cmdline", &cmdline);

    for (const auto& entry : android::base::Split(android::base::Trim(cmdline), " ")) {
        std::vector<std::string> pieces = android::base::Split(entry, "=");
        if (pieces.size() == 2) {
            if(pieces[0].compare(findstring) == 0)
            {
                return pieces[1];
            }
        }
    }
    return "";
}

void init_target_properties()
{
    std::string model;

    if (model = parse_cmdline("androidboot.vendor.lge.model.name"), model.empty())
    {
        model = "UNKNOWN";
    }

    if(parse_cmdline("lge.dsds") == "dsds";)
    {
        property_override("persist.radio.multisim.config", "dsds");
    }

    property_override("ro.product.model", model);
    property_override("ro.product.odm.model", model);
    property_override("ro.product.product.model", model);
    property_override("ro.product.system.model", model);
    property_override("ro.product.vendor.model", model);
}

void vendor_load_properties() {
    LOG(INFO) << "Loading vendor specific properties";
    init_target_properties();
}
