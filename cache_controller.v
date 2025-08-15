module reg32 (
	clk,
	rst_n,
	cpu_req_addr,  //CPU signals
	cpu_req_datain,
	cpu_req_dataout,
	cpu_req_rw,
	cpu_req_valid,
	cache_ready,   //Cache ready////////////////////////////////////////////////////////
	mem_req_addr,  //Main memory signals	
	mem_req_datain,
	mem_req_dataout,
	mem_req_rw,
	mem_req_valid,
	mem_req_ready,
	cpu_req_addr_reg,
	tagmem_enable,
	hitcount,
	tag_mem_entry
	);
	

parameter IDLE        = 2'b00;
parameter COMPARE_TAG = 2'b01;
parameter ALLOCATE    = 2'b10;
parameter WRITE_BACK  = 2'b11;

input clk;
input rst_n;


//CPU request to cache controller
input [3:0] cpu_req_addr;
input [7:0] cpu_req_datain;
output [7:0] cpu_req_dataout;
input cpu_req_rw; //1=write, 0=read
input cpu_req_valid;

//Main memory request from cache controller
output [3:0] mem_req_addr;
input [7:0] mem_req_datain;
output [7:0] mem_req_dataout;
output mem_req_rw;
output mem_req_valid;
input mem_req_ready;
output [3:0]tag_mem_entry;

//Cache ready
output cache_ready;
output reg[3:0]hitcount;
//Cache consists of tag memory and data memory
//Tag memory = valid bit + dirty bit + tag
reg [3:0] tag_mem [3:0];
//Data memory holds the actual data in cache
reg [7:0] data_mem [3:0];

reg [1:0] present_state, next_state;
reg [7:0] cpu_req_dataout, next_cpu_req_dataout;
reg [7:0] cache_read_data;
reg cache_ready, next_cache_ready;
reg [3:0] mem_req_addr, next_mem_req_addr;
reg mem_req_rw, next_mem_req_rw;
reg mem_req_valid, next_mem_req_valid;
reg [7:0] mem_req_dataout, next_mem_req_dataout;
reg write_datamem_mem; //write operation from memory
reg write_datamem_cpu; //write operation from cpu
output reg tagmem_enable;
reg valid_bit, dirty_bit;

output reg [3:0] cpu_req_addr_reg;
reg[3:0] next_cpu_req_addr_reg;
reg [7:0] cpu_req_datain_reg, next_cpu_req_datain_reg;
reg cpu_req_rw_reg, next_cpu_req_rw_reg;

wire [1:0] cpu_addr_tag;
wire [1:0] cpu_addr_index;
//wire [3:0] tag_mem_entry;
wire [7:0] data_mem_entry;
wire hit;

//CPU Address = tag + index + block offset + byte offset
assign cpu_addr_tag         = cpu_req_addr_reg[3:2];
assign cpu_addr_index       = cpu_req_addr_reg[1:0];
assign tag_mem_entry  = tag_mem[cpu_addr_index];
assign data_mem_entry = data_mem[cpu_addr_index];
assign hit = tag_mem_entry[3] && (cpu_addr_tag == tag_mem_entry[1:0]);
integer i;
always @ (posedge clk )
begin
  if(!rst_n)
  begin
	 for (i = 0; i < 4; i = i + 1) begin
        tag_mem[i] <= 4'b0; // Invalidate all entries
        data_mem[i] <= 8'b0;
    end
	present_state   	<= IDLE;
	cpu_req_dataout 	<= 4'd0;
	cache_ready     	<= 1'b0;
	mem_req_addr    	<= 4'd0;
	mem_req_rw      	<= 1'b0;
	mem_req_valid   	<= 1'b0;
	mem_req_dataout 	<= 8'd0;
	cpu_req_addr_reg	<= 1'b0;
	cpu_req_datain_reg  	<= 8'd0;
	cpu_req_rw_reg  	<= 1'b0;
	
	
  end
  else
  begin
    	tag_mem[cpu_addr_index]  <= tagmem_enable ? {valid_bit,dirty_bit,cpu_addr_tag} : tag_mem[cpu_addr_index];
   	data_mem[cpu_addr_index] <= write_datamem_mem ? mem_req_datain : write_datamem_cpu ? cpu_req_datain_reg : data_mem[cpu_addr_index];
	present_state   	<= next_state;
	cpu_req_dataout 	<= next_cpu_req_dataout;
	cache_ready     	<= next_cache_ready;
	mem_req_addr    	<= next_mem_req_addr;
	mem_req_rw      	<= next_mem_req_rw;
	mem_req_valid   	<= next_mem_req_valid;
	mem_req_dataout 	<= next_mem_req_dataout;
	cpu_req_addr_reg	<= next_cpu_req_addr_reg;
	cpu_req_datain_reg  	<= next_cpu_req_datain_reg;
	cpu_req_rw_reg  	<= next_cpu_req_rw_reg;
  end
 end
 
