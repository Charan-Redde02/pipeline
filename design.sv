module pipeline_processor(
    input clk,
    input reset
);
    // Registers for PC and memory
    reg [31:0] pc;
    reg [31:0] instruction_memory [0:15];
    reg [31:0] register_file [0:31];

    // Pipeline registers
    reg [31:0] IF_ID_instr, IF_ID_pc;
    reg [31:0] ID_EX_operand1, ID_EX_operand2, ID_EX_dest, ID_EX_instr;
    reg [31:0] EX_MEM_result, EX_MEM_dest, EX_MEM_instr;
    reg [31:0] MEM_WB_result, MEM_WB_dest, MEM_WB_instr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            IF_ID_instr <= 0;
            IF_ID_pc <= 0;
            ID_EX_operand1 <= 0;
            ID_EX_operand2 <= 0;
            ID_EX_dest <= 0;
            ID_EX_instr <= 0;
            EX_MEM_result <= 0;
            EX_MEM_dest <= 0;
            EX_MEM_instr <= 0;
            MEM_WB_result <= 0;
            MEM_WB_dest <= 0;
            MEM_WB_instr <= 0;
        end else begin
            // Instruction Fetch (IF)
            IF_ID_instr <= instruction_memory[pc >> 2];
            IF_ID_pc <= pc;
            pc <= pc + 4;

            // Instruction Decode (ID)
            ID_EX_operand1 <= register_file[IF_ID_instr[25:21]];
            ID_EX_operand2 <= register_file[IF_ID_instr[20:16]];
            ID_EX_dest <= IF_ID_instr[15:11];
            ID_EX_instr <= IF_ID_instr;

            // Execute (EX)
            case (ID_EX_instr[31:26])
                6'b000000: EX_MEM_result <= ID_EX_operand1 + ID_EX_operand2; // ADD
                6'b000001: EX_MEM_result <= ID_EX_operand1 - ID_EX_operand2; // SUB
                6'b000010: EX_MEM_result <= ID_EX_operand1 & ID_EX_operand2; // AND
                default: EX_MEM_result <= 0;
            endcase
            EX_MEM_dest <= ID_EX_dest;
            EX_MEM_instr <= ID_EX_instr;

            // Memory Access (MEM)
            MEM_WB_result <= EX_MEM_result;
            MEM_WB_dest <= EX_MEM_dest;
            MEM_WB_instr <= EX_MEM_instr;

            // Write Back (WB)
            if (MEM_WB_dest != 0) register_file[MEM_WB_dest] <= MEM_WB_result;
        end
    end
endmodule
