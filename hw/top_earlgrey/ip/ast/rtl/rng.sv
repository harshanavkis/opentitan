// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//############################################################################
// *Name: rng
// *Module Description:  Random (bit/s) Generator (Pseudo Model)
//############################################################################

module rng #(
  parameter int EntropyStreams = 4
) (
  input clk_i,                                // Non-Jittery Clock (TLUL)
  input rst_ni,                               // Non-Jittery Reset (TLUL)
  input clk_ast_rng_i,                        // Jittery Clock (RNG)
  input rst_ast_rng_ni,                       // Jittery Reset (RNG)
  input rng_en_i,                             // RNG Enable
  input rng_fips_i,                           // RNG FIPS Enable
  input scan_mode_i,                          // Scan Mode
  output logic [EntropyStreams-1:0] rng_b_o,  // RNG Bus/Bits Output
  output logic rng_val_o                      // RNG Bus/Bits Valid
);

///////////////////////////////////////
// RNG Bus using LFSR
///////////////////////////////////////
logic rst_n;
logic[EntropyStreams-1:0] lfsr_val;

assign rst_n = scan_mode_i ? rst_ni : rst_ni && rng_en_i;

// These LFSR parameters have been generated with
// $ ./util/design/gen-lfsr-seed.py --width 64 --seed 15513 --prefix "Rng"
localparam int RngLfsrWidth = 64;
typedef logic [RngLfsrWidth-1:0] rng_lfsr_seed_t;
typedef logic [RngLfsrWidth-1:0][$clog2(RngLfsrWidth)-1:0] rng_lfsr_perm_t;
localparam rng_lfsr_seed_t RndCnstRngLfsrSeedDefault = 64'h1d033d20eed3b14;
localparam rng_lfsr_perm_t RndCnstRngLfsrPermDefault = {
  128'h98c2c94ab5e40420ed73f6c7396cd9e1,
  256'h58c6d7435ddb2ed1f22400c53a5aaa796ef7785e120628fbabc87f0b3928550f
};

prim_lfsr #(
  .LfsrDw ( RngLfsrWidth ),
  .EntropyDw ( 1 ),
  .StateOutDw ( EntropyStreams ),
  .DefaultSeed ( RndCnstRngLfsrSeedDefault ),
  .StatePermEn ( 1'b1 ),
  .StatePerm ( RndCnstRngLfsrPermDefault ),
  .ExtSeedSVA ( 1'b0 )  // ext seed is unused
) u_rng_lfsr (
  .clk_i ( clk_i ),
  .rst_ni ( rst_n ),
  .lfsr_en_i ( rng_en_i ),
  .seed_en_i ( 1'b0 ),
  .seed_i ( '0 ),
  .entropy_i ( 1'b0 ),
  .state_o ( lfsr_val )
);

logic srate_rng_val;
logic [12-1:0] srate_cnt, srate_value;
logic [EntropyStreams-1:0] rng_b;

assign srate_value = 12'd120;

always_ff @( posedge clk_i, negedge rst_n ) begin
  if ( !rst_n ) begin
    srate_cnt     <= 12'h000;
    srate_rng_val <= 1'b0;
  end else if ( srate_cnt == srate_value ) begin
    srate_cnt     <= 12'h000;
    srate_rng_val <= 1'b1;
  end else begin
    srate_cnt     <= srate_cnt + 1'b1;
    srate_rng_val <= 1'b0;
  end
end


////////////////////////////////////////
// Sychronize Bus & Valid to RNG Clock
////////////////////////////////////////
logic sync_rng_val, srate_rng_val_en, src_busy;

ast_pulse_sync u_rng_val_pulse_sync (
  .scan_mode_i ( scan_mode_i ),
  .scan_reset_ni ( rst_n ),
  // source clock domain
  .clk_src_i ( clk_i ),
  .rst_src_ni ( rst_n ),
  .src_pulse_i ( srate_rng_val ),
  .src_pulse_en_o ( srate_rng_val_en ),
  .src_busy_o ( src_busy ),
  // destination clock domain
  .clk_dst_i ( clk_ast_rng_i ),
  .rst_dst_ni ( rst_ast_rng_ni ),
  .dst_pulse_o ( sync_rng_val )
);

// Sanple & Hold the rng_b value until the sync completes
always_ff @( posedge clk_i, negedge rst_n ) begin
  if ( !rst_n ) begin
    rng_b <= {EntropyStreams{1'b0}};
  end else if ( srate_rng_val_en ) begin
    rng_b <= lfsr_val[EntropyStreams-1:0];
  end
end

//Sync to RNG clock domain
always_ff @( posedge clk_ast_rng_i, negedge rst_ast_rng_ni ) begin
  if (!rst_ast_rng_ni ) begin
    rng_b_o <= {EntropyStreams{1'b0}};
    rng_val_o <= 1'b0;
  end else if ( sync_rng_val ) begin
    rng_b_o <= rng_b[EntropyStreams-1:0];
    rng_val_o <= 1'b1;
  end else begin
    rng_val_o <= 1'b0;
  end
end


///////////////////////
// Unused Signals
///////////////////////
logic unused_sigs;
assign unused_sigs = ^{
                        rng_fips_i,  // Used in ASIC implementation
                        src_busy
                      };

endmodule : rng
