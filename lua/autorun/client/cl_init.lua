AddCSLuaFile()

local giveHint = true
local crates = crates or {}

net.Receive("octoCarryingCrateGiveHint", function()
    if giveHint then
        giveHint = false
        notification.AddLegacy("[Carrying Crate] Press "..string.upper(input.LookupBinding("+use", true)).." on the crate to secure and release its contents", NOTIFY_HINT, 7)
    end
end)

net.Receive("octoCarryingCrateEmergencyExit", function()
    local count = net.ReadInt(16)
    local max = net.ReadInt(16)
    notification.AddLegacy("[Carrying Crate] Too many constrained entities to connect! ("..count.." > "..max..")", NOTIFY_ERROR, 7)
end)

--Fetch the response contianing all custom crates.
net.Receive("octoCarryingCrateCustomResponse", function ()
    local count = net.ReadInt(64)

    for i=1, count do
        local ent = net.ReadEntity()
        table.insert(crates, ent)
        --print(ent)
    end
end)

--[[hook.Add("OnContextMenuOpen", "octoCarryingCrateOnContextMenuOpen", function()
    --if table.Count(crates) == 0 then
        net.Start("octoCarryingCrateCustomRequest")
        net.SendToServer()
    --end

    hook.Add("PreDrawOpaqueRenderables", "octoCarryingCratePreDrawOpaqueRenderables", function(isDrawingDepth, isDrawSkybox, isDraw3DSkybox)
        for i in pairs(crates) do
            local ent = crates[i]
            --print(ent, i)

            if IsValid(ent) then
                render.DrawWireframeBox(
                    ent:GetPos(), 
                    ent:GetAngles(), 
                    Vector(ent:GetBoxMinX(), ent:GetBoxMinY(), ent:GetBoxMinZ()), 
                    Vector(ent:GetBoxMaxX(), ent:GetBoxMaxY(), ent:GetBoxMaxZ()), 
                    Color( 245, 224, 66 ), 
                    true
                )
            end
        end
    end)
end)]]--

--[[hook.Add("OnContextMenuClose", "octoCarryingCrateOnContextMenuClose", function()
    hook.Remove("PreDrawOpaqueRenderables", "octoCarryingCratePreDrawOpaqueRenderables")
end)]]--