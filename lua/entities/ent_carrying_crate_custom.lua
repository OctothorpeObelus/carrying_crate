AddCSLuaFile() --Uncomment this, this is just so a template entity doesn't show up in the spawnmenu

ENT.Type        = "anim"
ENT.PrintName   = "Customizable Crate" --Human readable name of the object (Undo, Spawnmenu, etc.)
ENT.Author      = "Octo"

ENT.Category = "Carrying Crates" --Don't change this
ENT.Spawnable       = true
ENT.AdminSpawnable  = false
ENT.Editable = true

--Crate attributes
ENT.Model = "models/carriers/cratecontroller.mdl"
ENT.Physmat = "wood"    --Optional parameter
ENT.AccumulateMass = true --Optional parameter (defaults to false). Makes the physical weight of the box equal to itself plus the combined weight of the contents inside it.

-- Whitelist of entity classes that can be put in the box.
ENT.Whitelist = {
    "prop_physics"
}

--Box to search for entities in relative to the coordinate center of the chosen model (Use Precision Alignment to obtain the desired size without trial and error)
ENT.Box = {
    min = Vector(-1,-1,-1),
    max = Vector(1,1,1)
}

ENT.TippingPoint = { --Optional paramter. Defines the Angles at which any cargo inside will be dropped. If not defined the crate will never automatically drop its contents.
    min = Angle(-90,-90,-90),   --Minimum angle to dump contents
    max = Angle(90,90,90)       --Maximum angle to dump contents
}

ENT.Sounds = {                  --Optional parameter
    on = "buttons/button6.wav", --Played when the crate holds onto something
    off = "buttons/button4.wav", --Played when the crate lets go of something
    tipsound = "" --This does not have to be defined and will only be used if ENT.TippingPoint is defined and is triggered.
}

