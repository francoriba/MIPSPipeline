# INSTRUCTION SET ARCHITECTURE FOR MIPS32

OP_CODE_R      = '000000'
OP_CODE_J      = '000010'
OP_CODE_JAL    = '000011'
OP_CODE_BEQ    = '000100'
OP_CODE_BNE    = '000101'
OP_CODE_ADDI   = '001000'
OP_CODE_SLTI   = '001010'
OP_CODE_ANDI   = '001100'
OP_CODE_ORI    = '001101'
OP_CODE_XORI   = '001110'
OP_CODE_LUI    = '001111'
OP_CODE_LB     = '100000'
OP_CODE_LH     = '100001'
OP_CODE_LW     = '100011'
OP_CODE_LBU    = '100100'
OP_CODE_LHU    = '100101'
OP_CODE_SB     = '101000'
OP_CODE_SH     = '101001'
OP_CODE_SW     = '101011'
OP_CODE_LWU    = '100111'

FUNC_CODE_JR   = '001000'
FUNC_CODE_JALR = '001001'
FUNC_CODE_SLL  = '000000'
FUNC_CODE_SRL  = '000010'
FUNC_CODE_SRA  = '000011'
FUNC_CODE_SLLV = '000100'
FUNC_CODE_SRLV = '000110'
FUNC_CODE_SRAV = '000111'
FUNC_CODE_ADDU = '100001'
FUNC_CODE_SUBU = '100011'
FUNC_CODE_AND  = '100100'
FUNC_CODE_OR   = '100101'
FUNC_CODE_XOR  = '100110'
FUNC_CODE_NOR  = '100111'
FUNC_CODE_SLT  = '101010'

instructionTable = {
    #R type
    'SLL'  : [ OP_CODE_R, FUNC_CODE_SLL  ],  #Rd = Rt << Shamt; Rs = 0x00
    'SRL'  : [ OP_CODE_R, FUNC_CODE_SRL  ],  #Rd = Rt >> Shamt; Rs = 0x00
    'SRA'  : [ OP_CODE_R, FUNC_CODE_SRA  ],  #Rd = Rt >>> Shamt; Rs = 0x00
    'SLLV' : [ OP_CODE_R, FUNC_CODE_SLLV ],  #Rd = Rt << Rs; Shamt = 0x00
    'SRLV' : [ OP_CODE_R, FUNC_CODE_SRLV ],  #Rd = Rt >> Rs; Shamt = 0x00
    'SRAV' : [ OP_CODE_R, FUNC_CODE_SRAV ],  #Rd = Rt >>> Rs; Shamt = 0x00
    'ADDU' : [ OP_CODE_R, FUNC_CODE_ADDU ],  #Rd = Rs + Rt; Shamt = 0x00
    'SUBU' : [ OP_CODE_R, FUNC_CODE_SUBU ],  #Rd = Rs - Rt; Shamt = 0x00
    'AND'  : [ OP_CODE_R, FUNC_CODE_AND  ],  #Rd = Rs & Rt; Shamt = 0x00
    'OR'   : [ OP_CODE_R, FUNC_CODE_OR   ],  #Rd = Rs | Rt; Shamt = 0x00
    'XOR'  : [ OP_CODE_R, FUNC_CODE_XOR  ],  #Rd = Rs ^ Rt; Shamt = 0x00
    'NOR'  : [ OP_CODE_R, FUNC_CODE_NOR  ],  #Rd = ~(Rs | Rt); Shamt = 0x00
    'SLT'  : [ OP_CODE_R, FUNC_CODE_SLT  ],  #Rd = (Rs < Rt) ? 1 : 0; Shamt = 0x00
    'JALR' : [ OP_CODE_R, FUNC_CODE_JALR ], #R31 = PC + 4; PC = Rs; Shamt = 0x00
    'JR'   : [ OP_CODE_R, FUNC_CODE_JR   ], #PC = Rs
    
    #I type
    'LB'   : [ OP_CODE_LB   ], #Rt = sigextend(Mem[Rs + unsigextend(INM)])
    'LH'   : [ OP_CODE_LH   ], #Rt = sigextend(Mem[Rs + unsigextend(INM)])
    'LW'   : [ OP_CODE_LW   ], #Rt = Mem[Rs + unsigextend(INM)]
    'LWU'  : [ OP_CODE_LWU  ], #Rt = Mem[Rs + unsigextend(INM)]
    'LBU'  : [ OP_CODE_LBU  ], #Rt = unsigextend(Mem[Rs + unsigextend(INM)])
    'LHU'  : [ OP_CODE_LHU  ], #Rt = unsigextend(Mem[Rs + unsigextend(INM)])
    'SB'   : [ OP_CODE_SB   ], #Mem[Rs + unsigextend(INM)] = Rt[7:0] 
    'SH'   : [ OP_CODE_SH   ], #Mem[Rs + unsigextend(INM)] = Rt[15:0]
    'SW'   : [ OP_CODE_SW   ], #Mem[Rs + unsigextend(INM)] = Rt[31:0]
    'ADDI' : [ OP_CODE_ADDI ], #Rt = Rs + sigextend(INM)
    'ANDI' : [ OP_CODE_ANDI ], #Rt = Rs & unsigextend(INM)
    'ORI'  : [ OP_CODE_ORI  ], #Rt = Rs | unsigextend(INM)
    'XORI' : [ OP_CODE_XORI ], #Rt = Rs ^ unsigextend(INM)
    'LUI'  : [ OP_CODE_LUI  ], #Rt = INM << 16; Rs = 0x00
    'SLTI' : [ OP_CODE_SLTI ], #Rt = (Rs < sigextend(INM)) ? 1 : 0
    'BEQ'  : [ OP_CODE_BEQ  ], #if (Rs == Rt) PC = PC + 4 + (INM << 2)
    'BNE'  : [ OP_CODE_BNE  ], #if (Rs != Rt) PC = PC + 4 + (INM << 2)

    
    
    #J type
    'J'    : [ OP_CODE_J,   'DIR' ], #PC = (PC & 0xf0000000) | (DIR << 2)
    'JAL'  : [ OP_CODE_JAL, 'DIR' ], #R31 = PC + 4; PC = (PC & 0xf0000000) | (DIR << 2)

    'NOP'  : [ '0x00000000' ], #No Operation
    'HALT' : [ '0xffffffff' ]  #Halt
}

load_and_store_inst = ['LB', 'LH', 'LW', 'LBU', 'LHU', 'SB', 'SH', 'SW', 'LWU']

registerTable = {
    'r0'  : 0,
    'r1'  : 1,
    'r2'  : 2,
    'r3'  : 3,
    'r4'  : 4,
    'r5'  : 5,
    'r6'  : 6,
    'r7'  : 7,
    'r8'  : 8,
    'r9'  : 9,
    'r10' : 10,
    'r11' : 11,
    'r12' : 12,
    'r13' : 13,
    'r14' : 14,
    'r15' : 15,
    'r16' : 16,
    'r17' : 17,
    'r18' : 18,
    'r19' : 19,
    'r20' : 20,
    'r21' : 21,
    'r22' : 22,
    'r23' : 23,
    'r24' : 24,
    'r25' : 25,
    'r26' : 26,
    'r27' : 27,
    'r28' : 28,
    'r29' : 29,
    'r30' : 30,
    'r31' : 31
}
