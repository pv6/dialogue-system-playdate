import "CoreLibs/object"


class("StorageItem",
    {
        storage = {},
        storageId = -1
    },
    dialogue
)


function dialogue.StorageItem:init(storage, storageId)
    self.storage = storage
    self.storgeId = storageId or -1
end


function dialogue.StorageItem:__tostring()
    return tostring(self:getValue())
end


function dialogue.StorageItem:__eq(other)
    if not other then
        return not storage
    end
    return self.storage == other.storage and self.storageId == other.storageId
end


function dialogue.StorageItem:getValue()
    if not self.storage then
        return nil
    end
    return self.storage.getItem(self.storageItem)
end
