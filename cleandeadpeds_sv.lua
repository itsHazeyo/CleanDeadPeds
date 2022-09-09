RegisterServerEvent('deleteEntitiesAcrossClients')
AddEventHandler('deleteEntitiesAcrossClients', function(entities)
    players = GetPlayers()

    for k,v in pairs(players) do
        TriggerClientEvent("deleteEntitiesFromServer", v, entities)
    end
end)