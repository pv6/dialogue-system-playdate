import "CoreLibs/object"

import "storageItem"


class("Storage",
    {
        _data = {},
        _ids = {},
        _items = {}
    },
    dialogue
)


function dialogue.Storage:setData(newData)
    table.shallowCopy(newData, self._data)

    local _, numOfItems = table.getSize(self._data)
    self._ids = table.create(numOfItems, 0)
    self._items = table.create(numOfItems, 0)
    for id, item in pairs(self._data) do
        table.insert(self._id, id)
        table.insert(self._items, item)
    end
end


function dialogue.Storage:getItem(id)
    return self._data[id]
end


function dialogue.Storage:getItemReference(id)
    return StorageItem(self, id)
end


function dialogue.Storage:hasId(id)
    return self._data[id] ~= nil
end


function dialogue.Storage:hasItem(item)
    return table.indexOfElement(self._data, item) ~= nil
end


function dialogue.Storage:ids()
    return table.shallowCopy(self._ids)
end


function dialogue.Storage:items()
    return table.shallowCopy(self._items)
end
