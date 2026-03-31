--to make ScriptAnalyzer Happy
describe = nil
step = nil
expect = nil
include = nil
-------------------------------
local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

local appRouter = XPath.new("game.CoreGui.App.AppContainer.AppRouter")
local homeScreen = appRouter:cat(XPath.new("Home"))
local topBar = homeScreen:cat(XPath.new("Contents.TopBar.TopBar"))
local verticalScrollingFrame = homeScreen:cat(XPath.new("Contents.Content.LoadingStateWrapper.scrollingFrame"))
local content = verticalScrollingFrame:cat(XPath.new("Content"))

local gamesScreen = appRouter:cat(XPath.new("Games"))

local moreScreen = appRouter:cat(XPath.new("More"))
local morePageContent = moreScreen:cat(XPath.new("Contents.Scroller.MorePageTable"))

local settingsScreen = appRouter:cat(XPath.new("Settings"))
local settingsPage = settingsScreen:cat(XPath.new("Contents"))
local settingsPageContent = settingsPage:cat(XPath.new("Scroller.SettingsPageList"))
local settingsPageTopBar = settingsPage:cat(XPath.new("TopBar.TopBar.NavBar"))

local aboutScreen = appRouter:cat(XPath.new("About"))
local aboutPage = aboutScreen:cat(XPath.new("Contents"))
local aboutPageContent = aboutPage:cat(XPath.new("Scroller.AboutPageList"))
local aboutPageTopBar = aboutPage:cat(XPath.new("TopBar.TopBar.NavBar"))

local eventsScreen = appRouter:cat(XPath.new("Events"))
local eventsPage = eventsScreen:cat(XPath.new("Contents"))
local eventsPageContent = eventsPage:cat(XPath.new("EventsContent"))
local eventsPageTopBar = eventsPage:cat(XPath.new("TopBar.TopBar.NavBar"))

local bottomBar = XPath.new("game.CoreGui.BottomBar")
local bottomBarFrame = bottomBar:cat(XPath.new("Background"))

local homeButton = bottomBarFrame:cat(XPath.new("ItemFrame1.Item"))
local gamesButton = bottomBarFrame:cat(XPath.new("ItemFrame2.Item"))
local avatarButton = bottomBarFrame:cat(XPath.new("ItemFrame3.Item"))
local chatButton = bottomBarFrame:cat(XPath.new("ItemFrame4.Item"))
local moreButton = bottomBarFrame:cat(XPath.new("ItemFrame5.Item"))

