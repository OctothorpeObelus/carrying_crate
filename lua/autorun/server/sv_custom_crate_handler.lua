--TODO: Move clientside rendering hook here.
/* 
local ent = nil

net.Start("octoCarryingCrateCustomEntRequest")
net.WriteEntity(LocalPlayer())
net.SendToServer()

net.Receive("octoCarryingCrateCustomEntResponse", function()
    ent = net.ReadEntity()
end)

hook.Add("OnContextMenuOpen", "octoCarryingCrateOnContextMenuOpen", function()
    hook.Add("PreDrawOpaqueRenderables", "octoCarryingCratePreDrawOpaqueRenderables", function(isDrawingDepth, isDrawSkybox, isDraw3DSkybox)
        if IsValid(ent) then
            render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), Vector(ent:GetBoxMinX(), ent:GetBoxMinY(), ent:GetBoxMinZ()), Vector(ent:GetBoxMaxX(), ent:GetBoxMaxY(), ent:GetBoxMaxZ()), Color( 245, 224, 66 ), true)
        else
            net.Start("octoCarryingCrateCustomEntRequest")
            net.WriteEntity(LocalPlayer())
            net.SendToServer()
        end
    end)
end)

hook.Add("OnContextMenuClose", "octoCarryingCrateOnContextMenuClose", function()
    hook.Remove("PreDrawOpaqueRenderables", "octoCarryingCratePreDrawOpaqueRenderables")
end)
*/

