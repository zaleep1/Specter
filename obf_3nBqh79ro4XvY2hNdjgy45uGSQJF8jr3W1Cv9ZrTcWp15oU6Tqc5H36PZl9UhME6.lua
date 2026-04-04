local emfs           = evidenceFolder.EMF
local equipment      = workspace:WaitForChild("Equipment")
local bone           = map and map:FindFirstChild("Bone")

local KEY_ENABLED = true
local GET_KEY_URL = "https://lootdest.org/s?SsiC5LyZ"
local VALID_KEY   = "5G0HL1P7MXNZXWDJSA13ZAWDJAMWASD"

local C = {
    bg       = Color3.fromRGB(12, 12, 14),
    surface  = Color3.fromRGB(22, 22, 26),
    border   = Color3.fromRGB(40, 40, 48),
    accent   = Color3.fromRGB(130, 100, 255),
    text     = Color3.fromRGB(220, 220, 230),
    muted    = Color3.fromRGB(110, 110, 130),
    yes      = Color3.fromRGB(80, 230, 140),
    no       = Color3.fromRGB(230, 70,  80),
    trait    = Color3.fromRGB(255, 190,  60),
    btnHover = Color3.fromRGB(35, 35, 45),
    ghost    = Color3.fromRGB(180, 140, 255),
}


local SPEED_TOL = 0.4

