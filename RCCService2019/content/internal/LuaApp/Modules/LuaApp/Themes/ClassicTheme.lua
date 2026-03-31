local CorePackages = game:GetService("CorePackages")
local Color = require(CorePackages.AppTempCommon.Common.Color)
local Colors = require(script.Parent.Colors)
local ButtonState = require(script.Parent.Parent.Enum.ButtonState)
local FormFactor = require(script.Parent.Parent.Enum.FormFactor)

local theme = {
	Name = "classic",

	Color = {
		Background = Colors.Gray4,
	},

	ContextPrimaryButton = {
		Color = Colors.Green,
		Transparency = 0,
		DisabledColor = Colors.Green,
		DisabledTransparency = 0.5,
		LoadingTransparency = 0.5,
		OnPressColor = Colors.Green,
		OnPressTransparency = 0.5,
		Text = {
			Color = Colors.White,
			Transparency = 0,
		},
		Border = {
			Hidden = true,
		},
	},

	SystemPrimaryButton = {
		Color = Colors.Black,
		Transparency = 0,
		DisabledColor = Colors.Black,
		DisabledTransparency = 0.5,
		LoadingTransparency = 0.5,
		OnPressColor = Colors.Black,
		OnPressTransparency = 0.5,
		Text = {
			Color = Colors.White,
			Transparency = 0,
		},
		Border = {
			Hidden = true,
		},
		ShimmerAnimation = {
			Transparency = 0.65,
			Image = "rbxasset://textures/ui/LuaApp/graphic/shimmer_darkTheme.png",
			AspectRatio = 219 / 250,
		},
	},

	SecondaryButton = {
		Color = Colors.BluePrimary,
		Transparency = 0,
		HoverColor = Colors.BlueHover,
		OnPressColor = Colors.BlueHover,
		OnPressTransparency = 0,
		DisabledColor = Colors.BlueDisabled,
		DisabledTransparency = 0,
		Text = {
			Color = Colors.White,
			Transparency = 0,
		},
		Border = {
			Hidden = true,
		},
	},

	IconButton = {
		Fill = {
			Off = {
				Color = Colors.Black,
				Transparency = 0.9,
			},
			On = {
				Color = Colors.Black,
				Transparency = 1.0,
			},
			OnPress = {
				Color = Colors.Black,
				Transparency = 0.95,
			},
			Loading = {
				Color = Colors.Black,
				Transparency = 0.9,
			},
			Disabled = {
				Color = Colors.Black,
				Transparency = 0.95,
			}
		},
		Border = {
			Off = {
				Color = Colors.Black,
				Transparency = 0.5,
			},
			On = {
				Color = Colors.Black,
				Transparency = 0.5,
			},
			OnPress = {
				Color = Colors.Black,
				Transparency = 0.75,
			},
			Loading = {
				Color = Colors.Black,
				Transparency = 0.5,
			},
			Disabled = {
				Color = Colors.Black,
				Transparency = 0.75,
			}
		},
		Icon = {
			Off = {
				Color = Colors.Black,
				Transparency = 0.5,
			},
			On = {
				Color = Colors.Green,
				Transparency = 0.0,
			},
			OnPress = {
				Color = Colors.Green,
				Transparency = 0.5,
			},
			Loading = {
				Color = Colors.Black,
				Transparency = 0.5,
			},
			Disabled = {
				Color = Colors.Black,
				Transparency = 0.5,
			}
		},
	},

	EmptyStatePage = {
		ErrorMessage = {
			Color = Colors.Gray3,
		},
	},

	RetryButton = {
		Color = Colors.Gray1,
		DisabledColor = Colors.Gray3,
		DisabledTransparency = 0,
	},

	ShimmerAnimation = {
		Transparency = 0,
		Image = "rbxasset://textures/ui/LuaApp/graphic/shimmer_lightTheme.png",
		AspectRatio = 219 / 250,
	},

	ShimmerPanel = {
		Color = Colors.Alabaster,
		Transparency = 0.5,
	},

	ContextualMenu = {
		Cells = {
			Icon = {
				Color = Colors.Gray1,
				OnColor = Colors.Green,
				Transparency = 0.5,
				OnTransparency = 0,
				DisabledTransparency = 0.5,
			},
			Content = {
				Color = Colors.Gray1,
				DisabledColor = Colors.Gray1,
				DisabledTransparency = 0.5,
			},
			Background = {
				OnPressColor = Colors.Black,
				OnPressTransparency = 0.9,
			},
		},
		Background = {
			Color = Colors.White,
		},
		Title = {
			Color = Colors.Black,
			Transparency = 0,
			DisabledTransparency = 0.5,
		},
		Divider = {
			Color = Colors.Gray4,
		},
		Cancel = {
			Color = Colors.Gray1,
		},
		DarkOverlay = {
			Color = Colors.Gray1,
			Transparency = 0.5,
		},
	},

	Authentication = {
		WeChatButton = {
			Text = {
				Font = Enum.Font.GothamBold,
				Size = 18,
				Color = Colors.White,
			},
			Background = {
				Color = Colors.Green2,
			},
		},
	},

	AlertWindow = {
		Background = {
			Color = Colors.White,
		},
		Title = {
			Color = Colors.Black,
			Font = Enum.Font.GothamBold,
		},
		Message = {
			Color = Colors.Gray1,
			Font = Enum.Font.Gotham,
		},
		Divider = {
			Color = Colors.Gray4,
		},
		Button = {
			Font = Enum.Font.Gotham,
		},
	},

	GameDetails = {
		Background = {
			Color = Colors.Black,
			Transparency = 0.3,
		},
		Text = {
			Font = Enum.Font.SourceSans,
			BoldFont = Enum.Font.SourceSansBold,
			Color = {
				Main = Colors.White,
				Secondary = Colors.Pumice,
			},
		},
		GameBasicStats = {
			Color = Colors.White,
			Transparency = 0.3,
			Font = Enum.Font.SourceSans,
		},
		GameInfoList = {
			DividerColor = Colors.Graphite,
			Cells = {
				Background = {
					Color = Colors.Black,
					Transparency = {
						Default = 1.0,
						Pressed = 0.7,
					}
				}
			}
		},
		Rating = {
			Background = {
				Color = Colors.White,
				Transparency = 0.7,
			},
		},
		Carousel = {
			Text = {
				Color = Colors.Flint,
			},
		},
		TopBar = {
			Icon = {
				Color = Colors.Slate,
			}
		},
		LoadingView = {
			BackgroundImage = {
				Image = "rbxasset://textures/ui/LuaApp/graphic/GameDetailsBackground/loadingBkg_base.jpg",
				Size = Vector2.new(500, 500),
				Tint = {
					Color = Colors.Ash,
					Transparency = 0.45,
				},
			},
		},
		SocialMediaButton = {
			Transparency = 0,
			OnPressTransparency = 0.5,
		},
	},

	GameMediaAccordion = {
		Item = {
			BackgroundColor = Colors.Flint,
			BackgroundTransparency = 0.5,
		},
		FakeItem = {
			Loading = {
				Color = Colors.Flint,
				BaseTransparency = 0.5,
				TransparencyStep = 0.25,
			},
			Loaded = {
				Color = Colors.White,
				BaseTransparency = 0.5,
				TransparencyStep = 0.25,
			},
		},
		VideoIconColor = Colors.White,
	},

	GameCard = {
		Background = {
			Color = Colors.White,
			Transparency = 0.0,
		},
		Sponsor = {
			Color = Colors.Gray3,
			TextColor = Colors.White,
			Font = Enum.Font.SourceSans,
		},
		Title = {
			Font = Enum.Font.SourceSans,
			Color = Colors.Gray1,
		},
		GameBasicStats = {
			Color = Colors.Gray2,
			Transparency = 0,
			Font = Enum.Font.SourceSans,
		},
	},

	ChatTopBar = {
		Background = {
			Color = Colors.ChatTopBarBluePressed,
			Transparency = 0.0,
		},
		Title = {
			Font = Enum.Font.SourceSans,
			Size = 23, -- FONT_SIZE_20
			Color = Colors.White,
		},
		Subtitle = {
			Font = Enum.Font.SourceSans,
			Size = 15, -- FONT_SIZE_12
			Color = Colors.White,
		}
	},

	AgreementPage = {
		Background = {
			Color = Colors.Slate,
		},
		Text = {
			Color = Colors.Pumice,
			Size = 16,
		}
	},

	BottomBar = {
		Background = {
			Color = Colors.White,
			Transparency = 0,
		},
		TopBorder = {
			Color = Colors.Gray4,
			Transparency = 0,
		},
	},

	BottomBarButton = {
		Icon = {
			Off = {
				Color = Colors.Flint,
				Transparency = 0.5,
			},
			On = {
				Color = Colors.Flint,
				Transparency = 0,
			},
		},
		Title = {
			Font = Enum.Font.GothamSemibold,
			Size = 14,
		},
	},

	NumericalBadge = {
		Text = {
			Font = Enum.Font.GothamSemibold,
			Color = Colors.White,
			Size = 12,
		},
		Border = {
			Default = {
				Color = Colors.Red,
				Transparency = 1,
			},
			AppChrome = {
				Color = Colors.Red,
				Transparency = 1,
			},
		},
		Inner = {
			Color = Colors.Red,
			Transparency = 0,
		},
	},

	MorePage = {
		Background = {
			Color = Colors.Gray6,
			Transparency = 0,
		},
		List = {
			Background = {
				Color = Colors.White,
				Transparency = 0,
			},
			Divider = {
				Color = Colors.Gray4,
				Transparency = 0,
			},
		},
		Button = {
			Background = {
				Default = {
					Color = Colors.White,
					Transparency = 0,
				},
				Pressed = {
					Color = Colors.Gray5,
					Transparency = 0,
				},
			},
			Text = {
				Font = Enum.Font.SourceSans,
				Size = 23,
				Color = Colors.Black,
				Transparency = 0,
			},
			Icon = {
				Color = Colors.White,
				Transparency = 0,
			},
			RightImage = {
				Color = Colors.White,
				Transparency = 0,
			},
		},
		Footer = {
			Font = Enum.Font.SourceSans,
			Size = 18,
			Color = Colors.Black,
			Transparency = 0,
		},
	},

	EventsPage = {
		Text = {
			Font = Enum.Font.SourceSans,
			Size = 23,
			Color = Colors.Gray3,
			Transparency = 0,
		},
	},

	PremiumIcon = {
		Color = Colors.Black,
		Transparency = 0,
	},
}

