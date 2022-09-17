carrying_crate = carrying_crate or {}
carrying_crate_custom = carrying_crate_custom or {}
carrying_crate.giveHint = true
util.AddNetworkString("octoCarryingCrateGiveHint")
util.AddNetworkString("octoCarryingCrateEmergencyExit")
util.AddNetworkString("octoCarryingCrateCustomRequest")
util.AddNetworkString("octoCarryingCrateCustomResponse")

CreateConVar("carrying_crate_max_connected_ents", 6, FCVAR_NONE, "The number of entities connected to a secured prop that will also be parented to the crate. Good for controlling performance, as large contraptions will cause lag spikes when parented all at once. Some contraptions are not physically stable when being unloaded.", 1, 65535)
CreateConVar("carrying_crate_custom_size_limit", 512, FCVAR_NONE, "The maximum and minimum limit of the box size on custom crates.", 1)
CreateConVar("carrying_crate_force_mass_accumulation", 0, FCVAR_NONE, "Makes the crate weigh the sum of the items inside of it. 0 = Entity's choice. 1 = Force mass acumulation for all crates. 2 = Disable mass accumulation for all crates.", 0, 2)
CreateConVar("carrying_crate_force_content_validation", 0, FCVAR_NONE, "Content validation checks to see if the prop trying to be carried has its center of mass within the crate boundaries. If it is not then it will not be carried. 0 = Entity's choice. 1 = Force content validation for all crates. 2 = Disable content validation for all crates.", 0, 2)

--Thanks, shadowscion
local function checkOwner(ply, ent)
    if CPPI then
        local owner = ent:CPPIGetOwner() or (ent.GetPlayer and ent:GetPlayer())
        if owner then
            return owner == ply
        end
    end
    return true
end

--Replaces ENT:Initialize()
carrying_crate.init = function(this)
	local modelpath = this.Model
	local physmat = this.Physmat or nil
	this.savedata = this.savedata or {}
	this.hasLoad = false
	this.Sounds = this.Sounds or {}
    this.tipped = false

	this:SetModel(modelpath)
	this:PhysicsInit(SOLID_VPHYSICS)
	this:SetMoveType(MOVETYPE_VPHYSICS)
	this:SetSolid(SOLID_VPHYSICS)
	this:DrawShadow(true)
	this.InitialVel = this.InitialVel or Vector(0,0,0)
    this.ValidateContents = this.ValidateContents or false

    --Determine mass accumulation settings.
    local svma = GetConVar("carrying_crate_force_mass_accumulation"):GetInt()
    local svvc = GetConVar("carrying_crate_force_content_validation"):GetInt()

    if svma == 1 then
        this.AccumulateMass = true
    elseif svma == 2 then
        this.AccumulateMass = false
    end

    if svvc == 1 then
        this.ValidateContents = true
    elseif svvc == 2 then
        this.ValidateContents = false
    end

	local Phys = this:GetPhysicsObject()
    this.Mass = this.Mass or Phys:GetMass()
	if IsValid(Phys) then
		Phys:Wake()
		Phys:EnableDrag(false)

		if this.Mass then
			Phys:SetMass(this.Mass)
		end

		if physmat then
			Phys:SetMaterial(physmat)
		end
	end

	--Give hint to player on how to use the crate when first spawned.
	net.Start("octoCarryingCrateGiveHint")
	net.Send(this:GetCreator())

    --Add inputs and outputs.
    if WireLib then
        this.hasWire = true
        this.lastState = 0 --Last input state
        WireLib.CreateSpecialInputs(this,{"A"},{"NORMAL"})
        WireLib.CreateSpecialOutputs(this,{"HasLoad"},{"NORMAL"})
    else
        this.hasWire = false
    end
end

--This adds all new custom crates to a table so their bounding boxes can be
--context menu is open.
carrying_crate.registerCustom = function(this)
    table.insert( carrying_crate_custom, this )
    --PrintTable(carrying_crate_custom)
end

