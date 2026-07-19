`default_nettype none

module tt_um_pine_pc_132 ( 
input  wire [7:0] ui_in,    // 8 Dedicated Digital Inputs 
output wire [7:0] uo_out,   // 8 Dedicated Digital Outputs 
input  wire [7:0] uio_in,   // 8 Bidirectional Inputs 
output wire [7:0] uio_out,  // 8 Bidirectional Outputs 
output wire [7:0] uio_oe,   // 8 Bidirectional Output Enables 
input  wire       ena,      // Will go high when design is active 
input  wire       clk,      // The Master 66MHz Clock Line 
input  wire       rst_n     // Reset line (active low)
);

// --- 1. INTERNAL 32-BIT ARCHITECTURE TRACKS (32x) ---
reg  [31:0] accumulator_register; // 32-bit Internal Memory Storage
wire [31:0] calculation_bus;      // 32-bit Math Highway
wire [1:0]  command_opcode;       // 2-bit Instruction Decoder
wire [5:0]  data_payload;         // 6-bit Incoming Number

// --- 2. DECODING THE INPUT BOARD PINS ---
// Top 2 pins control the math type. Bottom 6 pins carry your numbers.
assign command_opcode = ui_in[7:6];
assign data_payload   = ui_in[5:0];

// --- 3. THE 32-BIT MATH CALCULATOR HIGHWAY ---
// Automatically routes addition or subtraction instructions
assign calculation_bus = (command_opcode == 2'b01) ? (accumulator_register + data_payload) :
                         (command_opcode == 2'b10) ? (accumulator_register - data_payload) :
                         accumulator_register; // If command is 00, just hold the value stable

// --- 4. THE 66MHz CLOCK SPINE CONTROLLER ---
// Every time the 66MHz clock ticks, this executes instantly inside the silicon
always @(posedge clk) begin
    if (!rst_n) begin
        // If the reset switch is flipped, wipe memory back to zero
        accumulator_register <= 32'b0;
    end else if (ena) begin
        // Checkpoint: Save the computed 32-bit math answer into memory
        accumulator_register <= calculation_bus;
    end
end

// --- 5. DRIVING THE EXERTNAL OUTPUT PINS ---
// Splits our internal 32-bit memory so it fits onto the 8 output legs
assign uo_out = accumulator_register[7:0];

// Disable the bidirectional pins for safety so they don't fight other circuits
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

endmodule
