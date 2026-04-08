HelipadCount = 0
PrisonersToRescue = 2
HelipadDestroyed = false
BaseDestroyed = false
ShipsRemaining = 3

ProducedUnitTypes =
{
	{ Tent1, { "e1", "e2", "e3", "e4", "sniper" } },
	{ Tent2, { "e1", "e2", "e3", "e4", "sniper" } },
	{ Tent3, { "e1", "e2", "e3", "e4", "sniper" } },
	{ Weap1, { "bmp", "maag", "jeep", "1tnk", "2tnk", "akbar", "hatf", "arty" } },
	{ Weap2, { "bmp", "maag", "jeep", "1tnk", "2tnk", "akbar", "hatf", "arty" } },
	{ Weap3, { "bmp", "maag", "jeep", "1tnk", "2tnk", "akbar", "hatf", "arty" } },
	{ Weap4, { "bmp", "maag", "jeep", "1tnk", "2tnk", "akbar", "hatf", "arty" } }
}

AirPoints = { AFLD1, AFLD2, AFLD3, AFLD4, AFLD1, AFLD2, AFLD3, AFLD4, MAINOBJ}
AirTypes = {"f16","su25","mushak"}

ParadropUnitTypes = { "e1", "e1", "e2", "e2", "e3", "e3", "e4", "e4" }
ParadropWaypoints = { Paradrop1, Paradrop2, Paradrop3, Paradrop4, Paradrop5}

DoomedReinforcements = {"mslb", "mslb", "mfrg", "mfrg", "ss", "ss"}	--The Doomed Squad
DoomedPath = { DoomEntry.Location, DoomRally.Location }				--The path taken by the Doomed squad while entering

MsubsReinforcements = {"mslb", "mslb", "mfrg", "mfrg", "ss", "ss", "msub", "msub", "msub", "msub"}

GabbarReinforcements = {"gabbar", "e6", "e6", "hijacker", "hijacker"}	--The Gabbar Squad
GabbarPath = { GabbarEntry.Location, GabbarRally.Location }				--The path taken by the Gabbar squad while entering

mcvReinforcements = {"mcv", "bggy", "bggy", "4tnk", "4tnk"}	--The MCV Squad
mcvPath = { mcvEntry.Location, mcvRally.Location }				--The path taken by the MCV squad while entering

TopPatrolUnits = {Top1, Top2, Top3, Top4, Top5, Top6, Top7, Top8, Top9, Top10}
TopPatrolPath = { TopPatrolPoint1.Location, TopPatrolPoint2.Location }

JailPatrolUnits = {JailPatrol1, JailPatrol2, JailPatrol3, JailPatrol4, JailPatrol5, JailPatrol6, JailPatrol7, JailPatrol8, JailPatrol9, JailPatrol10, JailPatrol11, JailPatrol12, JailPatrol13, JailPatrol14, JailPatrol15, JailPatrol16, JailPatrol17, JailPatrol18}
JailPatrolPath = { JailPatrolPoint1.Location, JailPatrolPoint2.Location }

TopTankUnits = {TopTank1, TopTank2, TopTank3, TopTank4, TopTank5, TopTank6}
TopTankPath = { TopTankPoint1.Location, TopTankPoint2.Location }

Jail01Guards = {Jail01G1, Jail01G2, Jail01G3, Jail01G4, Jail01G5, Jail01G6, Jail01G7, Jail01G8, Jail01G9, Jail01G10, Jail01G11}
Jail02Guards = {Jail02G1, Jail02G2, Jail02G3, Jail02G4, Jail02G5, Jail02G6, Jail02G7, Jail02G8, Jail02G9}
JailPrisoners = {"e1", "e1", "e1", "e1", "e2", "e2", "e2", "e2", "e3", "e3", "e3", "e3", "Sniper"}

CentralArty = {Arty1, Arty2, Arty3, Arty4, Arty5}

HeliPatrolPath = {HeliPoint1, HeliPoint2, HeliPoint3, HeliPoint4, HeliPoint5, HeliPoint6}

Force1 = { "e1", "e1", "e1", "e1", "e2"}
Force2 = { "e1", "e1", "e1", "e2", "e2"}
Force3 = { "e2", "e2", "e4", "e3", "e3"}

LakeBoats = {LakeBoat1, LakeBoat2}
LakePath = { LakePoint1.Location, LakePoint2.Location}

Alpha = { Alpha1, Alpha2, Alpha3, Alpha4, Alpha5, Alpha6, Alpha7, Alpha8 }
Beta = { Beta1, Beta2, Beta3, Beta4, Beta5, Beta6, Beta7, Beta8 }
Gamma = { Gamma1, Gamma2, Gamma3, Gamma4, Gamma5, Gamma6, Gamma7, Gamma8, Gamma9, Gamma10 }

