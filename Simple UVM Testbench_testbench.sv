import uvm_pkg::*;// Import UVM package
`include "uvm_macros.svh"// Include UVM macros

//----------------
// environment env
//----------------
class env extends uvm_env;// Define a UVM environment class

  virtual add_sub_if m_if;//包含一个virtual interface变量 m_if，类型是add_sub_if

  function new(string name, uvm_component parent = null);// Constructor for the environment class
    super.new(name, parent);
  endfunction
  
  function void connect_phase(uvm_phase phase);//定义了 connect_phase 函数，是 UVM 里所有组件的标准阶段函数之一，专门用来连接各类句柄和信号。
    `uvm_info("LABEL", "Started connect phase.", UVM_HIGH);//打印信息，告诉你 connect 阶段开始。
    assert(uvm_resource_db#(virtual add_sub_if)::read_by_name(//从资源数据库中读取名为 "add_sub_if" 的 virtual interface，如果没找到会报错，仿真终止
      get_full_name(), "add_sub_if", m_if));//读取名为 "add_sub_if" 的 virtual interface，并将其赋值给 m_if
    `uvm_info("LABEL", "Finished connect phase.", UVM_HIGH);//打印信息，告诉你 connect 阶段结束。
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);//告诉 UVM，“我的测试还没完，请不要结束仿真！
    `uvm_info("LABEL", "Started run phase.", UVM_HIGH);//打印信息，告诉你 run 阶段开始。
    begin
      int a = 8'h2, b = 8'h3;
      @(m_if.cb);// 等待时钟上升沿
      m_if.cb.a <= a;//testbench 代码用 m_if.cb.a 驱动信号，其实最终作用的还是 interface 里的 a 信号本身
      m_if.cb.b <= b;
      m_if.cb.doAdd <= 1'b1;// 设置加法操作
      repeat(2) @(m_if.cb);// 等待两个时钟周期
      `uvm_info("RESULT", $sformatf("%0d + %0d = %0d",
        a, b, m_if.cb.result), UVM_LOW);
    end
    `uvm_info("LABEL", "Finished run phase.", UVM_HIGH);
    phase.drop_objection(this);//告诉 UVM，“我的测试结束了，可以结束仿真了。
  endtask: run_phase
  
endclass

//-----------
// module top
//-----------
module top;//顶层模块，包含了整个测试环境和 DUT（设计单元）

  bit clk;// 时钟信号，声明一个 1 位的 bit 类型变量，名为 clk
  env environment;//声明一个 env 类的对象，名字叫 environment。
  ADD_SUB dut(.clk (clk));//例化一个 ADD_SUB 模块（DUT），端口 clk 连接到顶层的 clk 信号

  initial begin
    environment = new("env");//用 new 方法（构造函数）实例化 env 对象，创建“environment”这个对象
    // Put the interface into the resource database.
    uvm_resource_db#(virtual add_sub_if)::set(//把 virtual interface 放入资源数据库
        "env","add_sub_if", dut.add_sub_if0);//把名为 "add_sub_if" 的 virtual interface 存入资源数据库，键是 "env"，值是 DUT 的 add_sub_if0 接口
    clk = 0;
    run_test();//调用 UVM 的 run_test 函数，开始测试
  end
  
  initial begin
    forever begin
      #(50) clk = ~clk;
    end
  end
  
  initial begin
    // Dump waves
    $dumpvars(0, top);
  end
  
endmodule