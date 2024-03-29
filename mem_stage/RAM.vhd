library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity RAM is
  port(
   RAM_CLOCK: in std_logic; 
   RAM_INS_ADDR: in std_logic_vector(10 downto 0);  
   RAM_DATA_ADDR: in std_logic_vector(10 downto 0);  
   RAM_DATA_WR: in std_logic;
   RAM_INS_WR: in std_logic; 
   RAM_INS_IN: in std_logic_vector(15 downto 0);
   RAM_INS_OUT: out std_logic_vector(15 downto 0);
   RAM_DATA_IN: in std_logic_vector(31 downto 0);
   RAM_DATA_OUT: out std_logic_vector(31 downto 0)
  );
end RAM;

architecture Behavioral of RAM is
type RAM_ARRAY is array (0 to 2047 ) of std_logic_vector (15 downto 0);
signal RAM: RAM_ARRAY :=(others =>"0000000000000000"); 
signal read_data_1,read_data_2,read_ins : std_logic_vector(15 downto 0);

begin
process(RAM_CLOCK)is
begin
 if(rising_edge(RAM_CLOCK)) then
 if(RAM_DATA_WR='1') then  
 RAM(to_integer(unsigned(RAM_DATA_ADDR))) <= RAM_DATA_IN(15 downto 0);
 RAM(to_integer(unsigned(RAM_DATA_ADDR))-1) <= RAM_DATA_IN(31 downto 16);
 end if;
 if(RAM_INS_WR='1') then  
 RAM(to_integer(unsigned(RAM_INS_ADDR))) <= RAM_INS_IN;
 end if;
 read_data_2 <= RAM(to_integer(unsigned(RAM_DATA_ADDR)));
 read_data_1 <= RAM(to_integer(unsigned(RAM_DATA_ADDR)) - 1);
 read_ins <=RAM(to_integer(unsigned(RAM_INS_ADDR))) ;
 end if;  
end process;
RAM_INS_OUT<=read_ins;
RAM_DATA_OUT<=read_data_2 & read_data_1;
end Behavioral;

