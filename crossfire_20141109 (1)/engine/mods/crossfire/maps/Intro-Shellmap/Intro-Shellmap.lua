ticks = 0
speed = 5

ShipUnitTypes = { "1tnk", "1tnk", "jeep", "jeep", "2tnk", "2tnk" }
BuggyReinforcements = { "bggy", "bggy", "sniper", "e1", "e1", "e1", "e1"}
BuggyInterval = 50
BuggyDelay = 225

ParadropUnitTypes = { "e1", "e1", "e2", "e2", "e3", "e3", "e4", "e4" }
ParadropWaypoints = { Paradrop1, Paradrop2, Paradrop3, Paradrop4, Paradrop5, Paradrop6, Paradrop7, Paradrop8, Paradrop9}

BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == pakistan then
			Trigger.OnIdle(a, a.Hunt)
		else
			Trigger.OnIdle(a, function(a) a.AttackMove(AttackPoint1.Location) end)
		end
	end

	if a.HasProperty("HasPassengers") then
		Trigger.OnDamaged(a, function()
			if a.HasPassengers then
				a.Stop()
				a.UnloadPassengers()
			end
		end)
	end
end

SendIndianUnits = function(entryCell, unitTypes, interval)
	local units = Reinforcements.Reinforce(india, unitTypes, { entryCell }, interval)
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.OnAllKilled(units, function() SendIndianUnits(entryCell, unitTypes, interval) end)
end

BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == india then
			Trigger.OnIdle(a, a.Hunt)
		else
			Trigger.OnIdle(a, function(a) a.AttackMove(AttackPoint1.Location) end)
		end
	end
end

ParadropIndianUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Utils.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = india, Facing = (Utils.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = india })
		BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(Utils.Seconds(15), ParadropIndianUnits)
end

SetupPakistaniUnits = function()
	Utils.Do(Map.NamedActors, function(a)
		if a.Owner == pakistan and a.HasProperty("AcceptsUpgrade") and a.AcceptsUpgrade("unkillable") then
			a.GrantUpgrade("unkillable")
			a.Stance = "Defend"
		end
	end)
end

SetupFactories = function()
	Utils.Do(ProducedUnitTypes, function(pair)
		Trigger.OnProduction(pair[1], function(_, a) BindActorTriggers(a) end)
	end)
end

Tick = function()
	ticks = ticks + 1
	
	local t = (ticks + 45) % (-360 * speed) * (math.pi / 180) / speed;
	Camera.Position = viewportOrigin + WVec.New(19200 * math.sin(t), 20480 * math.cos(t), 0)
end

SendVehicles = function()
	Reinforcements.Reinforce(india, { "bggy", "bggy", "veer", "veer", "3tnk", "3tnk"}, { EntryPoint1.Location, AttackPoint1.Location}, Utils.Seconds(2))
	Reinforcements.Reinforce(india, { "4tnk", "4tnk", "veer", "veer", "3tnk", "3tnk"}, { EntryPoint2.Location, AttackPoint1.Location}, Utils.Seconds(2))
	Reinforcements.Reinforce(india, { "e1", "e1", "e2", "e2", "e3", "e3"}, { EntryPoint3.Location, AttackPoint1.Location}, Utils.Seconds(1))
	
	Trigger.AfterDelay(Utils.Seconds(25),SendVehicles )
end

FrigatesReinforcements = { "mfrg", "mfrg" }
SendFrigates = function()
	local i = 1
	Utils.Do(FrigatesReinforcements, function(mfrg)
		local a = Actor.Create(mfrg, true, { Owner = india, Location = Map.NamedActor("SeaEntry" .. i).Location + CVec.New(2 * i, 0) })
		a.AttackMove(Map.NamedActor("SeaRally" .. i).Location)
		i = i + 1
	end)
	Trigger.AfterDelay(Utils.Seconds(25),SendFrigates )
end

--*******When the world is loaded***********
WorldLoaded = function()
	pakistan = Player.GetPlayer("PAKISTAN")
	india = Player.GetPlayer("INDIA")
	viewportOrigin = Camera.Position
	
	SetupPakistaniUnits()
	--SetupFactories()
	SendVehicles()
	SendFrigates()
	--SendIndianUnits(EntryPoint1.Location,{ "bggy", "bggy", "sniper", "e1", "e1", "e1", "e1"}, 50)
	--SendIndianUnits(EntryPoint2.Location,{ "bggy", "bggy", "veer", "veer", "3tnk", "3tnk", "4tnk"}, 50)
	--SendIndianUnits(EntryPoint3.Location,{ "veer", "veer", "sniper", "4tnk", "4tnk", "mlrs", "mlrs"}, 50)
	--sending ships
	--SendIndianUnits(SeaEntry1.Location,{ "mfrg", "mfrg", "mslb", "mslb"}, 50)
	--SendIndianUnits(SeaEntry2.Location,{ "mfrg", "mfrg", "mslb", "mslb"}, 50)
	ParadropIndianUnits()
	--OpenRA.RunAfterDelay(25*5, ChangeStance)
end



ChangeStance = function()
	local indiaUnits = Mission.GetGroundAttackersOf(india)
	for i, unit in ipairs(indiaUnits) do
		Actor.Hunt(unit)
	end
	--OpenRA.RunAfterDelay(StanceDelay, ChangeStance)
end