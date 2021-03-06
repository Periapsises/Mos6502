Mos.Assembler.Instructions = Mos.Assembler.Instructions or {}
local Instructions = Mos.Assembler.Instructions

--? Lookup for an instruction's name[addressing mode] -> Bytecode
Instructions.bytecodes = {
    ["adc"] = { imm = 0x69, zpg = 0x65, zpgx = 0x75, abs = 0x6d, absx = 0x7d, absy = 0x79, xind = 0x61, indy = 0x71 },
    ["and"] = { imm = 0x29, zpg = 0x25, zpgx = 0x35, abs = 0x2d, absx = 0x3d, absy = 0x39, xind = 0x21, indy = 0x31 },
    ["asl"] = { acc = 0x0a, zpg = 0x06, zpgx = 0x16, abs = 0x0e, absx = 0x1e },
    ["bcc"] = { rel = 0x90 },
    ["bcs"] = { rel = 0xb0 },
    ["beq"] = { rel = 0xf0 },
    ["bit"] = { zpg = 0x24, abs = 0x2c },
    ["bmi"] = { rel = 0x30 },
    ["bne"] = { rel = 0xd0 },
    ["bpl"] = { rel = 0x10 },
    ["brk"] = { imp = 0x00 },
    ["bvc"] = { rel = 0x50 },
    ["bvs"] = { rel = 0x70 },
    ["clc"] = { imp = 0x18 },
    ["cld"] = { imp = 0xd8 },
    ["cli"] = { imp = 0x58 },
    ["clv"] = { imp = 0xb8 },
    ["cmp"] = { imm = 0xc9, zpg = 0xc5, zpgx = 0xd5, abs = 0xcd, absx = 0xdd, absy = 0xd9, xind = 0xc1, indy = 0xd1 },
    ["cpx"] = { imm = 0xe0, zpg = 0xe4, abs = 0xec },
    ["cpy"] = { imm = 0xc0, zpg = 0xc4, abs = 0xcc },
    ["dec"] = { zpg = 0xc6, zpgx = 0xd6, abs = 0xce, absx = 0xde },
    ["dex"] = { imp = 0xca },
    ["dey"] = { imp = 0x88 },
    ["eor"] = { imm = 0x49, zpg = 0x45, zpgx = 0x55, abs = 0x4d, absx = 0x5d, absy = 0x59, xind = 0x41, indy = 0x51 },
    ["inc"] = { zpg = 0xe6, zpgx = 0xf6, abs = 0xee, absx = 0xfe },
    ["inx"] = { imp = 0xe8 },
    ["iny"] = { imp = 0xc8 },
    ["jmp"] = { abs = 0x4c, ind = 0x6c },
    ["jsr"] = { abs = 0x20 },
    ["lda"] = { imm = 0xa9, zpg = 0xa5, zpgx = 0xb5, abs = 0xad, absx = 0xbd, absy = 0xb9, xind = 0xa1, indy = 0xb },
    ["ldx"] = { imm = 0xa2, zpg = 0xa6, zpgy = 0xb6, abs = 0xae, absy = 0xbe },
    ["ldy"] = { imm = 0xa0, zpg = 0xa4, zpgx = 0xb4, abs = 0xac, absx = 0xbc },
    ["lsr"] = { acc = 0x4a, zpg = 0x46, zpgx = 0x56, abs = 0x4e, absx = 0x5e },
    ["nop"] = { imp = 0xea },
    ["ora"] = { imm = 0x09, zpg = 0x05, zpgx = 0x15, abs = 0x0d, absx = 0x1d, absy = 0x19, xind = 0x01, indy = 0x11 },
    ["pha"] = { imp = 0x48 },
    ["php"] = { imp = 0x08 },
    ["pla"] = { imp = 0x68 },
    ["plp"] = { imp = 0x28 },
    ["rol"] = { acc = 0x2a, zpg = 0x26, zpgx = 0x36, abs = 0x2e, absx = 0x3e },
    ["ror"] = { acc = 0x6a, zpg = 0x66, zpgx = 0x76, abs = 0x6e, absx = 0x7e },
    ["rti"] = { imp = 0x40 },
    ["rts"] = { imp = 0x60 },
    ["sbc"] = { imm = 0xe9, zpg = 0xe5, zpgx = 0xf5, abs = 0xed, absx = 0xfd, absy = 0xf9, xind = 0xe1, indy = 0xf1 },
    ["sec"] = { imp = 0x38 },
    ["sed"] = { imp = 0xf8 },
    ["sei"] = { imp = 0x78 },
    ["sta"] = { zpg = 0x85, zpgx = 0x95, abs = 0x8d, absx = 0x9d, absy = 0x99, xind = 0x81, indy = 0x91 },
    ["stx"] = { zpg = 0x86, zpgy = 0x96, abs = 0x8e },
    ["sty"] = { zpg = 0x84, zpgx = 0x94, abs = 0x8c },
    ["tax"] = { imp = 0xaa },
    ["tay"] = { imp = 0xa8 },
    ["tsx"] = { imp = 0xba },
    ["txa"] = { imp = 0x8a },
    ["txs"] = { imp = 0x9a },
    ["tya"] = { imp = 0x98 }
}

