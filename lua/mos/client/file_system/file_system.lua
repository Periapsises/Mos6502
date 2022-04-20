Mos.FileSystem = Mos.FileSystem or {}
local FileSystem = Mos.FileSystem

-- Taken from https://wiki.facepunch.com/gmod/file.Write
FileSystem.allowedExtensions = {".txt", ".dat", ".json", ".xml", ".csv", ".jpg", ".jpeg", ".png", ".vtf", ".vmt", ".mp3", ".wav", ".ogg"}

FileSystem.associations = {
    files = {
        asm = "icon16/page_code.png"
    },
    folders = {
        lib = "icon16/folder_brick.png",
        libs = "icon16/folder_brick.png"
    }
}

--[[
    @name FileSystem:Verify()
    @desc Ensures all default folders and files exist
]]
function FileSystem:Verify()
    file.CreateDir( "mos6502/" )
    file.CreateDir( "mos6502/asm/" )
    file.CreateDir( "mos6502/bin/" )

    if not self:Exists( "mos6502/asm/default.asm" ) then
        self:Write( "mos6502/asm/default.asm", "/*\n    Mos6502 Assembly Editor\n*/\n" )
    end
end

--[[
    @name FileSystem:HasAllowedExtension( path )
    @desc Checks if a filepath ends with a valid extension

    @param string path - The filepath to check

    @return bool - Whether the extension is valid or not
]]
function FileSystem:HasAllowedExtension( path )
    for _, extension in ipairs( self.allowedExtensions ) do
        if string.EndsWith( path, extension ) then return true end
    end
end

--[[
    @name FileSystem:GetSanitizedPath( path )
    @desc Returns a path with a valid extension

    @param string path - The path to sanitize

    @return string - The sanitized path
]]
function FileSystem:GetSanitizedPath( path )
    if self:HasAllowedExtension( path ) then return path end

    return path .. "~.txt"
end

--[[
    @name FileSystem:GetDirtyPath( path )
    @desc Gets rid of extra extensions required for validity

    @param string path - The path to make dirty

    @return string - The dirty path
]]
function FileSystem:GetDirtyPath( path )
    return string.match( path, "^([^~]+)" )
end

--[[
    @name FileSystem:GetCompiledPath( path )
    @desc Returns the path a file would be compiled to

    @param string path - The path to convert
]]
function FileSystem:GetCompiledPath( path )
    path = self:GetDirtyPath( path )

    return string.gsub( path, "mos6502/asm/(.+)%.%a+", "mos6502/bin/%1.bin" )
end

--[[
    @name FileSystem:Write( path, data )
    @desc Checks if a file exists in the DATA folder just like file.Exists() would but ensures the path is sanitized

    @param string path - The path to the file
]]
function FileSystem:Exists( path )
    path = self:GetSanitizedPath( path )

    return file.Exists( path, "DATA" )
end

--[[
    @name FileSystem:Open( path, mode )
    @desc Opens and returns a file

    @param string path - The path to the file
    @param string mode - The mode in which to open the file
]]
function FileSystem:Open( path, mode )
    path = self:GetSanitizedPath( path )

    return file.Open( path, mode, "DATA" )
end

--[[
    @name FileSystem:Write( path, data )
    @desc Writes a file in the DATA folder just like file.Write() would but ensures the path is sanitized

    @param string path - The path to write the file to
    @param string data - The data to write in the file
]]
function FileSystem:Write( path, data )
    path = self:GetSanitizedPath( path )

    file.Write( path, data )
end

--[[
    @name FileSystem:Read( path )
    @desc Reads a file in the DATA folder just like file.Read() would but ensures the path is sanitized

    @param string path - The path to read the file from
]]
function FileSystem:Read( path )
    path = self:GetSanitizedPath( path )

    local f = file.Open( path, "rb", "DATA" )
    local data = f:Read( f:Size() )
    f:Close()

    return data
end

FileSystem:Verify()