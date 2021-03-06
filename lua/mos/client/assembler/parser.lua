--[[
    @class Parser
    @desc Generates an AST from a stream of tokens
]]
Mos.Assembler.Parser = Mos.Assembler.Parser or {}
local Parser = Mos.Assembler.Parser

include( "mos/client/assembler/lexer.lua" )
include( "mos/client/assembler/ast/ast.lua" )

local Ast = Mos.Assembler.Ast
local instructions = Mos.Assembler.Instructions

-- Formated error message, takes a string and extra arguments like string.format and generates an error from it.
local function errorf( str, ... )
    error( string.format( str, ... ), 2 )
end

--------------------------------------------------
-- Parser API

Parser.__index = Parser

--[[
    @name Parser.Create()
    @desc Creates a new parser object

    @param string code: The code to generate an AST for

    @return Parser: The newly created object
]]
function Parser.Create( code )
    local parser = {}
    parser.lexer = Mos.Assembler.Lexer.Create( code )
    parser.allowedDirectives = {
        ["define"] = true,
        ["ifdef"] = true,
        ["ifndef"] = true,
        ["org"] = true,
        ["db"] = true,
        ["dw"] = true
    }

    return setmetatable( parser, Parser )
end

--------------------------------------------------
-- Parser metamethods

--[[
    @name Parser:eat( type )
    @desc Pops a token from the stream and returns it. Throws an error if the type isn't the one we expect

    @param string type: The type of token expected
]]
function Parser:eat( type )
    local token = self.token
    if token.type ~= type then
        -- TODO: Properly throw errors
        error( string.format( "Expected %s got %s at line %d, char %d", type, token.type, token.line, token.char ), 2 )
    end

    self.token = self.lexer:getNextToken()

    return token
end

--------------------------------------------------
-- Parsing

--[[
    @name Parser:parse()
    @desc Starts generating the AST

    @return AST: The generated AST
]]
function Parser:parse()
    self.token = self.lexer:getNextToken()

    local program = Ast.Node.Create( "Program" )
    self:program( program )
    self:eat( "Eof" )

    return program
end

function Parser:program( node )
    local statements = node:list()

    while self.token.type ~= "Eof" do
        self:statement( statements )
    end
end

function Parser:statement( node )
    local type = self.token.type

    if type == "Newline" then
        self:eat( "Newline" )
    elseif type == "Hash" or type == "Dot" then
        return self:directive( node )
    else
        return self:identifier( node )
    end
end

function Parser:directive( node )
    local reference = self:eat( self.token.type )
    local directive = node:table( "Directive", reference )

    local name = self:eat( "Identifier" )
    directive.Name = directive:leaf( name )
    self:arguments( directive )
    self:eat( "Newline" )

    if not self.allowedDirectives[name.value] then
        errorf( "Unexpected directive %s at line %d, character %d", name.value, name.line, name.char )
    end

    directive.Value = directive:list( "Statements" )
    if self[name.value] then self[name.value]( self, directive ) end

    return name.value
end

function Parser:identifier( node )
    local id = self:eat( "Identifier" )

    if self.token.type == "Colon" then
        self:eat( "Colon" )
        self:eat( "Newline" )

        local label = node:node( "Label" )
        label:leaf( id )

        return
    end

    local instruction = node:table( "Instruction", id )
    instruction.Name = instruction:leaf( id )

    self:instruction( instruction, string.lower( id.value ) )
end

function Parser:instruction( node, name )
    local addressingModes = instructions.bytecodes[name]
    if not addressingModes then
        errorf( "Invalid instruction name '%s' at line %d, char %d", name, node._line, node._char )
    end

    self:operand( node, name )
    self:eat( "Newline" )
end

local addressingMode = {
    LSqrBracket = "indirect",
    Hash = "immediate",
    Newline = "implied"
}

function Parser:operand( node, name )
    node.Operand = node:table( "Operand", self.token )
    node.Operand.Value = node:node( "Expression" )

    local mode = addressingMode[self.token.type] or "maybeAbsolute"
    self[mode]( self, node.Operand, name )
end

