local enums = {}

for _, enum in script:GetChildren() do
    if enum:IsA("ModuleScript") then
        enums[enum.Name] = require(enum)
        enums[enum.Name].__classname = enum.Name
    end

    
end

return enums
