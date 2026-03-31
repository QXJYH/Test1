local Colors = require(script.Parent.Colors)
local FormFactor = require(script.Parent.Parent.Enum.FormFactor)

local theme = {
	Color = {
		Background = Colors.Alabaster,
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
		Color = Colors.Smoke,
		Transparency = 1,
		HoverColor = Colors.Flint,
		OnPressColor = Colors.Smoke,
		OnPressTransparency = 0.5,
		DisabledColor = Colors.Smoke,
		DisabledTransparency = 0.5,
		Text = {
			Color = Colors.Black,
			Transparency = 0.5,
		},
		Border = {
			Hidden = false,
			Color = Colors.Black,
			Transparency = 0.5,
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
				Color = Colors.Flint,
				OnColor = Colors.Green,
				Transparency = 0.5,
				OnTransparency = 0,
				DisabledTransparency = 0.5,
			},
			Content = {
				Color = Colors.Flint,
				DisabledColor = Colors.Flint,
				DisabledTransparency = 0.5,
			},
			Background = {
				OnPressColor = Colors.Black,
				OnPressTransparency = 0.9,
			},
		},
		Background = {
			Color = Colors.Alabaster,
		},
		Title = {
			Color = Colors.Flint,
			Transparency = 0,
			DisabledTransparency = 0.5,
		},
		Divider = {
			Color = Colors.Pumice,
		},
		Cancel = {
			Color = Colors.Smoke,
		},
	},

	AlertWindow = {
		Background = {
			Color = Colors.Alabaster,
		},
		Title = {
			Color = Colors.Flint,
		},
		Message = {
			Color = Colors.Graphite,
		},
		Divider = {
			Color = Colors.Pumice,
		},
	},

	GameDetails = {
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
		Title = {
			Font = Enum.Font.SourceSans,
			Color = Colors.Flint,
		},
		GameBasicStats = {
			Color = Colors.Black,
			Transparency = 0.5,
			Font = Enum.Font.SourceSans,
		},
	},

	ChatTopBar = {
		Background = {
			Color = Colors.ChatTopBarWhite,
			Transparency = 0.0,
		},
		Title = {
			Font = Enum.Font.SourceSans,
			Size = 22,
			Color = Colors.Flint,
		},
		Subtitle = {
			Font = Enum.Font.SourceSans,
			Size = 14,
			Color = Colors.Flint,
		}
	},

	BottomBar = {
		Background = {
			Color = Colors.White,
			Transparency = 0,
		},
		TopBorder = {
			Color = Colors.Pumice,
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
				Color = Colors.White,
				Transparency = 1,
			},
			AppChrome = {
				Color = Colors.White,
				Transparency = 0,
			},
		},
		Inner = {
			Color = Colors.Flint,
			Transparency = 0,
		},
	},

	MorePage = {
		Background = {
			Color = Colors.Alabaster,
			Transparency = 0,
		},
		List = {
			Background = {
				Color = Colors.White,
				Transparency = 0,
			},
			Divider = {
				Color = Colors.Pumice,
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
					Color = Colors.Alabaster,
					Transparency = 0,
				},
			},
			Text = {
				Font = Enum.Font.GothamSemibold,
				Size = 19,
				Color = Colors.Smoke,
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
			Font = Enum.Font.GothamSemibold,
			Size = 12,
			Color = Colors.Smoke,
			Transparency = 0,
		},
	},

	EventsPage = {
		Text = {
			Font = Enum.Font.Gotham,
			Size = 19,
			Color = Colors.Black,
			Transparency = 0.5,
		},
	},

	PremiumIcon = {
		Color = Colors.Flint,
		Transparency = 0,
	},
}

theme.RetryButton = theme.SecondaryButton

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
		Color = Colors.Gray4,
		Font = Enum.Font.Gotham,
	}
}

theme.ScrollingFrameWithScrollBar = {
	ScrollBar = {
		Color = Colors.Black,
		Transparency = 0.7,
	},
}

return theme
