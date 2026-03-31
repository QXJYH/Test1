local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local FocusedTextbox = Roact.PureComponent:extend("FocusedTextbox")

function FocusedTextbox:init()
	self.TextboxRef = Roact:createRef()
end

function FocusedTextbox:render()
	local props = self.props
	props[Roact.Ref] = self.TextboxRef
	return Roact.createElement("TextBox",props)
end

function FocusedTextbox:didMount() 
	delay(0,function()
		--self.TextboxRef.current:CaptureFocus() --this is broken, frequently tries to crash studio
	end)
end

return FocusedTextbox