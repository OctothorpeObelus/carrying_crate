AddCSLuaFile()

ENT.Type        = "anim"
ENT.PrintName   = "Laundry Cart 1"
ENT.Author      = "Octo"

ENT.Category = "Carrying Crates"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = "models/props_wasteland/laundry_cart002.mdl"
ENT.Physmat = "metal"   --Optional parameter
ENT.Mass = 50           --Optional parameter
ENT.AccumulateMass = true

-- Whitelist of entity classes that can be put in the box.
ENT.Whitelist = {
    "prop_physics"
}
ENT.Box = {
    max = Vector(26.218, 14.676, 21.949),
    min = Vector(-20.756, -14.615, -14.162)
}

ENT.TippingPoint = {
    min = Angle(-95,-360,-95),
    max = Angle(95,360,95)
}

ENT.Sounds = {          --Optional parameter
    on = "buttons/button6.wav",
    off = "buttons/button4.wav"
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