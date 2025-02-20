// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// A sequence to do illegal read and write accesses to the imem when the otbn is busy

class otbn_illegal_mem_acc_vseq extends otbn_single_vseq;
  `uvm_object_utils(otbn_illegal_mem_acc_vseq)
  `uvm_object_new

  task body();
    fork
      begin
        super.body();
      end
      begin
        do_mem_acc();
        repeat (3) wait_alert_trigger("fatal", .wait_complete(1), .max_wait_cycle(100));
      end
    join
  endtask: body

  task do_mem_acc();
    bit write;
    uvm_mem mems[$];
    string ral_name;
    bit [BUS_AW-1:0] offset;
    bit [BUS_AW-1:0] addr;
    bit [BUS_DW-1:0] data;
    bit completed, saw_err;
    // Pick either dmem or imem to access randomly
    bit choose_mem;

    cfg.ral_models["otbn_reg_block"].get_memories(mems);
    `DV_CHECK_STD_RANDOMIZE_FATAL(choose_mem)
    `DV_CHECK_STD_RANDOMIZE_FATAL(write)
    wait (cfg.model_agent_cfg.vif.status == otbn_pkg::StatusBusyExecute);
    offset = $urandom_range(0, mems[choose_mem].get_n_bytes() - 1);
    addr = mems[choose_mem].get_address(offset);
    ral_name = mems[choose_mem].get_parent().get_name();
    cfg.en_scb_tl_err_chk = 0;
    tl_access_w_abort(.addr(addr), .write(0), .data(data), .completed(completed),
                      .saw_err(saw_err), .check_rsp(1),
                      .tl_sequencer_h(p_sequencer.tl_sequencer_hs[ral_name]));
    `DV_CHECK_EQ(completed, 1)
    `DV_CHECK_EQ(saw_err, 0)
    cfg.en_scb_tl_err_chk = 1;
  endtask

endclass : otbn_illegal_mem_acc_vseq