--This does the opposite of the above.
carrying_crate.removeCustom = function(this)
    table.RemoveByValue( carrying_crate_custom, this )
    --PrintTable(carrying_crate_custom)
end

--Returns the custom crates table.
carrying_crate.getCustom = function()
    return carrying_crate_custom
end

--Replaces ENT:Use()
carrying_crate.used = function(this)
	local onsound = this.Sounds.on or nil
	local offsound = this.Sounds.off or nil
    local max_connected_ents = GetConVar("carrying_crate_max_connected_ents"):GetInt()

	--Unparent everything inside if there is anything and return
	if this.hasLoad then
		for i in pairs(this.savedata) do

            --Skip over invalid entities. These usually are entities that are contanied in the crate but were removed before being released.
            if not IsValid(this.savedata[i][1]) then
                continue
            end

            local phys = this.savedata[i][1]:GetPhysicsObject()

			this.savedata[i][1]:SetParent(nil)
			this.savedata[i][1]:SetPos(this:LocalToWorld(this.savedata[i][2]))
			this.savedata[i][1]:SetAngles(this:LocalToWorldAngles(this.savedata[i][3]))
			phys:SetVelocity(this:GetPhysicsObject():GetVelocity())
			this.savedata[i][1]:SetLocalAngularVelocity(this:GetLocalAngularVelocity())
		end
		this.savedata = {}
		this.hasLoad = false
        
        if this.AccumulateMass then
            this:GetPhysicsObject():SetMass(this.Mass)
        end

        if this.hasWire then
            this.Outputs.HasLoad.Value = 0
        end

		if offsound then
			this:EmitSound(offsound)
		end
		return
	end

    --Do not attempt to fill crate if it is tipped over
    if this.tipped then
        return
    end

	--Parent everything inside
	local Ents = ents.FindInSphere( ( (this:LocalToWorld(this.Box.min)+this:LocalToWorld(this.Box.max))/2 ), this.Box.min:Distance(this.Box.max)/2 )

    this.Mass = this:GetPhysicsObject():GetMass()
    local emergencyExit = false --Called if too many props to constrain.

	for i in ipairs(Ents) do
		if Ents[i]:GetClass() ~= "player" and checkOwner(Ents[i]:CPPIGetOwner(), this) and IsValid(Ents[i]) and IsValid(Ents[i]:GetPhysicsObject()) then
			if not IsValid(Ents[i]:GetParent()) and constraint.GetAllConstrainedEntities(this)[Ents[i]] == nil then
                
                --Make sure the object is within the detection box
                local localPos
                
                if this.ValidateContents then
                    localPos = this:WorldToLocal(Ents[i]:LocalToWorld(Ents[i]:GetPhysicsObject():GetMassCenter()))

                    if not localPos:WithinAABox(this.Box.min, this.Box.max) then continue end
                else
                    --5 point check if center of mass check isn't required.
                    localPos = this:WorldToLocal(Ents[i]:GetPos())
                    localPos2, localPos3 = Ents[i]:GetCollisionBounds()
                    localPos2 = this:WorldToLocal(Ents[i]:LocalToWorld(localPos2))
                    localPos3 = this:WorldToLocal(Ents[i]:LocalToWorld(localPos3))
                    localPos4 = -localPos2
                    localPos5 = -localPos3

                    if not localPos:WithinAABox(this.Box.min, this.Box.max) and not localPos2:WithinAABox(this.Box.min, this.Box.max) and not localPos3:WithinAABox(this.Box.min, this.Box.max) and not localPos4:WithinAABox(this.Box.min, this.Box.max) and not localPos5:WithinAABox(this.Box.min, this.Box.max) then continue end
                end

				local pos = this:WorldToLocal(Ents[i]:GetPos())
				local ang = this:WorldToLocalAngles(Ents[i]:GetAngles())
				local phys = Ents[i]:GetPhysicsObject()

                local cons = constraint.GetAllConstrainedEntities(Ents[i])
                local c = 0
                
                for j in pairs(cons) do
                    if c > max_connected_ents then
                        emergencyExit = true
                        break
                    end
                    if not table.HasValue(Ents,j) then
                        table.insert(Ents,j)
                        c = c + 1
                    end
                end

                if emergencyExit then
                    net.Start("octoCarryingCrateEmergencyExit")
                    net.WriteInt(table.Count(cons), 16)
                    net.WriteInt(max_connected_ents, 16)
                    net.Send(this.lastuser)
                    break
                end

				table.insert(this.savedata, {Ents[i], pos, ang})
				phys:EnableMotion(true)
				phys:Sleep()
				Ents[i]:SetParent(this)
				this.hasLoad = true

                if this.AccumulateMass then
                    this:GetPhysicsObject():SetMass(math.Clamp(this:GetPhysicsObject():GetMass()+phys:GetMass(), 1, 50000))
                end

                if this.hasWire then
                    this.Outputs.HasLoad.Value = 1
                end

                if onsound then
					this:EmitSound(onsound)
				end
			end
		end
	end
