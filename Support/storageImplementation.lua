import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"


local ds<const> = dialogueSystem


class("StorageImplementation", {}, ds).extends()


function ds.StorageImplementation:init(template, devaultValue)
    self.defaultValue = devaultValue
    self._nameToId = {}
    self._idToValue = {}
    self:setTemplate(template)
end


function ds.StorageImplementation:set(item, value)
    local name = tostring(item)
    self:setById(self._nameToId[name], value)
end


function ds.StorageImplementation:setById(id, value)
    self._idToValue[id] = value
end


function ds.StorageImplementation:get(item)
    local name = tostring(item)
    return self:getById(self._nameToId[name])
end


function ds.StorageImplementation:getById(id)
    return self._idToValue[id]
end


function ds.StorageImplementation:clear(clearValue)
    clearValue = clearValue or self.defaultValue
    for id, value in pairs(self._idToValue) do
        self._idToValue[id] = self.defaultValue
    end
end


function ds.StorageImplementation:setTemplate(newTemplate)
    self.template = newTemplate
    if self.template ~= nil then
        for i, id in ipairs(self.template:ids()) do
            local item = self.template:getItem(id)
            self._nameToId[tostring(item)] = id
            if self._idToValue[id] == nil then
                self._idToValue[id] = self.defaultValue
            end
        end
    end
end
