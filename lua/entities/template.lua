--AddCSLuaFile() --Uncomment this line, this is just so a template entity doesn't show up in the spawnmenu

ENT.Type        = "anim"
ENT.PrintName   = "Template Crate" --Human readable name of the object (Undo, Spawnmenu, etc.)
ENT.Author      = "Octo"

ENT.Category = "Carrying Crates" --Don't change this
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

--Crate attributes
ENT.Model = ""
ENT.Physmat = ""    --Optional parameter
ENT.Mass = 50       --Optional parameter
ENT.ValidateContents = false --Checks if the CoM of the entity is within the box. Defaults to false.
ENT.AccumulateMass = true --Optional parameter (defaults to false). Makes the physical weight of the box equal to itself plus the combined weight of the contents inside it.

--Box to search for entities in relative to the coordinate center of the chosen model (Use Precision Alignment to obtain the desired size without trial and error)
ENT.Box = {
    min = Vector(-1,-1,-1),
    max = Vector(1,1,1)
}

ENT.TippingPoint = { --Optional paramter. Defines the Angles at which any cargo inside will be dropped. If not defined the crate will never automatically drop its contents.
    min = Angle(-90,-360,-90),   --Minimum angle to dump contents
    max = Angle(90,360,90)       --Maximum angle to dump contents
}

ENT.Sounds = {                  --Optional parameter
    on = "buttons/button6.wav", --Played when the crate holds onto something
    off = "buttons/button4.wav", --Played when the crate lets go of something
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