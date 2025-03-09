`timescale 1ns / 1ps

module pwm_multiplier_tb;
    reg clk = 0;
    reg pwm_in = 0;
    wire pwm_out;

    // Exposing internal signals
    wire pwm_prev;
    wire [15:0] high_counter;
    wire [15:0] low_counter;
    wire [15:0] latched_high_time;
    wire [15:0] latched_low_time;
    wire [15:0] output_counter;
    wire high_count_enable;
    wire low_count_enable;
    wire cycle_detected_flag;

    integer cycle_count = 0;
    integer high_time = 500000; // Default: 50% Duty Cycle (500 µs HIGH)
    integer low_time = 500000;  // Default: 50% Duty Cycle (500 µs LOW)

    // Instantiate the DUT (Device Under Test)
    pwm_multiplier uut (
        .clk(clk),
        .pwm_in(pwm_in),
        .pwm_out(pwm_out),
        .pwm_prev(pwm_prev),
        .high_counter(high_counter),
        .low_counter(low_counter),
        .latched_high_time(latched_high_time),
        .latched_low_time(latched_low_time),
        .output_counter(output_counter),
        .high_count_enable(high_count_enable),
        .low_count_enable(low_count_enable),
        .cycle_detected_flag(cycle_detected_flag)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock → 10 ns period

    // Generate a test PWM signal with changing duty cycles
    initial begin
        $dumpfile("pwm_multiplier_tb.vcd");
        $dumpvars(0, pwm_multiplier_tb, uut);

        pwm_in = 0;
        #10;

        forever begin
            // PWM HIGH
            pwm_in = 1;
            #high_time;
            
            // PWM LOW
            pwm_in = 0;
            #low_time;

            // Increment cycle count
            cycle_count = cycle_count + 1;

            // Change duty cycle every 4 full cycles
            if (cycle_count % 4 == 0) begin
                case (cycle_count / 4 % 3)
                    0: begin 
                        high_time = 500000; // 50% duty cycle
                        low_time = 500000;
                    end
                    1: begin 
                        high_time = 750000; // 75% duty cycle
                        low_time = 250000;
                    end
                    2: begin 
                        high_time = 250000; // 25% duty cycle
                        low_time = 750000;
                    end
                endcase
            end
        end
    end

    // Simulation runtime
    initial begin
        #20000000; // Run simulation for 20 ms
        $display("Simulation complete.");
        $finish;
    end

endmodule
