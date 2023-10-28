import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"
import "DialogueSystem/dialogue/logic/dialogueNodeLogic"


local ds<const> = dialogueSystem


class("DialogueNode", {dummyId = -1}, ds).extends()


function ds.DialogueNode:init()
    self.id = self.dummyId
    self.children = {}
    self.parentId = self.dummyId
    self.conditionLogic = ds.DialogueNodeLogic()
    self.actionLogic = ds.DialogueNodeLogic()
    self.comment = ""
end


function ds.DialogueNode:__tostring()
    return string.format("Node %d", self.id)
end


function ds.DialogueNode:addChild(node, position)
    if not position then
        table.insert(self.children, node)
    else
        table.insert(self.children, position, node)
    end
    node.parentId = self.id
end


function ds.DialogueNode:getChildPosition(childNode)
    for i = 1, #self.children do
        if self.children[i] == childNode then
            return i
        end
    end

    return -1
end
