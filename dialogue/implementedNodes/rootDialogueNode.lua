import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/dialogueNode"


local ds<const> = dialogueSystem


class("RootDialogueNode", {}, ds).extends(ds.DialogueNode)


function ds.RootDialogueNode :init()
    ds.RootDialogueNode.super.init(self)
end


function ds.RootDialogueNode:__tostring()
    return string.format("Root Node %d", self.id)
end
