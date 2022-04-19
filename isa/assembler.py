import sys
import re
import math
import copy
from functools import reduce
from enum import Enum

class bcolors:
    PURPLE = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    ORANGE = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


REG_TYPE_2_MAX_NUM = { "t": 5, "s": 0, "a": 3, "v": 1 }
REG_TYPE_2_OFFSET = { "t": 5, "s": 11, "a": 11, "v": 14 }
ASM_TEMP_REG = 15

class Instruction(Enum):
    ADD_IMM = "addi"
    LOAD_IMM = "li"     # pseudo
    MOVE = "move"     # pseudo
    ADD = "add"
    RIGHT_SHIFT_LOGICAL = "srlv"
    LEFT_SHIFT_LOGICAL = "sllv"
    SUB = "sub"
    LOAD_WORD = "lw"
    SWAP = "swap"
    STORE_WORD = "sw"
    ROTATE_LEFT_BYTES = "rolb"
    XOR_BYTES = "xorb"
    JUMP = "j"
    BRANCH_NOT_EQUAL = "bne"
    BRANCH_EQUAL = "beq"
    NOP = "nop"

# op | rs | rt | rd | fn
R_TYPE_INSTRS = set([
    Instruction.ADD,
    Instruction.RIGHT_SHIFT_LOGICAL,
    Instruction.LEFT_SHIFT_LOGICAL,
    Instruction.SUB,
    Instruction.SWAP,
    Instruction.ROTATE_LEFT_BYTES,
    Instruction.XOR_BYTES,
])

# op | rs | rt | imm
I_TYPE_INSTRS = set([
    Instruction.ADD_IMM,
    Instruction.STORE_WORD,
    Instruction.LOAD_WORD,
    Instruction.BRANCH_NOT_EQUAL,
    Instruction.BRANCH_EQUAL
])

# op | addr
J_TYPE_INSTRS = set([
    Instruction.JUMP,
])

INSTR_2_OPCODE = {
    Instruction.ADD_IMM: 0b1010,
    Instruction.ADD: 0b0110,
    Instruction.NOP: 0b0000,
    Instruction.RIGHT_SHIFT_LOGICAL: 0b1100,
    Instruction.LEFT_SHIFT_LOGICAL: 0b1011,
    Instruction.SUB: 0b1101,
    Instruction.LOAD_WORD: 0b0001,
    Instruction.SWAP: 0b0011,
    Instruction.STORE_WORD: 0b0010,
    Instruction.ROTATE_LEFT_BYTES: 0b0100,
    Instruction.XOR_BYTES: 0b0101,
    Instruction.JUMP: 0b0111,
    Instruction.BRANCH_NOT_EQUAL: 0b1000,
    Instruction.BRANCH_EQUAL: 0b1001,
}

class AssemblyDataType(Enum):
    INSTRUCTION = 0
    LABEL = 1
    CONSTANT = 2
    DIRECTIVE = 3

class DirectiveType(Enum):
    TEXT = "text"
    DATA = "data"
    SPACE = "space"

class AssemblerMode(Enum):
    TEXT = 0
    DATA = 1

def compose(*fns):
    return reduce(lambda f, g: lambda x: f(g(x)), fns, lambda x: x)

def remove_comment(line):
    res_line = re.sub(r"#.*", "", line)
    return res_line

def strip(line):
    return line.strip()

def encode_instr(instruction):
    instr_func, func_args = instruction

    if instr_func == Instruction.NOP:
        bit_str = '{0:0>24}'.format(bin(0x00)[2:])
        return (0x000000, bit_str)

    elif instr_func in R_TYPE_INSTRS:
        # add rd, rs, rt
        # op | rs | rt | rd
        op = INSTR_2_OPCODE[instr_func]
        rs = func_args[1]
        rt = func_args[2]
        rd = func_args[0]
        bit24 = (op << 20) | (rs << 16) | (rt << 12) | (rd << 0)
        bit_str = '{0:0>24}'.format(bin(bit24)[2:])
        debug_str = f'{bcolors.CYAN}{bit_str[0:4]}{bcolors.GREEN}{bit_str[4:8]}{bcolors.RED}{bit_str[8:12]}{bcolors.ENDC}{bit_str[12:20]}{bcolors.PURPLE}{bit_str[20:24]}{bcolors.ENDC}'
        return (bit24, debug_str)
    elif instr_func in I_TYPE_INSTRS:
        # addi rs, rt, imm
        # op | rs | rt | imm
        op = INSTR_2_OPCODE[instr_func]
        rs = func_args[1]
        rt = func_args[0]
        imm = func_args[2]
        if imm > (2**12 -1):
            print(f'immediate value: {imm} is larger than max supported ({2**12 - 1})')
            exit(1)
        bit24 = (op << 20) | (rs << 16) | (rt << 12) | (imm << 0)
        bit_str = '{0:0>24}'.format(bin(bit24)[2:])
        debug_str = f'{bcolors.CYAN}{bit_str[0:4]}{bcolors.GREEN}{bit_str[4:8]}{bcolors.RED}{bit_str[8:12]}{bcolors.ORANGE}{bit_str[12:24]}{bcolors.ENDC}'
        return (bit24, debug_str)
    elif instr_func in J_TYPE_INSTRS:
        # j label
        # op | addr
        op = INSTR_2_OPCODE[instr_func]
        addr = func_args[0]
        if addr > (2**24 -1):
            print(f'jump addr: {addr} is larger than max supported ({2**24 - 1})')
            exit(1)
        bit24 = (op << 20) | (addr << 0)
        bit_str = '{0:0>24}'.format(bin(bit24)[2:])
        debug_str = f'{bcolors.CYAN}{bit_str[0:4]}{bcolors.ORANGE}{bit_str[4:24]}{bcolors.ENDC}'
        return (bit24, debug_str)
    else:
        print(f'reg {instr_func} not supported.')
        exit(1)