function Parser:indirect( node )
    local mode = self:eat( "LSqrBracket" )
    mode.value = "Indirect"

    self:expression( node.Value )

    if self.token.type == "Comma" then
        local register = self:registerIndex()

        if register == "y" then
            errorf( "Invalid index register. 'x' expected, got 'y'" )
        end

        mode.value = "Indirect,X"
    end

    self:eat( "RSqrBracket" )

    if self.token.type == "Comma" then
        if mode.value ~= "Indirect" then
            errorf( "Cannot index two registers at once" )
        end

        local register = self:registerIndex()

        if register == "x" then
            errorf( "Invalid index register. 'y' expected, got 'x'" )
        end

        mode.value = "Indirect,Y"
    end

    node.Mode = node:leaf( mode )
end

function Parser:immediate( node )
    local mode = self:eat( "Hash" )
    mode.value = "Immediate"
    node.Mode = node:leaf( mode )

    self:expression( node.Value )
end

function Parser:implied( node )
    --! Don't eat the newline. All instructions are expected to end with one and :instruction() will take care of it
    local mode = self.token
    mode.Value = "Implied"
    node.Mode = node:leaf( mode )
end

local isBranchInstruction = {
    bcc = true,
    bcs = true,
    beq = true,
    bmi = true,
    bne = true,
    bpl = true,
    bvc = true,
    bvs = true
}

function Parser:maybeAbsolute( node, name )
    if self.token.type == "Identifier" and self.token.value == "a" then
        return self:accumulator( node )
    end

    local mode = self.token

    self:expression( node.Value )

    if isBranchInstruction[name] then
        mode.value = "Relative"
        node.Mode = node:leaf( mode )
        return
    end

    mode.value = "Absolute"

    if self.token.type == "Comma" then
        local register = string.upper( self:registerIndex() )
        mode.value = "Absolute," .. register
    end

    node.Mode = node:leaf( mode )
end

function Parser:accumulator( node )
    local mode = self:eat( "Identifier" )
    mode.value = "Accumulator"
    node.Mode = node:leaf( mode )
end

function Parser:registerIndex()
    self:eat( "Comma" )
    local register = self:eat( "Identifier" )
    local name = string.lower( register.value )

    if name ~= "x" and name ~= "y" then
        errorf( "Invalid register '%s' at line %d, char %d", register.value, register.line, register.char )
    end

    return register.value
end

local validTermOperation = {
    ["+"] = true,
    ["-"] = true,
}

function Parser:expression( node )
    local left = self:term( node )
    if not validTermOperation[self.token.value] then
        return node:attach( left )
    end

    local operator = self:eat( "Operator" )

    local operation = node:table( "Operation", operator )
    operation.Left = left
    operation.Operator = operation:leaf( operator )
    operation.Right = self:term( node )
end

local validFactorOperation = {
    ["*"] = true,
    ["/"] = true
}

function Parser:term( node )
    local left = self:factor( node )
    if not validFactorOperation[self.token.value] then
        return left
    end

    local operator = self:eat( "Operator" )

    local operation = Ast.Table.Create( "Operation", operator )
    operation.Left = left
    operation.Operator = operation:leaf( operator )
    operation.Right = self:factor( node )
end

local validFactor = {
    ["Identifier"] = true,
    ["Number"] = true,
    ["String"] = true
}

function Parser:factor( node )
    if self.token.type == "LParen" then
        self:eat( "LParen" )
        self:expression( node )
        self:eat( "RParen" )

        return
    end

    if not validFactor[self.token.type] then return end

    node:leaf( self:eat( self.token.type ) )
end

function Parser:arguments( node )
    local arguments = node:list()
    node.Arguments = arguments

    self:argument( arguments )

    while self.token.type == "Comma" or self.token.type ~= "Newline" do
        self:eat( "Comma" )
        self:argument( arguments )
    end
end

function Parser:argument( node )
    local arg = node:node( "Argument" )
    self:expression( arg )
end

--------------------------------------------------
-- Directives

function Parser:ifdef( node )
    node.Default = node.Value
    node.Value = nil
    node.Fallback = node:list( "Statements" )

    local statements = node.Default
    local accepts = {["else"] = true, ["endif"] = true}

    local previous = self.allowedDirectives["else"]

    self.allowedDirectives["else"] = true
    self.allowedDirectives["endif"] = true

    while true do
        local directive = self:statement( statements )

        if directive then
            local value = string.sub( directive, 1 )

            if accepts[value] and value == "else" then
                statements = node.Fallback
                accepts[value] = false
                statement = nil
            elseif accepts[value] then
                break
            end
        end

        if statement then table.insert( statements, statement ) end
    end

    self.allowedDirectives["else"] = previous
    self.allowedDirectives["endif"] = previous

    return result
end

Parser.ifndef = Parser.ifdef
