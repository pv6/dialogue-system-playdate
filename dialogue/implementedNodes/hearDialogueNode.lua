import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/textDialogueNode"


local ds<const> = dialogueSystem


class("HearDialogueNode", {}, ds).extends(ds.TextDialogueNode)


function ds.HearDialogueNode :init()
    ds.HearDialogueNode.super.init(self)
end


function ds.HearDialogueNode:__tostring()
    return string.format("Hear Node %d", self.id)
end