def create_instr(parsed_line, constants):
    func, func_args = parsed_line
    parsed_func_args = []

    def resolve_reg(reg_str):
        if reg_str == "$zero":
            return 0
        elif reg_str == "$rec":
            return 1
        elif reg_str == "$send":
            return 2
        elif reg_str == "$tag":
            return 3
        elif reg_str == "$busy":
            return 4
        else:
            res = re.match(r"\$(t|s|a|v)([0-9]+)", reg_str)
            if not res:
                print(f'reg {func_arg} not supported')
                exit(1)

            reg_type = res.group(1)
            reg_num = int(res.group(2), 10)
            max_num = REG_TYPE_2_MAX_NUM[reg_type]
            offset = REG_TYPE_2_OFFSET[reg_type]
            if reg_num > max_num:
                print(f'reg {func_arg} not supported. {reg_num} needs to be less or equal to {max_num}')
                exit(1)
            return offset + reg_num
    
    for func_arg in func_args:
        # is register?
        if func_arg.startswith("$"):
            parsed_func_args.append(resolve_reg(func_arg))
        # is immediate value?
        elif func_arg in constants or re.match(r"^(0x|0b|0o|[0-9])", func_arg):
            imm_v = constants[func_arg] if func_arg in constants else int(func_arg, 0)
            if imm_v > (2**12 - 1) and (func == Instruction.LOAD_IMM or func == Instruction.ADD_IMM):
                # li $t2, 0x01345678
                imm_nbytes = math.ceil(len(hex(imm_v)[2:]) / 2)
                target_reg = parsed_func_args[0]
                instrs = []
                for ith_byte in range(0, imm_nbytes):
                    instrs = instrs + [
                        # addi  $t2, $zero, 0x01
                        (Instruction.ADD_IMM, (target_reg, 0, (imm_v >> 8*ith_byte) & 0xFF)),
                        # addi  $at, $zero, (32 - 8*(ith_byte+1))
                        (Instruction.ADD_IMM, (ASM_TEMP_REG, 0, 8*ith_byte)),
                        # sllv  $at, $t2, $at
                        (Instruction.LEFT_SHIFT_LOGICAL, (ASM_TEMP_REG, target_reg, ASM_TEMP_REG)),
                        # add   $t2, $t2, $at
                        (Instruction.ADD, (target_reg, target_reg, ASM_TEMP_REG)),
                    ]

                # can only return since we know that the immediate value
                # is always last for the li and addi instr
                return instrs
            else:
                parsed_func_args.append(imm_v)
        # is label
        elif re.match(r"([a-z][a-z0-9_]*)", func_arg):
            if func == Instruction.LOAD_WORD or func == Instruction.STORE_WORD:
                res = re.match(r"([a-z][a-z0-9_]*)\((.*)\)", func_arg)
                if res:
                    parsed_func_args.append(resolve_reg(res.group(2)))
                    parsed_func_args.append(res.group(1))
                else:
                    parsed_func_args.append(0)
                    parsed_func_args.append(func_arg)
            else:
                parsed_func_args.append(func_arg)
        # is constant
        elif re.match(r"([A-Z0-9_]+)", func_arg):
            if func == Instruction.LOAD_WORD or func == Instruction.STORE_WORD:
                parsed_func_args.append(0)
                if constants[func_arg] % 4 != 0:
                    print(f'space needs to be 4 byte aligned, instead received {constants[func_arg]}')
                    exit(1)
                parsed_func_args.append(int(constants[func_arg] / 4))
            else:
                parsed_func_args.append(constants[func_arg])
        else:
            print(f'func_arg {func_arg} not supported')
            exit(1)

    # handle psuedo instructions
    if func == Instruction.LOAD_IMM:
        func = Instruction.ADD_IMM
        # li    $t3, 0x12     <=>     addi    $t3, $zero, 0x12
        parsed_func_args = [parsed_func_args[0], 0, parsed_func_args[1]]
    elif func == Instruction.MOVE:
        func = Instruction.ADD_IMM
        # move  $t3, $t4      <=>     addi    $t3, $t4, $zero
        parsed_func_args = [parsed_func_args[0], parsed_func_args[1], 0]

    return [(func, tuple(parsed_func_args))]


