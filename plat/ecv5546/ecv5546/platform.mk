#
# Copyright (c) 2017-2019, ARM Limited and Contributors. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# The differences between the platform are covered by the include files.
include plat/ecv5546/common/sp-common.mk

BL31_SOURCES += plat/ecv5546/ecv5546/sp_helpers.S
BL31_SOURCES += plat/ecv5546/ecv5546/sp_pm.c
