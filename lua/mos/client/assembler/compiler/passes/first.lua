local instructions = Mos.Assembler.Instructions
local directives = Mos.Assembler.Compiler.directives

--[[
    @class FirstPass
    @desc The first pass performed by the compiler.
    @desc Locates and stores all labels
]]
Mos.Assembler.Compiler.passes[1] = Mos.Assembler.Compiler.passes[1] or {}
local Pass = Mos.Assembler.Compiler.passes[1]

Pass.__index = Pass
setmetatable( Pass, Mos.Assembler.Ast )

--[[
    @name FirstPass.Perform()
    @desc Passes over the ast and stores all labels

    @param AST ast: The ast to pass over

    @return Table: The labels discovered
]]
function Pass.Perform( ast )
    local pass = setmetatable( {}, Pass )

    pass.address = 0
    pass.labels = {}
    pass.isFirstPass = true

    pass:visit( ast )

    return pass.labels
end

--[[
    Visitor methods for the pass.
    They are called automatically with the Pass:visit() method
]]

function Pass:visitProgram( statements )
    for _, statement in ipairs( statements ) do
        self:visit( statement )
    end
end

function Pass:visitLabel( label )
    if self.labels[label.value] then
        error( "Label '" .. label.value .. "' already exists at line " .. self.labels[label.value].line )
    end

    self.labels[label.value] = {
        line = label.line,
        address = self.address
    }
end

function Pass:visitInstruction( instruction )
    local name = string.lower( instruction.instruction.value )
    local data = instructions.bytecodes[name]

    if not data then
        error( "Invalid instruction " .. name .. " at line " .. instruction.line )
    end

    local mode = instruction.operand.value.type
    local id = instructions.modeLookup[mode]

    if not data[id] then
        error( "Invalid addressing mode for " .. name .. ", '" .. mode .. "' not supported" )
    end

    self.address = self.address + instructions.modeByteSize[mode] + 1
end

function Pass:visitDirective( directive )
    directives[directive.directive.value]( self, directive.arguments )
end
