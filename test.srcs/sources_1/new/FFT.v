`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/24 12:09:27
// Design Name: 
// Module Name: FFT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FFT (xn_r, xn_i,RST,CLK,START,OUT,Xk_r,Xk_i,OUT);
input [15:0] xn_r , xn_i; 
input RST, CLK, START; 

output [15:0] Xk_r, Xk_i;
output OUT;

reg [15:0] Xk_r, Xk_i;
reg OUT; 		//输入的实部与虚部//ITT 启动信号与时钟信号和|复位信号 //FFT 输出实部与虚部 //输出标志信号
reg OUT1, STRT1; //级联 FF凹的输出标志和启动信号 
reg [2 :0] k, j , m , n, l, p; //循环指针 
reg [4 : 0] i; 
reg [15:0] IN_r[15:0], IN_i [15:0] ; 
reg [15:0] OUT_r[15:0], OUT_i [15:0] ; 
reg [15:0] TRANIN_r,TRANIN_i ; //的转接 
reg [15:0] TRANOUT_r,TRANOUT_i ;// 的转接 
reg [2:0] state; 
parameter Idle=3'b000,
	Input=3'b001, 
	Compute0=3'b010, 
	Compute1=3'b100, 
	Butfly=3'b101, 
	Output=3'b110; 
//存储输入的实都与虚部 //存储输出的实部与虚部 //输入序列与 FFT4 输入之间
//输出序列与 FFT1 输出之间
//空闲 //输入 //计算引擎 //第二级计算的控制 //蝶形计算 //输出
//定义三个移位函数 
function[15:0] Shift03;//乘以 0. 3827
	input [15:0] xn; 
		begin 
		Shift03= {xn[15],xn[15:1]}-{xn[15],xn[15],xn[15],xn[15:3]}+{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:7]}-{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:13]};
		end
endfunction 

function[15:0] Shift07;//乘以 0. 7071
	input [15:0] xn; 
		begin 
		Shift07={xn[15],xn[15:1]}+{xn[15],xn[15],xn[15],xn[15:3]}+{xn[15],xn[15],xn[15],xn[15],xn[15:4]}+{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:6]}+{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:8]}+{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:14]};
	end 
endfunction 

function[15:0] Shift09;//乘以 0. 9239
	input [15:0] xn; 
		begin 
		Shift09=xn-{xn[15],xn[15],xn[15],xn[15],xn[15:4]} - {xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:6]}+{xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15],xn[15:14]};
	end
endfunction 
//调用 FFT4 模块计算 4 组 4 点的 FFT 
//FFT4 
XFFT(.CLK(CLK),
	.START(STRT1), 
	.xn_r(TRANIN_r), 
	.xn_i(TRANIN_i), 
	.OUT(OUT1), 
	.Xk_r (TRANOUT_r), 
	.Xk_i(TRANOUT_i)); 

always@(posedge CLK or posedge RST)
	if(RST) begin 
		state<=Idle; 
		OUT<=0; //异步复位， 高电平有效 //输出无效 
		end 
	else begin 
	case (state) //空闲状态 
    Idle:
		begin OUT<=0; 
		if (START) //只有在空闲状态下才能启动 FFT 
			begin state<=Input; 
			i<=0; 
			end 
		else  
			begin state<=Idle; 
			end 
		end
//16 位复数输入
    Input: 
		begin 
		if(i<16) 
			begin 
			IN_r[i]<=xn_r; 
			IN_i[i]<=xn_i;
			i<=i+1;
			end
		else if(i==16) //输入完毕进入的计算 
			begin 
			state<=Compute0; 
			STRT1<=1;//启动 FFT4 
			j<=0; //指针复位 
			k<=0; 
			m<=0;
			n<=0; 
			end 
		end 
//第一二级计算 	
    Compute0:
	begin if(j<4) //4 组串行输入计算 
		begin STRT1<=0;//关断 FFT4 启动信号 
			if(k<4) 
				begin 
				TRANIN_r<=IN_r[4*k+j]; //时选法输入 
				TRANIN_i<=IN_i[4*k+j]; 
				k<=k+1; 
				end 
			else if(k==4)//k=4 输入完毕， 则等待 FFT4的输出
				begin if((OUT1==1)&&(m<4)) //可 以输出 
					begin //这两个信号同时消失储
					OUT_r[4*j+m]<=TRANOUT_r; //连续存
					OUT_i[4*j+m]<=TRANOUT_i;
					m<=m+1;
					end 
				else 
					begin if (m==4) //输出完毕， 并非没有开始
						begin j<=j+1 ; //进入下一 组的计算
						m<=0; //清零，以备用 
						k<=0; 
						STRT1<=1;//为下一个计算作准备启动信号
						end 
					end//输出完毕
				end 
		end 
		else if(j==4) 
			begin 
				if(n==0) 
					begin 
					state<=Butfly; //第一级计算完毕进入蝶形计算
					n<=n+1;
					end
				else if(n==3) 
					begin 
					state<=Output ; //第二级计算
					l<=0; 
					p<=0; 
					end 
			end 
	end 
    Butfly: 
	begin if(n==1) 
		begin 
		IN_r[0]<=OUT_r[0];
		IN_i[0]<=OUT_i[0];
		IN_r[l]<=OUT_r[l];
		IN_i[1]<=OUT_i[1]; 
		IN_r[2]<=OUT_r[2];
		IN_i[2]<=OUT_i[2];
		IN_r[3]<=OUT_r[3];
		IN_i[3]<=OUT_i[3];
		IN_r[4]<=OUT_r[4];
		IN_i[4]<=OUT_i[4]; 
		IN_r[5]<=Shift09(OUT_r[5])+Shift03(OUT_i [5]); 
		IN_i[5]<=Shift09(OUT_i [5])-Shift03(OUT_r[5]); 
		IN_r[6]<=Shift07(OUT_r [6])+Shift07(OUT_i [6]); 
		IN_i[6]<=Shift07(OUT_i [6])-Shift07(OUT_r[6]); 
		IN_r[7]<=Shift03(OUT_r[7])+Shift09(OUT_i [7]); 
		IN_r[8]<=OUT_r[8];
		IN_i[8]<=OUT_i[8];
		IN_r[9]<=Shift07(OUT_r [9])+Shift07(OUT_i[9]); 
		IN_i[9]<=Shift07(OUT_i [9])-Shift07(OUT_r[9]);
		IN_r[10]<=OUT_r[10];
		IN_i[10]<=OUT_i[10];	
		IN_r[11]<=Shift07(OUT_i[11])-Shift07(OUT_r[11]); 
		IN_i[11]<=0-Shift07(OUT_i[11])-Shift07(OUT_r[11]);
		IN_r[12]<=OUT_r[12];
		IN_i[12]<=OUT_i[12]; 
		IN_r[13]<=Shift03(OUT_r[13])+Shift09(OUT_i[13]); 
		IN_i[13]<=Shift03(OUT_i[13])-Shift09(OUT_r [13]); 
		IN_r[14]<=Shift07(OUT_i[14])-Shift07(OUT_r[14]);	
		IN_i[14]<=0-Shift07(OUT_i[14])-Shift07(OUT_r[14]); 
		IN_r[15]<=0-Shift09(OUT_r[15])-Shift03(OUT_i[15]);	
		IN_i[15]<=Shift03(OUT_r[15])-Shift09(OUT_i[15]);
		n<=n+1;
		end 
	else 
		begin if(n==2) 
		state<=Compute1; //进入第二级计算 
		end 
	end 
    Compute1: 
	begin 
	n<=3;
	j<=0;
	STRT1<=1;
	state<=Compute0; 
	end 
    Output: 
	begin if(l<4) 
		begin 
		OUT<=l; 
		Xk_r<=OUT_r[4*p+l]; 
		Xk_i<=OUT_i[4*p+l];
		p<=(p==3)?0:(p+l);
		l<=(p==3)?(l+1):1; 
		end
	else if(1==4) //输出完毕 
		begin
		OUT<=0;
		state<=Idle; 
		end 
	end
	default: 
	begin 
	state<=Idle;
	end
endcase 
end 
endmodule
