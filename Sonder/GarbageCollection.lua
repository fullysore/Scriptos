local Utility = { Storage = {} }

-->

function Utility:Set(Identifier: string, Function: any): nil
    Utility.Storage[Identifier] = Function
end

function Utility:Get(Identifier: string): any
    if not (Utility.Storage[Identifier]) then
        return function() warn(Identifier, "Is Not A Valid Function!") end
    end

    return Utility.Storage[Identifier]
end

function Utility:GetFunctionWithHash(Hash: string): any
    for i,v in getgc() do
        if (typeof(v) == "function" and islclosure(v) and getfunctionhash(v) == Hash) then
            return v
        end
    end

    return function() warn(Hash, "Is Not A Valid Function Hash!") end
end

function Utility:GetFunctionWithName(Name: any): any
    for i,v in getgc() do
        if (typeof(v) == "function" and debug.info(v,"n") == Name) then
            return v
        end
    end

    return function() warn(Name, "Is Not A Valid Function Name!") end
end

function Utility:GetSimularFunctionWithName(Name: any): any
    for i,v in getgc() do
        if (typeof(v) == "function" and debug.info(v,"n"):lower() == Name:lower()) then
            return v
        end
    end

    return function() warn(Name, "Is Not A Valid Function Name!") end
end

function Utility:GetFunctionWithNameAndSource(Name: string, Source: string): any
    for i,v in getgc() do
        if (typeof(v) == "function" and debug.info(v,"n") == Name and debug.info(v,"s"):find(Source)) then
            return v
        end
    end

    return function() warn(Name, "Is Not A Valid Function Name!") end
end

function Utility:GetTablesWithContent(Content: string): SharedTable | string
    local Tables = {}

    for i,v in getgc(true) do
        if (typeof(v) == "table" and (rawget(v, Content) or rawget(v, Content:lower()))) then
            table.insert(Tables, v)
        end
    end

    return (#Tables > 0 and Tables or 'No Valid Table Found.')
end

function Utility:GetFunctionHash(Function: any): string
    local Hash = pcall(getfunctionhash, Function)
    return Hash or 'Invalid Function.'
end

function Utility:SetHeap(Names: SharedTable): any
    for i,v in Names do
        local Function
        if (typeof(v) == "table") then
            if (v.Name and v.Source) then
                Function = Utility:GetFunctionWithNameAndSource(v.Name, v.Source)
            elseif (v.Name) then
                Function = Utility:GetFunctionWithName(v.Name)
            elseif (v.Source) then
                return warn("Only Source Will Not Return A Valid Function.")
            end
        else
            Function = Utility:GetFunctionWithName(v)
        end

        Utility:Set(i, Function)
    end
end

-->

return Utility
