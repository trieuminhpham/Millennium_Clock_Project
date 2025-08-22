module Gen_1Hz (
    input  wire clk_50Mhz,
    input  wire rst_n,
    output wire clk_1Hz
);
    parameter MAX_COUNT = 50_000_000 - 1;
    reg [25:0] counter_reg;


    always @(posedge clk_50Mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= 26'd0;
        end
        else begin
            if (counter_reg == MAX_COUNT) begin
                counter_reg <= 26'd0;
            end
            else begin
                counter_reg <= counter_reg + 1;
            end
        end
    end
    assign clk_1Hz = (counter_reg == MAX_COUNT);

endmodule