function ENT:SetupDataTables()
    /* if SERVER then
        local sizelimit = GetConVar("carrying_crate_custom_size_limit"):GetInt()
        
    end */
    local sizelimit = 512

    self:NetworkVar("Int", 12, "InitialMass", {KeyName = "initialmas", Edit = {type = "Int", order = 1, title = "Dry Mass", min = 1, max = 50000}})
    self:NetworkVar("Bool", 0, "AccumulateMass", {KeyName = "accumulatemass", Edit = {type = "Boolean", order = 2, title = "Accumulate Mass?"}})
    self:NetworkVar("Int", 0, "BoxMinX", {KeyName = "boxminx", Edit = {type = "Int", order = 3, title = "X", category = "Box Corner 1", min = -sizelimit, max = -1}})
    self:NetworkVar("Int", 1, "BoxMinY", {KeyName = "boxminy", Edit = {type = "Int", order = 4, title = "Y", category = "Box Corner 1", min = -sizelimit, max = -1}})
    self:NetworkVar("Int", 2, "BoxMinZ", {KeyName = "boxminz", Edit = {type = "Int", order = 5, title = "Z", category = "Box Corner 1", min = -sizelimit, max = -1}})
    self:NetworkVar("Int", 3, "BoxMaxX", {KeyName = "boxmaxx", Edit = {type = "Int", order = 6, title = "X", category = "Box Corner 2", min = 1, max = sizelimit}})
    self:NetworkVar("Int", 4, "BoxMaxY", {KeyName = "boxmaxy", Edit = {type = "Int", order = 7, title = "Y", category = "Box Corner 2", min = 1, max = sizelimit}})
    self:NetworkVar("Int", 5, "BoxMaxZ", {KeyName = "boxmaxz", Edit = {type = "Int", order = 8, title = "Z", category = "Box Corner 2", min = 1, max = sizelimit}})
    self:NetworkVar("Bool", 1, "TipEnable", {KeyName = "tipenable", Edit = {type = "Boolean", order = 9, title = "Enable Crate Tipping?", category = "Tipping"}})
    self:NetworkVar("Int", 6, "TipMinX", {KeyName = "tipminx", Edit = {type = "Int", order = 10, title = "X", category = "Minimum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("Int", 7, "TipMinY", {KeyName = "tipminy", Edit = {type = "Int", order = 11, title = "Y", category = "Minimum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("Int", 8, "TipMinZ", {KeyName = "tipminz", Edit = {type = "Int", order = 12, title = "Z", category = "Minimum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("Int", 9, "TipMaxX", {KeyName = "tipmaxx", Edit = {type = "Int", order = 13, title = "X", category = "Maximum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("Int", 10, "TipMaxY", {KeyName = "tipmaxy", Edit = {type = "Int", order = 14, title = "Y", category = "Maximum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("Int", 11, "TipMaxZ", {KeyName = "tipmaxz", Edit = {type = "Int", order = 15, title = "Z", category = "Maximum Tipping Angle", min = -180, max = 180}})
    self:NetworkVar("String", 1, "OnSound", {KeyName = "onsound", Edit = {type = "Generic", order = 16, title = "On", category = "Sounds"}})
    self:NetworkVar("String", 2, "OffSound", {KeyName = "offsound", Edit = {type = "Generic", order = 17, title = "Off", category = "Sounds"}})
    self:NetworkVar("String", 3, "TipSound", {KeyName = "tipsound", Edit = {type = "Generic", order = 18, title = "Tipped", category = "Sounds"}})
    
    if SERVER then
        self:SetInitialMass(50)
        self:SetAccumulateMass(true)
        self:SetBoxMinX(-64)
        self:SetBoxMinY(-64)
        self:SetBoxMinZ(-64)
        self:SetBoxMaxX(64)
        self:SetBoxMaxY(64)
        self:SetBoxMaxZ(64)
        self:SetTipMinX(-90)
        self:SetTipMinY(-180)
        self:SetTipMinZ(-90)
        self:SetTipMaxX(90)
        self:SetTipMaxY(180)
        self:SetTipMaxZ(90)
    end
end

--Standard block of code below. Copy this into every crate entity. Function sources can be found in lua/autorun/server and lua/autorun/client (for the hints)
if SERVER then
    function ENT:Initialize()
        carrying_crate.init(self)
        --carrying_crate.registerCustom(self)
    end

    function ENT:Use(activator, caller, useType, value)
        if activator:KeyPressed(IN_USE) then
            self.lastuser = activator
            carrying_crate.used(self)
        end
    end

    function ENT:Think()
        if self:GetTipEnable() then
            self.TippingPoint = {
                min = Angle(self:GetTipMinX(), self:GetTipMinY(), self:GetTipMinZ()),
                max = Angle(self:GetTipMaxX(), self:GetTipMaxY(), self:GetTipMaxZ())
            }
        else
            self.TippingPoint = nil
        end
        self.AccumulateMass = self:GetAccumulateMass()

        self.Sounds = {
            on = self:GetOnSound(),
            off = self:GetOffSound(),
            tip = self:GetTipSound()
        }

        self.Box = {
            min = Vector(self:GetBoxMinX(),self:GetBoxMinY(),self:GetBoxMinZ()),
            max = Vector(self:GetBoxMaxX(),self:GetBoxMaxY(),self:GetBoxMaxZ())
        }

        self.Mass = self:GetInitialMass()

        carrying_crate.think(self)
    end

    function ENT:OnRemove()
        --carrying_crate.removeCustom(self)
        carrying_crate.onremove(self)
    end

    /* net.Receive("octoCarryingCrateCustomEntRequest", function()
        local ply = net.ReadEntity()

        net.Start("octoCarryingCrateCustomEntResponse")
        net.WriteEntity(self or nil)
        net.WriteInt(self:GetCreationID() or -1, 64)
        net.Send(ply)
    end)  */
else --Clientside
    local cmenu = false
    local ent = nil
    local cid = 0 -- CreationID
    local pos = Vector(0,0,0)
    local ang = Angle(0,0,0)
    local min = Vector(0,0,0)
    local max = Vector(0,0,0)
    
    function ENT:Draw()
        self:DrawModel()
    end

    /* function ENT:Think()
        if ent == nil then
            net.Start("octoCarryingCrateCustomEntRequest")
            net.WriteEntity(LocalPlayer())
            net.SendToServer() 
        end
    end

    net.Receive("octoCarryingCrateCustomEntResponse", function()
        ent = net.ReadEntity()
        cid = net.ReadInt(64)

        local cmenuHookName = "octoCarryingCrateOnContextMenuOpen"..tostring(cid)
        local predrawHookName = "octoCarryingCratePreDrawOpaqueRenderables"..tostring(cid)
        hook.Add("OnContextMenuOpen", cmenuHookName, function()
            hook.Add("PreDrawOpaqueRenderables", predrawHookName, function(isDrawingDepth, isDrawSkybox, isDraw3DSkybox)
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
            hook.Remove("PreDrawOpaqueRenderables", predrawHookName)
        end)
    end)

    function ENT:OnRemove()
        print("Boob")
    end */
end