--[[
    @class Preprocessor
    @desc Generates the ast and processes it before the compilation
]]
Mos.Assembler.Preprocessor = Mos.Assembler.Preprocessor or {}
local Preprocessor = Mos.Assembler.Preprocessor

include( "mos/client/assembler/preprocessor/directives.lua" )

setmetatable( Preprocessor, Mos.Assembler.Ast )

--------------------------------------------------
-- Preprocessor API

Preprocessor.__index = Preprocessor

--[[
    @name Preprocessor.Create()
    @desc Creates a new preprocessor object and initializes its default values

    @return Table: The newly created preprocessor
]]
function Preprocessor.Create()
    local preprocessor = {}

    preprocessor.definitions = {
        ["SERVER"] = {type = "Bool", value = SERVER},
        ["CLIENT"] = {type = "Bool", value = CLIENT},
        ["VECTOR_IRQ"] = {type = "Definition", value = {type = "Number", value = "0xfffe"}},
        ["VECTOR_NMI"] = {type = "Definition", value = {type = "Number", value = "0xfffa"}},
        ["VECTOR_RESET"] = {type = "NuDefinitioner", value = {type = "Number", value = "0xfffc"}}
    }

    return setmetatable( preprocessor, Preprocessor )
end

--[[
    @name Preprocessor:process()
    @desc Fetches and processes the ast of the the main source file

    @return Table: The processed ast
]]
function Preprocessor:process()
    self.ast = self.assembly:parseFile( self.assembly.main )
    self:visit( self.ast )

    return self.ast
end

--[[
    Visitor methods for the pass.
    They are called automatically with the Pass:visit() method
]]

function Preprocessor:visitProgram( statements )
    self:visit( statements )
end

function Preprocessor:visitInstructionName( name )
    self:visit( name )
end

function Preprocessor:visitInstructionOperand( operand )
    self:visit( operand )
end

function Preprocessor:visitOperandMode( mode )
    self:visit( mode )
end

function Preprocessor:visitOperandValue( value )
    self:visit( value )
end

function Preprocessor:visitExpression( expr )
    self:visit( expr )
end

function Preprocessor:visitIdentifier( id )
    return id
end

function Preprocessor:visitNumber( number )
    return tonumber( number )
end

--[[
function Preprocessor:visitProgram( statements )
    local i = 1

    while statements[i] do
        local result = {self:visit( statements[i] )}
        callback = table.remove( result, 1 )

        if callback then
            i = callback( statements, i, unpack( result ) ) or ( i + 1 )
        else
            i = i + 1
        end
    end
end

function Preprocessor:visitLabel() end

function Preprocessor:visitInstruction( data )
    self:visit( data.operand )
end

function Preprocessor:visitAddressingMode( mode )
    if not mode.value then return end

    local result = self:visit( mode.value )

    --? Allows for replacing nodes with others
    mode.value = result or mode.value
end

function Preprocessor:visitDirective( data )
    return self.directives[data.directive.value]( self, data.arguments, data.value )
end

function Preprocessor:visitOperation( data )
    self:visit( data.left )
    self:visit( data.right )
end

function Preprocessor:visitIdentifier( value )
    if not self.definitions[value] then return end
    if self.definitions[value].type == "Bool" then return end

    return self.definitions[value].value
end

function Preprocessor:visitNumber( number, node )
    local format = number[2]
    local result = 0

    if format == "h" or format == "x" then
        result = tonumber( "0x" .. string.sub( number, 3 ) )
    elseif format == "b" then
        number = string.sub( number, 3 )
        local size = string.len( number )

        for i = 0, size - 1 do
            local b = tonumber( number[size - i] )

            if b > 1 then
                -- TODO: Properly throw errors
                error( "Invalid binary format 0b" .. number )
            end

            result = result + ( 2 ^ i ) * b
        end
    elseif format == "d" then
        result = tonumber( string.sub( number, 3 ) )
    else
        result = tonumber( number )
    end

    node.value = result
end

function Preprocessor:visitString( str, node )
    node.value = string.gsub( string.sub( str, 2, -2 ), "\\([nt])", {n = "\n", t = "\t"} )
end
--]]
