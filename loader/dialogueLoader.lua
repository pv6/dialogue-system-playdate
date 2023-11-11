import "CoreLibs/object"

import "DialogueSystem/dialogueSystem"

import "DialogueSystem/storage/storage"
import "DialogueSystem/storage/storageItem"

import "DialogueSystem/dialogue/dialogue"

import "DialogueSystem/dialogue/dialogueNode"
import "DialogueSystem/dialogue/implementedNodes/rootDialogueNode"
import "DialogueSystem/dialogue/implementedNodes/hearDialogueNode"
import "DialogueSystem/dialogue/implementedNodes/sayDialogueNode"
import "DialogueSystem/dialogue/implementedNodes/referenceDialogueNode"

import "DialogueSystem/dialogue/logic/dialogueNodeLogic"
import "DialogueSystem/dialogue/logic/dialogueFlag"
import "DialogueSystem/dialogue/logic/implementedFlags/blackboardDialogueFlag"
import "DialogueSystem/dialogue/logic/implementedFlags/visitedNodeDialogueFlag"


local ds<const> = dialogueSystem
local table<const> = table


class("DialogueLoader", {}, ds).extends()


function ds.DialogueLoader:init()
    self.dialogue = nil
end


function ds.DialogueLoader:load(path)
    local packedDialogue<const> = json.decodeFile(path)
    return self:unpack(packedDialogue)
end


function ds.DialogueLoader:unpack(packedDialogue)
    assert(packedDialogue["__type"] == "Dialogue")

    local dialogue<const> = ds.Dialogue()
    self.dialogue = dialogue

    dialogue.actors = self:unpackStorage(packedDialogue["actors"])
    for _, id in ipairs(dialogue.actors:ids()) do
        dialogue.actors._data[id] = self:unpackStorageItem(dialogue.actors._data[id])
    end
    dialogue.actors:setData(dialogue.actors._data)

    local localBlackboard<const> = self:unpackStorage(packedDialogue["local_blackboard"])
    dialogue.blackboards = self:unpackStorage(packedDialogue["blackboards"])
    for _, id in ipairs(dialogue.blackboards:ids()) do
        dialogue.blackboards._data[id] = self:unpackResourceReference(dialogue.blackboards._data[id], localBlackboard)
    end
    dialogue.blackboards:setData(dialogue.blackboards._data)

    dialogue:setRootNode(self:unpackNode(packedDialogue["root_node"]))

    dialogue.comment = packedDialogue["comment"]
    dialogue.description = packedDialogue["description"]

    dialogue.maxId = packedDialogue["max_id"]
    dialogue.editorVersion = packedDialogue["editor_version"]

    self.dialogue = nil

    return dialogue
end


function ds.DialogueLoader:unpackNode(packedNode)
    local node

    local type<const> = packedNode["__type"]

    if type == "RootDialogueNode" then
        node = ds.RootDialogueNode()
    elseif type == "HearDialogueNode" then
        node = ds.HearDialogueNode()
        node.text = packedNode["text"]
        node.tags = self:unpackStorage(packedNode["tags"])
        node.speaker = packedNode["speaker"] and self:unpackStorageItem(packedNode["speaker"], self.dialogue.actors) or nil
        node.listener = packedNode["listener"] and self:unpackStorageItem(packedNode["listener"], self.dialogue.actors) or nil
    elseif type == "SayDialogueNode" then
        node = ds.SayDialogueNode()
        node.text = packedNode["text"]
        node.tags = self:unpackStorage(packedNode["tags"])
        node.speaker = packedNode["speaker"] and self:unpackStorageItem(packedNode["speaker"], self.dialogue.actors) or nil
        node.listener = packedNode["listener"] and self:unpackStorageItem(packedNode["listener"], self.dialogue.actors) or nil
    elseif type == "ReferenceDialogueNode" then
        node = ds.ReferenceDialogueNode()
        node.referencedNodeId = packedNode["referenced_node_id"]
        local packedJumpTo<const> = packedNode["jump_to"]
        if packedJumpTo == "START_OF_NODE" then
            node.jumpTo = ds.ReferenceDialogueNode.jumpToType.startOfNode
        else
            node.jumpTo = ds.ReferenceDialogueNode.jumpToType.endOfNode
        end
    else
        node = ds.DialogueNode()
    end

    node.id = packedNode["id"]
    node.comment = packedNode["comment"]

    node.actionLogic = self:unpackLogic(packedNode["action_logic"])
    node.conditionLogic = self:unpackLogic(packedNode["condition_logic"])

    local packedChildren<const> = packedNode["children"]
    for i, packedChild in ipairs(packedChildren) do
        table.insert(node.children, self:unpackNode(packedChild))
    end

    return node
end


function ds.DialogueLoader:unpackStorage(packedStorage)
    assert(packedStorage["__type"] == "Storage")
    storage = ds.Storage(packedStorage["data"])
    return storage
end


function ds.DialogueLoader:unpackLogic(packedLogic)
    assert(packedLogic["__type"] == "DialogueNodeLogic")

    local logic<const> = ds.DialogueNodeLogic()

    local packedFlags<const> = packedLogic["flags"]
    for i, packedFlag in ipairs(packedFlags) do
        table.insert(logic.flags, self:unpackFlag(packedFlag))
    end

    local packedAutoFlags<const> = packedLogic["auto_flags"]
    for i, packedFlag in ipairs(packedAutoFlags) do
        table.insert(logic.autoFlags, self:unpackFlag(packedFlag))
    end

    logic.script = packedLogic["script"]

    logic.useFlags = packedLogic["use_flags"]
    logic.useScript = packedLogic["use_script"]

    return logic
end


function ds.DialogueLoader:unpackFlag(packedFlag)
    local flag
   
    local type<const> = packedFlag["__type"]

    if type == "BlackboardDialogueFlag" then
        flag = ds.BlackboardDialogueFlag()
        flag.blackboardField = self:unpackStorageItem(packedFlag["blackboard_field"], self.dialogue.blackboards)
    elseif type == "VisitedNodeDialogueFlag" then
        flag = ds.VisitedNodeDialogueFlag()
        flag.nodeId = packedFlag["node_id"]
    else
        flag = ds.DialogueFlag()
    end

    flag.value = packedFlag["value"]

    return flag
end


function ds.DialogueLoader:unpackStorageItem(packedStorageItem, localStorage)
    assert(packedStorageItem["__type"] == "StorageItem")

    local storageItem<const> = ds.StorageItem()
    storageItem.storageId = packedStorageItem["storage_id"]
    storageItem.storage = self:unpackResourceReference(packedStorageItem["storage_reference"], localStorage)

    return storageItem
end


function ds.DialogueLoader:unpackResourceReference(packedResourceReference, localResource)
    local resource

    if packedResourceReference["__type"] == "DirectResourceReference" then
        resource = localResource
    elseif packedResourceReference["__type"] == "ExternalResourceReference" then
        -- TODO: external resources
        resource = nil
    elseif packedResourceReference["__type"] == "StorageItemResourceReference" then
        local storageItem = self:unpackStorageItem(packedResourceReference["storage_item"], localResource)
        resource = storageItem:getValue()
    end

    return resource
end
