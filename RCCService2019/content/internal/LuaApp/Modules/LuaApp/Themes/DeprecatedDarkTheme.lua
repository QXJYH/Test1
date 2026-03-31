local Colors = require(script.Parent.Colors)
local ButtonState = require(script.Parent.Parent.Enum.ButtonState)
local FormFactor = require(script.Parent.Parent.Enum.FormFactor)

local theme = {
	Name = "dark",

	Color = {
		Background = Colors.Slate,
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
		Color = Colors.White,
		Transparency = 0,
		DisabledColor = Colors.White,
		DisabledTransparency = 0.5,
		LoadingTransparency = 0.5,
		OnPressColor = Colors.White,
		OnPressTransparency = 0.5,
		Text = {
			Color = Colors.Black,
			Transparency = 0,
		},
		Border = {
			Hidden = true,
		},
		ShimmerAnimation = {
			Transparency = 0,
			Image = "rbxasset://textures/ui/LuaApp/graphic/shimmer_lightTheme.png",
			AspectRatio = 219 / 250,
		},
	},

	SecondaryButton = {
		Color = Colors.Pumice,
		Transparency = 1,
		HoverColor = Colors.White,
		OnPressColor = Colors.Pumice,
		OnPressTransparency = 0.5,
		DisabledColor = Colors.Pumice,
		DisabledTransparency = 0.5,
		Text = {
			Color = Colors.White,
			Transparency = 0.3,
		},
		Border = {
			Hidden = false,
			Color = Colors.White,
			Transparency = 0.3,
		},
	},

	IconButton = {
		Fill = {
			Off = {
				Color = Colors.White,
				Transparency = 0.7,
			},
			On = {
				Color = Colors.White,
				Transparency = 1.0,
			},
			OnPress = {
				Color = Colors.White,
				Transparency = 0.85,
			},
			Loading = {
				Color = Colors.White,
				Transparency = 0.7,
			},
			Disabled = {
				Color = Colors.White,
				Transparency = 0.85,
			}
		},
		Border = {
			Off = {
				Color = Colors.White,
				Transparency = 0.3,
			},
			On = {
				Color = Colors.White,
				Transparency = 0.3,
			},
			OnPress = {
				Color = Colors.White,
				Transparency = 0.85,
			},
			Loading = {
				Color = Colors.White,
				Transparency = 0.3,
			},
			Disabled = {
				Color = Colors.White,
				Transparency = 0.85,
			}
		},
		Icon = {
			Off = {
				Color = Colors.White,
				Transparency = 0.3,
			},
			On = {
				Color = Colors.Green,
				Transparency = 0.0,
			},
			OnPress = {
				Color = Colors.Green,
				Transparency = 0.7,
			},
			Loading = {
				Color = Colors.White,
				Transparency = 0.5,
			},
			Disabled = {
				Color = Colors.White,
				Transparency = 0.7,
			}
		},
	},

	EmptyStatePage = {
		ErrorMessage = {
			Color = Colors.Graphite,
		},
	},

	ShimmerAnimation = {
		Transparency = 0.65,
		Image = "rbxasset://textures/ui/LuaApp/graphic/shimmer_darkTheme.png",
		AspectRatio = 219 / 250,
	},

	ShimmerPanel = {
		Color = Colors.Flint,
		Transparency = 0.5,
	},

	ContextualMenu = {
		Cells = {
			Icon = {
				Color = Colors.White,
				OnColor = Colors.Green,
				Transparency = 0.3,
				OnTransparency = 0,
				DisabledTransparency = 0.5,
			},
			Content = {
				Color = Colors.White,
				DisabledColor = Colors.White,
				DisabledTransparency = 0.5,
			},
			Background = {
				OnPressColor = Colors.Black,
				OnPressTransparency = 0.7,
			},
		},
		Background = {
			Color = Colors.Flint,
		},
		Title = {
			Color = Colors.White,
			Transparency = 0,
			DisabledTransparency = 0.5,
		},
		Divider = {
			Color = Colors.Graphite,
		},
		Cancel = {
			Color = Colors.Pumice,
		},
		DarkOverlay = {
			Color = Colors.Black,
			Transparency = 0.7,
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
			Color = Colors.Flint,
		},
		Title = {
			Color = Colors.White,
			Font = Enum.Font.GothamBold,
		},
		Message = {
			Color = Colors.Pumice,
			Font = Enum.Font.Gotham,
		},
		Divider = {
			Color = Colors.Graphite,
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
				Color = Colors.White,
			},
		},
		TopBar = {
			Icon = {
				Color = Colors.White,
			}
		},
		LoadingView = {
			BackgroundImage = {
				Image = "rbxasset://textures/ui/LuaApp/graphic/GameDetailsBackground/loadingBkg_base.jpg",
				Size = Vector2.new(500, 500),
				Tint = {
					Color = Colors.Obsidian,
					Transparency = 0.2,
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
			Color = Colors.Flint,
			Transparency = 0.0,
		},
		Sponsor = {
			Color = Colors.Graphite,
			TextColor = Colors.White,
			Font = Enum.Font.SourceSans,
		},
		Title = {
			Font = Enum.Font.SourceSans,
			Color = Colors.White,
		},
		GameBasicStats = {
			Color = Colors.White,
			Transparency = 0.3,
			Font = Enum.Font.SourceSans,
		},
	},
	ChatTopBar = {
		Background = {
			Color = Colors.ChatTopBarSlate,
			Transparency = 0.0,
		},
		Title = {
			Font = Enum.Font.SourceSans,
			Size = 22,
			Color = Colors.White,
		},
		Subtitle = {
			Font = Enum.Font.SourceSans,
			Size = 14,
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
			Color = Colors.Carbon,
			Transparency = 0,
		},
		TopBorder = {
			Color = Colors.Graphite,
			Transparency = 0,
		},
	},

	BottomBarButton = {
		Icon = {
			Off = {
				Color = Colors.White,
				Transparency = 0.5,
			},
			On = {
				Color = Colors.White,
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
			Color = Colors.Slate,
			Size = 12,
		},
		Border = {
			Default = {
				Color = Colors.Slate,
				Transparency = 1,
			},
			AppChrome = {
				Color = Colors.Slate,
				Transparency = 0,
			},
		},
		Inner = {
			Color = Colors.White,
			Transparency = 0,
		},
	},

	MorePage = {
		Background = {
			Color = Colors.Slate,
			Transparency = 0,
		},
		List = {
			Background = {
				Color = Colors.Flint,
				Transparency = 0,
			},
			Divider = {
				Color = Colors.Graphite,
				Transparency = 0,
			},
		},
		Button = {
			Background = {
				Default = {
					Color = Colors.Flint,
					Transparency = 0,
				},
				Pressed = {
					Color = Colors.Slate,
					Transparency = 0,
				},
			},
			Text = {
				Font = Enum.Font.GothamSemibold,
				Size = 19,
				Color = Colors.Pumice,
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
			Color = Colors.Pumice,
			Transparency = 0,
		},
	},

	EventsPage = {
		Text = {
			Font = Enum.Font.Gotham,
			Size = 19,
			Color = Colors.White,
			Transparency = 0.3,
		},
	},

	PremiumIcon = {
		Color = Colors.White,
		Transparency = 0,
	},
}

theme.RetryButton = theme.SecondaryButton

theme.Main = {
	Background = {
		Color = Colors.Slate,
	},
	Foreground = {
		Color = Colors.Flint,
	},
	TitleText = {
		Color = Colors.White,
	},
	BodyText = {
		Font = Enum.Font.Gotham,
		Color = Colors.Pumice,
	},
	Divider = {
		Color = Colors.Graphite,
	},
}

theme.TopBar = {
	Bar = {
		Color = theme.Main.Background.Color,
	},
	Background = {
		Color = theme.Main.Background.Color,
	},
	DarkOverlay = {
		Color = Colors.Black,
		Transparency = 0.3,
	},
	Text = {
		Color = theme.Main.TitleText.Color,
		Transparency = 0,
	},
	Icon = {
		Color = theme.Main.BodyText.Color,
	},
	Badge = {
		Color = Colors.White,
	},
	BadgeText = {
		Color = Colors.Slate,
	},
	Separator = {
		Color = Colors.Obsidian,
	},
}

theme.SearchBar = {
	Background = {
		Color = Colors.Black,
	},
	Placeholder = {
		Color = Colors.Flint,
	},
	Content = {
		Color = Colors.Pumice,
	},
}

theme.DropDownList =
{
	[ButtonState.Default] = {
		Background = {
			Color = theme.Main.Background.Color,
			Transparency = 0.3,
		},
		Content = {
			Color = theme.Main.BodyText.Color,
			Transparency = 0.3,
		},
		Border = {
			Color = Colors.Smoke,
		},
	},
	[ButtonState.Pressed] = {
		Background = {
			Transparency = 0.5,
		},
		Content = {
			Transparency = 0.5,
		},
	},
}

theme.ListPickerItem = {
	[ButtonState.Default] = {
		Background = {
			Color = Colors.Flint,
			Transparency = 0.5,
		},
		Content = {
			Color = Colors.Pumice,
			Transparency = 0,
		},
		Separator = {
			Color = Colors.Flint,
		},
	},
	[ButtonState.Hover] = {
		Background = {
			Color = Colors.Graphite,
		},
		Content = {
			Color = Colors.White,
		},
	},
	[ButtonState.Pressed] = {
		Background = {
			Color = Colors.Black,
			Transparency = 0.7,
		},
		Content = {
			Color = Colors.White,
			Transparency = 0.7,
		},
	},
	[ButtonState.Disabled] = {
		Content = {
			Color = Colors.White,
			Transparency = 0.7,
		},
	},
}

theme.Buttons = {}
theme.Buttons.CtaButton = {
	TextFont = Enum.Font.SourceSansBold,
	[ButtonState.Default] = {
		Background = {
			Color = Colors.White,
			Transparency = 0,
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Colors.Slate,
			Transparency = 0,
		},
	},

	[ButtonState.Pressed] = {
		Background = {
			Transparency = 0.5,
		},
		Content = {
			Transparency = 0.5,
		},
	},

	[ButtonState.Disabled] = {
		Background = {
			Transparency = 0.5,
		},
		Content = {
			Transparency = 0.5,
		},
	},
}

theme.Buttons.GrowthButton = {
	TextFont = Enum.Font.SourceSansBold,
	[ButtonState.Default] = {
		Background = {
			Color = Colors.Green,
			Transparency = 0,
		},
		Border = {
			Transparency = 1,
		},
		Content = {
			Color = Colors.White,
			Transparency = 0,
		},
	},

	[ButtonState.Pressed] = {
		Background = {
			Transparency = 0.5,
		},
		Content = {
			Transparency = 0.5,
		},
	},

	[ButtonState.Disabled] = {
		Background = {
			Transparency = 0.5,
		},
		Content = {
			Transparency = 0.5,
		},
	},
}

theme.Buttons.SecondaryButton = {
	TextFont = Enum.Font.SourceSansBold,
	[ButtonState.Default] = {
		Background = {
			Transparency = 1,
		},
		Border = {
			Color = Colors.White,
			Transparency = 0.3,
		},
		Content = {
			Color = Colors.White,
			Transparency = 0.3,
		}
	},

	[ButtonState.Pressed] = {
		Border = {
			Transparency = 0.65,
		},
		Content = {
			Transparency = 0.65,
		}
	},

	[ButtonState.Hover] = {
		Border = {
			Transparency = 0,
		},
		Content = {
			Transparency = 0,
		}
	},

	[ButtonState.Disabled] = {
		Border = {
			Transparency = 0.65,
		},
		Content = {
			Transparency = 0.65,
		}
	},
}

--NOTE: remove these when classic theme and FFlagLuaRetheme are removed
theme.Buttons.ControlButton = theme.Buttons.SecondaryButton
theme.Buttons.BuyButton = theme.Buttons.SecondaryButton

theme.Buttons.AlertButton = {
	TextFont = Enum.Font.SourceSansBold,
	[ButtonState.Default] = {
		Background = {
			Transparency = 1,
		},
		Border = {
			Color = Colors.Red,
			Transparency = 0.3,
		},
		Content = {
			Color = Colors.Red,
			Transparency = 0.3,
		}
	},

	[ButtonState.Pressed] = {
		Border = {
			Transparency = 0.65,
		},
		Content = {
			Transparency = 0.65,
		}
	},

	[ButtonState.Hover] = {
		Border = {
			Transparency = 0,
		},
		Content = {
			Transparency = 0,
		}
	},

	[ButtonState.Disabled] = {
		Border = {
			Transparency = 0.65,
		},
		Content = {
			Transparency = 0.65,
		}
	},
}

theme.Buttons.ToggleButton =
{
	TextFont = Enum.Font.SourceSans,
	On = {
		[ButtonState.Default] = {
			Background = {
				Transparency = 1,
			},
			Border = {
				Color = Colors.White,
				Transparency = 0.3,
			},
			Content = {
				Color = Colors.Green,
				Transparency = 0.3,
			}
		},

		[ButtonState.Pressed] = {
			Border = {
				Transparency = 0.65,
			},
			Content = {
				Transparency = 0.65,
			}
		},

		[ButtonState.Hover] = {
			Border = {
				Transparency = 0,
			},
			Content = {
				Transparency = 0,
			}
		},

		[ButtonState.Disabled] = {
			Border = {
				Transparency = 0.65,
			},
			Content = {
				Transparency = 0.65,
			}
		},
	},
	Off = theme.Buttons.SecondaryButton,
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
		Font = Enum.Font.Gotham,
	},
}

theme.IconCards =
{
	Text = {
		Color = Colors.Pumice,
		Font = Enum.Font.Gotham,
	}
}

theme.ScrollingFrameWithScrollBar = {
	ScrollBar = {
		Color = Colors.White,
		Transparency = 0.7,
	},
}

return theme