theme.Main = {
	Background = {
		Color = Colors.Gray4,
	},
	Foreground = {
		Color = Colors.White,
	},
	TitleText = {
		Color = Colors.Gray1,
	},
	BodyText = {
		Font = Enum.Font.SourceSans,
		Color = Colors.Gray2,
	},
	Divider = {
		Color = Colors.Gray4,
	},
}

theme.TopBar = {
	Bar = {
		Color = Colors.BluePressed,
	},
	Background = {
		Color = Colors.BluePressed,
	},
	DarkOverlay = {
		Color = Colors.Black,
		Transparency = 0.3,
	},
	Text = {
		Color = Colors.White,
		Transparency = 0,
	},
	Icon = {
		Color = Colors.White,
	},
	Badge = {
		Color = Colors.Red,
	},
	BadgeText = {
		Color = Colors.White,
	},
	Separator = {
		Color = Colors.BluePressed,
	},
}

theme.SearchBar = {
	Background = {
		Color = Colors.White,
	},
	Placeholder = {
		Color = Colors.Gray2,
	},
	Content = {
		Color = Colors.Gray2,
	},
}

theme.DropDownList =
{
	[ButtonState.Default] = {
		Background = {
			Color = Colors.White,
		},
		Content = {
			Color = Colors.Gray2,
		},
		Border = {
			Color = Colors.Black,
		},
	},
}

