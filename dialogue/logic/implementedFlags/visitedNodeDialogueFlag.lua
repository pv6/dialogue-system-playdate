import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/dialogueFlag"
import "DialogueSystem/storage/storageItem"
import "DialogueSystem/dialogue/dialogueNode"


local ds<const> = dialogueSystem


class("VisitedDialogueFlag", {}, ds).extends(ds.DialogueFlag)


function ds.VisitedDialogueFlag:init()
    ds.VisitedDialogueFlag.super.init(self)

    self.nodeId = ds.DialogueNode.dummyId
end


-- virtual
function ds.VisitedDialogueFlag:check(input)
    return input.blackboards:get("local"):get(string.format("auto_visited_node_%d", self.nodeId)) == self.value
end
