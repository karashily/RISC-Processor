import util
from ISA import *

def read(filename):
    file = open(filename,"r")
    ops = file.readlines()
    file.close()
    return ops
    
def clean(ops):
    for i in range(len(ops)):
        ops[i] = ops[i].replace("\n","").replace("\t", "")
        ops[i] = ops[i].split("#")[0]
        ops[i] = ops[i].replace(",", " ").split(" ")
        while '' in ops[i]:
            ops[i].remove('')
    while [] in ops:
        ops.remove([])
    return ops

def asm2mc(ops):
    machine_code = []
    for i in range(len(ops)):
        # checking for hexa nums using int() which return an exception if not a number
        if(len(ops[i])==1):
            try:    
                num = int(ops[i][0], 16)
                num = (32-len(bin(num))+2)*'0' + bin(num).replace("0b", "")
                machine_code.append(num[16:])
                machine_code.append(num[:16])
            except:
                # if it returns an exception then it's a no operand instruction
                opcode = util.get_opcode(ops[i][0])
                if(len(op_types[opcode])==0):
                    machine_code.append(opcode + '0' * (16-len(opcode)))
                else:
                    raise Exception("Fatal Error: Operation \"{}\" has {} operands, {} was entered".format(ops[i][0], len(op_types[opcode]), str(0)))
        else:
            # if it's more than one word
            if(ops[i][0].lower() == ".org"):     
                # checking if it's a .org
                for i in range(int(ops[i][1], 16) - len(machine_code)):
                    # fill the hole between the desired address and current address with zeros
                    machine_code.append("0100000000000000")

            else:        
                # else it's an instruction
                opcode = util.get_opcode(ops[i][0])
                gt_types = op_types[opcode]
                if(len(gt_types)==len(ops[i])-1):
                    for idx in range(len(ops[i])-1):
                        if(util.get_type(ops[i][idx+1]) != gt_types[idx]):
                            raise Exception("Fatal Error: Entered operand for operation \"{}\": \"{}\" is wrong".format(ops[i][0], ops[i][idx+1]))
                else:
                    raise Exception("Fatal Error: Operation \"{}\" has {} operands, {} was entered".format(ops[i][0], len(op_types[opcode]), len(ops[i])-1))
                mc = util.get_machine_code(ops[i])
                if(len(mc) == 16):
                    machine_code.append(mc)
                elif(len(mc) == 32):
                    machine_code.append(mc[:16])
                    machine_code.append(mc[16:])
    return machine_code

def prepare_ram(machine_code):
	ram = []
	for i in range(len(machine_code)):
		if(machine_code[i] != '0100000000000000'):
			entry = str(i) + " => \"" + machine_code[i] + "\","
			ram.append(entry)
	ram.append("others => \"0100000000000000\"")
	return ram

def convert_to_mem(machine_code):
    mem = []
    mem.append("// memory data file (do not edit the following line - required for mem load use)")
    mem.append("// instance=/main/memory/r/RAM")
    mem.append("// format=mti addressradix=d dataradix=h version=1.0 wordsperline=1")
    for i in range(len(machine_code)):
        hexa = hex(int(machine_code[i], 2)).replace("0x", "")
        hexa = '0' * (4-len(hexa)) + hexa
        mem.append(str(i) + ": " + hexa)
    for i in range(len(machine_code), 2048):
        mem.append(str(i) + ": 4000")
    return mem

asm_file = input("Assembly code filename: ")
ops = clean(read(asm_file))
machine_code = asm2mc(ops)
ram = prepare_ram(machine_code)

mc_filename = asm_file.split(".")[0] + ".txt"
mc_file = open(mc_filename, "w")
for i in ram:
     mc_file.write(i + "\n")
mc_file.close()

mem = convert_to_mem(machine_code)
mem_filename = asm_file.split(".")[0] + ".mem"
mem_file = open(mem_filename, "w")
for i in mem:
     mem_file.write(i + "\n")
mem_file.close()

print("Done...!\nOutput ram file = {}\nOutput mem file = {}".format(mc_filename, mem_filename))