-- Mario Hub | Compact FlowAuth Key Loader
-- Compact UI matching the Mario Hub key screen.
-- FlowAuth key/game logic is kept the same as the original loader.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")

local GET_KEY_LINK = "https://discord.gg/nAtBBmPYpr"
local DISCORD_LINK = "https://discord.gg/nAtBBmPYpr"
local PREMIUM_LINK = "https://cosmickeys.mysellauth.com/product/zehub"

local GAMES = {
	[1202096104]  = { "Driving Empire",       "1cf4fd2dd29ee40e884037620feed355" },
	[10031505426] = { "Airdrop Arena",        "5edab16eb54b4f37ae6600d7de1935fd" },
	[10708913337] = { "Anime Dice",           "5d387d5155460a73d4648f246adc5917" },
	[10765288803] = { "Break & Steal an Egg", "ab06edc2c4bb20702ed128f6e4d22d11" },
	[7633926880]  = { "Blox Strike",          "8fb15594b421c1a0915225b42ca5f44b" },
	[10765012427] = { "Build the Pyramid",    "50fa48fdb668974dcdb9915703985f33" },
	[10684750879] = { "Loot To Forge",        "8c611445eb4def5eca25306c285d7ac7" },
	[66654135]    = { "MM2",                  "f266d39c8d792327cd6ea74ce575bca4" },
	[10765091041] = { "Open Sea For Animals", "2fc10f56843e9b8535985847fc08236c" },
	[9534705677]  = { "Sniper Arena",         "431abb514629c7b04ea619b81d39fb89" },
	[10765298801] = { "Stone Skipping",       "1d6f572154f3914b092dd930c283638a" },
	[10418224975] = { "TNT Mining",           "8b980cf9558d2dc097a664482f10b651" },
	[6739698191]  = { "Violence District",    "c8f35d3f42c1e32ac70e04070ef281b4" },
}

local KEY_FOLDER = "mariohub"
local KEY_FILE = "mariohub/key.txt"

local KEY_ERRORS = {
	premium_required = "Enter your key to continue.",
	invalid_key = "That key isn't valid. Check it and try again.",
	key_expired = "Your key expired. Get a new one.",
	key_revoked = "That key was revoked.",
	key_paused = "That key is paused.",
	hwid_mismatch = "That key is linked to another device. Ask for an HWID reset.",
}

local function notify(text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Mario Hub", Text = text, Duration = 8,
		})
	end)
end

local function readKey()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return nil end
	local ok, key = pcall(function()
		return isfile(KEY_FILE) and readfile(KEY_FILE) or nil
	end)
	if not ok or type(key) ~= "string" then return nil end
	key = key:gsub("%s", "")
	return key ~= "" and key or nil
end

local function saveKey(key)
	if type(writefile) ~= "function" then return end
	pcall(function()
		if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(KEY_FOLDER) then
			makefolder(KEY_FOLDER)
		end
		writefile(KEY_FILE, key)
	end)
end

local function clearKey()
	if type(delfile) ~= "function" or type(isfile) ~= "function" then return end
	pcall(function()
		if isfile(KEY_FILE) then delfile(KEY_FILE) end
	end)
end

local entry = GAMES[game.GameId]
if not entry then
	notify("Mario Hub doesn't support this game yet.")
	return
end

-- Original FlowAuth start logic.
local function start(key)
	local ok, err = pcall(function()
		local source = game:HttpGet("https://flowauth.net/v1/loaders/" .. entry[2] .. ".lua")
		local chunk, compileErr = loadstring(source)
		assert(chunk, compileErr or "the script could not compile")
		chunk(key)
	end)
	if ok then
		saveKey(key)
		return true
	end

	local message = tostring(err)
	local code = message:match("FlowAuthError:([%w_]+)")
	if code and KEY_ERRORS[code] then
		clearKey()
		return false, KEY_ERRORS[code]
	end

	warn("[Mario Hub] " .. message)
	notify("Could not start " .. entry[1] .. ". Check the console (F9).")
	return true
end

