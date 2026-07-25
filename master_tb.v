module i2c_master_tb;
reg clk_i;
reg rst_i;
wire [7:0] m_data_o;
reg [6:0] m_slv_add_i;
reg m_w_r_i;
reg m_start_i;
reg m_stop_i;
reg [7:0] m_data_i;
reg m_ack_i;
wire m_busy_o;
wire m_error_o;
wire m_data_ready_o;
wire sda;
wire sca;
reg tb_ack;
pullup(sda);
pullup(sca);


 assign sda = (tb_ack) ? 1'b0 : 1'bz;
i2c_master dut (.clk_i(clk_i),.rst_i(rst_i),.m_data_o(m_data_o),.m_slv_add_i(m_slv_add_i),.m_w_r_i(m_w_r_i),.m_start_i(m_start_i),
.m_stop_i(m_stop_i),.m_data_i(m_data_i),.sda(sda),.sca(sca),.m_busy_o(m_busy_o),.m_error_o(m_error_o),.m_data_ready_o(m_data_ready_o),.m_ack_i(m_ack_i));

always
#10 clk_i=~clk_i;
always@(posedge clk_i or posedge rst_i)
begin

if(rst_i)
begin
tb_ack<=1'b0;
end
else if ((dut.state==dut.ack1 || dut.state==dut.ack2)&& (dut.sub_step==2'b01))
begin
tb_ack<=1'b1;

end

else
begin
tb_ack<=1'b0;
end

end






initial
begin
clk_i=0;
rst_i=1;
m_start_i=0;
m_stop_i=0;
m_slv_add_i=7'h5A;
m_w_r_i=0;
m_ack_i=0;
m_data_i=8'hA5;

#40;
rst_i=0;
#40;
m_start_i=1;
#20;
m_start_i=0;

wait(dut.state == dut.ack2);

#40;
m_stop_i=1;
#40;
m_stop_i=0;

wait(m_busy_o==0);
#100;
$finish;
end
endmodule