def parse_lines(lines):
    for line_i, line in enumerate(lines):
        # is empty line?
        if line == "":
            continue

        # is constant?
        # res = re.match(r"([A-Z0-9_]+)\s*=\s*([A-Za-z0-9]+)", line)
        res = re.match(r"([A-Z0-9_]+)\s*=\s*(.+)", line)
        if res:
            yield (AssemblyDataType.CONSTANT, (res.group(1).strip(), res.group(2).strip()), (line_i, line))
            continue

        # is label?
        res = re.match(r"([a-z0-9_]+):", line)
        if res:
            yield (AssemblyDataType.LABEL, (res.group(1).strip(),), (line_i, line))
            continue

        # is directive?
        res = re.match(r"^\.([a-z]+)\s*([0-9]*)", line)
        if res:
            directive = DirectiveType[res.group(1).strip().upper()]
            if directive == DirectiveType.SPACE:
                yield (AssemblyDataType.DIRECTIVE, (directive, int(res.group(2).strip(), 0)), (line_i, line))
            else:
                yield (AssemblyDataType.DIRECTIVE, (directive,), (line_i, line))
            continue

        # is instruction?
        for instr in Instruction:
            if line.startswith(instr.value):
                # sub     $t1, $a2, $t0
                instr_args_str = line[len(instr.value):]
                if instr_args_str == "":
                    yield (AssemblyDataType.INSTRUCTION, (instr, ()), (line_i, line))
                else:
                    instr_args = [strip(arg_str) for arg_str in line[len(instr.value):].split(',')]
                    yield (AssemblyDataType.INSTRUCTION, (instr, tuple(instr_args)), (line_i, line))
                break


def emit_instrs(lines):
    asm_mode = AssemblerMode.TEXT

    next_text_addr = 0
    labels = {}
    constants = {}

    next_data_addr = 0

    instructions = []

    # 1st pass
    for line_type, parsed_line, line_info in parse_lines(lines):

        if line_type == AssemblyDataType.INSTRUCTION:
            created_instrs = [instr + ((line_info),) for instr in create_instr(parsed_line, constants)]
            next_text_addr = next_text_addr + len(created_instrs)
            instructions = instructions + created_instrs

        elif line_type == AssemblyDataType.LABEL:
            labels[parsed_line[0]] = next_text_addr if asm_mode == AssemblerMode.TEXT else next_data_addr

        elif line_type == AssemblyDataType.CONSTANT:
            constants_local = copy.deepcopy(constants) # need to copy as eval will mutate the arg: global
            v = eval(parsed_line[1], constants_local)
            constants[parsed_line[0]] = v

        elif line_type == AssemblyDataType.DIRECTIVE:
            if parsed_line[0] == DirectiveType.TEXT:
                asm_mode = AssemblerMode.TEXT
            elif parsed_line[0] == DirectiveType.DATA:
                asm_mode = AssemblerMode.DATA
            elif parsed_line[0] == DirectiveType.SPACE:
                if parsed_line[1] % 4 != 0:
                    print(f'space needs to be 4 byte aligned, instead received {parsed_line[1]}')
                    exit(1)

                next_data_addr = next_data_addr + (int(parsed_line[1] / 4))

        else:
            print(f'line_type {line_type} not supported')
            exit(1)

    def resolve_labels(func_args):
        return tuple([labels[a] if a in labels else a for a in func_args])

    # 2nd pass
    nop_instr = (Instruction.NOP, (), ())
    for instr_addr, instruction in enumerate(instructions + [nop_instr]):
        instr_func, func_args, line_info = instruction
        res_func_args = resolve_labels(func_args)
        bit24, debug_str = encode_instr((instr_func, res_func_args))
        line_details = () if len(line_info) == 0 else (line_info[0], line_info[1])
        comment = ' -- {0: <3}'.format(line_details[0]) + f' {line_details[1]}' if len(line_details) > 0 else ''
        instr_vhdl = 'var_insn_mem(' + '{0: <2}'.format(instr_addr) + ') := ' + 'x"{0:0>6}"'.format(hex(bit24)[2:]).upper() + comment
        yield (bit24, instr_vhdl, debug_str, (instr_func, res_func_args, line_details))

def main():
    if len(sys.argv) <= 1:
        print(f'usage: python assembler.py [-d] <filename.s> [-o <output.vhdl>]')
        exit(1)
    
    debug_flag = sys.argv[1] == '-d'
    assembly_pathname = sys.argv[2 if debug_flag else 1]

    output_opt = sys.argv[3 if debug_flag else 2] == '-o' if len(sys.argv) > 2 else False

    with open(assembly_pathname) as f:
        lines = f.readlines()

        clean_up_line = compose(
            strip,
            remove_comment
        )

        of = open(sys.argv[4 if debug_flag else 3], "w+") if output_opt else None

        for instr_i, (instr_bit24, instr_vhdl, instr_debug_str, instr_desc) in enumerate(emit_instrs([clean_up_line(l) for l in lines])):
            if debug_flag:
                desc = (instr_desc[0].name, instr_desc[1], instr_desc[2])
                print('{0: <3}'.format(instr_i), '{0: <8}'.format(hex(instr_bit24)), instr_debug_str, desc)

            if output_opt:
                of.write(f'{instr_vhdl}\n')
        
        if of:
            of.close()

main()
