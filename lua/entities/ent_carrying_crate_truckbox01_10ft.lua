AddCSLuaFile()

ENT.Type        = "anim"
ENT.PrintName   = "10ft Truck Box"
ENT.Author      = "Geemar"

ENT.Category = "Carrying Crates"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = "models/carriers/truckbox_10ft.mdl"
ENT.AccumulateMass = true

-- Whitelist of entity classes that can be put in the box.
ENT.Whitelist = {
    "prop_physics",
    "prop_vehicle_prisoner_pod"
}
ENT.Box = {
    max = Vector(-57, 34, 1.4),
    min = Vector(57, -34, 70)
}

ENT.Sounds = {          --Optional parameter
    on = "carrying_crates/cargo_common_pack.wav",
    off = "carrying_crates/cargo_common_unpack.wav",
    tipsound = "carrying_crates/cargo_common_unpack.wav"
}

if SERVER then
    function ENT:Initialize()
        carrying_crate.init(self)
    end

    function ENT:Use(activator, caller, useType, value)
        if activator:KeyPressed(IN_USE) then
            self.lastuser = activator
            carrying_crate.used(self)
            if self.hasLoad then
                self:SetBodygroup(1,0)
            else
                self:SetBodygroup(1,1)
            end
        end
    end

    function ENT:Think()
        carrying_crate.think(self)
    end
    
    function ENT:OnRemove()
        carrying_crate.onremove(self)
    end
else --Clientside
    function ENT:Draw()
        self:DrawModel()
    end
end