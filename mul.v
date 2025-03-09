module pwm_multiplier (
    input wire clk,         // System clock (e.g., 100 MHz)
    input wire pwm_in,      // Input PWM signal
    output reg pwm_out      // Output multiplied PWM
);

    reg pwm_prev;
    reg [15:0] high_counter;
    reg [15:0] low_counter;
    reg [15:0] latched_high_time;
    reg [15:0] latched_low_time;
    reg [15:0] output_counter;
    reg high_count_enable;
    reg low_count_enable;
    reg cycle_detected_flag;

    initial begin
        pwm_prev = 0;
        high_counter = 0;
        low_counter = 0;
        latched_high_time = 0;
        latched_low_time = 0;
        output_counter = 0;
        high_count_enable = 0;
        low_count_enable = 0;
        cycle_detected_flag = 0;
        pwm_out = 0;
    end

    wire rising_edge = (~pwm_prev & pwm_in);
    wire falling_edge = (pwm_prev & ~pwm_in);

    always @(posedge clk) begin
        pwm_prev <= pwm_in;

        if (rising_edge) begin
            cycle_detected_flag <= 1;
            latched_high_time <= high_counter;
            latched_low_time <= low_counter;
            high_count_enable <= 1;
            low_count_enable <= 0;
        end
        
        if (falling_edge) begin
            high_count_enable <= 0;
            low_count_enable <= 1;
        end
    end

    always @(posedge clk) begin
        if (cycle_detected_flag) begin
            cycle_detected_flag <= 0;
        end
    end

    always @(posedge clk) begin
        if (high_count_enable) begin
            high_counter <= high_counter + 1;
        end
    end

    always @(posedge clk) begin
        if (low_count_enable) begin
            low_counter <= low_counter + 1;
        end
    end

    reg cycle_detected_prev;

    always @(posedge clk) begin
        cycle_detected_prev <= cycle_detected_flag;
    end

    wire cycle_detected_negedge = (cycle_detected_prev && !cycle_detected_flag);

    always @(posedge clk) begin
        if (cycle_detected_negedge) begin
            high_counter <= 0;
            low_counter <= 0;
        end
    end

    always @(posedge clk) begin
        if (latched_high_time > 0) begin
            output_counter <= output_counter + 1;

            if (output_counter < (latched_high_time / 25)) begin
                pwm_out <= 0;
            end else if (output_counter < ((latched_high_time + latched_low_time) / 25)) begin
                pwm_out <= 1;
            end else begin
                output_counter <= 0;
            end
        end
    end

endmodule
