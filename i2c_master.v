module i2c_master(clk_i,rst_i,m_data_o,m_w_r_i,m_start_i,m_stop_i,m_error_o,m_slv_add_i,m_ack_i,m_data_i,m_data_ready_o,m_busy_o,sca,sda);
input wire clk_i,rst_i,m_w_r_i,m_start_i,m_stop_i,m_ack_i;
input [7:0] m_data_i;
input  [6:0] m_slv_add_i;
output [7:0] m_data_o;
inout wire sda;
inout wire sca;
output reg m_error_o;
output reg m_data_ready_o;
output reg m_busy_o;

reg [7:0] shift_reg;
reg [2:0] state;
reg [1:0] sub_step;
reg [2:0] bit_counter;
reg sda_out;
reg sca_out;
localparam
idle=3'd0,
start=3'd1,
address=3'd2,
ack1=3'd3,
data=3'd4,
ack2=3'd5,
stop=3'd6;
wire sda_oe= (state !=ack1 && state !=ack2);
assign sda = sda_oe ? (sda_out ? 1'bz : 1'b0) : 1'bz;

assign sca = (sca_out==1'b0) ? 1'b0:1'bz;

always @(posedge clk_i or posedge rst_i)
begin
if (rst_i)
begin
state<=idle;

shift_reg<=8'b0;
sda_out<=1'b1;
sca_out<=1'b1;
bit_counter<=3'd7;
sub_step<= 2'b00;
m_busy_o <=1'b0;
m_data_ready_o<=1'b0;
m_error_o<=1'b0;

end
else
begin
case(state)

idle:  begin
sda_out <= 1'b1;
sca_out <= 1'b1;
m_busy_o <=1'b0;
m_data_ready_o<=1'b0;
sub_step<= 2'b00;
if(m_start_i)
begin
state<=start;
m_busy_o <=1'b1;
m_error_o<=1'b0;

end
end
start: begin

case(sub_step) 

2'b00: begin
sda_out <= 1'b1;
sca_out <= 1'b1;
sub_step<=2'b01;
end

2'b01: begin
sda_out <= 1'b0;
sub_step<= 10;
end

2'b10: begin
sca_out<=0;
sub_step<= 2'b11;
end

2'b11:begin
shift_reg<= {m_slv_add_i,m_w_r_i};
bit_counter<=3'd7;
sub_step<=2'b00;
state<=address;

end
endcase
end

address: begin

case(sub_step)

2'b00: begin
sca_out<=1'b0;
sda_out<= shift_reg[bit_counter];
sub_step<=2'b01;
end

2'b01:begin
 sca_out<=1'b1;
sub_step<=2'b10;
end

2'b10: begin
sub_step<=2'b11;
end

2'b11: begin

sca_out<=1'b0;
sub_step<= 2'b00;

if(bit_counter==0)
state<=ack1;
else
bit_counter<=bit_counter-1'b1;

end

endcase

end

ack1: begin

case(sub_step)

2'b00: begin
sca_out<=1'b0;
sub_step<=2'b01;
end

2'b01:begin
 sca_out<=1'b1;
sub_step<=2'b10;
if(m_ack_i ==1'b1)begin
m_error_o<=1'b1;
end
end

2'b10: begin
sub_step<=2'b11;
end

2'b11: begin

sca_out<=1'b0;
sub_step<= 2'b00;

if(m_error_o || m_ack_i)
state<=stop;
else begin
bit_counter<=3'd7;
shift_reg<=m_data_o;
state<=data;
end
end

endcase

end

data: begin

case(sub_step)

2'b00: begin
sca_out<=1'b0;
if(~m_w_r_i)
begin 
sda_out<= shift_reg[bit_counter];
end
sub_step<=2'b01;
end

2'b01:begin
 sca_out<=1'b1;
sub_step<=2'b10;
end

2'b10: begin
sub_step<=2'b11;
end

2'b11: begin

sca_out<=1'b0;
sub_step<= 2'b00;

if(bit_counter==0)
state<=ack2;
else
bit_counter<=bit_counter-1'b1;

end

endcase


end

ack2: begin
case(sub_step)

2'b00: begin
sca_out<=1'b0;
sda_out<=1'b1;
sub_step<=2'b01;
end

2'b01:begin
 sca_out<=1'b1;

sub_step<=2'b10;
if(~m_w_r_i && sda==1'b1)begin
m_error_o<=1'b1;
end
end

2'b10: begin
sub_step<=2'b11;
end

2'b11: begin

sca_out<=1'b0;
sub_step<= 2'b00;

if(m_error_o || m_stop_i || (~m_w_r_i && sda==1'b1))
state<=stop;
else begin
bit_counter<=3'd7;
shift_reg<=m_data_o;
state<=data;
end
end

endcase

end


stop: begin 

case(sub_step) 

2'b00: begin
sca_out<=1'b0;
sda_out<=1'b0;
sub_step<=2'b01;

end

2'b01:begin
 sca_out<=1'b1;

sub_step<=2'b10;

end

2'b10: begin
sda_out<=1'b1;
sub_step<=2'b11;
end

2'b11: begin

m_busy_o<=1'b0;
sub_step<=2'b00;
state<=idle;
end
endcase

end



default:state<=idle;

endcase



end



end





endmodule
