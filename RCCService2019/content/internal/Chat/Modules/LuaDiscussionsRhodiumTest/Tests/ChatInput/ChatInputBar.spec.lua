local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Modules = CoreGui.RobloxGui.Modules
local Rhodium = Modules.Rhodium

local Roact = require(CorePackages.Roact)
local Element = require(Rhodium.Element)
local XPath = require(Rhodium.XPath)

local ChatInputBar = require(Modules.LuaDiscussions.Components.ChatInput.ChatInputBar)
local mockStyle = require(Modules.LuaDiscussions.UnitTestHelpers.mockStyle)

return function()
    it("should trigger the callback with the given text when the button is pushed", function()
        local sentText
        local function onSend(text)
            sentText = text
        end

        local chatBarElement = Roact.createElement("ScreenGui", {}, {
            ChatInputBar = Roact.createElement(ChatInputBar, {
                onSend = onSend,
            })
        })

        local withStyle = mockStyle(chatBarElement)

        local instance = Roact.mount(withStyle, CoreGui, "TestRoot")
        local barPath = XPath.new("game.CoreGui.TestRoot.ChatInputBar")
        local textBox = Element.new(barPath:cat(XPath.new("textBox")))
        local button = Element.new(barPath:cat(XPath.new("sendButton")))

        expect(textBox:getRbxInstance()).to.be.ok()
        expect(button:getRbxInstance()).to.be.ok()

        local testString = "FOO"

        textBox:sendText(testString)
        wait(0)
        expect(sentText).never.to.be.ok()

        button:click()
        wait(0)
        expect(sentText).to.equal(testString)
        expect(textBox:getRbxInstance().Text).to.equal("")

        Roact.unmount(instance)
    end)
end