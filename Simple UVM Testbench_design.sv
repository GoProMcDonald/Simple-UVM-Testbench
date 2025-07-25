// Simple adder/subtractor module
module ADD_SUB(//定义了一个模块，名字叫 ADD_SUB
  input            clk,
  input [7:0]      a0,
  input [7:0]      b0,
  // if this is 1, add; else subtract
  input            doAdd0,//控制信号，为1时做加法，否则做减法
  output reg [8:0] result0//结果输出，9位宽度
);

  always @ (posedge clk)
    begin
      if (doAdd0)
        result0 <= a0 + b0;
      else
        result0 <= a0 - b0;
    end

endmodule: ADD_SUB

//---------------------------------------
// Interface for the adder/subtractor DUT
//---------------------------------------
interface add_sub_if(//定义了一个接口，名字叫 add_sub_if
  input bit clk,
  input [7:0] a,
  input [7:0] b,
  input       doAdd,
  input [8:0] result
);

  clocking cb @(posedge clk);// 定义了一个时钟块 cb，基于 posedge clk。clocking block 是 SystemVerilog testbench 里的专用语法，用于同步信号的读写
    output    a;
    output    b;
    output    doAdd;
    input     result;
  endclocking // cb

endinterface: add_sub_if

//---------------
// Interface bind
//---------------
bind ADD_SUB add_sub_if add_sub_if0(//实例化一个 interface，名为 add_sub_if0，类型为add_sub_if，并把 ADD_SUB 实例的端口和 interface 信号对应连起来。
  .clk(clk),
  .a(a0),// 连接到 ADD_SUB 模块的 a0 信号
  .b(b0),// 连接到 ADD_SUB 模块的 a0 信号
  .doAdd(doAdd0),// 连接到 ADD_SUB 模块的 doAdd0 信号
  .result(result0)// 连接到 ADD_SUB 模块的 result0 信号
);
