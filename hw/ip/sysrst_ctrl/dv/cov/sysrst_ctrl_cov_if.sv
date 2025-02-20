// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Implements functional coverage for SYSRST_CTRL

interface sysrst_ctrl_cov_if
  (
   input logic   clk_i,
   input logic   rst_ni
  );

  import uvm_pkg::*;
  import sysrst_ctrl_pkg::*;
  import dv_utils_pkg::*;
  `include "dv_fcov_macros.svh"

  ////////////////////////////////////////////////
  // Combo detect actions register cover points //
  ////////////////////////////////////////////////

  covergroup sysrst_ctrl_combo_detect_action_cg (int index) with function sample (
    bit bat_disable,
    bit interrupt,
    bit ec_rst,
    bit rst_req
  );
    option.per_instance = 1;
    option.name = $sformatf("sysrst_ctrl_combo_detect_action_cg_%0d", index);

    cp_bat_disable: coverpoint bat_disable;
    cp_interrupt:   coverpoint interrupt;
    cp_ec_rst:      coverpoint ec_rst;
    cp_rst_req:     coverpoint rst_req;
  endgroup // sysrst_ctrl_combo_detect_action_cg

  ////////////////////////////////////////////////
  // Combo detect select register cover points //
  ////////////////////////////////////////////////

  covergroup sysrst_ctrl_combo_detect_sel_cg (int index) with function sample (
    bit key0_in_sel,
    bit key1_in_sel,
    bit key2_in_sel,
    bit pwrb_in_sel,
    bit ac_present_sel
  );
    option.per_instance = 1;
    option.name = $sformatf("sysrst_ctrl_combo_detect_sel_cg_%0d", index);

    cp_key0_in_sel:   coverpoint key0_in_sel;
    cp_key1_in_sel:   coverpoint key1_in_sel;
    cp_key2_in_sel:   coverpoint key2_in_sel;
    cp_pwrb_in_sel:   coverpoint pwrb_in_sel;
    cp_ac_present_sel:coverpoint ac_present_sel;
    cp_cross_combo_detect_sel: cross cp_key0_in_sel, cp_key1_in_sel, cp_key2_in_sel,
          cp_pwrb_in_sel, cp_ac_present_sel;
  endgroup // sysrst_ctrl_combo_detect_sel_cg

  /////////////////////////////////////////////////
  // Combo detection timer register cover points //
  /////////////////////////////////////////////////

  covergroup sysrst_ctrl_combo_detect_det_cg (int index) with function sample (
    bit [31:0] detection_timer
  );
    option.per_instance = 1;
    option.name = $sformatf("sysrst_ctrl_combo_detect_det_cg_%0d", index);

    cp_detect_timer: coverpoint detection_timer
      {
        bins min_range = {[10:50]};
        bins mid_range = {[51:100]};
        bins max_range = {[101:$]};
      }
  endgroup // sysrst_ctrl_combo_detect_det_cg

  ///////////////////////////////////////////////////////
  // Auto block debounce control register cover points //
  ///////////////////////////////////////////////////////

  covergroup sysrst_ctrl_auto_block_debounce_ctl_cg with function sample (
    bit [15:0] debounce_timer,
    bit auto_block_enable
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_auto_block_debounce_ctl_cg";

    cp_auto_block_enable: coverpoint auto_block_enable;
    cp_debounce_timer: coverpoint debounce_timer
      {
        bins min_range = {[10:50]};
        bins mid_range = {[51:100]};
        bins max_range = {[101:$]};
      }

  endgroup // sysrst_ctrl_auto_block_debounce_ctl_cg

  /////////////////////////////////////////////
  // Combo intr status register cover points //
  /////////////////////////////////////////////

  covergroup sysrst_ctrl_combo_intr_status_cg with function sample (
    bit combo0_h2l,
    bit combo1_h2l,
    bit combo2_h2l,
    bit combo3_h2l
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_combo_intr_status_cg";

    cp_combo0_h2l: coverpoint combo0_h2l;
    cp_combo1_h2l: coverpoint combo1_h2l;
    cp_combo2_h2l: coverpoint combo2_h2l;
    cp_combo3_h2l: coverpoint combo3_h2l;

  endgroup // sysrst_ctrl_combo_intr_status_cg

  /////////////////////////////////////////////
  // key intr status register cover points //
  /////////////////////////////////////////////

  covergroup sysrst_ctrl_key_intr_status_cg with function sample (
    bit pwrb_h2l,
    bit key0_in_h2l,
    bit key1_in_h2l,
    bit key2_in_h2l,
    bit ac_present_h2l,
    bit ec_rst_l_h2l,
    bit flash_wp_l_h2l,
    bit pwrb_l2h,
    bit key0_in_l2h,
    bit key1_in_l2h,
    bit key2_in_l2h,
    bit ac_present_l2h,
    bit ec_rst_l_l2h,
    bit flash_wp_l_l2h
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_key_intr_status_cg";

    cp_pwrb_h2l: coverpoint pwrb_h2l;
    cp_key0_in_h2l: coverpoint key0_in_h2l;
    cp_key1_in_h2l: coverpoint key1_in_h2l;
    cp_key2_in_h2l: coverpoint key2_in_h2l;
    cp_ac_present_h2l: coverpoint ac_present_h2l;
    cp_ec_rst_l_h2l: coverpoint ec_rst_l_h2l;
    cp_flash_wp_l_h2l: coverpoint flash_wp_l_h2l;
    cp_pwrb_l2h: coverpoint pwrb_l2h;
    cp_key0_in_l2h: coverpoint key0_in_l2h;
    cp_key1_in_l2h: coverpoint key1_in_l2h;
    cp_key2_in_l2h: coverpoint key2_in_l2h;
    cp_ac_present_l2h: coverpoint ac_present_l2h;
    cp_ec_rst_l_l2h: coverpoint ec_rst_l_l2h;
    cp_flash_wp_l_l2h: coverpoint flash_wp_l_l2h;

  endgroup // sysrst_ctrl_key_intr_status_cg

  //////////////////////////////////////////////////
  // Ultra low power status register cover points //
  //////////////////////////////////////////////////

  covergroup sysrst_ctrl_ulp_status_cg with function sample (
    bit ulp_wakeup
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_ulp_status_cg";

    cp_ulp_wakeup: coverpoint ulp_wakeup;

  endgroup // sysrst_ctrl_ulp_status_cg

  /////////////////////////////////////////
  // Wakeup status register cover points //
  /////////////////////////////////////////

  covergroup sysrst_ctrl_wkup_status_cg with function sample (
    bit wakeup_sts
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_wkup_status_cg";

    cp_wakeup_sts: coverpoint wakeup_sts;

  endgroup // sysrst_ctrl_wkup_status_cg

  //////////////////////////////////////
  // Pin in value register cover points //
  //////////////////////////////////////
  covergroup sysrst_ctrl_pin_in_value_cg with function sample (
    bit pwrb_in,
    bit key0_in,
    bit key1_in,
    bit key2_in,
    bit lid_open,
    bit ac_present,
    bit ec_rst_l,
    bit flash_wp_l
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_pin_in_value_cg";

    cp_pwrb_in: coverpoint pwrb_in;
    cp_key0_in: coverpoint key0_in;
    cp_key1_in: coverpoint key1_in;
    cp_key2_in: coverpoint key2_in;
    cp_lid_open: coverpoint lid_open;
    cp_ac_present: coverpoint ac_present;
    cp_ec_rst_l: coverpoint ec_rst_l;
    cp_flash_wp_l: coverpoint flash_wp_l;

  endgroup // sysrst_ctrl_pin_in_value_cg

  /////////////////////////////////////
  // Auto block out ctl cover points //
  /////////////////////////////////////
  covergroup sysrst_ctrl_auto_blk_out_ctl_cg with function sample (
    bit key0_out_sel,
    bit key1_out_sel,
    bit key2_out_sel,
    bit key0_out_value,
    bit key1_out_value,
    bit key2_out_value
  );
    option.per_instance = 1;
    option.name = "sysrst_ctrl_auto_blk_out_ctl_cg";

    cp_key0_out_sel: coverpoint key0_out_sel;
    cp_key1_out_sel: coverpoint key1_out_sel;
    cp_key2_out_sel: coverpoint key2_out_sel;
    cp_key0_out_value: coverpoint key0_out_value;
    cp_key1_out_value: coverpoint key1_out_value;
    cp_key2_out_value: coverpoint key2_out_value;

  endgroup // sysrst_ctrl_auto_blk_out_ctl_cg

  ///////////////////////////////////
  // Instantiation Macros          //
  ///////////////////////////////////
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_auto_block_debounce_ctl_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_combo_intr_status_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_key_intr_status_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_ulp_status_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_wkup_status_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_pin_in_value_cg)
  `DV_FCOV_INSTANTIATE_CG(sysrst_ctrl_auto_blk_out_ctl_cg)

  sysrst_ctrl_combo_detect_action_cg combo_detect_action_cg_inst[4];
  initial begin
    foreach (combo_detect_action_cg_inst[i]) begin
      combo_detect_action_cg_inst[i] = new(i);
    end
  end

  sysrst_ctrl_combo_detect_sel_cg combo_detect_sel_cg_inst[4];
  initial begin
    foreach (combo_detect_sel_cg_inst[i]) begin
      combo_detect_sel_cg_inst[i] = new(i);
    end
  end

  sysrst_ctrl_combo_detect_det_cg combo_detect_det_cg_inst[4];
  initial begin
    foreach (combo_detect_det_cg_inst[i]) begin
      combo_detect_det_cg_inst[i] = new(i);
    end
  end

  /////////////////////
  // Sample function //
  /////////////////////
  function automatic void cg_combo_detect_actions_sample (
    int index,
    bit bat_disable,
    bit interrupt,
    bit ec_rst,
    bit rst_req
  );
    foreach (combo_detect_action_cg_inst[i]) begin
      combo_detect_action_cg_inst[index].sample(bat_disable, interrupt, ec_rst, rst_req);
    end
  endfunction

  function automatic void cg_combo_detect_sel_sample (
    int index,
    bit key0_in_sel,
    bit key1_in_sel,
    bit key2_in_sel,
    bit pwrb_in_sel,
    bit ac_present_sel
  );
    foreach (combo_detect_sel_cg_inst[i]) begin
      combo_detect_sel_cg_inst[index].sample(key0_in_sel, key1_in_sel, key2_in_sel,
                pwrb_in_sel, ac_present_sel);
    end
  endfunction

  function automatic void cg_combo_detect_det_sample(
    int index,
    bit [31:0] detection_timer
  );
    foreach (combo_detect_det_cg_inst[i]) begin
      combo_detect_det_cg_inst[index].sample(detection_timer);
    end
  endfunction

  function automatic void cg_auto_block_sample (
    bit [15:0] debounce_timer,
    bit auto_block_enable
  );
    sysrst_ctrl_auto_block_debounce_ctl_cg_inst.sample(debounce_timer, auto_block_enable);
  endfunction

   function automatic void cg_combo_intr_status_sample (
    bit combo0_h2l,
    bit combo1_h2l,
    bit combo2_h2l,
    bit combo3_h2l
  );
    sysrst_ctrl_combo_intr_status_cg_inst.sample(combo0_h2l,combo1_h2l,combo2_h2l,combo3_h2l);
  endfunction

  function automatic void cg_key_intr_status_sample (
    bit pwrb_h2l,
    bit key0_in_h2l,
    bit key1_in_h2l,
    bit key2_in_h2l,
    bit ac_present_h2l,
    bit ec_rst_l_h2l,
    bit flash_wp_l_h2l,
    bit pwrb_l2h,
    bit key0_in_l2h,
    bit key1_in_l2h,
    bit key2_in_l2h,
    bit ac_present_l2h,
    bit ec_rst_l_l2h,
    bit flash_wp_l_l2h
  );
    sysrst_ctrl_key_intr_status_cg_inst.sample(pwrb_h2l, key0_in_h2l, key1_in_h2l, key2_in_h2l,
           ac_present_h2l, ec_rst_l_h2l, flash_wp_l_h2l, pwrb_l2h, key0_in_l2h, key1_in_l2h,
           key2_in_l2h, ac_present_l2h, ec_rst_l_l2h, flash_wp_l_l2h);
  endfunction

  function automatic void cg_ulp_status_sample (
    bit ulp_wakeup
  );
    sysrst_ctrl_ulp_status_cg_inst.sample (ulp_wakeup);
  endfunction

  function automatic void cg_wkup_status_sample (
    bit wakeup_sts
  );
    sysrst_ctrl_wkup_status_cg_inst.sample(wakeup_sts);
  endfunction

  function automatic void cg_pin_in_value_sample (
    bit pwrb_in,
    bit key0_in,
    bit key1_in,
    bit key2_in,
    bit lid_open,
    bit ac_present,
    bit ec_rst_l,
    bit flash_wp_l
  );
    sysrst_ctrl_pin_in_value_cg_inst.sample (pwrb_in, key0_in,
        key1_in, key2_in, lid_open, ac_present, ec_rst_l, flash_wp_l);
  endfunction

   function automatic void cg_auto_blk_out_ctl_sample (
    bit key0_out_sel,
    bit key1_out_sel,
    bit key2_out_sel,
    bit key0_out_value,
    bit key1_out_value,
    bit key2_out_value
  );
    sysrst_ctrl_auto_blk_out_ctl_cg_inst.sample (key0_out_sel,
        key1_out_sel, key2_out_sel, key0_out_value, key1_out_value, key2_out_value);
  endfunction

endinterface
