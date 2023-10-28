import "CoreLibs/object"


class("StorageImplementation",
    {
        template = {},
        defaultValue = nil,
        _idToValue = {},
        _nameToId = {}
    },
    dialogue
)

function dialogue.StorageImplementation:init(template, devaultValue)
    self.defaultValue = devaultValue
    self:setTemplate(template)
end


function dialogue.StorageImplementation:set(item, value)
    local name = tostring(item)
    self:setById(self._nameToId(name), value)
end


function dialogue.StorageImplementation:setById(id, value)
    self._idToValue[id] = value
end


function dialogue.StorageImplementation:get(item)
    local name = tostring(item)
    return self:getById(self._nameToId(name))
end


function dialogue.StorageImplementation:getById(id)
    return self._idToValue[id]
end


function dialogue.StorageImplementation:clear(clearValue)
    clearValue = clearValue or self.defaultValue
    for id, value in pairs(self._idToValue) do
        self._idToValue[id] = self.defaultValue
    end
end


function dialogue.StorageImplementation:setTemplate(newTemplate)
    self.template = newTemplate
    if self.template ~= nil then
        for i, id in ipairs(template.ids()) do
            local item = template.getItem(id)
            self._nameToId[tostring(item)] = id
            if self._idToValue[id] == nil then
                self._idToValue[id] = self.defaultValue
            end
        end
    end
end
