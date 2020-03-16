//==============================================================================
// Module for PUnC LC3 Processor
// Author: Artemis Veizi and Jonathan Pollock
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	wire INTER_ir_w_en;
	wire INTER_pc_w_en;
	wire INTER_regfiles_w_en;
	wire INTER_memory_w_en;
	wire INTER_status_w_en;

	wire INTER_OC_LDI_first;
	wire INTER_OC_LDI_second;

	wire [2:0] INTER_state;

	wire [3:0] INTER_op_code;
	
	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		// External inputs
		.clk			(clk),
		.rst			(rst),
		
		// Input from datapath
		.DPATH_op_code	(INTER_op_code),

		// Output to datapath	
		.state			(INTER_state),
		.ir_w_en		(INTER_ir_w_en),
		.pc_w_en		(INTER_pc_w_en),
		.reg_w_en		(INTER_regfiles_w_en),
		.mem_w_en		(INTER_memory_w_en),
		.status_w_en	(INTER_status_w_en),
		
		.oc_ldi_first	(INTER_OC_LDI_first),
		.oc_ldi_second	(INTER_OC_LDI_second)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Our Input Ports
		.CNTRL_state 			(INTER_state),
		.CNTRL_ir_w_en   		(INTER_ir_w_en),
		.CNTRL_pc_w_en   		(INTER_pc_w_en),
		.CNTRL_regfiles_w_en 	(INTER_regfiles_w_en),
		.CNTRL_memory_w_en 		(INTER_memory_w_en),
		.CNTRL_status_w_en 		(INTER_memory_w_en),

		.CNTRL_OC_LDI_first 	(INTER_OC_LDI_first),
		.CNTRL_OC_LDI_second 	(INTER_OC_LDI_second),
		
		// Our output ports
		.op_code 				(INTER_op_code)
	);

endmodule
