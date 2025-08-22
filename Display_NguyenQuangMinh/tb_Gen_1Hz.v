`timescale 1ns/1ps

module tb_Gen_1Hz;

    // Inputs
    reg clk_50Mhz;
    reg rst_n;

    // Outputs
    wire clk_1Hz;

    // Instantiate the Unit Under Test (UUT)
    Gen_1Hz uut (
        .clk_50Mhz(clk_50Mhz),
        .rst_n(rst_n),
        .clk_1Hz(clk_1Hz)
    );

    // Tạo clock 50MHz (chu kỳ 20ns)
    initial begin
        clk_50Mhz = 0;
        forever #10 clk_50Mhz = ~clk_50Mhz; // 10ns high, 10ns low -> 20ns period
    end

    // Quy trình kiểm thử
    initial begin
        // 1. Khởi tạo và reset
        $display("Starting simulation...");
        rst_n = 0; // Áp dụng reset
        #50;       // Giữ reset trong 50ns
        rst_n = 1; // Nhả reset
        $display("Reset released at time %t", $time);

        // Chờ xung 1Hz đầu tiên
        // Thời gian dự kiến = 50,000,000 * 20ns = 1,000,000,000 ns = 1s
        wait (clk_1Hz == 1);
        $display("First 1Hz pulse detected at time %t", $time);

        // Chờ xung 1Hz thứ hai để xác nhận chu kỳ
        wait (clk_1Hz == 0); // Đợi xung kết thúc
        wait (clk_1Hz == 1);
        $display("Second 1Hz pulse detected at time %t", $time);

        // 2. Kết thúc mô phỏng
        #100;
        $display("Simulation finished.");
        $finish;
    end

endmodule