-------------------------------------
-- Created by Umair Azfar Khan 
--
-- Version 0.9
--
-- Can be easily converted to RA mod
--
-- Creation date: 2014 Nov 9 
-------------------------------------

ScoutTeam = {"sniper", "e3", "e3", "e3", "e3"}							--Starting reinforcements

ScoutTeamPath = { EntryPoint.Location, RallyPoint.Location }			--The path taken by the reinforcements as the mission starts

--The Anti Aircraft guns to destroy in order to call reinforcements
AgunsA = { Agun1a, Agun2a, Agun3a, Agun4a }
AgunsB = { Agun1b, Agun2b, Agun3b }
AgunsC = { Agun1c, Agun2c, Agun3c, Agun4c, Agun5c, Agun6c, Agun7c}
AgunsD = { Agun1d, Agun2d, Agun3d, Agun4d, Agun5d, Agun6d }

InsertionHelicopter = "tran"											--transport helicopter
TransReinforcements = { "e1", "e1", "e1", "e1", "e1" }					--Reinforcements carried by the transport helicopter

TransReinforcementsPathA = { PathAEntry.Location, PathARally.Location}	--Reinforcements path A
TransReinforcementsPathB = { PathBEntry.Location, PathBRally.Location}	--Reinforcements path B
TransReinforcementsPathC = { PathCEntry.Location, PathCRally.Location}	--Reinforcements path C

AgunsType = 1	--Used to keep track of which AA guns team is destroyed, so that the appropriate transport is called

ParadropPoints = { Paradrop1, Paradrop2, Paradrop3, Paradrop4 }			--Points where troops will be paradropped
ParadropTroops = { "e1", "e1", "e1", "e1", "e4", "e3", "e3", "e3" }		--Troop types to be paradropped

Helipads = { Hpad1, Hpad2, Hpad3, Hpad4 }								--List of Helipads

Buildings = { Obj1, Obj2, Obj3, Obj4, Obj5, Obj6, Obj7, Obj8, Obj9, Obj10, Obj11, Obj12, Obj13, Obj14, Obj15, Obj16, Obj17, Obj18, Obj19, Obj20, Obj21, Obj22, Obj23, Obj24, Obj25, Obj26 }

AgunDefenders = {"e1", "rflgnd", "e3", "e3"}								--Defenders of Aguns
AgunPoints = { AgunPoint1, AgunPoint2, AgunPoint3, AgunPoint4, AgunPoint5, AgunPoint6, AgunPoint7, AgunPoint8, AgunPoint9, AgunPoint10, AgunPoint11, AgunPoint12 }

BaseDefenders = {"e1", "e1", "e3", "e3", "2tnk", "2tnk"}				--Base Defenders
BasePoints = { BasePoint1, BasePoint2, BasePoint3, BasePoint4, BasePoint5, BasePoint6, BasePoint7, BasePoint8, BasePoint9, BasePoint10 }

--------------------------------------
--   Called when the game starts    --
--------------------------------------
SendScoutTeam = function()
	local Scouts = Reinforcements.Reinforce(player, ScoutTeam, ScoutTeamPath, DateTime.Seconds(1))
	Trigger.OnAllKilled(Scouts, MissionFailed)
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

--------------------------------------------------
--   Called when reinforcements are demanded    --
--------------------------------------------------
SendReinforcements = function()
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
	if AgunsType == 1 then
		Reinforcements.ReinforceWithTransport(player, InsertionHelicopter, TransReinforcements, TransReinforcementsPathA)
	elseif AgunsType == 2 then
		Reinforcements.ReinforceWithTransport(player, InsertionHelicopter, TransReinforcements, TransReinforcementsPathB)
	elseif AgunsType == 3 then
		Reinforcements.ReinforceWithTransport(player, InsertionHelicopter, TransReinforcements, TransReinforcementsPathC)
	end
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

