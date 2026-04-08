JeepReinforcements = {"jeep", "jeep"}
JeepReinforcementsPath = { PakEntry.Location, PakRally.Location }
JeepDelay = 12
JeepInterval = 2


Force = { "e1", "e1", "e1", "e1", "e2"}
ForcePath = { IndiaEntry.Location, IndiaRally.Location }
ForceDelay = 15
ForceInterval = 2

ProducedUnitTypes =
{
	{ Barracks1, { "e1", "e2", "e3" } },
	{ Barracks2, { "e1", "e3", "e4", "sniper" } }
}

ProduceUnits = function(t)
	local factory = t[1]
	if not factory.IsDead then
		local unitType = t[2][Utils.RandomInteger(1, #t[2] + 1)]
		factory.Wait(Actor.BuildTime(unitType))
		factory.Produce(unitType)
		factory.CallFunc(function() ProduceUnits(t) end)
	end
end

SetupFactories = function()
	Utils.Do(ProducedUnitTypes, function(pair)
		Trigger.OnProduction(pair[1], function(_, a) BindActorTriggers(a) end)
	end)
end

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
	SetupFactories()
	Trigger.AfterDelay(DateTime.Seconds(60), function()
		MissionAccomplished()
		player.MarkCompletedObjective(SurviveObjective)
		india.MarkFailedObjective(DestroyObjective)
	end)
	Trigger.AfterDelay(DateTime.Seconds(2), function() Actor.Create("camera", true, { Owner = player, Location = PakRally.Location }) end)
	Camera.Position = Outpost.CenterPosition
	Trigger.AfterDelay(DateTime.Seconds(5), SendJeeps) --Sending Allied reinforcements	
	SendIndianInfantry(IndiaEntry.Location, Force, ForceInterval) --Sending Indian ground troops every 15 seconds	
	Utils.Do(ProducedUnitTypes, ProduceUnits)
end