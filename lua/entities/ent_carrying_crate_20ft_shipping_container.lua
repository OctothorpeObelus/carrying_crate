AddCSLuaFile()

ENT.Type        = "anim"
ENT.PrintName   = "20ft Shipping Container" --Human readable name of the object (Undo, Spawnmenu, etc.)
ENT.Author      = "Geemar"

ENT.Category = "Carrying Crates" --Don't change this
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = "models/carriers/shippingcontainer20.mdl"
ENT.Physmat = "metal"    --Optional parameter
ENT.Mass = 2000       --Optional parameter
ENT.ValidateContents = true --Checks if the CoM of the entity is within the box. Defaults to true.
ENT.AccumulateMass = true --Optional parameter (defaults to false). Makes the physical weight of the box equal to itself plus the combined weight of the contents inside it.

--Box to search for entities in relative to the coordinate center of the chosen model (Use Precision Alignment to obtain the desired size without trial and error)
ENT.Box = {
    min = Vector(-119.792,-42.142,43.943),
    max = Vector(119.792,42.138,-43.921)
}

ENT.Sounds = {                  --Optional parameter
    on = "carrying_crates/cargo_common_pack.wav", --Played when the crate holds onto something
    off = "carrying_crates/cargo_common_unpack.wav", --Played when the crate lets go of something
    tipsound = "" --This does not have to be defined and will only be used if ENT.TippingPoint is defined and is triggered.
}

--Standard block of code below. Copy this into every crate entity. Function sources can be found in lua/autorun/server and lua/autorun/client (for the hints)
if SERVER then

    
    function ENT:Initialize()
        carrying_crate.init(self)
    end

    function ENT:Use(activator, caller, useType, value)
        if activator:KeyPressed(IN_USE) then
            self.lastuser = activator
            carrying_crate.used(self)
            if self.hasLoad then
                self:SetBodygroup(1,1)
            else
                self:SetBodygroup(1,0)
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