-------------------------------------------------------
--   Called when all helipads have been destroyed    --
-------------------------------------------------------
HelipadsDestroyed = function()
	player.MarkCompletedObjective(HelipadsCapturedObjective)
	pakistan.MarkFailedObjective(DefendHelipadsObjective)
	Trigger.AfterDelay(DateTime.Seconds(2), function() Media.PlaySpeechNotification(player, "ObjectiveMet") end)
end

------------------------------------------------------------
--   Called when all the buildings have been destroyed    --
------------------------------------------------------------
BuildingsDestroyed = function()
	MissionAccomplished()
end

--------------------------------------------
--   Called when Mission is successful    --
--------------------------------------------
MissionAccomplished = function()
	Trigger.AfterDelay(DateTime.Seconds(2), function() 
		Media.PlaySpeechNotification(player, "Win")
	end)
	Trigger.AfterDelay(DateTime.Seconds(4), function() 
		player.MarkCompletedObjective(SurviveObjective)
		pakistan.MarkFailedObjective(AnnihilateObjective)
	end)
end

-------------------------------------------
--   Called when Mission is a failure    --
-------------------------------------------
MissionFailed = function()
	Trigger.AfterDelay(DateTime.Seconds(2), function() 
		Media.PlaySpeechNotification(player, "Lose")
	end)
	Trigger.AfterDelay(DateTime.Seconds(4), function() 
		player.MarkFailedObjective(SurviveObjective)
		pakistan.MarkCompletedObjective(AnnihilateObjective)
	end)
end

----------------------------------------
--   Called to produce Helicopters    --
----------------------------------------
ProduceHelicopters = function()
	local pad = Utils.Random(Helipads)
	if not pad.IsDead then
		local heli = Actor.Create("heli", true, { Owner = pakistan, Location = pad.Location})
		local path = {HeliPoint1.Location, HeliPoint2.Location}
		
		heli.AttackMove(path[1])
		heli.AttackMove(path[2])
		Trigger.OnIdle(heli, function() ContinuePatrol(heli, path) end)
	end
	Trigger.AfterDelay(DateTime.Seconds(120), ProduceHelicopters)
end

------------------------------------
--   Called to continue patrol    --
------------------------------------
ContinuePatrol = function(unit, path)
    unit.AttackMove(path[1])
    unit.AttackMove(path[2])
end
----------------------------------------------------
--   Called when a series of AA guns is killed    --
----------------------------------------------------
AgunsAKilled = function()
	AgunsType = 1
	Trigger.AfterDelay(DateTime.Seconds(2), SendReinforcements)
end

AgunsBKilled = function()
	AgunsType = 2
	Trigger.AfterDelay(DateTime.Seconds(2), SendReinforcements)
end

AgunsCKilled = function()
	AgunsType = 3
	Trigger.AfterDelay(DateTime.Seconds(2), SendReinforcements)
end

AgunsDKilled = function()
	Trigger.AfterDelay(DateTime.Seconds(2), function()
		Media.PlaySpeechNotification(player, "ObjectiveMet")
		player.MarkCompletedObjective(AAgunsDestroyedObjective)
		pakistan.MarkFailedObjective(AAgunsSavedObjective)
	end)
	Trigger.AfterDelay(DateTime.Seconds(4), function() 
		ParadropUnits()
	end)
end

-----------------------------------------------
--   Called when the last AA gun is killed   --
-----------------------------------------------
ParadropUnits = function()
	num = 1
	Media.PlaySpeechNotification(player, "ReinforcementsArrived")
	Utils.Do(ParadropPoints, function(type)
		local lz = ParadropPoints[num].Location
		local start = Map.CenterOfCell(Map.RandomEdgeCell()) + WVec.New(0, 0, Actor.CruiseAltitude("badr"))
		local transport = Actor.Create("badr", true, { CenterPosition = start, Owner = player, Facing = (Map.CenterOfCell(lz) - start).Facing })

		Utils.Do(ParadropTroops, function(type)
			local a = Actor.Create(type, false, { Owner = player })
			transport.LoadPassenger(a)
		end)

		transport.Paradrop(lz)
		num = num + 1
	end)
