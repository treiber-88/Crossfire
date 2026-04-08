PakForce = { "e1", "e1", "e1", "e1", "e2", "e2", "e1" }
PakForcePath = { PakEntry.Location, PakRally.Location }
PakForceDelay = 15
PakForceInterval = 2

IndForce1 = { "e1", "e1",  }
IndForcePath1 = { IndTopSpawn1.Location, IndTopSpawn1.Location }


IndForce2 = { "e1", "e1", "e1", "e2" }
IndForcePath2 = { IndTopSpawn2.Location, IndTopSpawn2.Location }


IndForce3 = { "e1", "e1", "e1", }
IndForcePath3 = { IndTopSpawn3.Location, IndTopSpawn3.Location }


IndForce4 = { "e1", "e1", "e1", "e1", "e1" }
IndForcePath4 = { IndTopSpawn4.Location, IndTopSpawn4.Location }


IndForce5 = { "e1", "e1", "e1", "e1", "e2", "e1", "e1", "e1", "e1", "e2", "e2", "e1" }
IndForcePath5 = { IndTopSpawn5.Location, IndTopSpawn5.Location }


PakDeploy = function()
    Reinforcements.Reinforce(player, PakForce, PakForcePath, Utils.Seconds(PakForceInterval))
    Media.PlaySpeechNotification(player, "ReinforcementsArrived")
end

IndDeploy1 = function()
    Reinforcements.Reinforce(India, IndForce1, IndForcePath1)
end

IndDeploy2 = function()
    Reinforcements.Reinforce(India, IndForce2, IndForcePath2)
end

IndDeploy3 = function()
    Reinforcements.Reinforce(India, IndForce3, IndForcePath3)
end

IndDeploy4 = function()
    Reinforcements.Reinforce(India, IndForce4, IndForcePath4)
end

IndDeploy5 = function()
    Reinforcements.Reinforce(India, IndForce5, IndForcePath5)
end




OutpostDestroyed = function()
    MissionFailed()
end

MissionFailed = function()
    Media.PlaySpeechNotification(player, "Lose")
    player.MarkFailedObjective(SurviveObjective)
    india.MarkCompletedObjective(DestroyObjective)
end

WorldLoaded = function()
    player = Player.GetPlayer("Pakistan")
    india = Player.GetPlayer("India")

    Trigger.OnObjectiveCompleted(player, function(p, id)
        Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
    end)

    Trigger.OnObjectiveFailed(player, function(p, id)
        Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
    end)

    Trigger.OnKilled(Outpost, MissionFailed)

    SurviveObjective = player.AddPrimaryObjective("The outpost must survive.")
    DestroyObjective = india.AddPrimaryObjective("The Pakistani outpost must be destroyed.")

    Trigger.AfterDelay(DateTime.Seconds(60), function()
        MissionAccomplished()
        player.MarkCompletedObjective(SurviveObjective)
        india.MarkFailedObjective(DestroyObjective)
    end)
	
	Trigger.AfterDelay(DateTime.Seconds(5), PakDeploy)
	Trigger.AfterDelay(DateTime.Seconds(1), IndDeploy1, IndDeploy2, IndDeploy3, IndDeploy5, IndDeploy5)
end

MissionAccomplished = function()
    Media.PlaySpeechNotification(player, "Win")
end










