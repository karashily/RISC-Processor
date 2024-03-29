LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE ieee.numeric_std.all; 
USE ieee.std_logic_misc.all;

ENTITY EXEC_stage IS
GENERIC (n : integer := 32);
	PORT(clk:std_logic;
	     Rsrc1,Rsrc2,imm,Rsrc1_mem,Rsrc2_mem,Rsrc1_WB,Rsrc2_WB: IN std_logic_vector(n-1 downto 0);
	     opcode_in: IN std_logic_vector(4 downto 0);
	     opcode_out: OUT std_logic_vector(4 downto 0);
	     IO_IN:IN std_logic_vector(n-1 downto 0);
	     IO_OUT: OUT std_logic_vector(n-1 downto 0);
	     OUT_SEL:IN std_logic;
	     IO_ALU_SEL:IN std_logic;
	     Rsrc2_sel:IN std_logic;       -- 0=rsrc2    1 = imm
	     Rsrc1_sel_forward,Rsrc2_sel_forward:IN std_logic_vector(1 downto 0); -- 00 = src value  01=mem value  10=wb value
	     Rst:IN std_logic;
	     flag_reg_in:IN std_logic_vector(3 downto 0);
	     flag_reg_out:OUT std_logic_vector(3 downto 0);
	     ALU_OUTPUT: INOUT  std_logic_vector(n-1 downto 0)
	     ); 
END ENTITY EXEC_stage;


ARCHITECTURE EXEC_arch OF EXEC_stage IS
component ALU IS
GENERIC (n : integer := 32);
	PORT(A,B: IN std_logic_vector(n-1 downto 0);
	     S: IN std_logic_vector(3 downto 0);
	     Rst,flag_en:IN std_logic;
	     F: INOUT  std_logic_vector(n-1 downto 0);
	     flagReg_out: INOUT std_logic_vector(3 downto 0)); 
END component ALU;

component flag_Register is  
  port(C,PRE,RST : in std_logic;  
        D : in  std_logic_vector (3 downto 0);  
        Q : out std_logic_vector (3 downto 0));  
end component flag_Register ; 

signal src1,src2,src2_1stMux: std_logic_vector(n-1 downto 0);
signal enable_flag_reg,preset_flags:std_logic;
signal my_output: std_logic_vector(n-1 downto 0);
signal falgs:std_logic_vector(3 downto 0);
begin
enable_flag_reg<='1' when opcode_in="01001" or opcode_in="01010" or opcode_in="01011" or opcode_in="00000" 
or opcode_in="00001" or opcode_in="00010" or opcode_in="00011" or opcode_in="00100" or opcode_in="00101" or opcode_in="00110";

opcode_out <= opcode_in;
src1<=Rsrc1 when Rsrc1_sel_forward="00"
else Rsrc1_mem when Rsrc1_sel_forward="01"
else Rsrc1_WB when Rsrc1_sel_forward="10";

src2_1stMux<=Rsrc2 when Rsrc2_sel='0' else imm when Rsrc2_sel='1';

src2<=src2_1stMux when Rsrc2_sel_forward="00"
else Rsrc2_mem when Rsrc2_sel_forward="01"
else Rsrc2_WB when Rsrc2_sel_forward="10";

my_alu:  ALU generic map(n) port map(src1,src2,opcode_in(3 downto 0),Rst,enable_flag_reg,my_output,falgs);
my_falg_reg: flag_Register port map(clk,preset_flags,Rst,falgs,flag_reg_out);

ALU_OUTPUT<= IO_IN when IO_ALU_SEL='1' else my_output when IO_ALU_SEL='0';
IO_OUT<= (OTHERS=>'Z') when OUT_SEL='0' else src1 when OUT_SEL='1';
end architecture;
