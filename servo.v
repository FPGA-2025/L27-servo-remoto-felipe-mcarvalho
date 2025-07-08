module servo #(
    parameter CLK_FREQ = 25_000_000, // 25 MHz
    parameter PERIOD = 500_000 // 50 Hz (1/50s = 20ms, 25MHz / 50Hz = 500000 cycles)
) (
    input wire clk,
    input wire rst_n,
    output wire servo_out
);

    // Duty cycles para 1ms e 2ms
    localparam MIN_DUTY = PERIOD / 20; // 5% de 500_000 = 25_000
    localparam MAX_DUTY = PERIOD / 10; // 10% de 500_000 = 50_000

    // Contador para alternar a cada 5 segundos
    localparam SWITCH_TIME = CLK_FREQ * 5; // 5 segundos

    reg [31:0] duty_cycle;
    reg [31:0] switch_counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            switch_counter <= 0;
            duty_cycle <= MIN_DUTY;
        end 
        else begin
            if (switch_counter < SWITCH_TIME - 1)
                switch_counter <= switch_counter + 1;
            else begin
                switch_counter <= 0;
                duty_cycle <= (duty_cycle == MIN_DUTY) ? MAX_DUTY : MIN_DUTY;
            end
        end
    end

    PWM pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty_cycle),
        .period(PERIOD),
        .pwm_out(servo_out)
    );


endmodule