local function parent()
	if type(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local ok, core = pcall(function() return game:GetService("CoreGui") end)
	if ok and core then return core end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function openLink(url, name)
	local opened = false
	pcall(function()
		if type(openbrowser) == "function" then
			openbrowser(url)
			opened = true
		end
	end)
	if not opened then
		pcall(function()
			if GuiService.OpenBrowserWindow then
				GuiService:OpenBrowserWindow(url)
				opened = true
			end
		end)
	end
	if not opened and type(setclipboard) == "function" then
		pcall(function() setclipboard(url) end)
	end
	notify(opened and (name .. " opened!") or (name .. " link copied!"))
end

local guiParent = parent()

local function make(class, props, p)
	local x = Instance.new(class)
	for k, v in pairs(props) do x[k] = v end
	x.Parent = p
	return x
end

local old = guiParent:FindFirstChild("MarioHubKey")
if old then old:Destroy() end

local gui = make("ScreenGui", {
	Name = "MarioHubKey",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

local scale = make("UIScale", {Scale = 1}, gui)

local card = make("Frame", {
	AnchorPoint = Vector2.new(.5, .5),
	Position = UDim2.fromScale(.5, .5),
	Size = UDim2.fromOffset(520, 352),
	BackgroundColor3 = Color3.fromRGB(247, 243, 235),
	BorderSizePixel = 0,
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 18)}, card)
make("UIStroke", {Color = Color3.fromRGB(61, 54, 67), Thickness = 3}, card)

local top = make("Frame", {
	Size = UDim2.new(1, 0, 0, 82),
	BackgroundColor3 = Color3.fromRGB(221, 83, 68),
	BorderSizePixel = 0,
}, card)
make("UICorner", {CornerRadius = UDim.new(0, 16)}, top)
make("Frame", {
	Position = UDim2.new(0, 0, 1, -16),
	Size = UDim2.new(1, 0, 0, 16),
	BackgroundColor3 = Color3.fromRGB(221, 83, 68),
	BorderSizePixel = 0,
}, top)

local icon = make("TextLabel", {
	Position = UDim2.fromOffset(22, 9),
	Size = UDim2.fromOffset(58, 62),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	Text = "🔑",
	TextSize = 42,
}, top)

local title = make("TextLabel", {
	Position = UDim2.fromOffset(84, 10),
	Size = UDim2.new(1, -98, 0, 62),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack,
	Text = "MARIO HUB · " .. entry[1],
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextStrokeColor3 = Color3.fromRGB(45, 39, 48),
	TextStrokeTransparency = 0,
	TextSize = 23,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextScaled = true,
}, top)
make("UITextSizeConstraint", {MaxTextSize = 23, MinTextSize = 15}, title)

local status = make("TextLabel", {
	Position = UDim2.fromOffset(30, 96),
	Size = UDim2.new(1, -60, 0, 32),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "Enter your Mario Hub key to continue.",
	TextColor3 = Color3.fromRGB(103, 96, 91),
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true,
}, card)

local box = make("TextBox", {
	Position = UDim2.fromOffset(28, 135),
	Size = UDim2.new(1, -56, 0, 54),
	BackgroundColor3 = Color3.fromRGB(255, 252, 247),
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Font = Enum.Font.GothamBold,
	PlaceholderText = "Paste key here",
	PlaceholderColor3 = Color3.fromRGB(154, 146, 136),
	Text = "",
	TextColor3 = Color3.fromRGB(63, 56, 69),
	TextSize = 17,
}, card)
make("UICorner", {CornerRadius = UDim.new(0, 16)}, box)
make("UIStroke", {Color = Color3.fromRGB(61, 54, 67), Thickness = 3}, box)

local function button(text, pos, size, bg)
	local b = make("TextButton", {
		Position = pos,
		Size = size,
		BackgroundColor3 = bg,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = text,
		TextColor3 = Color3.fromRGB(48, 42, 58),
		TextSize = 16,
		AutoButtonColor = true,
	}, card)
	make("UICorner", {CornerRadius = UDim.new(0, 15)}, b)
	make("UIStroke", {Color = Color3.fromRGB(61, 54, 67), Thickness = 3}, b)
	return b
end

local getKey = button("Get Key", UDim2.fromOffset(28, 198), UDim2.new(.5, -34, 0, 44), Color3.fromRGB(235, 173, 70))
local check = button("Check Key", UDim2.new(.5, 6, 0, 198), UDim2.new(.5, -34, 0, 44), Color3.fromRGB(101, 174, 98))
local supported = button("Supported Games", UDim2.fromOffset(28, 250), UDim2.new(.5, -34, 0, 44), Color3.fromRGB(218, 213, 204))
local premium = button("Purchase Premium", UDim2.new(.5, 6, 0, 250), UDim2.new(.5, -34, 0, 44), Color3.fromRGB(218, 213, 204))

local function showGames()
	local existing = guiParent:FindFirstChild("MarioHubSupportedGames")
	if existing then existing:Destroy(); return end

	local panel = make("Frame", {
		Name = "MarioHubSupportedGames",
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(390, 390),
		BackgroundColor3 = Color3.fromRGB(247, 243, 235),
		BorderSizePixel = 0,
		ZIndex = 20,
	}, guiParent)
	make("UICorner", {CornerRadius = UDim.new(0, 16)}, panel)
	make("UIStroke", {Color = Color3.fromRGB(61, 54, 67), Thickness = 3}, panel)

	make("TextLabel", {
		Position = UDim2.fromOffset(18, 12), Size = UDim2.new(1, -70, 0, 30),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
		Text = "Supported Games", TextColor3 = Color3.fromRGB(61,54,67),
		TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
	}, panel)

	local close = make("TextButton", {
		Position = UDim2.new(1, -48, 0, 10), Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Color3.fromRGB(221,83,68), BorderSizePixel = 0,
		Font = Enum.Font.GothamBold, Text = "X", TextColor3 = Color3.new(1,1,1),
		TextSize = 14, ZIndex = 21,
	}, panel)
	make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
	close.MouseButton1Click:Connect(function() panel:Destroy() end)

	local list = make("ScrollingFrame", {
		Position = UDim2.fromOffset(14, 55), Size = UDim2.new(1, -28, 1, -68),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 5,
		CanvasSize = UDim2.new(), ZIndex = 21,
	}, panel)
	local layout = make("UIListLayout", {Padding = UDim.new(0, 5)}, list)

	local games = {}
	for _, data in pairs(GAMES) do games[#games + 1] = data[1] end
	table.sort(games)

	for i, name in ipairs(games) do
		local row = make("TextLabel", {
			Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Color3.fromRGB(232, 226, 217),
			BorderSizePixel = 0, Font = Enum.Font.GothamSemibold, Text = "  " .. name,
			TextColor3 = Color3.fromRGB(61,54,67), TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i, ZIndex = 22,
		}, list)
		make("UICorner", {CornerRadius = UDim.new(0, 8)}, row)
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
	end)
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
end

getKey.MouseButton1Click:Connect(function() openLink(GET_KEY_LINK, "Get Key") end)
premium.MouseButton1Click:Connect(function() openLink(PREMIUM_LINK, "Premium") end)
supported.MouseButton1Click:Connect(showGames)

local busy = false
local function checkKey()
	if busy then return end
	local key = box.Text:gsub("%s", "")
	if key == "" then
		status.Text = "Paste your key first."
		return
	end

	busy = true
	check.Text = "Checking..."
	task.spawn(function()
		local ok, why = start(key)
		if ok then
			gui:Destroy()
			return
		end
		status.Text = why
		check.Text = "Check Key"
		busy = false
	end)
end

check.MouseButton1Click:Connect(checkKey)
box.FocusLost:Connect(function(enter)
	if enter then checkKey() end
end)

local function resize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local v = camera.ViewportSize
	scale.Scale = math.min((v.X - 20) / 520, (v.Y - 20) / 352, 1)
end
resize()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

local saved = readKey()
if saved then
	local ok, why = start(saved)
	if not ok then status.Text = why end
else
	status.Text = "Enter your Mario Hub key to continue."
end