AlphaPath = {AlphaPoint1.Location, AlphaPoint2.Location}
BetaPath = {BetaPoint1.Location, BetaPoint2.Location}
GammaPath = {GammaPoint1.Location, GammaPoint2.Location}

ParadropUnits = function()
	local lz = Utils.Random(ParadropWaypoints).Location
	local start = Utils.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
	local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = pakistan, Facing = (Map.CenterOfCell(lz) - start).Facing })

	Utils.Do(ParadropUnitTypes, function(type)
		local a = Actor.Create(type, false, { Owner = pakistan })
		BindActorTriggers(a)
		transport.LoadPassenger(a)
	end)

	transport.Paradrop(lz)
	Trigger.AfterDelay(DateTime.Seconds(40), ParadropUnits)
end

--****************************************************
	--local f16 = Actor.Create("f16", true, { Owner = pakistan, Location = Helipad1.Location})
	--local tada = {f16}
	--StartPatrol(tada, GabbarPath)
	--****************************************************
CreateAircraft = function()
	local AttackPath = {HavyWeap.Location, Paradrop4.Location}
	local spawnPoint = Utils.Random(AirPoints)
	local randomAircraft = Utils.Random(AirTypes)
	local aircraftType = Actor.Create(randomAircraft, true, { Owner = pakistan, Location = spawnPoint.Location})
	local aircraft = {aircraftType}
	StartPatrol(aircraft, AttackPath)
	Trigger.AfterDelay(DateTime.Seconds(20), CreateAircraft)
end

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

--------------Pakistani Reinforcements on getting MCV
SendPakistanInfantry = function()
	Ambush1Path = { Ambush1.Location, InfantryRally1.Location }
	local units = Reinforcements.Reinforce(pakistan, Force1, Ambush1Path, DateTime.Seconds(2))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Ambush2Path = { Ambush2.Location, InfantryRally2.Location }
	units = Reinforcements.Reinforce(pakistan, Force2, Ambush2Path, DateTime.Seconds(2))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	Ambush3Path = { Ambush3.Location, InfantryRally3.Location }
	units = Reinforcements.Reinforce(pakistan, Force3, Ambush3Path, DateTime.Seconds(2))
	Utils.Do(units, function(unit)
		BindActorTriggers(unit)
	end)
	if BaseDestroyed == false then
		Trigger.AfterDelay(DateTime.Seconds(30),SendPakistanInfantry )
	end
end
--------------CREATE THE PATROLLING HELICOPTERS---------------
CreateHeliPatrol = function()
	local heli1 = Actor.Create("heli", true, { Owner = pakistan, Location = Helipad1.Location})
	local heli2 = Actor.Create("heli", true, { Owner = pakistan, Location = HeliPoint6.Location})
	local heli3 = Actor.Create("heli", true, { Owner = pakistan, Location = HeliPoint5.Location})
	local heli4 = Actor.Create("heli", true, { Owner = pakistan, Location = Helipad4.Location})
	local helis = {heli1, heli2, heli3, heli4}
	local path = {HeliPoint3.Location, HeliPoint6.Location}
	--StartPatrol({heli1}, AttackPath)
	
	Utils.Do(helis, function(unit)
        unit.AttackMove(path[1])
        unit.AttackMove(path[2])
		Trigger.OnIdle(unit, function() ContinuePatrol(unit, path) end)
    end)
end

-- StartHeliPatrol = function(units, path)   --Start the patrol
	-- Utils.Do(units, function(unit)
		-- Utils.Do(path, function(wpt)
			-- unit.AttackMove(wpt.Location)
		-- end)
		-- Trigger.OnIdle(unit, StartSinglePatrol(unit, path))
	-- end)
-- end

-- StartSinglePatrol = function(unit, path)
	-- Utils.Do(path, function(wpt)
			-- unit.AttackMove(wpt.Location)
		-- end)
-- end
-------------What happens when Helipad is captured----------------
HelipadCaptured = function()
	HelipadCount = HelipadCount + 1
	if HelipadCount == 4 then
		player.MarkCompletedObjective(HelipadsCapturedObjective)
		pakistan.MarkFailedObjective(DefendHelipadsObjective)
	end
	if HelipadDestroyed == false then
		Media.PlaySpeechNotification(player, "ReinforcementsArrived")
		local hind = Actor.Create("hind", true, { Owner = player, Location = GabbarEntry.Location})
		--hind.AttackMove(HelipadLocation)
	end
end
----------Send Doomed Units------------------
SendDoomedUnits = function()
	local doomed = Reinforcements.Reinforce(player, DoomedReinforcements, DoomedPath, DateTime.Seconds(2))
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
	Trigger.OnAllKilled(doomed, function() DestroyShipsObjective = player.AddSecondaryObjective("Destroy the Pakistani Naval Fleet.") end)
