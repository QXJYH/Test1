-- Model.lua
-- Interface for Model-factory factories

--[[
	Model is designed to provide a way to easily describe and assert
	model interfaces.
]]

--[[
	Calling `extend` will generate a model class with these members:

		. requiredProps(mapOfPropTyping)
			* Declares what properties the model class can accept when using `fromProps`

		.fromProps(mapOfProps)
			* Creates a new model from the model class with provided properties.

		.is(any)
			* Objects created from the model class will return true, otherwise false.
]]

--[[
	Previously when defining a Model, one would set up a base constructor
	that stashes model-type information into its state:

		local myNewModel = {}
		function myNewModel.new()
			return {
				type = "myNewModelType",
			}
		end

	Then from there, one would typically compose a new detailed constructor
	that composes itself with this plain base constructor:

		function myNewModel.fromTheseArgs(arg1, arg2)
			local self = myNewModel.new()
			self.arg1 = arg1
			self.arg2 = arg2
			return self
		end

	However this can lead to multiple different flavors of constructors depending on the
	purpose and can be tricky for a reader to determine the interface of this model's fields.

	Now we can declaratively define our models in a way that is easy to parse as a reader:

		local myNewModel = Model.extend("myNewModel")
		myNewModel.requiredProps({
			arg1 = "number",
			arg2 = "string",
		})

		local mockModel1 = myNewModel.fromProps({
			arg1 = 100,
			arg2 = "user",
		})
]]

local ModelImpl = script.Parent.ModelImpl

return {
	extend = require(ModelImpl.extend),
	requiredProps = require(ModelImpl.requiredProps),
}