library ieee;
use ieee.std_logic_1164.all;

entity mimic_forward is
  port(regcode : in std_logic_vector(2 downto 0);
      reg : out std_logic_vector(31 downto 0);
      --codes to compare
      exec_src1,exec_src2,exec_dst: in std_logic_vector(2 downto 0);
      mem_src: in std_logic_vector(2 downto 0);
      wb_src: in std_logic_vector(2 downto 0);
      src1_exec_value,src2_exec_value,exec_dst_value,mem_value,wb_value,reg_file_value:IN std_logic_vector(31 downto 0);
      src1_dec,src2_dec,dst_dec:in  std_logic_vector(2 downto 0);
      regcode_in_decode: out std_logic;

      opcode_in_decode:in std_logic_vector(4 downto 0);
      csFlush_exec:in std_logic;
      opcode_in_exec:in std_logic_vector(4 downto 0);
      dec_imm:IN std_logic_vector(31 downto 0);
      csFlush_dec:in std_logic;
      regcode_in_exec:out std_logic
      );
end mimic_forward;

architecture mimic_forward_arch of mimic_forward is

  component reg_code_changing is
    port(opcode : in std_logic_vector(4 downto 0);
    src1, src2, dst: in std_logic_vector(2 downto 0);
    flush: in std_logic;
    is_execute_changing: out std_logic;
    q: out std_logic_vector(1 downto 0));
  
  end component;

  signal is_execute_changing: std_logic;
  signal exec_changing: std_logic_vector(1 downto 0);
  begin
    exec: reg_code_changing port map(opcode_in_exec,exec_src1,exec_src2,exec_dst,csFlush_exec,is_execute_changing,exec_changing);
    reg <= exec_dst_value when ((exec_changing = "00") and (exec_src1 = regcode) and (is_execute_changing = '1')) else
            exec_dst_value when ((exec_changing = "11") and (exec_src2 = regcode) and (is_execute_changing = '1')) else
           exec_dst_value when ((exec_changing = "01") and (exec_dst = regcode) and (is_execute_changing = '1')) else
           mem_value when (regcode=mem_src) else
           wb_value when (regcode=wb_src) else
           dec_imm when (regcode=src1_dec) else
           reg_file_value;
    
    -- reg <=src1_exec_value when( regcode=exec_src1 ) 
    -- else src2_exec_value when( regcode=exec_src2 )
    -- else mem_value when (regcode=mem_src )
    -- else wb_value when (  regcode=wb_src ) 
    -- else exec_dst_value when (regcode=exec_dst)
    -- else exec_dst_value when(regcode=exec_src1 and (opcode_in_exec="01001" or opcode_in_exec="01010" or opcode_in_exec="01011" or opcode_in_exec="01100" or opcode_in_exec="01101"))
    -- else reg_file_value ;

    regcode_in_decode<='1' when (regcode=src1_dec and csFlush_dec='0' and  (opcode_in_decode="01001" or opcode_in_decode="01010" 
    or opcode_in_decode="01011" or opcode_in_decode="01101" or opcode_in_decode="00111" or opcode_in_decode="00101"
    or opcode_in_decode="00110" or opcode_in_decode="10001"  or opcode_in_decode="10011"))
    else '1' when (regcode=src2_dec and opcode_in_decode="00111" and csFlush_dec='1')
    else '1' when (regcode=dst_dec and csFlush_dec='0' and (opcode_in_decode="00000" or opcode_in_decode="00001" or opcode_in_decode="00010"
    or opcode_in_decode="00011" or opcode_in_decode="00100") )
    else '0';
    regcode_in_exec<='1' when (csFlush_exec='0'and (opcode_in_exec="10001" or opcode_in_exec="10011")) else '0';
  end architecture;