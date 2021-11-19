AddCSLuaFile()

ENT.Type        = "anim"
ENT.PrintName   = "Plastic Crate" --Human readable name of the object (Undo, Spawnmenu, etc.)
ENT.Author      = "Octo"

ENT.Category = "Carrying Crates" --Don't change this
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = "models/props_junk/PlasticCrate01a.mdl"
ENT.Physmat = "plastic"    --Optional parameter
ENT.Mass = 10       --Optional parameter
ENT.ValidateContents = true --Checks if the CoM of the entity is within the box. Defaults to false.
ENT.AccumulateMass = false --Optional parameter (defaults to false). Makes the physical weight of the box equal to itself plus the combined weight of the contents inside it.

ENT.Box = {
    min = Vector(-8.054, -11.882, -6.399),
    max = Vector(8.6, 12.412, 7.404)
}

ENT.TippingPoint = {
    min = Angle(-95,-360,-95),
    max = Angle(95,360,95)
}

ENT.Sounds = {                  --Optional parameter
    on = "buttons/button6.wav", --Played when the crate holds onto something
    off = "buttons/button4.wav" --Played when the crate lets go of something
}

--Standard block of code below. Copy this into every crate entity. Function sources can be found in lua/autorun/server and lua/autorun/client (for the hints)
if SERVER then
    function ENT:Initialize()
        carrying_crate.init(self)
        self:SetSkin(math.random(1,5))
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