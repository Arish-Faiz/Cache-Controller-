`timescale 1ns / 1ps

module cache_tb;

    //-- Testbench signals --//
    reg clk;
    reg rst_n;
    reg [3:0] cpu_req_addr;
    reg [7:0] cpu_req_datain;
    reg cpu_req_rw;
    reg cpu_req_valid;
    wire [7:0] cpu_req_dataout;
    wire cache_ready;

    // We will simulate the main memory with a simple array
    reg [7:0] main_memory [15:0]; 

    //-- Instantiate the Cache Controller (Device Under Test) --//
    // Note: I've removed the main_mem ports for this simple test
    reg32 dut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_req_addr(cpu_req_addr),
        .cpu_req_datain(cpu_req_datain),
        .cpu_req_dataout(cpu_req_dataout),
        .cpu_req_rw(cpu_req_rw),
        .cpu_req_valid(cpu_req_valid),
        .cache_ready(cache_ready)
        // Simplified: Not connecting main memory ports for now
    );

    //-- Clock Generation --//
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Create a 10ns (100MHz) clock
    end

    //-- Test Sequence --//
    initial begin
        // 1. Initialize and Reset the controller
        rst_n = 0;          // Assert reset (active low)
        cpu_req_valid = 0;
        cpu_req_rw = 0;     // Read mode
        cpu_req_addr = 4'b0;
        cpu_req_datain = 8'b0;

        // Initialize some values in our fake main memory
        main_memory[4'hA] = 8'hBE; // Address 1010 will have data BE
        main_memory[4'hB] = 8'hEF; // Address 1011 will have data EF

        #20 rst_n = 1;      // De-assert reset

        // Wait for the cache to be ready
        wait(cache_ready);

        // 2. Perform a READ MISS
        // Request data from address 1010 (binary). Index=10, Tag=10
        $display("TB: Requesting READ from Address 1010 (miss expected)");
        cpu_req_addr = 4'b1010;
        cpu_req_rw = 0; // Read
        cpu_req_valid = 1;

        @(posedge clk);
        cpu_req_valid = 0; // Request lasts for one cycle

        // The controller should now be busy (cache_ready = 0).
        // It will go through ALLOCATE state to fetch data.
        // In a real system, it would read from memory. We'll just wait.
        wait(cache_ready);
        $display("TB: Controller is ready again. Miss handled.");

        // 3. Perform a READ HIT
        // Request data from the same address 1010 again.
        $display("TB: Requesting READ from Address 1010 again (hit expected)");
        cpu_req_addr = 4'b1010;
        cpu_req_rw = 0; // Read
        cpu_req_valid = 1;

        @(posedge clk);
        cpu_req_valid = 0;

        // This time, it should be a hit and finish quickly.
        wait(cache_ready);
        $display("TB: Controller is ready. Hit handled. Data out = %h", cpu_req_dataout);

        // 4. Perform a WRITE operation
        $display("TB: Requesting WRITE to Address 1011");
        cpu_req_addr = 4'b1011;
        cpu_req_datain = 8'hC0; // Write data C0
        cpu_req_rw = 1; // Write
        cpu_req_valid = 1;

        @(posedge clk);
        cpu_req_valid = 0;

        wait(cache_ready);
        $display("TB: Controller is ready. Write handled.");

        #100;
        $finish; // End the simulation
    end

endmodule
