import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/dialogueNode"
import "DialogueSystem/storage/storage"


local ds<const> = dialogueSystem


class("TextDialogueNode", {}, ds).extends(ds.DialogueNode)


function ds.TextDialogueNode:init()
    ds.TextDialogueNode.super.init(self)
    self.text = ""
    self.tags = ds.Storage()
    self.speaker = nil
    self.listener = nil
end


function ds.TextDialogueNode:__tostring()
    return string.format("Text Node %d", self.id)
end
