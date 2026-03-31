local TransitionAnimation = require(script.Parent.Enum.TransitionAnimation)

local transitionMap = {
	[TransitionAnimation.SlideInFromRight] = "slideInFromRight",
	[TransitionAnimation.SlideInFromBottom] = "slideInFromBottom",
}

return function(transitionAnimation)
	return transitionMap[transitionAnimation]
end
