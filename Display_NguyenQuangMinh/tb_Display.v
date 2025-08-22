`timescale 1ns / 1ps

module tb_Display;

    // Inputs
    reg clk;
    reg rst_n;
    reg en;
    reg smh_dmy;
    reg dem_chinh;
    reg [1:0] blink_led;
    reg [7:0] bcd_ss, bcd_mm, bcd_hh, bcd_dd, bcd_mo;
    reg [15:0] bcd_yyyy;

    // Outputs
    wire [6:0] led_segment;
    wire [7:0] dis_sel;

    // Instantiate the UUT
    Display uut (
        .clk(clk), .rst_n(rst_n), .en(en), .smh_dmy(smh_dmy), .dem_chinh(dem_chinh),
        .blink_led(blink_led), .bcd_ss(bcd_ss), .bcd_mm(bcd_mm), .bcd_hh(bcd_hh),
        .bcd_dd(bcd_dd), .bcd_mo(bcd_mo), .bcd_yyyy(bcd_yyyy),
        .led_segment(led_segment), .dis_sel(dis_sel)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end

    // Test procedure
    initial begin
        // Initialize Inputs
        rst_n = 0; en = 0; smh_dmy = 0; dem_chinh = 0; blink_led = 0;
        bcd_ss = 0; bcd_mm = 0; bcd_hh = 0;
        bcd_dd = 0; bcd_mo = 0; bcd_yyyy = 0;

        // Apply reset
        #50;
        rst_n = 1;
        $display("Reset released.");

        // Test Case 1: Display Time (12:34:56)
        $display("Test Case 1: Displaying time 12:34:56");
        en = 1;
        smh_dmy = 0; // Time mode
        dem_chinh = 0; // Normal count mode
        bcd_hh = 8'h12;
        bcd_mm = 8'h34;
        bcd_ss = 8'h56;
        #1_000_000; // Wait for some time to see the display scan

        // Test Case 2: Display Date (15-08-2025)
        $display("Test Case 2: Displaying date 15-08-2025");
        smh_dmy = 1; // Date mode
        bcd_dd = 8'h15;
        bcd_mo = 8'h08;
        bcd_yyyy = 16'h2025;
        #1_000_000;

        // Test Case 3: Adjust Mode - Blinking Hours (HH)
        $display("Test Case 3: Adjust mode, blinking MM (time mode)");
        smh_dmy = 0; // Back to time mode
        dem_chinh = 1; // Adjust mode on
        blink_led = 2'b10; // Select MM to blink
        #500_000_000; // Wait long enough to observe blinking

        // Test Case 4: Adjust Mode - Blinking Year (YYYY)
        $display("Test Case 4: Adjust mode, blinking YYYY (date mode)");
        smh_dmy = 1; // Date mode
        dem_chinh = 1; // Adjust mode on
        blink_led = 2'b11; // Select YYYY to blink
        #500_000_000;

        $display("Simulation Finished");
        $finish;
    end

endmodule