end

carrying_crate.think = function(this)

    if this.hasWire then
        if this.Inputs.A.Value > 0 and this.Inputs.A.Value ~= this.lastState then
            carrying_crate.used(this)
        end
        this.lastState = this.Inputs.A.Value
    end

    if this.TippingPoint then
        local phys = this:GetPhysicsObject()
        local angs = phys:GetAngles()
        local x,y,z = angs:Unpack()
        x = math.NormalizeAngle(x)
        y = math.NormalizeAngle(y)
        z = math.NormalizeAngle(z)
        local minx,miny,minz = this.TippingPoint.min:Unpack()
        local maxx,maxy,maxz = this.TippingPoint.max:Unpack()
        local tipsound = this.Sounds.tipsound or nil
        
        if (x<minx or y<miny or z<minz) or (x>maxx or y>maxy or z>maxz) then
            --Unparent everything inside if there is anything and return
            if this.hasLoad then
                for i in pairs(this.savedata) do
                    local phys = this.savedata[i][1]:GetPhysicsObject()

                    this.savedata[i][1]:SetParent(nil)
                    phys:Wake()
                    this.savedata[i][1]:SetPos(this:LocalToWorld(this.savedata[i][2]))
                    this.savedata[i][1]:SetAngles(this:LocalToWorldAngles(this.savedata[i][3]))
                    phys:SetVelocity(this:GetPhysicsObject():GetVelocity())
                    this.savedata[i][1]:SetLocalAngularVelocity(this:GetLocalAngularVelocity())
                end
                this.savedata = {}
                this.hasLoad = false

                if this.hasWire then
                    this.Outputs.HasLoad.Value = 0
                end

                if tipsound then
                    this:EmitSound(tipsound)
                end
            end

            if this.AccumulateMass then
                this:GetPhysicsObject():SetMass(this.Mass)
            end

            this.tipped = true
        else
            this.tipped = false
        end
    end
end

--Maybe look into this, behavior seems strange
carrying_crate.onremove = function(this)
    if this.hasLoad then
        for i in pairs(this.savedata) do
            if not IsValid(this.savedata[i][1]) then continue end
            local phys = this.savedata[i][1]:GetPhysicsObject()

            this.savedata[i][1]:SetParent(nil)
            phys:Wake()
            this.savedata[i][1]:SetPos(this:LocalToWorld(this.savedata[i][2]))
            this.savedata[i][1]:SetAngles(this:LocalToWorldAngles(this.savedata[i][3]))
            phys:SetVelocity(this:GetPhysicsObject():GetVelocity())
            this.savedata[i][1]:SetLocalAngularVelocity(this:GetLocalAngularVelocity())
        end
    end
end

--Net message to send the client the custom crates table.
net.Receive("octoCarryingCrateCustomRequest", function(len, ply)
    net.Start("octoCarryingCrateCustomResponse")
    net.WriteInt(table.Count(carrying_crate_custom), 64)
    for i in pairs(carrying_crate_custom) do
        --print("Server", carrying_crate_custom[i], i)
        net.WriteEntity(carrying_crate_custom[i])
    end
    net.Send(ply)
end)