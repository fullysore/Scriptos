local Base64Decode = crypt and crypt.base64decode or base64decode or function() end

local Utility = {}

-->

if not (isfolder("Images")) then
    makefolder("Images")
end

-->

function Utility:New(Images)
    for i,v in Images do
        Utility:CreateImage(i,v)
    end
end

function Utility:Resolve(Image: any)
    return Base64Decode(Image)
end

function Utility:CreateImage(Name: string, Base64: string)
    return writefile("Images/" .. Name .. ".png", Utility:Resolve(Base64))
end

function Utility:LoadImage(Name)
    repeat task.wait() until isfile("Images/" .. Name .. ".png")

    return getcustomasset("Images/" .. Name .. ".png")
end

-->

return Utility