end
----------Send in Gabbar Singh --------------
SendGabbar = function()
	local daku = Reinforcements.Reinforce(player, GabbarReinforcements, GabbarPath, DateTime.Seconds(2))
	local GABBAR = daku[1]
	Media.PlaySpeechNotification(player, "Ind01GabbarEntry")
	Trigger.OnKilled(GABBAR, GabbarKilled)
end
----------Send in MCV----------------------
DeployMCV = function()
	local mcvUnits = Reinforcements.Reinforce(player, mcvReinforcements, mcvPath, DateTime.Seconds(5))
	local MCV = mcvUnits[1]
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
	
	--Trigger.OnIdle(MCV, function(MCV) MCV.Deploy() end)
	DestroyBaseObjective = player.AddSecondaryObjective("Destroy the base to the South.")
	DefendBaseObjective = pakistan.AddSecondaryObjective("Defend the base to the South.")	
end
-----------Bind Actor Triggers------------
BindActorTriggers = function(a)
	if a.HasProperty("Hunt") then
		if a.Owner == pakistan then
			Trigger.OnIdle(a, a.Hunt)
		else
			Trigger.OnIdle(a, function(a) a.AttackMove(mcvRally.Location) end)
		end
	end
end


StartPatrol = function(units, path)    
	Utils.Do(units, function(unit)
        unit.AttackMove(path[1])
        unit.AttackMove(path[2])
		Trigger.OnIdle(unit, function() ContinuePatrol(unit, path) end)
    end)
end

ContinuePatrol = function(unit, path)
    unit.AttackMove(path[1])
    unit.AttackMove(path[2])
end
--------------SECONDARY OBJECTIVE: CentralArtyDestroyed ----------------------
CentralArtyDestroyed = function()
	player.MarkCompletedObjective(ArtilleryDestroyedObjective)
	Trigger.AfterDelay(DateTime.Seconds(5), function() Media.PlaySpeechNotification(player, "ObjectiveMet") end)	
end

Jail02GuardsKilled = function()
	PrisonersToRescue = PrisonersToRescue - 1;
	if PrisonersToRescue == 0 then
		player.MarkCompletedObjective(RescuePrisonersObjective)
		Trigger.AfterDelay(DateTime.Seconds(5), function() Media.PlaySpeechNotification(player, "ObjectiveMet") end)
	end
	
	Utils.Do(JailPrisoners, function(unit)
		local u = Actor.Create(unit, true, { Owner = player, Location = Jail02Point.Location})
		u.Scatter()	
	end)
	
	Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(player, "TargetFreed") end)
end

Jail01GuardsKilled = function()
	PrisonersToRescue = PrisonersToRescue - 1;
	if PrisonersToRescue == 0 then
		player.MarkCompletedObjective(RescuePrisonersObjective)
		Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(player, "ObjectiveMet") end)
	end
	
	Utils.Do(JailPrisoners, function(unit)
		local u = Actor.Create(unit, true, { Owner = player, Location = Jail01Point.Location})
		u.Scatter()	
	end)
	
	Trigger.AfterDelay(DateTime.Seconds(1), function() Media.PlaySpeechNotification(player, "TargetFreed") end)
end
------------------------LAB DESTROYED----------------------
JailDestroyed = function()
	if PrisonersToRescue > 0 then
		RescueFailed()
	end
end
------------------------RESCUE DESTROYED----------------------
RescueFailed = function()
	player.MarkFailedObjective(RescuePrisonersObjective)
	pakistan.MarkCompletedObjective(DefendPrisonersObjective)
end

MissionAccomplished = function()
	Media.PlaySpeechNotification(player, "Win")
end

MissionFailed = function()
	Media.PlaySpeechNotification(player, "Lose")
	player.MarkFailedObjective(GabbarSurviveObjective)
	pakistan.MarkCompletedObjective(KillGabbarObjective)
end

SetUnitStances = function()
	Utils.Do(pakistanArmy, function(a)
		if a.Owner == pakistan then
			a.Stance = "Defend"
		end
	end)
end

ObjectiveDestroyed = function()
	MissionAccomplished()
	player.MarkCompletedObjective(GabbarSurviveObjective)
	pakistan.MarkFailedObjective(KillGabbarObjective)
end

GabbarKilled = function()
	MissionFailed()	
end

HelipadCaptureFailed = function() 
	HelipadDestroyed = true 
	player.MarkFailedObjective(HelipadsCapturedObjective)
	pakistan.MarkCompletedObjective(DefendHelipadsObjective)
end

OnBaseDestroyed = function() 
	BaseDestroyed = true
	player.MarkCompletedObjective(DestroyBaseObjective)
	SendDoomedUnits()
