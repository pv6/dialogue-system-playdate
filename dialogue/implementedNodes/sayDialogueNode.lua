import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/textDialogueNode"


local ds<const> = dialogueSystem


class("SayDialogueNode", {}, ds).extends(ds.TextDialogueNode)


function ds.SayDialogueNode:init()
    ds.SayDialogueNode.super.init(self)
end


function ds.SayDialogueNode:__tostring()
    return string.format("Say Node %d", self.id)
end
