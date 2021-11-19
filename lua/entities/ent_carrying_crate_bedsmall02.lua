AddCSLuaFile()

ENT.Type        = "anim"
ENT.PrintName   = "Tiny Truck Bed"
ENT.Author      = "Octo"

ENT.Category = "Carrying Crates"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = "models/carriers/bedsmall02.mdl"
ENT.AccumulateMass = true

-- Whitelist of entity classes that can be put in the box.
ENT.Whitelist = {
    "prop_physics",
    "prop_vehicle_prisoner_pod"
}
ENT.Box = {
    max = Vector(30.03, -33, 34.405),
    min = Vector(-32.722, 32.979, -0.438)
}

ENT.TippingPoint = {
    min = Angle(-40,-360,-95),
    max = Angle(95,360,95)
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