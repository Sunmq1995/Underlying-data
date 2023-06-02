`timescale 1ns/1ps
module top(

input				sys_clk_p,//200M
input				sys_clk_n,

input				ddr4_clk_p,//100M
input				ddr4_clk_n,

output              c0_ddr4_act_n,
output [16:0]       c0_ddr4_adr,
output [1:0]        c0_ddr4_ba,
output [1:0]        c0_ddr4_bg,
output [0:0]        c0_ddr4_cke,
output [0:0]        c0_ddr4_odt,
output [0:0]        c0_ddr4_cs_n,
output [0:0]        c0_ddr4_ck_t,
output [0:0]        c0_ddr4_ck_c,
output              c0_ddr4_reset_n,
inout  [7:0]        c0_ddr4_dm_dbi_n,
inout  [63:0]       c0_ddr4_dq,
inout  [7:0]        c0_ddr4_dqs_c,
inout  [7:0]        c0_ddr4_dqs_t
);

//parameter TOTAL_WR_CNT = 26'd33554432; //26'd10_0000_0000_0000_0000_0000_0000;

parameter TOTAL_WR_CNT = 26'd33546240; //26'd10_0000_0000_0000_0000_0000_0000;

wire	clk;
wire	sys_reset;
  clk_wiz_0 pll
   (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    .locked(),
   // Clock in ports
    .clk_in1_p(sys_clk_p),    // input clk_in1_p
    .clk_in1_n(sys_clk_n));    // input clk_in1_n

wire              	ddr4_clk;
wire				ddr4_rst;

vio_0 vio (
  .clk(clk),                // input wire clk
  .probe_out0(sys_reset)  // output wire [0 : 0] probe_out0
);

wire             	init_calib_complete;

// Debug Bus
wire 	[511:0]		dbg_bus; 
wire				dbg_clk;

// Slave Interface Write Address Ports
reg 		      	axi_awid;
reg 	[32:0]    	axi_awaddr;
reg 	[7:0]       axi_awlen;
reg 	[2:0]       axi_awsize;
reg 	[1:0]       axi_awburst;
reg                	axi_awvalid;
wire                axi_awready;
// Slave Interface Write Data Ports
reg 	[511:0]    	axi_wdata;
wire    [63:0]  	wdata;
assign wdata = axi_wdata[63:0];

reg 	[63:0]  	axi_wstrb;
reg                	axi_wlast;
reg                	axi_wvalid;
wire                axi_wready;
// Slave Interface Write Response Ports
wire                axi_bready;
wire 		      	axi_bid;
wire 	[1:0]       axi_bresp;
wire                axi_bvalid;
// Slave Interface Read Address Ports
reg 		      	axi_arid;
reg 	[32:0]    	axi_araddr;
reg 	[7:0]       axi_arlen;
reg 	[2:0]       axi_arsize;
reg 	[1:0]       axi_arburst;
reg	                axi_arvalid;
wire                axi_arready;
// Slave Interface Read Data Ports
reg                 axi_rready;
wire 		      	axi_rid;
wire 	[511:0]    	axi_rdata;
wire 	[1:0]       axi_rresp;
wire                axi_rlast;
wire                axi_rvalid;

// Port 0 axi_wr
reg 		      	axi_0_awid;
reg 	[32:0]    	axi_0_awaddr;
reg 	[7:0]       axi_0_awlen;
wire 	[2:0]       axi_0_awsize;
wire 	[1:0]       axi_0_awburst;
assign	axi_0_awsize = 3'd6;
assign	axi_0_awburst = 2'd1;

reg                	axi_0_awvalid;
reg                	axi_0_awready;

reg 	[511:0]    	axi_0_wdata;
wire 	[63:0]  	axi_0_wstrb;
assign	axi_0_wstrb = 64'hffffffff_ffffffff;
reg               	axi_0_wlast;
reg                	axi_0_wvalid;
reg                	axi_0_wready;

// Port 1 axi_wr
wire 		      	axi_1_awid;
wire 	[32:0]    	axi_1_awaddr;
wire 	[7:0]       axi_1_awlen;
wire 	[2:0]       axi_1_awsize;
wire 	[1:0]       axi_1_awburst;
wire                axi_1_awvalid;
reg	                axi_1_awready;
// Slave Interface Write Data Ports
wire 	[511:0]    	axi_1_wdata;
wire 	[63:0]  	axi_1_wstrb;
wire                axi_1_wlast;
wire                axi_1_wvalid;
reg                	axi_1_wready;

reg	axi_wr_sel;
always @(*)
	if(axi_wr_sel)begin
		axi_awid = axi_0_awid;
		axi_awaddr = axi_0_awaddr;
		axi_awlen = axi_0_awlen;
		axi_awsize = axi_0_awsize;
		axi_awburst = axi_0_awburst;
		axi_awvalid = axi_0_awvalid;
		axi_0_awready = axi_awready;
		axi_1_awready = 0;
		axi_wdata = axi_0_wdata;
		axi_wstrb = axi_0_wstrb;
		axi_wlast = axi_0_wlast;
		axi_wvalid = axi_0_wvalid;
		axi_0_wready = axi_wready;
		axi_1_wready = 0;
		end
	else begin
		axi_awid = axi_1_awid;
		axi_awaddr = axi_1_awaddr;
		axi_awlen = axi_1_awlen;
		axi_awsize = axi_1_awsize;
		axi_awburst = axi_1_awburst;
		axi_awvalid = axi_1_awvalid;
		axi_0_awready = 0;
		axi_1_awready = axi_awready;
		axi_wdata = axi_1_wdata;
		axi_wstrb = axi_1_wstrb;
		axi_wlast = axi_1_wlast;
		axi_wvalid = axi_1_wvalid;
		axi_0_wready = 0;
		axi_1_wready = axi_wready;
		end

// Port 0 axi_rd		
// Slave Interface Read Address Ports
reg 		      	axi_0_arid;
reg 	[32:0]    	axi_0_araddr;
reg 	[7:0]       axi_0_arlen;
wire 	[2:0]       axi_0_arsize;
wire 	[1:0]       axi_0_arburst;
assign	axi_0_arsize = 3'd6;
assign	axi_0_arburst = 2'd1;
reg                	axi_0_arvalid;
reg	                axi_0_arready;
// Slave Interface Read Data Ports
wire                axi_0_rready;
assign	axi_0_rready = 1;
reg 		      	axi_0_rid;
reg 	[511:0]    	axi_0_rdata;
reg 	[1:0]       axi_0_rresp;
reg                	axi_0_rlast;
reg                	axi_0_rvalid;
// Port 1 axi_rd		
// Slave Interface Read Address Ports
wire 		      	axi_1_arid;
wire 	[32:0]    	axi_1_araddr;
wire 	[7:0]       axi_1_arlen;
wire 	[2:0]       axi_1_arsize;
wire 	[1:0]       axi_1_arburst;
wire                axi_1_arvalid;
reg	                axi_1_arready;
// Slave Interface Read Data Ports
wire                axi_1_rready;
reg 		      	axi_1_rid;
reg 	[511:0]    	axi_1_rdata;
reg 	[1:0]       axi_1_rresp;
reg                	axi_1_rlast;
reg                	axi_1_rvalid;

reg	axi_rd_sel;
always @(*)
	if(axi_rd_sel)begin
		axi_arid = axi_0_arid;
		axi_araddr = axi_0_araddr;
		axi_arlen = axi_0_arlen;
		axi_arsize = axi_0_arsize;
		axi_arburst = axi_0_arburst;
		axi_arvalid = axi_0_arvalid;		
		axi_0_arready = axi_arready;
		axi_1_arready = 0;
		axi_rready = axi_0_rready;
		axi_0_rid = axi_rid;
		axi_0_rdata = axi_rdata;
		axi_0_rresp = axi_rresp;
		axi_0_rlast = axi_rlast;
		axi_0_rvalid = axi_rvalid;
		axi_1_rid = 0;
		axi_1_rdata = 0;
		axi_1_rresp = 0;
		axi_1_rlast = 0;
		axi_1_rvalid = 0;
		end
	else begin
		axi_arid = axi_1_arid;
		axi_araddr = axi_1_araddr;
		axi_arlen = axi_1_arlen;
		axi_arsize = axi_1_arsize;
		axi_arburst = axi_1_arburst;
		axi_arvalid = axi_1_arvalid;
		axi_0_arready = 0;		
		axi_1_arready = axi_arready;
		axi_rready = axi_1_rready;
		axi_0_rid = 0;
		axi_0_rdata = 0;
		axi_0_rresp = 0;
		axi_0_rlast = 0;
		axi_0_rvalid = 0;
		axi_1_rid = axi_rid;
		axi_1_rdata = axi_rdata;
		axi_1_rresp = axi_rresp;
		axi_1_rlast = axi_rlast;
		axi_1_rvalid = axi_rvalid;
		end

//su status indicate
wire                sort_rdy;
//sort req and ack
reg              	sort_req;
wire              	sort_ack;
reg			[63:0]	sort_req_info; //28+28+8bits start_addr+depth+width
reg			[7:0]  	sort_id;
//sort complete
wire               	sort_complete;
wire       [63:0]  	sort_complete_info;
wire       [7:0]   	sort_complete_id;
reg	                sort_complete_info_rd;

reg			[63:0]	wr_data;
reg			[27:0]	wr_cnt;

reg		[26:0]	init_wr_addr;
reg		[63:0]	init_wr_data;
reg		[27:0]	total_wr_cnt;
reg		[8:0]	single_wr_cnt;

reg			[3:0]	state;
reg			[27:0]	req_addr;
reg			[27:0]	req_cnt;
reg			[27:0]	init_rd_addr;
reg			[27:0]	total_rd_cnt;
reg			[27:0]	total_cnt;
reg			[8:0]	single_rd_cnt;
reg			[63:0]	data_for_check;
reg					error;
reg         [63:0]  sort_time;

always @(posedge ddr4_clk or posedge ddr4_rst)
	if(ddr4_rst)begin
		axi_wr_sel <= 0;
		state <= 0;
		init_wr_addr <= 0;
		init_wr_data <= 0;
		total_wr_cnt <= 0;
		single_wr_cnt <= 0;		
		axi_0_awid <= 0;	
		axi_0_awaddr <= 0;	
		axi_0_awlen <= 0;	
		axi_0_awvalid <= 0;	
		axi_0_wdata <= 0;	
		axi_0_wlast <= 0;	
		axi_0_wvalid <= 0;	
		req_addr <= 0;
		req_cnt <= 0;
		init_rd_addr <= 0;
		total_rd_cnt <= 0;
		total_cnt <= 0;
		single_rd_cnt <= 0;
		sort_complete_info_rd <= 0;
		sort_req_info <= 0; //28+28+8bits start_addr+depth+width
		sort_id <= 0;		
		sort_req <= 0;	
		axi_0_arid <= 0;
		axi_0_araddr <= 0;
		axi_0_arlen <= 0;
		axi_0_arvalid <= 0;	
		axi_rd_sel <= 0;
		data_for_check <= 0;
		error <= 0;
		sort_time <= 0;
		end
	else begin
		case(state)
		0:begin
			wr_data <= 12287;
			wr_cnt <= 12288;
			if(init_calib_complete)
				state <= 1;
			end
		1:begin
			init_wr_addr <= 0;
			init_wr_data <= wr_data;
			total_wr_cnt <= wr_cnt;
			if(init_calib_complete)begin
				axi_wr_sel <= 1;
				state <= 2;
				end
			end
		2:begin
			if(total_wr_cnt > 256)begin
				single_wr_cnt <= 256;
				total_wr_cnt <= total_wr_cnt - 256;
				state <= 3;
				end
			else if(total_wr_cnt == 0)begin
				axi_wr_sel <= 0;
				state <= 9;
				end
			else begin
				single_wr_cnt[8:0] <=  total_wr_cnt[8:0];
				total_wr_cnt <= 0;
				state <= 3;
				end
			end
		3:begin
			if(axi_0_awready)begin 
			     axi_0_awaddr[32:0] <= {init_wr_addr[26:0],6'b0};  
			     axi_0_awlen[7:0] <= single_wr_cnt - 1;
			     axi_0_awid <= 1;
			     axi_0_awvalid <= 1;
				 init_wr_addr <= init_wr_addr + single_wr_cnt;
			     state <= 4;
			     end
			end
		4:begin
			if(axi_0_awready)begin
				axi_0_awaddr <= 0; 
				axi_0_awlen <= 0;
				axi_0_awid <= 0;
				axi_0_awvalid <= 0;
				state <= 5;
				end
			end
		5:begin
			axi_0_wdata[511:0] <= {8{init_wr_data[63:0]}};
			axi_0_wvalid <= 1;
			init_wr_data <= init_wr_data - 1;
			if(single_wr_cnt == 1)begin
				axi_0_wlast <= 1;
				state <= 7;
				end
			else begin
				single_wr_cnt <= single_wr_cnt - 1;
				state <= 6;
				end
			end
		6:begin
			if(axi_0_wready)begin
				axi_0_wdata[511:0] <= {8{init_wr_data[63:0]}};
				axi_0_wvalid <= 1;
				init_wr_data <= init_wr_data - 1;
				single_wr_cnt <= single_wr_cnt - 1;
				if(single_wr_cnt == 1)begin
					axi_0_wlast <= 1;
					state <= 7;
					end
				else 
					single_wr_cnt <= single_wr_cnt - 1;
				end
			end
		7:begin
			if(axi_0_wready)begin
				axi_0_wdata <= 0;
				axi_0_wvalid <= 0;
				axi_0_wlast <= 0;
				//wr_rr <= current_wr_opera_fifo;
				state <= 8;
				end
			end
		8:begin
			if(axi_bvalid)begin
				
				state <= 2;
				end
			end
		9:begin
			if(sort_rdy)begin
				sort_req <= 1;
				sort_req_info[7:0] <= 8'd64;
				sort_req_info[35:8] <= wr_cnt[27:0];
				sort_req_info[63:36] <= 0; 
				sort_id[7:0] <= 8'd1;
				axi_rd_sel <= 0;
				state <= 10;
				end
			end
		10:begin
			if(sort_ack)begin
				sort_req <= 0;
				sort_req_info <= 0;
				sort_id <= 0;
				sort_time <= 1;
				state <= 11;
				end
			end
		11:begin
		    sort_time <= sort_time + 1;
			if(sort_complete)begin
			    //rd_time_wait_cnt <= 0;
			     
		         sort_complete_info_rd <= 1;
			     axi_rd_sel <= 1;
			     init_rd_addr[27:0] <= sort_complete_info[63:36];
			     total_rd_cnt[27:0] <= sort_complete_info[35:8];
			     total_cnt[27:0] <= sort_complete_info[35:8];
			     data_for_check <= 0;
			     state <= 12;
				end
			end
		12:begin
			sort_complete_info_rd <= 0;
			if(total_rd_cnt > 32)begin
				single_rd_cnt <= 32;
				total_rd_cnt <= total_rd_cnt - 32;
				state <= 13;
				end
			else if(total_rd_cnt == 0)begin
			    if(wr_cnt < TOTAL_WR_CNT)begin
					wr_data <= wr_data + 12288;
					wr_cnt <= wr_cnt + 12288;
					end
				else begin
					wr_data <= 12287;
					wr_cnt <= 12288;
					end
				state <= 1;
				end
			else begin
				single_rd_cnt[8:0] <=  total_rd_cnt[8:0];
				total_rd_cnt <= 0;
				state <= 13;
				end
			end
		13:begin
		    if(axi_0_arready)begin
			     axi_0_arid <= 1;
			     axi_0_araddr[32:0] <= {init_rd_addr[26:0],6'b0};
			     axi_0_arlen[7:0] <= single_rd_cnt - 1;
			     init_rd_addr <= init_rd_addr + single_rd_cnt;
			     axi_0_arvalid <= 1;
			     state <= 14;
			     end
			end
		14:begin
			if(axi_0_arready)begin
				axi_0_arid <= 0;
				axi_0_araddr[32:0] <= 0;
				axi_0_arlen[7:0] <= 0;
				axi_0_arvalid <= 0;
				state <= 15;
				end
			end
		15:begin
			if(axi_0_rvalid)begin
				if(axi_0_rdata[63:0] == data_for_check)
					error <= 0;
				else 
					error <= 1;
				single_rd_cnt <= single_rd_cnt - 1;
				data_for_check <= data_for_check + 1;
				if(single_rd_cnt == 1)
					state <= 12;
				end
			end
		endcase
		end
		
		
		
merge_sort uut(
	.clk(clk),
	.rst_n(!sys_reset),
	.ddr4_clk(ddr4_clk),
	.ddr4_rst(ddr4_rst),
	.init_calib_complete(init_calib_complete),
//su status indicate
	.sort_rdy(sort_rdy),
//sort req and ack
	.sort_req(sort_req),
	.sort_ack(sort_ack),
	.sort_req_info(sort_req_info), //28+28+8bits start_addr+depth+width
	.sort_id(sort_id),
//sort complete
	.sort_complete(sort_complete),
	.sort_complete_info(sort_complete_info),
	.sort_complete_id(sort_complete_id),
	.sort_complete_info_rd(sort_complete_info_rd),

//AXI
//Slave Interface Write Address Ports
	.axi_awid(axi_1_awid),
	.axi_awaddr(axi_1_awaddr),
	.axi_awlen(axi_1_awlen),
	.axi_awsize(axi_1_awsize),
	.axi_awburst(axi_1_awburst),
	.axi_awvalid(axi_1_awvalid),
	.axi_awready(axi_1_awready),
//Slave Interface Write Data Ports
	.axi_wdata(axi_1_wdata),
	.axi_wstrb(axi_1_wstrb),
	.axi_wlast(axi_1_wlast),
	.axi_wvalid(axi_1_wvalid),
	.axi_wready(axi_1_wready),
//Slave Interface Write Response Ports
	.axi_bready(axi_bready),
	.axi_bid(axi_bid),
	.axi_bresp(axi_bresp),
	.axi_bvalid(axi_bvalid),
//Slave Interface Read Address Ports
	.axi_arid(axi_1_arid),
	.axi_araddr(axi_1_araddr),
	.axi_arlen(axi_1_arlen),
	.axi_arsize(axi_1_arsize),
	.axi_arburst(axi_1_arburst),
	.axi_arvalid(axi_1_arvalid),
	.axi_arready(axi_1_arready),
//Slave Interface Read Data Ports
	.axi_rready(axi_1_rready),
	.axi_rid(axi_1_rid),
	.axi_rdata(axi_1_rdata),
	.axi_rresp(axi_1_rresp),
	.axi_rlast(axi_1_rlast),
	.axi_rvalid(axi_1_rvalid)
);

reg 				aresetn;
always @(posedge ddr4_clk)
    aresetn <= ~ddr4_rst;
	
ddr4_0 ddr4 (
  .c0_init_calib_complete(init_calib_complete),    // output wire c0_init_calib_complete
  .dbg_clk(dbg_clk),                                  // output wire dbg_clk
  .c0_sys_clk_p(ddr4_clk_p),                        // input wire c0_sys_clk_p
  .c0_sys_clk_n(ddr4_clk_n),                        // input wire c0_sys_clk_n
  .dbg_bus(dbg_bus),                                  // output wire [511 : 0] dbg_bus

	.c0_ddr4_act_n          (c0_ddr4_act_n),
	.c0_ddr4_adr            (c0_ddr4_adr),
	.c0_ddr4_ba             (c0_ddr4_ba),
	.c0_ddr4_bg             (c0_ddr4_bg),
	.c0_ddr4_cke            (c0_ddr4_cke),
	.c0_ddr4_odt            (c0_ddr4_odt),
	.c0_ddr4_cs_n           (c0_ddr4_cs_n),
	.c0_ddr4_ck_t           (c0_ddr4_ck_t),
	.c0_ddr4_ck_c           (c0_ddr4_ck_c),
	.c0_ddr4_reset_n        (c0_ddr4_reset_n),
	.c0_ddr4_dm_dbi_n       (c0_ddr4_dm_dbi_n),
	.c0_ddr4_dq             (c0_ddr4_dq),
	.c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
	.c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

  .c0_ddr4_ui_clk(ddr4_clk),                    // output wire c0_ddr4_ui_clk
  .c0_ddr4_ui_clk_sync_rst(ddr4_rst),  // output wire c0_ddr4_ui_clk_sync_rst
  
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn(aresetn),                  // input wire c0_ddr4_aresetn
  .c0_ddr4_s_axi_awid(axi_awid),            // input wire [3 : 0] c0_ddr4_s_axi_awid
  .c0_ddr4_s_axi_awaddr(axi_awaddr),        // input wire [32 : 0] c0_ddr4_s_axi_awaddr
  .c0_ddr4_s_axi_awlen(axi_awlen),          // input wire [7 : 0] c0_ddr4_s_axi_awlen
  .c0_ddr4_s_axi_awsize(axi_awsize),        // input wire [2 : 0] c0_ddr4_s_axi_awsize
  .c0_ddr4_s_axi_awburst(axi_awburst),      // input wire [1 : 0] c0_ddr4_s_axi_awburst
  .c0_ddr4_s_axi_awlock(1'b0),        // input wire [0 : 0] c0_ddr4_s_axi_awlock
  .c0_ddr4_s_axi_awcache(4'b0),      // input wire [3 : 0] c0_ddr4_s_axi_awcache
  .c0_ddr4_s_axi_awprot(3'b0),        // input wire [2 : 0] c0_ddr4_s_axi_awprot
  .c0_ddr4_s_axi_awqos(4'b0),          // input wire [3 : 0] c0_ddr4_s_axi_awqos
  .c0_ddr4_s_axi_awvalid(axi_awvalid),      // input wire c0_ddr4_s_axi_awvalid
  .c0_ddr4_s_axi_awready(axi_awready),      // output wire c0_ddr4_s_axi_awready
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata(axi_wdata),          // input wire [511 : 0] c0_ddr4_s_axi_wdata
  .c0_ddr4_s_axi_wstrb(axi_wstrb),          // input wire [63 : 0] c0_ddr4_s_axi_wstrb
  .c0_ddr4_s_axi_wlast(axi_wlast),          // input wire c0_ddr4_s_axi_wlast
  .c0_ddr4_s_axi_wvalid(axi_wvalid),        // input wire c0_ddr4_s_axi_wvalid
  .c0_ddr4_s_axi_wready(axi_wready),        // output wire c0_ddr4_s_axi_wready
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid(axi_bid),              // output wire [3 : 0] c0_ddr4_s_axi_bid
  .c0_ddr4_s_axi_bresp(axi_bresp),          // output wire [1 : 0] c0_ddr4_s_axi_bresp
  .c0_ddr4_s_axi_bvalid(axi_bvalid),        // output wire c0_ddr4_s_axi_bvalid
  .c0_ddr4_s_axi_bready(axi_bready),        // input wire c0_ddr4_s_axi_bready
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid(axi_arid),            // input wire [3 : 0] c0_ddr4_s_axi_arid
  .c0_ddr4_s_axi_araddr(axi_araddr),        // input wire [32 : 0] c0_ddr4_s_axi_araddr
  .c0_ddr4_s_axi_arlen(axi_arlen),          // input wire [7 : 0] c0_ddr4_s_axi_arlen
  .c0_ddr4_s_axi_arsize(axi_arsize),        // input wire [2 : 0] c0_ddr4_s_axi_arsize
  .c0_ddr4_s_axi_arburst(axi_arburst),      // input wire [1 : 0] c0_ddr4_s_axi_arburst
  .c0_ddr4_s_axi_arlock(1'b0),        // input wire [0 : 0] c0_ddr4_s_axi_arlock
  .c0_ddr4_s_axi_arcache(4'b0),      // input wire [3 : 0] c0_ddr4_s_axi_arcache
  .c0_ddr4_s_axi_arprot(3'b0),        // input wire [2 : 0] c0_ddr4_s_axi_arprot
  .c0_ddr4_s_axi_arqos(4'b0),          // input wire [3 : 0] c0_ddr4_s_axi_arqos
  .c0_ddr4_s_axi_arvalid(axi_arvalid),      // input wire c0_ddr4_s_axi_arvalid
  .c0_ddr4_s_axi_arready(axi_arready),      // output wire c0_ddr4_s_axi_arready
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rready(axi_rready),        // input wire c0_ddr4_s_axi_rready
  .c0_ddr4_s_axi_rlast(axi_rlast),          // output wire c0_ddr4_s_axi_rlast
  .c0_ddr4_s_axi_rvalid(axi_rvalid),        // output wire c0_ddr4_s_axi_rvalid
  .c0_ddr4_s_axi_rresp(axi_rresp),          // output wire [1 : 0] c0_ddr4_s_axi_rresp
  .c0_ddr4_s_axi_rid(axi_rid),              // output wire [3 : 0] c0_ddr4_s_axi_rid
  .c0_ddr4_s_axi_rdata(axi_rdata),          // output wire [511 : 0] c0_ddr4_s_axi_rdata
  
  .sys_rst(sys_reset)                                  // input wire sys_rst
);


ila_0 top_ila (
	.clk(ddr4_clk), // input wire clk


	.probe0(init_calib_complete), // input wire [0:0]  probe0  
	.probe1(data_for_check), // input wire [63:0]  probe1 
	.probe2(axi_0_rdata[63:0]), // input wire [63:0]  probe2 
	.probe3(axi_0_rvalid), // input wire [0:0]  probe3 
	.probe4(error), // input wire [0:0]  probe4 
	.probe5(state), // input wire [3:0]  probe5 
	.probe6(total_cnt), // input wire [27:0]  probe6 
	.probe7(sort_time), // input wire [63:0]  probe7 
	.probe8(sort_complete_info_rd) // input wire [0:0]  probe8
);
endmodule