//=============================================================
// Control Unit for PUnC LC3 Processor
//=============================================================
`include "Defines.v"

module PUnCControl(input	wire clk,                  // Clock
                   input	wire rst,                  // Reset
                   input 	wire	[3:0]	DPATH_op_code,
                   output	reg	[2:0]	state,
                   output	reg			mem_w_en,
                   output	reg			reg_w_en,
                   output	reg			ir_w_en,
                   output	reg			status_w_en,
                   output	reg			pc_w_en,
                   output	reg			oc_ldi_first,
                   output	reg			oc_ldi_second);

// FSM States
localparam	STATE_FETCH		  = 3'b001;
localparam	STATE_DECODE	  = 3'b010;
localparam	STATE_EXECUTE	 = 3'b100;

// Instruction completion
reg	[1:0]	instr_length, instr_current, instr_next;

// Next State local var
reg [2:0] next_state;

// Output Combinational Logic
always @(*) begin
    // Output logic
    case (state)
        // Default: all w_en disabled
        STATE_FETCH: begin
            // Enable write to internal registers
            ir_w_en = 1;
        end
        STATE_DECODE: begin
            // Enable write to program counter
            pc_w_en = 1;
            end
            
            STATE_EXECUTE: begin
                status_w_en = 1;
                // Determine how long this instruction will take to complete
                    if (DPATH_op_code == `OC_LDI) begin
                        instr_length = 2;
                    end else begin
                        instr_length = 1;
                    end
            end
    endcase
    
    // Update LDI information lines continously
    if (state == STATE_EXECUTE) begin
        if (DPATH_op_code == `OC_LDI) begin
            if (instr_current == 1) begin
                oc_ldi_first  = 1;
                oc_ldi_second = 0;
                end else if (instr_current == 2) begin
                oc_ldi_second = 1;
                oc_ldi_first  = 0;
                end else begin
                oc_ldi_first  = 0;
                oc_ldi_second = 0;
            end
        end
        end else begin
        oc_ldi_first  = 0;
        oc_ldi_second = 0;
    end
end

// Next State Combinational Logic
always @(*) begin
    // Set default value for next state here
    next_state = state;
    
    // Add your next-state logic here
    case (state)
        STATE_FETCH: begin
            next_state = STATE_DECODE;
        end
        STATE_DECODE: begin
            next_state = STATE_EXECUTE;
        end
        STATE_EXECUTE: begin
            if (DPATH_op_code == `OC_HLT) begin
                next_state = STATE_EXECUTE;
                end else if (instr_length == instr_current) begin
                    next_state = STATE_FETCH;
                end
            end
    endcase
    
end

// Memory update sequential logic
always @(posedge clk) begin
    if (state == STATE_EXECUTE) begin
        // Check on these, might not be set 1 in execute
        if (DPATH_op_code == `OC_ST || DPATH_op_code == `OC_STI || DPATH_op_code == `OC_STR) begin
            mem_w_en <= 1;
        end
        
        if (DPATH_op_code == `OC_ADD || DPATH_op_code == `OC_AND || DPATH_op_code == `OC_JMP ||
        DPATH_op_code == `OC_JSR || DPATH_op_code == `OC_LD || DPATH_op_code == `OC_LDI ||
        DPATH_op_code == `OC_LDR || DPATH_op_code == `OC_NOT || DPATH_op_code == `OC_LEA) begin
        reg_w_en <= 1;
    end
    
    if (DPATH_op_code == `OC_BR || DPATH_op_code == `OC_JMP || DPATH_op_code == `OC_JSR) begin
        pc_w_en <= 1;
    end
    
    // MIGHT ALSO NEED STATUS WRITE ENABLE IN OTHER METHODS!
    if (DPATH_op_code == `OC_ADD) begin
        status_w_en <= 1;
    end
end
else begin
mem_w_en    <= 0;
reg_w_en    <= 0;
pc_w_en     <= 0;
status_w_en <= 0;
end
end

// State Update Sequential Logic
always @(posedge clk) begin
    // Consider RST being high
    if (rst) begin
        state <= STATE_FETCH;
    end
    else begin
        if(state == STATE_DECODE) begin
            instr_current <= 2'b01;
            instr_next    <= 2'b10;
        end
        // Update time in current state
        if (state == STATE_EXECUTE) begin
            instr_current <= instr_next;
        end
        
        // Update state
        state <= next_state;
    end
end

endmodule
