import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"


local ds<const> = dialogueSystem


class("StorageItem", {dummyId = -1}, ds).extends()


function ds.StorageItem:init(storage, storageId)
    self.storage = storage
    self.storageId = storageId or self.dummyId
end


function ds.StorageItem:__tostring()
    return tostring(self:getValue())
end


function ds.StorageItem:__eq(other)
    if not other then
        return not storage
    end
    return self.storage == other.storage and self.storageId == other.storageId
end


function ds.StorageItem:getValue()
    if not self.storage then
        return nil
    end
    return self.storage:getItem(self.storageId)
end
