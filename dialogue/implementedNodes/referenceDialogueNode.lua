import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/dialogueNode"


local ds<const> = dialogueSystem
local string<const> = string


class("ReferenceDialogueNode", {jumpToType = {startOfNode = 0, endOfNode = 1}}, ds).extends(ds.DialogueNode)


function ds.ReferenceDialogueNode :init()
    ds.ReferenceDialogueNode.super.init(self)
    self.jumpTo = self.jumpToType.startOfNode
    self.referencedNodeId = self.dummyId
end


function ds.ReferenceDialogueNode:__tostring()
    return string.format("Referenced Node %d", self.id)
end