end

OnAllShipsDestroyed = function() 
	ShipsRemaining = ShipsRemaining - 1
	if ShipsRemaining == 0 then
		player.MarkCompletedObjective(DestroyShipsObjective)
		SendMissileSubs()
	end	
end

SendMissileSubs = function() 
	local msubs = Reinforcements.Reinforce(player, MsubsReinforcements, DoomedPath, DateTime.Seconds(2))
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

WorldLoaded = function()
	Media.PlayMovieFullscreen("landing.vqa")
	player = Player.GetPlayer("INDIA")
	pakistan = Player.GetPlayer("PAKISTAN")
	
	Trigger.OnObjectiveAdded(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)
	
	Trigger.OnObjectiveCompleted(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)

	Trigger.OnObjectiveFailed(player, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)
	
	Trigger.OnKilled(MAINOBJ, ObjectiveDestroyed)
	Trigger.OnKilled(Base, OnBaseDestroyed)
	
	----------------Primary Objectives-------------------	
	GabbarSurviveObjective = player.AddPrimaryObjective("Gabbar Singh must survive.")
	KillGabbarObjective = pakistan.AddPrimaryObjective("Gabbar Singh must die.")
	DestroyMainObjective = player.AddPrimaryObjective("Destroy the Island Outpost to the South-East.")
	DefendMainObjective = pakistan.AddPrimaryObjective("Defend the Island Outpost to the South-East.")
	----------------Secondary Objectives-----------------
	RescuePrisonersObjective = player.AddSecondaryObjective("Rescue all prisoners of war.")
	DefendPrisonersObjective = pakistan.AddSecondaryObjective("Defend all prisoners of war.")
	ArtilleryDestroyedObjective = player.AddSecondaryObjective("Take out any artillery that you encounter.")
	HelipadsCapturedObjective = player.AddSecondaryObjective("Capture any helipads you encounter in this area.")
	DefendHelipadsObjective = pakistan.AddSecondaryObjective("Defend all helipads.")
	
	
	SetupFactories()
	Trigger.AfterDelay(DateTime.Seconds(1400), function() 
		Utils.Do(ProducedUnitTypes, ProduceUnits) 
		CreateAircraft()
	end)
	Trigger.AfterDelay(DateTime.Seconds(300), DeployMCV);
	Trigger.AfterDelay(DateTime.Seconds(660), SendPakistanInfantry);
	Trigger.AfterDelay(DateTime.Seconds(840), ParadropUnits);
	
	CreateHeliPatrol()	--Create the Helicopter Patrol
	pakistanArmy = pakistan.GetGroundAttackers()
	SetUnitStances()

	Trigger.AfterDelay(DateTime.Seconds(2), function() Actor.Create("camera", true, { Owner = player, Location = GabbarRally.Location }) end)
	Camera.Position = GabbarRally.CenterPosition

	Trigger.AfterDelay(DateTime.Seconds(1), SendGabbar)
	
	--StartPatrol(TopPatrolUnits, TopPatrolPath)
	StartPatrol(TopPatrolUnits, TopPatrolPath)
	StartPatrol(JailPatrolUnits, JailPatrolPath)
	StartPatrol(TopTankUnits, TopTankPath)
	--StartPatrol(LakeBoats, LakePath)
	StartPatrol(Alpha, AlphaPath)
	StartPatrol(Beta, BetaPath)
	StartPatrol(Gamma, GammaPath)
	Trigger.OnAllKilled(Jail01Guards, Jail01GuardsKilled)
	Trigger.OnAllKilled(Jail02Guards, Jail02GuardsKilled)
	Trigger.OnAllKilled(CentralArty, CentralArtyDestroyed)
	Trigger.OnKilled(Jail01, JailDestroyed)
	Trigger.OnKilled(Jail02, JailDestroyed)
	
	Trigger.OnAllKilled(Alpha, OnAllShipsDestroyed)
	Trigger.OnAllKilled(Beta, OnAllShipsDestroyed)
	Trigger.OnAllKilled(Gamma, OnAllShipsDestroyed)

		
	Trigger.OnCapture(Helipad1, HelipadCaptured)
	Trigger.OnCapture(Helipad2, HelipadCaptured)
	Trigger.OnCapture(Helipad3, HelipadCaptured)
	Trigger.OnCapture(Helipad4, HelipadCaptured)
	-----------If a Helipad is destroyed, do not give a hind on capture-----------
	Trigger.OnKilled(Helipad1, HelipadCaptureFailed)
	Trigger.OnKilled(Helipad2, HelipadCaptureFailed)
	Trigger.OnKilled(Helipad3, HelipadCaptureFailed)
	Trigger.OnKilled(Helipad4, HelipadCaptureFailed)
end