--? Lookup for an instruction's bytcode -> 1: Name 2: Standard clock count
Instructions.opcodes = {
    { "ora", 6 },{ "???", 2 },{ "???", 8 },{ "???", 3 },{ "ora", 3 },{ "asl", 5 },{ "???", 5 },{ "php", 3 },{ "ora", 2 },{ "asl", 2 },{ "???", 2 },{ "???", 4 },{ "ora", 4 },{ "asl", 6 },{ "???", 6 },
    { "bpl", 2 },{ "ora", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "ora", 4 },{ "asl", 6 },{ "???", 6 },{ "clc", 2 },{ "ora", 4 },{ "???", 2 },{ "???", 7 },{ "???", 4 },{ "ora", 4 },{ "asl", 7 },{ "???", 7 },
    { "jsr", 6 },{ "and", 6 },{ "???", 2 },{ "???", 8 },{ "bit", 3 },{ "and", 3 },{ "rol", 5 },{ "???", 5 },{ "plp", 4 },{ "and", 2 },{ "rol", 2 },{ "???", 2 },{ "bit", 4 },{ "and", 4 },{ "rol", 6 },{ "???", 6 },
    { "bmi", 2 },{ "and", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "and", 4 },{ "rol", 6 },{ "???", 6 },{ "sec", 2 },{ "and", 4 },{ "???", 2 },{ "???", 7 },{ "???", 4 },{ "and", 4 },{ "rol", 7 },{ "???", 7 },
    { "rti", 6 },{ "eor", 6 },{ "???", 2 },{ "???", 8 },{ "???", 3 },{ "eor", 3 },{ "lsr", 5 },{ "???", 5 },{ "pha", 3 },{ "eor", 2 },{ "lsr", 2 },{ "???", 2 },{ "jmp", 3 },{ "eor", 4 },{ "lsr", 6 },{ "???", 6 },
    { "bvc", 2 },{ "eor", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "eor", 4 },{ "lsr", 6 },{ "???", 6 },{ "cli", 2 },{ "eor", 4 },{ "???", 2 },{ "???", 7 },{ "???", 4 },{ "eor", 4 },{ "lsr", 7 },{ "???", 7 },
    { "rts", 6 },{ "adc", 6 },{ "???", 2 },{ "???", 8 },{ "???", 3 },{ "adc", 3 },{ "ror", 5 },{ "???", 5 },{ "pla", 4 },{ "adc", 2 },{ "ror", 2 },{ "???", 2 },{ "jmp", 5 },{ "adc", 4 },{ "ror", 6 },{ "???", 6 },
    { "bvs", 2 },{ "adc", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "adc", 4 },{ "ror", 6 },{ "???", 6 },{ "sei", 2 },{ "adc", 4 },{ "???", 2 },{ "???", 7 },{ "???", 4 },{ "adc", 4 },{ "ror", 7 },{ "???", 7 },
    { "???", 2 },{ "sta", 6 },{ "???", 2 },{ "???", 6 },{ "sty", 3 },{ "sta", 3 },{ "stx", 3 },{ "???", 3 },{ "dey", 2 },{ "???", 2 },{ "txa", 2 },{ "???", 2 },{ "sty", 4 },{ "sta", 4 },{ "stx", 4 },{ "???", 4 },
    { "bcc", 2 },{ "sta", 6 },{ "???", 2 },{ "???", 6 },{ "sty", 4 },{ "sta", 4 },{ "stx", 4 },{ "???", 4 },{ "tya", 2 },{ "sta", 5 },{ "txs", 2 },{ "???", 5 },{ "???", 5 },{ "sta", 5 },{ "???", 5 },{ "???", 5 },
    { "ldy", 2 },{ "lda", 6 },{ "ldx", 2 },{ "???", 6 },{ "ldy", 3 },{ "lda", 3 },{ "ldx", 3 },{ "???", 3 },{ "tay", 2 },{ "lda", 2 },{ "tax", 2 },{ "???", 2 },{ "ldy", 4 },{ "lda", 4 },{ "ldx", 4 },{ "???", 4 },
    { "bcs", 2 },{ "lda", 5 },{ "???", 2 },{ "???", 5 },{ "ldy", 4 },{ "lda", 4 },{ "ldx", 4 },{ "???", 4 },{ "clv", 2 },{ "lda", 4 },{ "tsx", 2 },{ "???", 4 },{ "ldy", 4 },{ "lda", 4 },{ "ldx", 4 },{ "???", 4 },
    { "cpy", 2 },{ "cmp", 6 },{ "???", 2 },{ "???", 8 },{ "cpy", 3 },{ "cmp", 3 },{ "dec", 5 },{ "???", 5 },{ "iny", 2 },{ "cmp", 2 },{ "dex", 2 },{ "???", 2 },{ "cpy", 4 },{ "cmp", 4 },{ "dec", 6 },{ "???", 6 },
    { "bne", 2 },{ "cmp", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "cmp", 4 },{ "dec", 6 },{ "???", 6 },{ "cld", 2 },{ "cmp", 4 },{ "nop", 2 },{ "???", 7 },{ "???", 4 },{ "cmp", 4 },{ "dec", 7 },{ "???", 7 },
    { "cpx", 2 },{ "sbc", 6 },{ "???", 2 },{ "???", 8 },{ "cpx", 3 },{ "sbc", 3 },{ "inc", 5 },{ "???", 5 },{ "inx", 2 },{ "sbc", 2 },{ "nop", 2 },{ "???", 2 },{ "cpx", 4 },{ "sbc", 4 },{ "inc", 6 },{ "???", 6 },
    { "beq", 2 },{ "sbc", 5 },{ "???", 2 },{ "???", 8 },{ "???", 4 },{ "sbc", 4 },{ "inc", 6 },{ "???", 6 },{ "sed", 2 },{ "sbc", 4 },{ "nop", 2 },{ "???", 7 },{ "???", 4 },{ "sbc", 4 },{ "inc", 7 },{ "???", 7 }
}
Instructions.opcodes[0x00] = { "brk", 7 }

Instructions.modeByteSize = {
    ["Accumulator"] = 0,
    ["Absolute"] = 2,
    ["Absolute,X"] = 2,
    ["Absolute,Y"] = 2,
    ["Immediate"] = 1,
    ["Implied"] = 0,
    ["Indirect"] = 2,
    ["X,Indirect"] = 1,
    ["Indirect,Y"] = 1,
    ["Relative"] = 1
}

Instructions.modeLookup = {
    ["Accumulator"] = "acc",
    ["Absolute"] = "abs",
    ["Absolute,X"] = "absx",
    ["Absolute,Y"] = "absy",
    ["Immediate"] = "imm",
    ["Implied"] = "imp",
    ["Indirect"] = "ind",
    ["X,Indirect"] = "xind",
    ["Indirect,Y"] = "indy",
    ["Relative"] = "rel"
}
