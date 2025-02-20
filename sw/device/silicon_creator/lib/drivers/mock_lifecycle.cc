// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/lib/drivers/mock_lifecycle.h"

namespace mask_rom_test {
extern "C" {
lifecycle_state_t lifecycle_state_get(void) {
  return MockLifecycle::Instance().State();
}

uint32_t lifecycle_raw_state_get(void) {
  return MockLifecycle::Instance().RawState();
}

void lifecycle_device_id_get(lifecycle_device_id_t *device_id) {
  MockLifecycle::Instance().DeviceId(device_id);
}
}  // extern "C"
}  // namespace mask_rom_test