local MobileAppElements = {
	topBar = topBar,
	pageName = topBar:cat(XPath.new("NavBar.Title")),
	robuxButton = topBar:cat(XPath.new("NavBar.RightIcons.Robux")),
	notificationsButton = topBar:cat(XPath.new("NavBar.RightIcons.Notifications")),
	searchInputBox = topBar:cat(XPath.new("NavBar.RightIcons.Search.SearchBar.SearchBoxBackground.SearchBox")),

	homeScreen = homeScreen,
	verticalScrollingFrame = verticalScrollingFrame,

	-- people list
	homePagePeopleList = content:cat(XPath.new("FriendSection.CarouselFrame.Content")),
	peopleListContextualMenu = XPath.new("game.CoreGui.PortalUI.Content"),

	backButton = topBar:cat(XPath.new("Layout.BackButton")),

	bottomBar = bottomBar,
	bottomBarFrame = bottomBarFrame,
	homeButton = homeButton,
	gamesButton = gamesButton,
	avatarButton = avatarButton,
	chatButton = chatButton,
	moreButton = moreButton,

	userNameText = content:cat(XPath.new("TitleSection.BuildersClubUsernameFrame.Username")),
	friendCarousel = content:cat(XPath.new("FriendSection.CarouselFrame.MainFrame.Carousel")),
	friendSeeAllText = content:cat(XPath.new("FriendSection.Container.Header.Spacer.Button.Text")),
	friendTitle = content:cat(XPath.new("FriendSection.Container.Header.Title")),
	gameCategoryEntry = content:cat(XPath.new("GameDisplay.*[.ClassName = Frame]")),
	viewFeedText = content:cat(XPath.new("FeedSection.MyFeedButton.Button.Text")),

	listPicker = XPath.new("game.CoreGui.PortalUI.Content.SafeAreaFrame.Content.*[.ClassName = Frame].Frame"),
	listPickerItem = XPath.new("game.CoreGui.PortalUI.Content.SafeAreaFrame.Content.*[.ClassName = Frame].Frame.Content.ListPicker.*[.ClassName = ImageButton]"),

	currentGameList = appRouter:cat(XPath.new("*[.ClassName = ScreenGui, .Enabled = true]")),
	currentGameDetail = appRouter:cat(XPath.new("*[.ClassName = ScreenGui, .Enabled = true]")),
	currentPage = appRouter:cat(XPath.new("*[.ClassName = ScreenGui, .Enabled = true]")),

	gamesScreen = gamesScreen,

	morePageButtons = morePageContent:cat(XPath.new("*[.ClassName = Frame].*[.ClassName = ImageButton]")),

	settingsPageButtons = settingsPageContent:cat(XPath.new("*[.ClassName = ImageButton]")),
	settingsPageTopBar = settingsPageTopBar,

	aboutPageButtons = aboutPageContent:cat(XPath.new("*[.ClassName = ImageButton]")),
	aboutPageTopBar = aboutPageTopBar,

	eventsPageButtons = eventsPageContent:cat(XPath.new("*[.ClassName = ImageButton]")),
	eventsPageTopBar = eventsPageTopBar,

	----avatar editor
	avatarEditorScene = XPath.new("game.Workspace.AvatarEditorScene"),
	character = XPath.new("game.Workspace.CharacterRoot.*[.ClassName = Model]"),
	r6r15SwitchFrame = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.LeftFrame.AEAvatarTypeSwitch"),
	r6r15SwitchButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.LeftFrame.AEAvatarTypeSwitch.ButtonContainer"),
	r6r15Switch = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.LeftFrame.AEAvatarTypeSwitch.Switch"),

	selectTabButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuClosed"),
	closeTabButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.CloseButton"),

	assetButton = XPath.new("game.CoreGui.ScreenGui.RootGui.Frame.ScrollingFrame.*[.ClassName = ImageButton]"),

	fullViewButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.FullViewButton"),
	rightFrame = XPath.new("game.CoreGui.ScreenGui.RootGui.Frame"),
	rightFrameText = XPath.new("game.CoreGui.ScreenGui.RootGui.Frame.ScrollingFrame.TextLabel"),

	groupTabs = {
		recentButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.*.*[.Name = Feature.Avatar.Heading.Recent]"),
		clothingButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.*.*[.Name = Feature.Avatar.Heading.Clothing]"),
		bodyButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.*.*[.Name = Feature.Avatar.Heading.Body]"),
		animationButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.*.*[.Name = Feature.Avatar.Heading.Animations]"),
		outfitsButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.*.Outfits"),
	},

	groupTabs_portrait = {
		recentButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.Frame.*[.Name = Feature.Avatar.Heading.Recent]"),
		clothingButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.Frame.*[.Name = Feature.Avatar.Heading.Clothing]"),
		bodyButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.Frame.*[.Name = Feature.Avatar.Heading.Body]"),
		animationButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.Frame.*[.Name = Feature.Avatar.Heading.Animations]"),
		outfitsButton = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.CategoryMenuUI.CategoryMenuOpen.Frame.Outfits"),
	},

	recentTabs = {
		tabAll = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Recent All"),
		tabClothing = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.*[.Name = Tab-Feature.Avatar.Label.CurrentlyWearing]"),
	},

	clothingTabs = {
		tabHats = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Hats"),
		tabShirts = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Shirts"),
		tabPants = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Pants"),
		tabHair = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Hair"),
		tabFace = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Face Accessories"),
		tabNeck = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Neck Accessories"),
		tabShoulder = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Shoulder Accessories"),
		tabFront = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Front Accessories"),
		tabBack = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Back Accessories"),
		tabWaist = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Waist Accessories"),
		tabGear = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Gear"),
	},

	bodyTabs = {
		tabFaces = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Faces"),
		tabHeads = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Heads"),
		tabLeftArms = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Left Arms"),
		tabLeftLegs = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Left Legs"),
		tabRightArms = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Right Arms"),
		tabRightLegs = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Right Legs"),
		tabScale = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Scale"),
		tabSkinTone = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Skin Tone"),
		tabTorsos = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Torsos"),
	},

	animationTabs = {
		tabClimb = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Climb Animations"),
		tabFall = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Fall Animations"),
		tabIdle = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Idle Animations"),
		tabJump = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Jump Animations"),
		tabRun = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Run Animations"),
		tabSwim = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Swim Animations"),
		tabWalk = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Walk Animations"),
	},

	outfitsTabs = {
		tabOutfits = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-Outfits"),
		tabPresetConstumes = XPath.new("game.CoreGui.AvatarEditorScreen.DialogFrame.Frame.RightFrame.TabListUI.TabList.Contents.Tab-PresetCostumes"),
	},

	getAvatarTabDetail = function(root)
		return{
			text = XPath.new("TextLabel", root),
		}
	end,

	getGameListDetail = function(root)
		return{
			backButton = XPath.new("Contents.TopBar.TopBar.NavBar.BackButton", root),
			dropDownText = XPath.new("Contents.Scroller.scrollingFrame.Content.TopSection.DropDown.Text", root),
			gameTitle = XPath.new("Contents.Scroller.scrollingFrame.Content.TopSection.Title", root),
			gameCard = XPath.new("Contents.Scroller.scrollingFrame.Content.*.Content.1[.ClassName = Frame]", root),
		}
	end,

	getGameDetailsPageDetail = function(root)
		return{
			backButton = XPath.new("Contents.SafeAreaFrame.GameDetailsCard.TopBar.TouchFriendlyNavigationButton", root),
			gameTitle = XPath.new("Contents.SafeAreaFrame.GameDetailsCard.Contents.GameDetails.LoadingState.Header.Title", root),
			description = XPath.new("Contents.SafeAreaFrame.GameDetailsCard.Contents.GameDetails.LoadingState.Description", root),
		}
	end,

	getPageContentDetail = function(root)
		return{
			backButton = XPath.new("TopBar.TopBar.NavBar.BackButton", root),
			pageTitle = XPath.new("TopBar.TopBar.NavBar.Title", root),
		}
	end,

	getListPickerItem = function(root)
		return {
			Text = XPath.new("Content.TextContent", root),
		}
	end,

	getGameCategoryDetail = function(root)
		return {
			title = XPath.new("Title.Title", root),
			seeAllButton = XPath.new("Title.Spacer.Button.Text", root),
			carousel = XPath.new("Carousel", root),
			carouselItem = XPath.new("Carousel.*", root),
		}
	end,

	getGameCardDetailFromCarouselItem = function(root)
		return {
			gameButton = XPath.new("GameButton", root),
			playerCount = XPath.new("GameButton.GameInfo.PlayerCount", root),
			title = XPath.new("GameButton.GameInfo.Title", root),
			icon = XPath.new("GameButton.Icon", root),
		}
	end,

	moreButtonItem = function(root)
		return {
			Text = XPath.new("Text", root)
		}
	end,

	filterBy = function(container, relativePath, property, value)
		local rootPath = container:copy()
		local key = "."..property
		if relativePath ~= nil then
			key = "." .. relativePath:toString() .. key
		end
		local filter = {{key = key, value = value}}
		rootPath:mergeFilter(rootPath:size(), filter)
		return rootPath
	end

}

return MobileAppElements
