

local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

local deadPeds = {}


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(900000) --Runs every 15 minutes
        local deadPeds = {}
        for ped in EnumeratePeds() do
            if IsEntityDead(ped) then
                --deadPeds.insert(deadPeds, ped)
                table.insert(deadPeds, ped)
            end
        end
        TriggerServerEvent("deleteEntitiesAcrossClients", deadPeds)
    end
end)


RegisterNetEvent('deleteEntitiesFromServer')
AddEventHandler('deleteEntitiesFromServer', function(entities)
  for i, entity in pairs(entities) do
    SetEntityAsNoLongerNeeded(entity)
    DeleteEntity(entity)
  end
end)