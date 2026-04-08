JeepReinforcements = {"jeep", "jeep"}
JeepReinforcementsPath = { PakEntry.Location, PakRally.Location }
JeepDelay = 12
JeepInterval = 2


Force = { "e1", "e1", "e1", "e1", "e2"}
ForcePath = { IndiaEntry.Location, IndiaRally.Location }
ForceDelay = 15
ForceInterval = 2

ParadropUnitTypes = { "e1", "e1", "e1", "e3", "e3"}
ParadropWaypoints = { PakRally, IndiaRally}

SendJeeps = function()
	Reinforcements.Reinforce(player, JeepReinforcements, JeepReinforcementsPath, DateTime.Seconds(JeepInterval))
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

SendIndianInfantry = function()
	local units = Reinforcements.Reinforce(india, Force, ForcePath, ForceInterval)
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Trigger.AfterDelay(DateTime.Seconds(5), SendIndianInfantry)
end

BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == india then
			Trigger.OnIdle(a, a.Hunt)
		else
			Trigger.OnIdle(a, function(a) a.AttackMove(Outpost.Location) end)
		end
	end
end

OutpostDestroyed = function()
	MissionFailed()
end

MissionAccomplished = function()
	Media.PlaySpeechNotification(player, "Win")
end

MissionFailed = function()
	Media.PlaySpeechNotification(player, "Lose")
	player.MarkFailedObjective(SurviveObjective)
	india.MarkCompletedObjective(DestroyObjective)
end

ParadropIndianUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = india, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = india })
		BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(15), ParadropIndianUnits)
end

WorldLoaded = function()
	player = Player.GetPlayer("PAKISTAN")
	india = Player.GetPlayer("INDIA")
	
	Trigger.OnObjectiveCompleted(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)

	Trigger.OnObjectiveFailed(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)
	
	Trigger.OnKilled(Outpost, OutpostDestroyed)
	
	SurviveObjective = player.AddPrimaryObjective("The outpost must survive.")
	DestroyObjective = india.AddPrimaryObjective("The Pakistani outpost must be destroyed.")
	
	Trigger.AfterDelay(DateTime.Seconds(60), function()
		MissionAccomplished()
		player.MarkCompletedObjective(SurviveObjective)
		india.MarkFailedObjective(DestroyObjective)
	end)
	Trigger.AfterDelay(DateTime.Seconds(2), function() Actor.Create("camera", true, { Owner = player, Location = PakRally.Location }) end)
	Camera.Position = Outpost.CenterPosition
	Trigger.AfterDelay(DateTime.Seconds(5), SendJeeps) --Sending Allied reinforcements	
	SendIndianInfantry(IndiaEntry.Location, Force, ForceInterval) --Sending Indian ground troops every 15 seconds	
	ParadropIndianUnits()
end