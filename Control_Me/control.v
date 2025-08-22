module control (
    input        clk,
    input        rst,
    input        dis_sel,     // 0: Giờ-phút-giây, 1: Ngày-tháng-năm
    input        mode_sel,    // 0: Đếm, 1: Chỉnh sửa
    input        adjust,      // Nút bấm chọn đối tượng chỉnh
    input        up_btn,      // Nút tăng (thô từ người dùng)
    input        down_btn,    // Nút giảm (thô từ người dùng)
    output reg   en_1,        // Cho phép counter chạy
    output reg [1:0] blink_group,       // Bật nhấp nháy khi chỉnh
    output reg   smh_dmy,     // Báo display hiển thị nhóm nào
    output reg   dem_chinh,   // Báo counter đếm hay chỉnh
    output reg [2:0] select_item, // Chọn đối tượng chỉnh (000..101)
    output reg   up,          // Xung tăng đã xử lý gửi counter
    output reg   down         // Xung giảm đã xử lý gửi counter
);

    // --- chống dội adjust ---
    reg adj_ff0, adj_ff1;
    wire adjust_posedge;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            adj_ff0 <= 0;
            adj_ff1 <= 0;
        end else begin
            adj_ff0 <= adjust;
            adj_ff1 <= adj_ff0;
        end
    end
    assign adjust_posedge = adj_ff0 & ~adj_ff1;

    // --- chống dội up ---
    reg up_ff0, up_ff1;
    wire up_posedge;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            up_ff0 <= 0;
            up_ff1 <= 0;
        end else begin
            up_ff0 <= up_btn;
            up_ff1 <= up_ff0;
        end
    end
    assign up_posedge = up_ff0 & ~up_ff1;

    // --- chống dội down ---
    reg down_ff0, down_ff1;
    wire down_posedge;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            down_ff0 <= 0;
            down_ff1 <= 0;
        end else begin
            down_ff0 <= down_btn;
            down_ff1 <= down_ff0;
        end
    end
    assign down_posedge = down_ff0 & ~down_ff1;

    // --- chọn đối tượng chỉnh ---
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            select_item <= 3'b000;
        end else if (mode_sel) begin
            if (adjust_posedge) begin
                if (select_item == 3'b101) // năm là mục cuối
                    select_item <= 3'b000;
                else
                    select_item <= select_item + 1'b1;
            end
        end else begin
            select_item <= 3'b000; // reset khi về chế độ đếm
        end
    end

// Ma hoa blink_group dua tren mode_sel va select_item

always @(mode_sel, smh_dmy, select_item) begin
    if (mode_sel) begin  // Chỉ khi chỉnh sửa
        if (smh_dmy == 0) begin  // Nhóm giờ-phút-giây
            case (select_item)
                3'b000: blink_group = 2'b00;  // Giây (seg2-3)
                3'b001: blink_group = 2'b01;  // Phút (seg4-5)
                3'b010: blink_group = 2'b10;  // Giờ (seg6-7) - cần thêm case trong Display
                default: blink_group = 2'b00;
            endcase
        end else begin  // Nhóm ngày-tháng-năm
            case (select_item)
                3'b011: blink_group = 2'b10;  // Ngày (seg6-7)
                3'b100: blink_group = 2'b01;  // Tháng (seg4-5)
                3'b101: blink_group = 2'b00;  // Năm (seg0-3)
                default: blink_group = 2'b00;
            endcase
        end
    end else begin
        blink_group = 2'b00;  // Không blink khi đếm
    end
end

    // --- điều khiển smh_dmy ---
    always @(dis_sel) begin
        smh_dmy = dis_sel; // nối thẳng từ input
    end

    // --- điều khiển dem_chinh và en_1 ---
    always @(mode_sel) begin
        if (mode_sel) begin
            dem_chinh = 1;  // chỉnh
            en_1      = 0;  // không chạy counter
        end else begin
            dem_chinh = 0;  // đếm
            en_1      = 1;  // bật counter
        end
    end

    // --- xuất tín hiệu up/down sạch cho counter ---
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            up   <= 0;
            down <= 0;
        end else if (mode_sel) begin
            // chỉ phát xung khi ở chế độ chỉnh
            up   <= up_posedge;
            down <= down_posedge;
        end else begin
            up   <= 0;
            down <= 0;
        end
    end

endmodule
