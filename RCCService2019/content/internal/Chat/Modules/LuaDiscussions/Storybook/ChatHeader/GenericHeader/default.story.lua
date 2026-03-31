local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local GenericHeader = require(Components.ChatHeader.GenericHeader)

local foo = Roact.createElement("TextLabel", {
    Size = UDim2.new(0,100,0.5,0),
    BackgroundColor3 = Color3.fromRGB(200, 30, 60),
    Text = "left",
})

local bar = Roact.createElement("TextLabel", {
    Size = UDim2.new(1,0,0.6,0),
    Text = "center",
})

local baz = Roact.createElement("TextLabel", {
    Size = UDim2.new(0,50,0,50),
    Text = "right",
})

local headerType = GenericHeader("test", {foo1=foo, foo2=foo}, {bar=bar}, {baz=baz})
return Roact.createElement(headerType, {
    ElementSpacing = 20,
    BackgroundColor3 = Color3.fromRGB(200, 30, 60),
    BackgroundTransparency = 0.9,
    Size = UDim2.new(1, -10, 0, 200),
    Position = UDim2.new(0, 5, 0, 5),
})