always @ (*)
begin
write_datamem_mem    = 1'b0;
write_datamem_cpu    = 1'b0;
valid_bit            = 1'b0;
dirty_bit            = 1'b0;
tagmem_enable        = 1'b0;
next_state           = present_state;
next_cpu_req_dataout = cpu_req_dataout;
next_cache_ready     = 1'b1;
next_mem_req_addr    = mem_req_addr;
next_mem_req_rw      = mem_req_rw;
next_mem_req_valid   = mem_req_valid;
next_mem_req_dataout = mem_req_dataout;
next_cpu_req_addr_reg  = cpu_req_addr_reg;
next_cpu_req_datain_reg  = cpu_req_datain_reg;
next_cpu_req_rw_reg  = cpu_req_rw_reg;

case(present_state)
  IDLE:
  begin
    if (cpu_req_valid)
    begin
    next_cpu_req_addr_reg  = cpu_req_addr;
    next_cpu_req_datain_reg  = cpu_req_datain;
    next_cpu_req_rw_reg  = cpu_req_rw;
    next_cache_ready = 1'b0;  
    next_state = COMPARE_TAG;
    end
    else
    next_state = present_state;
  end
  
  COMPARE_TAG:
  begin
    if (hit & !cpu_req_rw_reg) //read hit
    begin
    next_cpu_req_dataout = data_mem_entry;
    next_state = IDLE;
    end
    else if (!cpu_req_rw_reg) //read miss
    begin
    next_cache_ready = 1'b0;  
	  if (!tag_mem_entry[2]) //clean, read new block from memory
	  begin
	  next_mem_req_addr = cpu_req_addr_reg;
	  next_mem_req_rw = 1'b0;
	  next_mem_req_valid = 1'b1;
	  next_state = ALLOCATE;
	  end
	  else 					  //dirty, write cache block to old memory address, then read this block with curr addr
	  begin
	  next_mem_req_addr = {tag_mem_entry[1:0],cpu_addr_index}; //old tag, current index, offset 00
	  next_mem_req_dataout = data_mem_entry;
	  next_mem_req_rw = 1'b1;
	  next_mem_req_valid = 1'b1;
	  next_state = WRITE_BACK;
	  end
    end
    else //write operation
    begin
	  if (tag_mem_entry[2]) //dirty, write cache block to old memory address and then write new cache entry
	  begin
          next_cache_ready = 1'b0;  
	  next_mem_req_addr = {tag_mem_entry[1:0],cpu_addr_index}; 
	  next_mem_req_dataout = data_mem_entry;
	  next_mem_req_rw = 1'b1;
	  next_mem_req_valid = 1'b1;
	  next_state = WRITE_BACK;
	  end
          else
	  begin
          valid_bit = 1'b1;
          dirty_bit = 1'b1;
          tagmem_enable = 1'b1;
          write_datamem_cpu = 1'b1;
          next_state = IDLE;
	  end
  end
  end
  
  ALLOCATE:
  begin
  next_mem_req_valid = 1'b0;
  next_cache_ready = 1'b0;  
	if(!mem_req_valid && mem_req_ready)	//wait for memory to be ready with read data
	begin
	write_datamem_mem = 1'b1; //write to data mem
    	valid_bit = 1'b1;	//make the tag mem entry valid
    	dirty_bit = 1'b0;
    	tagmem_enable = 1'b1;
	next_state = COMPARE_TAG;
	end
	else
	begin
	next_state = present_state;
	end
  end
  
  WRITE_BACK:
  begin
  next_cache_ready = 1'b0;  
  next_mem_req_valid = 1'b0;
	if(!mem_req_valid && mem_req_ready)  //write is done, now read
	begin
	valid_bit = 1'b1;
	dirty_bit = 1'b0;
	tagmem_enable = 1'b1;
	next_mem_req_addr = cpu_req_addr_reg;
	next_mem_req_rw = 1'b0;
	next_mem_req_valid = 1'b1;
        next_state = cpu_req_rw_reg ? COMPARE_TAG : ALLOCATE;
	end
	else
	begin
	next_state = present_state;
	end
  end
endcase
end
always@(posedge clk)
begin
if ((hit)&(cpu_req_addr!=0))
begin
hitcount<=hitcount+1;
end
end


endmodule 