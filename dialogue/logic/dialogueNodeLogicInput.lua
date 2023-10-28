import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/storage/storageImplementation"


local ds<const> = dialogueSystem


class("DialogueNodeLogicInput", {}, ds).extends()


function ds.DialogueNodeLogicInput:init()
    self.actors = ds.StorageImplementation()
    self.blackboards = ds.StorageImplementation()
end