theme.ListPickerItem = {
	[ButtonState.Default] = {
		Background = {
			Color = Colors.White,
		},
		Content = {
			Color = Colors.Gray2,
			Transparency = 0,
		},
		Separator = {
			Color = Colors.Gray4,
		},
	},
	[ButtonState.Pressed] = {
		Background = {
			Color = Color3.fromRGB(242, 242, 242),
		},
	},
}

theme.Buttons = {}
theme.Buttons.CtaButton = {
	TextFont = Enum.Font.SourceSans,
	[ButtonState.Default] = {
		Background = {
			Color = Color.Color3FromHex(0x02B757),
			Transparency = 0,
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
			Transparency = 0,
		},
	},

	[ButtonState.Pressed] = {
		Background = {
			Color = Color.Color3FromHex(0x3FC679),
		},
	},

	[ButtonState.Hover] = {
		Background = {
			Color = Color.Color3FromHex(0x3FC679),
		},
	},

	[ButtonState.Disabled] = {
		Background = {
			Color = Color.Color3FromHex(0xA3E2BD),
		},
	},
}

theme.Buttons.GrowthButton = theme.Buttons.CtaButton

theme.Buttons.SecondaryButton = {
	TextFont = Enum.Font.SourceSans,
	[ButtonState.Default] = {
		Background = {
			Color = Color.Color3FromHex(0x00A2FF),
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
			Transparency = 0,
		},
	},

	[ButtonState.Pressed] = {
		Background = {
			Color = Color.Color3FromHex(0x32B5FF),
		},
	},

	[ButtonState.Hover] = {
		Background = {
			Color = Color.Color3FromHex(0x32B5FF),
		},
	},

	[ButtonState.Disabled] = {
		Background = {
			Color = Color.Color3FromHex(0x99DAFF),
		},
	},
}

