// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/silicon_creator/rom_ext/rom_ext.h"

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/base/macros.h"
#include "sw/device/lib/base/stdasm.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/silicon_creator/lib/base/sec_mmio.h"
#include "sw/device/silicon_creator/lib/drivers/flash_ctrl.h"
#include "sw/device/silicon_creator/lib/drivers/hmac.h"
#include "sw/device/silicon_creator/lib/drivers/lifecycle.h"
#include "sw/device/silicon_creator/lib/drivers/otp.h"
#include "sw/device/silicon_creator/lib/drivers/pinmux.h"
#include "sw/device/silicon_creator/lib/drivers/uart.h"
#include "sw/device/silicon_creator/lib/manifest.h"
#include "sw/device/silicon_creator/lib/rom_print.h"
#include "sw/device/silicon_creator/lib/shutdown.h"
#include "sw/device/silicon_creator/lib/sigverify/sigverify.h"
#include "sw/device/silicon_creator/mask_rom/sigverify_keys.h"
#include "sw/device/silicon_creator/rom_ext/rom_ext_boot_policy.h"
#include "sw/device/silicon_creator/rom_ext/rom_ext_epmp.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"  // Generated.

// In-memory copy of the ePMP register configuration.
epmp_state_t epmp;
// Life cycle state of the chip.
lifecycle_state_t lc_state = kLcStateProd;

static rom_error_t rom_ext_irq_error(void) {
  uint32_t mcause;
  CSR_READ(CSR_REG_MCAUSE, &mcause);
  // Shuffle the mcause bits into the uppermost byte of the word and report
  // the cause as kErrorInterrupt.
  // Based on the ibex verilog, it appears that the most significant bit
  // indicates whether the cause is an exception (0) or external interrupt (1),
  // and the 5 least significant bits indicate which exception/interrupt.
  //
  // Preserve the MSB and shift the 7 LSBs into the upper byte.
  // (we preserve 7 instead of 5 because the verilog hardcodes the unused bits
  // as zero and those would be the next bits used should the number of
  // interrupt causes increase).
  mcause = (mcause & 0x80000000) | ((mcause & 0x7f) << 24);
  return kErrorInterrupt + mcause;
}

void rom_ext_init(void) {
  sec_mmio_next_stage_init();

  lc_state = lifecycle_state_get();

  // TODO: Verify ePMP expectations from ROM.

  pinmux_init();
  // Configure UART0 as stdout.
  uart_init(kUartNCOValue);
}

static rom_error_t rom_ext_verify(const manifest_t *manifest) {
  RETURN_IF_ERROR(rom_ext_boot_policy_manifest_check(manifest));
  const sigverify_rsa_key_t *key;
  RETURN_IF_ERROR(sigverify_rsa_key_get(
      sigverify_rsa_key_id_get(&manifest->modulus), lc_state, &key));

  hmac_sha256_init();
  // Hash usage constraints.
  manifest_usage_constraints_t usage_constraints_from_hw;
  sigverify_usage_constraints_get(manifest->usage_constraints.selector_bits,
                                  &usage_constraints_from_hw);
  hmac_sha256_update(&usage_constraints_from_hw,
                     sizeof(usage_constraints_from_hw));
  // Hash the remaining part of the image.
  manifest_digest_region_t digest_region = manifest_digest_region_get(manifest);
  hmac_sha256_update(digest_region.start, digest_region.length);
  // Verify signature
  hmac_digest_t act_digest;
  hmac_sha256_final(&act_digest);
  uint32_t flash_exec = 0;
  return sigverify_rsa_verify(&manifest->signature, key, &act_digest, lc_state,
                              &flash_exec);
}

static rom_error_t rom_ext_boot(const manifest_t *manifest) {
  // Disable access to silicon creator info pages and OTP partitions until next
  // reset.
  flash_ctrl_creator_info_pages_lockdown();
  otp_creator_sw_cfg_lockdown();
  SEC_MMIO_WRITE_INCREMENT(kFlashCtrlSecMmioCreatorInfoPagesLockdown +
                           kOtpSecMmioCreatorSwCfgLockDown);

  // Unlock execution of owner stage executable code (text) sections.
  rom_ext_epmp_unlock_owner_stage_rx(&epmp, manifest_code_region_get(manifest));

  // Jump to BL0 entry point.
  uintptr_t entry_point = manifest_entry_point_get(manifest);
  rom_printf("entry: 0x%x\r\n", (unsigned int)entry_point);
  ((owner_stage_entry_point *)entry_point)();

  return kErrorMaskRomBootFailed;
}

static rom_error_t rom_ext_try_boot(void) {
  rom_ext_boot_policy_manifests_t manifests =
      rom_ext_boot_policy_manifests_get();
  rom_error_t error = kErrorMaskRomBootFailed;
  for (size_t i = 0; i < ARRAYSIZE(manifests.ordered); ++i) {
    error = rom_ext_verify(manifests.ordered[i]);
    if (error != kErrorOk) {
      continue;
    }
    // Boot fails if a verified ROM_EXT cannot be booted.
    RETURN_IF_ERROR(rom_ext_boot(manifests.ordered[i]));
    // `rom_ext_boot()` should never return `kErrorOk`, but if it does
    // we must shut down the chip instead of trying the next ROM_EXT.
    return kErrorMaskRomBootFailed;
  }
  return error;
}

void rom_ext_main(void) {
  rom_ext_init();
  rom_printf("starting rom_ext\r\n");
  shutdown_finalize(rom_ext_try_boot());
}

void rom_ext_interrupt_handler(void) { shutdown_finalize(rom_ext_irq_error()); }

// We only need a single handler for all ROM_EXT interrupts, but we want to
// keep distinct symbols to make writing tests easier.  In the ROM_EXT,
// alias all interrupt handler symbols to the single handler.
OT_ALIAS("rom_ext_interrupt_handler")
void rom_ext_exception_handler(void);

OT_ALIAS("rom_ext_interrupt_handler")
void rom_ext_nmi_handler(void);
