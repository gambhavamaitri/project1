module sensorInterface(
    input wire clk,
    input wire reset,
    input wire sensor_data_ready,
    input wire [9:0] sensor_x, // 10-bit X coordinate
    input wire [9:0] sensor_y, // 10-bit Y coordinate
    output reg [9:0] touch_x,
    output reg [9:0] touch_y,
    output reg touch_valid
);

always @(posedge clk or posedge reset)
 begin
    if (reset)
     begin
        touch_x <= 10'b0;
        touch_y <= 10'b0;
        touch_valid <= 1'b0;
    end 
    else if (sensor_data_ready) 
    begin
        touch_x <= sensor_x;
        touch_y <= sensor_y;
        touch_valid <= 1'b1;
    end 
    else begin
        touch_valid <= 1'b0;
    end
end

endmodule
module CoordinateMapper (
    input wire [9:0] raw_x,
    input wire [9:0] raw_y,
    input wire touch_valid,
    output reg [9:0] screen_x,
    output reg [9:0] screen_y,
    output reg screen_valid
);

localparam SCREEN_WIDTH = 800;
localparam SCREEN_HEIGHT = 600;
localparam SENSOR_MAX = 1023;

always @(*) begin
    if (touch_valid) 
    begin
        screen_x = (raw_x * SCREEN_WIDTH) / SENSOR_MAX;
        screen_y = (raw_y * SCREEN_HEIGHT) / SENSOR_MAX;
        screen_valid = 1'b1;
    end 
    else begin
        screen_valid = 1'b0;
    end
end

endmodule


module GestureRecognition (
    input wire clk,
    input wire reset,
    input wire [9:0] screen_x,
    input wire [9:0] screen_y,
    input wire screen_valid,
    output reg gesture_tap,
    output reg gesture_swipe
);

localparam IDLE = 2'b00, TOUCH = 2'b01, SWIPE = 2'b10;

reg [1:0] state, next_state;
reg [9:0] last_x, last_y;

always @(posedge clk or posedge reset)
 begin
    if (reset)
     begin
        state <= IDLE;
        gesture_tap <= 1'b0;
        gesture_swipe <= 1'b0;
    end 
    else begin
        state <= next_state;
        if (screen_valid) 
        begin
            last_x <= screen_x;
            last_y <= screen_y;
        end
    end
end

always @(*) begin
    next_state = state;
    gesture_tap = 1'b0;
    gesture_swipe = 1'b0;
case (state)
        IDLE: begin
            if (screen_valid)
                next_state = TOUCH;
        end
        TOUCH: begin
            if (!screen_valid)
                gesture_tap = 1'b1; // Short press detected
            else if ((screen_x != last_x) || (screen_y != last_y))
                next_state = SWIPE;
        end
        SWIPE: begin
            gesture_swipe = 1'b1; // Swipe detected
            if (!screen_valid)
                next_state = IDLE;
        end
    endcase
end

endmodule


module DisplayController (
    input wire clk, 
    input wire reset, 
    input wire [9: 0] screen_x, 
    input wire [9: 0] screen_y, 
    input wire screen_valid, 
    output reg [3: 0] vga_r, 
    output reg [3: 0] vga_g, 
    output reg [3: 0] vga_b, 
    output wire vga_hsync,  // Changed to wire
    output wire vga_vsync   // Changed to wire
);

// VGA Parameters (800x600 @ 60Hz)
localparam H_RES = 800;
localparam V_RES = 600;
localparam H_FP = 40,  H_PW = 128,  H_BP = 88; // Front porch,  pulse width,  back porch
localparam V_FP = 1,  V_PW = 4,  V_BP = 23;

reg [9: 0] h_count = 0;
reg [9: 0] v_count = 0;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        h_count <= 0;
        v_count <= 0;
    end else begin
        if (h_count < H_RES + H_FP + H_PW + H_BP - 1)
            h_count <= h_count + 1;
        else begin
            h_count <= 0;
            if (v_count < V_RES + V_FP + V_PW + V_BP - 1)
                v_count <= v_count + 1;
            else
                v_count <= 0;
        end
    end
end
assign vga_hsync = (h_count >= H_RES + H_FP) && (h_count < H_RES + H_FP + H_PW);
assign vga_vsync = (v_count >= V_RES + V_FP) && (v_count < V_RES + V_FP + V_PW);

// Generate Display Output
always @(*) begin
    if (h_count < H_RES && v_count < V_RES) begin
        if (screen_valid && h_count == screen_x && v_count == screen_y) begin
            vga_r = 4'hF; // Display touch point in red
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end
    end else begin
        vga_r = 4'h0;
        vga_g = 4'h0;
        vga_b = 4'h0;
    end
end

endmodule