theme.Buttons.ControlButton = {
	TextFont = Enum.Font.SourceSans,
	[ButtonState.Default] = {
		Background = {
			Color = Color.Color3FromHex(0xFFFFFF),
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Color.Color3FromHex(0x191919),
			Transparency = 0,
		},
	},

	[ButtonState.Disabled] = {
		Content = {
			Color = Color.Color3FromHex(0xB8B8B8),
			Transparency = 0.5,
		},
	},
}

theme.Buttons.AlertButton = {
	TextFont = Enum.Font.SourceSans,
	[ButtonState.Default] = {
		Background = {
			Color = Color.Color3FromHex(0xD86868),
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
			Transparency = 0,
		},
	},

	[ButtonState.Hover] = {
		Background = {
			Color = Color.Color3FromHex(0xE27676),
		},
	},
}

theme.Buttons.BuyButtons = {
	TextFont = Enum.Font.SourceSans,
	[ButtonState.Default] = {
		Background = {
			Color = Color.Color3FromHex(0xFFFFFF),
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Color.Color3FromHex(0x191919),
			Transparency = 0,
		},
	},

	[ButtonState.Pressed] = {
		Background = {
			Color = Color.Color3FromHex(0x3FC679),
		},
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
		},
	},

	[ButtonState.Hover] = {
		Background = {
			Color = Color.Color3FromHex(0x3FC679),
		},
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
		},
	},

	[ButtonState.Disabled] = {
		Content = {
			Color = Color.Color3FromHex(0xFFFFFF),
			Transparency = 0.5,
		},
	},
}

theme.Buttons.ToggleButton =
{
	TextFont = Enum.Font.SourceSans,
	On = {
		[ButtonState.Default] = {
			Background = {
				Color = Color.Color3FromHex(0xFFFFFF),
			},
			Border = {
				Transparency = 1,
			},
			Content = {
				Color = Color.Color3FromHex(0x191919),
				Transparency = 0,
			},
		},

		[ButtonState.Pressed] = {
			Background = {
				Color = Color.Color3FromHex(0xD8D8D8),
			},
		},
	},
	Off = {
		[ButtonState.Default] = {
			Background = {
				Color = Color.Color3FromHex(0xFFFFFF),
			},
			Border = {
				Transparency = 1,
			},
			Content = {
				Color = Color.Color3FromHex(0x191919),
				Transparency = 0,
			},
		},

		[ButtonState.Pressed] = {
			Background = {
				Color = Color.Color3FromHex(0xD8D8D8),
			},
		},
	}
}

theme.Buttons.AgreementButton = {
	Text = {
		Font = Enum.Font.Gotham,
		Color = Colors.Pumice,
	}
}

theme.Widget = {
	Header = {
		Text = {
			Font = Enum.Font.GothamBold,
			Color = Colors.White,
		}
	},
	Background = {
		[FormFactor.UNKNOWN] = {
			Color = Colors.Carbon,
			Transparency = 0,
		},
		[FormFactor.WIDE] = {
			Color = Colors.Carbon,
			Transparency = 0,
		},
		[FormFactor.COMPACT] = {
			Color = Colors.Black,
			Transparency = 0.3,
		},
	},
	ContentText = {
		Color = Colors.Pumice,
		Font = Enum.Font.SourceSans,
	},
}

theme.IconCards =
{
	Text = {
		Color = Colors.Pumice,
		Font = Enum.Font.SourceSans,
	}
}

theme.ScrollingFrameWithScrollBar = {
	ScrollBar = {
		Color = Colors.Gray3,
		Transparency = 0.7,
	},
}

return theme
