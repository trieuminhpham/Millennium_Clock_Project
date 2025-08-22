module day #(
    parameter SELECT_DAY = 3'b011
)(
    input wire clk_1Hz, rst_n, en_1, up, down,
    input wire [2:0] select_item, // chọn thành phần để chỉnh 011: ngày, ...
    input wire carry_in,
    input wire [3:0] month_bin,
    input wire leap_year,
    output reg [4:0] day_bin,
    output reg carry_out //báo tràn sang tháng
);

reg [4:0] max_day;

always @(month_bin or leap_year) begin
    case (month_bin)
        4'd4, 4'd6, 4'd9, 4'd11: max_day = 5'd30;
        4'd2: max_day = (leap_year ? 5'd29 : 5'd28);
        default: max_day = 5'd31;
    endcase
end

always @(posedge clk_1Hz or negedge rst_n) begin
    if (!rst_n) begin
        day_bin <= 5'd1;
        carry_out <= 1'b0;
    end
    else if (select_item == SELECT_DAY) begin //chỉnh
        if (up) begin
            if (day_bin == max_day)
                day_bin <= 5'd1;
            else
                day_bin <= day_bin + 1'b1;
        end
        else if (down) begin
            if (day_bin == 5'd1)
                day_bin <= max_day;
            else
                day_bin <= day_bin - 1'b1;
        end
        carry_out <= 1'b0; //Không tạo carry khi chỉnh tay
    end
    else if (en_1 && carry_in) begin //đếm
        if (day_bin == max_day) begin
            day_bin <= 5'd1;
            carry_out <= 1'b1;
        end
        else begin
            day_bin <= day_bin + 1'b1;
            carry_out <= 1'b0;
        end
    end
    else begin
        carry_out <= 1'b0;
    end
end
endmodule
