import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/storage/storageItem"


local ds<const> = dialogueSystem


class("Storage", {}, ds).extends()


function ds.Storage:init(data)
    self:setData(data)
end


function ds.Storage:setData(newData)
    self._data = table.shallowcopy(newData)

    local arrayCount, hashCount = table.getsize(self._data)
    local numOfItems = arrayCount + hashCount
    self._ids = table.create(numOfItems, 0)
    self._items = table.create(numOfItems, 0)
    for id, item in pairs(self._data) do
        table.insert(self._ids, id)
        table.insert(self._items, item)
    end
end


function ds.Storage:getItem(id)
    return self._data[id]
end


function ds.Storage:getItemReference(id)
    return ds.StorageItem(self, id)
end


function ds.Storage:hasId(id)
    return self._data[id] ~= nil
end


function ds.Storage:hasItem(item)
    return table.indexOfElement(self._data, item) ~= nil
end


function ds.Storage:ids()
    return table.shallowcopy(self._ids)
end


function ds.Storage:items()
    return table.shallowcopy(self._items)
end