local GHOSTS = {
    { name="Otakata",  ev={"emf","fingerprints","orbs"},
      speed={ min=14, max=14.8, fixed=true, unique=true,
              hint="Always 14.4 — only ghost with this speed" } },
    { name="Haint",    ev={"motion","orbs"},
      speed={ min=22.5, max=24.5, fixed=true, unique=true,
              hint="Always ~23.4 — fastest ghost" } },
    { name="Blair",    ev={"emf"},
      speed={ min=13.4, max=14.2, fixed=true,
              hint="Always 13.8" } },
    { name="Duppy",    ev={"trickster","emf","orbs"},
      speed={ min=14.7, max=15.5, fixed=true,
              hint="Always 15.1" } },
    { name="Myling",   ev={"emf","motion"},
      speed={ min=17.5, max=18.3, fixed=true, unique=true,
              hint="Always ~17.9" } },
    { name="Wendigo",  ev={"motion"},
      speed={ min=14.7, max=15.5, fixed=true,
              hint="Always 15.1" } },
    { name="Yokai",    ev={"trickster","motion","fingerprints"},
      speed={ min=13.4, max=17, fixed=false,
              hint="Starts 13.8, can spike to 16.5+" } },
    { name="Afarit",   ev={"motion","orbs"},
      speed={ min=13.4, max=19.7, fixed=false,
              hint="13.8 base → 19.3 watching player" } },
    { name="Aswang",   ev={"emf","fingerprints"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Banshee",  ev={"emf","fingerprints"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Bhuta",    ev={"book","motion"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Bogey",    ev={"orbs","fingerprints","motion"},
      speed={ min=12, max=14.2, fixed=false,
              hint="12.4 base → 13.8 in hunt" } },
    { name="Demon",    ev={"flicker","book"},
      speed={ min=12, max=15, fixed=false,
              hint="12.4, slowly +0.1/s in hunt" } },
    { name="Douen",    ev={"trickster","motion","fingerprints","book"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Egui",     ev={"orbs","book"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Jinn",     ev={"flicker","emf","motion","orbs"},
      speed={ min=12, max=22.4, fixed=false,
              hint="12.4 base → up to 22.0 in hunt" } },
    { name="Mare",     ev={"flicker","orbs"},
      speed={ min=12, max=18.3, fixed=false,
              hint="12.4 base → up to 17.9 in hunt" } },
    { name="Mimic",    ev={"book","emf"},
      speed={ min=12, max=99, fixed=false,
              hint="Copies another ghost speed after 2 min" } },
    { name="Oni",      ev={"motion","book"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Phantom",  ev={"emf","orbs"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Polter",   ev={"trickster","fingerprints","orbs"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Preta",    ev={"motion","fingerprints"},
      speed={ min=15.4, max=22.7, fixed=false, unique = true,
              hint="15.4 / 18.0 / 22.3 by player count" } },
    { name="Revenant", ev={"emf","fingerprints","book"},
      speed={ min=12, max=18.3, fixed=false,
              hint="12.4 → 13.8 → 17.9 spotting player" } },
    { name="Shade",    ev={"emf","book","orbs"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Spirit",   ev={"flicker","book","fingerprints"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Thaye",    ev={"orbs","fingerprints"},
      speed={ min=13.4, max=17, fixed=false,
              hint="13.8 base, slowly accelerates" } },
    { name="Upyr",     ev={"emf","motion"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Wisp",     ev={"flicker","orbs","fingerprints","book"},
      speed={ min=10.6, max=13.2, fixed=false,
              hint="~12.4 base, slows to 11 in hunt" } },
    { name="Wraith",   ev={"motion","book","emf"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
    { name="Yurei",    ev={"book","orbs"},
      speed={ min=12, max=13.2, fixed=false, hint="~12.4 base" } },
}


local function getPosition(inst)
    if not inst then return end
    if inst:IsA("BasePart") then return inst.Position end
    if inst.PrimaryPart then return inst.PrimaryPart.Position end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    if p then return p.Position end
end

local function colorClose(c1, c2, tol)
    tol = tol or 0.01
    return math.abs(c1.R - c2.R) < tol
       and math.abs(c1.G - c2.G) < tol
       and math.abs(c1.B - c2.B) < tol
end

local COLOR_MOTION_YES = Color3.fromRGB(252, 52, 52)
local COLOR_TOOTHPASTE = BrickColor.new("Toothpaste").Color

local function speedCouldMatch(g, speed)
    local s = g.speed
    if s.fixed then
        return speed >= (s.min - SPEED_TOL) and speed <= (s.max + SPEED_TOL)
    else
        return speed <= (s.max + SPEED_TOL)
    end
end

local function uniqueSpeedInstantID(speed)
    if speed < 12 then return nil end
    local matches = {}
    for _, g in ipairs(GHOSTS) do
        if speedCouldMatch(g, speed) then
            table.insert(matches, g)
        end
    end
    if #matches == 1 then
        return matches[1].name, matches[1].speed.hint
    end
    return nil
end

local function speedTag(speed)
    if speed < 12 then return "" end
    if speed >= 22.5 then return "🔴 >"..string.format("%.1f",speed)..": Haint" end
    if speed >= 21 then return "🟠 >"..string.format("%.1f",speed)..": Jinn / Preta / Mimic" end
    if speed >= 18 then return "🟡 ~"..string.format("%.1f",speed)..": Jinn / Preta / Myling" end
    if speed >= 17 then return "🟡 ~"..string.format("%.1f",speed)..": Myling / Mare / Revenant / Preta" end
    if speed >= 14.9 and speed <= 15.3 then return "🟢 ~15.1: Duppy or Wendigo" end
    if speed >= 15 then return "🟡 ~"..string.format("%.1f",speed)..": Duppy / Wendigo / Preta / Afarit" end
    if speed >= 14 and speed <= 14.8 then return "🟣 ~14.4: OTAKATA (unique!)" end
    if speed >= 13.4 and speed <= 14 then return "🔵 ~13.8: Blair / Afarit / Thaye / Yokai" end
    return ""
end


local detectedEv  = {}
local rejectedEv  = {}
local anyEvidence = false
local maxSpeedSeen = 0

local confirmEvidence, rejectEvidence
local ghostNameLbl, ghostSpeedHint, ghostSpeedTag

local function setStatus(dot, pill, state)
    if state == "Yes" then
        dot.BackgroundColor3 = C.yes
        pill.Text            = "YES"
        pill.TextColor3      = C.yes
    elseif state == "No" then
        dot.BackgroundColor3 = C.no
        pill.Text            = "NO"
        pill.TextColor3      = C.no
    else
        dot.BackgroundColor3 = C.muted
        pill.Text            = "?"
        pill.TextColor3      = C.muted
    end
end

local function updateGhostLabel()
    if not ghostNameLbl then return end

    if ghostSpeedTag then
        ghostSpeedTag.Text = speedTag(maxSpeedSeen)
    end

    local speedActive = maxSpeedSeen >= 13
    if not anyEvidence and not speedActive then
        ghostNameLbl.Text       = "? candidates"
        ghostNameLbl.TextColor3 = C.muted
        if ghostSpeedHint then ghostSpeedHint.Text = "" end
        return
    end

    local instantName, instantHint = uniqueSpeedInstantID(maxSpeedSeen)
    if instantName and not anyEvidence then
        ghostNameLbl.Text       = instantName
        ghostNameLbl.TextColor3 = C.yes
        if ghostSpeedHint then
            ghostSpeedHint.Text       = instantHint or ""
            ghostSpeedHint.TextColor3 = C.trait
        end
        return
    end

    local candidates = {}
    for _, g in ipairs(GHOSTS) do
        local possible = true
        for ev in pairs(rejectedEv) do
            for _, gev in ipairs(g.ev) do
                if gev == ev then possible = false; break end
            end
            if not possible then break end
        end
        if possible then
            for ev in pairs(detectedEv) do
                local hasIt = false
                for _, gev in ipairs(g.ev) do
                    if gev == ev then hasIt = true; break end
                end
                if not hasIt then possible = false; break end
            end
        end
        if possible and maxSpeedSeen >= 12 then
            if not speedCouldMatch(g, maxSpeedSeen) then
                possible = false
            end
        end
        if possible then table.insert(candidates, g.name) end
    end

    if #candidates == 0 then
        ghostNameLbl.Text       = "No match"
        ghostNameLbl.TextColor3 = C.no
        if ghostSpeedHint then ghostSpeedHint.Text = "" end
    elseif #candidates == 1 then
        ghostNameLbl.Text       = candidates[1]
        ghostNameLbl.TextColor3 = C.yes
        for _, gh in ipairs(GHOSTS) do
            if gh.name == candidates[1] then
                if ghostSpeedHint then
                    ghostSpeedHint.Text       = gh.speed.hint or ""
                    ghostSpeedHint.TextColor3 = C.trait
                end
                break
            end
        end
    elseif #candidates == 2 then
        ghostNameLbl.Text       = candidates[1] .. " / " .. candidates[2]
        ghostNameLbl.TextColor3 = C.ghost
        local hints = {}
        for _, gh in ipairs(GHOSTS) do
            if gh.name == candidates[1] or gh.name == candidates[2] then
                if gh.speed.hint then
                    table.insert(hints, gh.name..": "..gh.speed.hint)
                end
            end
        end
        if ghostSpeedHint then
            ghostSpeedHint.Text       = table.concat(hints, "  |  ")
            ghostSpeedHint.TextColor3 = C.trait
        end
    else
        local joined = table.concat(candidates, " / ")
        if #joined > 58 then joined = #candidates.." possible" end
        ghostNameLbl.Text       = joined
        ghostNameLbl.TextColor3 = C.ghost
        if ghostSpeedHint then ghostSpeedHint.Text = "" end
    end
end

confirmEvidence = function(key, dot, pill)
    if detectedEv[key] then return end
    detectedEv[key] = true
    anyEvidence = true
    setStatus(dot, pill, "Yes")
    updateGhostLabel()
end

rejectEvidence = function(key, dot, pill)
    if detectedEv[key] then return end
    rejectedEv[key] = true
    setStatus(dot, pill, "No")
    updateGhostLabel()
end


local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "GhostInfoUI_v8"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent         = player:WaitForChild("PlayerGui")


local keyScreen = Instance.new("Frame")
keyScreen.Name             = "KeyScreen"
keyScreen.Size             = UDim2.new(1, 0, 1, 0)
keyScreen.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
keyScreen.BorderSizePixel  = 0
keyScreen.ZIndex           = 10
keyScreen.Parent           = screenGui

local keyCard = Instance.new("Frame", keyScreen)
keyCard.Size             = UDim2.new(0, 280, 0, 200)
keyCard.Position         = UDim2.new(0.5, -140, 0.5, -100)
keyCard.BackgroundColor3 = C.bg
keyCard.BorderSizePixel  = 0
Instance.new("UICorner", keyCard).CornerRadius = UDim.new(0, 16)

local keyCardStroke = Instance.new("UIStroke", keyCard)
keyCardStroke.Color        = C.accent
keyCardStroke.Thickness    = 1
keyCardStroke.Transparency = 0.4

local keyTitle = Instance.new("TextLabel", keyCard)
keyTitle.Size                   = UDim2.new(1, -24, 0, 28)
keyTitle.Position               = UDim2.new(0, 12, 0, 14)
keyTitle.BackgroundTransparency = 1
keyTitle.Text                   = "GHOST INFO — Key System"
keyTitle.TextColor3             = C.text
keyTitle.Font                   = Enum.Font.GothamBold
keyTitle.TextScaled             = false
keyTitle.TextSize               = 13
keyTitle.TextXAlignment         = Enum.TextXAlignment.Center

local keySub = Instance.new("TextLabel", keyCard)
keySub.Size                   = UDim2.new(1, -24, 0, 16)
keySub.Position               = UDim2.new(0, 12, 0, 40)
keySub.BackgroundTransparency = 1
keySub.Text                   = "Enter your lifetime key to continue"
keySub.TextColor3             = C.muted
keySub.Font                   = Enum.Font.Gotham
keySub.TextScaled             = false
keySub.TextSize               = 10
keySub.TextXAlignment         = Enum.TextXAlignment.Center

local keyBox = Instance.new("TextBox", keyCard)
keyBox.Size                   = UDim2.new(1, -24, 0, 34)
keyBox.Position               = UDim2.new(0, 12, 0, 66)
keyBox.BackgroundColor3       = C.surface
keyBox.BorderSizePixel        = 0
keyBox.Text                   = ""
keyBox.PlaceholderText        = "Paste key here..."
keyBox.PlaceholderColor3      = C.muted
keyBox.TextColor3             = C.text
keyBox.Font                   = Enum.Font.Gotham
keyBox.TextScaled             = false
keyBox.TextSize               = 11
keyBox.ClearTextOnFocus       = false
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local keyBoxPad = Instance.new("UIPadding", keyBox)
keyBoxPad.PaddingLeft  = UDim.new(0, 10)
keyBoxPad.PaddingRight = UDim.new(0, 10)

local keyBoxStroke = Instance.new("UIStroke", keyBox)
keyBoxStroke.Color        = C.border
keyBoxStroke.Thickness    = 1
keyBoxStroke.Transparency = 0.2

local keyStatus = Instance.new("TextLabel", keyCard)
keyStatus.Size                   = UDim2.new(1, -24, 0, 14)
keyStatus.Position               = UDim2.new(0, 12, 0, 108)
keyStatus.BackgroundTransparency = 1
keyStatus.Text                   = ""
keyStatus.TextColor3             = C.no
keyStatus.Font                   = Enum.Font.Gotham
keyStatus.TextScaled             = false
keyStatus.TextSize               = 10
keyStatus.TextXAlignment         = Enum.TextXAlignment.Center

local function makeKeyBtn(text, xPos, bgColor)
    local btn = Instance.new("TextButton", keyCard)
    btn.Size             = UDim2.new(0, 118, 0, 32)
    btn.Position         = UDim2.new(0, xPos, 0, 152)
    btn.BackgroundColor3 = bgColor
    btn.BorderSizePixel  = 0
    btn.Text             = text
    btn.TextColor3       = C.text
    btn.Font             = Enum.Font.GothamBold
    btn.TextScaled       = false
    btn.TextSize         = 11
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12),
            {BackgroundColor3 = bgColor:Lerp(Color3.new(1,1,1), 0.12)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12),
            {BackgroundColor3 = bgColor}):Play()
    end)
    return btn
end

local getLinkBtn  = makeKeyBtn("Get Lifetime Key", 12,  Color3.fromRGB(50, 40, 90))
local checkKeyBtn = makeKeyBtn("Check Key",        142, Color3.fromRGB(40, 80, 50))

getLinkBtn.MouseButton1Click:Connect(function()
    setclipboard(GET_KEY_URL)
    local orig = getLinkBtn.Text
    getLinkBtn.Text       = "Copied to clipboard!"
    getLinkBtn.TextColor3 = C.yes
    task.delay(2, function()
        getLinkBtn.Text       = orig
        getLinkBtn.TextColor3 = C.text
    end)
end)

checkKeyBtn.MouseButton1Click:Connect(function()
    local entered = keyBox.Text:gsub("%s+", "")  -- trim whitespace
    if entered == VALID_KEY then
        TweenService:Create(keyScreen, TweenInfo.new(0.4),
            {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        for _, d in ipairs(keyScreen:GetDescendants()) do
            if d:IsA("GuiObject") then
                pcall(function() d.Visible = false end)
            end
        end
        keyScreen.Visible = false
        launchMainUI()
    else
        keyStatus.Text       = "Invalid key. Try again."
        keyStatus.TextColor3 = C.no
        TweenService:Create(keyBox, TweenInfo.new(0.08, Enum.EasingStyle.Bounce),
            {BackgroundColor3 = Color3.fromRGB(60, 20, 20)}):Play()
        task.delay(0.4, function()
            TweenService:Create(keyBox, TweenInfo.new(0.2),
                {BackgroundColor3 = C.surface}):Play()
        end)
    end
end)


function launchMainUI()

    local panel = Instance.new("Frame")
    panel.Name             = "Panel"
    panel.Size             = UDim2.new(0, 228, 0, 660)
    panel.Position         = UDim2.new(1, -246, 0.5, -330)
    panel.BackgroundColor3 = C.bg
    panel.BorderSizePixel  = 0
    panel.Parent           = screenGui

    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", panel)
    stroke.Color        = C.border
    stroke.Thickness    = 1
    stroke.Transparency = 0.4

    local layout = Instance.new("UIListLayout", panel)
    layout.Padding       = UDim.new(0, 0)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder     = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding", panel)
    padding.PaddingLeft   = UDim.new(0, 14)
    padding.PaddingRight  = UDim.new(0, 14)
    padding.PaddingTop    = UDim.new(0, 14)
    padding.PaddingBottom = UDim.new(0, 14)

    do
        local dragging   = false
        local dragStart  = Vector2.new()
        local panelStart = Vector2.new()
        panel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging   = true
                dragStart  = Vector2.new(input.Position.X, input.Position.Y)
                panelStart = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
            end
        end)
        panel.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
                panel.Position = UDim2.new(0, panelStart.X + delta.X, 0, panelStart.Y + delta.Y)
            end
        end)
    end

    local function spacer(order, h)
        local sp = Instance.new("Frame", panel)
        sp.Size                   = UDim2.new(1, 0, 0, h or 8)
        sp.BackgroundTransparency = 1
        sp.LayoutOrder            = order
    end
    local function divider(order)
        local d = Instance.new("Frame", panel)
        d.Size             = UDim2.new(1, 0, 0, 1)
        d.BackgroundColor3 = C.border
        d.BorderSizePixel  = 0
        d.LayoutOrder      = order
    end

    local header = Instance.new("Frame", panel)
    header.Size                   = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.LayoutOrder            = 1

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size                   = UDim2.new(1, 0, 0.6, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                   = "GHOST  INFO"
    titleLbl.TextColor3             = C.text
    titleLbl.Font                   = Enum.Font.GothamBold
    titleLbl.TextScaled             = false
    titleLbl.TextSize               = 13
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left

    local subtitleLbl = Instance.new("TextLabel", header)
    subtitleLbl.Size                   = UDim2.new(1, 0, 0.4, 0)
    subtitleLbl.Position               = UDim2.new(0, 0, 0.6, 0)
    subtitleLbl.BackgroundTransparency = 1
    subtitleLbl.Text                   = "Evidence tracker  v7"
    subtitleLbl.TextColor3             = C.muted
    subtitleLbl.Font                   = Enum.Font.Gotham
    subtitleLbl.TextScaled             = false
    subtitleLbl.TextSize               = 10
    subtitleLbl.TextXAlignment         = Enum.TextXAlignment.Left

    divider(2)
    spacer(3, 8)

    local ghostBox = Instance.new("Frame", panel)
    ghostBox.Size             = UDim2.new(1, 0, 0, 70)
    ghostBox.BackgroundColor3 = Color3.fromRGB(20, 16, 36)
    ghostBox.BorderSizePixel  = 0
    ghostBox.LayoutOrder      = 4
    Instance.new("UICorner", ghostBox).CornerRadius = UDim.new(0, 10)
    local ghostStroke = Instance.new("UIStroke", ghostBox)
    ghostStroke.Color        = C.accent
    ghostStroke.Thickness    = 1
    ghostStroke.Transparency = 0.5

    local ghostTitleLbl2 = Instance.new("TextLabel", ghostBox)
    ghostTitleLbl2.Size                   = UDim2.new(1, -12, 0, 14)
    ghostTitleLbl2.Position               = UDim2.new(0, 8, 0, 4)
    ghostTitleLbl2.BackgroundTransparency = 1
    ghostTitleLbl2.Text                   = "POSSIBLE GHOST"
    ghostTitleLbl2.TextColor3             = C.muted
    ghostTitleLbl2.Font                   = Enum.Font.Gotham
    ghostTitleLbl2.TextScaled             = false
    ghostTitleLbl2.TextSize               = 9
    ghostTitleLbl2.TextXAlignment         = Enum.TextXAlignment.Left

    ghostNameLbl = Instance.new("TextLabel", ghostBox)
    ghostNameLbl.Size                   = UDim2.new(1, -12, 0, 18)
    ghostNameLbl.Position               = UDim2.new(0, 8, 0, 17)
    ghostNameLbl.BackgroundTransparency = 1
    ghostNameLbl.Text                   = "? candidates"
    ghostNameLbl.TextColor3             = C.muted
    ghostNameLbl.Font                   = Enum.Font.GothamBold
    ghostNameLbl.TextScaled             = false
    ghostNameLbl.TextSize               = 13
    ghostNameLbl.TextXAlignment         = Enum.TextXAlignment.Left

    ghostSpeedHint = Instance.new("TextLabel", ghostBox)
    ghostSpeedHint.Size                   = UDim2.new(1, -12, 0, 12)
    ghostSpeedHint.Position               = UDim2.new(0, 8, 0, 36)
    ghostSpeedHint.BackgroundTransparency = 1
    ghostSpeedHint.Text                   = ""
    ghostSpeedHint.TextColor3             = C.trait
    ghostSpeedHint.Font                   = Enum.Font.Gotham
    ghostSpeedHint.TextScaled             = false
    ghostSpeedHint.TextSize               = 9
    ghostSpeedHint.TextXAlignment         = Enum.TextXAlignment.Left

    ghostSpeedTag = Instance.new("TextLabel", ghostBox)
    ghostSpeedTag.Size                   = UDim2.new(1, -12, 0, 12)
    ghostSpeedTag.Position               = UDim2.new(0, 8, 0, 52)
    ghostSpeedTag.BackgroundTransparency = 1
    ghostSpeedTag.Text                   = ""
    ghostSpeedTag.TextColor3             = C.accent
    ghostSpeedTag.Font                   = Enum.Font.Gotham
    ghostSpeedTag.TextScaled             = false
    ghostSpeedTag.TextSize               = 9
    ghostSpeedTag.TextXAlignment         = Enum.TextXAlignment.Left

    spacer(5, 8)
    divider(6)
    spacer(7, 8)

    local function makeButton(icon, text, order)
        local btn = Instance.new("TextButton", panel)
        btn.Size             = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = C.surface
        btn.BorderSizePixel  = 0
        btn.AutoButtonColor  = false
        btn.Text             = ""
        btn.LayoutOrder      = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
        local ico = Instance.new("TextLabel", btn)
        ico.Size = UDim2.new(0, 24, 1, 0); ico.Position = UDim2.new(0, 10, 0, 0)
        ico.BackgroundTransparency = 1; ico.Text = icon
        ico.TextScaled = false; ico.TextSize = 14; ico.Font = Enum.Font.Gotham
        ico.TextColor3 = C.accent; ico.TextXAlignment = Enum.TextXAlignment.Center
        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -44, 1, 0); lbl.Position = UDim2.new(0, 38, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = text
        lbl.TextScaled = false; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = C.text; lbl.TextXAlignment = Enum.TextXAlignment.Left
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.btnHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface}):Play()
        end)
        spacer(order + 0.5, 5)
        return btn, lbl
    end

    local tpGhostBtn, _            = makeButton("👻", "TP to Ghost",  10)
    local collectBtn,  _           = makeButton("🦴", "Collect Bone", 11)
    local checkPMBtn,  _           = makeButton("📡", "Check Motion", 12)
    local tpVanBtn,    _           = makeButton("🚐", "TP to Van",    13)
    local staminaBtn,  staminaLbl  = makeButton("⚡", "Inf Stamina",  14)

    divider(15)
    spacer(16, 8)

    local function makeEvidenceRow(name, order)
        local row = Instance.new("Frame", panel)
        row.Size = UDim2.new(1, 0, 0, 24); row.BackgroundTransparency = 1
        row.LayoutOrder = order
        local dot = Instance.new("Frame", row)
        dot.Size = UDim2.new(0, 8, 0, 8); dot.Position = UDim2.new(0, 0, 0.5, -4)
        dot.BackgroundColor3 = C.muted; dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(0.62, -16, 1, 0); nameLbl.Position = UDim2.new(0, 18, 0, 0)
        nameLbl.BackgroundTransparency = 1; nameLbl.Text = name
        nameLbl.TextScaled = false; nameLbl.TextSize = 11; nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextColor3 = C.text; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        local pill = Instance.new("TextLabel", row)
        pill.Size = UDim2.new(0.38, 0, 1, 0); pill.Position = UDim2.new(0.62, 0, 0, 0)
        pill.BackgroundTransparency = 1; pill.Text = "?"
        pill.TextScaled = false; pill.TextSize = 11; pill.Font = Enum.Font.GothamBold
        pill.TextColor3 = C.muted; pill.TextXAlignment = Enum.TextXAlignment.Right
        spacer(order + 0.5, 2)
        return dot, pill
    end

    local emfDot,  emfPill  = makeEvidenceRow("EMF Level 5",  20)
    local motDot,  motPill  = makeEvidenceRow("Motion",       21)
    local orbDot,  orbPill  = makeEvidenceRow("Ghost Orbs",   22)
    local fpDot,   fpPill   = makeEvidenceRow("Fingerprints", 23)
    local bookDot, bookPill = makeEvidenceRow("Book",         24)

    divider(25)
    spacer(26, 8)

    local traitRow = Instance.new("Frame", panel)
    traitRow.Size             = UDim2.new(1, 0, 0, 28)
    traitRow.BackgroundColor3 = Color3.fromRGB(40, 30, 10)
    traitRow.BorderSizePixel  = 0
    traitRow.LayoutOrder      = 27
    Instance.new("UICorner", traitRow).CornerRadius = UDim.new(0, 8)
    local traitStroke = Instance.new("UIStroke", traitRow)
    traitStroke.Color = C.trait; traitStroke.Thickness = 1; traitStroke.Transparency = 0.5

    local traitIcon = Instance.new("TextLabel", traitRow)
    traitIcon.Size = UDim2.new(0, 22, 1, 0); traitIcon.Position = UDim2.new(0, 8, 0, 0)
    traitIcon.BackgroundTransparency = 1; traitIcon.Text = "✦"
    traitIcon.TextScaled = false; traitIcon.TextSize = 11; traitIcon.Font = Enum.Font.GothamBold
    traitIcon.TextColor3 = C.trait; traitIcon.TextXAlignment = Enum.TextXAlignment.Center

    local traitLabel = Instance.new("TextLabel", traitRow)
    traitLabel.Size = UDim2.new(1, -30, 1, 0); traitLabel.Position = UDim2.new(0, 30, 0, 0)
    traitLabel.BackgroundTransparency = 1; traitLabel.Text = "Trait: —"
    traitLabel.TextScaled = false; traitLabel.TextSize = 11; traitLabel.Font = Enum.Font.GothamBold
    traitLabel.TextColor3 = C.muted; traitLabel.TextXAlignment = Enum.TextXAlignment.Left

    spacer(28, 6)

    local speedRow = Instance.new("Frame", panel)
    speedRow.Size = UDim2.new(1, 0, 0, 22); speedRow.BackgroundTransparency = 1
    speedRow.LayoutOrder = 29

    local speedIcon2 = Instance.new("TextLabel", speedRow)
    speedIcon2.Size = UDim2.new(0, 16, 1, 0); speedIcon2.BackgroundTransparency = 1
    speedIcon2.Text = "💨"; speedIcon2.TextScaled = false; speedIcon2.TextSize = 11
    speedIcon2.Font = Enum.Font.Gotham; speedIcon2.TextXAlignment = Enum.TextXAlignment.Left

    local speedVal = Instance.new("TextLabel", speedRow)
    speedVal.Size = UDim2.new(1, -20, 1, 0); speedVal.Position = UDim2.new(0, 20, 0, 0)
    speedVal.BackgroundTransparency = 1; speedVal.Text = "Speed: 0.0"
    speedVal.TextScaled = false; speedVal.TextSize = 11; speedVal.Font = Enum.Font.GothamBold
    speedVal.TextColor3 = C.accent; speedVal.TextXAlignment = Enum.TextXAlignment.Left

    ------------------------------------------------
    ------------------------------------------------

    tpGhostBtn.MouseButton1Click:Connect(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")
        local pos  = getPosition(ghost)
        if not pos then return end
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        workspace.CurrentCamera.CFrame =
            CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
    end)

    collectBtn.MouseButton1Click:Connect(function()
        if not bone then return end
        local char    = player.Character or player.CharacterAdded:Wait()
        local hrp     = char:WaitForChild("HumanoidRootPart")
        local bonePos = getPosition(bone)
        if not bonePos then return end
        local old = hrp.CFrame
        hrp.CFrame = CFrame.new(bonePos + Vector3.new(0, 4, 0))
        task.wait(0.2)
        workspace.CurrentCamera.CFrame =
            CFrame.new(workspace.CurrentCamera.CFrame.Position, bonePos)
        task.wait(0.2)
        local prompt = bone:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then pcall(fireproximityprompt, prompt) end
        task.wait(0.3)
        hrp.CFrame = old
    end)

    checkPMBtn.MouseButton1Click:Connect(function()
        local ghostModel = workspace.NPCs:FindFirstChildOfClass("Model")
        if not ghostModel then return end
        local root = ghostModel:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local saved = {}
        for _, grid in pairs(motions:GetDescendants()) do
            if grid:IsA("Part") then
                saved[grid] = grid.CFrame
                grid.CFrame = root.CFrame
            end
        end

        task.wait(0.15)  -- let game process overlap

        local yesDetected = false
        local noDetected  = false
        for grid in pairs(saved) do
            if grid:IsA("Part") then
                if colorClose(grid.Color, COLOR_MOTION_YES) then
                    yesDetected = true; break
                elseif colorClose(grid.Color, COLOR_TOOTHPASTE) then
                    noDetected = true
                end
            end
        end

        for part, cf in pairs(saved) do
            part.CFrame = cf
        end

        if yesDetected then
            confirmEvidence("motion", motDot, motPill)
        elseif noDetected and not detectedEv["motion"] then
            rejectEvidence("motion", motDot, motPill)
        end
    end)

    tpVanBtn.MouseButton1Click:Connect(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")
        local van  = workspace:FindFirstChild("Van")
        if van and van.PrimaryPart then
            hrp.CFrame = van.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
        end
    end)

    local infStamina = false
    local staminaConn
    staminaLbl.TextColor3 = C.no

    staminaBtn.MouseButton1Click:Connect(function()
        infStamina = not infStamina
        if infStamina then
            staminaLbl.Text       = "Inf Stamina  ON"
            staminaLbl.TextColor3 = C.yes
            if not staminaConn then
                staminaConn = RunService.RenderStepped:Connect(function()
                    player:SetAttribute("Stamina", 100)
                end)
            end
        else
            staminaLbl.Text       = "Inf Stamina"
            staminaLbl.TextColor3 = C.text
            if staminaConn then staminaConn:Disconnect(); staminaConn = nil end
        end
    end)

    ------------------------------------------------
    ------------------------------------------------

    emfs.ChildAdded:Connect(function(e)
        if e.Name == "EMF5" then confirmEvidence("emf", emfDot, emfPill) end
    end)
    fingerprints.ChildAdded:Connect(function()
        confirmEvidence("fingerprints", fpDot, fpPill)
    end)
    orbs.ChildAdded:Connect(function()
        confirmEvidence("orbs", orbDot, orbPill)
    end)

    task.delay(120, function()
        if not detectedEv["emf"]          then rejectEvidence("emf",         emfDot, emfPill)  end
        if not detectedEv["fingerprints"] then rejectEvidence("fingerprints", fpDot,  fpPill)  end
        if not detectedEv["orbs"]         then rejectEvidence("orbs",         orbDot, orbPill) end
    end)

    task.spawn(function()
        while true do
            local yesDetected = false
            local noDetected  = false
            for _, motion in pairs(motions:GetDescendants()) do
                if motion:IsA("Part") then
                    if colorClose(motion.Color, COLOR_MOTION_YES) then
                        yesDetected = true; break
                    elseif colorClose(motion.Color, COLOR_TOOTHPASTE) then
                        noDetected = true
                    end
                end
            end
            if yesDetected then
                confirmEvidence("motion", motDot, motPill)
            elseif noDetected and not detectedEv["motion"] then
                rejectEvidence("motion", motDot, motPill)
            end
            task.wait(0.5)
        end
    end)

    local function watchBook(book)
        local function checkPages()
            if detectedEv["book"] then return end
            local left  = book:FindFirstChild("LeftPage")
            local right = book:FindFirstChild("RightPage")
            if (left and #left:GetChildren() > 0)
            or (right and #right:GetChildren() > 0) then
                confirmEvidence("book", bookDot, bookPill)
            end
        end
        checkPages()
        local function connectPage(page)
            if not page then return end
            page.ChildAdded:Connect(function()
                confirmEvidence("book", bookDot, bookPill)
            end)
        end
        connectPage(book:FindFirstChild("LeftPage"))
        connectPage(book:FindFirstChild("RightPage"))
        book.ChildAdded:Connect(function(child)
            if child.Name == "LeftPage" or child.Name == "RightPage" then
                connectPage(child); checkPages()
            end
        end)
    end

    for _, item in pairs(equipment:GetChildren()) do
        if item.Name == "Book" then watchBook(item) end
    end
    equipment.ChildAdded:Connect(function(item)
        if item.Name == "Book" then watchBook(item) end
    end)
    task.delay(180, function()
        if not detectedEv["book"] then rejectEvidence("book", bookDot, bookPill) end
    end)

    local traitDetected = false
    task.spawn(function()
        local ghostBase = ghost:WaitForChild("Base")
        local history = {}
        local MAX = 8; local INTERVAL = 1.5; local FLIPS_REQ = 3
        while not traitDetected do
            local val = ghostBase.Transparency > 0.5 and 1 or 0
            table.insert(history, val)
            if #history > MAX then table.remove(history, 1) end
            if #history >= MAX then
                local flips = 0
                for i = 2, #history do
                    if history[i] ~= history[i-1] then flips += 1 end
                end
                if flips >= FLIPS_REQ then
                    traitDetected = true
                    traitLabel.Text       = "Trait: Flicker"
                    traitLabel.TextColor3 = C.trait
                    confirmEvidence("flicker", motDot, motPill)
                end
            end
            task.wait(INTERVAL)
        end
    end)

    local function checkForTrickster(model)
        if traitDetected then return end
        local main = model:FindFirstChild("Main")
        if not main then return end
        if main:FindFirstChildWhichIsA("BodyForce") then
            traitDetected = true
            traitLabel.Text       = "Trait: Trickster"
            traitLabel.TextColor3 = C.trait
            confirmEvidence("trickster", motDot, motPill)
            return
        end
        main.ChildAdded:Connect(function(child)
            if traitDetected then return end
            if child:IsA("BodyForce") then
                traitDetected = true
                traitLabel.Text       = "Trait: Trickster"
                traitLabel.TextColor3 = C.trait
                confirmEvidence("trickster", motDot, motPill)
            end
        end)
    end
    for _, model in pairs(equipment:GetChildren()) do
        if model:IsA("Model") then checkForTrickster(model) end
    end
    equipment.ChildAdded:Connect(function(child)
        if traitDetected then return end
        if child:IsA("Model") then checkForTrickster(child) end
    end)

    task.spawn(function()
        while true do
            local speed = ghost:GetAttribute("Speed") or 0
            speedVal.Text = "Speed: " .. string.format("%.1f", speed)
            if speed > maxSpeedSeen + 0.2 then
                maxSpeedSeen = speed
                updateGhostLabel()
            elseif speed >= 12 then
                updateGhostLabel()
            end
            task.wait(0.3)
        end
    end)

    if bone then
        local part = bone:IsA("BasePart") and bone
            or bone:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local esp = Instance.new("BillboardGui", part)
            esp.Size = UDim2.new(0, 100, 0, 32); esp.AlwaysOnTop = true
            esp.StudsOffset = Vector3.new(0, 3, 0)
            local txt = Instance.new("TextLabel", esp)
            txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
            txt.Text = "🦴 Bone"; txt.TextColor3 = C.yes
            txt.TextScaled = false; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold
        end
    end

    local ghostESP
    local function createGhostESP(part)
        if ghostESP then ghostESP:Destroy() end
        ghostESP = Instance.new("BillboardGui", part)
        ghostESP.Size = UDim2.new(0, 130, 0, 36); ghostESP.AlwaysOnTop = true
        ghostESP.StudsOffset = Vector3.new(0, 3, 0)
        local txt = Instance.new("TextLabel", ghostESP)
        txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
        txt.Text = "👻 Ghost"; txt.TextColor3 = C.no
        txt.TextScaled = false; txt.TextSize = 14; txt.Font = Enum.Font.GothamBold
    end
    task.spawn(function()
        while true do
            local g = workspace.ServerNPCs:FindFirstChild("GLOBAL")
            if g then
                local part = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
                if part and (not ghostESP or ghostESP.Adornee ~= part) then
                    createGhostESP(part)
                end
            end
            task.wait(1)
        end
    end)

end -- end launchMainUI

if KEY_ENABLED then
    keyScreen.Visible = true
else
    keyScreen.Visible = false
    launchMainUI()
end