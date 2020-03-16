// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 
// Memory with 2 read ports, 1 write port
// ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  == 

module Memory #(parameter N_ELEMENTS = 128,        // Number of Memory Elements
                parameter ADDR_WIDTH = 16,         // Address Width (in bits)
                parameter DATA_WIDTH = 16)
               (input clk,                         // Clock
                input rst,                         // Reset (All entries -> 0)
                input [ADDR_WIDTH-1:0] r_addr_0,   // Read Address 0
                input [ADDR_WIDTH-1:0] r_addr_1,   // Read Address 1
                input [ADDR_WIDTH-1:0] w_addr,     // Write Address
                input [DATA_WIDTH-1:0] w_data,     // Write Data
                input w_en,                        // Write Enable
                output [DATA_WIDTH-1:0] r_data_0,  // Read Data 0
                output [DATA_WIDTH-1:0] r_data_1); // Read Data 1
    
    // Memory Unit
    reg [DATA_WIDTH-1:0] mem[N_ELEMENTS-1:0];
    
    
    //---------------------------------------------------------------------------
    // BEGIN MEMORY INITIALIZATION BLOCK
    //   - Paste the code you generate for memory initialization in synthesis
    //     here, deleting the current code.
    //   - Use the LC3 Assembler on Blackboard to generate your Verilog.
    //---------------------------------------------------------------------------
    localparam PROGRAM_LENGTH = 45;
    wire [DATA_WIDTH-1:0] mem_init[PROGRAM_LENGTH-1:0];
    
    assign mem_init[0]  = 16'h2228;   // LD R1, #40
    assign mem_init[1]  = 16'h2428;   // LD R2, #40
    assign mem_init[2]  = 16'h94BF;   // NOT R2, R2
    assign mem_init[3]  = 16'h14A1;   // ADD R2, R2, #1
    assign mem_init[4]  = 16'h1042;   // ADD R0, R1, R2
    assign mem_init[5]  = 16'h0C1F;   // BRnz #31
    assign mem_init[6]  = 16'h2624;   // LD R3, #36
    assign mem_init[7]  = 16'h927F;   // NOT R1, R1
    assign mem_init[8]  = 16'h1261;   // ADD R1, R1, #1
    assign mem_init[9]  = 16'h5020;   // AND R0, R0, #0
    assign mem_init[10] = 16'h1043;   // ADD R0, R1, R3
    assign mem_init[11] = 16'h0205;   // BRp #5
    assign mem_init[12] = 16'h127F;   // ADD R1, R1, #-1
    assign mem_init[13] = 16'h927F;   // NOT R1, R1
    assign mem_init[14] = 16'h1901;   // ADD R4, R4, R1
    assign mem_init[15] = 16'h16E1;   // ADD R3, R3, #1
    assign mem_init[16] = 16'h03F6;   // BRp #-10
    assign mem_init[17] = 16'h14BF;   // ADD R2, R2, #-1
    assign mem_init[18] = 16'h94BF;   // NOT R2, R2
    assign mem_init[19] = 16'h2617;   // LD R3, #23
    assign mem_init[20] = 16'h94BF;   // NOT R2, R2
    assign mem_init[21] = 16'h14A1;   // ADD R2, R2, #1
    assign mem_init[22] = 16'h5020;   // AND R0, R0, #0
    assign mem_init[23] = 16'h1083;   // ADD R0, R2, R3
    assign mem_init[24] = 16'h0205;   // BRp #5
    assign mem_init[25] = 16'h14BF;   // ADD R2, R2, #-1
    assign mem_init[26] = 16'h94BF;   // NOT R2, R2
    assign mem_init[27] = 16'h1B42;   // ADD R5, R5, R2
    assign mem_init[28] = 16'h16E1;   // ADD R3, R3, #1
    assign mem_init[29] = 16'h03F6;   // BRp #-10
    assign mem_init[30] = 16'h9B7F;   // NOT R5, R5
    assign mem_init[31] = 16'h1B61;   // ADD R5, R5, #1
    assign mem_init[32] = 16'h1D44;   // ADD R6, R5, R4
    assign mem_init[33] = 16'h5262;   // AND R1, R1, #2
    assign mem_init[34] = 16'h5481;   // AND R2, R2, R1
    assign mem_init[35] = 16'h2408;   // LD R2, #8
    assign mem_init[36] = 16'hC080;   // JMP R2
    assign mem_init[37] = 16'h1DA1;   // ADD R6, R6, #1
    assign mem_init[38] = 16'h3C01;   // ST R6, #1
    assign mem_init[39] = 16'hF000;   // HALT
    assign mem_init[40] = 16'h0000;   // 0000
    assign mem_init[41] = 16'h000C;   // 000C
    assign mem_init[42] = 16'h000B;   // 000B
    assign mem_init[43] = 16'h0001;   // 0001
    assign mem_init[44] = 16'h0026;   // 0026
    
    
    //---------------------------------------------------------------------------
    // END MEMORY INITIALIZATION BLOCK
    //---------------------------------------------------------------------------
    
    // Continuous Read
    assign r_data_0 = mem[r_addr_0];
    assign r_data_1 = mem[r_addr_1];
    
    // Synchronous Reset + Write
    genvar i;
    generate
    for (i = 0; i < N_ELEMENTS; i = i + 1) begin : wport
    always @(posedge clk) begin
        if (rst) begin
            if (i < PROGRAM_LENGTH) begin
                `ifndef SIM
                mem[i] <= mem_init[i];
                `endif
            end
            else begin
                `ifndef SIM
                mem[i] <= 0;
                `endif
            end
        end
        else if (w_en && w_addr == i) begin
            mem[i] <= w_data;
        end
            end
            end
            endgenerate
            
            endmodule
