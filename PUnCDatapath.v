//=====================================================
// Datapath for PUnC LC3 Processor
// Author: Jonathan Pollock & Artemis Veizi
//=====================================================
`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(input	wire	clk,
                    input	wire	rst,
                    input	wire	CNTRL_ir_w_en,
                    input	wire	CNTRL_pc_w_en,
                    input	wire	CNTRL_regfiles_w_en,
                    input	wire	CNTRL_memory_w_en,
                    input	wire	CNTRL_status_w_en,
                    input	wire	CNTRL_OC_LDI_first,
                    input	wire	CNTRL_OC_LDI_second,
                    input	wire	[2:0] CNTRL_state,       // CNTRL_state for input
                    input	wire 	[15:0] mem_debug_addr,
                    input	wire 	[2:0] rf_debug_addr,
                    output	wire 	[15:0] mem_debug_data,
                    output	wire 	[15:0] rf_debug_data,
                    output	wire 	[15:0] pc_debug_data,
                    output reg [3:0] op_code);

localparam STATE_FETCH		  = 3'b001;
localparam STATE_DECODE		 = 3'b010;
localparam STATE_EXECUTE	 = 3'b100;

// Local Registers
reg	[15:0] pc;
reg [15:0] pc_next;
reg	[15:0] ir;
reg [15:0] LDI_buffer;
reg [15:0] pc_buffer;
// Stores processor value data
reg	[15:0] alu;
// Stores status registers
reg	STATUS_REG_ZERO;
reg	STATUS_REG_POS;
reg	STATUS_REG_NEG;

// Declare other local wires and registers here
// Local Data Lines for RFILE inputs and outputs
reg		[2:0]	RFILE_r_addr_0;
reg 	[2:0]	RFILE_r_addr_1;
wire	[15:0]	RFILE_r_data_0;
wire	[15:0]	RFILE_r_data_1;
reg		[2:0]	RFILE_w_addr;
reg		[15:0]	RFILE_w_data;

// Local Data Lines for MEMORY inputs and outputs
reg		[15:0]	MEMORY_r_addr;
wire	[15:0]	MEMORY_r_data;
reg		[15:0]	MEMORY_w_addr;
reg 	[15:0]	MEMORY_w_data;

//
wire    [15:0] pc_comb;

// Assign PC debug net
assign	pc_debug_data = pc;
assign  pc_comb = pc;



//----------------------------------------------------------------------
// Memory Module
//----------------------------------------------------------------------

// 1024-entry 16-bit memory (connect other ports)
Memory mem(
.clk      (clk),
.rst      (rst),
.r_addr_0 (MEMORY_r_addr),
.r_addr_1 (mem_debug_addr),
.w_addr   (MEMORY_w_addr),
.w_data   (MEMORY_w_data),
.w_en     (CNTRL_memory_w_en),
.r_data_0 (MEMORY_r_data),
.r_data_1 (mem_debug_data)
);

//----------------------------------------------------------------------
// Register File Module
//----------------------------------------------------------------------

// 8-entry 16-bit register file (connect other ports)
RegisterFile rfile(
.clk      (clk),
.rst      (rst),
.r_addr_0 (RFILE_r_addr_0),
.r_addr_1 (RFILE_r_addr_1),
.r_addr_2 (rf_debug_addr),
.w_addr   (RFILE_w_addr),
.w_data   (RFILE_w_data),
.w_en     (CNTRL_regfiles_w_en),
.r_data_0 (RFILE_r_data_0),
.r_data_1 (RFILE_r_data_1),
.r_data_2 (rf_debug_data)
);

//----------------------------------------------------------------------
// Add all other datapath logic here
//----------------------------------------------------------------------

// Clock edge logic
// Only <= non-blocking logic
always @ (posedge clk) begin
    // Check for reset. Reset takes two clock cycles.
    if (rst) begin
        // reset status Registers to zero
        STATUS_REG_NEG  <= 0;
        STATUS_REG_POS  <= 0;
        STATUS_REG_ZERO <= 0;

        pc <= 16'd0;        
    end
    
    // Else begin standard posedge logic
    else begin
    if (CNTRL_state == STATE_FETCH) begin
        pc_next <= pc + 16'd1;
    end
    
    if (CNTRL_state == STATE_DECODE) begin
        pc <= pc_next;
    end
    
    if (CNTRL_state == STATE_EXECUTE) begin
        // Control logic controls write enables
        // Not needed to write anything here
        // But, at clockedge the values in the alu
        // get stored in their proper location
        

        if (op_code == `OC_JSR) begin
            pc <= pc_buffer;
        end
        
        if (op_code == `OC_BR) begin
            pc <= pc_buffer;
        end

        if (op_code == `OC_JMP) begin
            pc <= pc_buffer;
        end
        
        // Set status register
        if (op_code == `OC_ADD || op_code == `OC_AND) begin
            // Check for zero alu
            if (alu == 16'd0) begin
                STATUS_REG_ZERO <= 1;
            end
            else begin
                STATUS_REG_ZERO <= 0;
            end
            
            // Check for pos alu
            if (alu != 16'd0 && alu[15] == 0) begin
                STATUS_REG_POS <= 1;
            end
            else begin
                STATUS_REG_POS <= 0;
            end
            
            // Check for neg alu
            if (alu != 16'd0 && alu[15] == 1) begin
                STATUS_REG_NEG <= 1;
            end
            else begin
                STATUS_REG_NEG <= 0;
            end
        end
    end
end

end

// Combinational logic directs values to the alu and determines
// read lines for edge logic to utilize.
// This logic does not write any values to registers ONLY memory.
// Only use with = (blocking assignment)
always @ (*) begin
    // Send the op_code to the controller
    op_code = ir[`OC];
    
    // Use pc accordingly
    if(CNTRL_state == STATE_FETCH) begin
        MEMORY_r_addr = pc_comb;
    end

    // Store the value of the instruction register.
    if(CNTRL_state == STATE_DECODE) begin
        ir            = MEMORY_r_data;
    end
    
    // Execute the function on the execute state
    if(CNTRL_state == STATE_EXECUTE)
    case (op_code)
        // STATUS REGISTER SET?
        `OC_ADD: begin
            // Distinguish ADD type
            case (ir[`IMM_BIT_NUM])
                // ADD immediate
                `IS_IMM: begin
                    // Set r_data_0 to SR1
                    RFILE_r_addr_0 = ir[8:6];
                    
                    // Set alu to r_data_0 + sext(imm5)
                    alu = RFILE_r_data_0 + { {11{ir[4]}}, ir[4:0] };
                    
                    // Set write data value
                    RFILE_w_data = alu;
                end
                // ADD Registers
                (!(`IS_IMM)): begin
                    // Set r_data_0 to SR1
                    RFILE_r_addr_0 = ir[8:6];
                    
                    // Set r_data_1 to SR2
                    RFILE_r_addr_1 = ir[2:0];
                    
                    // Set alu to r_data_0 + r_data_1
                    alu = RFILE_r_data_0 + RFILE_r_data_1;
                    
                    // Set write data value
                    RFILE_w_data = alu;
                end
            endcase
            
            // Prepare storage lines
            RFILE_w_addr = ir[11:9];
            
            // On next posedge clk, the control will enable the write to memory
        end
        
        `OC_AND: begin
            // Distinguise AND type
            case (ir[`IMM_BIT_NUM])
                // AND immediate
                `IS_IMM: begin
                    // Set r_data_0 to SR1
                    RFILE_r_addr_0 = ir[8:6];
                    
                    // Set alu to r_data_0 and sext(imm5)
                    alu = RFILE_r_data_0 & { {11{ir[4]}}, ir[4:0] };
                    
                    // Set write data value
                    RFILE_w_data = alu;
                end
                // AND registers
                (!(`IS_IMM)): begin
                    // Set r_data_0 to SR1
                    RFILE_r_addr_0 = ir[8:6];
                    
                    // Set r_data_1 to SR2
                    RFILE_r_addr_1 = ir[2:0];
                    
                    // Set alu to r_data_0 & r_data_1
                    alu = RFILE_r_data_0 & RFILE_r_data_1;
                    
                    // Set write data value
                    RFILE_w_data = alu;
                end
            endcase
            // Prepare storage lines
            RFILE_w_addr = ir[11:9];
        end
        
        `OC_BR: begin
            if ((ir[`BR_N] && STATUS_REG_NEG) ||
                (ir[`BR_Z] && STATUS_REG_ZERO) ||
                (ir[`BR_P] && STATUS_REG_POS)) begin
                // sequentially set alu to PC + sext(PCoffset 9)
                alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
            
            // set pc_buffer to alu
            pc_buffer = alu;
            end else begin
                pc_buffer = pc_comb;
            end
        end
        
        `OC_JMP: begin
            // Distinguish between JMP and RET cases
            // JMP to BaseR
            if (ir != 16'b1100000111000000) begin
                // sets r_data_0 to JumpR
                RFILE_r_addr_0 = ir[8:6];
                
                // Set PC to BaseR
                pc_buffer = RFILE_r_data_0;
            end
            // RET to R7
            else if (ir == 16'b1100000111000000) begin
                // Set r_data_0 to R7
                RFILE_r_addr_0 = 3'd7;
                
                // Set PC to R7
                pc_buffer = RFILE_r_data_0;
            end
        end
        `OC_JSR: begin
            // Regardless store PC in R7
            RFILE_w_addr = 3'd7;
            
            // Prepare R7 Data Lines
            RFILE_w_data = pc_comb;
            
            // Consider JSR and JSRR cases
            case (ir[`JSR_BIT_NUM])
                // JSR Case
                `IS_JSR: begin
                    pc_buffer = pc_comb + { {7{ir[8]}}, ir[8:0] };
                end
                // JSRR Case
                (!(`IS_JSR)): begin
                    // Get value at BaseR
                    RFILE_r_addr_0 = ir[8:6];
                    
                    // Set pc update buffer to
                    pc_buffer = RFILE_r_data_0;
                end
            endcase
        end
        `OC_LD: begin
            // Set alu to pc + sext(offset)
            alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
            
            // Read data at mem alu
            MEMORY_r_addr = alu;
            
            // Set DR adr lines
            RFILE_w_addr = ir[11:9];
            
            // Prepare DR data lines
            RFILE_w_data = MEMORY_r_data;
        end
        `OC_LDI: begin
            // First CLock Cycle (acts asynchronously)
            if (CNTRL_OC_LDI_first) begin
                // Set alu to pc + sext(offset)
                alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
                
                // Get value at mem[alu]
                MEMORY_r_addr = alu;
                
                // Store value in LDI buffer
                LDI_buffer = MEMORY_r_data;
            end
            // Second Clock Cycle (acts sequentially)
            else if (CNTRL_OC_LDI_second) begin
                // Read mem[mem[alu]]
                MEMORY_r_addr = LDI_buffer;
                
                // Store value in DR
                RFILE_w_addr = ir[11:9];
                
                // Prepare data lines for DR
                RFILE_w_data = MEMORY_r_data;
            end
        end
        `OC_LDR: begin
            // Get value of BaseR
            RFILE_r_addr_0 = ir[8:6];
            
            // Compute BaseR + sext(offset6)
            alu = RFILE_r_data_0 + { {10{ir[5]}}, ir[5:0] };
            
            // Get value at mem[alu]
            MEMORY_r_addr = alu;
            
            // Set DR addr lines
            RFILE_w_addr = ir[11:9];
            
            // Prepare DR data lines
            RFILE_w_data = MEMORY_r_data;
        end
        `OC_LEA: begin
            // Set alu to PC + offset9
            alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
            
            // Set DR addr lines
            RFILE_w_addr = ir[11:9];
            
            // Prepare DR data lines
            RFILE_w_data = alu;
        end
        `OC_NOT: begin
            
            // Set DR = ~SR (bitwise not)
            RFILE_r_addr_0 = ir[8:6];
            RFILE_w_addr   = ir[11:9];
            alu            = ~RFILE_r_data_0;
            
            // Prepare data lines for DR
            RFILE_w_data = alu;
        end
        `OC_ST: begin
            // Mem write enable goes high
            // Set alu to PC + offset
            alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
            
            // Load SR into mem[alu]
            MEMORY_w_addr  = alu;
            RFILE_r_addr_0 = ir[11:9];
            MEMORY_w_data  = RFILE_r_data_0;
        end
        `OC_STI: begin
            // Mem write enable goes high
            // Set alu to PC + offset
            alu = pc_comb + { {7{ir[8]}}, ir[8:0] };
            // Set read from mem at alu
            MEMORY_r_addr = alu;
            MEMORY_w_addr = MEMORY_r_data;
            
            // Load SR into mem[mem[alu]]
            RFILE_r_addr_0 = ir[11:9];
            MEMORY_w_data  = RFILE_r_data_0;
        end
        `OC_STR: begin
            // Mem write enable goes high
            // Set alu to BaseR + offset6
            RFILE_r_addr_0 = ir[8:6];
            alu            = RFILE_r_data_0 + { {10{ir[5]}}, ir[5:0] };
            
            // Load SR into mem[alu]
            MEMORY_w_addr  = alu;
            RFILE_r_addr_1 = ir[11:9];
            MEMORY_w_data  = RFILE_r_data_1;
        end
    endcase
end

endmodule