end

------------------------------------------------------------------
--   Called to initialize Pakistani infantry all over the map   --
------------------------------------------------------------------
InitializePakArmy = function()	
	--Initialize all the Agun Defenders
	num = 1
	Utils.Do(AgunPoints, function(type)
		Utils.Do(AgunDefenders, function(unit)
			local u = Actor.Create(unit, true, { Owner = pakistan, Location = AgunPoints[num].Location})
			u.Scatter()	
		end)
		num = num + 1
	end)	
	--Initialize all the Base Defenders
	num = 1
	Utils.Do(BasePoints, function(type)
		Utils.Do(BaseDefenders, function(unit)
			local u = Actor.Create(unit, true, { Owner = pakistan, Location = BasePoints[num].Location})
			u.Scatter()	
		end)
		num = num + 1
	end)	
	
	--Acquire the entire pakistan army
	pakistanArmy = pakistan.GetGroundAttackers()
	--Set the stance to Hunt
	Utils.Do(pakistanArmy, function(a) 
		--a.Stance = "Defend"
		if not a.IsDead and a.HasProperty("Hunt") then
			Trigger.OnIdle(a, a.Hunt)
		end
	end)
		
end

---------------------------------------------------------------------
--   Called when the world is loaded at the beginning of the map   --
---------------------------------------------------------------------
WorldLoaded = function()
	player = Player.GetPlayer("INDIA")						--Setting India as the playable faction
	pakistan = Player.GetPlayer("PAKISTAN")
	
	Trigger.OnObjectiveCompleted(player, function(p, id) Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")	end)
	Trigger.OnObjectiveFailed(player, function(p, id) Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed") end)
	
	--Setting the Primary Objectives
	SurviveObjective = player.AddPrimaryObjective("At least one member of the scout team must survive.")
	AnnihilateObjective = pakistan.AddPrimaryObjective("The Indian scout team must be annihilated.")
	
	--Setting Secondary Objectives
	AAgunsDestroyedObjective = player.AddSecondaryObjective("Destroy all Anti Aircraft Guns in the area.")
	AAgunsSavedObjective = pakistan.AddSecondaryObjective("Defend all Anti Aircraft Guns in the area.")
	HelipadsDestroyedObjective = player.AddSecondaryObjective("Destroy all helipads in the area.")
	HelipadsSavedObjective = pakistan.AddSecondaryObjective("Defend all helipads in the area.")
	
	--Initializing Camera
	Trigger.AfterDelay(DateTime.Seconds(1), function() Actor.Create("camera", true, { Owner = player, Location = CameraPoint.Location }) end)
	Camera.Position = CameraPoint.CenterPosition			--Centering the map to the Location
	
	InitializePakArmy()										--Produce the Pakistan army on map
	ProduceHelicopters()
	Trigger.AfterDelay(DateTime.Seconds(1), SendScoutTeam) 	--Sending the Indian scout team reinforcements	
	
	Trigger.OnAllKilled(AgunsA, AgunsAKilled) 				--This is triggered when the A series of funs is Annihilated
	Trigger.OnAllKilled(AgunsB, AgunsBKilled) 				--This is triggered when the B series of funs is Annihilated
	Trigger.OnAllKilled(AgunsC, AgunsCKilled) 				--This is triggered when the C series of funs is Annihilated
	Trigger.OnAllKilled(AgunsD, AgunsDKilled) 				--This is triggered when the D series of funs is Annihilated
	Trigger.OnAllKilled(Helipads, HelipadsDestroyed) 		--This is triggered when all helipads have been Annihilated
	Trigger.OnAllKilled(Buildings, BuildingsDestroyed) 		--This is triggered when all Buildings have been Annihilated
end