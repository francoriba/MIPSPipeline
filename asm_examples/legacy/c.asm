DEFINE INT32 Label = 0b011
DEFINE INT16 Labelx = 0x6
DEFINE UINT8 labelz = 200
J FIVE
FIVE: AND r7,r4,r3
J THREE
THREE: SUBU r7,r4,r3
NOP
HALT