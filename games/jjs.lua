-- [jjs] Jujutsu Shenanigans module.
-- The upstream script keeps its own Fluent window and its own keybinds; this
-- module only makes it part of the hub: globals are guarded, dependencies are
-- fetched from the hub mirrors, and the body runs inside one function so the
-- original main chunk keeps its 200-local headroom.
if type(Services) ~= "table" then
	warn("E601")
	return false
end
if type(UI) ~= "table" or type(UI.Window) ~= "table" or type(UI.VLib) ~= "table" then
	warn("E602")
	return false
end
if type(VUniverse) ~= "table" then
	warn("E603")
	return false
end

local jjs = { sources = {}, failed = nil }

do
	local override = nil
	if type(getgenv) == "function" then
		local env = getgenv()
		override = env and env.V_HUB_SOURCE
	end
	if type(override) == "string" and #override > 0 then
		jjs.sources[#jjs.sources + 1] = override
	end
	jjs.sources[#jjs.sources + 1] = "https://ghfast.top/https://raw.githubusercontent.com/OvaLxrding/V/main/"
	jjs.sources[#jjs.sources + 1] = "https://gh-proxy.com/https://raw.githubusercontent.com/OvaLxrding/V/main/"
	jjs.sources[#jjs.sources + 1] = "https://raw.githubusercontent.com/OvaLxrding/V/main/"
	jjs.sources[#jjs.sources + 1] = "https://cdn.jsdelivr.net/gh/OvaLxrding/V@main/"
end

function jjs.cachePath(path)
	return "V Hub/vendor/" .. tostring(path):gsub("^vendor/", "")
end

function jjs.readCache(path)
	local okFile, exists = pcall(function() return isfile(jjs.cachePath(path)) end)
	if not okFile or not exists then return nil end
	local ok, body = pcall(function() return readfile(jjs.cachePath(path)) end)
	if ok and type(body) == "string" and #body > 200 then return body end
	return nil
end

function jjs.writeCache(path, body)
	pcall(function()
		if type(makefolder) == "function" then
			if not isfolder("V Hub") then makefolder("V Hub") end
			if not isfolder("V Hub/vendor") then makefolder("V Hub/vendor") end
		end
		writefile(jjs.cachePath(path), body)
	end)
end

function jjs.fetch(path)
	local cached = jjs.readCache(path)
	if cached then return cached end
	for index = 1, #jjs.sources do
		local ok, body = pcall(function() return game:HttpGet(jjs.sources[index] .. path) end)
		if ok and type(body) == "string" and #body > 200 then
			jjs.writeCache(path, body)
			return body
		end
	end
	jjs.failed = path
	return nil
end

function jjs.require(path, name)
	local body = jjs.fetch(path)
	if not body then return nil end
	local chunk = loadstring(body, name)
	if type(chunk) ~= "function" then
		jjs.failed = path
		return nil
	end
	local ok, module = pcall(chunk)
	if not ok or module == nil then
		jjs.failed = path
		return nil
	end
	return module
end

if type(getgenv) == "function" then
	pcall(function() getgenv().GojoDomainLoaded = nil end)
end

local function jjsRun()
-- PATCH P14: Keybinds fixed on PC + mobile. Saved keys now really rebind after rejoin/autoload
-- (Fluent's SetValue never ran ChangedCallback, so only the label changed). Mouse picks are
-- rejected instead of silently binding KeyCode.Unknown, duplicate keys are warned about,
-- choosing a key / typing / hub-sent presses (Auto QTE, Haruta slot 2) never fire a bind,
-- Left Ctrl descends while flying (Right Ctrl still toggles the hub), and mobile no longer
-- shows keyboard-only Combo Recorder pickers. Offline compile only; live test required.
-- PATCH P13: Smart M1 Auto Block -- instant per-animator detection for every moveset's M1s,
-- measured-RTT ping compensation, FPS-independent time leases, combo-chain holds, predicted
-- reach + facing gate (never from behind), snap+track facing, resend-until-confirmed block.
-- PATCH P12: working-reference M1 debounce/re-activation restored; Auto Punish stays separate.
-- Melee blocks require <=5 studs and not being behind the attacker. Dash/projectiles independent.
-- Moving-player relative collision entry, launch-ray rechecks, bounded live tracking and tail holds.
-- Passed projectiles immediately relinquish facing; manual block, BF, Solo and hard CC preserved.
-- Removed the unsolicited Combat filter paragraph. Offline validation only; live test required.
-- PATCH P11: v109's blocking native tap/hold/release sequence and calibrated timing restored.
-- Impact-timed polar dash, adaptive motion/yaw prediction, short back-sync hold, wall clamps.
-- P10-only transient lock/lease/return-value aborts removed; hard CC/death/respawn still cancel.
-- Desktop Three tickets + mobile original UseKey preserved; competing auto-defense yields.
-- Todo and the rest of P10 remain intact. Offline validation only; live game testing required.
-- PATCH P10: v109 BF timing + platform-native input restored; one pinned input route
-- per pair, deadline-based re-input, queued-key bypass tickets, and guarded move completion.
-- Todo swaps are serialized, track range during a ping-aware 100-180ms settle, and use
-- slightly longer origin holds with exact-character cleanup + observed-arrival diagnostics.
-- Offline compilation/mock tests only. Sending inputs is NOT proof of server acceptance.
-- PATCH P9: Items explicitly restore the pre-grab CFrame/velocity on success or error,
-- independent of AC snapback. Serialized grabs preserve the camera remote's prior parent.
-- BF keeps the configured native tap interval: latency leads impact prediction, not the
-- two-input gap. Re-input survives ordinary first-hit knockback; hard leashes remain.
-- Nonblocking tap holds, guarded native routing and timing diagnostics; live testing required.
-- PATCH P8: missing mobile keybind actions use the unchanged native float-button factory.
-- Flat Keybinds tab: opt-in Invisibility, Rotate Lock-On, Auto Block, Void/Reset,
-- Sweep Stop and Combo Panic Stop buttons. Existing mobile controls remain intact.
-- Auto Block has a rebindable PC key (K), a base toggle, and synced Solo Block state.
-- PATCH P7: Invisibility (I) and Rotate Locked-On Target (T) have synced inline/master keybinds.
-- One guarded keyboard dispatcher; canonical saved bindings keep both controls in sync.
-- PATCH P6: stay-hidden hit protection is built into Invisibility; no separate toggle.
-- Removed the optional hit-animation mute setting and its broader suppression logic.
-- PATCH P5: Black Flash initializer isolated to fix the -O0 local-register overflow.
-- PATCH P4: v109 lock-on methods restored; Console body and orbit camera have independent easing.
-- Body facing runs after the camera/game pass, yielding to Black Flash and defense ownership.
-- Black Flash retains the locked target and has a late-frame facing pass; no synthetic camera
-- steering while the live lock-on owns the camera. Invis hit protection no longer restarts a
-- playing frozen pose every frame; shiftlock follows smoothly without changing movement velocity.
-- Offline Luau compilation + mocked regression tests only; Roblox/server behavior needs live testing.
-- ============================================================
-- NIGGA HUB — ULTIMATE EDITION
-- Updated base · v5.5.9r3 Bisect02 (Earthquake Fixed / No Anti-Team / No Alt Farm) · Native remote-gated Mahoraga Earthquake hold/release · Shared AC / Move-Safe No Stun / Todo Void Fixes · Stability+Perf Fixes · Auto Dash Predict v3 · Garuda v4.1 · Anti-CC v2.3.0 Move-Safe
-- ============================================================

local getgenv = getgenv or function() return _G end
if getgenv().GojoDomainLoaded then return end
getgenv().GojoDomainLoaded = true
getgenv().NH_HubBooting = true

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local StarterGui        = game:GetService("StarterGui")
local TweenService      = game:GetService("TweenService")
local InsertService     = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local mobile      = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local _lastDomainRebuild = 0

_G.mainFloatGuis = {}
_G.flyFloatGuis = {}
_G.NH_btnManual = {}

_G.NH_floatBtns = {}
_G.NH_btnLocked = false
_G.NH_boostVisible = false  -- optional manual pin; flight now surfaces its controls automatically
_G.NH_upDownVisible = false -- optional manual pin; Up/Down also surface automatically while flying
-- Mobile feature buttons automatically follow their matching feature toggles.
-- Manual-pin switches remain available (normally in Keybinds; Auto Backdash is
-- grouped with its Combat toggle), but they are no longer required just to get
-- a button after enabling a feature.
_G.NH_btnScale = 1
_G.NH_ApplyBtnScale = function(scale)
    _G.NH_btnScale = scale
    for _, e in ipairs(_G.NH_floatBtns) do
        if e.f and e.f.Parent then
            local sz = math.floor((e.base or 60) * scale)
            e.f.Size = UDim2.fromOffset(sz, sz)
        end
    end
end

_G.mainOverlayMaster = false
-- These two used to write .Enabled directly on EVERY float button, so flipping the
-- emote toggle flashed the whole button set onto the screen for a frame before the
-- visibility gate pulled them back off again. They are HIDE-ONLY now: switching
-- something off still takes effect instantly; the feature-aware visibility table
-- below is responsible for restoring only the buttons that should be visible.
_G.ToggleMainOverlay = function(v)
    _G.mainOverlayMaster = v and true or false
    if not v then
        for _, g in ipairs(_G.mainFloatGuis) do g.Enabled = false end
    end
end
_G.ToggleFlyControls = function(v)
    if not v then
        for _, g in ipairs(_G.flyFloatGuis) do g.Enabled = false end
    end
end

-- ============================================================
-- CONFIG & STATE
-- ============================================================
local Cfg = {
    INCLUDE_NPCS        = true,
    MAX_HUNT_ATTEMPTS   = 50,
    RESPAWN_WAIT        = 1.3,
    STABILITY_DURATION  = 0.85,
    SNAP_THRESHOLD      = 8,
    MIN_TARGET_DISTANCE = 55,
    offsetX = 0, offsetY = 0, offsetZ = 2,
    tpMode      = "under",
    tpMethod    = "default",
    sweepMode   = "normal",
    tpPriority  = "normal",
    fallenHeight = -1000,
    -- ROTATE TARGET: orbit the selected target at high speed. The angle advances at
    -- rotateSpeed radians/sec (frame-rate independent). Velocity prediction reads the
    -- target's real velocity (AssemblyLinearVelocity, with a position-delta fallback
    -- for CFrame-animated targets) and orbits where they are HEADED, scaled by
    -- rotateLead -- so a running/dashing target drags us around ahead of them instead
    -- of leaving the orbit trailing behind their old position.
    rotateSpeed = 11, rotateRadius = 6, rotateLead = 0.30,
    -- PATCH P3: grab-proof rotate. Short target blips are held for rotateLockGrace seconds;
    -- orbit frames are skipped (paused, not stopped) while the game anchors us/the target.
    rotateLockGrace = 2.5, rotatePauseWhenAnchored = true,
    -- Built-in invisibility hit protection: keep the frozen pose on top of hit-stun anims.
    invisBurstTime = 1.2,
    BF = {
        Duration = 0.25, Radius = 3, Range = 60, CurveStrength = 14, CamOffset = 2, PredictionMultiplier = 0.6,
        LandingLinger = 0.2, BackAngleDot = 0.5, BehindDist = 4.0, FacingDot = 0.3, GlideCurveK = 0.6,
    },
    BF_AnimationTriggers = {
        ["rbxassetid://100962226150441"] = 0.19,
        ["rbxassetid://95852624447551"]  = 0.19,
        ["rbxassetid://74145636023952"]  = 0.19,
        ["rbxassetid://72475960800126"]  = 0.20,
    },
    BF_StraightAnimations = { ["rbxassetid://123171106092050"] = true },
    BF_DASH_ANIM_LEFT  = "rbxassetid://117223862448096",
    BF_DASH_ANIM_RIGHT = "rbxassetid://75203303352791",
    DRONE_ID          = 17865400476,
    SHRINK_ANIM_ID    = "rbxassetid://75390215999547",
    INVIS_ANIM_ID     = "rbxassetid://108081843941348",
    INVIS_FREEZE_TIME = 7,
    FlySpeed = 150,
    LockOn = { Method = "Console", SideOffset = 0, Smoothness = 0.15, MaxDistance= 150, ESP = false, MarkerImage = 87061703528307 },
}

local EMOTE_LIST = {
    {name="Mahito Itadori", id=105199432380841}, {name="Waste of Time", id=5775509840},
    {name="Ganbare Ganbare", id=128755610900618}, {name="Heavenly Ramble", id=82476745705122},
    {name="Satoru Gojo", id=6265242673}, {name="Huh", id=16363777391},
    {name="Don", id=12917642257}, {name="Sorry Nanami", id=18680487885},
    {name="Mambo", id=97871211303571}, {name="What Are U Mahito", id=71411567772779},
    {name="Idk This Guy", id=78044670447386}, {name="Yowai Mo", id=7948969023},
    {name="You Did It", id=99137255050147}, {name="My Besto Frendo", id=129622474979733},
    {name="Besto Frendo", id=18257697094}, {name="Convergence", id=15917626934},
    {name="Where U Going", id=96326653225562}, {name="Next", id=7061369096},
    {name="Toji Fushiguro", id=6743603446}, {name="Apologize", id=15753185070},
    {name="Disrespectful Rush", id=136335654594541}, {name="Hidoi Na", id=106755448566954},
    {name="Nanami Sigh", id=10173613362}, {name="You Cryin", id=112599702984099},
    {name="Laugh", id=18319797565}, {name="Words Are Unnecessary", id=134719689134074},
    {name="Jackpot", id=108907296117028}, {name="Stand Proud", id=100445971002729},
    {name="Forreal", id=7061190867}, {name="Veri Angri", id=13997948756},
    {name="Slap Vibra", id=18246120711}, {name="Majika", id=16159090773},
    {name="Somethin Off", id=131371183130808}, {name="Yujiiii", id=89667437228243},
    {name="Yo Long Time", id=7061193663}, {name="Oi", id=18370175258}, {name="Idiot", id=137318879402973},
}

local emoteSelectedIndex = 1
local function fireEmote(id) pcall(function() ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("JoinService"):WaitForChild("RE"):WaitForChild("Talk"):FireServer(id) end) end
local function fireSelectedEmote() local e = EMOTE_LIST[emoteSelectedIndex] if e then fireEmote(e.id) end end
local function getEmoteNames() local n = {} for _, e in ipairs(EMOTE_LIST) do table.insert(n, e.name) end return n end
local function setEmoteIndex(name) for i, e in ipairs(EMOTE_LIST) do if e.name == name then emoteSelectedIndex = i; return end end end

local St = {
    sweepActive = false, huntRunning = false, acBypassHunting = false, luckyCycleFound = false,
    noDomainTP = false, voidMethodSit = false, overlayEnabled = true,
    attachActive = false, attachTarget = nil, attachLoopId = 0, safeTpActive = false,
    bfEnabled = false, bfGlideActive = false, bfPingDelay = 0.12, bfMode = "blatant",
    flyActive = false, flyOriginalFOV = 70, noStunConn = nil, shrinkHitboxActive = false, invisActive = false,
    hitboxLoaded = false, invisLoaded = false, emotesLoaded = false, instantBHLoaded = false, wallhopMetaHooked = false,
    flyCharacter = nil, flyHumanoid = nil, flyRootPart = nil, flyAnimator = nil, flyBodyVelocity = nil, flyBodyGyro = nil, flyToggleOn = false, flyWasMoving = false,
    flyIdleTrack = nil, flyMoveTrack = nil, flyBoostTrack = nil, flyRightTrack = nil, flyLeftTrack = nil, flyBackTrack = nil, flyCurrentAnimState = nil,
    whitelist = {}, originalFallenHeight = Workspace.FallenPartsDestroyHeight,
    dashMultiplierEnabled = false, dashMultiplierValue = 1, yonkEnabled = false, yonkSpeed = 1, yonkAnimTrack = nil, yonkAnim = nil,
    autoQteEnabled = false, qteSpeed = 15, autoDownslamEnabled = false, downslamMode = "blatant", autoUppercutEnabled = false, lockOnEnabled = false, lockOnOrigAutoRotate = true, lockOnToggleOn = false, lockOnTarget = nil, lockOnArmed = false,
    todoEnabled = false, todoBlackFlashEnabled = false, todoVoidEnabled = false, todoSweepVariantEnabled = false, autoBlockEnabled = false, autoDashPredictEnabled = false, autoPunishEnabled = false, autoBlockBreakEnabled = false, dashBehindTargetEnabled = false, antiAfkEnabled = false, autoProjBlockEnabled = false, autoHarutaDodgeEnabled = false,
    todoSwapEnabled = false, todoSwapAcBypassed = false, todoSwapReturn = false, todoSwapSelected = "",
    todoSwapHunting = false, todoSwapAreaEnabled = false, todoSwapArea = "Restaurant",
    harutaBackstabEnabled = false,
    rotateActive = false, rotateTarget = nil, rotateFollowLockOn = false, rotateAngle = 0, rotateLastPos = nil, rotateLastT = 0, rotateVel = Vector3.zero,
    rotateSoftSince = nil, -- Rotate retains its own grab-pause grace; lock-on uses v109 validation.
    bfChainBtnEnabled = false,
    harutaBsBtnEnabled = false,
    autoWorldSlashEnabled = false, autoFrogVariantEnabled = false, autoEarthquakeEnabled = false, autoShutUpEnabled = false, autoMahoragaThrowEnabled = false, itemEspEnabled = false,
    flashStepM1Enabled = false, flashStepM1Range = 20,
    instantRespawnEnabled = false,
    huntDefaultRespawnActive = false,
    autoCounterEnabled = false, autoCounterRange = 22, autoCounterBusy = false, autoCounterCooldown = 0,
    -- AUTO BLOCK SOLO TARGET: when autoBlockSoloEnabled, locking onto someone makes every
    -- auto-block detection path serve ONLY them (see _G.NH_AutoBlockSolo above the do block).
    autoBlockSoloEnabled = false, autoBlockSoloTarget = nil,
    bfLastAttackTime = {}, bfTargetLookSmoothed = {}, bfPrevTargetPos = {}, bfPrevTargetTime = {},
    StatusParagraph = nil, invisAnimTrack = nil, invisCamAnchor = nil, invisPrevCamSubject = nil,
}

-- Companion feature packs read this exact table instead of maintaining stale
-- copies of private hub toggles such as Todo Void and lock-on state.
getgenv().NH_HubState = St
_G.NH_HubState = St

local Cn = {
    noclipConn = nil, invisCharConn = nil, shrinkCharConn = nil, noDashCooldownConn = nil, wallhopConn2 = nil, bfHeartbeatConn = nil, bfCharConn = nil, bfPlayerAddedConn = nil, bfPlayerRemovingConn = nil, bfAttackConns = {}, 
    flyConnection = nil, nanamiRatioConn = nil, qteGuiAddedConn = nil, yonkCharConn = nil, dashMultCharConn = nil, lockOnConn = nil, attachLoopConn = nil, todoAnimConn = nil, autoCounterConn = nil, autoCounterAnimConn = nil,
    toggleKeybindConn = nil, -- shared Invisibility / Rotate / Auto Block keyboard dispatcher
}

local Keys = {
    sweepKey = Enum.KeyCode.E, huntKey = Enum.KeyCode.Y, stopKey = Enum.KeyCode.H, bfKey = Enum.KeyCode.G, dashBehindTargetKey = Enum.KeyCode.B, flyKey = Enum.KeyCode.X, yonkKey = Enum.KeyCode.J, lockOnKey = Enum.KeyCode.C, voidKey = Enum.KeyCode.V, emoteKey = Enum.KeyCode.Z, harutaBsKey = Enum.KeyCode.Two, bfChainKey = Enum.KeyCode.Three,
    rotateLockOnKey = Enum.KeyCode.T, -- toggles "Rotate Locked-On Target"
    invisKey = Enum.KeyCode.I, -- toggles the existing Invisibility option
    autoBlockKey = Enum.KeyCode.K -- toggles Auto Block (rebindable in Keybinds)
}
-- PATCH P14: keyboard presses the hub sends itself (Auto QTE letters, Haruta's slot-2
-- press) must never be read back as one of YOUR binds -- e.g. a QTE "V" firing Void.
St.syntheticKeys = {}
function St.MarkSyntheticKey(kc, dur)
    if typeof(kc) == "EnumItem" then St.syntheticKeys[kc] = os.clock() + (dur or 0.35) end
end
function St.IsSyntheticKey(kc)
    local untilT = kc and St.syntheticKeys[kc]
    if untilT and os.clock() < untilT then return true end
    return St.bfIsSyntheticKey ~= nil and St.bfIsSyntheticKey(kc) == true
end
-- One gate for every hub keyboard shortcut: typing in a box, choosing a new key in
-- the UI, or a hub-generated press never triggers a bound action.
function St.HubKeyBlocked(kc)
    if UserInputService:GetFocusedTextBox() then return true end
    if St.KeyBinds and St.KeyBinds.IsPicking() then return true end
    return St.IsSyntheticKey(kc)
end
local flyKeys = { W=false, A=false, S=false, D=false, Up=false, Down=false, Boost=false }

-- ============================================================
-- UTILS & HOOKS
-- ============================================================
local function notify(title, text, dur)
    if getgenv().NH_HubBooting then return end
    pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 4}) end)
end
local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255, 255, 255)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end
local function setStatus(text) if St.StatusParagraph then pcall(function() St.StatusParagraph:SetText(text) end) end end

local mt = getrawmetatable(game)
local oldNc = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    -- PERF: this hook intercepts EVERY namecall in the game (tens of thousands per
    -- frame). r3 called getnamecallmethod() unconditionally on that volume, which is
    -- the PC-only FPS-drop source (mobile/Delta blocks this hook entirely, so it paid
    -- zero -- that is exactly the PC-vs-mobile split you saw).
    --
    -- The fix restores the r2-style short-circuit WITHOUT changing r3 behaviour:
    -- getnamecallmethod() is only reached when one of the two features that need it is
    -- actually live. The gate still fires on FireServer whenever the earthquake remote
    -- gate is installed, and the Parkour interception still only fires while wallhop is
    -- hooked -- byte-for-byte the r3 logic, just without paying for it every frame.
    if not St.wallhopMetaHooked and rawget(_G, "NH_EarthquakeRemoteGate") == nil then
        return oldNc(self, ...)
    end

    local method = getnamecallmethod()

    -- Earthquake final-boundary gate: hold the actual outbound Deactivated
    -- remote rather than only suppressing a ToolController callback.
    if method == "FireServer" then
        local gate = rawget(_G, "NH_EarthquakeRemoteGate")
        if type(gate) == "function" then
            local ok, suppress = pcall(gate, self, table.pack(...))
            if ok and suppress then return nil end
        end
    end

    if St.wallhopMetaHooked and method == "GetAttribute" and (...)=="Parkour" and self.Name=="Info" then return nil end
    return oldNc(self, ...)
end)
setreadonly(mt, true)

LocalPlayer.Idled:Connect(function()
    if St.antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

local PlayerModuleControls = nil
task.spawn(function()
    local ok, pm = pcall(function() return require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 5)) end)
    if ok and pm then PlayerModuleControls = pm:GetControls() end
end)

-- ============================================================
-- MOBILE TOUCH-CONTROL GUARD  (joystick + jump button protector)
-- ------------------------------------------------------------
-- ROOT CAUSE of the "black-flash steals my joystick" bug: the hub fakes input
-- via VirtualInputManager in several places -- the BF flash keys (KeyCode.Three),
-- the Auto-QTE handler, and the M1 fallback. On a touch device every synthetic
-- keyboard/mouse event flips UserInputService.LastInputType away from Touch, and
-- Roblox's PlayerModule then auto-disables the on-screen thumbstick + jump button
-- until the next real touch. This guard re-enables the touch controls the instant
-- that happens, so faking input can never take the player's movement UI again.
-- ============================================================
-- ============================================================
-- GAME'S OWN MOBILE BUTTONS (PlayerGui.Controls.Mobile: Melee/Block/Dash/Special/ShiftLock)
-- ------------------------------------------------------------
-- Confirmed by live source inspection of ToolController: a RenderStepped loop only KEEPS
-- Controls.Mobile visible WHILE ToolController.LastInput == "Mobile". Our synthetic BF key flips
-- UserInputService.PreferredInput -> KeyboardAndMouse, so the game sets LastInput = "Keyboard",
-- runs its tag-visibility pass (hiding every "Mobile"-tagged GuiObject), and the loop then STOPS
-- touching Mobile -- so just forcing Mobile.Visible = true loses again the very next frame.
-- THE reliable fix (no real touch required): (1) patch ToolController.LastInput back to "Mobile"
-- so the loop re-shows AND sustains the buttons, and (2) re-run the CollectionService tag pass
-- ourselves (exactly what the game's internal u19() does).
local NH_ToolController = nil
local function nhGetToolController()
    if NH_ToolController then return NH_ToolController end
    pcall(function()
        local Knit = require(ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"))
        NH_ToolController = Knit.GetController("ToolController")
    end)
    return NH_ToolController
end
local function restoreMobileControls()
    if not mobile then return end
    -- (1) Patch the field the game's RenderStepped loop reads, so it re-shows + SUSTAINS the buttons.
    pcall(function()
        local tc = nhGetToolController()
        if tc then tc.LastInput = "Mobile" end
    end)
    -- (2) Re-run the platform tag visibility (mirror of the game's u19()): hide non-touch UI, then
    -- show every "Mobile"-tagged GuiObject (Controls.Mobile is tagged "Mobile").
    pcall(function()
        for _, platform in ipairs({ "Keyboard", "Playstation", "Xbox" }) do
            for _, obj in ipairs(CollectionService:GetTagged(platform)) do
                if obj:IsA("GuiObject") then obj.Visible = false end
            end
        end
        for _, obj in ipairs(CollectionService:GetTagged("Mobile")) do
            if obj:IsA("GuiObject") then obj.Visible = true end
        end
    end)
end
local function restoreTouchControls()
    if not mobile then return end
    -- (1) Re-enable the control module. Re-acquire a FRESH handle if our cached one
    -- is missing/stale (require is cached, so this is cheap). The initial capture
    -- could fail or go stale after a respawn -- that was a reason controls sometimes
    -- never came back at all.
    pcall(function()
        local pm = PlayerModuleControls
        if not (pm and pm.Enable) then
            local mod = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 2))
            pm = mod and mod:GetControls()
            PlayerModuleControls = pm
        end
        if pm and pm.Enable then pm:Enable() end
    end)
    -- (2) Force the master touch GUI back on.
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local tg = pg and pg:FindFirstChild("TouchGui")
        if tg and not tg.Enabled then tg.Enabled = true end
    end)
    -- (2b) THE ACTUAL FIX for "the BF chain eats my joystick": Jujutsu Shenanigans does NOT use
    -- Roblox's default thumbstick. It has its OWN on-screen controls at PlayerGui.Controls (a
    -- ScreenGui) with a "Mobile" frame -- that frame IS your joystick + jump + ability buttons
    -- (it's where the Special button lives). The game HIDES this whole GUI the instant
    -- LastInputType flips to Keyboard, which our synthetic BF key does. Re-enabling only the
    -- default TouchGui above never brought your stick back because the stick lives HERE. Force
    -- the game's own controls GUI + its Mobile frame (and direct children) visible again.
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local controls = pg and pg:FindFirstChild("Controls")
        if controls then
            if controls:IsA("ScreenGui") and not controls.Enabled then controls.Enabled = true end
            local mob = controls:FindFirstChild("Mobile")
            if mob then
                if mob:IsA("GuiObject") and not mob.Visible then mob.Visible = true end
                for _, ch in ipairs(mob:GetChildren()) do
                    if ch:IsA("GuiObject") and not ch.Visible then ch.Visible = true end
                end
            end
        end
    end)
    -- (2c) Patch ToolController.LastInput back to "Mobile" + re-run the CollectionService tag pass
    -- so the game's OWN RenderStepped loop re-shows and SUSTAINS Controls.Mobile every frame. This
    -- is the real "the buttons live here and the game keeps hiding them" fix (per source).
    restoreMobileControls()
    -- (3) THE KEY FIX: our synthetic KEYBOARD event (the BF move key) flipped
    -- UserInputService.LastInputType to Keyboard, so Roblox's control module HID the
    -- thumbstick/jump until the next *real* touch -- which never came, so they were
    -- "gone for good." Nudge LastInputType back to Touch with a harmless corner touch
    -- so the engine immediately re-shows the on-screen controls.
    pcall(function()
        local id = 91237
        -- Reset LastInputType to Touch so the engine re-shows the thumbstick + jump button.
        -- Executors DISAGREE on SendTouchEvent's argument order, and if we use the wrong one it
        -- silently no-ops (caught by pcall) -- which is exactly why the synthetic key used to
        -- kill the joystick "for good": the reset never actually registered. So we fire BOTH
        -- common forms; whichever the executor accepts registers a real touch (the position is
        -- irrelevant for the input-type reset), and the DynamicThumbstick is rebuilt.
        local function cornerTouch(stateVal)
            pcall(function() VirtualInputManager:SendTouchEvent(id, stateVal, 3, 3) end) -- (id, state, x, y)
            pcall(function() VirtualInputManager:SendTouchEvent(id, 3, 3, stateVal) end) -- (id, x, y, state)
        end
        cornerTouch(Enum.UserInputState.Begin.Value)
        cornerTouch(Enum.UserInputState.End.Value)
    end)
end
-- LIGHTWEIGHT per-frame force: just flips the master TouchGui + the thumbstick/jump frame
-- back on. Cheap enough to call every RenderStepped frame (no require, no SendTouchEvent),
-- which is the only way to keep the controls from blinking out while we spam synthetic keys.
local function forceTouchVisible()
    if not mobile then return end
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local tg = pg and pg:FindFirstChild("TouchGui")
        if tg then
            if not tg.Enabled then tg.Enabled = true end
            local tcf = tg:FindFirstChild("TouchControlFrame")
            if tcf and not tcf.Visible then tcf.Visible = true end
        end
        -- ALSO keep the game's OWN mobile controls (PlayerGui.Controls.Mobile -- the real
        -- joystick + jump + ability buttons) shown every frame; the synthetic BF key keeps
        -- hiding this game GUI, and THAT -- not the default TouchGui -- is the joystick you lose.
        local controls = pg and pg:FindFirstChild("Controls")
        if controls then
            if controls:IsA("ScreenGui") and not controls.Enabled then controls.Enabled = true end
            local mob = controls:FindFirstChild("Mobile")
            if mob and mob:IsA("GuiObject") and not mob.Visible then mob.Visible = true end
        end
        -- Keep ToolController.LastInput == "Mobile" so the game's own RenderStepped loop SUSTAINS
        -- Controls.Mobile (forcing Mobile.Visible alone loses to that loop unless LastInput matches).
        local tc = NH_ToolController
        if tc then tc.LastInput = "Mobile" end
    end)
end
-- re-assert across a few frames so it wins regardless of signal ordering with the engine
local function reassertControls()
    if not mobile then return end
    for _, d in ipairs({0, 0.03, 0.08, 0.16, 0.3}) do task.delay(d, restoreTouchControls) end
end
-- HARD rebuild: a plain pm:Enable() (in restoreTouchControls) often is NOT enough after a
-- synthetic KEY event leaves the control module in keyboard mode -- it keeps the (now hidden)
-- old thumbstick, so on Delta the joystick stays gone after a flash. Disable() then Enable()
-- forces the module to tear DOWN and rebuild the DynamicThumbstick from scratch -- the standard
-- way to get a stuck-off mobile joystick back. We run this ONCE after the flash chain settles.
local function rebuildTouchControls()
    if not mobile then return end
    pcall(function()
        local mod = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 2))
        local pm = mod and mod:GetControls()
        if pm then
            PlayerModuleControls = pm
            pcall(function() pm:Disable() end)
            task.wait(0.05)
            pcall(function() pm:Enable() end)
        end
    end)
    restoreTouchControls()
end
if mobile then
    -- whenever the engine switches away from touch (caused by our synthetic input), restore.
    -- MUST use the LastInputTypeChanged EVENT, never GetPropertyChangedSignal("LastInputType"):
    -- "LastInputType" is NOT a real property, so strict executors (e.g. Delta / fresh GitHub
    -- runs) THROW "LastInputType is not a valid property name" and kill the WHOLE script before
    -- any UI builds. Lenient executors (some PC ones) silently allowed it, which hid the bug.
    UserInputService.LastInputTypeChanged:Connect(function(lastType)
        if (lastType or UserInputService:GetLastInputType()) ~= Enum.UserInputType.Touch then reassertControls() end
    end)
    -- backstop: if the master TouchGui ever gets flagged off, flip it back
    local function hookTouchGui()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local tg = pg and pg:FindFirstChild("TouchGui")
        if tg then
            pcall(function()
                tg:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if not tg.Enabled then task.defer(restoreTouchControls) end
                end)
            end)
        end
    end
    local pg0 = LocalPlayer:FindFirstChild("PlayerGui")
    if pg0 then
        hookTouchGui()
        pg0.ChildAdded:Connect(function(c) if c.Name == "TouchGui" then task.wait(0.1); hookTouchGui() end end)
    end
    -- touch controls are rebuilt on respawn -> re-hook and re-assert
    LocalPlayer.CharacterAdded:Connect(function() task.delay(0.6, function() hookTouchGui(); reassertControls() end) end)
    -- PERSISTENT POLL GUARD -- the real fix for "BF chain killed my joysticks for good":
    -- LastInputTypeChanged only fires on a CHANGE. Once a synthetic BF key (KeyCode.Three)
    -- leaves LastInputType STUCK on Keyboard and no real touch follows, NO further event
    -- ever fires, so the event-driven restore never runs and the joystick + jump button
    -- stay hidden indefinitely. This poll detects the stuck non-touch state and restores.
    -- It is self-limiting: restoreTouchControls() sends a harmless corner touch that flips
    -- LastInputType back to Touch, so on a real touch device it only kicks in right after
    -- our synthetic keys, then goes idle (no thumbstick reset while you're actually moving).
    task.spawn(function()
        while true do
            task.wait(0.12)
            if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
                restoreTouchControls()
            end
        end
    end)
end

-- ============================================================
-- TARGETS & CACHE
-- ============================================================
local domainsFolder = Workspace:FindFirstChild("Domains")
local domainPartsCache = {}; local cacheBuilding = false
local function rebuildDomainCache()
    if cacheBuilding then return end
    cacheBuilding = true
    task.spawn(function()
        local nc = {}
        if domainsFolder then for _, obj in ipairs(domainsFolder:GetDescendants()) do if obj:IsA("BasePart") then table.insert(nc, obj) end end end
        domainPartsCache = nc; cacheBuilding = false
    end)
end
rebuildDomainCache()
if domainsFolder then
    domainsFolder.ChildAdded:Connect(function() task.wait(0.5); rebuildDomainCache() end)
    domainsFolder.ChildRemoved:Connect(function() task.wait(0.1); rebuildDomainCache() end)
end
local function isInsideDomainRaw(worldPos)
    for _, part in ipairs(domainPartsCache) do
        if part and part.Parent then
            local lp = part.CFrame:PointToObjectSpace(worldPos); local h = part.Size / 2
            if math.abs(lp.X)<=h.X and math.abs(lp.Y)<=h.Y and math.abs(lp.Z)<=h.Z then return true end
        end
    end
    return false
end
local function isTargetInsideDomain(target) return target.Core and isInsideDomainRaw(target.Core.Position) end

local _npcCache = {}; local _npcCacheTime = 0
local function getValidTargets(myHRP)
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local core = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
            if hum and core and hum.Health > 0 then 
                table.insert(targets, 1, {Humanoid=hum, Core=core, Char=p.Character, name=p.Name}) 
            end
        end
    end
    
    if Cfg.INCLUDE_NPCS then
        if tick() - _npcCacheTime > 2 then
            _npcCacheTime = tick(); _npcCache = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Humanoid") and obj.Health > 0 then
                    local model = obj.Parent
                    if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                        local core = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
                        if core then table.insert(_npcCache, {Humanoid=obj, Core=core, Char=model, name=model.Name}) end
                    end
                end
            end
        end
        for _, t in ipairs(_npcCache) do 
            if t.Humanoid and t.Humanoid.Health > 0 and t.Core.Parent then table.insert(targets, t) end 
        end
    end
    return targets
end

local function getSweepTargets(myHRP)
    local tgts = getValidTargets(myHRP); local filtered = {}
    for _, t in ipairs(tgts) do
        if not St.whitelist[t.name] then
            if St.noDomainTP and isTargetInsideDomain(t) then else table.insert(filtered, t) end
        end
    end
    if Cfg.tpPriority == "hppct" then table.sort(filtered, function(a, b) return (a.Humanoid.Health / a.Humanoid.MaxHealth) < (b.Humanoid.Health / b.Humanoid.MaxHealth) end) end
    return filtered
end

local function getAttackCFrame(myHRP, targetCore)
    local tp = targetCore.Position
    if Cfg.tpMode == "under" then
        local bp = Vector3.new(tp.X+Cfg.offsetX, tp.Y-3-math.abs(Cfg.offsetY), tp.Z+Cfg.offsetZ)
        return CFrame.new(bp) * CFrame.Angles(math.pi/2, 0, 0), bp
    else
        local tcf = targetCore.CFrame
        local ap  = tp + tcf.LookVector*Cfg.offsetZ + tcf.RightVector*Cfg.offsetX + Vector3.new(0, Cfg.offsetY, 0)
        return CFrame.new(ap, Vector3.new(tp.X, ap.Y, tp.Z)), ap
    end
end

local function smartTP(myHRP, targetCF, frames)
    frames = frames or 11; if not myHRP then return end
    local count = 0; local conn
    conn = RunService.Heartbeat:Connect(function()
        count = count + 1; pcall(function() myHRP.CFrame = targetCF end)
        if count >= frames then conn:Disconnect(); pcall(function() myHRP.CFrame = targetCF end) end
    end)
end
-- ============================================================
-- INSTANT RESPAWN ENGINE v5  (integrated)
-- ------------------------------------------------------------
-- ONE fast-death engine shared by the whole hub. Two ways in:
--   * _G.NH_Respawn.SetAuto(true)  -- Extras > "Instant Respawn": the moment
--     you die, the engine drives the fastest possible respawn on its own.
--   * _G.NH_Respawn.Await(timeout) -- BLOCKING fast helper for the Extras
--     "Respawn Now" button. Gojo/Todo hunt loops deliberately use the game's
--     normal Reset -> CharacterAdded flow instead; the Extras auto toggle and
--     manual Force Reset/keybind behavior are otherwise unchanged.
--
-- MECHANISM: the server only accepts the death once it samples our root far
-- outside the map, so we alternate the root between the void and its real
-- CFrame every Heartbeat for a short hold, fire JoinService.RE.Reset shortly
-- after, and RETRY on a tight ~450ms cadence until the server acknowledges.
-- Retrying is the actual fix: a single pulse is unreliable, a retried pulse is
-- not. There are no dead gaps, so a death that used to take 1.5-5s lands in a
-- few hundred ms. Every exit path restores the captured CFrame and zeroes both
-- velocities, so we never fall through the map or crash into the ground.
--
-- !! IMPORTANT -- WHY THIS IS AN IIFE AND NOT A do...end BLOCK !!
-- This main chunk sits at EXACTLY Lua's 200-active-locals-per-function limit.
-- Declaring even one extra local at this scope makes the WHOLE FILE fail to
-- compile, so the hub silently never executes. Wrapping the engine in an
-- immediately-invoked function puts all ~57 of its locals in their own scope,
-- and storing the result on _G instead of a local keeps our footprint at ZERO
-- new main-chunk locals. Do not convert this to `local X = ...` or `do ... end`.
-- ============================================================
_G.NH_Respawn = (function()
    -- If the standalone NH Instant Respawn is also loaded, shut it down so the
    -- two engines can never pulse the same root against each other.
    pcall(function()
        local prev = rawget(getgenv(), "NHInstantRespawn")
        if prev and type(prev.Destroy) == "function" then prev:Destroy() end
    end)

    local CFG = {
        Hold        = 0.12,   -- how long the root is held at the void per attempt
        ResetAt     = 0.25,   -- when inside an attempt the Reset remote fires
        RetryEvery  = 0.45,   -- attempt cadence -- no dead gaps
        MaxAttempts = 16,
        SpawnGuard  = 0.20,   -- the game drops death pulses fired right after CharacterAdded
        VoidY       = 10000,
        SettleWait  = 0.05,   -- tiny post-respawn settle before callers continue
    }

    local API = {
        Auto = false, Busy = false,
        Count = 0, Attempts = 0, LastAttempts = 0,
        LastMs = 0, BestMs = 0, Fails = 0,
        Config = CFG,
    }

    local token      = 0
    local bornAt     = os.clock()
    local cycleStart = 0
    local queued     = false
    local diedConn, healthConn

    -- Resolve an executor global without getfenv (getfenv deoptimises the whole
    -- enclosing function in Luau, and some executors sandbox it oddly).
    local replicatesignalFn
    pcall(function()
        local v = replicatesignal
        if type(v) == "function" then replicatesignalFn = v end
    end)
    if not replicatesignalFn then
        pcall(function()
            local v = rawget(getgenv(), "replicatesignal")
            if type(v) == "function" then replicatesignalFn = v end
        end)
    end
    if not replicatesignalFn then
        pcall(function()
            local v = rawget(_G, "replicatesignal")
            if type(v) == "function" then replicatesignalFn = v end
        end)
    end
    API.CanBreak = replicatesignalFn ~= nil

    -- ---- Reset remote (cached + self-healing) ----
    local resetRemote
    local function resolveReset()
        if resetRemote and resetRemote.Parent then return resetRemote end
        resetRemote = nil
        pcall(function()
            local outer = ReplicatedStorage:FindFirstChild("Knit")
            local knit  = outer and outer:FindFirstChild("Knit")
            local svcs  = knit and knit:FindFirstChild("Services")
            local join  = svcs and svcs:FindFirstChild("JoinService")
            local re    = join and join:FindFirstChild("RE")
            resetRemote = re and re:FindFirstChild("Reset")
        end)
        return resetRemote
    end

    local function fireReset()
        local remote = resolveReset()
        if not remote then API.Fails = API.Fails + 1 return false end
        local ok = pcall(function() remote:FireServer() end)
        if not ok then API.Fails = API.Fails + 1 end
        return ok
    end

    local function breakJoints(hum)
        if not (replicatesignalFn and hum) then return false end
        -- the signal lookup stays INSIDE the pcall: a missing signal must not escape
        local ok = pcall(function() replicatesignalFn(hum.ServerBreakJoints) end)
        if not ok then API.Fails = API.Fails + 1 end
        return ok
    end

    -- ---- pulse state + the single cleanup path every exit routes through ----
    local pulseRoot, pulseAnchor
    local function restore()
        local root, anchor = pulseRoot, pulseAnchor
        pulseRoot, pulseAnchor = nil, nil
        if root and root.Parent and anchor then
            pcall(function()
                root.CFrame = anchor
                root.AssemblyLinearVelocity  = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    -- Blocking. Holds the root at the void for CFG.Hold, snapping back to the real
    -- anchor each frame so the server samples the void while we never visibly move.
    local function doPulse(char, root, hum, mine)
        if mine ~= token or LocalPlayer.Character ~= char or not root.Parent then return end

        pulseRoot   = root
        pulseAnchor = root.CFrame
        breakJoints(hum)

        local anchor   = pulseAnchor
        local pos      = anchor.Position
        local rot      = anchor - pos
        local void     = CFrame.new(pos.X, tonumber(CFG.VoidY) or 10000, pos.Z) * rot
        local deadline = os.clock() + CFG.Hold

        local ok = pcall(function()
            while mine == token
                and LocalPlayer.Character == char
                and root.Parent
                and os.clock() < deadline
            do
                root.CFrame = void
                RunService.Heartbeat:Wait()
                if root.Parent then
                    root.CFrame = anchor
                    root.AssemblyLinearVelocity  = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end)

        restore()
        if not ok then API.Fails = API.Fails + 1 end
    end

    -- ---- the retry cycle: this is what makes it fast ----
    local function startCycle(char, root, hum)
        token = token + 1
        local mine = token
        API.Busy   = true
        API.Count  = API.Count + 1
        cycleStart = os.clock()
        local used = 0

        task.spawn(function()
            for i = 1, CFG.MaxAttempts do
                -- a token bump from CharacterAdded, or a character swap, ends this
                if mine ~= token or LocalPlayer.Character ~= char or not root.Parent then break end

                used = i
                API.Attempts = API.Attempts + 1
                local t0 = os.clock()

                task.delay(CFG.ResetAt, function()
                    -- Identity check: CharacterRemoving invalidates a stale cycle LONG
                    -- before CharacterAdded bumps the token. Without this, a Reset fired
                    -- in that gap reaches the server AFTER we've already respawned and
                    -- kills the fresh body (the "respawn dead" bug).
                    if mine == token and API.Busy and LocalPlayer.Character == char then fireReset() end
                end)

                doPulse(char, root, hum, mine)

                while mine == token
                    and LocalPlayer.Character == char
                    and (os.clock() - t0) < CFG.RetryEvery
                do
                    task.wait(0.03)
                end
            end

            API.LastAttempts = used
            if mine == token then
                API.Busy = false
                restore()
            end
        end)
    end

    local function request(char, root, hum, manual)
        if API.Busy and not manual then return false, "busy" end
        if LocalPlayer.Character ~= char then return false, "stale character" end
        if not (root and root.Parent and hum and hum.Parent) then return false, "no parts" end

        local age   = os.clock() - bornAt
        local guard = tonumber(CFG.SpawnGuard) or 0.20

        -- the game drops death pulses fired in the first moments after CharacterAdded
        if age < guard then
            if queued then return true, "queued" end
            queued = true
            task.delay(guard - age, function()
                queued = false
                if LocalPlayer.Character ~= char then return end
                local dead = hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead
                if manual or dead then startCycle(char, root, hum) end
            end)
            return true, "queued"
        end

        startCycle(char, root, hum)
        return true, "started"
    end

    -- ---- public: fire a fast respawn now (non-blocking) ----
    function API.Now()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not (char and hum and root) then
            return fireReset(), "no body, plain Reset"
        end
        -- a manual request deliberately preempts an in-flight cycle
        if API.Busy then
            token = token + 1
            API.Busy = false
            restore()
        end
        return request(char, root, hum, true)
    end

    -- ---- public: fire a fast respawn and BLOCK until we are alive again ----
    -- This is the backend helper. Returns true, elapsedSeconds on success.
    function API.Await(timeout)
        timeout = tonumber(timeout) or 6
        local old = LocalPlayer.Character
        local t0  = os.clock()
        API.Now()
        while os.clock() - t0 < timeout do
            local c = LocalPlayer.Character
            if c and c ~= old then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if CFG.SettleWait > 0 then task.wait(CFG.SettleWait) end
                    return true, os.clock() - t0
                end
            end
            task.wait(0.03)
        end
        return false, os.clock() - t0
    end

    -- ---- auto-on-death hooks (the Extras toggle) ----
    local function dropDeathConns()
        if diedConn then diedConn:Disconnect() diedConn = nil end
        if healthConn then healthConn:Disconnect() healthConn = nil end
    end

    local function bindCharacter(char)
        dropDeathConns()
        if not (API.Auto and char) then return end

        local function attach(hum, root)
            if not API.Auto or LocalPlayer.Character ~= char or diedConn then return end
            if not (hum and root) then return end

            local function trigger()
                if St.huntDefaultRespawnActive then
                    -- Let the hunt's normal Reset/CharacterAdded cycle finish;
                    -- do not let the Extras auto engine replace it with fast pulses.
                    dropDeathConns()
                    return
                end
                dropDeathConns()
                request(char, root, hum, false)
            end

            diedConn   = hum.Died:Connect(trigger)
            healthConn = hum.HealthChanged:Connect(function(hp) if hp <= 0 then trigger() end end)
            if hum.Health <= 0 then trigger() end
        end

        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            attach(hum, root)
        else
            task.spawn(function()
                attach(hum or char:WaitForChild("Humanoid", 6), root or char:WaitForChild("HumanoidRootPart", 6))
            end)
        end
    end

    function API.SetAuto(v)
        local on = v == true
        API.Auto = on
        token = token + 1
        API.Busy = false
        queued   = false
        restore()
        dropDeathConns()
        if on then
            resolveReset()
            bindCharacter(LocalPlayer.Character)
        end
        return on
    end

    -- ---- lifecycle: always on, so timings and anti-fling apply to every respawn ----
    LocalPlayer.CharacterAdded:Connect(function(char)
        token    = token + 1
        API.Busy = false
        queued   = false
        bornAt   = os.clock()
        restore()
        dropDeathConns()

        if cycleStart > 0 then
            API.LastMs = math.floor((os.clock() - cycleStart) * 1000 + 0.5)
            if API.BestMs == 0 or API.LastMs < API.BestMs then API.BestMs = API.LastMs end
            cycleStart = 0
        end

        -- kill inherited momentum so we never spawn mid-fling
        task.spawn(function()
            local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
            if root and LocalPlayer.Character == char then
                pcall(function()
                    root.AssemblyLinearVelocity  = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end)

        task.defer(bindCharacter, char)

        -- Dead-on-spawn recovery: if the fresh body arrives already dead (the server
        -- ate a late Reset), send ONE plain Reset so you come back alive instead of
        -- lying there as a corpse. Fires past the SpawnGuard drop window, and skips
        -- if a cycle is already handling it.
        task.delay(0.55, function()
            if LocalPlayer.Character ~= char or API.Busy then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then fireReset() end
        end)
    end)

    LocalPlayer.CharacterRemoving:Connect(function()
        restore()
        dropDeathConns()
    end)

    function API.Status()
        return string.format(
            "auto:%s busy:%s n:%d att:%d last:%dms best:%dms err:%d break:%s",
            API.Auto and "Y" or "N", API.Busy and "Y" or "N",
            API.Count, API.LastAttempts, API.LastMs, API.BestMs, API.Fails,
            API.CanBreak and "Y" or "N"
        )
    end

    pcall(function() getgenv().NH_Respawn = API end)
    return API
end)()

-- Hub-wide reset entry point. Reuses the ORIGINAL forceReset local (no new
-- local is introduced -- see the 200-local note above). Features that need to
-- block until they are alive again call _G.NH_Respawn.Await(timeout) directly.
local function forceReset() _G.NH_Respawn.Now() end
local function checkACStatus()
    local test = rawget(_G, "NH_SharedACTest")
    if type(test) ~= "function" then
        notify("AC Check", "Shared Gojo 0.2 detector is not ready.", 4)
        return
    end
    local bypassed, reason = test()
    if bypassed == nil then
        notify("AC Check", tostring(reason or "Unable to run the shared test."), 4)
        return
    end
    if bypassed then
        local proofChar = LocalPlayer.Character
        local proofHum = proofChar and proofChar:FindFirstChildOfClass("Humanoid")
        if proofChar and proofHum and proofHum.Health > 0 then
            St.luckyCycleFound = true
            St.todoSwapAcBypassed = true
            _G.NH_TodoACProof = {
                Character = proofChar,
                CheckedAt = os.clock(),
                Source = "Shared Gojo 0.2 AC status check",
            }
        end
        notify("AC BYPASSED", "Shared Gojo 0.2 test passed; Gojo and Todo are armed.", 6)
    else
        St.luckyCycleFound = false
        St.todoSwapAcBypassed = false
        _G.NH_TodoACProof = nil
        notify("AC ACTIVE", tostring(reason or "Snapback observed."), 6)
    end
end

-- ============================================================
-- SPECTATE / VIEW
-- ============================================================
local _ovSpectate=nil
local _ovSavedCam=nil

local function ovStopSpectate()
    if not _ovSpectate then return end
    _ovSpectate=nil
    pcall(function()
        if _ovSavedCam and _ovSavedCam.Parent then Camera.CameraSubject=_ovSavedCam
        else local c=LocalPlayer.Character; local h=c and c:FindFirstChildOfClass("Humanoid") if h then Camera.CameraSubject=h end end
    end)
    _ovSavedCam=nil
end

local function ovStartSpectate(name)
    ovStopSpectate()
    local pl=Players:FindFirstChild(name)
    if not pl or not pl.Character then return false end
    local hum=pl.Character:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    _ovSavedCam=Camera.CameraSubject; _ovSpectate=name; Camera.CameraSubject=hum; return true
end


-- ============================================================
-- SWEEP & HUNT
-- ============================================================
local function doTP(myChar, myHRP, attackCF)
    if Cfg.tpMethod == "smart" then smartTP(myHRP, attackCF, 11)
    else pcall(function() myChar:PivotTo(attackCF) end); myHRP.AssemblyLinearVelocity = Vector3.zero end
end

local function runSweep()
    local myChar = LocalPlayer.Character; local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myChar or not myHRP then St.sweepActive=false; return end
    if tick() - _lastDomainRebuild > 30 then _lastDomainRebuild = tick(); rebuildDomainCache() end
    local startCFrame = myHRP.CFrame; local skySanctuary = startCFrame * CFrame.new(0, 1000, 0)
    local sweepIndex = 1

    while St.sweepActive do
        myChar = LocalPlayer.Character; myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myChar or not myHRP then RunService.Heartbeat:Wait() else
            local sweepTgts = getSweepTargets(myHRP)
            if #sweepTgts==0 then RunService.Heartbeat:Wait() else
                if sweepIndex>#sweepTgts then sweepIndex=1 end
                local tgt=sweepTgts[sweepIndex]; sweepIndex=sweepIndex+1
                if tgt and tgt.Core and tgt.Humanoid.Health>0 then
                    local hpBefore=tgt.Humanoid.Health
                    doTP(myChar, myHRP, getAttackCFrame(myHRP, tgt.Core))
                    RunService.Heartbeat:Wait()
                    if St.sweepActive and (tgt.Humanoid.Health<hpBefore or tgt.Humanoid.Health<=0) then
                        pcall(function() myChar:PivotTo(skySanctuary) end)
                    end
                end
            end
        end
    end
    myChar = LocalPlayer.Character; if myChar and myChar:FindFirstChild("HumanoidRootPart") then myChar:PivotTo(startCFrame) end
end

local function checkCycle(keepRunning)
    if keepRunning and not keepRunning() then return nil, "Stopped" end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myChar or not myHRP or not hum or hum.Health <= 0 then
        return nil, "Waiting for a live character"
    end
    local targets = getValidTargets(myHRP)
    if #targets == 0 then return nil, "Waiting for a player or dummy to test against" end
    local testTarget = targets[1]
    if not testTarget.Core or not testTarget.Core.Parent then return nil, "Target changed" end

    local startCF = myChar:GetPivot()
    local attackCF, attackPos = getAttackCFrame(myHRP, testTarget.Core)
    local ok, bypassed, reason = pcall(function()
        myChar:PivotTo(attackCF)
        myHRP.AssemblyLinearVelocity = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
        local deadline = os.clock() + Cfg.STABILITY_DURATION
        repeat
            if keepRunning and not keepRunning() then return nil, "Stopped" end
            RunService.Heartbeat:Wait()
            if LocalPlayer.Character ~= myChar or not myHRP.Parent or hum.Health <= 0 then
                return nil, "Character changed during AC test"
            end
            if (myHRP.Position - attackPos).Magnitude > Cfg.SNAP_THRESHOLD then
                return false, "Snapback observed"
            end
        until os.clock() >= deadline
        return true, "No snapback observed"
    end)

    if LocalPlayer.Character == myChar and myHRP.Parent and hum.Health > 0 then
        pcall(function()
            myChar:PivotTo(startCF)
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if not ok then return nil, "AC-test error: " .. tostring(bypassed) end
    return bypassed, reason
end
_G.NH_SharedACTest = checkCycle

local function runHunt(requester)
    requester = type(requester) == "string" and requester or "Hunt"
    if St.huntRunning then
        notify(requester, "The shared Gojo 0.2 AC hunt is already running.", 3)
        return
    end
    if St.acBypassHunting then notify(requester, "Stop the other AC reset loop first.", 3); return end

    St.huntRunning = true
    St.todoSwapHunting = requester == "Todo Range Swap"
    St.luckyCycleFound = false
    St.todoSwapAcBypassed = false
    _G.NH_TodoACProof = nil
    notify(requester, "Shared Gojo 0.2 AC hunt started. Press H to stop.", 3)

    -- Mirror v109's hunt reset path: send the game's normal Reset remote, then
    -- wait for CharacterAdded and the configured settle delay. Keep the Extras
    -- fast-respawn engine from intercepting only this hunt-triggered death.
    local function defaultHuntRespawn()
        local oldCharacter = LocalPlayer.Character
        local newCharacter = nil
        St.huntDefaultRespawnActive = true

        local characterAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
            if character ~= oldCharacter then newCharacter = character end
        end)
        local resetSent = pcall(function()
            ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services").JoinService.RE.Reset:FireServer()
        end)
        if not resetSent then
            characterAddedConn:Disconnect()
            St.huntDefaultRespawnActive = false
            return false
        end

        -- Check the current Character as well as the event value so an unusually
        -- fast respawn cannot be missed between firing Reset and yielding. Bound
        -- the wait so Stop Hunt (or a rejected Reset) cannot leave the Extras
        -- auto-respawn suppression active forever.
        local deadline = os.clock() + 15
        while not newCharacter and St.huntRunning and os.clock() < deadline do
            local currentCharacter = LocalPlayer.Character
            if currentCharacter and currentCharacter ~= oldCharacter then
                newCharacter = currentCharacter
                break
            end
            task.wait(0.05)
        end

        if not newCharacter then
            characterAddedConn:Disconnect()
            St.huntDefaultRespawnActive = false
            return false
        end

        task.wait(Cfg.RESPAWN_WAIT)
        characterAddedConn:Disconnect()
        St.huntDefaultRespawnActive = false
        return true
    end

    local attempts = 0
    while St.huntRunning and attempts < Cfg.MAX_HUNT_ATTEMPTS do
        attempts = attempts + 1
        local result, reason = checkCycle(function() return St.huntRunning end)
        if result == true then
            local proofChar = LocalPlayer.Character
            local proofHum = proofChar and proofChar:FindFirstChildOfClass("Humanoid")
            if proofChar and proofHum and proofHum.Health > 0 then
                St.luckyCycleFound = true
                St.todoSwapAcBypassed = true
                _G.NH_TodoACProof = {
                    Character = proofChar,
                    CheckedAt = os.clock(),
                    Source = "Shared Gojo 0.2 AC hunt",
                }
            end
            St.huntRunning = false
            St.todoSwapHunting = false
            if requester == "Todo Range Swap" then
                notify(requester, "AC bypass found in " .. attempts .. " tries; Todo Swap is armed.", 6)
            else
                notify("LUCKY CYCLE!", "Got it in " .. attempts .. " tries. Sweep and Todo Swap now share this proof.", 8)
            end
            break
        elseif result == false then
            if not St.huntRunning then break end
            local respawned = defaultHuntRespawn()
            if not respawned and St.huntRunning then
                notify(requester, "Default respawn failed or timed out; hunt stopped.", 4)
                St.huntRunning = false
                St.todoSwapHunting = false
                break
            end
        else
            if reason == "Stopped" or not St.huntRunning then break end
            task.wait(0.35)
        end
    end

    local exhausted = St.huntRunning and attempts >= Cfg.MAX_HUNT_ATTEMPTS
    St.huntRunning = false
    St.todoSwapHunting = false
    if exhausted then notify(requester, "No usable cycle found in " .. attempts .. " tries.", 4) end
end

local function stopHunt(silent)
    St.huntRunning = false
    St.acBypassHunting = false
    St.todoSwapHunting = false
    if silent ~= true then notify("Hunt", "Shared AC hunt stopped.", 3) end
end

_G.NH_StopCycleHunt = function() stopHunt(true) end

-- ============================================================
-- ATTACH
-- ============================================================
local function startAttach(liveTarget)
    if St.stopRotate then St.stopRotate() end
    St.attachActive=true; St.attachTarget=liveTarget; Workspace.FallenPartsDestroyHeight = Cfg.fallenHeight
    if Cn.attachLoopConn then Cn.attachLoopConn:Disconnect() end
    Cn.attachLoopConn = RunService.Heartbeat:Connect(function()
        if not St.attachActive or not St.attachTarget then return end
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and St.attachTarget.Core and St.attachTarget.Core.Parent then 
            hrp.CFrame = St.attachTarget.Core.CFrame * CFrame.new(Cfg.offsetX, Cfg.offsetY, Cfg.offsetZ) 
        end
    end)
end
local function stopAttach()
    St.attachActive=false; if Cn.attachLoopConn then Cn.attachLoopConn:Disconnect() end
    Workspace.FallenPartsDestroyHeight = St.originalFallenHeight
end

-- ============================================================
-- ROTATE TARGET (smart orbit with velocity prediction)
-- ============================================================
-- Constantly swings the player around the selected target in a tight circle at
-- high speed, always facing them. The target's measured velocity is used to orbit
-- their PREDICTED future position, so when they run or dash we stay out in front
-- of their movement instead of lagging behind their old spot. Attach is mutually
-- exclusive (both write HRP CFrame every frame, so they would fight).
-- Stored on St (not as locals) so no main-chunk local slots are consumed -- this
-- file is already at the local-count ceiling -- and so startAttach can reference
-- St.stopRotate safely regardless of declaration order.
St.startRotate = function(liveTarget, followLockOn)
    stopAttach()
    St.rotateActive=true; St.rotateTarget=liveTarget; St.rotateFollowLockOn=followLockOn == true; St.rotateSoftSince=nil
    St.rotateAngle=0; St.rotateLastPos=nil; St.rotateLastT=0; St.rotateVel=Vector3.zero
    Workspace.FallenPartsDestroyHeight = Cfg.fallenHeight
    if Cn.rotateConn then Cn.rotateConn:Disconnect() end
    Cn.rotateConn = RunService.Heartbeat:Connect(function(dt)
        if not St.rotateActive or not St.rotateTarget then return end
        if St.rotateFollowLockOn then
            local lockedTarget = St.lockOnEnabled and St.lockOnTarget or nil
            -- v109 lock-on clears invalid targets immediately; orbit stops on that same clear.
            if type(lockedTarget) ~= "table" then
                St.stopRotate()
                notify("Rotate", "Lock-On target cleared; stopped rotating.", 3)
                return
            end
            local lockedChar = lockedTarget.Char
            local lockedHumanoid = lockedTarget.Humanoid
            local lockedCore = lockedTarget.Core
            -- HARD: the locked target is genuinely dead -> stop right away.
            if typeof(lockedHumanoid) == "Instance" and lockedHumanoid:IsA("Humanoid")
                and lockedHumanoid.Parent and lockedHumanoid.Health <= 0 then
                St.stopRotate()
                notify("Rotate", "Lock-On target lost; stopped rotating.", 3)
                return
            end
            -- SOFT: grab/cutscene hid or swapped their body for a moment -> hold, don't stop.
            if typeof(lockedChar) ~= "Instance" or not lockedChar:IsA("Model") or not lockedChar.Parent
                or typeof(lockedHumanoid) ~= "Instance" or not lockedHumanoid:IsA("Humanoid")
                or lockedHumanoid.Parent ~= lockedChar
                or typeof(lockedCore) ~= "Instance" or not lockedCore:IsA("BasePart")
                or not lockedCore.Parent or not lockedCore:IsDescendantOf(lockedChar)
                then
                St.rotateSoftSince = St.rotateSoftSince or os.clock()
                St.rotateLastPos = nil
                if os.clock() - St.rotateSoftSince < Cfg.rotateLockGrace then return end
                St.stopRotate()
                notify("Rotate", "Lock-On target lost; stopped rotating.", 3)
                return
            end
            if lockedTarget ~= St.rotateTarget then
                St.rotateTarget = lockedTarget
                St.rotateAngle = 0
                St.rotateLastPos = nil
                St.rotateLastT = 0
                St.rotateVel = Vector3.zero
                notify("Rotate", "Following Lock-On target: " .. tostring(lockedTarget.name or lockedChar.Name), 2)
            end
        end
        local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local core = St.rotateTarget.Core
        -- PATCH P3: target DEAD -> hard stop. Missing hrp/core (grab, respawn swap) -> soft,
        -- held for Cfg.rotateLockGrace before giving up. Reflect stops back on the toggle.
        local tHum = St.rotateTarget.Humanoid
        local lostLockMode = St.rotateFollowLockOn == true
        if not tHum or (tHum.Parent and tHum.Health <= 0) then
            St.stopRotate()
            notify("Rotate", lostLockMode and "Lock-On target lost; stopped rotating." or "Target lost; stopped rotating.", 3)
            return
        end
        if not hrp or not core or not core.Parent then
            St.rotateSoftSince = St.rotateSoftSince or os.clock()
            St.rotateLastPos = nil
            if os.clock() - St.rotateSoftSince < Cfg.rotateLockGrace then return end
            St.stopRotate()
            notify("Rotate", lostLockMode and "Lock-On target lost; stopped rotating." or "Target lost; stopped rotating.", 3)
            return
        end
        St.rotateSoftSince = nil
        -- PATCH P3 grab-safety: while the game anchors / physics-states us or the target
        -- (grab moves), PAUSE the orbit instead of fighting it. Resumes when the grab ends.
        if Cfg.rotatePauseWhenAnchored then
            local myHum = char:FindFirstChildOfClass("Humanoid")
            local hs = myHum and myHum:GetState()
            if hrp.Anchored or core.Anchored or hs == Enum.HumanoidStateType.Physics
                or (myHum and myHum.PlatformStand) then
                St.rotateLastPos = nil
                return
            end
        end
        local now = os.clock()
        local tPos = core.Position
        -- REAL velocity: prefer physics velocity; fall back to a position-delta over
        -- time (catches CFrame-animated targets whose engine velocity reads 0).
        local vel = core.AssemblyLinearVelocity
        if typeof(vel) ~= "Vector3" or vel.Magnitude < 0.1 then
            if St.rotateLastPos and now - St.rotateLastT > 1e-4 then
                vel = (tPos - St.rotateLastPos) / (now - St.rotateLastT)
            else
                vel = Vector3.zero
            end
        end
        -- SMOOTH the velocity (exponential average) so a single lag-spike or a
        -- teleport does not fling the orbit point across the map.
        St.rotateVel = St.rotateVel:Lerp(vel, 0.35)
        St.rotateLastPos = tPos; St.rotateLastT = now
        -- PREDICT: orbit where they are going. Lead scales with speed so a fast
        -- target gets a longer runway than a shuffling one, clamped so a teleport
        -- can't yank us miles away.
        local speed = St.rotateVel.Magnitude
        local lead = Cfg.rotateLead * math.min(speed / 16, 1.6)
        local center = tPos + St.rotateVel * lead
        -- ORBIT: advance the angle in radians, scaled by real elapsed time so the
        -- spin rate is identical at any framerate. We stand on a circle of radius
        -- rotateRadius around the predicted center, and always face the target's
        -- REAL position (not the lead point) so our guard/m1s stay aimed at them.
        St.rotateAngle = St.rotateAngle + Cfg.rotateSpeed * (dt or 1/60)
        local offset = (CFrame.Angles(0, St.rotateAngle, 0) * CFrame.new(0, 0, -Cfg.rotateRadius)).Position
        hrp.CFrame = CFrame.lookAt(center + offset, tPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
end
St.stopRotate = function()
    local wasLockMode = St.rotateFollowLockOn == true
    St.rotateActive=false; St.rotateTarget=nil; St.rotateFollowLockOn=false; St.rotateSoftSince=nil
    if Cn.rotateConn then Cn.rotateConn:Disconnect() end
    Workspace.FallenPartsDestroyHeight = St.originalFallenHeight
    local option
    if type(Fluent) == "table" and type(Fluent.Options) == "table" then
        if wasLockMode then option = Fluent.Options.TglRotateLockOn else option = Fluent.Options.TglRotate end
    end
    if option then pcall(function() if option.Value then option:SetValue(false) end end) end
end

-- ============================================================
-- PATCH P1: one body-rotation owner; short leases expire without delayed callbacks.
do
    local leases = {}
    local Face = { priority = { dash = 90, counter = 80, defense = 70, blackflash = 60, lockon = 10, invis = 5 } }
    function Face.blocked(owner)
        local now, priority = os.clock(), Face.priority[owner] or 0
        for other, lease in pairs(leases) do
            if lease.untilT <= now then leases[other] = nil
            elseif other ~= owner and lease.priority >= priority then return true end
        end
        return false
    end
    function Face.claim(owner, seconds)
        if Face.blocked(owner) then return false end
        leases[owner] = { untilT = os.clock() + (seconds or 0.08), priority = Face.priority[owner] or 0 }
        return true
    end
    function Face.release(owner) leases[owner] = nil end
    function Face.canDefend(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or hum.PlatformStand or hum.Sit then return false end
        local ragdoll = char:GetAttribute("Ragdoll")
        if ragdoll == true or (tonumber(ragdoll) or 0) > 0 then return false end
        local info = char:FindFirstChild("Info")
        if info and (info:FindFirstChild("Knockback") or info:FindFirstChild("Grabbed")
            or info:FindFirstChild("Stun")) then return false end
        local state = hum:GetState()
        return state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Physics
            and state ~= Enum.HumanoidStateType.Ragdoll and state ~= Enum.HumanoidStateType.FallingDown
    end
    function Face.canRotate(hum)
        local root = hum and hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart")
        return root and Face.canDefend(hum.Parent) and not root.Anchored
    end
    -- Turning is not an attack: a plain hit-stun marker must not stall normal facing.
    -- Real physics/CC ownership (grab, knockback, ragdoll, seat, anchored root) still wins.
    function Face.canTurn(hum)
        local char = hum and hum.Parent
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or root.Anchored or hum.Health <= 0 or hum.PlatformStand or hum.Sit then return false end
        local ragdoll = char:GetAttribute("Ragdoll")
        if ragdoll == true or (tonumber(ragdoll) or 0) > 0 then return false end
        local info = char:FindFirstChild("Info")
        for _, name in ipairs({"Knockback", "Hold", "Grab", "Grabbed", "Carry"}) do
            if char:FindFirstChild(name) or (info and info:FindFirstChild(name)) then return false end
        end
        local state = hum:GetState()
        return state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Physics
            and state ~= Enum.HumanoidStateType.Ragdoll and state ~= Enum.HumanoidStateType.FallingDown
            and state ~= Enum.HumanoidStateType.PlatformStanding
    end
    function Face.lockOnRotating()
        local t = St.lockOnTarget
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        return St.lockOnEnabled and t and t.Char and t.Char.Parent and t.Core and t.Core.Parent
            and t.Humanoid and t.Humanoid.Health > 0 and Face.canTurn(hum)
            and (Cfg.LockOn.Method == "Body" or Cfg.LockOn.Method == "Console")
    end
    function Face.lockOnCameraActive()
        local t = St.lockOnTarget
        return St.lockCamOwned ~= nil or (St.lockOnEnabled and t and t.Core and t.Core.Parent
            and t.Humanoid and t.Humanoid.Health > 0
            and (Cfg.LockOn.Method == "Camera" or Cfg.LockOn.Method == "Console" or St.invisActive))
    end
    function Face.restore(hum)
        if not hum or not hum.Parent or not Face.canTurn(hum) then return end
        local locked = St.invisActive and St.invisFacingReady
            and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
        hum.AutoRotate = not (Face.lockOnRotating() or locked or Face.blocked("lockon"))
    end
    St.Face = Face
    _G.NH_Face = Face
    LocalPlayer.CharacterRemoving:Connect(function() table.clear(leases) end)
end

-- Verified defense observations, shared by block and counter (never arbitrary Action animations).
do
    local pending = {}
    local consumed = setmetatable({}, { __mode = "k" })
    St.DefenseBus = {}
    function St.DefenseBus.offer(key, kind, root, source, impact)
        if not St.autoCounterEnabled or not key or (consumed[key] or 0) > os.clock() then return false end
        local now = os.clock()
        pending[key] = { key = key, kind = kind, root = root, source = source,
            impact = impact or 0, expires = now + 0.12 }
        return St.tryCounter and St.tryCounter(pending[key]) or false
    end
    function St.DefenseBus.consume(key)
        consumed[key] = os.clock() + 6
        pending[key] = nil
    end
    function St.DefenseBus.step()
        local now = os.clock()
        for key, untilT in pairs(consumed) do if untilT <= now then consumed[key] = nil end end
        for key, threat in pairs(pending) do
            if threat.expires < now then pending[key] = nil
            elseif St.tryCounter and St.tryCounter(threat) then break end
        end
    end
    function St.DefenseBus.reset() table.clear(pending); table.clear(consumed) end
end

-- EXTRAS (NoDashCooldown, Invis, Noclip, Wallhop, Shrink, LockOn)
-- ============================================================

local function enableNoDashCooldown()
    if Cn.noDashCooldownConn then return end
    pcall(function()
        local ok, movCtrl=pcall(function() return require(LocalPlayer.PlayerScripts.Controllers.Character.MovementController) end)
        if not ok or not movCtrl then return end
        local dashFn=movCtrl.DashRequest; if not dashFn then return end
        Cn.noDashCooldownConn=RunService.RenderStepped:Connect(function()
            pcall(function() debug.setupvalue(dashFn,4,0); debug.setupvalue(dashFn,6,999) end)
        end)
    end)
end
local function disableNoDashCooldown()
    if Cn.noDashCooldownConn then Cn.noDashCooldownConn:Disconnect(); Cn.noDashCooldownConn=nil end
end

-- PATCH P1: desired-state invisibility lifecycle; no yields inside setup/cleanup.
do
    local generation, live = 0, nil
    local Life = {}
    local function disconnect(connection) if connection then connection:Disconnect() end end
    function Life.cleanup()
        generation += 1 -- cancels any older CharacterAdded/setup job
        local state = live
        live = nil
        St.invisFacingReady = false
        disconnect(Cn.invisGuardConn); Cn.invisGuardConn = nil
        for _, name in ipairs({"NH_InvisCamAnchor", "NH_SelfView", "NH_InvisShiftlock"}) do
            RunService:UnbindFromRenderStep(name)
        end
        if state then
            for _, connection in ipairs(state.connections) do disconnect(connection) end
            if state.hitWeights then
                for track, weight in pairs(state.hitWeights) do
                    pcall(function() if track.IsPlaying then track:AdjustWeight(weight, 0.08) end end)
                end
            end
            local cam = Workspace.CurrentCamera
            if cam and cam.CameraSubject == state.anchor then
                local char = LocalPlayer.Character
                cam.CameraSubject = char and char:FindFirstChildOfClass("Humanoid") or state.previousSubject
            end
            if state.track then pcall(function() state.track:Stop(0); state.track:Destroy() end) end
            if state.anchor then state.anchor:Destroy() end
            if state.marker then state.marker:Destroy() end
            St.Face.release("invis")
            St.Face.restore(state.humanoid)
        end
        St.invisAnimTrack, St.invisCamAnchor, St.invisPrevCamSubject, St.selfViewModel = nil, nil, nil, nil
    end
    function Life.setup(char)
        if not St.invisActive or not char or LocalPlayer.Character ~= char then return end
        if live and live.char == char then return end
        Life.cleanup()
        local token = generation
        task.spawn(function()
            local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
            local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
            if token ~= generation or not St.invisActive or LocalPlayer.Character ~= char
                or not char.Parent or not hum or not root or hum.Health <= 0 then return end
            local cam = Workspace.CurrentCamera
            local state = { char = char, humanoid = hum, root = root, connections = {},
                previousSubject = cam and cam.CameraSubject, baseY = root.Position.Y, lastGuard = 0 }
            live = state
            St.invisFacingReady = true
            state.hitWeights = setmetatable({}, { __mode = "k" })
            local anchor = Instance.new("Part")
            anchor.Name = "NH_CamAnchor"; anchor.Size = Vector3.new(0.1, 0.1, 0.1)
            anchor.Anchored = true; anchor.CanCollide = false; anchor.CanQuery = false
            anchor.CanTouch = false; anchor.Transparency = 1; anchor.CastShadow = false
            anchor.CFrame = root.CFrame; anchor.Parent = Workspace
            state.anchor = anchor; St.invisCamAnchor = anchor; St.invisPrevCamSubject = state.previousSubject
            if cam then cam.CameraSubject = anchor end

            -- Keep the local self-view; never move/anchor any replicated character parts.
            local marker = Instance.new("Model"); marker.Name = "NH_SelfViewMarker"
            local body = Instance.new("Part"); body.Name = "Body"; body.Size = Vector3.new(2, 3, 1)
            body.Anchored = true; body.CanCollide = false; body.CanQuery = false; body.CanTouch = false
            body.Material = Enum.Material.Neon; body.Color = Color3.fromRGB(90, 170, 255)
            body.Transparency = 0.35; body.Parent = marker
            local nose = body:Clone(); nose.Name = "Nose"; nose.Size = Vector3.new(0.45, 0.45, 2.6)
            nose.Color = Color3.fromRGB(80, 255, 140); nose.Transparency = 0; nose.Parent = marker
            local highlight = Instance.new("Highlight"); highlight.Adornee = marker
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.Parent = marker
            marker.PrimaryPart = body; marker.Parent = cam or Workspace
            state.marker = marker; St.selfViewModel = marker

            local function repairPose(force)
                local animator = hum:FindFirstChildOfClass("Animator")
                if not animator then return end -- wait for the game's animator, do not replace it
                if state.animator ~= animator or not state.track then
                    if state.track then pcall(function() state.track:Stop(0); state.track:Destroy() end) end
                    local animation = Instance.new("Animation"); animation.AnimationId = Cfg.INVIS_ANIM_ID
                    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
                    animation:Destroy()
                    if not ok or not track then state.track = nil; return end
                    state.animator, state.track = animator, track; St.invisAnimTrack = track
                    -- One persistent frozen pose. Do not restart it merely because an attack plays.
                    pcall(function()
                        track.Priority = Enum.AnimationPriority.Action4
                        track.Looped = true
                    end)
                end
                local track = state.track
                local ok = pcall(function()
                    -- Only recover an actually stopped track; replaying a live track resets its
                    -- root-joint pose and caused the p3 hit-burst movement/camera jolts.
                    local restarted = not track.IsPlaying
                    if restarted then track:Play(0, 1, 0) end
                    -- Length is zero until the asset loads. Never seek past its duration.
                    if track.Length > 0 then
                        local freezeAt = math.min(Cfg.INVIS_FREEZE_TIME, math.max(track.Length - 0.03, 0))
                        if force or restarted or math.abs(track.TimePosition - freezeAt) > 0.01 then
                            track.TimePosition = freezeAt
                        end
                    end
                    track:AdjustSpeed(0); track:AdjustWeight(1, 0)
                end)
                if not ok then
                    pcall(function() track:Stop(0); track:Destroy() end)
                    state.track, St.invisAnimTrack = nil, nil
                end
            end
            repairPose()
            -- Damage protection only touches visual animation weights, never walking velocity,
            -- root position, Humanoid state or attack remotes. Equal-priority hit tracks are
            -- temporarily reduced during CONFIRMED damage, then their previous weights return.
            state.burstUntil = 0
            local function protectHitTracks()
                if not state.animator then return end
                local ok, tracks = pcall(function() return state.animator:GetPlayingAnimationTracks() end)
                if not ok or not tracks then return end
                for _, other in ipairs(tracks) do
                    -- Only equal-priority tracks can compete with the frozen invisibility pose.
                    -- Leave lower-priority action animations alone; there is no mute mode.
                    if other ~= state.track and other.Priority == Enum.AnimationPriority.Action4 then
                        if state.hitWeights[other] == nil then
                            state.hitWeights[other] = other.WeightTarget
                        end
                        pcall(function() other:AdjustWeight(0.001, 0) end)
                    end
                end
            end
            local function restoreHitTracks()
                for other, weight in pairs(state.hitWeights) do
                    pcall(function() if other.IsPlaying then other:AdjustWeight(weight, 0.08) end end)
                    state.hitWeights[other] = nil
                end
            end
            -- Hit protection is an inherent part of Invisibility, not a saved UI option.
            state.lastHealth = hum.Health
            state.connections[#state.connections + 1] = hum.HealthChanged:Connect(function(hp)
                if live ~= state then return end
                if hp > 0 and hp < (state.lastHealth or hp) then
                    state.burstUntil = os.clock() + Cfg.invisBurstTime
                    repairPose(true)
                    protectHitTracks()
                end
                state.lastHealth = hp
            end)
            local function hookAnimator(animator)
                if not animator or state.hookedAnimator == animator then return end
                if state.animPlayedConn then state.animPlayedConn:Disconnect() end
                state.hookedAnimator = animator
                state.animPlayedConn = animator.AnimationPlayed:Connect(function(t)
                    if live ~= state or t == state.track or os.clock() >= state.burstUntil then return end
                    task.defer(function()
                        if live ~= state or os.clock() >= state.burstUntil then return end
                        repairPose(true)
                        protectHitTracks()
                    end)
                end)
                state.connections[#state.connections + 1] = state.animPlayedConn
            end
            hookAnimator(hum:FindFirstChildOfClass("Animator"))
            state.connections[#state.connections + 1] = hum.ChildAdded:Connect(function(c)
                if c:IsA("Animator") then hookAnimator(c) end
            end)
            Cn.invisGuardConn = RunService.Heartbeat:Connect(function()
                if live ~= state or token ~= generation then return end
                if not St.invisActive or LocalPlayer.Character ~= char or not char.Parent or hum.Health <= 0 then
                    Life.cleanup(); return
                end
                local now = os.clock()
                local inBurst = now < state.burstUntil
                if not inBurst and now - state.lastGuard < 0.08 then return end
                state.lastGuard = now
                repairPose(false)
                if inBurst then protectHitTracks() else restoreHitTracks() end
            end)
            state.connections[#state.connections + 1] = hum.Died:Connect(function()
                if live == state then Life.cleanup() end
            end)
            RunService:BindToRenderStep("NH_InvisCamAnchor", Enum.RenderPriority.Camera.Value - 1, function(dt)
                if live ~= state or not root.Parent then return end
                local pos = root.Position
                local floorState = hum:GetState()
                local airborne = floorState == Enum.HumanoidStateType.Freefall
                    or floorState == Enum.HumanoidStateType.Jumping
                local farm = rawget(_G, "AltFarmState")
                local fastAlt = farm and farm.running and farm.role == "ALT" and farm.movementMode == "FAST"
                if airborne or fastAlt then
                    state.baseY = pos.Y
                elseif pos.Y >= state.baseY - 6 then
                    state.baseY = math.min(state.baseY, pos.Y)
                end
                pos = Vector3.new(pos.X, math.max(pos.Y, state.baseY), pos.Z)
                anchor.CFrame = CFrame.new(pos)
                local current = Workspace.CurrentCamera
                if current then
                    if marker.Parent ~= current then marker.Parent = current end
                    -- Subject ownership is separate from lock-on's Scriptable camera ownership.
                    if current.CameraSubject ~= anchor then current.CameraSubject = anchor end
                end
            end)
            -- Draw AFTER all facing owners, including the late dash-defense render pass.
            RunService:BindToRenderStep("NH_SelfView", Enum.RenderPriority.Last.Value + 10, function()
                if live ~= state or not root.Parent then return end
                body.CFrame = root.CFrame
                nose.CFrame = root.CFrame * CFrame.new(0, 0, -(nose.Size.Z / 2 + 0.6))
            end)
            RunService:BindToRenderStep("NH_InvisShiftlock", Enum.RenderPriority.Last.Value + 6, function(dt)
                if live ~= state then return end
                if not St.Face.canTurn(hum) then St.Face.release("invis"); return end
                local farm = rawget(_G, "AltFarmState")
                if farm and farm.running and farm.role == "ALT" then St.Face.release("invis"); return end
                if St.Face.lockOnRotating() or St.Face.blocked("invis") then
                    St.Face.release("invis"); return
                end
                local current = Workspace.CurrentCamera
                if current and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                    local look = current.CFrame.LookVector * Vector3.new(1, 0, 1)
                    if look.Magnitude > 0.001 and St.Face.claim("invis", 0.04) then
                        hum.AutoRotate = false
                        local goal = CFrame.lookAt(root.Position, root.Position + look.Unit)
                        local alpha = 1 - math.exp(-40 * math.max(dt or 1/60, 0))
                        root.CFrame = CFrame.new(root.Position) * root.CFrame.Rotation:Lerp(goal.Rotation, alpha)
                    end
                else St.Face.release("invis"); St.Face.restore(hum) end
            end)
        end)
    end
    St.InvisLifecycle = Life
    Cn.invisRemovingConn = LocalPlayer.CharacterRemoving:Connect(function()
        Life.cleanup() -- leave the desired toggle enabled for the next character
    end)
end
local function setupInvisForChar(char) St.InvisLifecycle.setup(char) end
local function cleanupInvis(char) St.InvisLifecycle.cleanup() end

local function startNoclip()
    if Cn.noclipConn then Cn.noclipConn:Disconnect() end
    -- PERF: cache the character's collision parts instead of running GetDescendants()
    -- every physics step. Refresh on character swap or a cheap 1s rescan (also picks
    -- up newly equipped tools/accessories).
    local parts = {}
    local lastScan = 0
    local cachedChar = nil
    Cn.noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character; if not char then cachedChar = nil return end
        if char ~= cachedChar or os.clock() - lastScan > 1 then
            cachedChar = char
            lastScan = os.clock()
            table.clear(parts)
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then parts[#parts+1] = p end end
        end
        for _, p in ipairs(parts) do if p.Parent then p.CanCollide = false end end
    end)
end

-- The normal alt-side invisibility toggle is desired state, not a one-character
-- effect. Reapply after respawn until that toggle is actually switched off.
if Cn.invisCharConn then Cn.invisCharConn:Disconnect() end
Cn.invisCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
    if not St.invisActive then return end
    task.spawn(function()
        local hum=char:WaitForChild("Humanoid",5)
        local root=char:WaitForChild("HumanoidRootPart",5)
        if not hum or not root or not St.invisActive or LocalPlayer.Character~=char then return end
        task.wait(0.2)
        if St.invisActive and LocalPlayer.Character==char then setupInvisForChar(char);startNoclip() end
    end)
end)

local function enableNoWallhopCooldown()
    St.wallhopMetaHooked = true
    local wallhopAnimR=Instance.new("Animation"); wallhopAnimR.AnimationId="rbxassetid://94327920127463"
    local wallhopAnimL=Instance.new("Animation"); wallhopAnimL.AnimationId="rbxassetid://113609963676386"
    local mapParams=RaycastParams.new(); mapParams.FilterType=Enum.RaycastFilterType.Include
    if Workspace:FindFirstChild("Map") then mapParams.FilterDescendantsInstances={Workspace.Map} end
    if Cn.wallhopConn2 then Cn.wallhopConn2:Disconnect() end
    Cn.wallhopConn2=RunService.Heartbeat:Connect(function()
        local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum:GetState()~=Enum.HumanoidStateType.Freefall or hum.Jump~=true or char:GetAttribute("Movement") then return end
        local right=hrp.CFrame.RightVector; local wallDir=nil
        if Workspace:Raycast(hrp.Position,right*6,mapParams) then wallDir=1 elseif Workspace:Raycast(hrp.Position,-right*6,mapParams) then wallDir=-1 end
        if not wallDir then return end
        local track=hum:FindFirstChildOfClass("Animator"):LoadAnimation(wallDir==1 and wallhopAnimR or wallhopAnimL)
        track:Play(0.05); task.delay(0.5,function() track:Stop(0.1) end)
        char:SetAttribute("Movement",true); task.delay(0.4,function() char:SetAttribute("Movement",nil) end)
        local bv=Instance.new("BodyVelocity", hrp); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=hrp.CFrame.UpVector*30-right*(wallDir*35)+(hrp.CFrame.LookVector*Vector3.new(1,0,1)).Unit*25; Debris:AddItem(bv,0.25)
    end)
end

local function applyDashMultiplier(val)
    local char = LocalPlayer.Character; if char and char:FindFirstChild("Info") then
        local exist = char.Info:FindFirstChild("DashMultiplier"); if exist then exist:Destroy() end
        local int = Instance.new("NumberValue", char.Info); int.Name = "DashMultiplier"; int.Value = val
    end
end

-- ----------------------------
-- SYSTEM CORE FUNCTIONS
-- ----------------------------
-- NOTE: getTargetFromScreen is defined ONCE, later in the file, right next to the
-- lock-on input handlers (single source of truth). A duplicate that used to live
-- here silently overrode the tap radius, so it has been removed.

-- == Lock-On ESP: highlight the locked target so you can see it through walls ==
-- Hand the camera back to the player. We take it Scriptable while steering a lock-on, so on every
-- unlock / lost-target path the camera must be restored to the player's previous mode (usually
-- Custom) or their view would stay frozen. Centralised because every real teardown calls clearLockOnESP().
local function restoreLockOnCamera()
    local cam = St.lockCamOwned
    if cam and St.lockCamPrevType and cam.CameraType == Enum.CameraType.Scriptable then
        cam.CameraType = St.lockCamPrevType
    end
    St.lockCamOwned, St.lockCamPrevType = nil, nil
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not St.Face.lockOnRotating() then St.Face.release("lockon") end
    St.Face.restore(hum)
end
-- Destroy ONLY the ESP highlight. Used by the per-frame ESP refresh so toggling ESP off mid-lock
-- never touches (and never fights) the lock-on camera.
local function clearLockOnHighlight()
    if St.lockOnHighlight then
        pcall(function() St.lockOnHighlight:Destroy() end)
        St.lockOnHighlight = nil
    end
end
-- Destroy ONLY the on-target console marker (the 4-triangle reticle).
local function clearLockOnMarker()
    if St.lockOnMarker then
        pcall(function() St.lockOnMarker:Destroy() end)
        St.lockOnMarker = nil
    end
end
-- Full teardown: drop the ESP highlight + target marker AND give the camera back to the player.
local function clearLockOnESP()
    clearLockOnHighlight()
    clearLockOnMarker()
    restoreLockOnCamera()
end
local function updateLockOnESP()
    -- only show ESP while ESP is on AND we actually have a live locked target
    if not Cfg.LockOn.ESP or not St.lockOnEnabled or not St.lockOnTarget
        or not St.lockOnTarget.Char or not St.lockOnTarget.Char.Parent then
        clearLockOnHighlight()
        return
    end
    local char = St.lockOnTarget.Char
    -- already highlighting this exact character -> nothing to do
    if St.lockOnHighlight and St.lockOnHighlight.Adornee == char then return end
    clearLockOnHighlight()
    local hl = Instance.new("Highlight")
    hl.Name = "NH_LockOnESP"
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- renders through walls
    hl.FillColor = Color3.fromRGB(255, 64, 64)
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 232, 96)
    hl.OutlineTransparency = 0
    hl.Parent = char
    St.lockOnHighlight = hl
end

-- Console-style on-target marker: a 4-triangle reticle (top/bottom/left/right, each pointing
-- inward) anchored to the target's HRP so you can always see who you're locked onto, even in
-- close quarters. Shows whenever a target is locked, independent of the wall-ESP toggle.
local function updateLockOnMarker()
    if not St.lockOnEnabled or not St.lockOnTarget or not St.lockOnTarget.Core or not St.lockOnTarget.Core.Parent then
        clearLockOnMarker()
        return
    end
    local hrp = St.lockOnTarget.Core
    if St.lockOnMarker and St.lockOnMarker.Adornee == hrp then return end  -- already marking this exact target
    clearLockOnMarker()
    local bb = Instance.new("BillboardGui")
    bb.Name = "NH_LockOnMarker"
    bb.Adornee = hrp
    bb.Size = UDim2.new(0, 185, 0, 185)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = (Cfg.LockOn.MaxDistance or 150) + 25
    bb.Parent = hrp
    -- EXACT-IMAGE MODE: if you've uploaded the chevron PNG to Roblox, put its image asset ID in
    -- Cfg.LockOn.MarkerImage (a number, e.g. 1234567890) and we render 4 rotated copies of YOUR
    -- image around the target -- a pixel-perfect replica. If it's left at 0 we fall back to the
    -- built-in vector chevrons so the marker always works.
    local imgId = Cfg.LockOn.MarkerImage
    if imgId and imgId ~= 0 and imgId ~= "" and imgId ~= "rbxassetid://0" then
        -- A plain number is treated as a Decal/Image ASSET id and loaded via rbxthumb, which
        -- renders correctly even when you uploaded it as a Decal (raw decal ids won't show in
        -- ImageLabel.Image otherwise). Pass a full "rbxassetid://<imageId>" string instead if you
        -- have the underlying IMAGE id and want to use it directly.
        local imgStr
        if typeof(imgId) == "number" then
            imgStr = "rbxthumb://type=Asset&id=" .. imgId .. "&w=420&h=420"
        else
            imgStr = tostring(imgId)
        end
        local function arrow(rot, anchor, pos)
            -- soft red glow layer behind: larger, tinted bright red, semi-transparent
            local glow = Instance.new("ImageLabel")
            glow.BackgroundTransparency = 1
            glow.Size = UDim2.new(0, 72, 0, 72)
            glow.AnchorPoint = anchor
            glow.Position = pos
            glow.Rotation = rot
            glow.Image = imgStr
            glow.ImageColor3 = Color3.fromRGB(255, 45, 45)
            glow.ImageTransparency = 0.4
            glow.ScaleType = Enum.ScaleType.Fit
            glow.ZIndex = 1
            glow.Parent = bb
            -- crisp main chevron on top
            local img = Instance.new("ImageLabel")
            img.BackgroundTransparency = 1
            img.Size = UDim2.new(0, 56, 0, 56)
            img.AnchorPoint = anchor
            img.Position = pos
            img.Rotation = rot
            img.Image = imgStr
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 2
            img.Parent = bb
        end
        -- PNG's apex points UP by default; rotate each copy so every apex faces OUTWARD.
        arrow(0,   Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 0))   -- TOP, apex UP
        arrow(180, Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, 0))   -- BOTTOM, apex DOWN
        arrow(-90, Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))   -- LEFT, apex LEFT
        arrow(90,  Vector2.new(1, 0.5), UDim2.new(1, 0, 0.5, 0))   -- RIGHT, apex RIGHT
        St.lockOnMarker = bb
        return
    end
    -- Console-style chevron reticle: each arrowhead is a "^" (two strokes, NO bottom line) built
    -- from rotated bars, so it renders identically on every executor (zero font/glyph dependency).
    -- Dark demonic red with a red glow edge; apexes point OUTWARD around the target.
    local CH_FILL = Color3.fromRGB(130, 0, 0)
    local CH_GLOW = Color3.fromRGB(225, 40, 40)
    local function chevron(rot, anchor, pos)
        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(0, 30, 0, 22)
        holder.AnchorPoint = anchor
        holder.Position = pos
        holder.Rotation = rot
        holder.Parent = bb
        local function stroke(strokeRot, xoff)
            local b = Instance.new("Frame")
            b.AnchorPoint = Vector2.new(0.5, 0.5)
            b.Position = UDim2.new(0.5, xoff, 0.5, 0)
            b.Size = UDim2.new(0, 6, 0, 20)
            b.Rotation = strokeRot
            b.BackgroundColor3 = CH_FILL
            b.BorderSizePixel = 0
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 3)
            c.Parent = b
            local s = Instance.new("UIStroke")
            s.Color = CH_GLOW
            s.Thickness = 1.2
            s.Transparency = 0.15
            s.Parent = b
            b.Parent = holder
        end
        stroke(34, -5)   -- left stroke  "/" rising to the apex
        stroke(-34, 5)   -- right stroke "\\" falling from the apex
    end
    chevron(0,   Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 0))   -- TOP, apex UP
    chevron(180, Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, 0))   -- BOTTOM, apex DOWN
    chevron(-90, Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))   -- LEFT, apex LEFT
    chevron(90,  Vector2.new(1, 0.5), UDim2.new(1, 0, 0.5, 0))   -- RIGHT, apex RIGHT
    St.lockOnMarker = bb
end

local function enableLockOn()
    RunService:UnbindFromRenderStep("HubLockOnSystem")
    RunService:UnbindFromRenderStep("HubLockOnBody")
    local firstFrame, lastTarget = true, nil
    local bodyRoot, bodyHum, bodyTarget, bodyAlpha
    RunService:BindToRenderStep("HubLockOnSystem", Enum.RenderPriority.Camera.Value + 1, function(dt)
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

        bodyRoot, bodyHum, bodyTarget = nil, nil, nil
        if not St.lockOnEnabled then clearLockOnESP(); return end

        -- DEATH FIX: while dead / mid-respawn there is no valid HRP. The old code
        -- just returned here, leaving the camera stuck in Scriptable (frozen screen
        -- until a force reset). Release the lock and hand the camera back instead.
        if not myHRP or not myHum or myHum.Health <= 0 then
            St.lockOnTarget = nil
            if myHum then pcall(function() myHum.AutoRotate = true end) end
            firstFrame = true
            clearLockOnESP()
            return
        end

        local lt = St.lockOnTarget
        if lt ~= lastTarget then lastTarget, firstFrame = lt, true end
        if not lt or not lt.Char or not lt.Char.Parent or not lt.Core or not lt.Core.Parent or not lt.Humanoid or lt.Humanoid.Health <= 0 then
            St.lockOnTarget = nil
            myHum.AutoRotate = true
            firstFrame = true
            clearLockOnESP()
            return
        end

        if (myHRP.Position - St.lockOnTarget.Core.Position).Magnitude > Cfg.LockOn.MaxDistance then
            St.lockOnTarget = nil
            myHum.AutoRotate = true
            firstFrame = true
            clearLockOnESP()
            notify("Lock-On", "Target too far. Returning to standby.", 2)
            return
        end

        local targetCore = St.lockOnTarget.Core
        updateLockOnESP()
        updateLockOnMarker()
        local base = math.clamp(Cfg.LockOn.Smoothness, 0.01, 1)
        -- Frame-rate-independent smoothing + an instant snap on the first frame of a
        -- fresh lock, so locking / switching targets faces them immediately instead
        -- of a slow ramp-in. Snappy to engage, smooth to track.
        local alpha = firstFrame and 1 or math.clamp(1 - (1 - base) ^ (math.max(dt or 0, 0) * 60), 0, 1)
        firstFrame = false

        -- CONSOLE-style lock = do BOTH at once: steer the camera so the enemy stays framed (you
        -- never have to drag your screen on mobile) AND rotate your body to face them (so hits
        -- land). "Body" only turns you (you still drag the cam); "Camera" only moves the cam (body
        -- never turns); "Console" combines them = true console aim-lock feel.
        local method = Cfg.LockOn.Method
        local rotateBody = (method == "Body") or (method == "Console")
        -- Drive the CAMERA for "Camera"/"Console", and ALSO during invisibility (where you're
        -- frozen mid-animation and can't see/aim your own body).
        local steerCam = (method == "Camera") or (method == "Console") or St.invisActive

        -- v109 semantics: Body/Console turn the body; Camera never implicitly becomes Body.
        -- Commit body facing late, AFTER the game's camera/shiftlock pass. Console tracks
        -- faster than its orbit camera so camera easing never slows down hit-facing.
        if rotateBody then
            bodyRoot, bodyHum, bodyTarget = myHRP, myHum, targetCore
            bodyAlpha = method == "Console" and math.max(alpha,
                1 - math.exp(-26 * math.max(dt or 0, 0))) or alpha
        else
            St.Face.release("lockon")
            St.Face.restore(myHum)
        end

        if steerCam then
            -- SMOOTH LOCK-ON CAMERA.
            -- Before, we left the camera in Roblox's default Custom mode and just overwrote its
            -- rotation every frame toward the target. The built-in camera controller kept
            -- re-asserting its OWN orientation from your look/drag input, so the two writes fought
            -- each other -- that tug-of-war is the jitter/"fighting" you saw, and it was worst when
            -- the target was off to the side or behind you (big angle gap = big fight).
            -- Fix: take real ownership with a Scriptable orbit camera. Nothing else writes the camera,
            -- so there's zero conflict -- just a clean, smooth follow that orbits to your far side from
            -- the enemy (framing you both) and eases onto a target that's currently out of view.
            local cam = Workspace.CurrentCamera
            if cam then
                if St.lockCamOwned ~= cam then
                    restoreLockOnCamera()
                    St.lockCamOwned = cam
                    St.lockCamPrevType = cam.CameraType
                    St.lockCamDist = math.clamp((cam.CFrame.Position - myHRP.Position).Magnitude, 8, 22)
                end
                if cam.CameraType ~= Enum.CameraType.Scriptable then
                    -- remember the player's mode + current zoom so we can restore their framing on unlock
                    St.lockCamPrevType = cam.CameraType
                    St.lockCamDist = math.clamp((cam.CFrame.Position - myHRP.Position).Magnitude, 8, 22)
                    cam.CameraType = Enum.CameraType.Scriptable
                end
                local dist = St.lockCamDist or 12
                -- INVIS FIX: the frozen invis pose can drag the HRP underground (that
                -- is why the invis camera anchor exists). While invisible, orbit the
                -- anchor's clamped position instead of the raw HRP so the lock-on
                -- camera can never be yanked under the map.
                local subjectBase = myHRP.Position
                local camAnchor = St.invisActive and St.invisCamAnchor
                if camAnchor and camAnchor.Parent then subjectBase = camAnchor.Position end
                local subjectPos = subjectBase + Vector3.new(0, 1.5, 0)
                local tPos = targetCore.Position
                -- horizontal dir from the target back to you; camera sits on your far side so you're
                -- between it and the enemy (classic lock-on framing). Guard the degenerate overlap case.
                local flat = subjectPos - tPos
                flat = Vector3.new(flat.X, 0, flat.Z)
                flat = (flat.Magnitude > 0.1) and flat.Unit or myHRP.CFrame.LookVector
                local sideOff = targetCore.CFrame.RightVector * Cfg.LockOn.SideOffset
                local camPos = subjectPos + flat * dist + Vector3.new(0, 2.5, 0)
                local lookPoint = subjectPos:Lerp(tPos + sideOff, 0.5)  -- keep both you and the enemy framed
                local goalCamCF = CFrame.lookAt(camPos, lookPoint)
                -- Ease in smoothly (frame-rate independent) WITHOUT the first-frame snap, so a target
                -- behind you glides into view instead of whipping the camera around.
                local camAlpha = math.clamp(1 - (1 - base) ^ (math.max(dt or 0, 0) * 60), 0, 1)
                cam.CFrame = cam.CFrame:Lerp(goalCamCF, camAlpha)
                cam.Focus = CFrame.new(lookPoint)
            end
        else
            -- not steering the camera (e.g. Body method while NOT invisible) -> make sure the player
            -- has their normal free-look camera back if we'd taken it on a previous frame.
            restoreLockOnCamera()
        end
    end)
    RunService:BindToRenderStep("HubLockOnBody", Enum.RenderPriority.Last.Value + 5, function()
        if not St.lockOnEnabled or not bodyRoot or not bodyTarget or not bodyRoot.Parent
            or not bodyTarget.Parent or not bodyHum or bodyHum.Health <= 0 then
            St.Face.release("lockon"); return
        end
        if not St.Face.canTurn(bodyHum) or not St.Face.claim("lockon", 0.09) then
            St.Face.release("lockon"); return
        end
        local delta = (bodyTarget.Position - bodyRoot.Position) * Vector3.new(1, 0, 1)
        if delta.Magnitude <= 0.01 then return end
        bodyHum.AutoRotate = false
        local goal = CFrame.lookAt(bodyRoot.Position, bodyRoot.Position + delta.Unit)
        bodyRoot.CFrame = CFrame.new(bodyRoot.Position) * bodyRoot.CFrame.Rotation:Lerp(goal.Rotation, bodyAlpha)
    end)
end

local function disableLockOn()
    St.lockOnEnabled = false
    St.lockOnTarget = nil
    St.lockOnArmed = false
    RunService:UnbindFromRenderStep("HubLockOnSystem")
    RunService:UnbindFromRenderStep("HubLockOnBody")
    local myChar = LocalPlayer.Character
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    clearLockOnESP()
end

do
    St.releaseLockTarget = function()
        St.lockOnTarget, St.lockOnArmed = nil, false
        RunService:UnbindFromRenderStep("HubLockOnSystem")
        RunService:UnbindFromRenderStep("HubLockOnBody")
        clearLockOnESP()
    end
    Players.PlayerRemoving:Connect(function(other)
        local target = St.lockOnTarget
        if target and (target.name == other.Name or target.Char == other.Character) then St.releaseLockTarget() end
    end)
    LocalPlayer.CharacterRemoving:Connect(St.releaseLockTarget)
end

-- Pick the best target to AUTO-lock when you press the LOCK ON button: the enemy
-- most directly in FRONT of you, within lock range. Lets a single button press lock
-- "whoever I'm facing" (like a soft-aim) instead of forcing you to tap them.
local function getBestFrontTarget(myHRP)
    if not myHRP then return nil end
    local maxWorldDist = Cfg.LockOn.MaxDistance
    local lookVec = myHRP.CFrame.LookVector
    local best, bestScore = nil, -math.huge
    for _, t in ipairs(getValidTargets(myHRP)) do
        if t.Core and t.Humanoid and t.Humanoid.Health > 0 then
            local toT = t.Core.Position - myHRP.Position
            local dist = toT.Magnitude
            if dist > 0 and dist <= maxWorldDist then
                local facing = lookVec:Dot(toT.Unit) -- 1 = dead ahead, 0 = beside, <0 = behind
                if facing > 0.15 then -- roughly in front of you
                    -- prefer most-in-front, then closest
                    local score = facing - (dist / maxWorldDist) * 0.5
                    if score > bestScore then bestScore = score; best = t end
                end
            end
        end
    end
    return best
end

-- MOBILE aim-lock helper: pick the enemy nearest the CENTER of your screen (i.e. whoever your
-- camera is pointing at), within lock range and actually on-screen. This lets a single button
-- press lock "whoever I'm aiming at" with ZERO reliance on tapping the screen, so dragging or
-- rotating the camera can never lock onto a random player.
local function getTargetNearestScreenCenter(myHRP)
    local cam = Workspace.CurrentCamera
    if not myHRP or not cam then return nil end
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local maxPix = math.min(vp.X, vp.Y) * 0.30   -- must be roughly centred (within ~30% of the smaller screen dimension)
    local maxWorldDist = Cfg.LockOn.MaxDistance
    local best, bestPix = nil, maxPix
    for _, t in ipairs(getValidTargets(myHRP)) do
        if t.Core and t.Humanoid and t.Humanoid.Health > 0 then
            local wd = (t.Core.Position - myHRP.Position).Magnitude
            if wd <= maxWorldDist then
                local sp, onScreen = cam:WorldToViewportPoint(t.Core.Position)
                if onScreen and sp.Z > 0 then
                    local pix = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if pix < bestPix then bestPix = pix; best = t end
                end
            end
        end
    end
    return best
end

local function setupShrinkForChar(char)
    if not char then return end
    task.spawn(function()
        local ok, model = pcall(function() return InsertService:LoadAsset(Cfg.DRONE_ID) end)
        if ok and model and model:FindFirstChildOfClass("Accessory") then
            model:FindFirstChildOfClass("Accessory").Parent = char; char.Humanoid:AddAccessory(model:FindFirstChildOfClass("Accessory"))
        end
    end)
    local anim = Instance.new("Animation"); anim.AnimationId = Cfg.SHRINK_ANIM_ID
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        local track = hum:LoadAnimation(anim)
        track:Play(); task.wait(); track.TimePosition = 2.1; track:AdjustSpeed(0)
    end
end

-- ============================================================
-- FULL V32 FLIGHT SYSTEM (ANIMATIONS, SOUND, BOOST, FOV, SMART MOBILE)
-- ============================================================
do
    local FLY_IDLE  = "idle"
    local FLY_MOVE  = "move"
    local FLY_BOOST = "boost"
    local FLY_RIGHT = "right"
    local FLY_LEFT  = "left"
    local FLY_BACK  = "back"

    local flyHiddenPart, flyFlySound, flyBoostSndRef = nil, nil, nil

    local function flyStopTrack(track)
        if track then pcall(function() track:Stop(0.12); track:Destroy() end) end
    end

    local function flyStopAllAnims()
        flyStopTrack(St.flyIdleTrack);  St.flyIdleTrack  = nil
        flyStopTrack(St.flyMoveTrack);  St.flyMoveTrack  = nil
        flyStopTrack(St.flyBoostTrack); St.flyBoostTrack = nil
        flyStopTrack(St.flyRightTrack); St.flyRightTrack = nil
        flyStopTrack(St.flyLeftTrack);  St.flyLeftTrack  = nil
        flyStopTrack(St.flyBackTrack);  St.flyBackTrack  = nil
        St.flyCurrentAnimState = nil
    end

    local _flyAnimCache = {}
    local function flyLoadTrack(animId, looped, speed, timePos)
        if not St.flyAnimator then return nil end
        if not _flyAnimCache[animId] then
            local a = Instance.new("Animation"); a.AnimationId = animId
            _flyAnimCache[animId] = a
        end
        local ok, track = pcall(function() return St.flyAnimator:LoadAnimation(_flyAnimCache[animId]) end)
        if not ok or not track then return nil end
        track.Priority = Enum.AnimationPriority.Idle
        track.Looped   = looped
        track:Play(0.15)
        track:AdjustSpeed(speed)
        if timePos and timePos > 0 then
            task.delay(0.06, function() if track and track.IsPlaying then pcall(function() track.TimePosition = timePos end) end end)
        end
        return track
    end

    local function flySetState(newState)
        if St.flyCurrentAnimState == newState then return end
        local old = St.flyCurrentAnimState
        St.flyCurrentAnimState = newState
        if old == FLY_IDLE then flyStopTrack(St.flyIdleTrack); St.flyIdleTrack = nil
        elseif old == FLY_MOVE then flyStopTrack(St.flyMoveTrack); St.flyMoveTrack = nil
        elseif old == FLY_BOOST then
            flyStopTrack(St.flyBoostTrack); St.flyBoostTrack = nil
            TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView=90}):Play()
        elseif old == FLY_RIGHT then flyStopTrack(St.flyRightTrack); St.flyRightTrack = nil
        elseif old == FLY_LEFT then flyStopTrack(St.flyLeftTrack); St.flyLeftTrack = nil
        elseif old == FLY_BACK then flyStopTrack(St.flyBackTrack); St.flyBackTrack = nil
        end
        if newState == FLY_IDLE then St.flyIdleTrack = flyLoadTrack("rbxassetid://91408938873266", true, 0, 1.5)
        elseif newState == FLY_MOVE then St.flyMoveTrack = flyLoadTrack("rbxassetid://9443519528", true, 0, 1)
        elseif newState == FLY_BOOST then
            St.flyBoostTrack = flyLoadTrack("rbxassetid://15984964491", true, 0, 0.5)
            TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView=120}):Play()
            if flyBoostSndRef then pcall(function() flyBoostSndRef.TimePosition = 0; flyBoostSndRef:Play() end) task.delay(1.5, function() if flyBoostSndRef then pcall(function() flyBoostSndRef:Pause() end) end end) end
        elseif newState == FLY_RIGHT then St.flyRightTrack = flyLoadTrack("rbxassetid://9443521999", true, 0, 0.02083333395421505)
        elseif newState == FLY_LEFT then St.flyLeftTrack = flyLoadTrack("rbxassetid://9443520855", true, 0, 0.02083333395421505)
        elseif newState == FLY_BACK then St.flyBackTrack = flyLoadTrack("rbxassetid://9443517965", true, 0, 0.03333333507180214)
        end
    end

    local function flyGetSpeed() return flyKeys.Boost and math.min(Cfg.FlySpeed + 200, 650) or Cfg.FlySpeed end

    local function flyBuildHiddenPart(hrp)
        if flyHiddenPart then flyHiddenPart:Destroy() end
        if flyFlySound then pcall(function() flyFlySound:Stop(); flyFlySound:Destroy() end) end
        if flyBoostSndRef then pcall(function() flyBoostSndRef:Stop(); flyBoostSndRef:Destroy() end) end
        
        flyHiddenPart = Instance.new("Part"); flyHiddenPart.Size=Vector3.new(0.05,0.05,0.05); flyHiddenPart.Transparency=1; flyHiddenPart.CanCollide=false; flyHiddenPart.CFrame=hrp.CFrame; flyHiddenPart.Parent=Workspace
        local weld=Instance.new("Weld", flyHiddenPart); weld.Part0=flyHiddenPart; weld.Part1=hrp
        St.flyBodyVelocity=Instance.new("BodyVelocity", flyHiddenPart); St.flyBodyVelocity.MaxForce=Vector3.new(1e9,1e9,1e9); St.flyBodyVelocity.P=1250; St.flyBodyVelocity.Velocity=Vector3.zero
        St.flyBodyGyro=Instance.new("BodyGyro", flyHiddenPart); St.flyBodyGyro.MaxTorque=Vector3.new(1e9,1e9,1e9); St.flyBodyGyro.P=1000; St.flyBodyGyro.D=50

        local snd = Instance.new("Sound"); snd.Name = "FlyAmbient"; snd.SoundId = "rbxassetid://79148321721845"; snd.Volume = 0.8; snd.PlaybackSpeed = 0.8; snd.Looped = true; snd.Parent = Camera
        local bsnd = Instance.new("Sound"); bsnd.Name = "FlyBoostSnd"; bsnd.SoundId = "rbxassetid://858508159"; bsnd.Volume = 1; bsnd.PlaybackSpeed = 1; bsnd.Looped = false; bsnd.Parent = Camera
        flyFlySound = snd; flyBoostSndRef = bsnd
    end

    local function enableFly()
        St.flyCharacter = LocalPlayer.Character; if not St.flyCharacter then return end
        St.flyHumanoid = St.flyCharacter:FindFirstChildOfClass("Humanoid")
        St.flyRootPart = St.flyCharacter:FindFirstChild("HumanoidRootPart")
        if not St.flyHumanoid or not St.flyRootPart then return end
        
        St.flyAnimator = St.flyHumanoid:FindFirstChildOfClass("Animator")
        if not St.flyAnimator then St.flyAnimator = Instance.new("Animator", St.flyHumanoid) end

        St.flyOriginalFOV = Camera.FieldOfView; St.flyWasMoving = false; flyKeys.Boost = false
        flyBuildHiddenPart(St.flyRootPart)
        pcall(function() St.flyHumanoid.PlatformStand = true end)
        flySetState(FLY_IDLE)
        if flyFlySound then pcall(function() flyFlySound:Play() end) end

        TweenService:Create(Camera, TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), {FieldOfView=90}):Play()

        Cn.flyConnection = RunService.Heartbeat:Connect(function()
            if not St.flyActive then return end
            if not St.flyRootPart or not St.flyRootPart.Parent then return end
            -- keep the on-screen joystick + buttons alive the WHOLE time fly is on (fly
            -- reads the joystick to steer), so they don't vanish the moment you tap FLY.
            if mobile then forceTouchVisible() end
            
            pcall(function() St.flyHumanoid.PlatformStand = true end)
            pcall(function()
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            end)

            local camCF = Camera.CFrame
            St.flyBodyGyro.CFrame = CFrame.lookAt(St.flyRootPart.Position, St.flyRootPart.Position + camCF.LookVector)
            
            local localMove = Vector3.zero
            if PlayerModuleControls then
                localMove = PlayerModuleControls:GetMoveVector()
            end
            
            if localMove.Magnitude < 0.01 and not mobile then
                localMove = Vector3.new((flyKeys.D and 1 or 0)-(flyKeys.A and 1 or 0), 0, (flyKeys.S and 1 or 0)-(flyKeys.W and 1 or 0))
            end

            local combinedMove = Vector3.new(localMove.X, (flyKeys.Up and 1 or 0)-(flyKeys.Down and 1 or 0), localMove.Z)
            
            if combinedMove.Magnitude > 0.01 then
                local spd = flyGetSpeed()
                local mv = (camCF:VectorToWorldSpace(combinedMove)).Unit * spd
                pcall(function() St.flyBodyVelocity.Velocity = mv end)

                local newAnimState = FLY_MOVE
                if combinedMove.Z < -0.1 then newAnimState = flyKeys.Boost and FLY_BOOST or FLY_MOVE
                elseif combinedMove.X > 0.1 then newAnimState = FLY_RIGHT
                elseif combinedMove.X < -0.1 then newAnimState = FLY_LEFT
                elseif combinedMove.Z > 0.1 then newAnimState = FLY_BACK end
                
                flySetState(newAnimState); St.flyWasMoving = true
            else
                St.flyBodyVelocity.Velocity = Vector3.zero
                if St.flyWasMoving then St.flyWasMoving = false; flyKeys.Boost = false end
                flySetState(FLY_IDLE)
            end
        end)
    end

    local function disableFly()
        St.flyActive=false; if Cn.flyConnection then Cn.flyConnection:Disconnect() end
        if mobile then reassertControls() end
        flyStopAllAnims()
        if flyFlySound then pcall(function() flyFlySound:Stop(); flyFlySound:Destroy() end) flyFlySound = nil end
        if flyBoostSndRef then pcall(function() flyBoostSndRef:Stop(); flyBoostSndRef:Destroy() end) flyBoostSndRef = nil end
        if flyHiddenPart then flyHiddenPart:Destroy() flyHiddenPart = nil end
        if St.flyHumanoid then 
            pcall(function()
                St.flyHumanoid.PlatformStand=false
                St.flyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                St.flyHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            end) 
        end
        TweenService:Create(Camera, TweenInfo.new(0.35,Enum.EasingStyle.Sine,Enum.EasingDirection.Out), {FieldOfView=St.flyOriginalFOV}):Play()
    end
    _G.enableFly = enableFly; _G.disableFly = disableFly
end
local enableFly = _G.enableFly; local disableFly = _G.disableFly

-- ============================================================
-- ITEM GRABBER (BACKEND)
-- ============================================================
local function zeroAllPrompts()
    local folder=Workspace:FindFirstChild("Items"); if not folder then return end
    for _, item in ipairs(folder:GetChildren()) do
        local prompt=item:FindFirstChildWhichIsA("ProximityPrompt",true)
        if prompt then prompt.HoldDuration=0 end
    end
end
zeroAllPrompts()

local function grabItem(item, onDone)
    local prompt=item:FindFirstChildWhichIsA("ProximityPrompt",true)
    if not prompt then notify("Item Grab","No prompt found!",3); if onDone then onDone(false) end; return end
    local char=LocalPlayer.Character; if not char then if onDone then onDone(false) end; return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then if onDone then onDone(false) end; return end
    local itemPos = item:IsA("Model") and item:GetPivot().Position or item.Position
    local returnCFrame=hrp.CFrame; prompt.HoldDuration=0
    local grabCFrame=CFrame.new(itemPos+Vector3.new(0,1.5,0))
    local done=false
    local function finish(success)
        if done then return end; done=true
        if hrp and hrp.Parent then hrp.CFrame=returnCFrame end
        if onDone then onDone(success) end
    end
    local renderConn; renderConn=RunService.RenderStepped:Connect(function()
        if done then renderConn:Disconnect(); return end
        if not prompt.Parent then renderConn:Disconnect(); finish(true); return end
        hrp.CFrame=grabCFrame; pcall(function() fireproximityprompt(prompt,0) end)
    end)
    task.delay(2,function() if not done then renderConn:Disconnect(); finish(false) end end)
end

local function getItemsList()
    local items={}; local folder=Workspace:FindFirstChild("Items"); if not folder then return items end
    for _, child in ipairs(folder:GetChildren()) do
        local prompt=child:FindFirstChildWhichIsA("ProximityPrompt",true)
        if prompt then table.insert(items,{name=child.Name,part=child,prompt=prompt}) end
    end
    return items
end

local function yonkToggle()
    St.yonkEnabled = not St.yonkEnabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if St.yonkEnabled then
        local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://72042024"
        St.yonkAnimTrack = hum:LoadAnimation(anim); St.yonkAnimTrack.Priority = Enum.AnimationPriority.Action4; St.yonkAnimTrack.Looped = true
        St.yonkAnimTrack:Play(); St.yonkAnimTrack:AdjustSpeed(St.yonkSpeed)
    else if St.yonkAnimTrack then St.yonkAnimTrack:Stop(); St.yonkAnimTrack:Destroy() end end
end

local lastQtePress = 0
local function hiromiHandleQTE(qteGui)
    local c; c = RunService.Heartbeat:Connect(function()
        if not qteGui.Parent or not St.autoQteEnabled then c:Disconnect() return end
        
        local delayInterval = 1 / math.clamp(St.qteSpeed, 1, 100)
        if tick() - lastQtePress < delayInterval then return end
        
        local pc = qteGui:FindFirstChild("QTE_PC", true); local mob = qteGui:FindFirstChild("QTE_MOBILE", true)
        if pc and pc.Text:match("^%a$") then
            local kc = Enum.KeyCode[pc.Text]
            if kc then 
                lastQtePress = tick()
                St.MarkSyntheticKey(kc, 0.3)
                VirtualInputManager:SendKeyEvent(true, kc, false, game)
                task.delay(0.02, function() VirtualInputManager:SendKeyEvent(false, kc, false, game) end) 
            end
        elseif mob then
            lastQtePress = tick()
            local pos = mob.AbsolutePosition + mob.AbsoluteSize * 0.5
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
            task.delay(0.02, function() VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0) end)
        end
    end)
end

local function startNanami()
    St.nanamiEnabled = true
    if Cn.nanamiRatioConn then Cn.nanamiRatioConn:Disconnect() end
    -- The ratio is a timing-bar minigame. On "SpawnRatio" the server sends the
    -- window `duration` and its spawn `serverTimestamp`. A cursor slides Y=1 -> Y=0
    -- over `duration`s, where Y = 1 - (serverNow - spawnTime)/duration, and the hit
    -- CENTER is Y=0.30. So instead of guessing a fixed delay, we solve for the exact
    -- server-time of the sweet spot and fire RightActivated then -- leading by our
    -- ping so the server registers it dead-center. No fixed delay and no cooldown,
    -- so each ratio self-times (combos work), and it self-aborts if the point is hit
    -- early or the window closes. Event is broadcast, so we filter to our own ratio.
    local HIT_Y, MAX_LEAD = 0.30, 0.12
    Cn.nanamiRatioConn = ReplicatedStorage.Knit.Knit.Services.NanamiService.RE.Effects.OnClientEvent:Connect(function(...)
        if not St.nanamiEnabled or select(1, ...) ~= "SpawnRatio" then return end
        local attacker, target, billboard, hitFlag, duration, spawnTime = select(2, ...)
        if attacker ~= LocalPlayer then return end
        if type(duration) ~= "number" or type(spawnTime) ~= "number" then return end
        task.spawn(function()
            local lead = 0
            pcall(function() lead = math.clamp(LocalPlayer:GetNetworkPing(), 0, MAX_LEAD) end)
            local fireLocalT = spawnTime + (1 - HIT_Y) * duration - lead
            while St.nanamiEnabled do
                if hitFlag and hitFlag.Value == true then return end       -- already hit
                if billboard and billboard.Parent == nil then return end    -- window gone
                local now = workspace:GetServerTimeNow()
                if now > spawnTime + duration then return end               -- window closed
                if now >= fireLocalT then break end
                RunService.Heartbeat:Wait()
            end
            if not St.nanamiEnabled or (hitFlag and hitFlag.Value == true) then return end
            pcall(function() ReplicatedStorage.Knit.Knit.Services.NanamiService.RE.RightActivated:FireServer(target) end)
        end)
    end)
end

local function stopNanami()
    St.nanamiEnabled = false
    if Cn.nanamiRatioConn then Cn.nanamiRatioConn:Disconnect(); Cn.nanamiRatioConn = nil end
end

-- ===== Auto Downslam (PC + mobile unified) =====
-- Mechanism (confirmed via decompile of the ToolController melee loop):
--     local airborne = Humanoid.FloorMaterial == Enum.Material.Air
--     local jumping  = Humanoid.Jump == true
--     local dir      = airborne and "Down" or jumping and "Up" or false  -- false = grounded normal hit
--     ToolController:UseSetService("Activated", dir, GetTarget())
-- A normal grounded M1 therefore sends dir == false. We intercept that ONE call and, while
-- the toggle is on, rewrite a NEUTRAL grounded hit (false/nil) into "Down" so every hit lands
-- as a downslam -- no hop, no re-fire, no client/server desync.
--
-- PRIMARY: hook tc.UseSetService at the Lua-table level. Needs NO hookmetamethod, so it works
--          identically on locked-down mobile executors (Delta/Fluxus) and on PC.
-- FALLBACK: if UseSetService isn't a plain function on this executor, hook the moveset
--          service's Activated remote via hookmetamethod (PC-class executors).
do
    -- Only convert a NEUTRAL hit (false/nil). An explicit "Up"/"Down" the game already chose
    -- (airborne finisher, jump-cancel, etc.) passes through untouched.
    local function wantDown(dir)
        -- BLATANT only: instantly rewrite a neutral M1 -> "Down". In LEGIT mode we leave the
        -- remote untouched and instead jump at combo-3 (see the legit controller below).
        return St.autoDownslamEnabled and St.downslamMode == "blatant" and (dir == false or dir == nil)
    end
    -- Auto Uppercut is the exact mirror of downslam: rewrite a NEUTRAL grounded hit
    -- (false/nil) into "Up" -- the same value the game uses for jump uppercuts --
    -- so every grounded M1 launches as an uppercut. Mutually exclusive with downslam.
    local function wantUp(dir)
        return St.autoUppercutEnabled and (dir == false or dir == nil)
    end

    -- ===== Legit Downslam combo tracker =====
    -- LEGIT mode rewrites NOTHING. We count genuine M1s off the SAME "Activated" signal the
    -- hooks below already see (guaranteed to fire -- that's how blatant works), and on the 3rd
    -- hit we force the character airborne, so the GAME itself computes your 4th M1 as "Down".
    -- The hop uses a state change + Humanoid.Jump + a direct upward velocity so it lifts off
    -- even while the attack state would normally swallow a plain Humanoid.Jump. Mobile + PC.
    local legitCombo, legitLastM1T, legitComboT = 0, 0, 0
    local legitArmed = true
    local function legitJump()
        local chr = LocalPlayer.Character
        if not chr then return end
        local hum = chr:FindFirstChildOfClass("Humanoid")
        local hrp = chr:FindFirstChild("HumanoidRootPart")
        if hum then
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            hum.Jump = true
        end
        if hrp then
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 50, v.Z)
        end
    end
    -- Only treat an M1 as "landed" when a live enemy is within 10 studs -- this stops the legit
    -- hop from firing on whiffed air swings (which felt like random jumps).
    local function legitHittingSomeone()
        local chr = LocalPlayer.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local folder = Workspace:FindFirstChild("Characters")
        if not folder then return false end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj ~= chr then
                local hum = obj:FindFirstChild("Humanoid")
                local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                if hum and part and hum.Health > 0 and (part.Position - hrp.Position).Magnitude <= 10 then
                    return true
                end
            end
        end
        return false
    end
    local function noteLegitM1()
        if not (St.autoDownslamEnabled and St.downslamMode == "legit") then return end
        local chr = LocalPlayer.Character
        if not chr then return end
        -- Don't hop on whiffs: only react to M1s thrown with an enemy within 10 studs.
        if not legitHittingSomeone() then return end
        -- PREFERRED: gate on the game's REAL combo counter so we hop EXACTLY ONCE, on the 3rd
        -- hit, no matter how many times the M1 remote fires per tap. (That was the "jump every
        -- click" bug -- our manual counter raced because Activated can fire several times a tap.)
        local m1 = chr:GetAttribute("CurrentM1")
        if type(m1) == "number" then
            if m1 < 3 then
                legitArmed = true                 -- early in the combo -> re-arm for next finisher
            elseif legitArmed then
                legitArmed = false                -- 3rd+ hit reached -> hop ONCE this combo
                legitJump()
            end
            return
        end
        -- FALLBACK (combo attribute unavailable): manual count, de-duped by time so the repeated
        -- Activated calls for ONE tap collapse into a single counted M1.
        local now = tick()
        if now - legitLastM1T < 0.12 then return end
        legitLastM1T = now
        if now - legitComboT > 1.2 then legitCombo = 0 end
        legitComboT = now
        legitCombo = legitCombo + 1
        if legitCombo == 3 then legitJump() end
        if legitCombo >= 4 then legitCombo = 0 end
    end

    -- ---- PRIMARY: ToolController.UseSetService table hook (PC + mobile) ----
    local ussHooked = false
    pcall(function()
        local tc = nhGetToolController()
        if tc and type(tc.UseSetService) == "function" then
            -- Safe re-run: if we already hooked this controller, restore first so we never wrap
            -- our own wrapper (which would capture the hooked fn as the "original").
            if _G.NH_origUSS then pcall(function() tc.UseSetService = _G.NH_origUSS end) end
            _G.NH_origUSS = tc.UseSetService
            tc.UseSetService = function(self, name, dir, ...)
                if name == "Activated" then
                    -- Universal, moveset-agnostic genuine-M1 signal: the game routes EVERY
                    -- moveset's M1 through ToolController:UseSetService("Activated", dir, target).
                    -- Fire the block-break check here so it works on ANY character/mode -- not just
                    -- the hardcoded vessel M1 animation IDs in M1_ANIMS. Our own auto-M1s fire the
                    -- moveset remote directly (not via UseSetService) and are also guarded by
                    -- lastAutoM1, so they never false-trigger this.
                    if _G.NH_tryBlockBreak then task.spawn(_G.NH_tryBlockBreak) end
                    noteLegitM1()
                    if wantDown(dir) then dir = "Down" elseif wantUp(dir) then dir = "Up" end
                end
                return _G.NH_origUSS(self, name, dir, ...)
            end
            ussHooked = true
        end
    end)

    -- ---- FALLBACK: __namecall hook on the moveset's Activated remote ----
    -- Resolves the per-moveset remote (e.g. DivergentFistService.RE.Activated) and refreshes it
    -- on moveset change. Only installed when the table hook could not be installed.
    if not ussHooked then
        local dsRemote = nil
        local function resolveDS()
            local ok, re = pcall(function()
                local mv = LocalPlayer:GetAttribute("Moveset")
                return ReplicatedStorage.Knit.Knit.Services[(tostring(mv):gsub("%s", "")) .. "Service"].RE.Activated
            end)
            dsRemote = ok and re or nil
        end
        resolveDS()
        pcall(function() LocalPlayer:GetAttributeChangedSignal("Moveset"):Connect(resolveDS) end)
        pcall(function() LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3) resolveDS() end) end)

        local oldDS
        local function dsHook(self, ...)
            if self == dsRemote and getnamecallmethod() == "FireServer" then
                -- Genuine user M1 on this moveset's Activated remote -> run the block-break check
                -- (moveset-agnostic). lastAutoM1 inside the check ignores our own auto-M1s.
                if _G.NH_tryBlockBreak then task.spawn(_G.NH_tryBlockBreak) end
                noteLegitM1()
                local a = { ... }
                if wantDown(a[1]) then
                    a[1] = "Down"
                    return oldDS(self, unpack(a))
                elseif wantUp(a[1]) then
                    a[1] = "Up"
                    return oldDS(self, unpack(a))
                end
            end
            return oldDS(self, ...)
        end
        local okHook = pcall(function() oldDS = hookmetamethod(game, "__namecall", dsHook) end)
        if not okHook then
            warn("[NH] auto-downslam: neither UseSetService nor hookmetamethod is available on this executor")
        end
    end
end

local function startAutoQTE()
    St.autoQteEnabled = true
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    if Cn.qteGuiAddedConn then Cn.qteGuiAddedConn:Disconnect() end
    Cn.qteGuiAddedConn = pg.ChildAdded:Connect(function(c)
        if c.Name == "QTE" and St.autoQteEnabled then hiromiHandleQTE(c) end
    end)
    
    for _, c in ipairs(pg:GetChildren()) do
        if c.Name == "QTE" then hiromiHandleQTE(c) end
    end
end

local function stopAutoQTE()
    St.autoQteEnabled = false
    if Cn.qteGuiAddedConn then Cn.qteGuiAddedConn:Disconnect(); Cn.qteGuiAddedConn = nil end
end

-- ============================================================
-- TODO PERFECT CLAP (EXACT ORIGINAL)
-- ============================================================
local todoAnims = {
    ["rbxassetid://131358603583212"] = true,
    ["rbxassetid://91074768993486"] = true,
    ["rbxassetid://116040503139675"] = true
}
local function setupTodoClap(char)
    if Cn.todoAnimConn then Cn.todoAnimConn:Disconnect(); Cn.todoAnimConn = nil end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    Cn.todoAnimConn = hum.AnimationPlayed:Connect(function(track)
        if not St.todoEnabled then return end
        local animId = track.Animation and track.Animation.AnimationId or ""
        if not todoAnims[animId] then return end
        
        task.spawn(function()
            while track.IsPlaying and track.TimePosition < 0.55 do task.wait() end
            if St.todoEnabled and track.TimePosition >= 0.55 then
                pcall(function()
                    ReplicatedStorage.Knit.Knit.Services.TodoService.RE.Activated:FireServer(false)
                end)
            end
        end)
    end)
end
LocalPlayer.CharacterAdded:Connect(function(char) setupTodoClap(char) end)
if LocalPlayer.Character then setupTodoClap(LocalPlayer.Character) end

-- ============================================================
-- AUTO BLOCK SOLO TARGET  (_G.NH_AutoBlockSolo)
--   Enable it, then lock onto someone with ANY lock-on path (PC key,
--   mobile LOCK ON button, or the "Lock Selected Target" button).
--   That person becomes your SOLO block target:
--     * a cyan marker confirms who you locked onto for 3s, then fades out
--     * auto-block / punish / projectile-block now respond to THEM ONLY
--     * the 30Hz animation scanner and the per-frame projectile pass only
--       ever look at ONE enemy instead of every enemy on the server
--       (this is the big lag reduction)
--     * "Clear Solo Target" (Combat tab) or the SOLO BLK mobile button
--       drops them so you can re-choose
--   Lives in its own IIFE so it costs zero main-chunk locals (the file is
--   at the 200-active-locals limit). Detection gates reach it through
--   _G.NH_AutoBlockSolo.IsActive(), so they add no locals either.
-- ============================================================
do
    local Solo = {}
    _G.NH_AutoBlockSolo = Solo

    local MARK_TIME = 3.0   -- seconds the cyan marker stays fully visible
    local FADE_TIME = 0.6   -- seconds to fade it out after that

    local hl            = nil   -- cyan Highlight (target visible through walls)
    local tag           = nil   -- BillboardGui name tag above their head
    local tagLabel      = nil   -- the TextLabel inside the tag (for the fade)
    local markUntil     = 0     -- os.clock() when the marker starts fading
    local lastTargetChar = nil  -- last char we adopted, so we only react to real switches

    local function clearMarker()
        if hl       then pcall(function() hl:Destroy()  end) end
        if tag      then pcall(function() tag:Destroy() end) end
        hl, tag, tagLabel = nil, nil, nil
    end

    local function buildMarker(char, name)
        clearMarker()
        if typeof(char) ~= "Instance" or not char.Parent then return end
        hl = Instance.new("Highlight")
        hl.Name = "NH_SoloBlockMarker"
        hl.FillColor = Color3.fromRGB(0, 200, 255)
        hl.OutlineColor = Color3.fromRGB(150, 240, 255)
        hl.FillTransparency = 0.55
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        tag = Instance.new("BillboardGui")
        tag.Name = "NH_SoloBlockTag"
        tag.Size = UDim2.fromOffset(240, 42)
        tag.StudsOffset = Vector3.new(0, 3.4, 0)
        tag.AlwaysOnTop = true
        tag.LightInfluence = 0
        tag.Adornee = char:FindFirstChild("HumanoidRootPart") or char
        tagLabel = Instance.new("TextLabel")
        tagLabel.BackgroundTransparency = 1
        tagLabel.Size = UDim2.fromScale(1, 1)
        tagLabel.Font = Enum.Font.GothamBold
        tagLabel.TextSize = 17
        tagLabel.TextColor3 = Color3.fromRGB(160, 245, 255)
        tagLabel.TextStrokeColor3 = Color3.fromRGB(0, 40, 60)
        tagLabel.TextStrokeTransparency = 0.35
        tagLabel.Text = "SOLO BLOCK: " .. tostring(name)
        tagLabel.Parent = tag
        tag.Parent = char
    end

    function Solo.GetTarget()
        return St.autoBlockSoloTarget
    end

    function Solo.GetTargetChar()
        if not St.autoBlockSoloEnabled then return nil end
        local t = St.autoBlockSoloTarget
        if type(t) ~= "table" then return nil end
        local char = t.Char
        if typeof(char) ~= "Instance" or not char:IsA("Model") or not char.Parent then return nil end
        local hum = t.Humanoid
        if typeof(hum) ~= "Instance" or not hum:IsA("Humanoid") or hum.Parent ~= char then
            hum = char:FindFirstChildOfClass("Humanoid")
        end
        if not hum or hum.Health <= 0 then return nil end
        local core = t.Core
        if typeof(core) ~= "Instance" or not core:IsA("BasePart")
            or not core.Parent or not core:IsDescendantOf(char) then
            core = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        end
        if not core or not core.Parent then return nil end
        return char
    end

    -- True when the feature is on AND the solo target is still alive/present.
    -- Every auto-block detection gate calls this: if it returns true, only the
    -- solo target is ever served, everyone else is ignored outright.
    function Solo.IsActive()
        return St.autoBlockSoloEnabled == true and Solo.GetTargetChar() ~= nil
    end

    function Solo.SetTarget(t)
        if type(t) ~= "table" or not t.Char then return end
        St.autoBlockSoloTarget = t
        lastTargetChar = t.Char
        markUntil = os.clock() + MARK_TIME
        buildMarker(t.Char, t.name)
    end

    function Solo.Clear()
        St.autoBlockSoloTarget = nil
        lastTargetChar = nil
        clearMarker()
    end

    -- Observer over St.lockOnTarget. Every lock path (PC keybind, mobile LOCK ON
    -- button, dropdown "Lock Selected Target") writes St.lockOnTarget, so watching
    -- it here adopts/switches the solo target for all of them with zero edits there.
    RunService.Heartbeat:Connect(function()
        if not St.autoBlockSoloEnabled then
            if St.autoBlockSoloTarget then Solo.Clear() end
            return
        end

        -- adopt / switch: the lock is pointing at someone we are not already solo-blocking
        local lt = St.lockOnTarget
        if lt and lt.Char then
            if lt.Char ~= lastTargetChar then
                Solo.SetTarget(lt)
                notify("Solo Block", "Locked onto " .. tostring(lt.name) .. ". Auto-block now ignores everyone else.", 3)
            elseif not hl and St.autoBlockSoloTarget == lt then
                -- re-locked the same person after their marker already faded: flash it again
                markUntil = os.clock() + MARK_TIME
                buildMarker(lt.Char, lt.name)
            end
        end

        -- validate: drop a dead / despawned target so the gates fall back to normal
        if St.autoBlockSoloTarget and not Solo.IsActive() then
            Solo.Clear()
            notify("Solo Block", "Target lost. Lock onto someone else to re-choose.", 3)
            return
        end

        -- marker lifecycle: solid for MARK_TIME, fade out over FADE_TIME, then gone.
        -- Auto-block keeps guarding them silently after the marker disappears.
        if hl or tag then
            local now = os.clock()
            if now <= markUntil then return end
            local f = math.clamp((now - markUntil) / FADE_TIME, 0, 1)
            if f >= 1 then
                clearMarker()
            else
                if hl then
                    hl.FillTransparency = 0.55 + 0.45 * f
                    hl.OutlineTransparency = f
                end
                if tagLabel then
                    tagLabel.TextTransparency = f
                    tagLabel.TextStrokeTransparency = 0.35 + 0.65 * f
                end
            end
        end
    end)

    print("[NH Hub] Auto Block Solo Target ready. Lock onto someone to assign your solo block target.")
end

-- ============================================================
-- AUTO BLOCK + AUTO DASH PREDICT + PUNISH
-- ============================================================
do
    local player = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local Knit = rs:WaitForChild("Knit"):WaitForChild("Knit")
    local BlockActivated = Knit.Services.BlockService.RE.Activated
    local BlockDeactivated = Knit.Services.BlockService.RE.Deactivated

    -- SUCCESSFUL-BLOCK SIGNAL (verified live in a VIP server): the server fires
    -- BlockService.RE.Effects at us exactly when one of our blocks absorbs a hit.
    -- A clean unblocked hit fires NOTHING. Auto Punish must only commit after a
    -- confirmed block, so this timestamp is the gate.
    -- The timestamp lives in blockState (not a local) and the connection is wrapped
    -- in do/end -- both keep the main chunk clear of extra locals, which is at
    -- Lua's local-variable limit.
    do
        local effectsRemote = Knit.Services.BlockService.RE:FindFirstChild("Effects")
        if effectsRemote then
            effectsRemote.OnClientEvent:Connect(function(who)
                if who == player or who == player.Character or who == LocalPlayer.Character then
                    getgenv().blockState.lastSuccessfulBlock = os.clock()
                end
            end)
        end
    end

    local AttackService = Knit.Services:FindFirstChild("AttackService") or Knit.Services:FindFirstChild("CombatService")
    local AttackActivated = nil
    if AttackService then
        local re = AttackService:FindFirstChild("RE")
        if re then
            AttackActivated = re:FindFirstChild("Activated") or re:FindFirstChild("Swing") or re:FindFirstChild("Attack")
        end
    end

    local Config = {
        CounterEnabled = true,
        CounterDelay = 0.14,
        CounterCooldown = 0.5,
        AutoBlockHoldFrames = 12,
        MeleeRange = 5, -- hard 3D limit for normal M1 auto-block; dash/projectiles stay independent
        BlockBreakRange = 10, -- keep the separate offensive block-break feature unchanged
        -- Reject a melee swing when we are behind the attacker. Use the frontal
        -- half-plane rather than the old narrower cone, which dropped angled M1s.
        AutoBlockPovDegrees = 180,
        -- RANGE CAPS: Auto Block / Auto Punish never consider an attacker beyond
        -- AutoBlockScanRange (hard 50). Auto Projectile Block may reach the full
        -- ProjectileRange (100). These cap both the trigger distance AND the
        -- animation-scan cull, so a 60-player server can't burn frames enumerating
        -- animation tracks for people too far away to matter.
        AutoBlockScanRange = 50,
        ProjectileRange = 100,
        -- SMART FACING: never turn toward an attacker beyond FaceRadius studs, no
        -- matter what. Within it, only face people actually aiming at us (the aim
        -- cone tightens with distance). This is the anti-"looking at every player"
        -- cap -- detection still runs server-wide, but our body only reacts to a
        -- real, nearby threat.
        FaceRadius = 16,
        FaceAimConeNear = 0.15,   -- dot threshold when the attacker is inside FaceRadius (wide)
        FaceAimConeFar = 0.45,    -- dot threshold near the edge of FaceRadius (tight)
        -- How long ago a verified successful block still counts as "we just blocked
        -- them" for Auto Punish gating. A block->punish window is a few hundred ms;
        -- this gives slack for the highest-ping servers without letting a stale
        -- block authorize a punish on a later, unrelated exchange.
        BlockSuccessWindow = 0.60,
        HarutaDodgeRange = 14,   -- studs: max attacker distance for the swordless-Haruta auto-dodge
    }

    getgenv().userIsBlocking = false
    getgenv().blockState = {
        active = false, holdFrames = 0, cooldown = 0, lastSuccessfulBlock = 0,
        holdTarget = nil, projectileSourceChar = nil,
    }

    -- Shared fail-closed gate for M1, cast, projectile, and dash defenses.
    -- With Solo Block off everyone remains eligible; with it on, only the valid
    -- lock-selected character is eligible. No lock means no automated target.
    _G.NH_IsSoloBlockTarget = function(character)
        if not St.autoBlockSoloEnabled then return true end
        local solo = _G.NH_AutoBlockSolo
        if not solo or type(solo.GetTargetChar) ~= "function" then return false end
        local target = solo.GetTargetChar()
        return target ~= nil and character == target
    end

    -- P12 block eligibility: restore the reference's ragdoll-based behavior without
    -- letting a missing Ragdoll attribute disable defense. Hard CC/death still win;
    -- a generic Stun marker alone no longer rejects every block attempt.
    getgenv().blockState.canBlock = function(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or hum.PlatformStand or hum.Sit then return false end
        local ragdoll = char:GetAttribute("Ragdoll")
        if ragdoll == true or (tonumber(ragdoll) or 0) > 0 then return false end
        local info = char:FindFirstChild("Info")
        if info and (info:FindFirstChild("Knockback") or info:FindFirstChild("Grabbed")
            or info:FindFirstChild("Grab") or info:FindFirstChild("Carry") or info:FindFirstChild("Hold")) then return false end
        local state = hum:GetState()
        return state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Physics
            and state ~= Enum.HumanoidStateType.Ragdoll and state ~= Enum.HumanoidStateType.FallingDown
    end

    getgenv().blockState.meleeEligible = function(attacker, myHRP, theirHRP)
        if not myHRP or not theirHRP or not _G.NH_IsSoloBlockTarget(attacker) then return false end
        local hum = attacker and attacker:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return false end
        if (theirHRP.Position - myHRP.Position).Magnitude > Config.MeleeRange then return false end
        local toMe = (myHRP.Position - theirHRP.Position) * Vector3.new(1, 0, 1)
        local look = theirHRP.CFrame.LookVector * Vector3.new(1, 0, 1)
        -- Overlapping roots have no meaningful front/back direction.
        return toMe.Magnitude <= 0.1 or look.Magnitude <= 0.1 or look.Unit:Dot(toMe.Unit) >= 0
    end

    local M1_ANIMS = {
        ["rbxassetid://95295463826732"] = true,
        ["rbxassetid://105077924973072"] = true,
        ["rbxassetid://124862357369335"] = true,
        ["rbxassetid://81630213087988"] = true,
    }
    -- P13 smart M1 block state. ONE local; helpers are fields (see SMART M1 BLOCK ENGINE).
    local MB = {
        ids = {}, hooked = setmetatable({}, { __mode = "k" }),
        threats = setmetatable({}, { __mode = "k" }), chain = setmetatable({}, { __mode = "k" }),
        untilT = 0, target = nil, root = nil,
        rtt = 0.2, eff = 0.2, samples = 0, sendAt = 0, firstSendAt = 0, sends = 0, confirmed = false,
        Acquire = 7.5, MaxRaw = 9.5, Keep = 11, Vertical = 6.5, Overlap = 2.6,
        FaceNear = -0.15, FaceFar = 0.35, FaceKeep = -0.45, ComboWindow = 0.95,
    }
    for id in pairs(M1_ANIMS) do MB.ids[id:match("%d+$")] = { ender = false } end

    local function startBlock()
        if St.bfChainActive then return end
        if getgenv().userIsBlocking then return end
        if os.clock() < (St.counterGuardUntil or 0) or not getgenv().blockState.canBlock(player.Character) then return end
        if getgenv().blockState.active then return end
        if getgenv().blockState.cooldown > 0 then return end
        MB.send(nil)
    end

    local function forceStartBlock()
        if St.bfChainActive then return end
        if getgenv().userIsBlocking then return end
        -- Re-assert Activated for a new verified swing, as in the working reference.
        if os.clock() < (St.counterGuardUntil or 0) or not getgenv().blockState.canBlock(player.Character) then return end
        getgenv().blockState.cooldown = 0
        MB.send(nil)
    end

    local function forceStopBlock(keepThreats)
        getgenv().blockState.holdFrames = 0
        getgenv().blockState.holdTarget = nil
        -- External callers (punish, counter, toggles) spend live swings so the lease
        -- cannot re-grab the guard; the idle heartbeat path keeps pending ones.
        if not keepThreats and MB.spend then MB.spend() end
        if not getgenv().blockState.active then return end
        getgenv().blockState.active = false
        MB.confirmed, MB.sends = false, 0
        getgenv().blockState.cooldown = 6
        if not getgenv().userIsBlocking then pcall(function() BlockDeactivated:FireServer() end) end
    end
    _G.NH_forceStopBlock = forceStopBlock

    -- Rotation-write safety gate. Snapping/steering the root CFrame while the
    -- humanoid is airborne, landing, seated, climbing or ragdolling trips the
    -- physics into FallingDown (the "I randomly fall over with autoblock on" bug).
    -- Only grounded locomotion states are safe to rotate in.
    local function canSafelyRotate(hum)
        if not St.Face.canRotate(hum) then return false end
        local s = hum:GetState()
        return s == Enum.HumanoidStateType.Running
            or s == Enum.HumanoidStateType.RunningNoPhysics
    end

    local function faceTarget(theirHRP)
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not canSafelyRotate(char:FindFirstChildOfClass("Humanoid")) then return end
        if not St.Face.claim("defense", 0.14) then return end
        local dir = (theirHRP.Position - hrp.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude < 0.1 then return end
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir.Unit)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end

    -- SMART SMOOTH FACING: instead of a hard snap every 0.25s (which reads as constant
    -- twitching between nearby fighters), we ease the body toward the attacker over a
    -- short window and only ever for someone inside FaceRadius who is actually a
    -- threat. The aim cone scales with distance: wide up close, tight at the rim, so a
    -- duel across the room never yanks our view.
    getgenv().blockState.faceUntil = 0
    getgenv().blockState.faceTurnUntil = 0
    getgenv().blockState.faceFromLook = nil
    getgenv().blockState.faceToLook = nil

    -- The actual turn runs on Heartbeat so it stays smooth and self-limits; it
    -- releases the moment the ease completes so nothing keeps writing rotation.
    -- Wrapped in do/end so `conn` is a block-local that frees its main-chunk slot
    -- once the block closes (the connection itself stays alive via the event and
    -- the blockState field).
    do
        local conn
        conn = RunService.Heartbeat:Connect(function()
            local st = getgenv().blockState
            local now = os.clock()
            if now >= st.faceTurnUntil then
                if st.faceToLook then
                    st.faceToLook = nil; st.faceFromLook = nil
                    St.Face.release("defense")
                    St.Face.restore(player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
                end
                return
            end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not canSafelyRotate(char:FindFirstChildOfClass("Humanoid")) then return end
            local from, to = st.faceFromLook, st.faceToLook
            if not from or not to or not St.Face.claim("defense", 0.05) then return end
            char:FindFirstChildOfClass("Humanoid").AutoRotate = false
            -- Remaining time -> ease-out alpha (same cubic as flash step).
            local remaining = math.max(st.faceTurnUntil - now, 0)
            local span = 0.14
            local alpha = math.clamp(1 - (remaining / span), 0, 1)
            local eased = 1 - (1 - alpha) ^ 3
            local look = from:Lerp(to, eased)
            if look.Magnitude > 0.1 then
                hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look.Unit)
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        getgenv().blockState.faceTurnConn = conn
    end

    getgenv().blockState.maybeFace = function(theirHRP, myHRP)
        if not theirHRP or not myHRP then return end
        local toMe = (myHRP.Position - theirHRP.Position) * Vector3.new(1, 0, 1)
        local dist = toMe.Magnitude
        if dist < 0.1 then return end
        -- RADIUS CAP: never react to anyone beyond FaceRadius. This is what stops the
        -- "spins to look at every player on the map" behaviour -- detection is still
        -- server-wide, but our body only answers a threat that is actually on top of us.
        if dist > Config.FaceRadius then return end
        -- DISTANCE-SCALED AIM CONE: up close, accept a wide arc (they can still hit
        -- us from an angle); near the rim, demand they be genuinely aimed at us.
        local t = math.clamp(dist / Config.FaceRadius, 0, 1)
        local aimDot = Config.FaceAimConeNear + (Config.FaceAimConeFar - Config.FaceAimConeNear) * t
        if theirHRP.CFrame.LookVector:Dot(toMe.Unit) < aimDot then return end
        local now = os.clock()
        if now < getgenv().blockState.faceUntil then return end
        getgenv().blockState.faceUntil = now + 0.25
        -- Start the smooth ease (inlined: no extra main-chunk local for a helper).
        local dir = (theirHRP.Position - myHRP.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0.1 then
            local targetLook = dir.Unit
            local currentLook = (myHRP.CFrame.LookVector * Vector3.new(1, 0, 1))
            if currentLook.Magnitude < 0.1 then currentLook = targetLook end
            currentLook = currentLook.Unit
            getgenv().blockState.faceFromLook = currentLook
            getgenv().blockState.faceToLook = targetLook
            getgenv().blockState.faceTurnUntil = now + 0.14
        end
    end

    -- ── Auto Haruta Dodge ────────────────────────────────────────────────────
    -- In JJS, swordless Haruta's "dodge" IS the Block input pressed at the perfect
    -- moment (the white-circle window). So the dodge is just a precisely-timed Block
    -- tap on the same BlockService remote we already use. We fire a short tap
    -- (Activated -> Deactivated) so it reads as a quick dodge press and does not
    -- linger as a held block. Independent of the auto-block state machine.
    local harutadodgdb = 0
    local function fireHarutaDodge()
        pcall(function() BlockActivated:FireServer() end)
        task.delay(0.16, function()
            -- only release if the normal auto-block isn't actively holding a block,
            -- so we never cancel a real block mid-hold.
            if not getgenv().blockState.active then
                pcall(function() BlockDeactivated:FireServer() end)
            end
        end)
    end

    local lastAutoM1 = 0
    local function triggerM1()
        lastAutoM1 = os.clock()
        -- This game has NO AttackService/CombatService, so AttackActivated was always
        -- nil and the synthetic-mouse fallback ALWAYS ran -- flipping LastInputType off
        -- Touch and killing the mobile joystick. M1 is really the moveset's own remote:
        -- <Moveset>Service.RE.Activated:FireServer(movesetInstance)  (no arg2 = plain M1).
        local ch = player.Character
        local mvName = ch and ch:GetAttribute("Moveset")
        local container = ch and ch:FindFirstChild("Moveset")
        local mi = container and ((mvName and container:FindFirstChild(mvName)) or container:GetChildren()[1])
        local re = nil
        if mvName then
            local ok, r = pcall(function() return Knit.Services[(mvName:gsub("%s", "")) .. "Service"].RE.Activated end)
            re = ok and r or nil
        end
        if re and mi then
            pcall(function() re:FireServer(mi) end)
        elseif AttackActivated then
            AttackActivated:FireServer()
        else
            local cam = workspace.CurrentCamera
            local x, y = 0, 0
            if cam then
                x, y = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
            end
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            -- last-resort synthetic mouse: restore touch controls right after.
            if mobile and restoreTouchControls then restoreTouchControls() end
        end
    end

    local lastCounterTime = 0
    local ping = 0
    local countingDown = false
    local DashBackend = nil

    RunService.Heartbeat:Connect(function()
        if not St.autoBlockEnabled and not St.autoPunishEnabled
            and not St.autoProjBlockEnabled and not St.autoCounterEnabled then return end
        pcall(function() ping = math.clamp(player:GetNetworkPing(), 0, 0.5) end)
    end)

    local function attemptCounter(theirHRP, context)
        if not St.autoPunishEnabled then return end
        if not Config.CounterEnabled then return end
        if countingDown then return end
        local now = os.clock()
        if now - lastCounterTime < Config.CounterCooldown then return end

        local myChar = player.Character
        if not myChar or myChar:GetAttribute("Ragdoll") ~= 0 then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        if not theirHRP or not theirHRP.Parent then return end
        if not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then return end
        if (theirHRP.Position - myHRP.Position).Magnitude > 14 then return end

        countingDown = true
        lastCounterTime = now

        -- GATE: wait for the block to actually SUCCEED before committing the punish.
        -- The enemy's swing is detected at animation-start, but the hit lands ~100ms
        -- later; only then does the server confirm our block via BlockService.RE.Effects
        -- (verified live in a VIP server -- a clean unblocked hit fires nothing). We
        -- poll until a confirmed block arrives or the window expires, so the punish is
        -- a true block->punish and never a detect->gamble.
        local deadline = os.clock() + Config.BlockSuccessWindow
        while os.clock() < deadline do
            if os.clock() - getgenv().blockState.lastSuccessfulBlock <= 0.50 then break end
            if not St.autoPunishEnabled then countingDown = false return end
            if not theirHRP or not theirHRP.Parent or not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then countingDown = false return end
            RunService.Heartbeat:Wait()
        end
        if os.clock() - getgenv().blockState.lastSuccessfulBlock > 0.50 then countingDown = false return end
        if not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then countingDown = false return end

        local adjustedDelay = math.clamp(Config.CounterDelay + (ping * 0.15), 0.06, 0.22)
        task.wait(adjustedDelay)

        if not St.autoPunishEnabled then countingDown = false return end
        if not theirHRP or not theirHRP.Parent or not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then countingDown = false return end
        if type(context) == "table" and type(context.IsValid) == "function" then
            local okContext, contextValid = pcall(context.IsValid)
            if not okContext or not contextValid then countingDown = false return end
        end
        myChar = player.Character
        if not myChar or myChar:GetAttribute("Ragdoll") ~= 0 then countingDown = false return end
        myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then countingDown = false return end
        if not theirHRP or not theirHRP.Parent then countingDown = false return end
        if (theirHRP.Position - myHRP.Position).Magnitude > 14 then countingDown = false return end

        faceTarget(theirHRP)
        local releaseDashBlock = type(context) == "table" and context.ReleaseBlock or nil
        if type(releaseDashBlock) ~= "function" and DashBackend then
            releaseDashBlock = DashBackend.ReleaseForPunish
        end
        if type(releaseDashBlock) == "function" then
            pcall(releaseDashBlock, theirHRP)
        end
        forceStopBlock()
        task.wait(0.03)

        if not St.autoPunishEnabled then countingDown = false return end
        myChar = player.Character
        if not myChar or myChar:GetAttribute("Ragdoll") ~= 0 then countingDown = false return end
        myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then countingDown = false return end
        if not theirHRP or not theirHRP.Parent then countingDown = false return end
        if not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then countingDown = false return end
        if (theirHRP.Position - myHRP.Position).Magnitude > 14 then countingDown = false return end

        faceTarget(theirHRP)
        triggerM1()

        countingDown = false
    end

    local function requestAutoPunish(theirHRP, context)
        if not St.autoPunishEnabled then return false, "disabled" end
        if not Config.CounterEnabled then return false, "disabled" end
        if countingDown then return false, "busy" end

        local requestTime = os.clock()
        if requestTime - lastCounterTime < Config.CounterCooldown then
            return false, "cooldown"
        end
        if typeof(theirHRP) ~= "Instance" or not theirHRP.Parent then
            return false, "invalid target"
        end
        if not _G.NH_IsSoloBlockTarget(theirHRP.Parent) then return false, "not the solo target" end

        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or (theirHRP.Position - myHRP.Position).Magnitude > 14 then
            return false, "out of range"
        end

        task.spawn(attemptCounter, theirHRP, context)
        return true, "accepted"
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.F then
            getgenv().userIsBlocking = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.F then
            getgenv().userIsBlocking = false
        end
    end)

    -- ============================================================
    -- SMART M1 BLOCK ENGINE (P13). Every helper is a field on the single MB
    -- local declared beside M1_ANIMS, so the main chunk stays under 200 locals.
    --  * Detection: instant Animator.AnimationPlayed hook on every character,
    --    with the Swing effect + 30Hz scan as backups. M1 IDs are harvested from
    --    every moveset in ReplicatedStorage.Animations (not 4 hardcoded IDs).
    --  * Timing: measured Activated->Info.Block RTT (GetNetworkPing x2 fallback).
    --    Holds are time leases, never frame counts, so 144/240 FPS can't cut them.
    --  * Combos: non-enders keep the guard up through the next swing's gap, so a
    --    chained M1 string is pre-blocked; enders (Melee4/Up/Down/4th hit) drop.
    --  * Geometry: horizontal reach judged now AND at predicted impact (moving
    --    fights), facing gate with hysteresis -- never block from behind them.
    --  * Network: Activated carries the attacker as Target (native shape) and is
    --    re-sent until the server confirms; a late Activated after release is undone.
    -- ============================================================
    function MB.digits(id)
        return type(id) == "string" and id:match("(%d+)%D*$") or nil
    end
    function MB.register(anim)
        if not anim:IsA("Animation") then return end
        local name = anim.Name
        local isMelee = name:match("^Melee%d") ~= nil
        local isDir = (name == "Up" or name == "Down") and anim.Parent ~= nil
            and anim.Parent.Name:lower():find("melee") ~= nil
        if not isMelee and not isDir then return end
        if name:lower():find("frame") or anim:GetFullName():lower():find("victim") then return end
        local d = MB.digits(anim.AnimationId)
        if not d then return end
        local ender = isDir or name:match("^Melee4") ~= nil
        local entry = MB.ids[d]
        -- Shared IDs (e.g. Gojo Melee1 == Melee4) only count as enders if every use is.
        if entry then entry.ender = entry.ender and ender else MB.ids[d] = { ender = ender } end
        M1_ANIMS["rbxassetid://" .. d] = true
    end
    function MB.ping()
        local net = 0.2
        pcall(function() net = player:GetNetworkPing() * 2 end)
        MB.eff = math.clamp(MB.samples > 0 and math.max(MB.rtt, net * 0.75) or net, 0.04, 0.9)
        return MB.eff
    end
    function MB.blockInfo()
        local c = player.Character
        local info = c and c:FindFirstChild("Info")
        return info and info:FindFirstChild("Block")
    end
    -- Idempotent: first call fires, later calls only re-send while unconfirmed.
    function MB.send(target)
        local bs = getgenv().blockState
        if St.bfChainActive or getgenv().userIsBlocking or os.clock() < (St.counterGuardUntil or 0)
            or not bs.canBlock(player.Character) then return end
        local now = os.clock()
        if bs.active then
            if MB.confirmed or MB.sends >= 8 or now - MB.sendAt < 0.06 then return end
            if MB.blockInfo() then MB.confirmed = true return end
        else
            MB.sends, MB.confirmed, MB.firstSendAt = 0, false, now
        end
        MB.sends += 1
        MB.sendAt = now
        bs.cooldown = 0
        bs.active = pcall(function() BlockActivated:FireServer(target) end) or bs.active
    end
    function MB.spend()
        for _, th in pairs(MB.threats) do th.spent = true end
        MB.untilT, MB.target, MB.root = 0, nil, nil
    end
    function MB.snap(root, myHRP)
        local hum = myHRP.Parent and myHRP.Parent:FindFirstChildOfClass("Humanoid")
        if not canSafelyRotate(hum) or not St.Face.claim("defense", 0.12) then return end
        local dir = (root.Position - myHRP.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude < 0.5 then return end
        hum.AutoRotate = false
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, myHRP.Position + dir.Unit)
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end
    -- Keep the guard pointed at a circling attacker while we move.
    function MB.track(myHRP, dt)
        local root = MB.root
        local hum = myHRP.Parent and myHRP.Parent:FindFirstChildOfClass("Humanoid")
        if not root or not root.Parent or not canSafelyRotate(hum) or not St.Face.claim("defense", 0.06) then return end
        local dir = (root.Position - myHRP.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude < 0.5 then return end
        hum.AutoRotate = false
        local goal = CFrame.lookAt(myHRP.Position, myHRP.Position + dir.Unit)
        myHRP.CFrame = myHRP.CFrame:Lerp(goal, 1 - math.exp(-30 * math.clamp(dt or 1/60, 0, 0.1)))
    end
    function MB.eligible(th, myHRP, holding, now)
        local hum = th.char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 or not _G.NH_IsSoloBlockTarget(th.char) then return false end
        local rel = myHRP.Position - th.root.Position
        if math.abs(rel.Y) > MB.Vertical then return false end
        local flat = rel * Vector3.new(1, 0, 1)
        local dist = flat.Magnitude
        if dist <= MB.Overlap then return true end
        local lead = math.clamp(th.hitAt - now + MB.eff * 0.5, 0, 0.35)
        local vel = (myHRP.AssemblyLinearVelocity - th.root.AssemblyLinearVelocity) * Vector3.new(1, 0, 1)
        local reach = math.min(dist, (flat + vel * lead).Magnitude)
        if reach > (holding and MB.Keep or MB.Acquire) or (not holding and dist > MB.MaxRaw) then return false end
        local look = th.root.CFrame.LookVector * Vector3.new(1, 0, 1)
        if look.Magnitude < 0.1 then return true end
        local need = holding and MB.FaceKeep or MB.FaceNear + (MB.FaceFar - MB.FaceNear)
            * math.clamp((reach - MB.Overlap) / (MB.Acquire - MB.Overlap), 0, 1)
        return look.Unit:Dot(flat.Unit) >= need
    end
    -- Re-evaluates every live swing; returns true while an M1 lease is held.
    function MB.step(myHRP, now)
        now = now or os.clock()
        local best, bestT = nil, 0
        for char, th in pairs(MB.threats) do
            if now > th.chainUntil or not char.Parent or not th.root.Parent then
                MB.threats[char] = nil
            elseif not th.spent then
                local holding = char == MB.target and now < MB.untilT
                if (holding or now < th.hitAt + 0.04) and MB.eligible(th, myHRP, holding, now) then
                    if not th.offered then
                        th.offered = true
                        if St.DefenseBus.offer(th.key, "m1", th.root, char, 0) then th.spent = true end
                    end
                    local t = th.ender and th.releaseAt or th.chainUntil
                    if not th.spent and t > bestT then best, bestT = th, t end
                end
            end
        end
        if not best or not (St.autoBlockEnabled or St.autoPunishEnabled) then
            MB.untilT, MB.target, MB.root = 0, nil, nil
            return false
        end
        local fresh = MB.target ~= best.char or now >= MB.untilT
        MB.target, MB.root, MB.untilT = best.char, best.root, bestT
        getgenv().blockState.holdTarget = best.char
        if fresh then
            MB.snap(best.root, myHRP)
            MB.send(best.char)
        end
        if St.autoPunishEnabled and not best.punished then
            best.punished = true
            task.spawn(attemptCounter, best.root)
        end
        return true
    end
    function MB.add(char, track, d, fromScan)
        if not (St.autoBlockEnabled or St.autoPunishEnabled or St.autoCounterEnabled) then return end
        if typeof(char) ~= "Instance" or char == player.Character or not char.Parent then return end
        if St.bfChainActive or os.clock() < (St.counterGuardUntil or 0) then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not root or not myHRP or not getgenv().blockState.canBlock(myChar)
            or not _G.NH_IsSoloBlockTarget(char) then return end
        if (root.Position - myHRP.Position).Magnitude > Config.AutoBlockScanRange then return end
        local now = os.clock()
        local old = MB.threats[char]
        if old and (now - old.seenAt < 0.15
            or (fromScan and old.track == track and now - old.seenAt < old.len * 0.85)) then return end
        local len = (track and track.Length > 0) and track.Length or 0.33
        local tp = track and math.clamp(track.TimePosition, 0, len) or 0
        local rtt = MB.ping()
        local ch = MB.chain[char]
        if not ch or now - ch.at > MB.ComboWindow then ch = { n = 0 }; MB.chain[char] = ch end
        ch.n += 1
        ch.at = now
        local info = d and MB.ids[d]
        local th = { char = char, root = root, track = track, len = len, seenAt = now, key = {},
            ender = (info and info.ender) or ch.n >= 4,
            hitAt = now + math.clamp(len - tp, 0.08, 0.6) }
        -- The strike resolves server-side near (seen - downlink + remaining windup);
        -- releasing at seen + remaining + jitter keeps Deactivated behind it.
        th.releaseAt = math.max(th.hitAt + 0.07 + rtt * 0.35, now + 0.16 + rtt * 0.5)
        th.chainUntil = th.ender and th.releaseAt or th.releaseAt + 0.30 + rtt * 0.5
        MB.threats[char] = th
        MB.step(myHRP, now)
    end
    function MB.hook(char)
        if typeof(char) ~= "Instance" or not char:IsA("Model") or MB.hooked[char] then return end
        MB.hooked[char] = true
        task.spawn(function()
            local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 6)
            local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 4))
            if not animator or char == player.Character then return end
            animator.AnimationPlayed:Connect(function(track)
                if not (St.autoBlockEnabled or St.autoPunishEnabled or St.autoCounterEnabled) then return end
                local d = track and track.Animation and MB.digits(track.Animation.AnimationId)
                if d and MB.ids[d] then MB.add(char, track, d, false) end
            end)
        end)
    end
    function MB.hookSelf(char)
        task.spawn(function()
            local info = char and char:WaitForChild("Info", 10)
            if not info then return end
            info.ChildAdded:Connect(function(c)
                if c.Name ~= "Block" then return end
                local now, bs = os.clock(), getgenv().blockState
                if bs.active then
                    MB.confirmed = true
                    local s = now - MB.firstSendAt
                    if MB.firstSendAt > 0 and s > 0.02 and s < 1.5 then
                        MB.rtt = MB.samples > 0 and MB.rtt + (s - MB.rtt) * 0.25 or s
                        MB.samples += 1
                    end
                    MB.firstSendAt = 0
                elseif not getgenv().userIsBlocking and now - MB.sendAt < MB.eff * 1.5 + 0.2 then
                    -- Unreliable Activated overtook our reliable Deactivated: undo it.
                    pcall(function() BlockDeactivated:FireServer() end)
                end
            end)
        end)
    end
    -- Native Block InputAction (rebinds, gamepad) counts as a manual guard too.
    function MB.hookManual()
        for _, base in ipairs({ player, rs }) do
            for _, a in ipairs(base:GetDescendants()) do
                if a.Name == "Block" and a.ClassName == "InputAction" and not MB.hooked[a] then
                    MB.hooked[a] = true
                    pcall(function()
                        a.Pressed:Connect(function() getgenv().userIsBlocking = true end)
                        a.Released:Connect(function() getgenv().userIsBlocking = false end)
                    end)
                end
            end
        end
    end
    task.spawn(function()
        local anims = rs:WaitForChild("Animations", 15)
        if anims then
            for _, a in ipairs(anims:GetDescendants()) do MB.register(a) end
            anims.DescendantAdded:Connect(MB.register)
        end
        task.wait(2)
        pcall(MB.hookManual)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            if p.Character then MB.hook(p.Character) end
            p.CharacterAdded:Connect(MB.hook)
        end
    end
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(MB.hook) end)
    task.spawn(function()
        local chars = workspace:WaitForChild("Characters", 15)
        if not chars then return end
        for _, c in ipairs(chars:GetChildren()) do MB.hook(c) end
        chars.ChildAdded:Connect(MB.hook)
    end)
    if player.Character then MB.hookSelf(player.Character) end
    player.CharacterAdded:Connect(function(c)
        MB.hookSelf(c)
        task.delay(3, function() pcall(MB.hookManual) end)
    end)

    local attackerDebounce = setmetatable({}, { __mode = "k" })

    -- Swing effect backup: same engine as the instant AnimationPlayed hook.
    local function onM1(attacker)
        if not St.autoBlockEnabled and not St.autoPunishEnabled and not St.autoCounterEnabled then return end
        if typeof(attacker) ~= "Instance" or not attacker:IsA("Model") or attacker == player.Character then return end
        MB.hook(attacker)
        MB.add(attacker, nil, nil, false)
    end

    -- P12 projectile state: all estimates expire, all geometry uses relative motion.
    -- Only live incoming threats may steer facing; the post-impact block tail never does.
    local PB = {
        parts = {}, rays = {}, rayDebounce = setmetatable({}, { __mode = "k" }),
        character = player.Character, threatUntil = 0, facePosition = nil,
        faceTarget = nil, source = nil, assumedSpeed = 150, hitRadius = 4.5,
        maxParts = 128, maxRays = 64, maxAge = 6, maxDistance = 320,
    }

    function PB.enabled()
        return St.autoBlockEnabled or St.autoPunishEnabled or St.autoProjBlockEnabled or St.autoCounterEnabled
    end
    function PB.canHold()
        return St.autoBlockEnabled or St.autoPunishEnabled or St.autoProjBlockEnabled
    end
    function PB.reset()
        table.clear(PB.parts); table.clear(PB.rays); table.clear(PB.rayDebounce)
        PB.threatUntil, PB.facePosition, PB.faceTarget, PB.source = 0, nil, nil, nil
        getgenv().blockState.projectileSourceChar = nil
    end
    function PB.syncCharacter()
        if PB.character ~= player.Character then
            PB.reset()
            PB.character = player.Character
        end
    end
    function PB.count(t)
        local n = 0
        for _ in pairs(t) do n += 1 end
        return n
    end
    function PB.eligible(source)
        if source == player.Character and source ~= nil then return false end
        if source and not source.Parent then return false end
        return not St.autoBlockSoloEnabled or (source ~= nil and _G.NH_IsSoloBlockTarget(source))
    end
    function PB.radius(size, relativeSpeed)
        local extra = typeof(size) == "Vector3" and math.clamp((size.Magnitude - 3) * 0.25, 0, 3) or 0
        return PB.hitRadius + extra + math.min(relativeSpeed * math.clamp(ping or 0, 0, 0.5), 3)
    end
    function PB.lead(dt)
        return math.clamp(0.12 + math.clamp(ping or 0, 0, 0.5) * 2
            + math.clamp(dt or 1/60, 1/240, 0.1) * 2, 0.15, 0.5)
    end
    function PB.predict(pos, velocity, myPos, myVel, radius)
        if typeof(pos) ~= "Vector3" or typeof(velocity) ~= "Vector3" or typeof(myPos) ~= "Vector3" then return false, 0 end
        myVel = typeof(myVel) == "Vector3" and myVel or Vector3.zero
        local offset, relative = pos - myPos, velocity - myVel
        local speed2 = relative:Dot(relative)
        if speed2 < 1 then return false, 0 end
        local approach = offset:Dot(relative)
        -- Already separating, even if inside the padded corridor: never turn
        -- backward to chase a shot that has passed us.
        if approach >= 0 then return false, 0 end
        radius = radius or PB.radius(nil, math.sqrt(speed2))
        local c = offset:Dot(offset) - radius * radius
        local discriminant = approach * approach - speed2 * c
        if discriminant < 0 then return false, 0 end
        local entry = math.max((-approach - math.sqrt(discriminant)) / speed2, 0)
        local exit = (-approach + math.sqrt(discriminant)) / speed2
        if exit < 0 or entry > 2 then return false, 0 end
        return true, entry
    end
    function PB.addRay(source, cf, range, kind)
        PB.syncCharacter()
        if not PB.enabled() or typeof(source) ~= "Instance" or not source:IsA("Model")
            or not PB.eligible(source) or typeof(cf) ~= "CFrame" then return false end
        local now = os.clock()
        local prior = PB.rayDebounce[source]
        if prior and prior.kind == kind and now < prior.untilT then return false end
        -- A replicated Fire supersedes the estimated cast ray, not vice versa.
        for key, ray in pairs(PB.rays) do
            if now > ray.expires then PB.rays[key] = nil
            elseif ray.source == source then
                if kind == "cast" and ray.kind == "fire" and now - ray.started < 0.12 then return false end
                if ray.kind == "cast" then PB.rays[key] = nil end
            end
        end
        if PB.count(PB.rays) >= PB.maxRays then return false end
        local direction = cf.LookVector
        if direction.Magnitude < 0.01 then return false end
        local key = {}
        PB.rays[key] = {
            source = source, origin = cf.Position, velocity = direction.Unit * PB.assumedSpeed,
            started = now, expires = now + math.clamp(range / PB.assumedSpeed + 0.35, 0.35, 2),
            delay = kind == "cast" and 0.04 or 0, kind = kind, committed = false,
        }
        PB.rayDebounce[source] = { kind = kind, untilT = now + 0.12 }
        return true
    end
    function PB.trackPart(part, source)
        PB.syncCharacter()
        if not PB.enabled() or not PB.eligible(source) or typeof(part) ~= "Instance"
            or not part:IsA("BasePart") or not part.Parent then return false end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or part:IsDescendantOf(char) or (part.Position - root.Position).Magnitude > 220 then return false end
        local now = os.clock()
        -- Bound allocation and remove expired/despawned entries even before Step.
        for p, d in pairs(PB.parts) do
            if not p.Parent or now - d.addedAt > PB.maxAge then PB.parts[p] = nil end
        end
        local data = PB.parts[part]
        local replaceEstimate = not data or (source and not data.source)
        if not data then
            if PB.count(PB.parts) >= PB.maxParts then return false end
            data = { addedAt = now, lastT = now, lastPos = part.Position, velocity = Vector3.zero,
                source = source, committed = false, lastMotion = now }
            PB.parts[part] = data
        elseif source then
            data.source = source
        end
        -- Replace only the nearest launch estimate for a newly observed part;
        -- other shots from the same shooter may still be in flight (barrages).
        if source and replaceEstimate then
            local match, distance = nil, 60
            for key, ray in pairs(PB.rays) do
                if ray.source == source then
                    if ray.kind == "cast" then
                        PB.rays[key] = nil
                    else
                        local pos = ray.origin + ray.velocity * math.max(now - ray.started - ray.delay, 0)
                        local gap = (pos - part.Position).Magnitude
                        if gap < distance then match, distance = key, gap end
                    end
                end
            end
            if match then PB.rays[match] = nil end
        end
        return true
    end
    function PB.velocity(part, data, now)
        local dt = now - data.lastT
        local delta = part.Position - data.lastPos
        local sample = dt > 1e-4 and delta / dt or Vector3.zero
        data.lastPos, data.lastT = part.Position, now
        if delta.Magnitude > 240 or sample.Magnitude > 1200 then
            data.velocity, data.committed = Vector3.zero, false
            return Vector3.zero
        end
        local physical = part.AssemblyLinearVelocity
        if not part.Anchored and typeof(physical) == "Vector3" and physical.Magnitude >= 1
            and (sample.Magnitude < 1 or physical.Magnitude > sample.Magnitude * 1.5) then sample = physical end
        if sample.Magnitude >= 1 then
            data.lastMotion = now
            local previous = data.velocity
            if previous.Magnitude < 1 or previous.Unit:Dot(sample.Unit) < 0.35
                or math.abs(sample.Magnitude - previous.Magnitude) > previous.Magnitude * 0.6 then
                data.velocity = sample
            else
                data.velocity = previous:Lerp(sample, 1 - math.exp(-math.max(dt, 1/240) * 55))
            end
        elseif now - data.lastMotion > 0.08 then
            data.velocity = Vector3.zero
        end
        return data.velocity
    end
    function PB.consider(key, data, pos, vel, faceTarget, size, myPos, myVel, dt, best)
        if not PB.eligible(data.source) then data.committed = false; return best end
        local relativeSpeed = (vel - myVel).Magnitude
        local hit, entry = PB.predict(pos, vel, myPos, myVel, PB.radius(size, relativeSpeed))
        local lead = PB.lead(dt)
        if not hit or entry > lead + (data.committed and 0.08 or 0) then
            data.committed = false
            return best
        end
        data.committed = true
        local root = faceTarget or (data.source and data.source:FindFirstChild("HumanoidRootPart"))
        if St.DefenseBus.offer(key, "projectile", root, data.source, entry) or not PB.canHold() then return best end
        if not best or entry < best.entry then
            return { entry = entry, position = pos, target = faceTarget, source = data.source }
        end
        return best
    end
    local function serviceProjectiles(myPos, myVel, dt)
        PB.syncCharacter()
        PB.facePosition, PB.faceTarget, PB.source = nil, nil, nil
        if not PB.enabled() then PB.reset(); return false end
        if not getgenv().blockState.canBlock(player.Character) or St.bfChainActive
            or os.clock() < (St.counterGuardUntil or 0) then
            PB.threatUntil = 0
            return false
        end
        myVel = typeof(myVel) == "Vector3" and myVel or Vector3.zero
        local now, best = os.clock(), nil
        for part, data in pairs(PB.parts) do
            if not part.Parent or now - data.addedAt > PB.maxAge or part:IsDescendantOf(player.Character)
                or not PB.eligible(data.source) or (part.Position - myPos).Magnitude > PB.maxDistance then
                PB.parts[part] = nil
            else
                local vel = PB.velocity(part, data, now)
                best = PB.consider(part, data, part.Position, vel, part, part.Size, myPos, myVel, dt, best)
            end
        end
        for key, ray in pairs(PB.rays) do
            if now > ray.expires or not PB.eligible(ray.source) then
                PB.rays[key] = nil
            else
                local elapsed = math.max(now - ray.started - ray.delay, 0)
                local pos = ray.origin + ray.velocity * elapsed
                best = PB.consider(key, ray, pos, ray.velocity, nil, nil, myPos, myVel, dt, best)
            end
        end
        if not PB.canHold() then PB.threatUntil = 0 end
        if not best then return false end
        PB.facePosition, PB.faceTarget, PB.source = best.position, best.target, best.source
        getgenv().blockState.projectileSourceChar = best.source
        PB.threatUntil = math.max(PB.threatUntil, now + math.clamp(0.12 + (ping or 0), 0.12, 0.3))
        if not getgenv().blockState.active then forceStartBlock() end
        return true
    end

    -- ── PROJECTILE CAST ANIMATION DETECTION ──────────────────────────────────
    -- Live MCP trace confirmed Hakari's 7 anim IDs (UV9 table in KnitStart).
    -- MeiMei controller is bytecode-protected so we use service-name detection instead.
    --
    -- Core idea: detect the CAST ANIMATION on the attacker the moment they start
    -- the move, before the projectile even leaves their hand. Range-check is on the
    -- ATTACKER's distance (not the projectile's) so we never block someone firing
    -- across the map at someone else. The block fires at animation-start speed —
    -- same frame as AnimationPlayed fires on the Animator — matching the exact
    -- latency of the existing M1 autoblock which also runs on AnimationPlayed.
    --
    -- Per-move range table (studs): how far out each kit's projectile actually reaches.
    -- Attacker must be within this range for us to bother blocking.
    -- Tighter than Config.ProjectileRange (100) because short-range moves (snap, bird)
    -- don't need 100 studs of detection — that was causing false blocks.
    local PROJ_CAST_RANGES = {
        -- Hakari — Reserve Ball (snap): detection range bumped 55 -> 70 studs.
        ["rbxassetid://17207807777"] = 70,  -- Hakari cast 1
        ["rbxassetid://17207806991"] = 70,  -- Hakari cast 2
        ["rbxassetid://17207806413"] = 70,  -- Hakari cast 3
        ["rbxassetid://17207805758"] = 70,  -- Hakari cast 4
        ["rbxassetid://17207805299"] = 70,  -- Hakari cast 5
        ["rbxassetid://17207804676"] = 70,  -- Hakari cast 6
        ["rbxassetid://17207804009"] = 70,  -- Hakari cast 7
    }

    -- Services whose Effects event means a projectile was CAST (not just flying).
    -- On these, we detect the ATTACKER and immediately face+block if in range.
    -- Range is per-service below. These are the "always cast = always dangerous" services.
    local CAST_SERVICES = {
        ReserveBallService    = 70,   -- Hakari ball — travels full map, detect at 70
        BirdControlService    = 65,
        MurmurateService      = 55,
        CirclingService       = 55,
        LapseBlueService      = 75,
        LapseBlueMaxService   = 75,
        HollowPurpleService   = 80,
        KamehamehaService     = 75,
        PiercingBloodService  = 70,
        FlameArrowService     = 60,
        FurnaceArrowService   = 60,
        MiracleCannonService  = 65,
        UltraCannonService    = 70,
        GraniteBlastService   = 55,
        PigeonViolaService    = 60,
        PlasmaWaveService     = 65,
        EnergyRippleService   = 60,
    }

    local function onCastDetected(attackerChar, range)
        if not PB.enabled() or typeof(attackerChar) ~= "Instance" then return end
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local theirHRP = attackerChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not theirHRP or attackerChar == myChar then return end
        if not getgenv().blockState.canBlock(myChar) or not _G.NH_IsSoloBlockTarget(attackerChar) then return end
        if (theirHRP.Position - myHRP.Position).Magnitude > math.min(range, Config.ProjectileRange) then return end
        -- Queue the estimated launch instead of one stale distance/aim decision.
        -- Movement into/out of the path is re-evaluated on every heartbeat.
        PB.addRay(attackerChar, theirHRP.CFrame, range, "cast")
    end

    -- Helper: find the character model that owns a given instance (Part, Player, Model)
    local function resolveChar(arg)
        if typeof(arg) ~= "Instance" then return nil end
        if arg:IsA("Model") and arg:FindFirstChildOfClass("Humanoid") then return arg end
        local anc = arg:FindFirstAncestorOfClass("Model")
        if anc and anc:FindFirstChildOfClass("Humanoid") then return anc end
        if arg:IsA("Player") then return arg.Character end
        local plr = Players:GetPlayerFromCharacter(arg)
        return plr and plr.Character or nil
    end

    local function onProjectileFire(attacker, projCFrame)
        if not PB.enabled() then return end
        attacker = resolveChar(attacker)
        if not attacker or attacker == player.Character then return end
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local theirHRP = attacker:FindFirstChild("HumanoidRootPart")
        if not myHRP or not theirHRP or not getgenv().blockState.canBlock(myChar) then return end
        if not _G.NH_IsSoloBlockTarget(attacker) then return end
        if (theirHRP.Position - myHRP.Position).Magnitude > Config.ProjectileRange then return end
        if PB.addRay(attacker, projCFrame, Config.ProjectileRange, "fire") then
            serviceProjectiles(myHRP.Position, myHRP.AssemblyLinearVelocity, 1/60)
        end
    end

    -- Wire up CAST-SERVICE detection: fires the instant the Effects remote replicates
    -- (= same frame the server processes the move activation, before the projectile spawns).
    for _, svc in ipairs(Knit.Services:GetChildren()) do
        local svcName = svc.Name
        local castRange = CAST_SERVICES[svcName]
        local re = svc:FindFirstChild("RE")
        if re then
            local eff = re:FindFirstChild("Effects")
            if eff and (eff:IsA("RemoteEvent") or eff:IsA("UnreliableRemoteEvent")) then
                pcall(function()
                    eff.OnClientEvent:Connect(function(effectType, arg2, arg3)
                        if not St.autoBlockEnabled and not St.autoPunishEnabled and not St.autoProjBlockEnabled and not St.autoCounterEnabled then return end
                        if type(effectType) ~= "string" then return end

                        -- CAST-SERVICE: any event from a projectile-exclusive service
                        -- = the move just fired, block immediately if attacker in range.
                        if castRange then
                            local attChar = resolveChar(arg2)
                            if attChar and (effectType == "Fire" or effectType == "Cast" or effectType == "Start"
                                or effectType == "Activated" or effectType == "Launch" or effectType == "Shoot"
                                or effectType == "Throw" or effectType == "Release" or effectType == "Projectile") then
                                onCastDetected(attChar, castRange)
                            end
                        end

                        -- GENERIC services: keep existing Fire/Interp/Swing handling
                        if effectType == "Swing" or effectType == "Swing2" then
                            onM1(resolveChar(arg2))
                        elseif effectType == "Fire" then
                            onProjectileFire(arg2, arg3)
                        elseif effectType == "Interp" then
                            if typeof(arg2) == "Instance" and arg2:IsA("BasePart") then
                                PB.trackPart(arg2, resolveChar(arg3))
                            end
                        end
                    end)
                end)
            end
        end
    end

    local animDebounce = setmetatable({}, { __mode = "k" })

    -- PERF: enumerating every enemy's playing animation tracks EVERY FRAME allocates
    -- a fresh table per enemy per frame -- constant GC churn and a top FPS-drop
    -- source. 30Hz is more than enough: M1/cast windows are hundreds of ms long and
    -- ping compensation dominates the timing anyway.
    getgenv().blockState.animScanAccum = 0
    RunService.Heartbeat:Connect(function(dt)
        if not St.autoBlockEnabled and not St.autoPunishEnabled and not St.autoProjBlockEnabled and not St.autoCounterEnabled then return end
        if St.bfChainActive or os.clock() < (St.counterGuardUntil or 0) then return end
        getgenv().blockState.animScanAccum = getgenv().blockState.animScanAccum + (dt or 1/60)
        if getgenv().blockState.animScanAccum < 1/30 then return end
        getgenv().blockState.animScanAccum = 0
        local myChar = player.Character
        if not myChar then return end
        if not getgenv().blockState.canBlock(myChar) then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local enemies = {}
        -- SOLO TARGET: skip the full server-wide enemy rebuild entirely and scan
        -- ONLY the person you locked onto. This is the main lag cut -- with a solo
        -- target we call GetPlayingAnimationTracks() once instead of once per enemy.
        local solo = _G.NH_AutoBlockSolo
        if St.autoBlockSoloEnabled then
            local sChar = solo and solo.GetTargetChar() or nil
            if sChar and sChar ~= myChar then
                table.insert(enemies, sChar)
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then table.insert(enemies, p.Character) end
            end
            local chars = workspace:FindFirstChild("Characters")
            if chars then
                for _, v in ipairs(chars:GetChildren()) do
                    if v:IsA("Model") and v ~= myChar then
                        local dup = false
                        for _, e in ipairs(enemies) do if e == v then dup = true break end end
                        if not dup then table.insert(enemies, v) end
                    end
                end
            end
        end

        for _, enemyChar in ipairs(enemies) do
            local theirHRP = enemyChar:FindFirstChild("HumanoidRootPart")
            local hum = enemyChar:FindFirstChildOfClass("Humanoid")
            if not theirHRP or not hum or hum.Health <= 0 then continue end

            local dist = (theirHRP.Position - myHRP.Position).Magnitude
            -- RANGE CAPS + PERF: never enumerate animation tracks for enemies too
            -- far to matter. Auto Block / Auto Punish are hard-capped at 50 studs;
            -- Auto Projectile Block may reach its full 100-stud cap. Per-move cast
            -- ranges below are all <= this cap, so they still gate on their own.
            local scanCap = 0
            if St.autoBlockEnabled or St.autoPunishEnabled then scanCap = Config.AutoBlockScanRange end
            if St.autoCounterEnabled then scanCap = math.max(scanCap, Config.MeleeRange) end
            if St.autoProjBlockEnabled then scanCap = math.max(scanCap, Config.ProjectileRange) end
            if dist > scanCap then continue end

            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                local id = track.Animation and track.Animation.AnimationId or ""
                local castRange = PROJ_CAST_RANGES[id]

                -- ── CAST ANIMATION DETECTION ──────────────────────────────
                -- If this animation ID is a known projectile cast, trigger
                -- immediately at animation-start. No waiting for the projectile
                -- to travel. Range gate is per-move so a Hakari snap only
                -- triggers when they're within 55 studs, not 80.
                -- Gated on St.autoProjBlockEnabled (independent of autoBlock).
                if castRange and St.autoProjBlockEnabled and dist <= castRange then
                    if track.Length <= 0 then
                        -- do nothing, no valid length
                    else
                        local bucket = animDebounce[enemyChar]
                        if not bucket then bucket = {}; animDebounce[enemyChar] = bucket end
                        local key = id .. "_cast"
                        if not bucket[key] then
                            local token = {}
                            bucket[key] = token
                            task.delay(math.max(track.Length, 0.5), function()
                                if bucket[key] == token then bucket[key] = nil end
                            end)
                            onCastDetected(enemyChar, castRange)
                        end
                    end
                end

                -- ── M1 BACKUP DETECTION -> smart engine (instant hook is primary) ──
                if not St.autoBlockEnabled and not St.autoPunishEnabled and not St.autoCounterEnabled then continue end
                local d = MB.digits(id)
                if d and MB.ids[d] and track.Length > 0 and track.TimePosition < track.Length * 0.85 then
                    MB.hook(enemyChar)
                    MB.add(enemyChar, track, d, true)
                end
            end
        end
    end)

    -- ============================================================
    -- AUTO DASH PREDICT V3 BACKEND (INTEGRATED, NO EXTRA GUI)
    -- ============================================================
    -- This fully replaces the old frame-dependent acceleration scanner. It keeps
    -- the exact verified threat from detection through facing, blocking and the
    -- optional Auto Punish handoff. Automatic code never selects a nearest player.
    local oldStandalone = rawget(getgenv(), "NH_DashBlockTestGUI")
    if type(oldStandalone) == "table" and type(oldStandalone.Destroy) == "function" then
        pcall(oldStandalone.Destroy)
    end

    local DashConfig = {
        MaximumRange = 34,
        SampleRate = 1 / 60,
        DashAnimationWindow = 0.62,
        AnyAnimationWindow = 0.20,
        MovementForceWindow = 0.48,
        KnownAnimationMinimumSpeed = 18,
        ForceMinimumSpeed = 26,
        UnknownAnimationMinimumSpeed = 38,
        VelocityOnlyMinimumSpeed = 55,
        VelocityOnlyHardSpeed = 72,
        VelocityOnlyMinimumAcceleration = 120,
        KnownMinimumClosingSpeed = 9,
        ForceMinimumClosingSpeed = 13,
        UnknownMinimumClosingSpeed = 18,
        VelocityOnlyMinimumClosingSpeed = 25,
        KnownThreatRadius = 7.5,
        ForceThreatRadius = 7.0,
        UnknownThreatRadius = 6.5,
        VelocityThreatRadius = 5.5,
        PredictionHorizon = 0.48,
        VelocityOnlyHorizon = 0.35,
        RearImmediateRange = 9.0,
        RearLandingRadius = 9.5,
        RearForecastTime = 0.16,
        RearMinimumClosingSpeed = -2.5,
        RearDot = -0.06,
        VelocityResponse = 42,
        AccelerationResponse = 18,
        MaximumTrackedSpeed = 360,
        MaximumTrackedAcceleration = 1000,
        TeleportSpeed = 700,
        MaximumFacingLead = 0.14,
        SideDashPostClosestLead = 0.045,
        DirectDashLeadFraction = 0.55,
        -- PASS-BY (side/front dash-through): a fast enemy whose dash line clips past
        -- us without converging on us. Closing speed is ~0 at the closest approach so
        -- the direct cone never fires -- these sailed in unpunished. The near-miss
        -- itself is the threat: they end up point blank, and usually behind us.
        PassByRadiusPadding = 2.8,   -- studs of extra tolerance beyond the source threatRadius
        PassByPingScale = 3.0,       -- per second of ping, widen the pass radius this much
        PassByMaximumRange = 24,     -- only a close pass counts; far ones can't hit us
        -- LEGIT FACING: a human can't spin 2160 deg/s. This caps the turn so the
        -- body reads as a fast flick, not an instant snap, while still completing a
        -- 180 rear turn inside the rear-forecast window.
        FaceLeadPingFraction = 0.55, -- lead the facing turn into our own latency
        FacingLease = 0.30,
        MinimumBlockHold = 0.18,
        PostThreatBlockHold = 0.08,
        MaximumDefenseDuration = 0.60,
        PerThreatCooldown = 0.30,
        NormalTurnResponse = 44,
        ShiftLockTurnResponse = 58,
        MaximumTurnRateDegrees = 1180,
        FacingDeadzoneDegrees = 1.2,
        PunishRange = 14,
        PunishProbeInterval = 0.10,
        ExpectedCounterDelay = 0.14,
        PunishThreatFreshness = 0.20,
        ImpactBlockPadding = 0.12,
    }

    local DashState = {
        Blocking = false,
        ActiveRecord = nil,
        FocusPoint = nil,
        ReferenceLook = nil,
        BlockUntil = 0,
        FaceUntil = 0,
        MaximumDefenseUntil = 0,
        SavedHumanoid = nil,
        SavedAutoRotate = nil,
        FacingBound = false,
        FacingLook = nil,
        FacingShiftLock = false,
        DefenseToken = 0,
        PunishRequested = false,
        PunishEligibleAt = 0,
        LastPunishProbeAt = 0,
        LastConfirmedThreatAt = 0,
        TriggerCount = 0,
        LastSignal = "Auto Dash Predict ready",
        LastThreat = "None",
        LastMetrics = "No confirmed threat",
    }

    local DashRecords = setmetatable({}, { __mode = "k" })
    local DashKnownIds = {
        ["117223862448096"] = "DashLeft",
        ["75203303352791"] = "DashRight",
    }
    local DashConnections = {}
    local DASH_ZERO = Vector3.zero
    local DASH_UP = Vector3.new(0, 1, 0)
    local DASH_BIND_NAME = "NH_AutoDashPredictFacingV3"
    local dashAccumulator = 0

    local function dashKeep(connection)
        if connection then DashConnections[#DashConnections + 1] = connection end
        return connection
    end

    local function dashDisconnect(connection)
        if connection then pcall(function() connection:Disconnect() end) end
    end

    local function dashFlat(vector)
        return Vector3.new(vector.X, 0, vector.Z)
    end

    local function dashExpAlpha(response, dt)
        return 1 - math.exp(-response * math.max(dt, 0))
    end

    local function dashClampMagnitude(vector, maximum)
        local magnitude = vector.Magnitude
        if magnitude > maximum and magnitude > 0 then return vector.Unit * maximum end
        return vector
    end

    local function dashRotateY(vector, radians)
        local cosine = math.cos(radians)
        local sine = math.sin(radians)
        return Vector3.new(
            cosine * vector.X + sine * vector.Z,
            0,
            -sine * vector.X + cosine * vector.Z
        )
    end

    local function dashAnimationId(value)
        return tostring(value or ""):match("%d+")
    end

    local function dashHumanoid(character)
        return character and character:FindFirstChildOfClass("Humanoid") or nil
    end

    local function dashRoot(character)
        if not character then return nil end
        return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    end

    local function dashAlive(character)
        local humanoid = dashHumanoid(character)
        return humanoid ~= nil and humanoid.Health > 0 and dashRoot(character) ~= nil
    end

    local function dashUnavailable(character)
        if not character then return true end
        if character:GetAttribute("Ragdoll") == true or (tonumber(character:GetAttribute("Ragdoll")) or 0) > 0 then return true end
        local info = character:FindFirstChild("Info")
        return info ~= nil and (info:FindFirstChild("Knockback") ~= nil or info:FindFirstChild("Grabbed") ~= nil)
    end

    local function dashPingAllowance()
        local value = 0
        pcall(function() value = player:GetNetworkPing() end)
        return math.clamp((tonumber(value) or 0) * 2, 0, 0.16)
    end

    local function dashForceVelocity(object)
        if not object or not object.Parent then return nil end
        if object:IsA("BodyVelocity") then return dashFlat(object.Velocity) end
        if object:IsA("LinearVelocity") then return dashFlat(object.VectorVelocity) end
        return nil
    end

    local function dashRegisterAnimation(object)
        if not object or not object:IsA("Animation") then return end
        local name = string.lower(object.Name)
        if not string.find(name, "dash", 1, true) and not string.find(name, "chase", 1, true) then return end
        local id = dashAnimationId(object.AnimationId)
        if id then DashKnownIds[id] = object.Name end
    end

    local movementAnimations = nil
    pcall(function()
        movementAnimations = rs:FindFirstChild("Animations") -- front dashes may live outside Misc.Movement
    end)
    if movementAnimations then
        for _, object in ipairs(movementAnimations:GetDescendants()) do dashRegisterAnimation(object) end
        dashKeep(movementAnimations.DescendantAdded:Connect(dashRegisterAnimation))
    end

    local function dashRemoveRecord(character)
        local record = DashRecords[character]
        if not record then return end
        for _, connection in ipairs(record.Connections) do dashDisconnect(connection) end
        DashRecords[character] = nil
        if DashState.ActiveRecord == record then DashState.ActiveRecord = nil end
    end

    local function dashCreateRecord(character)
        if not character or character == player.Character or DashRecords[character] then return end
        local record = {
            Character = character,
            Humanoid = nil,
            Root = nil,
            Connections = {},
            LastPosition = nil,
            LastSampleAt = 0,
            Velocity = DASH_ZERO,
            RawVelocity = DASH_ZERO,
            Acceleration = DASH_ZERO,
            Speed = 0,
            AccelerationMagnitude = 0,
            DashAnimationUntil = 0,
            AnyAnimationUntil = 0,
            ForceUntil = 0,
            ForceObject = nil,
            DashName = "Unknown",
            LastAnimation = "None",
            LastTriggeredAt = 0,
            LastMetrics = nil,
            TeleportUntil = 0,
            LastNonThreatAt = 0,
        }
        DashRecords[character] = record

        task.spawn(function()
            local humanoid = dashHumanoid(character) or character:WaitForChild("Humanoid", 6)
            local root = dashRoot(character) or character:WaitForChild("HumanoidRootPart", 6)
            if DashRecords[character] ~= record or not humanoid or not root or not character.Parent then
                dashRemoveRecord(character)
                return
            end

            record.Humanoid = humanoid
            record.Root = root
            record.LastPosition = root.Position
            record.LastSampleAt = os.clock()
            record.Velocity = dashFlat(root.AssemblyLinearVelocity)

            local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 6)
            if animator and DashRecords[character] == record then
                record.Connections[#record.Connections + 1] = animator.AnimationPlayed:Connect(function(track)
                    if not St.autoDashPredictEnabled or DashRecords[character] ~= record then return end
                    local animation = track.Animation
                    local id = animation and dashAnimationId(animation.AnimationId)
                    local objectName = animation and animation.Name or "Animation"
                    local trackName = track.Name or "Track"
                    local knownName = id and DashKnownIds[id] or nil
                    local names = string.lower(objectName .. " " .. trackName)
                    local namedDash = string.find(names, "dash", 1, true) ~= nil
                        or string.find(names, "chase", 1, true) ~= nil -- server-driven forward Chase
                    local now = os.clock()

                    record.LastAnimation = string.format("%s [%s]", knownName or objectName, id or "no-id")
                    record.AnyAnimationUntil = now + DashConfig.AnyAnimationWindow
                    if knownName or namedDash then
                        record.DashName = knownName or objectName or trackName
                        record.DashTrack = track
                        record.DashAnimationUntil = now + DashConfig.DashAnimationWindow
                        DashState.LastSignal = "Animation: " .. character.Name .. " / " .. record.DashName
                    end
                end)
            end

            record.Connections[#record.Connections + 1] = character.DescendantAdded:Connect(function(object)
                if not St.autoDashPredictEnabled or DashRecords[character] ~= record then return end
                if object.Name ~= "MovementForce" then return end
                if not (object:IsA("BodyVelocity") or object:IsA("LinearVelocity")) then return end
                record.ForceObject = object
                record.ForceUntil = os.clock() + DashConfig.MovementForceWindow
                DashState.LastSignal = "MovementForce: " .. character.Name
            end)

            record.Connections[#record.Connections + 1] = humanoid.Died:Connect(function()
                dashRemoveRecord(character)
            end)
        end)
    end

    local function dashUpdateMotion(record, now)
        local root = record.Root
        if not root or not root.Parent then
            root = dashRoot(record.Character)
            record.Root = root
        end
        if not root then return false end

        if not record.LastPosition then
            record.LastPosition = root.Position
            record.LastSampleAt = now
            return false
        end

        local dt = now - record.LastSampleAt
        if dt <= 0.001 then return true end
        if dt > 0.35 then
            record.LastPosition = root.Position
            record.LastSampleAt = now
            record.Velocity = dashFlat(root.AssemblyLinearVelocity)
            record.Acceleration = DASH_ZERO
            return false
        end

        local position = root.Position
        local positionVelocity = dashFlat(position - record.LastPosition) / dt
        local physicsVelocity = dashFlat(root.AssemblyLinearVelocity)
        local movementVelocity = dashForceVelocity(record.ForceObject)

        if positionVelocity.Magnitude > DashConfig.TeleportSpeed then
            record.TeleportUntil = now + 0.20
            record.LastPosition = position
            record.LastSampleAt = now
            record.Velocity = DASH_ZERO
            record.RawVelocity = DASH_ZERO
            record.Acceleration = DASH_ZERO
            return false
        end

        local positionSpeed = positionVelocity.Magnitude
        local physicsSpeed = physicsVelocity.Magnitude
        local rawVelocity
        if positionSpeed > 1 and physicsSpeed > 1 then
            local alignment = positionVelocity.Unit:Dot(physicsVelocity.Unit)
            rawVelocity = alignment > 0 and positionVelocity:Lerp(physicsVelocity, 0.32) or positionVelocity
        elseif positionSpeed >= physicsSpeed then
            rawVelocity = positionVelocity
        else
            rawVelocity = physicsVelocity
        end

        if movementVelocity and movementVelocity.Magnitude > 1 then
            if rawVelocity.Magnitude < 1 then
                rawVelocity = movementVelocity
            elseif rawVelocity.Unit:Dot(movementVelocity.Unit) > 0.20 then
                rawVelocity = rawVelocity:Lerp(movementVelocity, 0.18)
            end
        end

        rawVelocity = dashClampMagnitude(rawVelocity, DashConfig.MaximumTrackedSpeed)
        local previousVelocity = record.Velocity
        local velocity = previousVelocity:Lerp(
            rawVelocity,
            dashExpAlpha(DashConfig.VelocityResponse, math.min(dt, 0.10))
        )
        local instantAcceleration = dashClampMagnitude(
            (velocity - previousVelocity) / dt,
            DashConfig.MaximumTrackedAcceleration
        )
        local acceleration = record.Acceleration:Lerp(
            instantAcceleration,
            dashExpAlpha(DashConfig.AccelerationResponse, math.min(dt, 0.10))
        )

        record.RawVelocity = rawVelocity
        record.Velocity = velocity
        record.Acceleration = acceleration
        record.Speed = velocity.Magnitude
        record.AccelerationMagnitude = acceleration.Magnitude
        record.LastPosition = position
        record.LastSampleAt = now
        return true
    end

    local function dashEvidence(record, now)
        -- A stopped track/destroyed movement force is the braking phase, not proof
        -- that the verified dash vanished. Keep only the bounded observation lease.
        if now <= record.DashAnimationUntil then
            return "ANIMATION", DashConfig.KnownAnimationMinimumSpeed,
                DashConfig.KnownMinimumClosingSpeed, DashConfig.KnownThreatRadius,
                DashConfig.PredictionHorizon
        end
        if now <= record.ForceUntil then
            return "FORCE", DashConfig.ForceMinimumSpeed,
                DashConfig.ForceMinimumClosingSpeed, DashConfig.ForceThreatRadius,
                DashConfig.PredictionHorizon
        end
        return nil -- never classify ordinary walking or a generic Action as a dash
    end

    local function dashEvaluate(record, myRoot, now, pingAllowance)
        local character = record.Character
        if not dashAlive(character) or dashUnavailable(character) then return nil end
        if now < record.TeleportUntil or not dashUpdateMotion(record, now) then return nil end

        local enemyRoot = record.Root
        local relativePosition = dashFlat(enemyRoot.Position - myRoot.Position)
        local distance = relativePosition.Magnitude
        if distance < 0.05 or distance > DashConfig.MaximumRange then return nil end

        local source, minimumSpeed, minimumClosing, threatRadius, baseHorizon = dashEvidence(record, now)
        if not source then return nil end
        local enemyLook = dashFlat(enemyRoot.CFrame.LookVector)
        local facingUs = enemyLook.Magnitude > 0.01
            and enemyLook.Unit:Dot(-relativePosition.Unit) > 0.35
        -- Forward-dash contact often happens AFTER its speed/track drops to zero.
        local contact = distance <= math.min(threatRadius, 6.5) and facingUs
        if math.max(record.Speed, record.RawVelocity and record.RawVelocity.Magnitude or 0) < minimumSpeed
            and not contact then return nil end

        local enemyVelocity = record.Velocity
        local raw = record.RawVelocity
        if raw and raw.Magnitude > enemyVelocity.Magnitude
            and (enemyVelocity.Magnitude < 1 or raw.Unit:Dot(enemyVelocity.Unit) > 0.7) then
            enemyVelocity = raw -- don't wait for the velocity smoother at dash onset
        end
        local myVelocity = dashFlat(myRoot.AssemblyLinearVelocity)
        local relativeVelocity = enemyVelocity - myVelocity
        local relativeSpeedSquared = relativeVelocity:Dot(relativeVelocity)
        if relativeSpeedSquared < 1 and not contact then return nil end
        relativeSpeedSquared = math.max(relativeSpeedSquared, 1)

        local closingSpeed = -relativePosition.Unit:Dot(relativeVelocity)
        local closestTime = -relativePosition:Dot(relativeVelocity) / relativeSpeedSquared
        local horizon = baseHorizon + pingAllowance
        local clampedClosestTime = math.clamp(closestTime, 0, horizon)
        local missDistance = (relativePosition + relativeVelocity * clampedClosestTime).Magnitude

        local forecastTime = math.min(DashConfig.RearForecastTime + pingAllowance * 0.35, horizon)
        local forecastDelta = enemyVelocity * forecastTime
            + record.Acceleration * (0.5 * forecastTime * forecastTime)
        forecastDelta = dashClampMagnitude(forecastDelta, 18)
        local forecastPoint = enemyRoot.Position + forecastDelta
        local forecastOffset = dashFlat(forecastPoint - myRoot.Position)
        local forecastDistance = forecastOffset.Magnitude

        local myLook = DashState.ReferenceLook or dashFlat(myRoot.CFrame.LookVector)
        if myLook.Magnitude < 0.01 then myLook = Vector3.new(0, 0, -1) end
        myLook = myLook.Unit
        local behindNow = myLook:Dot(relativePosition.Unit) <= DashConfig.RearDot
        local forecastBehind = forecastDistance > 0.05
            and myLook:Dot(forecastOffset.Unit) <= DashConfig.RearDot

        local inWindow = closestTime >= -0.035 and closestTime <= horizon
        local nearMiss = missDistance <= threatRadius + DashConfig.PassByRadiusPadding
            + pingAllowance * DashConfig.PassByPingScale
        -- DIRECT: the dash is converging on us and its line lands inside our hitbox.
        local directThreat = closestTime >= 0 and inWindow and closingSpeed >= minimumClosing
            and missDistance <= threatRadius
        -- PASS-BY: a fast enemy whose dash line clips past us without converging -
        -- side dash, circle strafe, dash-through. Closing speed is ~0 (or negative)
        -- at the closest approach, so the direct cone never fires and the dash sails
        -- in unpunished. The near miss itself is the threat: they end up point blank,
        -- and usually behind us, when the dash ends.
        local passByThreat = closestTime >= 0 and closestTime <= 0.18 + pingAllowance
            and nearMiss and distance <= DashConfig.PassByMaximumRange
            and (facingUs or behindNow or forecastBehind) and closingSpeed > -2.5
        local rearThreat = (behindNow or forecastBehind) and facingUs and closingSpeed > 2
            and missDistance <= 5.0 and closestTime >= 0 and closestTime <= 0.20 + pingAllowance
            and (distance <= 7 or forecastDistance <= 5)

        local reason
        if contact and closingSpeed > -6 then
            reason = "DASH CONTACT"
        elseif rearThreat then
            reason = "DASH BEHIND"
        elseif directThreat then
            reason = "INCOMING DASH"
        elseif passByThreat then
            reason = "SIDE PASS"
        else
            if now - record.LastNonThreatAt > 0.22 then
                record.LastNonThreatAt = now
                DashState.LastSignal = string.format("Ignored %s / %s / miss %.1f", character.Name, source, missDistance)
            end
            return nil
        end

        local dashName = string.lower(tostring(record.DashName or ""))
        local sideDash = reason == "DASH BEHIND"
            or reason == "SIDE PASS"
            or string.find(dashName, "left", 1, true) ~= nil
            or string.find(dashName, "right", 1, true) ~= nil
        -- PING-COMPENSATED LEAD: our input takes ping/2 to reach the server, so face
        -- where the target will be slightly further along their dash than the raw
        -- impact time. Without this we consistently turn to a position the target
        -- already left, and the block eats air on anything above ~80ms.
        local pingLead = pingAllowance * DashConfig.FaceLeadPingFraction
        local facingTime
        if closestTime >= 0 then
            if sideDash then
                facingTime = math.min(closestTime + DashConfig.SideDashPostClosestLead + pingLead,
                    DashConfig.MaximumFacingLead + pingLead)
            else
                facingTime = math.min(
                    math.max(closestTime * DashConfig.DirectDashLeadFraction, 0.02) + pingLead,
                    DashConfig.MaximumFacingLead + pingLead
                )
            end
        else
            facingTime = (sideDash and DashConfig.SideDashPostClosestLead or 0) + pingLead
        end

        local focusPoint = enemyRoot.Position + enemyVelocity * facingTime
        if dashFlat(focusPoint - myRoot.Position).Magnitude < 0.65 then focusPoint = enemyRoot.Position end
        local score = math.max(closestTime, 0) * 100 + missDistance * 4 + distance * 0.20
        if reason == "DASH BEHIND" then score = score - 7 end

        local metrics = {
            Record = record,
            Character = character,
            Reason = reason,
            Source = source,
            Speed = record.Speed,
            ClosingSpeed = closingSpeed,
            ClosestTime = reason == "DASH CONTACT" and 0 or closestTime,
            MissDistance = missDistance,
            Distance = distance,
            FocusPoint = focusPoint,
            Score = score,
        }
        record.LastMetrics = metrics
        return metrics
    end

    local function dashRestoreAutoRotate()
        local humanoid = DashState.SavedHumanoid
        if humanoid and humanoid.Parent and DashState.SavedAutoRotate ~= nil then
            St.Face.release("dash")
            pcall(function() St.Face.restore(humanoid) end)
        end
        DashState.SavedHumanoid = nil
        DashState.SavedAutoRotate = nil
    end

    local function dashStopFacing()
        pcall(function() RunService:UnbindFromRenderStep(DASH_BIND_NAME) end)
        DashState.FacingBound = false
        DashState.FacingLook = nil
        DashState.FacingShiftLock = false
        St.Face.release("dash")
        dashRestoreAutoRotate()
    end

    local function dashReleaseDefense()
        DashState.Blocking = false
        DashState.ActiveRecord = nil
        DashState.FocusPoint = nil
        DashState.ReferenceLook = nil
        DashState.BlockUntil = 0
        DashState.FaceUntil = 0
        DashState.MaximumDefenseUntil = 0
        DashState.PunishRequested = false
        DashState.PunishEligibleAt = 0
        DashState.LastPunishProbeAt = 0
        DashState.LastConfirmedThreatAt = 0
        dashStopFacing()
    end

    local function dashDetectShiftLock(myRoot)
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then return true end
        if not UserInputService.TouchEnabled or not myRoot then return false end
        local camera = workspace.CurrentCamera
        if not camera then return false end
        local cameraLook = dashFlat(camera.CFrame.LookVector)
        local bodyLook = dashFlat(myRoot.CFrame.LookVector)
        if cameraLook.Magnitude < 0.10 or bodyLook.Magnitude < 0.10 then return false end
        return cameraLook.Unit:Dot(bodyLook.Unit) > 0.86
    end

    local function dashSmoothFacing(dt)
        if not DashState.Blocking or os.clock() > DashState.FaceUntil then return end
        local record = DashState.ActiveRecord
        if not record or not record.Character or not record.Character.Parent then return end
        local myCharacter = player.Character
        local humanoid = dashHumanoid(myCharacter)
        local myRoot = dashRoot(myCharacter)
        local threatRoot = dashRoot(record.Character)
        if not humanoid or not myRoot or not threatRoot then return end

        if DashState.SavedHumanoid ~= humanoid then
            dashRestoreAutoRotate()
            DashState.SavedHumanoid = humanoid
            DashState.SavedAutoRotate = humanoid.AutoRotate
        end
        if not St.Face.canRotate(humanoid) or not St.Face.claim("dash", 0.08) then return end
        humanoid.AutoRotate = false

        local point = typeof(DashState.FocusPoint) == "Vector3" and DashState.FocusPoint or threatRoot.Position
        local desired = dashFlat(point - myRoot.Position)
        if desired.Magnitude < 0.10 then desired = dashFlat(threatRoot.Position - myRoot.Position) end
        if desired.Magnitude < 0.10 then return end
        desired = desired.Unit

        local current = DashState.FacingLook
        if not current or current.Magnitude < 0.10 then
            current = dashFlat(myRoot.CFrame.LookVector)
            if current.Magnitude < 0.10 then current = desired end
            current = current.Unit
        end

        local dot = math.clamp(current:Dot(desired), -1, 1)
        local angle = math.atan2(current:Cross(desired).Y, dot)
        local nextLook
        local imminentRear = dot < -0.85 and record.LastMetrics
            and record.LastMetrics.ClosestTime <= 0.12
        if imminentRear or math.abs(angle) <= math.rad(DashConfig.FacingDeadzoneDegrees) then
            nextLook = desired
        else
            local shiftLocked = DashState.FacingShiftLock
            if not UserInputService.TouchEnabled then
                shiftLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
            end
            local response = shiftLocked and DashConfig.ShiftLockTurnResponse or DashConfig.NormalTurnResponse
            local safeDt = math.clamp(dt or DashConfig.SampleRate, 1 / 240, 1 / 20)
            local wantedStep = angle * dashExpAlpha(response, safeDt)
            local maximumStep = math.rad(DashConfig.MaximumTurnRateDegrees) * safeDt
            nextLook = dashRotateY(current, math.clamp(wantedStep, -maximumStep, maximumStep))
            if nextLook.Magnitude < 0.10 then nextLook = desired end
            nextLook = nextLook.Unit
        end

        DashState.FacingLook = nextLook
        -- Never write rotation while airborne/landing (trips the humanoid into a
        -- fall); keep tracking the look so facing resumes smoothly once grounded.
        if canSafelyRotate(humanoid) then
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + nextLook, DASH_UP)
            myRoot.AssemblyAngularVelocity = DASH_ZERO
        end
    end

    local function dashStartFacing()
        if DashState.FacingBound then return end
        pcall(function() RunService:UnbindFromRenderStep(DASH_BIND_NAME) end)
        local ok = pcall(function()
            RunService:BindToRenderStep(DASH_BIND_NAME, Enum.RenderPriority.Last.Value, dashSmoothFacing)
        end)
        DashState.FacingBound = ok
    end

    local function dashReassertFacing()
        local look = DashState.FacingLook
        if not look or look.Magnitude < 0.10 then return end
        local myChar = player.Character
        local myRoot = dashRoot(myChar)
        if not myRoot then return end
        if not canSafelyRotate(dashHumanoid(myChar)) or not St.Face.claim("dash", 0.08) then return end
        myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + look.Unit, DASH_UP)
        myRoot.AssemblyAngularVelocity = DASH_ZERO
    end

    local function dashBeginOrExtend(metrics, now)
        if St.bfChainActive then return end
        local record = metrics.Record
        local newThreat = not DashState.Blocking or DashState.ActiveRecord ~= record
        if newThreat then
            DashState.DefenseToken = DashState.DefenseToken + 1
            DashState.Blocking = true
            DashState.ActiveRecord = record
            DashState.FocusPoint = metrics.FocusPoint
            if not DashState.ReferenceLook then
                local localRoot = dashRoot(player.Character)
                local startingLook = localRoot and dashFlat(localRoot.CFrame.LookVector) or DASH_ZERO
                if startingLook.Magnitude > 0.10 then DashState.ReferenceLook = startingLook.Unit end
            end
            local impactDelay = math.clamp(metrics.ClosestTime or 0, 0, DashConfig.PredictionHorizon)
            DashState.MaximumDefenseUntil = now + DashConfig.MaximumDefenseDuration
            DashState.FaceUntil = now + DashConfig.FacingLease
            DashState.BlockUntil = now + math.max(
                DashConfig.MinimumBlockHold,
                impactDelay + DashConfig.ImpactBlockPadding
            )
            DashState.PunishRequested = false
            DashState.PunishEligibleAt = now + math.max(0, impactDelay - DashConfig.ExpectedCounterDelay)
            DashState.LastPunishProbeAt = 0
            DashState.LastConfirmedThreatAt = now
            DashState.FacingShiftLock = dashDetectShiftLock(dashRoot(player.Character))
            dashStartFacing()
            dashSmoothFacing(DashConfig.SampleRate)
            DashState.TriggerCount = DashState.TriggerCount + 1
        end

        -- Refresh facing for the whole guard, not only its first 0.30 seconds.
        DashState.FaceUntil = math.min(math.max(DashState.FaceUntil,
            now + DashConfig.FacingLease), DashState.MaximumDefenseUntil)
        DashState.BlockUntil = math.min(
            math.max(DashState.BlockUntil, now + DashConfig.PostThreatBlockHold),
            DashState.MaximumDefenseUntil
        )
        DashState.FocusPoint = metrics.FocusPoint
        DashState.LastConfirmedThreatAt = now
        if not DashState.PunishRequested then
            local impactDelay = math.clamp(metrics.ClosestTime or 0, 0, DashConfig.PredictionHorizon)
            DashState.PunishEligibleAt = now + math.max(0, impactDelay - DashConfig.ExpectedCounterDelay)
        end
        DashState.LastSignal = metrics.Source .. ": " .. metrics.Character.Name
        DashState.LastThreat = metrics.Character.Name .. " - " .. metrics.Reason
        DashState.LastMetrics = string.format(
            "%s | %.0f speed | %.2fs | %.1f miss",
            metrics.Source,
            metrics.Speed,
            metrics.ClosestTime,
            metrics.MissDistance
        )
    end

    local function dashUpdateFocus(record, myRoot)
        if not record or not record.Root or not record.Root.Parent then return nil end
        local relativePosition = dashFlat(record.Root.Position - myRoot.Position)
        local relativeVelocity = record.Velocity - dashFlat(myRoot.AssemblyLinearVelocity)
        local speedSquared = relativeVelocity:Dot(relativeVelocity)
        local closestTime = 0
        if relativePosition.Magnitude > 0.05 and speedSquared > 1 then
            closestTime = -relativePosition:Dot(relativeVelocity) / speedSquared
        end
        local dashName = string.lower(tostring(record.DashName or ""))
        local sideDash = string.find(dashName, "left", 1, true) ~= nil
            or string.find(dashName, "right", 1, true) ~= nil
            or (record.LastMetrics and (record.LastMetrics.Reason == "DASH BEHIND"
                or record.LastMetrics.Reason == "SIDE PASS"))
        local lead
        if sideDash then
            lead = math.min(math.max(closestTime, 0) + DashConfig.SideDashPostClosestLead, DashConfig.MaximumFacingLead)
        else
            lead = math.min(math.max(closestTime, 0) * DashConfig.DirectDashLeadFraction, DashConfig.MaximumFacingLead)
        end
        return record.Root.Position + record.Velocity * lead
    end

    local function dashReleaseForPunish(theirHRP)
        if not DashState.Blocking or not DashState.ActiveRecord then return false end
        local activeRoot = dashRoot(DashState.ActiveRecord.Character)
        if not activeRoot then return false end
        if typeof(theirHRP) == "Instance" and theirHRP ~= activeRoot then return false end
        dashReleaseDefense()
        DashState.LastSignal = "Auto Punish handoff"
        return true
    end

    local function dashRequestPunish(record, now)
        if not St.autoPunishEnabled or DashState.PunishRequested or not record then return end
        if now < DashState.PunishEligibleAt then return end
        if now - DashState.LastConfirmedThreatAt > DashConfig.PunishThreatFreshness then return end
        if now - DashState.LastPunishProbeAt < DashConfig.PunishProbeInterval then return end
        DashState.LastPunishProbeAt = now

        local myRoot = dashRoot(player.Character)
        local theirHRP = dashRoot(record.Character)
        if not myRoot or not theirHRP then return end
        if (theirHRP.Position - myRoot.Position).Magnitude > DashConfig.PunishRange then return end

        local token = DashState.DefenseToken
        local accepted = requestAutoPunish(theirHRP, {
            Kind = "DashPredict",
            IsValid = function()
                return St.autoDashPredictEnabled
                    and DashState.Blocking
                    and DashState.DefenseToken == token
                    and DashState.ActiveRecord == record
            end,
            ReleaseBlock = function(targetRoot)
                if DashState.DefenseToken ~= token or DashState.ActiveRecord ~= record then return false end
                return dashReleaseForPunish(targetRoot or theirHRP)
            end,
        })
        if accepted then DashState.PunishRequested = true end
    end

    DashBackend = {}

    function DashBackend.ReleaseForPunish(theirHRP)
        return dashReleaseForPunish(theirHRP)
    end

    function DashBackend.Reset()
        dashReleaseDefense()
    end

    function DashBackend.SetEnabled(value)
        St.autoDashPredictEnabled = value == true
        if not St.autoDashPredictEnabled then
            dashReleaseDefense()
            for _, record in pairs(DashRecords) do
                record.DashAnimationUntil = 0
                record.AnyAnimationUntil = 0
                record.ForceUntil = 0
            end
        else
            local now = os.clock()
            for _, record in pairs(DashRecords) do
                local animator = record.Humanoid and record.Humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        local anim = track.Animation
                        local id = anim and dashAnimationId(anim.AnimationId)
                        local known = id and DashKnownIds[id]
                        local names = string.lower((anim and anim.Name or "") .. " " .. track.Name)
                        if known or string.find(names, "dash", 1, true) or string.find(names, "chase", 1, true) then
                            record.DashName = known or (anim and anim.Name) or track.Name
                            record.DashTrack = track
                            record.DashAnimationUntil = now + math.min(DashConfig.DashAnimationWindow,
                                math.max(0.08, track.Length - track.TimePosition))
                        end
                    end
                end
                for _, object in ipairs(record.Character:GetDescendants()) do
                    if object.Name == "MovementForce" and (object:IsA("BodyVelocity") or object:IsA("LinearVelocity")) then
                        record.ForceObject = object
                        record.ForceUntil = now + DashConfig.MovementForceWindow
                    end
                end
            end
        end
        return St.autoDashPredictEnabled
    end

    function DashBackend.GetState()
        return DashState
    end

    function DashBackend.Step(dt, suppliedRoot)
        if not St.autoDashPredictEnabled then
            if DashState.Blocking or DashState.FacingBound then dashReleaseDefense() end
            return false
        end

        local soloMode = St.autoBlockSoloEnabled == true
        local soloTargetCharacter = nil
        if soloMode then
            local solo = _G.NH_AutoBlockSolo
            if solo and type(solo.GetTargetChar) == "function" then
                soloTargetCharacter = solo.GetTargetChar()
            end
            if (DashState.Blocking or DashState.FacingBound) and (not soloTargetCharacter or not DashState.ActiveRecord
                or DashState.ActiveRecord.Character ~= soloTargetCharacter) then
                dashReleaseDefense()
            end
        end

        dashAccumulator = dashAccumulator + (dt or DashConfig.SampleRate)
        if dashAccumulator < DashConfig.SampleRate then return DashState.Blocking end
        dashAccumulator = 0

        local now = os.clock()
        local myCharacter = player.Character
        local myHumanoid = dashHumanoid(myCharacter)
        local myRoot = suppliedRoot or dashRoot(myCharacter)
        if not myHumanoid or myHumanoid.Health <= 0 or not myRoot
            or (tonumber(myCharacter:GetAttribute("Ragdoll")) or 0) > 0 then
            dashReleaseDefense()
            return false
        end

        local best = nil
        local dead = {}
        local allowance = dashPingAllowance()
        for character, record in pairs(DashRecords) do
            if not character.Parent or not dashAlive(character) then
                dead[#dead + 1] = character
            elseif not soloMode or (soloTargetCharacter and character == soloTargetCharacter) then
                local metrics = dashEvaluate(record, myRoot, now, allowance)
                if metrics then
                    local sameThreat = DashState.ActiveRecord == record
                    local cooledDown = now - record.LastTriggeredAt >= DashConfig.PerThreatCooldown
                    if sameThreat then metrics.Score -= 12 end
                    if (sameThreat or cooledDown) and (not best or metrics.Score < best.Score) then
                        best = metrics
                    end
                end
            end
        end
        for _, character in ipairs(dead) do dashRemoveRecord(character) end

        if best then
            local key = best.Record.CounterKey
            if not key or now - (best.Record.CounterKeyAt or 0) > 0.65 then
                key = {}; best.Record.CounterKey = key; best.Record.CounterKeyAt = now
            end
            St.DefenseBus.offer(key, "dash", best.Record.Root, best.Character, math.max(best.ClosestTime, 0))
            if DashState.ActiveRecord ~= best.Record then best.Record.LastTriggeredAt = now end
            dashBeginOrExtend(best, now)
        end

        if DashState.Blocking then
            local record = DashState.ActiveRecord
            if not record or not record.Character.Parent or not dashAlive(record.Character) then
                dashReleaseDefense()
                return false
            end

            if now <= DashState.FaceUntil then
                local focus = dashUpdateFocus(record, myRoot)
                if focus then DashState.FocusPoint = focus end
                dashStartFacing()
                dashReassertFacing()
            else
                dashStopFacing()
            end

            dashRequestPunish(record, now)
            if now >= DashState.BlockUntil or now >= DashState.MaximumDefenseUntil then
                dashReleaseDefense()
            end
        end

        return DashState.Blocking
    end

    pcall(function() RunService:UnbindFromRenderStep(DASH_BIND_NAME) end)

    local charactersFolder = workspace:FindFirstChild("Characters") or workspace:WaitForChild("Characters", 10)
    if charactersFolder then
        dashKeep(charactersFolder.ChildAdded:Connect(function(character)
            if character:IsA("Model") then dashCreateRecord(character) end
        end))
        dashKeep(charactersFolder.ChildRemoved:Connect(dashRemoveRecord))
        for _, character in ipairs(charactersFolder:GetChildren()) do
            if character:IsA("Model") then dashCreateRecord(character) end
        end
    end

    local function dashHookPlayer(otherPlayer)
        if otherPlayer ~= player and otherPlayer.Character then dashCreateRecord(otherPlayer.Character) end
        dashKeep(otherPlayer.CharacterAdded:Connect(function(character)
            if otherPlayer == player then
                dashReleaseDefense()
            else
                dashCreateRecord(character)
            end
        end))
    end
    for _, otherPlayer in ipairs(Players:GetPlayers()) do dashHookPlayer(otherPlayer) end
    dashKeep(Players.PlayerAdded:Connect(dashHookPlayer))

    _G.NH_AutoDashPredictBackend = DashBackend
    getgenv().NH_AutoDashPredictBackend = DashBackend
    _G.NH_SetAutoDashPredict = function(value)
        return DashBackend.SetEnabled(value)
    end

    -- Shared controller: retain dash leases; reference-style M1 hold and independent
    -- projectile leases. Never rotate toward a projectile during a stale block tail.
    getgenv().blockState.resetDefense = function()
        PB.reset()
        table.clear(attackerDebounce); table.clear(animDebounce)
        getgenv().blockState.holdFrames = 0
        getgenv().blockState.holdTarget = nil
        getgenv().blockState.lastSuccessfulBlock = 0
        getgenv().blockState.faceTurnUntil = 0
        getgenv().blockState.faceUntil = 0
        MB.untilT, MB.target, MB.root = 0, nil, nil
        table.clear(MB.threats)
        St.Face.release("defense")
        St.Face.restore(player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
    end
    player.CharacterRemoving:Connect(function()
        getgenv().blockState.resetDefense()
        getgenv().userIsBlocking = false
        forceStopBlock()
    end)
    player.CharacterAdded:Connect(function(char)
        getgenv().blockState.resetDefense()
        PB.character = char
        getgenv().userIsBlocking = false
        getgenv().blockState.cooldown = 0
    end)
    RunService.Heartbeat:Connect(function(dt)
        local dashShouldBlock = DashBackend.Step(dt)
        if not St.autoBlockEnabled and not St.autoDashPredictEnabled
            and not St.autoPunishEnabled and not St.autoProjBlockEnabled and not St.autoCounterEnabled then
            getgenv().blockState.resetDefense()
            forceStopBlock()
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not getgenv().blockState.canBlock(char) then
            DashBackend.Reset(); getgenv().blockState.resetDefense(); forceStopBlock(); return
        end
        PB.syncCharacter()
        -- P13: time-based M1 lease (FPS independent) with reach/facing hysteresis.
        local meleeHold = MB.step(hrp)
        if St.autoBlockSoloEnabled and not PB.eligible(getgenv().blockState.projectileSourceChar) then
            PB.threatUntil = 0
        end
        -- Preserve the working reference's short twelve-heartbeat melee hold.
        if getgenv().blockState.holdFrames > 0 then
            getgenv().blockState.holdFrames = math.max(getgenv().blockState.holdFrames - 1, 0)
        end
        if getgenv().blockState.cooldown > 0 then
            getgenv().blockState.cooldown = math.max(getgenv().blockState.cooldown - 1, 0)
        end

        local anyLive = serviceProjectiles(hrp.Position, hrp.AssemblyLinearVelocity, dt)
        local shouldBlock = dashShouldBlock or meleeHold or getgenv().blockState.holdFrames > 0
            or (PB.canHold() and (anyLive or os.clock() < PB.threatUntil))
        if shouldBlock and not dashShouldBlock and anyLive and PB.facePosition then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if canSafelyRotate(hum) and St.Face.claim("defense", 0.06) then
                local direction = (PB.facePosition - hrp.Position) * Vector3.new(1, 0, 1)
                if direction.Magnitude > 0.5 then
                    hum.AutoRotate = false
                    local goal = CFrame.lookAt(hrp.Position, hrp.Position + direction.Unit)
                    hrp.CFrame = hrp.CFrame:Lerp(goal, 1 - math.exp(-35 * math.clamp(dt or 1/60, 0, 0.1)))
                end
            end
        elseif meleeHold and not dashShouldBlock then
            MB.track(hrp, dt)
        end
        if not anyLive and not dashShouldBlock and not meleeHold and getgenv().blockState.holdFrames <= 0 then
            St.Face.release("defense")
            St.Face.restore(char:FindFirstChildOfClass("Humanoid"))
        end
        if St.bfChainActive or os.clock() < (St.counterGuardUntil or 0) then shouldBlock = false end
        if shouldBlock then
            getgenv().blockState.cooldown = 0
            MB.send(meleeHold and MB.target or nil)
        elseif not getgenv().userIsBlocking then
            forceStopBlock(true)
        end
    end)

    -- ============================================================
    -- AUTO BLOCK BREAK  (independent toggle: St.autoBlockBreakEnabled)
    --   When you throw an M1 at someone who is BLOCKING in front of you,
    --   dash behind them using the BF curved-dash engine (NO black flash)
    --   then M1 their back to break the block. Block detection reuses the
    --   same "Block" status signal the autoblock / No-Stun logic relies on.
    -- ============================================================
    -- Server-authoritative block flag: the game inserts a "Block" child into
    -- character.Info while that character is holding block (verified in
    -- MovementController:367, Jujutsu Shenanigans).
    local function isModelBlocking(model)
        if not model then return false end
        local info = model:FindFirstChild("Info")
        return info ~= nil and info:FindFirstChild("Block") ~= nil
    end

    -- True when the target is FACING me, i.e. their block arc covers my frontal
    -- attack. Block only protects the direction they face, so when this is true a
    -- front M1 is wasted and I must hit their back; when false their back/side is
    -- already exposed and a plain M1 lands.
    local function targetFacingMe(theirHRP, myHRP)
        local toMe = (myHRP.Position - theirHRP.Position) * Vector3.new(1,0,1)
        if toMe.Magnitude < 0.1 then return true end
        local look = theirHRP.CFrame.LookVector * Vector3.new(1,0,1)
        if look.Magnitude < 0.1 then return true end
        return look.Unit:Dot(toMe.Unit) > 0
    end

    local function closestBlockingInFront()
        local myChar = player.Character
        if not myChar then return nil end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local myLook = (myHRP.CFrame.LookVector * Vector3.new(1,0,1))
        if myLook.Magnitude < 0.1 then return nil end
        myLook = myLook.Unit
        local best, bestDist = nil, math.huge
        local seen = {}
        local function consider(model)
            if not model or model == myChar or seen[model] then return end
            seen[model] = true
            local ohrp = model:FindFirstChild("HumanoidRootPart")
            local ohum = model:FindFirstChildOfClass("Humanoid")
            if not ohrp or not ohum or ohum.Health <= 0 then return end
            local toThem = (ohrp.Position - myHRP.Position) * Vector3.new(1,0,1)
            local dist = toThem.Magnitude
            if dist > Config.BlockBreakRange or dist < 0.1 then return end
            if myLook:Dot(toThem.Unit) < 0.35 then return end       -- must be in front of me
            if not isModelBlocking(model) then return end
            if dist < bestDist then bestDist = dist; best = model end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then consider(p.Character) end
        end
        local chars = workspace:FindFirstChild("Characters")
        if chars then for _, v in ipairs(chars:GetChildren()) do if v:IsA("Model") then consider(v) end end end
        return best
    end

    local blockBreakBusy = false
    local lastBlockBreak = 0
    local function tryBlockBreak()
        if not St.autoBlockBreakEnabled then return end
        -- Ignore M1s that WE fired programmatically (auto punish, or this feature's own
        -- follow-up M1). Without this, an auto-punish M1 plays the M1 animation, which
        -- re-triggered this and made the hub dash-behind + block-break ON ITS OWN with no
        -- real button press. Only a genuine user M1 should ever start a block break.
        if os.clock() - lastAutoM1 < 0.35 then return end
        if blockBreakBusy then return end
        if type(_G.NH_dashBehind) ~= "function" then return end
        local now = os.clock()
        if now - lastBlockBreak < 0.6 then return end
        local target = closestBlockingInFront()
        if not target then return end
        local thrp  = target:FindFirstChild("HumanoidRootPart")
        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not thrp or not myHRP then return end
        blockBreakBusy = true
        lastBlockBreak = now
        -- If their block arc is NOT facing me, their back/side is already open:
        -- just M1, no dash needed. Otherwise dash behind to hit the open back.
        if not targetFacingMe(thrp, myHRP) then
            faceTarget(thrp); triggerM1()
            task.delay(0.4, function() blockBreakBusy = false end)
            return
        end
        local ok = _G.NH_dashBehind(target, function()
            faceTarget(thrp); triggerM1()
        end)
        if ok == false then blockBreakBusy = false end
        task.delay(0.8, function() blockBreakBusy = false end)
    end
    -- Expose the block-break check so the UNIVERSAL M1 hook (ToolController:UseSetService
    -- "Activated", plus the moveset-remote namecall fallback) can trigger it for ANY moveset
    -- and ANY mode -- not just the few hardcoded vessel M1 animation IDs in M1_ANIMS.
    _G.NH_tryBlockBreak = tryBlockBreak

    -- Secondary/back-up trigger: the LOCAL player's M1 swing animation (vessel-only IDs).
    -- Harmless duplicate for vessel (blockBreakBusy + lastBlockBreak dedupe); the universal
    -- UseSetService hook above is what makes every other moveset work.
    -- Fire the block-break check whenever the LOCAL player starts an M1 swing.
    local function hookLocalM1(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator") or hum
        animator.AnimationPlayed:Connect(function(track)
            if not St.autoBlockBreakEnabled then return end
            local id = track and track.Animation and track.Animation.AnimationId
            if id and M1_ANIMS[id] then task.spawn(tryBlockBreak) end
        end)
    end
    if player.Character then task.spawn(hookLocalM1, player.Character) end
    player.CharacterAdded:Connect(hookLocalM1)

    -- IMPORTANT: block-break is triggered ONLY by the AnimationPlayed hook above (a real
    -- M1 SWING animation). We deliberately removed the old raw-InputBegan trigger: on
    -- mobile EVERY screen tap (joystick, camera drag, any button) is a Touch input, so it
    -- made the hub dash-behind + block-break "on its own" with no real M1. Now a manual
    -- M1 in front of a blocking target is the ONLY thing that starts a block break.
end


-- ============================================================
-- BLACK FLASH CHAIN  ::  CURVED DASH-BEHIND v45 + AntiFling
--   (replaces the original V32 BF system; wired to the hub via
--    St.bfEnabled + bfStartAll / bfStopAll / bfTriggerDash)
-- ============================================================
do
    -- PATCH P5: a do/end block still shares the main chunk's local/register budget.
    -- Initialize this subsystem in a separate function so unoptimized Luau (-O0)
    -- stays below the 200-active-local limit; exported closures retain its state.
    (function()
    local Stats  = game:GetService("Stats")
    local VIM    = VirtualInputManager
    local player = LocalPlayer


local CFG = {
    CURVE_BOW       = 5.0,
    OUT_BOW         = 2.0,
    BACK_DISTANCE   = 4.5,
    CAM_SENS        = 0.6,
    CAM_STEER       = true,
    AUTO_BLACKFLASH = true,
    ARRIVE_DIST     = 1.2,
    BF_MAX_WHIFF    = 4.0,
    SMART_PREDICT   = true,
    NET_LEAD        = 1.0,
    POSITION_GAIN   = 26,
    GLUE_SPEED      = 96,
    -- Anti-Fling / Leash Protections
    MAX_PREDICT_DIST     = 14, -- Prevents aiming across the map if they get blasted
    MAX_CHASE_DIST       = 35, -- Aborts if they fly out of combo range horizontally
    MAX_Y_DIFF           = 25, -- Aborts if they go way too high/low vertically
    KNOCKBACK_H_SPEED    = 65, -- Abs horizontal speed that always counts as knockback
    KNOCKBACK_V_SPEED    = 60, -- Abs vertical speed that always counts as knockback
    AWAY_KNOCKBACK_SPEED = 28, -- NEW: moving AWAY from you faster than this = knockback
}

local DASH_KEY          = Enum.KeyCode.E
local DASH_RANGE        = 10
local DASH_COOLDOWN     = 0.4
local DASH_DURATION     = 0.28
local DASH_MAX_DURATION = 0.36
local PREDICT_LEAD      = 0.32
local MAX_SPEED         = 320
local VEL_SMOOTH_K      = 55
local FACE_K            = 26
local TRACK_K           = 42
local YAW_TRACK_K       = 35
local ACCEL_TRACK_K     = 14
local EARLY_MIN_FRAC    = 0.35
local CAM_SETTLE_TIME   = 0.22
local BEHIND_FINISH_DEG = 62
local FACELOCK_LEAD_BOOST = 1.6
-- if we're within this gap of their LIVE back AND on their back side -> never dash
local NO_DASH_GAP  = 4.0
local BACK_SIDE_DOT = -0.15   -- look.toMe <= this counts as "on their back side"
-- last-second prediction tuning
local YAW_ACCEL_TRACK_K  = 12
local ADAPT_YAW_SCALE    = 3.0
local ADAPT_VEL_SCALE    = 22
local ADAPT_MAX_MULT     = 4.0
-- Chain reposition (Micro-Adjust)
local CHAIN_CORRECT_THRESHOLD = 1.6
local CHAIN_CORRECT_ENABLED   = true
local CHAIN_DASH_SETTLE       = 0.22
local BF = {
    MOVE_KEY    = Enum.KeyCode.Three,
    TRIGGER_KEY = Enum.KeyCode.X,
    TIMING      = 0.26,
    KEY_NUM     = 3, -- BF move skill slot (mobile tc:UseKey path); matches MOVE_KEY = Three
    HOLD        = 0.02,
    PING_FACTOR = 0.5,  -- restore the supplied v109 timing calibration
    PING_MAX    = 0.06,
    INPUT_LAT   = 0.012,
    PING_SMOOTH = 0.40,
    FINE_SPIN   = 0.003,
    SPAM_COOLDOWN = 0.12, -- min idle window after a flash completes before another can start (anti-spam settle so the game's move state resets)
}

local lastDashTime   = 0
local isDashing      = false
local dashConnection = nil
local movementController = nil
local trackerConn = nil
local bfActive       = false
local bfBusy         = false  -- sequence lock: held across chain-dash + BOTH hits so spam-taps are DROPPED, never interleaved (interleaving downgrades BF to a normal Divergent Fist)
local trackedModel, lastTPos, lastTLook, lastSampleT
local estVel         = Vector3.zero
local estAccel       = Vector3.zero
local estYawRate     = 0
local estYawAccel    = 0
local estPhysYaw     = 0
local estBlendedYaw  = 0
local faceLockConf   = 0
local lastTLookRaw   = nil
local myLastPos      = nil
local Runtime = { generation = 0, target = nil, character = nil, lock = nil,
    correction = nil, hitAt = nil, input = nil, mouseBefore = nil, noBF = false,
    reinputPending = false, moveInFlight = false, plan = nil, pairReady = false,
    timing = {status = "idle"} }
St.Face.priority.blackflash = 95
_G.NH_bfTimingStatus = function()
    return table.clone(Runtime.timing) -- a sent pair is NOT confirmation of a Black Flash
end
local function bfTargetRoot(target)
    return target and target.Parent and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)
end
local function bfValid(target, token)
    if token and token ~= Runtime.generation then return false end
    local ch = player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local enemyHum = target and target:FindFirstChildOfClass("Humanoid")
    -- Complete an already-started v109 pair through ordinary move-busy/stun.
    -- Death, respawn, hard crowd control and removal still cancel immediately.
    if not ch or (Runtime.character and Runtime.character ~= ch)
        or not hum or not St.Face.canTurn(hum) or not enemyHum or enemyHum.Health <= 0
        or not bfTargetRoot(target) then return false end
    return Runtime.noBF or St.bfEnabled == true
end

-- VIM keyboard events may be delivered AFTER SendKeyEvent returns. A scoped
-- boolean alone is not enough: the slot-3 hook would swallow that deferred event.
-- One short-lived ticket per synthetic edge lets only that expected edge through.
local function bfSendKeyboard(down)
    local eventName = down and "Activated" or "Deactivated"
    local queues = St.bfNativeKeyEvents
    if not queues then queues = {}; St.bfNativeKeyEvents = queues end
    local queue = queues[eventName]
    if not queue then queue = {}; queues[eventName] = queue end
    local now = os.clock()
    for i = #queue, 1, -1 do
        if queue[i].expires <= now then table.remove(queue, i) end
    end
    local ticket = {expires = now + 0.25}
    St.bfSyntheticUntil = now + 0.20
    table.insert(queue, ticket)
    local ok, err = pcall(function() VIM:SendKeyEvent(down, BF.MOVE_KEY, false, game) end)
    if not ok then
        for i = #queue, 1, -1 do
            if queue[i] == ticket then table.remove(queue, i); break end
        end
        error(err)
    end
end
local function bfReleaseInput(expected)
    local input = Runtime.input
    if expected and input ~= expected then return true end
    Runtime.input = nil
    if not input then return true end
    local previous = St.bfSyntheticInput
    St.bfSyntheticInput = true
    local ok, err = pcall(function()
        if input.route.tc then
            return input.route.useKey(input.route.tc, input.route.slot, "Deactivated")
        else bfSendKeyboard(false) end
    end)
    St.bfSyntheticInput = previous
    if not ok then
        Runtime.timing.releaseError = tostring(err)
        return false
    end
    return true
end
local function bfRestore()
    St.Face.release("blackflash")
    local ch = player.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then St.Face.restore(hum) end
    if Runtime.mouseBefore then
        local previous = Runtime.mouseBefore; Runtime.mouseBefore = nil
        pcall(function() UserInputService.MouseBehavior = previous end)
    end
end
local function bfCancel()
    Runtime.generation += 1
    RunService:UnbindFromRenderStep("HubBlackFlashFacing")
    local moving = isDashing or Runtime.correction ~= nil
    if dashConnection then dashConnection:Disconnect(); dashConnection = nil end
    if Runtime.correction then Runtime.correction:Disconnect(); Runtime.correction = nil end
    bfReleaseInput()
    local ch = Runtime.character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if moving and root and root.Parent then
        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    end
    bfActive, bfBusy, isDashing = false, false, false
    Runtime.target, Runtime.character, Runtime.lock, Runtime.hitAt = nil, nil, nil, nil
    Runtime.noBF = false
    Runtime.plan, Runtime.pairReady = nil, false
    St.bfChainActive, St.bfChainUntil = false, 0
    Runtime.reinputPending, Runtime.moveInFlight = false, false
    Runtime.timing.status = "cancelled"
    St.bfSyntheticInput = false
    bfRestore()
end
local function bfBegin(target, noBF)
    Runtime.generation += 1
    Runtime.target, Runtime.character = target, player.Character
    Runtime.lock = St.lockOnEnabled and St.lockOnTarget and St.lockOnTarget.Char or nil
    Runtime.noBF = noBF == true
    Runtime.hitAt = nil
    Runtime.plan, Runtime.pairReady = nil, false
    Runtime.reinputPending, Runtime.moveInFlight = false, false
    St.bfChainActive, St.bfChainUntil = true, os.clock() + 1.5
    St.Face.claim("blackflash", 0.09)
    return Runtime.generation
end
local function bfFace(root, targetRoot, dt)
    local hum = root and root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
    local canRotate = hum and St.Face.canTurn(hum)
    if not root or not targetRoot or not root.Parent or not targetRoot.Parent or not canRotate
        or not St.Face.claim("blackflash", 0.09) then return false end
    local delta = (targetRoot.Position - root.Position) * Vector3.new(1, 0, 1)
    hum.AutoRotate = false
    if delta.Magnitude > 0.05 then
        local goal = CFrame.lookAt(root.Position, root.Position + delta.Unit)
        root.CFrame = CFrame.new(root.Position) * root.CFrame.Rotation:Lerp(goal.Rotation,
            1 - math.exp(-FACE_K * math.max(dt or 1/60, 0)))
    end
    return true
end

-- Keep BF body-facing AFTER the game's camera/shiftlock pass. Console keeps owning
-- its smooth orbit camera; this pass owns only body yaw, never camera/movement input.
local function bfStartFacing(token)
    RunService:UnbindFromRenderStep("HubBlackFlashFacing")
    RunService:BindToRenderStep("HubBlackFlashFacing", Enum.RenderPriority.Last.Value + 4, function(dt)
        if token ~= Runtime.generation or not Runtime.target
            or not (isDashing or Runtime.correction or bfActive or bfBusy) then
            RunService:UnbindFromRenderStep("HubBlackFlashFacing"); return
        end
        if not bfValid(Runtime.target, token) then bfCancel(); return end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local part = bfTargetRoot(Runtime.target)
        if root and part then bfFace(root, part, dt) end
    end)
end

-- == mousemoverel wrapper =======================================================
local function moveMouse(dx, dy)
    if type(mousemoverel) == "function" then
        local ok = pcall(function() mousemoverel(dx, dy) end)
        if ok then return true end
    end
    if VIM and VIM.SendMouseMoveEvent then
        local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
        local ok = pcall(function() VIM:SendMouseMoveEvent(vp.X/2 + dx, vp.Y/2 + dy, game) end)
        if ok then return true end
    end
    return false
end

-- MOBILE: never allow synthetic mouse-move camera steering. SendMouseMoveEvent
-- flips Roblox's LastInputType to mouse/keyboard, which auto-hides the touch
-- joystick + jump button. PC keeps full camera steering.
local canSteer = (not mobile) and ((type(mousemoverel) == "function") or (VIM ~= nil and VIM.SendMouseMoveEvent ~= nil))

-- == ping =======================================================================
local function getPing()
    local ok, ping = pcall(function() return player:GetNetworkPing() end)
    if ok and type(ping) == "number" and ping > 0 then return ping end
    local ok2, ms = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok2 and type(ms) == "number" and ms > 0 then return (ms / 1000) * 0.5 end
    return 0
end

local smoothedPing = nil
local function getSmoothedPing()
    local p = getPing()
    if not smoothedPing then smoothedPing = p
    else smoothedPing = smoothedPing + (p - smoothedPing) * BF.PING_SMOOTH end
    return smoothedPing
end

-- == shift lock =================================================================
local function isShiftLockActive()
    local mlc = player.PlayerScripts
        :FindFirstChild("PlayerModule")
        and player.PlayerScripts.PlayerModule:FindFirstChild("CameraModule")
        and player.PlayerScripts.PlayerModule.CameraModule:FindFirstChild("MouseLockController")
    if mlc then return mlc:FindFirstChild("CursorImage") ~= nil end
    return false
end

-- == math helpers ===============================================================
local function horizontal(v) return Vector3.new(v.X, 0, v.Z) end
local function damp(k, dt)   return 1 - math.exp(-k * dt) end
local function easeOutCirc(x)
    x = math.clamp(x, 0, 1)
    return math.sqrt(1 - (x-1)*(x-1))
end
local function rotateY(v, a)
    local c, s = math.cos(a), math.sin(a)
    return Vector3.new(c*v.X + s*v.Z, v.Y, -s*v.X + c*v.Z)
end
local function signedYawBetween(a, b)
    local dot = math.clamp(a:Dot(b), -1, 1)
    local ang = math.acos(dot)
    local cY  = a.X * b.Z - a.Z * b.X
    return (cY >= 0) and -ang or ang
end
local function adaptiveK(baseK, deviation, scale)
    local mult = 1 + math.clamp(deviation / scale, 0, ADAPT_MAX_MULT - 1)
    return baseK * mult
end

-- == character helpers ==========================================================
local function getCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        return char
    end
end
local function getMovementController()
    if movementController and type(movementController.Dash) == "function" then return movementController end
    movementController = nil
    if type(getreg) == "function" then
        local ok, registry = pcall(getreg)
        if ok and type(registry) == "table" then
            for _, m in pairs(registry) do
                if type(m) == "table" and rawget(m, "Name") == "MovementController"
                    and type(rawget(m, "Dash")) == "function" then movementController = m; break end
            end
        end
    end
    if not movementController then
        pcall(function()
            local knitRoot = ReplicatedStorage:FindFirstChild("Knit")
            local module = knitRoot and knitRoot:FindFirstChild("Knit")
            if module then
                local Knit = require(module)
                local controller = Knit.GetController("MovementController")
                if controller and type(controller.Dash) == "function" then movementController = controller end
            end
        end)
    end
    return movementController
end

local function nukeGameBV(character)
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        for _, bv in ipairs(torso:GetChildren()) do
            if bv:IsA("BodyVelocity") then
                pcall(function() bv.MaxForce = Vector3.zero; bv.Velocity = Vector3.zero; bv:Destroy() end)
            end
        end
    end
    for _, d in ipairs(character:GetDescendants()) do
        if d:IsA("BodyVelocity") then
            pcall(function() d.MaxForce = Vector3.zero; d.Velocity = Vector3.zero; d:Destroy() end)
        end
    end
end

-- == target finding =============================================================
local function findTarget(maxRange)
    local character = getCharacter()
    if not character then return nil, math.huge end
    local rootPart = character.HumanoidRootPart
    local range = tonumber(maxRange) or DASH_RANGE
    if St.lockOnEnabled and St.lockOnTarget then
        local locked = St.lockOnTarget.Char
        local part = bfTargetRoot(locked)
        local hum = locked and locked:FindFirstChildOfClass("Humanoid")
        if part and hum and hum.Health > 0 and locked ~= character then
            local distance = (part.Position - rootPart.Position).Magnitude
            if distance <= range then return locked, distance end
        end
        return nil, math.huge
    end
    local closest, closestDist = nil, range + 1
    local folder = Workspace:FindFirstChild("Characters")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj ~= character then
                local hum  = obj:FindFirstChild("Humanoid")
                local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                if hum and part and hum.Health > 0 then
                    local dist = (part.Position - rootPart.Position).Magnitude
                    if dist <= range and dist < closestDist then
                        closestDist, closest = dist, obj
                    end
                end
            end
        end
    end
    return closest, closestDist
end

-- == LIVE back geometry (no prediction) - single source of truth ================
local function liveBackInfo(target)
    local char = getCharacter()
    local part = target and (target.PrimaryPart or target:FindFirstChild("HumanoidRootPart"))
    if not char or not part then return math.huge, 1 end
    local hrp = char.HumanoidRootPart
    local look = horizontal(part.CFrame.LookVector)
    if look.Magnitude < 0.01 then look = lastTLook or Vector3.new(0,0,1) end
    look = look.Unit
    local backH = horizontal(part.Position) - look * CFG.BACK_DISTANCE
    local gap   = (horizontal(hrp.Position) - backH).Magnitude
    local toMe  = horizontal(hrp.Position - part.Position)
    local dot   = (toMe.Magnitude > 0.05) and look:Dot(toMe.Unit) or -1
    return gap, dot
end

-- == UNIFIED KNOCKBACK GUARD ====================================================
-- Replaces ALL the duplicated inline velocity checks. Detects knockback by:
--   (a) position gates (distance / height) - always reliable
--   (b) physics velocity AWAY from you  - catches BodyVelocity/impulse knockback
--   (c) position-derived velocity AWAY  - catches CFrame/animation knockback,
--       where AssemblyLinearVelocity stays ~0 (this was the old blind spot)
local function isKnockedBack(target)
    local char = getCharacter()
    local part = target and (target.PrimaryPart or target:FindFirstChild("HumanoidRootPart"))
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not part or not hrp then return false end

    -- (a) positional gates
    local distH = (horizontal(part.Position) - horizontal(hrp.Position)).Magnitude
    local yDiff = math.abs(part.Position.Y - hrp.Position.Y)
    if distH > CFG.MAX_CHASE_DIST or yDiff > CFG.MAX_Y_DIFF then return true end

    -- direction pointing from ME -> THEM
    local away = horizontal(part.Position - hrp.Position)
    away = (away.Magnitude > 0.1) and away.Unit or Vector3.new(0, 0, 1)

    -- (b) physics-impulse knockback
    local v = part.AssemblyLinearVelocity
    if math.abs(v.Y) > CFG.KNOCKBACK_V_SPEED then return true end
    if Vector3.new(v.X, 0, v.Z).Magnitude > CFG.KNOCKBACK_H_SPEED then return true end
    if horizontal(v):Dot(away) > CFG.AWAY_KNOCKBACK_SPEED then return true end

    -- (c) CFrame/animation knockback (use tracker's position-derived velocity)
    if trackedModel == target and horizontal(estVel):Dot(away) > CFG.AWAY_KNOCKBACK_SPEED then
        return true
    end

    return false
end

local function bfInsideHardLeash(target)
    local char, part = getCharacter(), bfTargetRoot(target)
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root ~= nil and part ~= nil
        and (horizontal(part.Position) - horizontal(root.Position)).Magnitude <= CFG.MAX_CHASE_DIST
        and math.abs(part.Position.Y - root.Position.Y) <= CFG.MAX_Y_DIFF
end

local function alreadyAtBack(target)
    if not target then return false end
    local gap, dot = liveBackInfo(target)
    return gap <= NO_DASH_GAP and dot <= BACK_SIDE_DOT
end
local function isPosBehind(target, myPos)
    local part = target and (target.PrimaryPart or target:FindFirstChild("HumanoidRootPart"))
    if not part then return false end
    local look = horizontal(part.CFrame.LookVector)
    if look.Magnitude < 0.01 then look = lastTLook end
    if not look or look.Magnitude < 0.01 then return false end
    look = look.Unit
    local toMe = horizontal(myPos - part.Position)
    if toMe.Magnitude < 0.1 then return true end
    return look:Dot(toMe.Unit) <= -math.cos(math.rad(BEHIND_FINISH_DEG))
end

-- == tracker (ADAPTIVE + yaw acceleration) ======================================
local function updateTracker(target)
    local part = bfTargetRoot(target)
    if not part then trackedModel = nil; return end
    local now, pos = os.clock(), part.Position
    local rawLook = horizontal(part.CFrame.LookVector)
    local look = rawLook.Magnitude > 0.01 and rawLook.Unit or Vector3.new(0, 0, 1)
    local physYaw = math.clamp(part.AssemblyAngularVelocity.Y, -14, 14)
    local char = getCharacter()
    local myPos = char and char.HumanoidRootPart.Position
    local dt = lastSampleT and now - lastSampleT or 0
    if trackedModel ~= target or not lastTPos or dt > 0.25
        or (pos - lastTPos).Magnitude > math.max(12, 100 * dt) then
        estVel, estAccel = horizontal(part.AssemblyLinearVelocity), Vector3.zero
        estYawRate, estYawAccel, estPhysYaw, estBlendedYaw = 0, 0, physYaw, 0
        faceLockConf = 0
    elseif dt > 1e-4 then
        -- Never mix a sub-frame duplicate sample into the adaptive filters.
        if dt < 0.008 and (pos - lastTPos).Magnitude < 0.001
            and look:Dot(lastTLookRaw) > 0.99999 then return end
        local observed = horizontal(pos - lastTPos) / dt
        local newVel = estVel:Lerp(observed, damp(adaptiveK(TRACK_K,
            (observed - estVel).Magnitude, ADAPT_VEL_SCALE), dt))
        local acceleration = (newVel - estVel) / dt
        if acceleration.Magnitude > 120 then acceleration = acceleration.Unit * 120 end
        estAccel = estAccel:Lerp(acceleration, damp(ACCEL_TRACK_K, dt))
        estVel = newVel
        local rawYaw = math.clamp(signedYawBetween(lastTLookRaw, look) / dt, -14, 14)
        local prevYaw = estYawRate
        estYawRate += (rawYaw - estYawRate) * damp(adaptiveK(YAW_TRACK_K,
            math.abs(rawYaw - estYawRate), ADAPT_YAW_SCALE), dt)
        estYawAccel += (math.clamp((estYawRate - prevYaw) / dt, -35, 35) - estYawAccel)
            * damp(YAW_ACCEL_TRACK_K, dt)
        estPhysYaw += (physYaw - estPhysYaw) * damp(50, dt)
        -- Only blend physical yaw when it agrees with observed CFrame rotation.
        local coherent = math.abs(estPhysYaw) > 0.15 and estPhysYaw * estYawRate > 0
            and math.abs(estPhysYaw - estYawRate) < 4
        estBlendedYaw = coherent and (estYawRate * 0.75 + estPhysYaw * 0.25) or estYawRate
        local confidence = 0
        if myPos and myLastPos then
            local toMe, previous = horizontal(myPos - pos), horizontal(myLastPos - lastTPos)
            if toMe.Magnitude > 0.1 and previous.Magnitude > 0.1 then
                local errorYaw = signedYawBetween(look, toMe.Unit)
                local bearingRate = signedYawBetween(previous.Unit, toMe.Unit) / dt
                local toward = math.abs(errorYaw) > 0.08 and estYawRate * math.sign(errorYaw) or 0
                local tracking = math.abs(bearingRate) > 0.4 and bearingRate * estYawRate > 0
                    and math.abs(bearingRate - estYawRate) < 2.5
                confidence = math.max(math.clamp(toward / 5, 0, 1), tracking and 0.7 or 0)
            end
        end
        faceLockConf += (confidence - faceLockConf) * damp(confidence > faceLockConf and 6 or 8, dt)
    else return end
    trackedModel, lastTPos, lastSampleT = target, pos, now
    lastTLookRaw, lastTLook, myLastPos = look, look, myPos
end

local function predictedDisplacement(target, lead)
    local part = bfTargetRoot(target)
    if not part then return Vector3.zero end
    lead = math.clamp(lead, 0, math.min(PREDICT_LEAD + 0.25, 0.75))
    local velocity = trackedModel == target and horizontal(estVel) or horizontal(part.AssemblyLinearVelocity)
    local acceleration = trackedModel == target and horizontal(estAccel) or Vector3.zero
    if acceleration.Magnitude > 120 then acceleration = acceleration.Unit * 120 end
    local delta = velocity * lead + acceleration * (0.5 * lead * lead * math.exp(-5 * lead))
    -- A braking estimate must not invent a reversal behind a moving target.
    if velocity.Magnitude > 0.5 and delta:Dot(velocity.Unit) < 0 then
        delta -= velocity.Unit * delta:Dot(velocity.Unit)
    end
    if delta.Magnitude > CFG.MAX_PREDICT_DIST then delta = delta.Unit * CFG.MAX_PREDICT_DIST end
    return delta
end
local function predictBack(target, lead)
    local part = bfTargetRoot(target)
    if not part then return Vector3.zero, Vector3.zero, Vector3.new(0, 0, 1) end
    lead = math.clamp(tonumber(lead) or 0, 0, math.min(PREDICT_LEAD + 0.25, 0.75))
    local look = horizontal(part.CFrame.LookVector)
    look = look.Magnitude > 0.01 and look.Unit or Vector3.new(0, 0, 1)
    local yaw = trackedModel == target and estBlendedYaw or 0
    local yawAccel = trackedModel == target and estYawAccel or 0
    local angle = yaw * lead + 0.5 * yawAccel * lead * lead * math.exp(-5 * lead)
    if CFG.SMART_PREDICT then
        local char = getCharacter()
        local toMe = char and horizontal(char.HumanoidRootPart.Position - part.Position)
        if toMe and toMe.Magnitude > 0.1 then
            local errorYaw = signedYawBetween(look, toMe.Unit)
            if errorYaw * yaw > 0 then
                angle += math.clamp(errorYaw - angle, -0.35, 0.35) * faceLockConf * math.min(lead * 3, 1)
            end
        end
    end
    local predLook = rotateY(look, math.clamp(angle, -math.pi, math.pi)).Unit
    local center = horizontal(part.Position) + predictedDisplacement(target, lead)
    return center, center - predLook * CFG.BACK_DISTANCE, predLook
end

-- == camera steering ============================================================
local dxAccumulator = 0
local function resetCamSteer() dxAccumulator = 0 end
local function steerCameraYaw(focusPos, dt)
    if not (CFG.CAM_STEER and canSteer) or St.Face.lockOnCameraActive() then
        dxAccumulator = 0; return nil
    end
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local camPos = cam.CFrame.Position
    local toT  = horizontal(focusPos - camPos)
    local look = horizontal(cam.CFrame.LookVector)
    if toT.Magnitude < 0.1 or look.Magnitude < 0.01 then return nil end
    toT = toT.Unit; look = look.Unit
    local crossY = look.X * toT.Z - look.Z * toT.X
    local dot = look.X * toT.X + look.Z * toT.Z
    local yawErr = math.atan2(crossY, dot)
    if math.abs(yawErr) < 0.005 then return 0 end
    local Kp = 16
    local turnRads = yawErr * Kp * dt
    if math.abs(turnRads) > math.abs(yawErr) then turnRads = yawErr end
    dxAccumulator = dxAccumulator + turnRads * 450 * CFG.CAM_SENS
    local int_dx = math.modf(dxAccumulator)
    if int_dx ~= 0 then
        dxAccumulator = dxAccumulator - int_dx
        moveMouse(int_dx, 0)
    end
    return math.abs(yawErr)
end
local function settleCamera(target)
    local token = Runtime.generation
    if not (CFG.CAM_STEER and canSteer) then return end
    task.spawn(function()
        local t0 = os.clock()
        while os.clock() - t0 < CAM_SETTLE_TIME do
            local dt = RunService.RenderStepped:Wait()
            if token ~= Runtime.generation then return end
            local part = bfTargetRoot(target)
            if not part then return end
            local err = steerCameraYaw(part.Position, dt)
            if err ~= nil and err < 0.01 then return end
        end
    end)
end

-- == v109 native input sequence + impact-synchronized dash =====================
local function faceTargetOnce(target)
    local char, part = getCharacter(), bfTargetRoot(target)
    if not char or not part then return end
    local root = char.HumanoidRootPart
    if bfFace(root, part, 1/60) then
        local delta = horizontal(part.Position - root.Position)
        if delta.Magnitude > 0.05 then root.CFrame = CFrame.lookAt(root.Position, root.Position + delta.Unit) end
    end
end
local function bfNetworkLead(ping)
    return CFG.SMART_PREDICT and math.clamp(ping * CFG.NET_LEAD, 0, 0.25) or 0
end
local function bfComputeEff(ping)
    -- UNCHANGED v109 calibration; latency prediction never changes this interval.
    return math.max(0.05, BF.TIMING + math.clamp(ping * BF.PING_FACTOR, 0, BF.PING_MAX) - BF.INPUT_LAT)
end
local function bfResolveRoute()
    if not mobile then return {label = "keyboard", key = BF.MOVE_KEY} end
    local tc = nhGetToolController()
    local useKey = tc and ((_G.NH_bfUseKeyOwner == tc and _G.NH_origUseKey) or tc.UseKey)
    if type(useKey) ~= "function" then return nil end
    return {label = "mobile_usekey", tc = tc, useKey = useKey, slot = BF.KEY_NUM}
end
local function bfEndSequence(token)
    if token ~= Runtime.generation or isDashing or bfActive then return end
    if not Runtime.noBF and not Runtime.pairReady then return end
    bfBusy = false
    Runtime.moveInFlight, Runtime.reinputPending = false, false
    Runtime.target, Runtime.character, Runtime.lock, Runtime.hitAt = nil, nil, nil, nil
    Runtime.plan, Runtime.noBF = nil, false
    St.bfChainActive, St.bfChainUntil = false, 0
    RunService:UnbindFromRenderStep("HubBlackFlashFacing")
    bfRestore()
end
local function bfTap(token, route, onDown)
    if token ~= Runtime.generation then return nil end
    if not bfReleaseInput() then error(Runtime.timing.releaseError or "key release failed") end
    local input = {route = route}
    Runtime.input = input
    local previous = St.bfSyntheticInput
    St.bfSyntheticInput = true
    local at = os.clock()
    local ok, err = pcall(function()
        if route.tc then route.useKey(route.tc, route.slot, "Activated") else bfSendKeyboard(true) end
    end)
    St.bfSyntheticInput = previous
    if not ok then bfReleaseInput(input); error(err) end
    if token ~= Runtime.generation then bfReleaseInput(input); return nil end
    if onDown then onDown(at) end
    -- Restore v109's yielding hold. P10's nonblocking absolute-down deadline
    -- removed the hold/frame slip that the user's working interval was tuned for.
    task.wait(BF.HOLD)
    if token ~= Runtime.generation then bfReleaseInput(input); return nil end
    if not bfReleaseInput(input) then error(Runtime.timing.releaseError or "key release failed") end
    return at
end
local function bfFireCharged(effTime, target, route, plan)
    if bfActive or not bfValid(target, Runtime.generation) then return false end
    bfActive, bfBusy = true, true
    local token, timing = Runtime.generation, Runtime.timing
    timing.status, timing.route = "charging", route.label
    task.spawn(function()
        local ok, err = pcall(function()
            faceTargetOnce(target)
            Runtime.moveInFlight, Runtime.reinputPending = true, true
            local firstAt = bfTap(token, route, function(at)
                timing.firstAt = at
                plan.impactAt = at + effTime + 1/60
                Runtime.hitAt = plan.impactAt + plan.netLead
            end)
            if not firstAt then return end
            -- EXACT v109 sequence: deadline is set AFTER first release, subtract
            -- only the configured hold; actual hold slippage remains observable.
            local deadline = os.clock() + (effTime - BF.HOLD)
            timing.secondDeadline = deadline
            timing.holdSlip = math.max(0, os.clock() - firstAt - BF.HOLD)
            plan.impactAt, Runtime.hitAt = deadline, deadline + plan.netLead
            while bfValid(target, token) and deadline - os.clock() > BF.FINE_SPIN do
                RunService.Heartbeat:Wait()
            end
            if not bfValid(target, token) then return end
            while os.clock() < deadline do end -- at most the final 3ms
            if not bfInsideHardLeash(target) then timing.status = "target_left_leash"; return end
            faceTargetOnce(target)
            local secondAt = bfTap(token, route, function(at)
                plan.impactAt, Runtime.hitAt = at, at + plan.netLead
                timing.secondAt, timing.actualInterval = at, at - firstAt
                timing.lateBy = math.max(0, at - deadline)
                timing.deadlineMissed = timing.lateBy > 0.025
                timing.status = "input_pair_sent" -- NOT server-accepted Black Flash
                Runtime.reinputPending = false
            end)
            if not secondAt then return end
        end)
        if token ~= Runtime.generation then return end
        if not ok then
            bfCancel()
            timing.status, timing.error = "sequence_error", tostring(err)
            warn("[BlackFlash P11] input sequence stopped:", err)
            return
        end
        if not bfValid(target, token) then bfCancel(); return end
        bfReleaseInput()
        bfActive, Runtime.reinputPending = false, false
        task.delay(BF.SPAM_COOLDOWN, function()
            if token ~= Runtime.generation then return end
            Runtime.pairReady = true
            bfEndSequence(token)
        end)
    end)
    return true
end

local function bfSelfBlocked()
    local ch = LocalPlayer.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not ch or not hum or not hrp or hum.Health <= 0 then return true end
    -- game ragdoll attribute (0 = fine, anything else = ragdolled / grabbed)
    if ch:GetAttribute("Ragdoll") == true or (tonumber(ch:GetAttribute("Ragdoll")) or 0) > 0 then return true end
    -- the game's CC / grab markers live as child instances on your character
    if ch:FindFirstChild("Stun") or ch:FindFirstChild("Knockback") or ch:FindFirstChild("Hold")
        or ch:FindFirstChild("Grab") or ch:FindFirstChild("Grabbed") or ch:FindFirstChild("Carry") then
        return true
    end
    -- physics ragdoll / fall states
    local st = hum:GetState()
    if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.PlatformStanding then return true end
    -- being physically launched / flung upward (a normal dash is horizontal, so we only gate on a
    -- large VERTICAL velocity to avoid blocking the legit post-dash flash)
    local v = hrp.AssemblyLinearVelocity
    if math.abs(v.Y) > 80 then return true end
    return false
end



local function wrapAngle(a) return (a + math.pi) % (2 * math.pi) - math.pi end
local function angleOf(v) return math.atan2(v.Z, v.X) end
local function radialAt(a) return Vector3.new(math.cos(a), 0, math.sin(a)) end
local function wallParams(character, target)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.RespectCanCollide = true
    local excluded = {character, target}
    for _, other in ipairs(Players:GetPlayers()) do
        if other.Character then table.insert(excluded, other.Character) end
    end
    params.FilterDescendantsInstances = excluded
    return params
end
local function wallLimited(origin, displacement, params)
    if displacement.Magnitude < 0.05 then return displacement end
    local hit = Workspace:Raycast(origin, displacement, params)
    if hit then return displacement.Unit * math.max(0, hit.Distance - 0.5) end
    return displacement
end
local function executeCurvedDash(target, opts)
    local noBF, onArrive = opts and opts.noBF == true, opts and opts.onArrive
    if isDashing or bfActive or bfBusy or bfSelfBlocked() then return false end
    local character, part = getCharacter(), bfTargetRoot(target)
    local enemyHum = target and target:FindFirstChildOfClass("Humanoid")
    if not character or not part or not enemyHum or enemyHum.Health <= 0 then return false end
    updateTracker(target)
    if isKnockedBack(target) then return false end
    local root, humanoid = character.HumanoidRootPart, character:FindFirstChildOfClass("Humanoid")
    local atBack = alreadyAtBack(target)
    if noBF and atBack then
        if onArrive then task.spawn(onArrive) end
        return true
    end
    local willFlash = not noBF and CFG.AUTO_BLACKFLASH
    if atBack and not willFlash then return true end
    local wantDash = not atBack
    local route = willFlash and bfResolveRoute() or nil
    if willFlash and not route then
        Runtime.timing = {status = "route_unavailable", error = "native mobile ToolController unavailable"}
        return false
    end
    local controller = wantDash and getMovementController() or nil
    if wantDash and not controller then
        Runtime.timing = {status = "dash_unavailable"}
        return false
    end
    local ping = getSmoothedPing() -- one sample for both calibration and prediction
    local eff, netLead = bfComputeEff(ping), bfNetworkLead(ping)
    local token = bfBegin(target, noBF)
    bfBusy = true -- owned synchronously, BEFORE Dash() or an input can yield
    local mode = wantDash and (willFlash and "flash_dash" or "dash")
        or (CHAIN_CORRECT_ENABLED and "flash_glue" or "flash_static")
    local plan = {mode = mode, netLead = netLead, interval = eff,
        hold = math.clamp(0.10 + netLead, 0.12, 0.20), armed = false}
    Runtime.plan = plan
    Runtime.timing = {status = "planned", mode = mode, interval = eff, networkLead = netLead}
    bfStartFacing(token)
    faceTargetOnce(target)
    local center = horizontal(part.Position)
    local relative = horizontal(root.Position) - center
    if relative.Magnitude < 0.1 then relative = -horizontal(root.CFrame.LookVector) * 0.1 end
    plan.phi0, plan.r0 = angleOf(relative), relative.Magnitude
    local _, _, look0 = predictBack(target, math.min(DASH_DURATION + netLead, PREDICT_LEAD + netLead))
    plan.delta = wrapAngle(angleOf(-look0) - plan.phi0)
    plan.params = wallParams(character, target)
    if math.abs(plan.delta) > math.rad(155) then
        -- Face-to-face is ambiguous: prefer the unobstructed half-orbit.
        local left = radialAt(plan.phi0 + math.pi/2) * math.max(plan.r0, CFG.BACK_DISTANCE)
        local right = radialAt(plan.phi0 - math.pi/2) * math.max(plan.r0, CFG.BACK_DISTANCE)
        local origin = Vector3.new(center.X, root.Position.Y, center.Z)
        local a, z = wallLimited(origin, left, plan.params).Magnitude, wallLimited(origin, right, plan.params).Magnitude
        if math.abs(a-z) > 1 then plan.delta = math.abs(plan.delta) * (a > z and 1 or -1) end
    end
    if wantDash then
        local tangent = Vector3.new(-relative.Unit.Z, 0, relative.Unit.X) * math.sign(plan.delta)
        local direction = tangent:Dot(horizontal(root.CFrame.RightVector)) >= 0 and "Right" or "Left"
        local before = {}
        for _, d in ipairs(character:GetDescendants()) do if d:IsA("BodyVelocity") then before[d] = true end end
        isDashing = true
        local ok, err = pcall(function() controller:Dash(player, character, direction) end)
        if token ~= Runtime.generation then return false end
        if not ok or not bfValid(target, token) then
            bfCancel(); Runtime.timing.error = tostring(err); return false
        end
        -- Only own newly-created dash BVs; never delete existing/move-owned ones.
        for _, d in ipairs(character:GetDescendants()) do
            if d:IsA("BodyVelocity") and not before[d] then
                pcall(function() d.MaxForce = Vector3.zero; d.Velocity = Vector3.zero; d:Destroy() end)
            end
        end
        if CFG.CAM_STEER and not mobile and not St.Face.lockOnCameraActive() then
            if not Runtime.mouseBefore then Runtime.mouseBefore = UserInputService.MouseBehavior end
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    else isDashing = true end -- a short low-speed back-sync phase, no Dash() call
    resetCamSteer()
    plan.t0 = os.clock() -- Dash() may yield: timeline begins after it returns
    plan.firstDelay = wantDash and math.max(0, DASH_DURATION - eff - 1/60) or 0
    plan.impactAt = plan.t0 + (willFlash and (plan.firstDelay + eff + 1/60) or DASH_DURATION)
    local smoothVelocity = horizontal(root.AssemblyLinearVelocity)
    local function finish(reason)
        if token ~= Runtime.generation then return end
        if dashConnection then dashConnection:Disconnect(); dashConnection = nil end
        isDashing = false
        if root.Parent then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
        Runtime.timing.movementReason = reason
        local gap = liveBackInfo(target)
        Runtime.timing.landGap = gap
        Runtime.timing.behind = isPosBehind(target, root.Position)
        if noBF then
            Runtime.pairReady = true
            Runtime.timing.status = reason == "arrived" and "dash_arrived" or "dash_stopped"
            bfEndSequence(token)
            if reason == "arrived" and onArrive then task.spawn(onArrive) end
        elseif not willFlash then
            Runtime.pairReady = true
            Runtime.timing.status = "dash_only"
            bfEndSequence(token)
        else bfEndSequence(token) end
        settleCamera(target)
    end
    local function snapshot(now, dt)
        local progress = math.clamp((now - plan.t0) / math.max(plan.impactAt - plan.t0, 0.05), 0, 1)
        local lead = math.clamp(math.max(0, plan.impactAt - now) + netLead, 0, PREDICT_LEAD + netLead)
        local _, _, look = predictBack(target, lead)
        local delta = wrapAngle(angleOf(-look) - plan.phi0)
        delta += math.floor((plan.delta - delta) / (2 * math.pi) + 0.5) * 2 * math.pi
        plan.delta += (delta - plan.delta) * damp(35, dt)
        local liveCenter = horizontal(part.Position)
        local origin = Vector3.new(part.Position.X, root.Position.Y, part.Position.Z)
        local displacement = wallLimited(origin, predictedDisplacement(target, lead), plan.params)
        local back = wallLimited(origin + displacement, -look * CFG.BACK_DISTANCE, plan.params)
        return {progress = progress, center = liveCenter, disp = displacement,
            radius = back.Magnitude, delta = plan.delta, velocity = horizontal(estVel)}
    end
    local function desiredAt(snap, nextStep)
        local duration = math.max(plan.impactAt - plan.t0, 0.05)
        local s = math.clamp(snap.progress + nextStep / duration, 0, 1)
        local p = easeOutCirc(s)
        local centerAt = snap.center + snap.velocity * nextStep
        local lead = math.clamp(math.max(0, plan.impactAt - os.clock() - nextStep) + netLead, 0, PREDICT_LEAD + netLead)
        local offset = nextStep > 0 and predictedDisplacement(target, lead) or snap.disp
        local relativeCenter = centerAt + offset * p
        local phi = plan.phi0 + snap.delta * p
        local bow = math.sin(math.pi * p) * (CFG.CURVE_BOW * 0.35 + CFG.OUT_BOW)
        local radius = plan.r0 + (snap.radius - plan.r0) * p + bow
        -- Grow the minimum radius smoothly; never pop outwards at progress zero.
        local floor = math.min(2.6, snap.radius) * math.sin(math.pi * math.min(s, 0.5))
        radius = math.max(radius, floor)
        return relativeCenter + radialAt(phi) * radius
    end
    if willFlash and plan.firstDelay == 0 then
        plan.armed = bfFireCharged(eff, target, route, plan)
        if token ~= Runtime.generation or not plan.armed then return false end
    end
    dashConnection = RunService.Stepped:Connect(function(_, rawDt)
        if not bfValid(target, token) then bfCancel(); return end
        local dt = math.clamp(rawDt, 1/1000, 0.05)
        if not (trackerConn and St.bfEnabled) then updateTracker(target) end
        St.Face.claim("blackflash", 0.09)
        St.bfChainUntil = os.clock() + 0.25
        local now = os.clock()
        if isKnockedBack(target) then
            if willFlash and plan.armed and bfInsideHardLeash(target) then
                -- Normal first-hit recoil stops chasing, NOT the pending second tap.
                finish("target_recoil"); return
            end
            bfCancel(); return
        end
        if willFlash and not plan.armed and now - plan.t0 >= plan.firstDelay then
            plan.armed = bfFireCharged(eff, target, route, plan)
            if not plan.armed then bfCancel(); return end
        end
        if noBF and now - plan.t0 >= DASH_DURATION * EARLY_MIN_FRAC then
            local gap = liveBackInfo(target)
            if gap <= CFG.ARRIVE_DIST and isPosBehind(target, root.Position) then finish("arrived"); return end
        end
        if not willFlash and now - plan.t0 >= DASH_MAX_DURATION then finish("timeout"); return end
        if willFlash and now >= plan.impactAt + plan.hold and not Runtime.reinputPending then finish("sync_complete"); return end
        if now - plan.t0 > 1.25 then bfCancel(); return end -- bounded stuck/route timeout
        if mode ~= "flash_static" then
            local snap = snapshot(now, dt)
            local desired = desiredAt(snap, 0)
            local nextDesired = desiredAt(snap, dt)
            local feedforward = (nextDesired - desired) / dt
            local command = feedforward + (desired - horizontal(root.Position)) * CFG.POSITION_GAIN
            local cap = (mode == "flash_glue" or snap.progress >= 1) and CFG.GLUE_SPEED or MAX_SPEED
            if command.Magnitude > cap then command = command.Unit * cap end
            smoothVelocity = smoothVelocity:Lerp(command, damp(VEL_SMOOTH_K, dt))
            if smoothVelocity.Magnitude > cap then smoothVelocity = smoothVelocity.Unit * cap end
            local allowed = wallLimited(root.Position, smoothVelocity * dt, plan.params) / dt
            root.AssemblyLinearVelocity = Vector3.new(allowed.X, root.AssemblyLinearVelocity.Y, allowed.Z)
        end
        bfFace(root, part, dt)
        if CFG.CAM_STEER then steerCameraYaw(part.Position, dt) end
    end)
    return true
end
local function startBlackFlash(target) return executeCurvedDash(target) end


    -- == HUB INTERFACE (preserves original bfStartAll/bfStopAll/bfTriggerDash) ==
    local function bfTriggerDash_inner()
        if not St.bfEnabled then return end
        if isDashing or bfActive or bfBusy then return end
        if bfSelfBlocked() then return end
        local target, dist = findTarget()
        if not target then return end
        if isKnockedBack(target) then return end
        if alreadyAtBack(target) then startBlackFlash(target); return end
        local now = tick()
        if now - lastDashTime < DASH_COOLDOWN then return end
        lastDashTime = now
        executeCurvedDash(target)
    end
    local function bfStartAll()
        if trackerConn then pcall(function() trackerConn:Disconnect() end); trackerConn = nil end
        -- continuous lightweight tracker so velocity/prediction stay warm for instant G presses
        trackerConn = RunService.Heartbeat:Connect(function()
            if not St.bfEnabled then return end
            local target = Runtime.target or findTarget()
            if Runtime.target and not bfValid(Runtime.target, Runtime.generation) then bfCancel(); return end
            updateTracker(target)
            if Runtime.target and (isDashing or Runtime.correction or bfActive or bfBusy) then
                St.Face.claim("blackflash", 0.09)
            end
        end)
    end
    local function bfStopAll()
        St.bfEnabled = false
        if trackerConn then trackerConn:Disconnect(); trackerConn = nil end
        bfCancel()
        trackedModel = nil
    end
    player.CharacterRemoving:Connect(function() bfCancel(); trackedModel = nil end)
    player.CharacterAdded:Connect(function() bfCancel(); trackedModel = nil end)

    -- live tuning bridge for the Fluent BF sliders/toggles
    _G.NH_bfSet = function(key, v)
        if     key == "DETECT_RANGE" then DASH_RANGE = v
        elseif key == "CURVE"        then CFG.CURVE_BOW = v
        elseif key == "BACKGAP"      then CFG.BACK_DISTANCE = v
        elseif key == "PREDICT"      then PREDICT_LEAD = v
        elseif key == "CAM_SENS"     then CFG.CAM_SENS = v
        elseif key == "BF_TIMING"    then BF.TIMING = math.clamp(tonumber(v) or BF.TIMING, 0.15, 0.4)
        elseif key == "SPEEDCAP"     then MAX_SPEED = v
        elseif key == "ANTIFLING"    then CFG.AWAY_KNOCKBACK_SPEED = v
        elseif key == "CAM_STEER"    then CFG.CAM_STEER = v and true or false
        elseif key == "AUTO_BF"      then CFG.AUTO_BLACKFLASH = v and true or false
        elseif key == "SMART"        then CFG.SMART_PREDICT = v and true or false
        elseif key == "NET_LEAD"     then CFG.NET_LEAD = math.clamp(tonumber(v) or 1, 0, 2)
        elseif key == "CHAIN"        then CHAIN_CORRECT_ENABLED = v and true or false
        end
    end

    -- Block-break hook: curved dash BEHIND target with NO black flash, then run
    -- onArrive() (used by Auto Block Break to M1 a blocker's exposed back).
    _G.NH_dashBehind = function(target, onArrive)
        if not target then return false end
        if isDashing or bfActive or bfBusy then return false end
        if bfSelfBlocked() then return false end
        if isKnockedBack(target) then return false end
        -- Shared motion-only path: no BF inputs and no callback on leash/timeout.
        updateTracker(target)
        return executeCurvedDash(target, { noBF = true, onArrive = onArrive })
    end

    -- Manual combat dash: locked target wins when it is live and within ten
    -- studs; otherwise use the same nearest-target selector as Black Flash.
    -- It calls the shared no-BF curved dash, so M1s and moves remain usable
    -- throughout the dash instead of being queued or simulated for the player.
    local manualDashLast = 0
    _G.NH_triggerDashBehindTarget = function()
        if not St.dashBehindTargetEnabled then return false end
        local character = getCharacter()
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return false end

        local target = St.lockOnTarget
        if type(target) == "table" and target.Char then target = target.Char end
        if typeof(target) == "Instance" then
            local targetHum = target:FindFirstChildOfClass("Humanoid")
            local targetRoot = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
            if target == character or not targetHum or targetHum.Health <= 0 or not targetRoot
                or (targetRoot.Position - root.Position).Magnitude > 10 then
                target = nil
            end
        else
            target = nil
        end
        if not target then target = findTarget(10) end
        if not target then
            notify("Dash Behind Target", "No live target within 10 studs.", 2)
            return false
        end

        local now = os.clock()
        if now - manualDashLast < 0.35 then return false end
        local ok = _G.NH_dashBehind(target)
        if ok then manualDashLast = now end
        return ok
    end

    St.bfNativeBypass = function(eventName)
        local edge = eventName == "Activated" and "Activated"
            or eventName == "Deactivated" and "Deactivated"
        if not edge then return false end
        local queue = St.bfNativeKeyEvents and St.bfNativeKeyEvents[edge]
        if not queue then return false end
        local now = os.clock()
        while queue[1] and queue[1].expires <= now do table.remove(queue, 1) end
        if queue[1] then table.remove(queue, 1); return true end
        return false
    end
    St.bfIsSyntheticKey = function(key)
        return key == BF.MOVE_KEY and (St.bfSyntheticInput == true
            or os.clock() < (St.bfSyntheticUntil or 0))
    end
    _G.bfStartAll = bfStartAll
    _G.bfStopAll = bfStopAll
    _G.bfTriggerDash = bfTriggerDash_inner
    end)()
end
local bfStartAll = _G.bfStartAll; local bfStopAll = _G.bfStopAll; local bfTriggerDash = _G.bfTriggerDash

-- ============================================================
-- HARUTA AUTO BACKSTAB  (dash behind + fire Backstab move)
--   Uses the BF chain's curved dash engine to get behind the
--   target, then fires Haruta's 2nd move (Backstab). Works on
--   PC (keybind) and mobile (float button). Safety: won't dash
--   if target is ragdolled / knocked back / self is stunned.
--   Requires Haruta with sword equipped.
-- ============================================================
do
    local BS_RANGE      = 16
    local BS_DEBOUNCE   = 0.5
    local bsBusy        = false
    local bsDebounce    = 0

    local function harutaBsSelfBlocked()
        local ch  = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not ch or not hum or not hrp or hum.Health <= 0 then return true end
        if (ch:GetAttribute("Ragdoll") or 0) ~= 0 then return true end
        if ch:FindFirstChild("Stun") or ch:FindFirstChild("Knockback") or ch:FindFirstChild("Hold")
            or ch:FindFirstChild("Grab") or ch:FindFirstChild("Grabbed") or ch:FindFirstChild("Carry") then
            return true
        end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
            or st == Enum.HumanoidStateType.PlatformStanding then return true end
        return false
    end

    local function isTargetRagdolled(target)
        if not target then return true end
        if (target:GetAttribute("Ragdoll") or 0) ~= 0 then return true end
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hum then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then return true end
        end
        return false
    end

    local function harutaBsFindTarget()
        local ch  = LocalPlayer.Character
        if not ch then return nil end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local closest, closestDist = nil, BS_RANGE + 1
        local folder = Workspace:FindFirstChild("Characters")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= ch then
                    local hum  = obj:FindFirstChild("Humanoid")
                    local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                    if hum and part and hum.Health > 0 and not isTargetRagdolled(obj) then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist <= BS_RANGE and dist < closestDist then
                            closestDist, closest = dist, obj
                        end
                    end
                end
            end
        end
        return closest, closestDist
    end

    local function harutaBsFireMove()
        local ch = LocalPlayer.Character
        if not ch then return false end
    if mobile then
        local tc = nhGetToolController()
        if tc then
            local useKey = _G.NH_origUseKey or tc.UseKey
            pcall(function() useKey(tc, 2, "Activated") end)
            task.wait(0.02)
            pcall(function() useKey(tc, 2, "Deactivated") end)
            return true
        end
    else
        St.MarkSyntheticKey(Enum.KeyCode.Two, 0.3)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
        return true
    end
        return false
    end

    local function triggerHarutaBackstab()
        if bsBusy then notify("Haruta BS", "Busy - wait", 2); return end

        local ch = LocalPlayer.Character
        if not ch then notify("Haruta BS", "No character", 2); return end

        local mv = ch:GetAttribute("Moveset")
        if mv ~= "Haruta" then notify("Haruta BS", "Not Haruta (have: "..tostring(mv)..")", 2); return end

        local assets = ch:FindFirstChild("SetAssets")
        if not (assets and assets:FindFirstChild("HarutaSword")) then notify("Haruta BS", "No sword equipped", 2); return end

        if harutaBsSelfBlocked() then notify("Haruta BS", "Stunned / ragdolled", 2); return end

        local target = harutaBsFindTarget()
        if not target then notify("Haruta BS", "No target in "..BS_RANGE.." studs", 2); return end

        if tick() - bsDebounce < BS_DEBOUNCE then return end
        bsDebounce = tick()
        bsBusy = true

        local targetRef = target
        local charRef = ch

        local function onArrive()
            if not targetRef or not targetRef.Parent then bsBusy = false; return end
            if isTargetRagdolled(targetRef) then bsBusy = false; return end
            local myHRP = charRef and charRef:FindFirstChild("HumanoidRootPart")
            local tHRP  = targetRef:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                local fd = (tHRP.Position - myHRP.Position) * Vector3.new(1, 0, 1)
                if fd.Magnitude > 0.1 then
                    myHRP.CFrame = CFrame.lookAt(myHRP.Position, myHRP.Position + fd.Unit)
                end
            end
            task.wait(0.08)
            harutaBsFireMove()
            task.delay(0.4, function() bsBusy = false end)
        end

        local ok = false
        if _G.NH_dashBehind then
            ok = _G.NH_dashBehind(targetRef, onArrive)
        else
            notify("Haruta BS", "Dash engine not loaded", 2)
        end

        if ok == false then
            notify("Haruta BS", "Dash failed (bf busy / self blocked)", 2)
            bsBusy = false
        end
        task.delay(2.5, function() bsBusy = false end)
    end

    _G.NH_triggerHarutaBackstab = triggerHarutaBackstab
end

-- ============================================================
-- MOBILE MOVE-KEY INTERCEPT (2nd and 3rd ability buttons)
-- On mobile, the game's 2nd/3rd move buttons fire ToolController:UseKey(n, "Activated").
-- When Haruta Backstab or BF Chain are enabled on mobile, we intercept UseKey for
-- slots 2 and 3 respectively. If the right character is equipped, we trigger our
-- feature instead. If the wrong character is equipped, we pass through normally with
-- NO notification (notification only comes from the dedicated UI buttons).
-- ============================================================
do
    task.spawn(function()
        -- Hook native slot 3 on every platform; keep slot-2 overrides mobile-only.
        task.wait(1)
        local ok, Knit = pcall(function() return require(ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit")) end)
        if not ok or not Knit then return end
        local tc = nil
        pcall(function() tc = Knit.GetController("ToolController") end)
        if not tc or type(tc.UseKey) ~= "function" then return end

        local origUseKey = tc.UseKey
        _G.NH_origUseKey = origUseKey
        _G.NH_bfUseKeyOwner = tc
        local _hookActive = false
        St.bfInputHookReady = true
        tc.UseKey = function(self, slot, eventName, ...)
            if slot == 3 and St.bfNativeBypass and St.bfNativeBypass(eventName) then
                return origUseKey(self, slot, eventName, ...)
            end
            -- Guard: if we're already inside our hook (e.g. BF system calling UseKey internally), pass through
            if St.bfSyntheticInput or _hookActive then return origUseKey(self, slot, eventName, ...) end
            -- Intercept slot 2 (Haruta Backstab OR Auto Shut Up for Charles/Mangaka)
            if mobile and slot == 2 and eventName == "Activated" then
                local ch = LocalPlayer.Character
                local mv = ch and ch:GetAttribute("Moveset")
                if St.harutaBackstabEnabled and mv == "Haruta" then
                    -- Haruta equipped: trigger backstab, suppress normal move
                    task.spawn(function()
                        local assets = ch and ch:FindFirstChild("SetAssets")
                        if not (assets and assets:FindFirstChild("HarutaSword")) then
                            notify("Haruta Backstab", "Need sword in hand to backstab.", 3)
                            return
                        end
                        if _G.NH_triggerHarutaBackstab then _G.NH_triggerHarutaBackstab() end
                    end)
                    return -- suppress the default slot-2 fire
                elseif St.autoShutUpEnabled and mv ~= "Haruta" then
                    -- Charles / Mangaka (or any non-Haruta): pre-rotate so back faces
                    -- the correct direction BEFORE the move fires. We do NOT suppress
                    -- the move -- the game still fires it normally, we just face right first.
                    -- Run in a task.spawn so the rotate is truly instant and doesn't block
                    -- the UseKey call from returning on time.
                    task.spawn(function()
                        if _G.NH_shutUpRotate then _G.NH_shutUpRotate() end
                    end)
                    -- fall through: return origUseKey below so the move fires as normal
                end
            end

            -- Intercept slot 3 (BF Chain), except when Auto Earthquake owns Mahoraga's
            -- slot. The old character-agnostic interception swallowed Earthquake's native
            -- Activated input on mobile, so the move literally never began.
            if slot == 3 and St.bfEnabled then
                local ch = LocalPlayer.Character
                local eq = rawget(_G, "NH_AutoEarthquake")
                local earthquakeOwnsSlot = St.autoEarthquakeEnabled
                    and type(eq) == "table" and type(eq.IsEarthquakeSlot) == "function"
                    and eq.IsEarthquakeSlot(ch, slot)
                if not earthquakeOwnsSlot then
                    if eventName == "Activated" then bfTriggerDash() end
                    return -- suppress native charge AND release; BF uses origUseKey directly
                end
            end

            return origUseKey(self, slot, eventName, ...)
        end
    end)
end

-- ============================================================
-- SWEEP OVERLAY GUI
-- ============================================================
local OL={W=244,TITLE=32,ROW_H=32}
local overlayGui,overlayFrame,overlayCountLbl=nil,nil,nil
local overlayRows={}
local overlayUpdateConn=nil
local overlaySavedPos=nil

local function destroyOverlay()
    if overlayUpdateConn then overlayUpdateConn:Disconnect(); overlayUpdateConn=nil end
    ovStopSpectate()
    local pg=LocalPlayer:FindFirstChild("PlayerGui")
    if pg then for _,v in ipairs(pg:GetChildren()) do if v.Name=="GojoDomainOverlay" then pcall(function() v:Destroy() end) end end end
    overlayGui=nil; overlayFrame=nil; overlayCountLbl=nil; overlayRows={}
end

local function ovRebuild()
    if not overlayFrame or not overlayFrame.Parent then return end
    local scroll=overlayFrame:FindFirstChild("OvScroll"); if not scroll then return end
    if _ovSpectate then
        local sp=Players:FindFirstChild(_ovSpectate)
        if not sp or not sp.Character then ovStopSpectate() end
    end
    for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA("Frame") then pcall(function() ch:Destroy() end) end end
    overlayRows={}
    local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targets=myHRP and getValidTargets(myHRP) or {}
    local pc=0
    for _,t in ipairs(targets) do if Players:FindFirstChild(t.name) then pc=pc+1 end end
    if overlayCountLbl then overlayCountLbl.Text="TARGETS "..#targets.."  ("..pc.." players)" end
    for i,tgt in ipairs(targets) do
        local n=tgt.name; local isP=Players:FindFirstChild(n)~=nil; local isWL=St.whitelist[n]~=nil; local isSpy=_ovSpectate==n; local hp=0
        if tgt.Humanoid and tgt.Humanoid.Parent and tgt.Humanoid.MaxHealth and tgt.Humanoid.MaxHealth>0 then hp=math.floor(tgt.Humanoid.Health/tgt.Humanoid.MaxHealth*100) end
        local rf=Instance.new("Frame"); rf.Name="OvRow_"..n; rf.Size=UDim2.new(1,-4,0,OL.ROW_H-2); rf.BackgroundColor3=isWL and Color3.fromRGB(26,26,4) or (isP and Color3.fromRGB(12,4,4) or Color3.fromRGB(4,10,4)); rf.BorderSizePixel=0; rf.LayoutOrder=i; rf.ZIndex=3; rf.Parent=scroll
        Instance.new("UICorner",rf).CornerRadius=UDim.new(0,6)
        makeStroke(rf, isWL and Color3.fromRGB(180,180,40) or (isP and Color3.fromRGB(80,130,255) or Color3.fromRGB(80,200,80)), 1, 0.55)
        local nb=Instance.new("TextButton"); nb.Size=UDim2.new(1,-64,1,0); nb.Position=UDim2.new(0,6,0,0); nb.BackgroundTransparency=1; nb.Text=(isP and "[P] " or "[N] ")..n.." "..hp.."%"..(isWL and " ✓" or ""); nb.TextColor3=isWL and Color3.fromRGB(200,200,60) or Color3.fromRGB(230,200,200); nb.TextSize=9; nb.Font=Enum.Font.GothamBold; nb.TextXAlignment=Enum.TextXAlignment.Left; nb.ZIndex=5; nb.Parent=rf
        local vb=Instance.new("TextButton"); vb.Size=UDim2.new(0,38,0,OL.ROW_H-10); vb.Position=UDim2.new(1,-42,0,4); vb.BackgroundColor3=isSpy and Color3.fromRGB(20,20,60) or Color3.fromRGB(10,10,28); vb.Text=isSpy and "■ Stop" or "▶ View"; vb.TextColor3=isSpy and Color3.fromRGB(160,160,255) or Color3.fromRGB(100,100,200); vb.TextSize=8; vb.Font=Enum.Font.GothamBold; vb.BorderSizePixel=0; vb.ZIndex=5; vb.Parent=rf; Instance.new("UICorner",vb).CornerRadius=UDim.new(0,5)
        local cn=n
        nb.MouseButton1Click:Connect(function()
            if St.whitelist[cn] then St.whitelist[cn]=nil; notify("Whitelist","Removed: "..cn,2) else St.whitelist[cn]=true; notify("Whitelist","Added: "..cn,2) end
        end)
        vb.MouseButton1Click:Connect(function()
            if _ovSpectate==cn then ovStopSpectate(); notify("Spectate","Stopped.",2)
            elseif isP then if ovStartSpectate(cn) then notify("Spectate","Spectating "..cn,2) else notify("Spectate","Target unavailable.",2) end
            else notify("Spectate","Can only spectate players.",2) end
        end)
        overlayRows[n]={frame=rf}
    end
end

local function buildOverlay()
    destroyOverlay()
    local screen=Camera and Camera.ViewportSize or Vector2.new(800,600)
    overlayGui=Instance.new("ScreenGui"); overlayGui.Name="GojoDomainOverlay"; overlayGui.ResetOnSpawn=false; overlayGui.IgnoreGuiInset=true; overlayGui.DisplayOrder=1000; overlayGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; overlayGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
    local cx=math.clamp(overlaySavedPos and overlaySavedPos.X or screen.X-OL.W-14,0,screen.X-OL.W-4)
    local cy=math.clamp(overlaySavedPos and overlaySavedPos.Y or 90,0,screen.Y-200)
    overlayFrame=Instance.new("Frame"); overlayFrame.Size=UDim2.fromOffset(OL.W,200); overlayFrame.Position=UDim2.fromOffset(cx,cy); overlayFrame.BackgroundColor3=Color3.fromRGB(10,4,4); overlayFrame.BorderSizePixel=0; overlayFrame.ClipsDescendants=true; overlayFrame.Active=true; overlayFrame.Parent=overlayGui
    Instance.new("UICorner",overlayFrame).CornerRadius=UDim.new(0,12)
    makeStroke(overlayFrame,Color3.fromRGB(160,10,10),1.5,0.2)
    local titleBar=Instance.new("Frame"); titleBar.Size=UDim2.new(1,0,0,OL.TITLE); titleBar.BackgroundColor3=Color3.fromRGB(18,5,5); titleBar.BorderSizePixel=0; titleBar.ZIndex=2; titleBar.Parent=overlayFrame
    overlayCountLbl=Instance.new("TextLabel"); overlayCountLbl.Size=UDim2.new(1,-8,1,0); overlayCountLbl.Position=UDim2.new(0,8,0,0); overlayCountLbl.BackgroundTransparency=1; overlayCountLbl.Text="TARGETS 0  (0 players)"; overlayCountLbl.TextColor3=Color3.fromRGB(200,20,20); overlayCountLbl.TextSize=11; overlayCountLbl.Font=Enum.Font.GothamBold; overlayCountLbl.TextXAlignment=Enum.TextXAlignment.Left; overlayCountLbl.ZIndex=3; overlayCountLbl.Parent=titleBar
    local dragging=false; local dragOr=Vector2.zero; local frOr=Vector2.zero
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true; dragOr=Vector2.new(inp.Position.X,inp.Position.Y); frOr=Vector2.new(overlayFrame.Position.X.Offset,overlayFrame.Position.Y.Offset) end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and overlayFrame and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=Vector2.new(inp.Position.X,inp.Position.Y)-dragOr; local sc2=Camera and Camera.ViewportSize or Vector2.new(800,600)
            overlayFrame.Position=UDim2.fromOffset(math.clamp(frOr.X+d.X,0,math.max(0,sc2.X-OL.W-4)), math.clamp(frOr.Y+d.Y,0,math.max(0,sc2.Y-100)))
            overlaySavedPos=Vector2.new(overlayFrame.Position.X.Offset,overlayFrame.Position.Y.Offset)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    local scroll=Instance.new("ScrollingFrame"); scroll.Name="OvScroll"; scroll.Size=UDim2.new(1,-4,1,-OL.TITLE-2); scroll.Position=UDim2.new(0,2,0,OL.TITLE+1); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=Color3.fromRGB(160,10,10); scroll.BorderSizePixel=0; scroll.ScrollingDirection=Enum.ScrollingDirection.Y; scroll.ZIndex=2; scroll.Parent=overlayFrame
    local rl=Instance.new("UIListLayout"); rl.Padding=UDim.new(0,3); rl.SortOrder=Enum.SortOrder.LayoutOrder; rl.Parent=scroll
    rl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentH = rl.AbsoluteContentSize.Y + 6; local screen2  = Camera and Camera.ViewportSize or Vector2.new(800, 600)
        local maxH = screen2.Y - overlayFrame.AbsolutePosition.Y - 20; local newH = math.max(math.min(OL.TITLE + contentH + 10, maxH), OL.TITLE + 40)
        overlayFrame.Size = UDim2.fromOffset(OL.W, newH); scroll.CanvasSize = UDim2.fromOffset(0, contentH)
    end)
    local _lastRebuild=0
    overlayUpdateConn=RunService.Heartbeat:Connect(function() local now=tick() if now-_lastRebuild<1.0 then return end _lastRebuild=now; ovRebuild() end)
    ovRebuild()
end

-- ============================================================
-- FLUENT UI
-- ============================================================
-- Vendored dependencies: the hub mirrors serve them, github.com does not.
local Fluent = jjs.require("vendor/fluent.lua", "fluent")
local SaveManager = jjs.require("vendor/save-manager.lua", "save-manager")
local InterfaceManager = jjs.require("vendor/interface-manager.lua", "interface-manager")
if not (Fluent and SaveManager and InterfaceManager) then
    return false
end

local Window = Fluent:CreateWindow({
    Title = "Nigga Hub", SubTitle = "Ultimate Edition", TabWidth = 130,
    Size = mobile and UDim2.fromOffset(math.clamp(Camera.ViewportSize.X * 0.92, 300, 540), math.clamp(Camera.ViewportSize.Y * 0.80, 300, 460)) or UDim2.fromOffset(600, 480),
    -- Fluent's built-in minimize state can desync after the first hide, which
    -- makes a second Ctrl press fail to reopen the hub. Disable that listener
    -- and route every minimize path through the visibility manager below.
    Acrylic = not mobile, Theme = "Darker", MinimizeKey = Enum.KeyCode.Unknown
})

-- One authoritative hub-visibility path for the title-bar button, PC Ctrl, and
-- the mobile green dot. Toggle from the REAL Root.Visible value each time, so
-- even an outside visibility change cannot leave the next press inverted.
local HubUI = {Visible = true, LastToggle = 0}

local function getHubRoot()
    if Window and typeof(Window) == "table" then
        local ok, root = pcall(function() return Window.Root end)
        if ok and typeof(root) == "Instance" and root:IsA("GuiObject") then
            return root
        end
    end
    return nil
end

-- Fluent's AcrylicPaint frame is the real backdrop. Keep its near-black glass
-- tint, then move a small layered oval glow inside it (not a full-window wipe).
_G.NH_PremiumTheme = (function()
    local currentTween = nil
    local currentBlob = nil
    local currentSweepTween = nil
    local currentSweep = nil

    local function styleSoftOval(blob, name, size, tint, backgroundTransparency, rotation, shoulderTransparency, centerTransparency, position)
        local shape = blob:FindFirstChild(name)
        if not (shape and shape:IsA("Frame")) then
            if shape then shape:Destroy() end
            shape = Instance.new("Frame")
            shape.Name = name
            shape.AnchorPoint = Vector2.new(0.5, 0.5)
            shape.Position = position or UDim2.fromScale(0.5, 0.5)
            shape.BorderSizePixel = 0
            shape.Active = false
            shape.Selectable = false
            shape.ZIndex = 1
            shape.Parent = blob
        end
        shape.Size = size
        shape.BackgroundColor3 = tint
        shape.BackgroundTransparency = backgroundTransparency
        shape.AnchorPoint = Vector2.new(0.5, 0.5)
        shape.Position = position or UDim2.fromScale(0.5, 0.5)

        local corner = shape:FindFirstChildOfClass("UICorner")
        if not corner then
            corner = Instance.new("UICorner")
            corner.Parent = shape
        end
        corner.CornerRadius = UDim.new(1, 0)

        local gradient = shape:FindFirstChild("NHPremiumBlobGradient")
        if not (gradient and gradient:IsA("UIGradient")) then
            if gradient then gradient:Destroy() end
            gradient = Instance.new("UIGradient")
            gradient.Name = "NHPremiumBlobGradient"
            gradient.Parent = shape
        end
        gradient.Enabled = true
        gradient.Rotation = rotation
        gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        -- Longer falloff shoulders feather the edge instead of making a crisp band.
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.00, 1.00),
            NumberSequenceKeypoint.new(0.08, 0.995),
            NumberSequenceKeypoint.new(0.20, shoulderTransparency),
            NumberSequenceKeypoint.new(0.38, centerTransparency),
            NumberSequenceKeypoint.new(0.50, centerTransparency),
            NumberSequenceKeypoint.new(0.62, centerTransparency),
            NumberSequenceKeypoint.new(0.80, shoulderTransparency),
            NumberSequenceKeypoint.new(0.92, 0.995),
            NumberSequenceKeypoint.new(1.00, 1.00),
        })
    end

    local function Apply()
        pcall(function() Fluent:SetTheme("Darker") end)

        local paintFrame = Window and Window.AcrylicPaint and Window.AcrylicPaint.Frame
        if not (paintFrame and paintFrame:IsA("GuiObject")) then
            return false, "Fluent AcrylicPaint frame is unavailable"
        end

        local ok, err = pcall(function()
            -- Remove both earlier full-frame wipe gradients if this is re-run.
            local oldFloat = paintFrame:FindFirstChild("NHPremiumFloatGradient", true)
            if oldFloat and oldFloat:IsA("UIGradient") then oldFloat:Destroy() end

            local layer = paintFrame:FindFirstChild("NHPremiumFloatingGradient")
            if not (layer and layer:IsA("Frame")) then
                layer = Instance.new("Frame")
                layer.Name = "NHPremiumFloatingGradient"
                layer.Parent = paintFrame
                local corner = Instance.new("UICorner")
                corner.Name = "NHPremiumGradientCorner"
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = layer
            end
            local oldWipe = layer:FindFirstChild("NHPremiumGradient", true)
            if oldWipe and oldWipe:IsA("UIGradient") then oldWipe:Destroy() end

            layer.AnchorPoint = Vector2.new(0, 0)
            layer.Position = UDim2.fromScale(0, 0)
            layer.Size = UDim2.fromScale(1, 1)
            layer.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
            layer.BackgroundTransparency = 0.62
            layer.BorderSizePixel = 0
            layer.Active = false
            layer.Selectable = false
            layer.ClipsDescendants = true
            layer.Visible = true
            layer.ZIndex = 1

            local blob = layer:FindFirstChild("NHPremiumBlob")
            if not (blob and blob:IsA("Frame")) then
                blob = Instance.new("Frame")
                blob.Name = "NHPremiumBlob"
                blob.BackgroundTransparency = 1
                blob.BorderSizePixel = 0
                blob.AnchorPoint = Vector2.new(0.5, 0.5)
                blob.Size = UDim2.fromScale(0.94, 0.78)
                blob.Position = UDim2.fromScale(0.12, 0.26)
                blob.Active = false
                blob.Selectable = false
                blob.ZIndex = 1
                blob.Parent = layer
            end
            blob.BackgroundTransparency = 1
            blob.Size = UDim2.fromScale(0.94, 0.78)
            blob.AnchorPoint = Vector2.new(0.5, 0.5)
            blob.Visible = true

            -- Remove the earlier pale glow if this script is reapplied in-place.
            for _, oldName in ipairs({"GlowHorizontal", "GlowVertical", "GlowCore"}) do
                local oldGlow = blob:FindFirstChild(oldName)
                if oldGlow then oldGlow:Destroy() end
            end

            -- Broad, feathered blue and violet lobes overlap into a displaced cloud.
            -- The outer layers are faint; the inner layers add color without a hard core.
            styleSoftOval(blob, "BlueHaloWide", UDim2.fromScale(0.92, 0.82), Color3.fromRGB(79, 126, 255), 0.68, 0, 0.985, 0.84, UDim2.fromScale(0.35, 0.46))
            styleSoftOval(blob, "VioletHaloWide", UDim2.fromScale(0.92, 0.82), Color3.fromRGB(151, 105, 244), 0.68, 0, 0.985, 0.84, UDim2.fromScale(0.65, 0.54))
            styleSoftOval(blob, "BlueHaloTall", UDim2.fromScale(0.76, 0.98), Color3.fromRGB(92, 142, 255), 0.72, 90, 0.985, 0.86, UDim2.fromScale(0.35, 0.46))
            styleSoftOval(blob, "VioletHaloTall", UDim2.fromScale(0.76, 0.98), Color3.fromRGB(166, 122, 255), 0.72, 90, 0.985, 0.86, UDim2.fromScale(0.65, 0.54))
            styleSoftOval(blob, "BlueSoftMid", UDim2.fromScale(0.72, 0.72), Color3.fromRGB(77, 126, 255), 0.59, 0, 0.97, 0.76, UDim2.fromScale(0.39, 0.46))
            styleSoftOval(blob, "VioletSoftMid", UDim2.fromScale(0.72, 0.72), Color3.fromRGB(151, 100, 245), 0.59, 0, 0.97, 0.76, UDim2.fromScale(0.61, 0.54))
            styleSoftOval(blob, "BlueSoftCore", UDim2.fromScale(0.48, 0.56), Color3.fromRGB(112, 161, 255), 0.66, 90, 0.97, 0.78, UDim2.fromScale(0.40, 0.45))
            styleSoftOval(blob, "VioletSoftCore", UDim2.fromScale(0.48, 0.56), Color3.fromRGB(183, 139, 255), 0.66, 90, 0.97, 0.78, UDim2.fromScale(0.60, 0.55))

            -- A low-contrast silver-blue sweep adds a restrained sheen without washing out the blob.
            local sweep = layer:FindFirstChild("NHPremiumBackdropSweep")
            if not (sweep and sweep:IsA("Frame")) then
                if sweep then sweep:Destroy() end
                sweep = Instance.new("Frame")
                sweep.Name = "NHPremiumBackdropSweep"
                sweep.AnchorPoint = Vector2.new(0.5, 0.5)
                sweep.Parent = layer
            end
            sweep.Size = UDim2.fromScale(0.28, 1.20)
            sweep.BackgroundColor3 = Color3.fromRGB(222, 230, 250)
            sweep.BackgroundTransparency = 0.74
            sweep.BorderSizePixel = 0
            sweep.Active = false
            sweep.Selectable = false
            sweep.ClipsDescendants = true
            sweep.Visible = true
            sweep.Rotation = 12
            sweep.ZIndex = 2

            local sweepCorner = sweep:FindFirstChildOfClass("UICorner")
            if not sweepCorner then
                sweepCorner = Instance.new("UICorner")
                sweepCorner.Parent = sweep
            end
            sweepCorner.CornerRadius = UDim.new(0, 8)

            local sweepGradient = sweep:FindFirstChild("NHPremiumBackdropSweepGradient")
            if not (sweepGradient and sweepGradient:IsA("UIGradient")) then
                if sweepGradient then sweepGradient:Destroy() end
                sweepGradient = Instance.new("UIGradient")
                sweepGradient.Name = "NHPremiumBackdropSweepGradient"
                sweepGradient.Parent = sweep
            end
            sweepGradient.Enabled = true
            sweepGradient.Rotation = 0
            sweepGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            sweepGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.00, 1.00),
                NumberSequenceKeypoint.new(0.24, 0.995),
                NumberSequenceKeypoint.new(0.38, 0.96),
                NumberSequenceKeypoint.new(0.46, 0.80),
                NumberSequenceKeypoint.new(0.50, 0.64),
                NumberSequenceKeypoint.new(0.54, 0.80),
                NumberSequenceKeypoint.new(0.62, 0.96),
                NumberSequenceKeypoint.new(0.76, 0.995),
                NumberSequenceKeypoint.new(1.00, 1.00),
            })

            if currentSweep ~= sweep then
                if currentSweepTween then pcall(function() currentSweepTween:Cancel() end) end
                sweep.Position = UDim2.fromScale(-0.20, 0.40)
                currentSweep = sweep
                currentSweepTween = TweenService:Create(
                    sweep,
                    TweenInfo.new(24, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                    {Position=UDim2.fromScale(1.20, 0.60)}
                )
                currentSweepTween:Play()
            end

            if currentBlob ~= blob then
                if currentTween then pcall(function() currentTween:Cancel() end) end
                -- Travel diagonally across most of the backdrop, with a gentle organic tilt.
                blob.Position = UDim2.fromScale(0.12, 0.26)
                blob.Rotation = -9
                currentBlob = blob
                currentTween = TweenService:Create(
                    blob,
                    TweenInfo.new(34, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                    {Position=UDim2.fromScale(0.88, 0.74), Rotation=9}
                )
                currentTween:Play()
            end
        end)

        if not ok then warn("[NH Theme] Floating glow failed: " .. tostring(err)) end
        return ok, err
    end

    return {Apply=Apply}
end)()
local premiumApplied, premiumError = _G.NH_PremiumTheme.Apply()
if not premiumApplied then
    warn("[NH Theme] " .. tostring(premiumError or "Could not apply Fluent's premium backdrop."))
end

function HubUI.SetVisible(visible)
    HubUI.Visible = visible and true or false
    local root = getHubRoot()
    if root then
        pcall(function() root.Visible = HubUI.Visible end)
    end
    pcall(function()
        if Window then Window.Minimized = not HubUI.Visible end
    end)
end

function HubUI.Toggle()
    local now = os.clock()
    if now - HubUI.LastToggle < 0.12 then return end
    HubUI.LastToggle = now

    local root = getHubRoot()
    local currentlyVisible = HubUI.Visible
    if root then
        currentlyVisible = root.Visible
    elseif Window then
        currentlyVisible = not Window.Minimized
    end
    HubUI.SetVisible(not currentlyVisible)
end

pcall(function()
    if Window then
        Window.Minimized = false
        Window.Minimize = function()
            -- Fluent's Minimize Bind (Left Ctrl by default) routes here too: choosing a key,
            -- or holding Left Ctrl to descend while flying, must not hide the hub.
            if St.KeyBinds and St.KeyBinds.IsPicking() then return end
            if St.flyActive and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                if St.KeyBinds then St.KeyBinds.FlyCtrlHint() end
                return
            end
            HubUI.Toggle()
        end
    end
end)

-- Do not gate this on gameProcessedEvent: Ctrl must always be able to reopen a
-- hidden hub. Supporting either Ctrl key also avoids keyboard-layout quirks.
UserInputService.InputBegan:Connect(function(input)
    if mobile or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    -- Keep Ctrl from hiding the hub while the global search TextBox is focused.
    if UserInputService:GetFocusedTextBox() then return end
    if St.KeyBinds and St.KeyBinds.IsPicking() then return end
    if input.KeyCode == Enum.KeyCode.LeftControl and St.flyActive then
        -- Left Ctrl is Fly's descend key; Right Ctrl still hides/shows the hub.
        if St.KeyBinds then St.KeyBinds.FlyCtrlHint() end
        return
    end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        HubUI.Toggle()
    end
end)

local Tabs = {}
Tabs.Combat = Window:AddTab({Title="Combat", Icon="sword"})
Tabs.Targets = Window:AddTab({Title="Targets", Icon="crosshair"})
Tabs.Movement = Window:AddTab({Title="Movement", Icon="navigation"})
Tabs.Characters = Window:AddTab({Title="Characters", Icon="user"})
Tabs.Extras = Window:AddTab({Title="Extras", Icon="star"})
Tabs.Items = Window:AddTab({Title="Items", Icon="package"})
Tabs.Combos = Window:AddTab({Title="Auto Combo", Icon="play"})
Tabs.Keybinds = Window:AddTab({Title="Keybinds", Icon="keyboard"})
Tabs.Settings = Window:AddTab({Title="Settings", Icon="settings"})

-- Build a lightweight feature index as the tabs/sections create their controls.
-- Search runs only after typing settles; it does not poll or scan the UI each frame.
_G.NH_FeatureSearch = (function()
    -- Pre-index controls once at load; normal queries use token/prefix buckets.
    local API = {Entries={}, WordIndex={}, PrefixIndex={}, Vocabulary={}}
    local vocabularySeen = {}
    local function indexEntry(index, key, entry)
        if key == "" then return end
        local bucket = index[key]
        if not bucket then bucket = {}; index[key] = bucket end
        table.insert(bucket, entry)
    end

    local tabOrder = {"Combat", "Targets", "Movement", "Characters", "Extras", "Items", "Combos", "Keybinds", "Settings"}
    local tabIndices = {}
    local seenEntries = {}
    local wrappedContainers = setmetatable({}, {__mode="k"})
    local trackedMethods = {
        AddToggle="Toggle", AddButton="Button", AddDropdown="Dropdown", AddSlider="Slider",
        AddInput="Input", AddKeybind="Keybind", AddColorpicker="Color", AddParagraph="Info",
        AddSection="Section",
    }

    for index, name in ipairs(tabOrder) do tabIndices[name] = index end

    local function splitIdentifier(value)
        value = tostring(value or "")
        value = value:gsub("([%l%d])(%u)", "%1 %2")
        value = value:gsub("(%u)(%u%l)", "%1 %2")
        value = value:gsub("_", " ")
        return value
    end

    local function normalize(value)
        local text = string.lower(tostring(value or ""))
        text = text:gsub("_", " ")
        text = text:gsub("[^%w%s]", " ")
        text = text:gsub("%s+", " ")
        return text
    end

    local function register(tabName, tabIndex, sectionName, kind, id, title, description, widget, targetFrame)
        if tabName == "Search" or title == "" then return end
        local unique = table.concat({tabName, kind, id, title, sectionName}, "|")
        if seenEntries[unique] then return end
        seenEntries[unique] = true

        local blob = table.concat({title, description, splitIdentifier(id), tabName, sectionName, kind}, " ")
        local normalized = normalize(blob)
        local words, wordSet = {}, {}
        for word in normalized:gmatch("%S+") do
            if not wordSet[word] then wordSet[word] = true; table.insert(words, word) end
        end
        local baseWordCount = #words
        for i = 1, baseWordCount - 1 do
            local pair = words[i] .. words[i + 1]
            if not wordSet[pair] then wordSet[pair] = true; table.insert(words, pair) end
        end

        local titleNormalized = normalize(title)
        local entry = {
            tabName=tabName, tabIndex=tabIndex, section=sectionName, kind=kind,
            id=id, title=title, description=description, widget=widget, frame=targetFrame,
            searchText=normalized, titleNormalized=titleNormalized,
            titleCompact=titleNormalized:gsub("%s+", ""),
            idNormalized=normalize(splitIdentifier(id)),
            words=words, wordSet=wordSet, prefixSet={},
            compact=normalized:gsub("%s+", ""), order=#API.Entries + 1,
        }
        table.insert(API.Entries, entry)
        for _, word in ipairs(words) do
            indexEntry(API.WordIndex, word, entry)
            if not vocabularySeen[word] then
                vocabularySeen[word] = true
                table.insert(API.Vocabulary, word)
            end
            for length = 2, math.min(#word, 3) do
                local prefix = word:sub(1, length)
                if not entry.prefixSet[prefix] then
                    entry.prefixSet[prefix] = true
                    indexEntry(API.PrefixIndex, prefix, entry)
                end
            end
        end
    end

    local function wrapContainer(container, tabName, tabIndex, initialSection, isTab)
        if type(container) ~= "table" or wrappedContainers[container] then return end
        wrappedContainers[container] = true
        local currentSection = initialSection or ""

        local function wrapMethod(methodName, kind, original)
            return function(self, ...)
                local first, second = ...
                -- Some Fluent options (notably Toggle) return a value/controller
                -- table with no Frame field. Capture the newly-added visual row from
                -- the actual parent container before calling the search registrar.
                local parentContainer = kind ~= "Section" and self and self.Container or nil
                local childrenBefore
                if typeof(parentContainer) == "Instance" then
                    childrenBefore = {}
                    for _, child in ipairs(parentContainer:GetChildren()) do childrenBefore[child] = true end
                end
                local widget = original(self, ...)
                local targetFrame
                if childrenBefore then
                    for _, child in ipairs(parentContainer:GetChildren()) do
                        if not childrenBefore[child] and child:IsA("GuiObject") then targetFrame = child end
                    end
                end
                if kind == "Section" then
                    local sectionTitle = type(first) == "string" and first or (type(first) == "table" and tostring(first.Title or "") or "")
                    if isTab then currentSection = sectionTitle end
                    wrapContainer(widget, tabName, tabIndex, sectionTitle, false)
                elseif tabName ~= "Search" then
                    local config = type(first) == "table" and first or (type(second) == "table" and second or {})
                    local id = (type(first) == "string" or type(first) == "number") and tostring(first) or ""
                    local title = tostring(config.Title or config.Label or id or "")
                    local description = tostring(config.Description or config.Content or "")
                    register(tabName, tabIndex, currentSection, kind, id, title, description, widget, targetFrame)
                end
                return widget
            end
        end

        for methodName, kind in pairs(trackedMethods) do
            local original = container[methodName]
            if type(original) == "function" then
                pcall(function()
                    container[methodName] = wrapMethod(methodName, kind, original)
                end)
            end
        end
    end

    for _, name in ipairs(tabOrder) do
        wrapContainer(Tabs[name], name, tabIndices[name], "", true)
    end

    local function splitWords(value)
        local out, seen = {}, {}
        for word in normalize(value):gmatch("%S+") do
            if not seen[word] then seen[word] = true; table.insert(out, word) end
        end
        return out
    end

    local function editDistance(a, b, limit)
        if a == b then return 0 end
        if math.abs(#a - #b) > limit or #a > 24 or #b > 24 then return limit + 1 end
        if #a == 0 then return #b end
        if #b == 0 then return #a end
        local previous = {}
        for j = 0, #b do previous[j] = j end
        for i = 1, #a do
            local current = {[0]=i}
            local rowMin = i
            for j = 1, #b do
                local cost = a:sub(i, i) == b:sub(j, j) and 0 or 1
                local value = math.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
                current[j] = value
                if value < rowMin then rowMin = value end
            end
            if rowMin > limit then return limit + 1 end
            previous = current
        end
        return previous[#b] or (limit + 1)
    end

    local function wordScore(queryWord, entry)
        if entry.wordSet[queryWord] then return 100 end
        if entry.prefixSet[queryWord] then return 82 end
        for _, word in ipairs(entry.words) do
            if #queryWord >= 2 and word:sub(1, #queryWord) == queryWord then return 82 end
        end
        if #queryWord >= 3 and entry.searchText:find(queryWord, 1, true) then return 72 end
        local best = 0
        if #queryWord >= 4 then
            local allowance = #queryWord >= 6 and 2 or 1
            for _, word in ipairs(entry.words) do
                if #word <= 24 and math.abs(#queryWord - #word) <= allowance then
                    local distance = editDistance(queryWord, word, allowance)
                    if distance <= allowance then best = math.max(best, 60 - distance * 13) end
                end
            end
        end
        return best
    end

    local semanticAliases = {
        mahoraga={"earthquake", "throw"}, maho={"mahoraga", "earthquake", "throw"},
        blackflash={"black", "flash", "bf", "chain"}, bf={"black", "flash", "chain"},
        todo={"boogie", "swap", "void", "clap"}, gojo={"hunt", "cycle", "sweep"},
        hunt={"cycle", "ac", "bypass"}, bypass={"hunt", "ac", "cycle"},
        respawn={"reset"}, reset={"respawn"}, speed={"fly", "dash"}, flight={"fly", "boost"},
        teleport={"tp", "swap", "rotate"}, target={"lock", "rotate", "spectate"},
        invis={"invisibility", "noclip"},
    }

    local function addIndexedCandidates(index, key, candidateSet, candidates)
        local bucket = index[key]
        if not bucket then return false end
        for _, entry in ipairs(bucket) do
            if not candidateSet[entry] then
                candidateSet[entry] = true
                table.insert(candidates, entry)
            end
        end
        return true
    end

    local function addWordCandidates(word, candidateSet, candidates)
        local found = addIndexedCandidates(API.WordIndex, word, candidateSet, candidates)
        if #word >= 2 then
            local prefix = word:sub(1, math.min(#word, 3))
            found = addIndexedCandidates(API.PrefixIndex, prefix, candidateSet, candidates) or found
        end
        if found or #word < 4 then return end

        -- Fuzzy fallback compares the unique vocabulary, not every control token.
        local allowance = #word >= 6 and 2 or 1
        for _, indexedWord in ipairs(API.Vocabulary) do
            if #indexedWord <= 24 and math.abs(#word - #indexedWord) <= allowance
                and editDistance(word, indexedWord, allowance) <= allowance then
                addIndexedCandidates(API.WordIndex, indexedWord, candidateSet, candidates)
            end
        end
    end

    local function scoreEntry(entry, normalizedQuery, queryWords, compactQuery)
        local directScore, directMatches, aliasScore = 0, 0, 0
        for _, queryWord in ipairs(queryWords) do
            if #queryWord >= 2 then
                local score = wordScore(queryWord, entry)
                if score > 0 then directScore = directScore + score; directMatches = directMatches + 1 end
                local aliases = semanticAliases[queryWord]
                if aliases then
                    for _, alias in ipairs(aliases) do
                        aliasScore = math.max(aliasScore, wordScore(alias, entry) * 0.68)
                    end
                end
            end
        end

        if #queryWords > 1 and directMatches > 0 then
            directScore = directScore * (0.55 + 0.45 * (directMatches / #queryWords))
        end
        local score = directScore
        if aliasScore > 0 then
            if score > 0 then score = score + aliasScore * 0.18 else score = aliasScore end
        end
        if normalizedQuery == entry.titleNormalized then score = score + 1400 end
        if normalizedQuery == entry.idNormalized then score = score + 1250 end
        if #compactQuery >= 3 and entry.titleCompact:find(compactQuery, 1, true) then score = score + 340 end
        if #compactQuery >= 3 and entry.compact:find(compactQuery, 1, true) then score = score + 115 end
        if #queryWords > 1 and directMatches == #queryWords then score = score + 24 end
        return score
    end

    API.BuildUI = function()
        local root = Window and Window.Root
        if not (root and root:IsA("GuiObject")) then return false end
        local previous = root:FindFirstChild("NHGlobalFeatureSearch")
        if previous then previous:Destroy() end

        -- The released Fluent build keeps TabWidth on its CreateWindow config,
        -- not on the returned Window object. TabDisplay is positioned from that
        -- same live width, so read its real offset instead of doing nil arithmetic.
        local headerLeft
        if Window.TabDisplay then
            pcall(function() headerLeft = Window.TabDisplay.Position.X.Offset end)
        end
        if type(headerLeft) ~= "number" then
            local tabFrame = Window.TabHolder and Window.TabHolder.Parent
            local tabWidth = tabFrame and tabFrame.Size and tabFrame.Size.X.Offset
            if type(tabWidth) == "number" then headerLeft = tabWidth + 26 end
        end
        if type(headerLeft) ~= "number" then
            warn("[NH Search] Could not determine Fluent's header position.")
            return false
        end

        local searchBar = Instance.new("Frame")
        searchBar.Name = "NHGlobalFeatureSearch"
        searchBar.Position = UDim2.fromOffset(headerLeft, 54)
        searchBar.Size = UDim2.fromOffset(240, 30)
        searchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        searchBar.BackgroundTransparency = 0.10
        searchBar.BorderSizePixel = 0
        searchBar.ZIndex = 40
        searchBar.Parent = root

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 8)
        barCorner.Parent = searchBar
        local barStroke = Instance.new("UIStroke")
        barStroke.Color = Color3.fromRGB(165, 172, 187)
        barStroke.Thickness = 1
        barStroke.Transparency = 0.48
        barStroke.Parent = searchBar
        local barGradient = Instance.new("UIGradient")
        barGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 20, 26)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(31, 34, 42)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 14, 19)),
        })
        barGradient.Rotation = 0
        barGradient.Parent = searchBar

        local searchInput = Instance.new("TextBox")
        searchInput.Name = "NHFeatureSearchInput"
        searchInput.BackgroundTransparency = 1
        searchInput.BorderSizePixel = 0
        searchInput.ClearTextOnFocus = false
        searchInput.Text = ""
        searchInput.PlaceholderText = "Search features, settings, keybinds..."
        searchInput.PlaceholderColor3 = Color3.fromRGB(155, 160, 171)
        searchInput.TextColor3 = Color3.fromRGB(240, 242, 247)
        searchInput.Font = Enum.Font.Gotham
        searchInput.TextSize = 13
        searchInput.TextXAlignment = Enum.TextXAlignment.Left
        searchInput.TextYAlignment = Enum.TextYAlignment.Center
        searchInput.Size = UDim2.new(1, -40, 1, 0)
        searchInput.Position = UDim2.fromOffset(10, 0)
        searchInput.ZIndex = 42
        searchInput.Parent = searchBar

        local clearButton = Instance.new("TextButton")
        clearButton.Name = "ClearSearch"
        clearButton.AnchorPoint = Vector2.new(1, 0.5)
        clearButton.Position = UDim2.new(1, -4, 0.5, 0)
        clearButton.Size = UDim2.fromOffset(22, 22)
        clearButton.BackgroundTransparency = 1
        clearButton.BorderSizePixel = 0
        clearButton.Text = "x"
        clearButton.TextColor3 = Color3.fromRGB(185, 190, 201)
        clearButton.Font = Enum.Font.GothamBold
        clearButton.TextSize = 14
        clearButton.AutoButtonColor = false
        clearButton.Visible = false
        clearButton.ZIndex = 43
        clearButton.Parent = searchBar

        local resultsPanel = Instance.new("Frame")
        resultsPanel.Name = "SearchResultsPanel"
        resultsPanel.Position = UDim2.fromOffset(headerLeft, 88)
        resultsPanel.Size = UDim2.fromOffset(240, 200)
        resultsPanel.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
        resultsPanel.BackgroundTransparency = 0.04
        resultsPanel.BorderSizePixel = 0
        resultsPanel.ClipsDescendants = true
        resultsPanel.Visible = false
        resultsPanel.ZIndex = 48
        resultsPanel.Parent = root
        local panelCorner = Instance.new("UICorner")
        panelCorner.CornerRadius = UDim.new(0, 9)
        panelCorner.Parent = resultsPanel
        local panelStroke = Instance.new("UIStroke")
        panelStroke.Color = Color3.fromRGB(145, 153, 168)
        panelStroke.Thickness = 1
        panelStroke.Transparency = 0.55
        panelStroke.Parent = resultsPanel

        local resultScroll = Instance.new("ScrollingFrame")
        resultScroll.Name = "ResultsScroll"
        resultScroll.Position = UDim2.fromOffset(3, 3)
        resultScroll.Size = UDim2.new(1, -6, 1, -6)
        resultScroll.BackgroundTransparency = 1
        resultScroll.BorderSizePixel = 0
        resultScroll.ScrollBarThickness = 3
        resultScroll.ScrollBarImageColor3 = Color3.fromRGB(190, 195, 206)
        resultScroll.ScrollBarImageTransparency = 0.42
        resultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        resultScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        resultScroll.ZIndex = 49
        resultScroll.Parent = resultsPanel

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 4)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = resultScroll
        local listPadding = Instance.new("UIPadding")
        listPadding.PaddingLeft = UDim.new(0, 4)
        listPadding.PaddingRight = UDim.new(0, 4)
        listPadding.PaddingTop = UDim.new(0, 4)
        listPadding.PaddingBottom = UDim.new(0, 4)
        listPadding.Parent = resultScroll
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            resultScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
        end)

        local slots = {}
        local slotCount = 16

        local focusSequence = 0
        local contentTween, selectorTween, scrollTween, activeHighlight

        local function cancelTween(tween)
            if tween then pcall(function() tween:Cancel() end) end
        end

        local function findExactFrame(entry, scroller)
            local target = entry.frame
            if typeof(target) == "Instance" and target:IsA("GuiObject") and target:IsDescendantOf(scroller) then
                return target
            end
            local widget = entry.widget
            if typeof(widget) == "Instance" and widget:IsA("GuiObject") then
                if widget:IsDescendantOf(scroller) then return widget end
                return nil
            end
            if type(widget) == "table" then
                for _, key in ipairs({"Frame", "Root", "Container"}) do
                    local candidate = widget[key]
                    if typeof(candidate) == "Instance" and candidate:IsA("GuiObject")
                        and candidate:IsDescendantOf(scroller) then
                        return candidate
                    end
                end
            end

            -- Last-resort lookup for controls that did not expose a row reference:
            -- Fluent's shared Element renders the control title inside its row button.
            for _, descendant in ipairs(scroller:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Text == entry.title then
                    local ancestor = descendant.Parent
                    while ancestor and ancestor ~= scroller do
                        if ancestor:IsA("TextButton") then return ancestor end
                        ancestor = ancestor.Parent
                    end
                end
            end
            return nil
        end

        local function selectTabAndFocus(entry)
            if not entry then return end
            local targetTab = Tabs[entry.tabName]
            if not targetTab then return end

            focusSequence = focusSequence + 1
            local mySequence = focusSequence
            cancelTween(contentTween)
            cancelTween(selectorTween)
            cancelTween(scrollTween)
            if activeHighlight then pcall(function() activeHighlight:Destroy() end); activeHighlight = nil end

            task.spawn(function()
                local ok, err = pcall(function()
                    -- The released Window:SelectTab adapter always chooses tab 1.
                    -- Switch the exposed tab objects directly, then focus the exact row.
                    for _, name in ipairs(tabOrder) do
                        local tab = Tabs[name]
                        if tab then
                            local selected = tab == targetTab
                            local container = tab.Container or tab.ScrollFrame
                            if container then container.Visible = selected end
                            tab.Selected = selected
                            if tab.SetTransparency then tab.SetTransparency(selected and 0.89 or 1) end
                        end
                    end
                    if Window.TabDisplay then Window.TabDisplay.Text = targetTab.Name end

                    local tabHolder = Window.TabHolder
                    local tabFrame = tabHolder and tabHolder.Parent
                    if tabFrame and targetTab.Frame then
                        for _, child in ipairs(tabFrame:GetChildren()) do
                            if child:IsA("Frame") and child ~= tabHolder and child.Size.X.Offset <= 6 then
                                local centerY = targetTab.Frame.AbsolutePosition.Y - tabFrame.AbsolutePosition.Y + targetTab.Frame.AbsoluteSize.Y / 2
                                selectorTween = TweenService:Create(
                                    child,
                                    TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                                    {Position=UDim2.fromOffset(0, centerY), Size=UDim2.fromOffset(4, targetTab.Frame.AbsoluteSize.Y)}
                                )
                                selectorTween:Play()
                                break
                            end
                        end
                    end

                    local holder = Window.ContainerHolder
                    if holder then
                        local x = holder.Position.X.Offset
                        holder.GroupTransparency = 1
                        holder.Position = UDim2.fromOffset(x, 102)
                        contentTween = TweenService:Create(
                            holder,
                            TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                            {Position=UDim2.fromOffset(x, 94), GroupTransparency=0}
                        )
                        contentTween:Play()
                        contentTween.Completed:Wait()
                    end
                    if mySequence ~= focusSequence then return end
                    -- Let Fluent's nested section layouts and canvas sizes settle
                    -- after making the previously hidden tab visible.
                    RunService.RenderStepped:Wait()
                    RunService.RenderStepped:Wait()
                    if mySequence ~= focusSequence then return end

                    local scroller = targetTab.Container or targetTab.ScrollFrame
                    if not (scroller and scroller:IsA("ScrollingFrame")) then return end
                    local elementFrame = findExactFrame(entry, scroller)
                    if not elementFrame then
                        warn("[NH Search] Could not resolve the exact control row: " .. tostring(entry.title))
                        return
                    end

                    -- Align the exact move near the top so the rest of its tab stays
                    -- visible below it; animate the scroll and briefly outline the row.
                    local relativeY = elementFrame.AbsolutePosition.Y - scroller.AbsolutePosition.Y
                    local maxY = 0
                    local canvasRead = pcall(function()
                        maxY = math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y)
                    end)
                    if not canvasRead or maxY <= 0 then
                        local canvas = scroller.CanvasSize
                        local canvasHeight = canvas.Y.Scale * scroller.AbsoluteSize.Y + canvas.Y.Offset
                        maxY = math.max(0, canvasHeight - scroller.AbsoluteSize.Y)
                    end
                    local targetY = math.clamp(scroller.CanvasPosition.Y + relativeY - 12, 0, maxY)
                    scrollTween = TweenService:Create(
                        scroller,
                        TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        {CanvasPosition=Vector2.new(scroller.CanvasPosition.X, targetY)}
                    )
                    scrollTween:Play()

                    local stroke = Instance.new("UIStroke")
                    stroke.Name = "NHSearchExactMatch"
                    stroke.Color = Color3.fromRGB(205, 216, 234)
                    stroke.Thickness = 2
                    stroke.Transparency = 0.12
                    stroke.Parent = elementFrame
                    activeHighlight = stroke
                    TweenService:Create(
                        stroke,
                        TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        {Transparency=1}
                    ):Play()
                    task.delay(1.30, function()
                        if activeHighlight == stroke then activeHighlight = nil end
                        pcall(function() stroke:Destroy() end)
                    end)
                end)
                if not ok then warn("[NH Search] Jump to exact feature failed: " .. tostring(err)) end
            end)
        end

        for i = 1, slotCount do
            local slot = {entry=nil, button=nil, title=nil, description=nil}
            local button = Instance.new("TextButton")
            button.Name = "FeatureResult" .. tostring(i)
            button.Size = UDim2.new(1, -8, 0, mobile and 46 or 42)
            button.BackgroundColor3 = Color3.fromRGB(35, 38, 46)
            button.BackgroundTransparency = 0.24
            button.BorderSizePixel = 0
            button.Text = ""
            button.AutoButtonColor = false
            button.Visible = false
            button.ClipsDescendants = true
            button.LayoutOrder = i
            button.ZIndex = 50
            button.Parent = resultScroll
            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 6)
            rowCorner.Parent = button

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "ResultTitle"
            titleLabel.Position = UDim2.fromOffset(9, 3)
            titleLabel.Size = UDim2.new(1, -16, 0, 18)
            titleLabel.BackgroundTransparency = 1
            titleLabel.TextColor3 = Color3.fromRGB(244, 245, 249)
            titleLabel.Font = Enum.Font.GothamSemibold
            titleLabel.TextSize = 12
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextYAlignment = Enum.TextYAlignment.Center
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.ZIndex = 51
            titleLabel.Parent = button

            local descriptionLabel = Instance.new("TextLabel")
            descriptionLabel.Name = "ResultLocation"
            descriptionLabel.Position = UDim2.fromOffset(9, 21)
            descriptionLabel.Size = UDim2.new(1, -16, 0, 16)
            descriptionLabel.BackgroundTransparency = 1
            descriptionLabel.TextColor3 = Color3.fromRGB(168, 174, 187)
            descriptionLabel.Font = Enum.Font.Gotham
            descriptionLabel.TextSize = 10
            descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
            descriptionLabel.TextYAlignment = Enum.TextYAlignment.Center
            descriptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
            descriptionLabel.ZIndex = 51
            descriptionLabel.Parent = button

            slot.button, slot.title, slot.description = button, titleLabel, descriptionLabel
            button.Activated:Connect(function()
                if slot.entry then
                    resultsPanel.Visible = false
                    pcall(function() searchInput:ReleaseFocus() end)
                    selectTabAndFocus(slot.entry)
                end
            end)
            button.MouseEnter:Connect(function() button.BackgroundTransparency = 0.10 end)
            button.MouseLeave:Connect(function() button.BackgroundTransparency = 0.24 end)
            slots[i] = slot
        end

        local function setSlot(slot, title, description, entry)
            slot.entry = entry
            slot.title.Text = title
            slot.description.Text = description
            slot.button.Visible = true
        end

        local function hideFrom(firstIndex)
            for i = firstIndex, #slots do
                slots[i].entry = nil
                slots[i].button.Visible = false
            end
        end

        local function layoutSearch()
            local width = root.AbsoluteSize.X
            local height = root.AbsoluteSize.Y
            if width <= 0 and Window.Size then width = Window.Size.X.Offset end
            if height <= 0 and Window.Size then height = Window.Size.Y.Offset end
            local available = width - headerLeft - 12
            local titleWidth = available >= 330 and 120 or (available >= 280 and 88 or 0)
            local gap = titleWidth > 0 and 12 or 0
            if Window.TabDisplay then
                Window.TabDisplay.Visible = titleWidth > 0
                Window.TabDisplay.Size = UDim2.new(0, titleWidth, 0, 28)
                pcall(function() Window.TabDisplay.TextTruncate = Enum.TextTruncate.AtEnd end)
            end
            local searchX = headerLeft + titleWidth + gap
            local searchWidth = math.max(96, width - searchX - 12)
            searchBar.Position = UDim2.fromOffset(searchX, 54)
            searchBar.Size = UDim2.fromOffset(searchWidth, 30)
            resultsPanel.Position = UDim2.fromOffset(searchX, 88)
            resultsPanel.Size = UDim2.fromOffset(searchWidth, math.max(140, math.min(250, height - 145)))
            if searchWidth < 160 then
                searchInput.PlaceholderText = "Search..."
            elseif searchWidth < 235 then
                searchInput.PlaceholderText = "Search features / keys..."
            else
                searchInput.PlaceholderText = "Search features, settings, keybinds..."
            end
        end
        layoutSearch()
        if API.LayoutConnection then
            pcall(function() API.LayoutConnection:Disconnect() end)
        end
        API.LayoutConnection = root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutSearch)

        local function display(query)
            local normalized = normalize(query)
            hideFrom(1)
            resultScroll.CanvasPosition = Vector2.new(0, 0)
            if #normalized == 0 then
                resultsPanel.Visible = false
                return
            end
            resultsPanel.Visible = true
            if #normalized < 2 then
                setSlot(slots[1], "Type a little more", "Enter at least two characters to search.", nil)
                return
            end

            local queryWords = splitWords(normalized)
            while #queryWords > 6 do table.remove(queryWords) end
            local compactQuery = normalized:gsub("%s+", "")
            local candidateSet, candidates = {}, {}
            for _, word in ipairs(queryWords) do
                addWordCandidates(word, candidateSet, candidates)
                local aliases = semanticAliases[word]
                if aliases then
                    for _, alias in ipairs(aliases) do
                        addIndexedCandidates(API.WordIndex, alias, candidateSet, candidates)
                        addIndexedCandidates(API.PrefixIndex, alias, candidateSet, candidates)
                    end
                end
            end
            -- Keep compact phrase search, but reserve edit-distance work for the
            -- unique vocabulary and likely candidates above.
            if #compactQuery >= 3 then
                for _, entry in ipairs(API.Entries) do
                    if entry.compact:find(compactQuery, 1, true) and not candidateSet[entry] then
                        candidateSet[entry] = true
                        table.insert(candidates, entry)
                    end
                end
            end

            local matches = {}
            for _, entry in ipairs(candidates) do
                local score = scoreEntry(entry, normalized, queryWords, compactQuery)
                if score > 0 then table.insert(matches, {entry=entry, score=score}) end
            end
            table.sort(matches, function(a, b)
                if a.score == b.score then
                    if a.entry.title == b.entry.title then return a.entry.order < b.entry.order end
                    return a.entry.title < b.entry.title
                end
                return a.score > b.score
            end)

            if #matches == 0 then
                setSlot(slots[1], "No close matches", "Try a shorter name, an alias, or a common spelling.", nil)
                return
            end

            local shown = math.min(#matches, slotCount)
            for i = 1, shown do
                local entry = matches[i].entry
                local maxTitle = searchBar.AbsoluteSize.X < 180 and 18 or (searchBar.AbsoluteSize.X < 245 and 26 or 46)
                local title = entry.title
                if #title > maxTitle then title = title:sub(1, maxTitle - 3) .. "..." end
                local location = entry.tabName
                if entry.section ~= "" then location = location .. " / " .. entry.section end
                local description = location .. " • " .. entry.kind
                if #matches > slotCount and i == shown then
                    description = description .. " • refine for " .. tostring(#matches - slotCount) .. " more"
                end
                setSlot(slots[i], title, description, entry)
            end
            hideFrom(shown + 1)
        end

        API.Display = display
        API.SearchSlots = slots
        API.SearchInput = searchInput
        API.SearchPanel = resultsPanel
        searchInput:GetPropertyChangedSignal("Text"):Connect(function()
            clearButton.Visible = searchInput.Text ~= ""
            API.QueueSearch(searchInput.Text)
        end)
        searchInput.Focused:Connect(function()
            if normalize(searchInput.Text) ~= "" then API.Display(searchInput.Text) end
        end)
        clearButton.Activated:Connect(function()
            searchInput.Text = ""
            searchInput:CaptureFocus()
        end)
        return true
    end

    local searchSequence = 0
    API.QueueSearch = function(query)
        searchSequence = searchSequence + 1
        local mine = searchSequence
        task.delay(0.09, function()
            if mine == searchSequence and API.Display then API.Display(query) end
        end)
    end

    return API
end)()

-- ============================================================
-- BISECT 02: Anti-Team / Stand Link remains removed for FPS isolation.
-- Todo Void is restored below as a standalone, event-driven backend only;
-- it has no link transport, farming, idle heartbeat, or permanent render loop.
-- ============================================================
_G.NH_TodoVoid = (function()
    local previous = rawget(_G, "NH_TodoVoid")
    if type(previous) == "table" and type(previous.Destroy) == "function" then
        pcall(previous.Destroy)
    end

    local API = {
        Version = "2.0-standalone-move-safe",
        Alive = true,
        Enabled = false,
        Busy = false,
        Hooked = false,
        Controller = nil,
        OriginalUseKey = nil,
        Wrapper = nil,
        Action = nil,
        LastResult = "Not run",
        LastStage = "Idle",
        LastTrace = nil,
        Config = {
            -- Exact working destination carried over from the reference hub.
            VoidPoint = Vector3.new(1.153542637825, 36.520683288574, -385.21221923828),
            PickupTimeout = 4.5,
            FinishTimeout = 10,
            TargetArrivalRadius = 40,
        },
        Contexts = setmetatable({}, {__mode = "k"}),
        TargetHooks = {},
    }

    local function rootOf(model)
        if not model then return nil end
        local hum = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or (hum and hum.RootPart)
            or model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model.PrimaryPart
        return root and root:IsA("BasePart") and root or nil
    end

    local function live(model)
        local hum = model and model:FindFirstChildOfClass("Humanoid")
        return model ~= nil
            and model ~= LocalPlayer.Character
            and model:IsDescendantOf(Workspace)
            and hum ~= nil and hum.Health > 0
            and rootOf(model) ~= nil
    end

    local function selectTarget()
        local locked = St.lockOnTarget
        if type(locked) == "table" and locked.Char then locked = locked.Char end
        if live(locked) then return locked end

        local character = LocalPlayer.Character
        local root = rootOf(character)
        if not root then return nil end
        local best, bestDistance = nil, nil
        for _, entry in ipairs(getValidTargets(root)) do
            local model = entry.Char
            local targetRoot = entry.Core or rootOf(model)
            if live(model) and targetRoot then
                local distance = (targetRoot.Position - root.Position).Magnitude
                if not bestDistance or distance < bestDistance then
                    best, bestDistance = model, distance
                end
            end
        end
        return best
    end

    local function effectsRemote()
        local outer = ReplicatedStorage:FindFirstChild("Knit")
        local knit = outer and outer:FindFirstChild("Knit")
        local services = knit and knit:FindFirstChild("Services")
        local service = services and services:FindFirstChild("SwiftKickService")
        local remotes = service and service:FindFirstChild("RE")
        local effects = remotes and remotes:FindFirstChild("Effects")
        return effects and effects:IsA("RemoteEvent") and effects or nil
    end

    local function setStatus(stage, message)
        API.LastStage = stage
        API.LastResult = tostring(message)
    end

    function API.Cancel(reason, silent)
        local action = API.Action
        if action then
            action.Cancelled = true
            if action.Cleanup then action.Cleanup() end
        end
        if reason then setStatus("Cancelled", reason) end
        if not silent and reason then notify("Todo Void", tostring(reason), 3) end
    end

    -- Arm listeners synchronously BEFORE normal slot-1 input is dispatched.
    -- This prevents a fast Grab event from being missed and keeps Swift Kick native.
    function API.Begin(target)
        if API.Busy then return false, "A Todo Void attempt is already active" end
        if not live(target) then return false, "No live target is available" end

        local character = LocalPlayer.Character
        local root = rootOf(character)
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not root or not hum or hum.Health <= 0 then
            return false, "Todo user is not alive"
        end
        if character:GetAttribute("Moveset") ~= "Todo" then return false, "Equip Todo" end
        local moves = character:FindFirstChild("Moveset")
        if not moves or not moves:FindFirstChild("Swift Kick") then
            return false, "Swift Kick is unavailable"
        end

        local effects = effectsRemote()
        if not effects then return false, "Swift Kick effect events are unavailable" end
        local victimRoot = rootOf(target)
        if not victimRoot then return false, "Target root is unavailable" end
        local point = API.Config.VoidPoint
        if typeof(point) ~= "Vector3" then return false, "Void destination is invalid" end

        local home = root.CFrame
        local drop = CFrame.new(point) * (home - home.Position)
        local camera = Workspace.CurrentCamera
        local cameraBefore = camera and camera.CFrame
        local anchoredBefore = root.Anchored
        local autoRotateBefore = hum.AutoRotate
        local platformBefore = hum.PlatformStand
        local started = os.clock()
        local renderName = "NHTodoVoidCarry"
        local effectConnection, heartbeatConnection
        local cleaned = false
        local state = {
            phase = "Approach",
            grabbed = false,
            thrown = false,
            throwAt = 0,
            mover = nil,
            moverBefore = nil,
            arrived = false,
            finished = false,
            pinCorrections = 0,
            events = {},
        }
        local action = {Cancelled = false, Character = character, Target = target, State = state}
        API.Action = action
        API.Busy = true
        API.LastTrace = state
        setStatus("Approach", "Armed before native Swift Kick input")

        local function active()
            return API.Alive and not action.Cancelled and API.Action == action
                and LocalPlayer.Character == character
                and root.Parent ~= nil and hum.Health > 0
        end

        local function moveActive()
            local info = character:FindFirstChild("Info")
            if info and info:FindFirstChild("InSkill") then return true end
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                local animation = track.Animation
                local id = animation and tostring(animation.AnimationId):match("%d+")
                if track.IsPlaying and (id == "84737448668938" or id == "124120330557927") then
                    return true
                end
            end
            return false
        end

        local function pin()
            if not active() then return end
            if state.phase == "Approach" then
                if live(target) and victimRoot.Parent then
                    local behind = (victimRoot.CFrame * CFrame.new(0, 0, 1)).Position
                    root.CFrame = CFrame.lookAt(behind, victimRoot.Position)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            elseif state.grabbed and not state.finished then
                if (root.Position - point).Magnitude > 8 then
                    state.pinCorrections = state.pinCorrections + 1
                end
                root.CFrame = drop
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                -- Aim creates a move-owned position holder. Move it with the cast
                -- rather than fighting or destroying the legitimate carry mover.
                if state.mover and state.mover.Parent then
                    pcall(function() state.mover.Position = point end)
                end
                local currentCamera = Workspace.CurrentCamera
                if currentCamera then
                    currentCamera.CFrame = CFrame.lookAt(
                        point + Vector3.new(0, 6, 2),
                        point + Vector3.new(0, -120, -4)
                    )
                end
                if victimRoot.Parent and (victimRoot.Position - point).Magnitude <= API.Config.TargetArrivalRadius then
                    state.arrived = true
                end
            end
        end

        local function depart()
            if state.grabbed or not active() then return end
            state.grabbed = true
            state.grabAt = os.clock() - started
            state.phase = "Holding at void"
            setStatus(state.phase, "Grab confirmed; holding until native Throw finishes")
            pin()
        end

        action.Cleanup = function()
            if cleaned then return end
            cleaned = true
            if effectConnection then pcall(function() effectConnection:Disconnect() end) end
            if heartbeatConnection then pcall(function() heartbeatConnection:Disconnect() end) end
            pcall(function() RunService:UnbindFromRenderStep(renderName) end)

            local skillReadOK, skillBusy = pcall(moveActive)
            local holderAlive = state.mover and state.mover.Parent ~= nil
            local safeReturn = not state.grabbed or state.finished or action.Cancelled
                or (skillReadOK and not skillBusy and not holderAlive)
            if LocalPlayer.Character == character and root.Parent then
                pcall(function()
                    if safeReturn and hum.Health > 0 then root.CFrame = home end
                    if state.mover and state.mover.Parent and safeReturn and state.moverBefore then
                        state.mover.Position = state.moverBefore
                    end
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.Anchored = anchoredBefore
                    hum.AutoRotate = autoRotateBefore
                    hum.PlatformStand = platformBefore
                end)
            end
            if cameraBefore and Workspace.CurrentCamera == camera then
                pcall(function() camera.CFrame = cameraBefore end)
            end
            if API.Action == action then API.Action = nil end
            API.Busy = false
            state.returned = safeReturn and LocalPlayer.Character == character and hum.Health > 0
        end

        local function pause(seconds)
            local deadline = os.clock() + seconds
            repeat
                if not active() then error("Todo Void cancelled or character changed") end
                task.wait(math.min(0.02, math.max(0, deadline - os.clock())))
            until os.clock() >= deadline
        end

        root.Anchored = true
        hum.AutoRotate = false
        effectConnection = effects.OnClientEvent:Connect(function(event, ...)
            if not active() then return end
            local args = table.pack(...)
            local ours = args[1] == character or args[1] == LocalPlayer or args[1] == target
            if not ours then return end

            if #state.events < 24 then
                state.events[#state.events + 1] = {event = tostring(event), at = os.clock() - started}
            end
            if event == "Grab" and (args[1] == target or (args[1] == character and args[2] == target)) then
                if victimRoot.Parent and (victimRoot.Position - root.Position).Magnitude <= 24 then depart() end
            elseif event == "Aim" and args[1] == character then
                local mover = args[2]
                if typeof(mover) == "Instance" and mover:IsDescendantOf(character) then
                    state.mover = mover
                    pcall(function() state.moverBefore = mover.Position end)
                end
                if not state.grabbed and args[3] == target and victimRoot.Parent
                    and (victimRoot.Position - root.Position).Magnitude <= 24 then
                    depart()
                end
                pin()
            elseif event == "Throw" and args[1] == character then
                if args[2] ~= target then state.wrongVictim = true; return end
                state.thrown = true
                state.throwAt = os.clock()
                state.throwAfter = os.clock() - started
                state.phase = "Finishing throw"
                setStatus(state.phase, "Throw received; staying at void until the move ends")
                pin()
            end
        end)
        heartbeatConnection = RunService.Heartbeat:Connect(pin)
        pcall(function() RunService:UnbindFromRenderStep(renderName) end)
        RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 20, pin)
        pin()

        task.spawn(function()
            local ok, err = xpcall(function()
                local deadline = os.clock() + API.Config.PickupTimeout
                while not state.grabbed do
                    if not live(target) then error("Target became unavailable before Grab") end
                    if os.clock() > deadline then
                        error("No selected-target Grab confirmation; Swift Kick missed, was blocked, or changed")
                    end
                    pause(0.02)
                end

                deadline = os.clock() + API.Config.FinishTimeout
                local quietSince = nil
                repeat
                    if state.wrongVictim then error("Swift Kick grabbed a different target; stopped safely") end
                    local holderAlive = state.mover and state.mover.Parent ~= nil
                    local ended = state.thrown and os.clock() - state.throwAt >= 0.6
                        and not holderAlive and not moveActive()
                    if ended then quietSince = quietSince or os.clock() else quietSince = nil end
                    if quietSince and os.clock() - quietSince >= 0.15 then
                        state.finished = true
                        break
                    end
                    if os.clock() > deadline then
                        error("Native move end was not confirmed; return withheld to avoid dragging the target back")
                    end
                    pause(0.02)
                until false

                state.finishAfter = os.clock() - started
                local targetHum = target:FindFirstChildOfClass("Humanoid")
                state.voidObserved = victimRoot.Position.Y <= Workspace.FallenPartsDestroyHeight
                    or (targetHum and targetHum.Health <= 0) or false
                if not state.arrived then
                    error("Throw finished, but target arrival at the saved void point was not verified")
                end
                state.phase = "Complete"
                setStatus("Complete", state.voidObserved
                    and "Void observed; move finished and position restored"
                    or "Throw finished at void; kill not yet verified")
            end, function(message) return tostring(message) end)

            action.Cleanup()
            if not ok then
                state.phase = "Failed"
                setStatus("Failed", tostring(err))
                if API.Enabled then notify("Todo Void", "Attempt failed: " .. tostring(err), 4) end
            end
        end)
        return true
    end

    local function installTargetHooks(controller)
        for _, name in ipairs({"GetTarget", "GetMouseTarget", "GetTargetOrProjectile"}) do
            if not API.TargetHooks[name] then
                local original = controller[name]
                if type(original) == "function" then
                    local wrapper = function(self, ...)
                        local target = API.Contexts[coroutine.running()]
                        local targetRoot = rootOf(target)
                        if targetRoot then
                            if name == "GetMouseTarget" then return targetRoot.Position end
                            return target
                        end
                        return original(self, ...)
                    end
                    API.TargetHooks[name] = {Original = original, Wrapper = wrapper}
                    controller[name] = wrapper
                end
            end
        end
    end

    function API.Install()
        if not API.Alive then return false end
        local controller = nhGetToolController()
        if not controller or type(controller.UseKey) ~= "function" then return false end
        if controller._NH_todoVoidPatched == API then API.Hooked = true; return true end

        local oldPatch = controller._NH_todoVoidPatched
        if oldPatch and oldPatch ~= API and type(oldPatch.Destroy) == "function" then
            pcall(oldPatch.Destroy)
        end
        API.Controller = controller
        installTargetHooks(controller)
        API.OriginalUseKey = controller.UseKey
        API.Wrapper = function(self, slot, eventName, ...)
            local target = nil
            if API.Alive and API.Enabled and St.todoVoidEnabled
                and slot == 1 and eventName == "Activated" then
                local character = LocalPlayer.Character
                if character and character:GetAttribute("Moveset") == "Todo" then
                    local chosen = selectTarget()
                    if chosen then
                        local protected, started, reason = pcall(API.Begin, chosen)
                        if protected and started then
                            target = chosen
                        else
                            notify("Todo Void", protected and tostring(reason) or tostring(started), 3)
                        end
                    else
                        notify("Todo Void", "No target found; normal Swift Kick still fired.", 3)
                    end
                end
            end

            local thread = coroutine.running()
            if target then API.Contexts[thread] = target end
            local result = table.pack(pcall(API.OriginalUseKey, self, slot, eventName, ...))
            API.Contexts[thread] = nil
            if not result[1] then
                API.Cancel("Native Swift Kick input failed", true)
                error(result[2], 0)
            end
            return table.unpack(result, 2, result.n)
        end
        controller.UseKey = API.Wrapper
        controller._NH_todoVoidPatched = API
        API.Hooked = true
        return true
    end

    function API.SetEnabled(value)
        API.Enabled = value == true
        St.todoVoidEnabled = API.Enabled
        if API.Enabled then
            if not API.Install() then
                task.spawn(function()
                    for _ = 1, 20 do
                        if not API.Alive or not API.Enabled or API.Install() then return end
                        task.wait(0.25)
                    end
                    if API.Alive and API.Enabled and not API.Hooked then
                        notify("Todo Void", "ToolController unavailable; toggle Todo Void again.", 4)
                    end
                end)
            end
        else
            API.Cancel("Todo Void disabled", true)
        end
        return API.Enabled
    end

    function API.GetState()
        return {
            version = API.Version,
            enabled = API.Enabled,
            hooked = API.Hooked,
            busy = API.Busy,
            stage = API.LastStage,
            result = API.LastResult,
            trace = API.LastTrace,
            destination = API.Config.VoidPoint,
        }
    end

    function API.Destroy()
        API.Alive = false
        API.Enabled = false
        API.Cancel("Destroyed", true)
        if API.CharacterConnection then pcall(function() API.CharacterConnection:Disconnect() end) end
        local controller = API.Controller
        if controller then
            if controller.UseKey == API.Wrapper then controller.UseKey = API.OriginalUseKey end
            if controller._NH_todoVoidPatched == API then controller._NH_todoVoidPatched = nil end
            for name, hook in pairs(API.TargetHooks) do
                if controller[name] == hook.Wrapper then controller[name] = hook.Original end
            end
        end
        table.clear(API.Contexts)
        API.Hooked = false
        if rawget(_G, "NH_TodoVoid") == API then _G.NH_TodoVoid = nil end
    end

    API.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
        API.Cancel("Character changed", true)
        if API.Alive and API.Enabled then
            task.defer(API.Install)
        end
    end)
    return API
end)()

-- ============================================================
-- TODO SWEEP VARIANT
-- Clean, reversible version of the supplied backend. The original
-- payload parked SwingForce in TestService and drove SwingForce2;
-- this module preserves that behavior while tracking every connection
-- and restoring the native force when the feature is switched off.
-- ============================================================
_G.NH_TodoSweepVariant = (function()
    local env = getgenv()
    local previous = rawget(_G, "NH_TodoSweepVariant")
        or (type(env) == "table" and rawget(env, "NH_TodoSweepVariant") or nil)
    if type(previous) == "table" and type(previous.Destroy) == "function" then
        pcall(previous.Destroy)
    end

    local TestService = game:GetService("TestService")
    local API = {
        Version = "1.0-managed",
        Alive = true,
        Enabled = false,
        BindSerial = 0,
        InputConnection = nil,
        CharacterConnection = nil,
        RootConnection = nil,
        BoundCharacter = nil,
        BoundRoot = nil,
        ActiveMoves = {},
    }

    local function disconnect(field)
        local connection = API[field]
        API[field] = nil
        if connection then
            pcall(function() connection:Disconnect() end)
        end
    end

    local function destroyReplacement(context)
        local replacement = context.Replacement
        context.Replacement = nil
        if replacement and replacement.Parent then
            pcall(function()
                replacement.MaxForce = Vector3.zero
                replacement.Velocity = Vector3.zero
                replacement:Destroy()
            end)
        end
    end

    local function cleanupMove(context, restoreOriginal)
        if not context or context.Cleaned then return end
        context.Cleaned = true
        context.Cancelled = true
        destroyReplacement(context)

        local original = context.Original
        local root = context.Root
        local canRestore = restoreOriginal
            and context.Parked
            and original and original.Parent == TestService
            and root and root.Parent
            and LocalPlayer.Character == context.Character

        if canRestore then
            pcall(function() original.Parent = root end)
        elseif original and original.Parent == TestService
            and (not root or not root.Parent or LocalPlayer.Character ~= context.Character) then
            -- Do not leave a move-owned force orphaned in TestService after respawn.
            pcall(function() original:Destroy() end)
        end

        if original and API.ActiveMoves[original] == context then
            API.ActiveMoves[original] = nil
        end
    end

    local function cleanupAll(restoreOriginal)
        local pending = {}
        for _, context in pairs(API.ActiveMoves) do
            pending[#pending + 1] = context
        end
        for _, context in ipairs(pending) do
            cleanupMove(context, restoreOriginal)
        end
    end

    local function swiftKickActivatedRemote()
        local outer = ReplicatedStorage:FindFirstChild("Knit")
        local knit = outer and outer:FindFirstChild("Knit")
        local services = knit and knit:FindFirstChild("Services")
        local service = services and services:FindFirstChild("SwiftKickService")
        local remotes = service and service:FindFirstChild("RE")
        local activated = remotes and remotes:FindFirstChild("Activated")
        return activated and activated:IsA("RemoteEvent") and activated or nil
    end

    local function fireOriginalTrigger(input, gameProcessed)
        if not API.Alive or not API.Enabled or gameProcessed then return end
        if not input or input.KeyCode ~= Enum.KeyCode.One then return end

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not humanoid or humanoid.FloorMaterial == Enum.Material.Air then return end

        local moves = character:FindFirstChild("Moveset")
        local swiftKick = moves and moves:FindFirstChild("Swift Kick")
        if not swiftKick then return end

        local activated = swiftKickActivatedRemote()
        if activated then
            pcall(function()
                -- These are the exact arguments used by the supplied payload.
                activated:FireServer(swiftKick, {false, false, true})
            end)
        end
    end

    local function directionAndMultiplier(root)
        local currentEnv = getgenv()
        local target = type(currentEnv) == "table" and rawget(currentEnv, "TARGEE") or nil
        local targetCharacter = target and target.Character
        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

        if targetRoot and targetRoot.Parent then
            local offset = targetRoot.Position - root.Position
            local distance = offset.Magnitude
            if distance > 0 then
                return offset.Unit, math.clamp(1 + distance / 10, 2, 10)
            end
        end

        local camera = Workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0 then
            flat = flat.Unit
        else
            flat = Vector3.new(0, 0, -1)
        end

        local configured = type(currentEnv) == "table" and rawget(currentEnv, "SlideSpeed") or nil
        return flat, tonumber(configured) or 2
    end

    local function beginSwingForce(original, character, root)
        if not API.Alive or not API.Enabled or not original or original.Name ~= "SwingForce" then return end
        if API.ActiveMoves[original] then return end

        local context = {
            Original = original,
            Character = character,
            Root = root,
            Replacement = nil,
            Parked = false,
            Cleaned = false,
            Cancelled = false,
        }
        API.ActiveMoves[original] = context

        task.spawn(function()
            local info = character:FindFirstChild("Info") or character:WaitForChild("Info", 2)
            local moves = character:FindFirstChild("Moveset") or character:WaitForChild("Moveset", 2)
            if not info or not info:FindFirstChild("ItadoriCancel")
                or not moves or not moves:FindFirstChild("Swift Kick") then
                cleanupMove(context, false)
                return
            end

            task.wait()
            while API.Alive and API.Enabled and not context.Cancelled
                and LocalPlayer.Character == character and root.Parent and original.Parent do

                local currentInfo = character:FindFirstChild("Info")
                local currentMoves = character:FindFirstChild("Moveset")
                if not currentInfo or not currentInfo:FindFirstChild("ItadoriCancel")
                    or not currentMoves or not currentMoves:FindFirstChild("Swift Kick") then
                    break
                end

                local originalVelocity
                local readOK = pcall(function() originalVelocity = original.Velocity end)
                if not readOK or typeof(originalVelocity) ~= "Vector3" then break end

                local direction, multiplier = directionAndMultiplier(root)
                local speed = originalVelocity.Magnitude * multiplier
                if context.Cleaned or not API.Enabled then break end

                if original.Parent ~= TestService then
                    local parked = pcall(function() original.Parent = TestService end)
                    if not parked then break end
                    context.Parked = true
                end

                local replacement = context.Replacement
                if not replacement or not replacement.Parent then
                    local existing = root:FindFirstChild("SwingForce2")
                    if existing and existing:IsA("BodyVelocity") then
                        replacement = existing
                    else
                        replacement = Instance.new("BodyVelocity")
                        replacement.Name = "SwingForce2"
                        replacement.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        replacement.Parent = root
                    end
                    context.Replacement = replacement
                end

                if context.Cleaned or not API.Enabled then break end
                pcall(function() replacement.Velocity = direction * speed end)
                task.wait()
            end

            local shouldRestore = original.Parent == TestService
                and LocalPlayer.Character == character and root.Parent ~= nil
            cleanupMove(context, shouldRestore)
        end)
    end

    local function bindCharacter(character)
        API.BindSerial = API.BindSerial + 1
        local serial = API.BindSerial
        disconnect("RootConnection")
        cleanupAll(false)
        API.BoundCharacter = character
        API.BoundRoot = nil

        if not character then return end
        task.spawn(function()
            local root = character:FindFirstChild("HumanoidRootPart")
                or character:WaitForChild("HumanoidRootPart", 10)
            if not root or not API.Alive or not API.Enabled
                or serial ~= API.BindSerial or LocalPlayer.Character ~= character then
                return
            end

            API.BoundRoot = root
            API.RootConnection = root.ChildAdded:Connect(function(child)
                beginSwingForce(child, character, root)
            end)
        end)
    end

    local function start()
        disconnect("InputConnection")
        disconnect("CharacterConnection")
        disconnect("RootConnection")
        API.InputConnection = UserInputService.InputBegan:Connect(fireOriginalTrigger)
        API.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            bindCharacter(character)
        end)
        bindCharacter(LocalPlayer.Character)
    end

    local function stop(restoreOriginal)
        API.BindSerial = API.BindSerial + 1
        disconnect("InputConnection")
        disconnect("CharacterConnection")
        disconnect("RootConnection")
        API.BoundCharacter = nil
        API.BoundRoot = nil
        cleanupAll(restoreOriginal)
    end

    function API.SetEnabled(value)
        if not API.Alive then return false end
        local enabled = value == true
        if API.Enabled == enabled then
            St.todoSweepVariantEnabled = enabled
            if not enabled then stop(true) end
            return API.Enabled
        end
        API.Enabled = enabled
        St.todoSweepVariantEnabled = enabled
        if enabled then
            start()
        else
            stop(true)
        end
        return API.Enabled
    end

    -- Combo Recorder replays saved remotes directly, so a playback never reaches
    -- the physical KeyCode.One InputBegan handler above. Its recorder also
    -- deliberately ignores executor-originated calls, which means the supplied
    -- variant payload is absent from otherwise valid Swift Kick tapes.
    --
    -- Give playback one narrow bridge: while this toggle is enabled, replace only
    -- Todo's SwiftKickService.Activated call with the exact two arguments used by
    -- the original backend. All other recorded calls remain byte-for-byte logical
    -- equivalents of what the recorder decoded.
    function API.RewriteRecordedCall(recordedEvent, args, argCount)
        if not API.Alive or not API.Enabled or type(recordedEvent) ~= "table" then
            return args, argCount, false
        end

        local serviceName = recordedEvent.svc
        local eventName = recordedEvent.ev
        local path = recordedEvent.path
        local isSwiftKick = serviceName == "SwiftKickService" and eventName == "Activated"
        if not isSwiftKick and type(path) == "string" then
            isSwiftKick = string.find(path, "SwiftKickService|RE|Activated", 1, true) ~= nil
        end
        if not isSwiftKick then return args, argCount, false end

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local moves = character and character:FindFirstChild("Moveset")
        local swiftKick = moves and moves:FindFirstChild("Swift Kick")
        if not character or not humanoid or humanoid.FloorMaterial == Enum.Material.Air
            or not swiftKick then
            return args, argCount, false
        end

        return {swiftKick, {false, false, true}}, 2, true
    end

    function API.GetState()
        local active = 0
        for _ in pairs(API.ActiveMoves) do active = active + 1 end
        return {
            version = API.Version,
            enabled = API.Enabled,
            alive = API.Alive,
            activeMoves = active,
            character = API.BoundCharacter,
            root = API.BoundRoot,
        }
    end

    function API.Destroy()
        if not API.Alive then return end
        API.Enabled = false
        St.todoSweepVariantEnabled = false
        stop(true)
        API.Alive = false
        if rawget(_G, "NH_TodoSweepVariant") == API then
            _G.NH_TodoSweepVariant = nil
        end
        local currentEnv = getgenv()
        if type(currentEnv) == "table" and rawget(currentEnv, "NH_TodoSweepVariant") == API then
            currentEnv.NH_TodoSweepVariant = nil
        end
    end

    return API
end)()
getgenv().NH_TodoSweepVariant = _G.NH_TodoSweepVariant

-- ==========================================================
-- INTEGRATED MODULES (Auto Garuda / Cooldown Viewer / Item Grabber)
-- ==========================================================

-- ============================================================
-- NH AUTO GARUDA REBOUND v4.1  (integrated working backend)
-- Animation-triggered Activated -> Deactivated pairs; no standalone panel.
-- ============================================================
do
    local okAG, errAG = pcall(function()
local ENV = getgenv and getgenv() or _G

-- Remove an older hub backend and the standalone test so only one detector can
-- ever send the rebound pair in this client.
local previous = rawget(_G, "NH_AutoGaruda")
if type(previous) == "table" then
    local destroyPrevious = previous._destroy or previous.Destroy
    if type(destroyPrevious) == "function" then pcall(destroyPrevious) end
end
local standalone = rawget(ENV, "NH_AutoGarudaStandalone")
if type(standalone) == "table" and standalone ~= previous then
    local destroyStandalone = standalone.Destroy or standalone._destroy
    if type(destroyStandalone) == "function" then pcall(destroyStandalone) end
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local M = {
    Version = "4.1-hub",
    Enabled = false,
    enabled = false,
    Config = {
        Delay = 1.00,          -- measured from GarudaRebound animation start
        ReleaseDelay = 0.04,  -- time between Activated and Deactivated
        RetryCount = 3,       -- paired taps; confirmation stops remaining retries
        RetryGap = 0.10,
        TargetRange = 140,
        Notify = false,
        Debug = true,
    },
}
_G.NH_AutoGaruda = M
_G.AG = M
ENV.NH_AutoGaruda = M
ENV.AG = M

local state = {
    token = 0,
    busy = false,
    confirmed = false,
    source = "idle",
    phase = "ready",
    attempts = 0,
    target = nil,
    capturedTarget = nil,
    lastError = nil,
    animationId = "rbxassetid://115097960689033",
    ignoreUntil = 0,
}
local connections = {}
local charConnections = {}
local destroyed = false
local remoteCache = {}
local ToolController

local function log(...)
    if M.Config.Debug then print("[NH AG4]", ...) end
end
local function notify(text)
    if getgenv().NH_HubBooting or not M.Config.Notify then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "Auto Garuda v4", Text = text, Duration = 3})
    end)
end
local function track(c, list)
    if c then
        local bucket = list or connections
        bucket[#bucket + 1] = c
    end
    return c
end
local function disconnect(list)
    for _, c in ipairs(list) do pcall(function() c:Disconnect() end) end
    table.clear(list)
end
local function character()
    local c = LocalPlayer.Character
    return c and c.Parent and c or nil
end
local function moveInstance()
    local c = character()
    local moveset = c and c:FindFirstChild("Moveset")
    if not moveset then return nil end
    local exact = moveset:FindFirstChild("Garuda Rebound")
    if exact and exact:IsA("NumberValue") then return exact end
    for _, move in ipairs(moveset:GetChildren()) do
        if move:IsA("NumberValue") and move:GetAttribute("Service") == "GarudaReboundService"
            and not move:GetAttribute("FakeMove") then return move end
    end
end
local function serviceFolder()
    local knit = RS:FindFirstChild("Knit")
    knit = knit and knit:FindFirstChild("Knit")
    local services = knit and knit:FindFirstChild("Services")
    return services and services:FindFirstChild("GarudaReboundService") or nil
end
local function remote(name)
    local cached = remoteCache[name]
    if cached and cached.Parent then return cached end
    local service = serviceFolder()
    local re = service and service:FindFirstChild("RE")
    local found = re and re:FindFirstChild(name)
    if not (found and found:IsA("RemoteEvent")) then found = nil end
    remoteCache[name] = found
    return found
end
local function controller()
    if ToolController then return ToolController end
    pcall(function()
        local knit = RS:FindFirstChild("Knit")
        knit = knit and knit:FindFirstChild("Knit")
        if knit then ToolController = require(knit).GetController("ToolController") end
    end)
    return ToolController
end
local function aliveTarget(model)
    if typeof(model) ~= "Instance" or not model.Parent or model == character() then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and model:FindFirstChild("HumanoidRootPart") ~= nil
end
local function nearestTarget()
    local c = character()
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild("Characters")
    if not (root and folder) then return nil end
    local best, bestDistance
    bestDistance = M.Config.TargetRange
    for _, model in ipairs(folder:GetChildren()) do
        if aliveTarget(model) then
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            local distance = (targetRoot.Position - root.Position).Magnitude
            local owned = model:GetAttribute("HitboxNPC") and model:FindFirstChild("Owner")
                and model.Owner.Value == c
            if not owned and model.Name ~= "HarutaSwordNPC" and distance < bestDistance then
                best, bestDistance = model, distance
            end
        end
    end
    return best
end
local function resolveTarget()
    if aliveTarget(state.target) then return state.target, "server Hit" end
    if aliveTarget(state.capturedTarget) then return state.capturedTarget, "cast aim" end
    local tc = controller()
    if tc then
        local ok, target = pcall(function() return tc:GetTarget() end)
        if ok and aliveTarget(target) then return target, "ToolController" end
    end
    local target = nearestTarget()
    return target, target and "nearest" or "none"
end
local function pairedPress(target)
    local move = moveInstance()
    local activated, deactivated = remote("Activated"), remote("Deactivated")
    if not move then return false, "Garuda Rebound is not equipped" end
    if not (activated and deactivated) then return false, "Garuda remotes are missing" end
    local ok, err = pcall(function()
        activated:FireServer(move, target)
        task.wait(M.Config.ReleaseDelay)
        deactivated:FireServer(move, target)
    end)
    return ok, err
end
local function waitUntil(deadline, token)
    while not destroyed and M.Enabled and token == state.token and os.clock() < deadline do
        task.wait(math.min(0.03, math.max(0, deadline - os.clock())))
    end
end
local function arm(source)
    if destroyed or not M.Enabled or state.busy or os.clock() < state.ignoreUntil then return end
    local c = character()
    if not c or c:GetAttribute("Moveset") ~= "Yuki" or not moveInstance() then return end
    state.token = state.token + 1
    local token = state.token
    state.busy, state.confirmed = true, false
    state.source, state.phase, state.attempts = source, "armed", 0
    state.target = nil
    state.capturedTarget = select(1, resolveTarget())
    local fireAt = os.clock() + M.Config.Delay
    state.ignoreUntil = fireAt + M.Config.RetryCount * (M.Config.ReleaseDelay + M.Config.RetryGap) + 1.0
    log("armed from", source, "target", state.capturedTarget and state.capturedTarget.Name or "nil")
    task.spawn(function()
        waitUntil(fireAt, token)
        for attempt = 1, M.Config.RetryCount do
            if destroyed or not M.Enabled or token ~= state.token or state.confirmed then break end
            local target, targetSource = resolveTarget()
            state.attempts, state.phase = attempt, "sending pair"
            local ok, err = pairedPress(target)
            log("pair", attempt, ok, targetSource, target and target.Name or "nil", err or "")
            if not ok then
                state.lastError, state.phase = tostring(err), "error"
                notify("Failed: " .. tostring(err))
                break
            end
            if attempt < M.Config.RetryCount then waitUntil(os.clock() + M.Config.RetryGap, token) end
        end
        task.delay(1.4, function()
            if token == state.token then
                if not state.confirmed and state.phase ~= "error" then state.phase = "sent; no confirmation" end
                state.busy = false
            end
        end)
    end)
end
local function confirm(name)
    if not state.busy then return end
    state.confirmed, state.phase = true, "confirmed: " .. name
    state.ignoreUntil = math.max(state.ignoreUntil, os.clock() + 1.5)
    state.token = state.token + 1
    state.busy = false
    log(state.phase, "after", state.attempts, "pair(s)")
    notify("Rebound confirmed (" .. name .. ")")
end
local function hookEffects()
    local effects = remote("Effects")
    if not effects then return false end
    track(effects.OnClientEvent:Connect(function(name, a, b, c, d)
        local myCharacter = character()
        if name == "Hit" and a == LocalPlayer and aliveTarget(b) then
            state.target = b
            log("server Hit target", b.Name)
        elseif name == "Recall" and a == myCharacter then
            local duration = tonumber(d)
            log("Recall", duration or "nil")
            if duration and math.abs(duration - 0.1) <= 0.06 then confirm("Recall 0.1") end
            if duration and math.abs(duration - 1.8) <= 0.2 and state.busy then
                state.token = state.token + 1
                state.busy, state.phase = false, "whiff"
            end
        elseif (name == "Punch" and a == myCharacter)
            or (name == "Woosh" and a == myCharacter)
            or (name == "HeavyHit" and a == LocalPlayer) then
            confirm(name)
        elseif name == "Startup" and a == myCharacter then
            -- AnimationPlayed is primary. This delayed fallback covers missed animation events.
            local seenToken = state.token
            task.delay(0.12, function()
                if not state.busy and state.token == seenToken then arm("Startup fallback") end
            end)
        end
    end))
    return true
end
local function hookCharacter(c)
    disconnect(charConnections)
    state.token = state.token + 1
    state.busy, state.phase, state.target, state.ignoreUntil = false, "ready", nil, 0
    local humanoid = c:WaitForChild("Humanoid", 10)
    local animator = humanoid and humanoid:WaitForChild("Animator", 10)
    if not animator then state.lastError = "Animator missing" return end
    local animation = RS:FindFirstChild("Animations")
    animation = animation and animation:FindFirstChild("Yuki")
    animation = animation and animation:FindFirstChild("GarudaRebound")
    if animation and animation:IsA("Animation") then state.animationId = animation.AnimationId end
    track(animator.AnimationPlayed:Connect(function(track)
        local id = track.Animation and track.Animation.AnimationId or ""
        if id == state.animationId or id:match("%d+") == state.animationId:match("%d+") then
            arm("Garuda animation")
        end
    end), charConnections)
end

function M.Start()
    M.Enabled, M.enabled = true, true
    state.phase = "ready"
    return true
end
function M.Stop()
    M.Enabled, M.enabled = false, false
    state.token = state.token + 1
    state.busy, state.phase = false, "disabled"
    return false
end
function M.SetDelay(seconds)
    seconds = tonumber(seconds)
    if not seconds then return false end
    M.Config.Delay = math.clamp(seconds, 0.65, 1.50)
    log("delay set to", M.Config.Delay)
    return true
end
function M.Status()
    return {
        version = M.Version, enabled = M.Enabled, phase = state.phase, source = state.source,
        attempts = state.attempts, confirmed = state.confirmed, target = state.target and state.target.Name,
        capturedTarget = state.capturedTarget and state.capturedTarget.Name, animationId = state.animationId,
        move = moveInstance() and moveInstance():GetFullName(), activated = remote("Activated") and remote("Activated"):GetFullName(),
        deactivated = remote("Deactivated") and remote("Deactivated"):GetFullName(), effects = remote("Effects") and remote("Effects"):GetFullName(),
        delay = M.Config.Delay, retryCount = M.Config.RetryCount, lastError = state.lastError,
    }
end
function M.Destroy()
    destroyed, M.Enabled, M.enabled = true, false, false
    state.token = state.token + 1
    disconnect(charConnections)
    disconnect(connections)
    if rawget(_G, "NH_AutoGaruda") == M then _G.NH_AutoGaruda = nil end
    if rawget(_G, "AG") == M then _G.AG = nil end
    if rawget(ENV, "NH_AutoGaruda") == M then ENV.NH_AutoGaruda = nil end
    if rawget(ENV, "AG") == M then ENV.AG = nil end
end

-- Compatibility surface used by the existing Fluent toggle and older debug calls.
function M.start() return M.Start() end
function M.stop() return M.Stop() end
function M.toggle() if M.Enabled then return M.Stop() else return M.Start() end end
function M.press() return pairedPress(select(1, resolveTarget())) end
function M.debug() return M.Status() end
function M.log() local s = M.Status(); print("[NH AG4]", s.phase, s.attempts, s.target or s.capturedTarget or "nil"); return s end
function M._destroy() return M.Destroy() end

if not hookEffects() then state.lastError = "Effects remote missing" end
if LocalPlayer.Character then task.spawn(hookCharacter, LocalPlayer.Character) end
track(LocalPlayer.CharacterAdded:Connect(hookCharacter))
log("v" .. M.Version .. " backend ready; animation", state.animationId)

return M
    end)
    if not okAG then
        warn("[NH HUB] Auto Garuda module failed: " .. tostring(errAG))
    end
end

-- ============================================================
-- NH COOLDOWN VIEWER v1.2  (integrated module)
-- Autostart suppressed; toggled from Extras tab.
-- ============================================================
do
    local okCD, errCD = pcall(function()
--=====================================================================
-- NH Cooldown Viewer  v1.2
--
-- Compact panel pinned to the SIDE of any player/NPC humanoid showing
-- their moveset, live move cooldowns, and their ultimate charge.
--
--   * anyone within AutoRadius studs  -> shows automatically, no aiming
--   * anyone further out              -> aim at or face them to show
--
-- FULLY SELF-CONTAINED. Does not touch St, Cn, makeStroke, notify or any
-- other local from the hub chunk. Talks only through _G.NH_CDViewer.
--
-- v1.2 changes
--   * ult bar across the very top, tinted with that character's own
--     UltNames colours, showing a "G" glyph when it's actually ready
--   * move name text and the moveset name both made prominent
--   * cooldown bars thickened 2px -> 3px (readable, still not chunky)
--
-- v1.1 changes
--   * constant screen-space side offset, auto left/right flip
--   * timers/bars redraw every frame; instance scan throttled to ScanHz
--   * stable row order by Key; grace period + fade to stop strobing
--=====================================================================

if _G.NH_CDViewer and _G.NH_CDViewer.stop then
	pcall(_G.NH_CDViewer.stop)
end

local CD = {}
_G.NH_CDViewer = CD

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- The game's own ult colour table: { displayName, colour1, colour2, bool }
-- keyed by the character's "Moveset" attribute. Required live rather than
-- hardcoded so it stays correct if the game adds movesets.
local UltNames = nil
pcall(function()
	UltNames = require(ReplicatedStorage.Modules.UltNames)
end)

--=====================================================================
-- CONFIG   (live-editable:  _G.NH_CDViewer.Config.AutoRadius = 15)
--=====================================================================
CD.Config = {
	-- "smart"  = everyone within AutoRadius, PLUS whoever you aim at / face
	-- "target" = only who you aim at / face
	-- "nearby" = everyone within AutoRadius only
	-- "all"    = everyone within MaxDistance
	Mode = "smart",

	AutoRadius = 10,
	MaxDistance = 300,
	FaceAngle = 20,
	MaxPanels = 6,

	ShowReady = true,
	ShowPlayers = true,
	ShowNPCs = true,
	ShowUlt = true,
	ShowEvade = true,   -- thin strip under the ult bar: the target's evade charge
	EvadeOnly = false,  -- draw ONLY the evade strip: no move rows, no ult bar
	MaxRows = 10,

	Side = "auto",     -- "auto" | "right" | "left"
	GapPx = 30,
	Width = 124,
	Scale = 1,
	UltGlyph = "G",    -- shown inside the ult bar when it's ready
	EvadeGlyph = "E",  -- shown inside the evade bar once it is full
	EvadeMax = 50,     -- game draws the meter as Evade / 50; retune here if that changes

	ScanHz = 10,
	LostGrace = 0.45,
	FadeTime = 0.14,
}
local Cfg = CD.Config

CD.enabled = false

--=====================================================================
-- INTERNAL STATE
--=====================================================================
local panels = {}
local moveState = setmetatable({}, { __mode = "k" })
local loopConn = nil
local guiFolder = nil
local scanAccum = 0

local COL_BG = Color3.fromRGB(12, 12, 16)
local COL_EDGE = Color3.fromRGB(255, 255, 255)
local COL_TITLE = Color3.fromRGB(245, 245, 252)
local COL_SUB = Color3.fromRGB(130, 130, 150)
local COL_NAME = Color3.fromRGB(228, 228, 240)
local COL_HOT = Color3.fromRGB(255, 250, 250)
local COL_READY = Color3.fromRGB(78, 228, 98)
local COL_CD = Color3.fromRGB(220, 64, 64)
local COL_SOON = Color3.fromRGB(240, 180, 48)
local COL_AWK = Color3.fromRGB(255, 190, 60)
local COL_SEAL = Color3.fromRGB(255, 175, 0)
local COL_ULTBG = Color3.fromRGB(30, 30, 38)
-- evade strip: muted blue while charging, bright blue at full, matching the
-- blue glow the game itself puts on a ready evade meter
local COL_EV_LOW = Color3.fromRGB(70, 105, 150)
local COL_EV_FULL = Color3.fromRGB(90, 180, 255)

-- layout constants, all multiplied by Cfg.Scale
local ULT_H = 8
local ULT_GAP = 3
local EV_H = 5
local EV_GAP = 3
local TITLE_H = 12
local SUB_H = 10
local SUB_GAP = 3
local ROW_H = 16
local ROW_PAD = 2

--=====================================================================
-- HELPERS
--=====================================================================
local function px(v)
	return math.floor(v * Cfg.Scale + 0.5)
end

local function getGuiFolder()
	if guiFolder and guiFolder.Parent then
		return guiFolder
	end
	local host = nil
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then
			host = h
		end
	end
	if not host then
		host = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
	local f = Instance.new("Folder")
	f.Name = "NHCDV"
	f.Parent = host
	guiFolder = f
	return f
end

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = inst
end

local function hex(c)
	return string.format(
		"#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5)
	)
end

-- Several movesets have pitch-black ult colours in UltNames -- Yuki is
-- (0,0,0), Megumi is (45,45,45), Choso's second colour is (0,0,0). On a
-- near-black card those are invisible, so lift anything too dark.
local function ensureVisible(c)
	local lum = 0.2126 * c.R + 0.7152 * c.G + 0.0722 * c.B
	if lum < 0.16 then
		return c:Lerp(Color3.fromRGB(235, 235, 245), 0.62)
	end
	return c
end

local function ultColors(setName)
	local e = setName and UltNames and UltNames[setName]
	if e and typeof(e[2]) == "Color3" then
		local c1 = ensureVisible(e[2])
		local c2 = typeof(e[3]) == "Color3" and ensureVisible(e[3]) or c1
		return c1, c2
	end
	return Color3.fromRGB(120, 170, 255), Color3.fromRGB(60, 95, 205)
end

-- Verbatim from ToolController:GetTarget().
-- HitboxNPC is an ATTRIBUTE with an Owner check, NOT a character name.
local function isExcluded(char)
	if char.Name == "HarutaSwordNPC" then
		return true
	end
	if char:GetAttribute("HitboxNPC") then
		local owner = char:FindFirstChild("Owner")
		if not owner or owner.Value == LocalPlayer.Character then
			return true
		end
	end
	return false
end

local function validRoot(char)
	if not char or not char.Parent then
		return nil
	end
	if char == LocalPlayer.Character then
		return nil
	end
	if isExcluded(char) then
		return nil
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return nil
	end
	local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
	if not root then
		return nil
	end
	local isPlayer = Players:GetPlayerFromCharacter(char) ~= nil
	if isPlayer and not Cfg.ShowPlayers then
		return nil
	end
	if not isPlayer and not Cfg.ShowNPCs then
		return nil
	end
	return root
end

local function charFolder()
	return workspace:FindFirstChild("Characters")
end

local function isTouchInput()
	local ok, pref = pcall(function()
		return UserInputService.PreferredInput == Enum.PreferredInput.Touch
	end)
	if ok then
		return pref
	end
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- EXACT mirror of the aim origin in ToolController:GetTarget().
local function getAimPoint()
	if isTouchInput() then
		local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		local controls = pg and pg:FindFirstChild("Controls")
		local ch = controls and controls:FindFirstChild("Crosshair")
		if ch then
			return ch.AbsolutePosition
		end
	end
	if mouse then
		return Vector2.new(mouse.X, mouse.Y)
	end
	local vp = Camera.ViewportSize
	return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
end

local function fmtTime(t)
	if t >= 10 then
		return string.format("%.0fs", t)
	end
	return string.format("%.1fs", t)
end

--=====================================================================
-- ULT STATE
--  "Ultimate" is an attribute on the PLAYER, not the character. Proven
--  by ReplicatedStorage.Utils.Reveal.Handle, which does
--    local u1 = game.Players:GetPlayerFromCharacter(Parent)
--    Fill.Size = UDim2.new(1, 0, u1:GetAttribute("Ultimate") / 100, 0)
--  on ANY revealed player. NPCs have no Player object, so they get no
--  ult bar -- the game guards the same way with `not v19 and 0`.
--
--  "Ready" mirrors Bar.Ready.Visible from the local HUD:
--    v134 = not InUlt and not Info:GetAttribute("Ult")
--    Yuki   : v134 = v134 and Dead and not LastResort
--    Haruta : v134 = v134 and Sword == nil
--    MeiMei : v133 = Info.ControlRemote:GetAttribute("Active")
--    ready  = (v134 and Ultimate >= 100) or v133
--=====================================================================
local function readUlt(char)
	local plr = Players:GetPlayerFromCharacter(char)
	if not plr then
		return nil
	end

	local pct = (plr:GetAttribute("Ultimate") or 0) / 100
	pct = math.clamp(pct, 0, 1)

	local info = char:FindFirstChild("Info")
	local inUlt = char:GetAttribute("InUlt") == true
	local setName = char:GetAttribute("Moveset")

	local canAwaken = false
	if info and not inUlt then
		canAwaken = not info:GetAttribute("Ult")
	end

	if setName == "Yuki" then
		canAwaken = (
			canAwaken
			and char:GetAttribute("Dead")
			and not char:GetAttribute("LastResort")
		) and true or false
	elseif setName == "Haruta" then
		if canAwaken then
			canAwaken = char:GetAttribute("Sword") == nil
		end
	end

	local altReady = false
	if setName == "MeiMei" and info then
		local cr = info:FindFirstChild("ControlRemote")
		altReady = (cr and cr:GetAttribute("Active")) and true or false
	end

	local ult2 = char:GetAttribute("Ult2")

	return {
		pct = pct,
		ready = (canAwaken and pct >= 1) or altReady,
		full = pct >= 1,
		inUlt = inUlt,
		ult2 = ult2 and math.clamp(ult2 / 100, 0, 1) or nil,
	}
end

--=====================================================================
-- EVADE STATE
--   The evade meter is a plain number attribute on the CHARACTER, which is
--   why this works on enemies at all -- character attributes replicate, so
--   we can read theirs the same way the game reads ours. Its own HUD does:
--     Fill.Size = UDim2.new(char:GetAttribute("Evade") / 50, 0, 1, 0)
--   A full meter is what matters: that is when the dash-escape is available
--   (in-game the bar glows blue at that point).
--
--   Returns a 0-1 fraction, or nil when the attribute is missing/not a
--   number -- nil hides the bar rather than drawing a fake empty one, so a
--   renamed attribute after a game update degrades quietly instead of
--   reading as "enemy has no evade".
--=====================================================================
local function readEvade(char)
	local raw = char:GetAttribute("Evade")
	if type(raw) ~= "number" then
		return nil
	end
	local maxv = tonumber(Cfg.EvadeMax) or 50
	if maxv <= 0 then
		maxv = 50
	end
	return math.clamp(raw / maxv, 0, 1)
end

--=====================================================================
-- MOVE READING
--=====================================================================
local function collectMoves(char)
	local ms = char:FindFirstChild("Moveset")
	if not ms then
		return nil
	end

	local inUlt = char:GetAttribute("InUlt") == true
	local now = workspace:GetServerTimeNow()
	local out = {}

	for _, mv in ipairs(ms:GetChildren()) do
		if mv:IsA("NumberValue") and not mv:GetAttribute("FakeMove") then
			local awk = mv:GetAttribute("AWK")
			local awk2 = mv:GetAttribute("AWK2")
			local hidden = (awk and inUlt) or (awk2 and not inUlt)

			if not hidden then
				local ra = mv:GetAttribute("ReadyAt")
				local rec = moveState[mv]

				if not rec then
					rec = { readyAt = ra, total = nil, exact = false }
					if ra then
						local rem = ra - now
						if rem > 0 then
							rec.total = rem
						end
					end
					moveState[mv] = rec
				elseif ra ~= rec.readyAt then
					rec.readyAt = ra
					if ra then
						rec.total = math.max(ra - now, 0.05)
						rec.exact = true
					else
						rec.total = nil
						rec.exact = false
					end
				end

				out[#out + 1] = {
					name = mv:GetAttribute("Tag") or mv.Name,
					key = tonumber(mv:GetAttribute("Key")),
					readyAt = ra,
					total = rec.total,
					exact = rec.exact,
					seal = mv:GetAttribute("Seal"),
				}
			end
		end
	end

	-- stable order by Key, matching the game's LayoutOrder. sorting by
	-- remaining time would make rows swap as timers cross = chop.
	table.sort(out, function(a, b)
		local ak = a.key or 99
		local bk = b.key or 99
		if ak ~= bk then
			return ak < bk
		end
		return a.name < b.name
	end)

	return out
end

--=====================================================================
-- PANEL CONSTRUCTION
--=====================================================================
local function buildRow(parent, index)
	local row = Instance.new("Frame")
	row.Name = "Row" .. index
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, px(ROW_H))
	row.LayoutOrder = index
	row.Visible = false
	row.Parent = parent

	local keyBadge = Instance.new("TextLabel")
	keyBadge.Name = "Key"
	keyBadge.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
	keyBadge.BackgroundTransparency = 0.25
	keyBadge.BorderSizePixel = 0
	keyBadge.Size = UDim2.fromOffset(px(13), px(13))
	keyBadge.Position = UDim2.fromOffset(0, 0)
	keyBadge.Font = Enum.Font.GothamBold
	keyBadge.TextSize = px(9)
	keyBadge.TextColor3 = Color3.fromRGB(195, 195, 210)
	keyBadge.Text = ""
	keyBadge.Parent = row
	corner(keyBadge, px(3))

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Name = "MoveName"
	nameLbl.BackgroundTransparency = 1
	nameLbl.Position = UDim2.fromOffset(px(17), 0)
	nameLbl.Size = UDim2.new(1, px(-53), 0, px(12))
	nameLbl.Font = Enum.Font.GothamMedium
	nameLbl.TextSize = px(11)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.TextColor3 = COL_NAME
	nameLbl.Text = ""
	nameLbl.Parent = row

	local timeLbl = Instance.new("TextLabel")
	timeLbl.Name = "Time"
	timeLbl.BackgroundTransparency = 1
	timeLbl.AnchorPoint = Vector2.new(1, 0)
	timeLbl.Position = UDim2.new(1, 0, 0, 0)
	timeLbl.Size = UDim2.fromOffset(px(34), px(12))
	timeLbl.Font = Enum.Font.GothamBold
	timeLbl.TextSize = px(10)
	timeLbl.TextXAlignment = Enum.TextXAlignment.Right
	timeLbl.Text = ""
	timeLbl.Parent = row

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.AnchorPoint = Vector2.new(0, 1)
	barBg.Position = UDim2.new(0, px(17), 1, 0)
	barBg.Size = UDim2.new(1, px(-17), 0, px(3))
	barBg.BackgroundColor3 = Color3.fromRGB(52, 52, 62)
	barBg.BackgroundTransparency = 0.35
	barBg.BorderSizePixel = 0
	barBg.Parent = row
	corner(barBg, px(2))

	local barFill = Instance.new("Frame")
	barFill.Name = "Fill"
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = COL_CD
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg
	corner(barFill, px(2))

	return {
		root = row,
		key = keyBadge,
		name = nameLbl,
		time = timeLbl,
		barBg = barBg,
		bar = barFill,
	}
end

local function cardHeight(shown, hasUlt, hasEv, evadeOnly)
	local top = (hasUlt and (px(ULT_H) + px(ULT_GAP)) or 0)
		+ (hasEv and (px(EV_H) + px(EV_GAP)) or 0)
	if evadeOnly then
		-- nothing but the strip: no title, no sub line, no move rows. The
		-- trailing EV_GAP is dropped too, since there is nothing below it
		-- left to space away from.
		return math.max(px(4) + top - (hasEv and px(EV_GAP) or 0) + px(4), px(11))
	end
	local h = px(4)
		+ top
		+ px(TITLE_H)
		+ px(SUB_H)
		+ px(SUB_GAP)
		+ shown * (px(ROW_H) + px(ROW_PAD))
		+ px(4)
	return math.max(h, px(34))
end

local function buildPanel(char, root)
	local W = px(Cfg.Width)
	local GAP = px(Cfg.GapPx)

	-- Billboard is centred on the character and sized in OFFSET units, so
	-- the card sits a constant number of PIXELS to the side at any range.
	-- StudsOffset could never do this -- its screen gap collapses with
	-- distance, which is why v1.0 covered the enemy when they were far.
	local bb = Instance.new("BillboardGui")
	bb.Name = "NHCDV_Panel"
	bb.Adornee = root
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.ClipsDescendants = false
	bb.MaxDistance = Cfg.MaxDistance
	bb.Size = UDim2.fromOffset((W + GAP) * 2, px(260))
	bb.Parent = getGuiFolder()

	local card = Instance.new("CanvasGroup")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0, 0.5)
	card.Position = UDim2.new(0.5, GAP, 0.5, 0)
	card.Size = UDim2.fromOffset(W, cardHeight(0, false, false))
	card.BackgroundColor3 = COL_BG
	card.BackgroundTransparency = 0.2
	card.BorderSizePixel = 0
	card.GroupTransparency = 1
	card.Parent = bb
	corner(card, px(5))

	local edge = Instance.new("UIStroke")
	edge.Color = COL_EDGE
	edge.Thickness = 1
	edge.Transparency = 0.86
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Parent = card

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, px(4))
	pad.PaddingBottom = UDim.new(0, px(4))
	pad.PaddingLeft = UDim.new(0, px(6))
	pad.PaddingRight = UDim.new(0, px(6))
	pad.Parent = card

	-- ---------------- ult bar (very top) ----------------
	local ultBg = Instance.new("Frame")
	ultBg.Name = "Ult"
	ultBg.BackgroundColor3 = COL_ULTBG
	ultBg.BackgroundTransparency = 0.2
	ultBg.BorderSizePixel = 0
	ultBg.Position = UDim2.fromOffset(0, 0)
	ultBg.Size = UDim2.new(1, 0, 0, px(ULT_H))
	ultBg.Visible = false
	ultBg.Parent = card
	corner(ultBg, px(3))

	local ultFill = Instance.new("Frame")
	ultFill.Name = "UltFill"
	ultFill.BackgroundColor3 = Color3.fromRGB(120, 170, 255)
	ultFill.BorderSizePixel = 0
	ultFill.Size = UDim2.fromScale(0, 1)
	ultFill.Parent = ultBg
	corner(ultFill, px(3))

	local ultGrad = Instance.new("UIGradient")
	ultGrad.Parent = ultFill

	-- secondary charge (Hakari etc). Character attribute "Ult2", drawn by
	-- the game as a rainbow strip: Color3.fromHSV(t % 1, 0.7, 1)
	local ult2Fill = Instance.new("Frame")
	ult2Fill.Name = "Ult2Fill"
	ult2Fill.AnchorPoint = Vector2.new(0, 1)
	ult2Fill.Position = UDim2.new(0, 0, 1, 0)
	ult2Fill.Size = UDim2.new(0, 0, 0, px(2))
	ult2Fill.BorderSizePixel = 0
	ult2Fill.Visible = false
	ult2Fill.Parent = ultBg

	local ultGlyph = Instance.new("TextLabel")
	ultGlyph.Name = "UltGlyph"
	ultGlyph.BackgroundTransparency = 1
	ultGlyph.Size = UDim2.fromScale(1, 1)
	ultGlyph.Font = Enum.Font.GothamBold
	ultGlyph.TextSize = px(8)
	ultGlyph.TextColor3 = Color3.fromRGB(255, 255, 255)
	ultGlyph.Text = Cfg.UltGlyph
	ultGlyph.Visible = false
	ultGlyph.ZIndex = 4
	ultGlyph.Parent = ultBg

	local glyphStroke = Instance.new("UIStroke")
	glyphStroke.Color = Color3.fromRGB(0, 0, 0)
	glyphStroke.Thickness = 1.4
	glyphStroke.Transparency = 0.35
	glyphStroke.Parent = ultGlyph

	-- ---------------- evade bar (sits under the ult bar) ----------------
	-- Deliberately thinner than the ult bar: it is a charge meter, not a
	-- cooldown row, so it should read at a glance without competing with the
	-- move list underneath.
	local evBg = Instance.new("Frame")
	evBg.Name = "Evade"
	evBg.BackgroundColor3 = COL_ULTBG
	evBg.BackgroundTransparency = 0.2
	evBg.BorderSizePixel = 0
	evBg.Position = UDim2.fromOffset(0, 0)
	evBg.Size = UDim2.new(1, 0, 0, px(EV_H))
	evBg.Visible = false
	evBg.Parent = card
	corner(evBg, px(2))

	local evFill = Instance.new("Frame")
	evFill.Name = "EvadeFill"
	evFill.BackgroundColor3 = COL_EV_LOW
	evFill.BorderSizePixel = 0
	evFill.Size = UDim2.fromScale(0, 1)
	evFill.Parent = evBg
	corner(evFill, px(2))

	local evGlyph = Instance.new("TextLabel")
	evGlyph.Name = "EvadeGlyph"
	evGlyph.BackgroundTransparency = 1
	evGlyph.Size = UDim2.fromScale(1, 1)
	evGlyph.Font = Enum.Font.GothamBold
	evGlyph.TextSize = px(7)
	evGlyph.TextColor3 = Color3.fromRGB(255, 255, 255)
	evGlyph.Text = Cfg.EvadeGlyph
	evGlyph.Visible = false
	evGlyph.ZIndex = 4
	evGlyph.Parent = evBg

	local evStroke = Instance.new("UIStroke")
	evStroke.Color = Color3.fromRGB(0, 0, 0)
	evStroke.Thickness = 1.4
	evStroke.Transparency = 0.35
	evStroke.Parent = evGlyph

	-- ---------------- title / sub ----------------
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, px(TITLE_H))
	title.Font = Enum.Font.GothamBold
	title.TextSize = px(11)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextColor3 = COL_TITLE
	title.Text = char.Name
	title.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, 0, 0, px(SUB_H))
	sub.Font = Enum.Font.GothamBold
	sub.TextSize = px(10)
	sub.RichText = true
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextTruncate = Enum.TextTruncate.AtEnd
	sub.TextColor3 = COL_SUB
	sub.Text = ""
	sub.Parent = card

	local list = Instance.new("Frame")
	list.Name = "Rows"
	list.BackgroundTransparency = 1
	list.Size = UDim2.new(1, 0, 1, px(-25))
	list.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, px(ROW_PAD))
	layout.Parent = list

	local rows = {}
	for i = 1, Cfg.MaxRows do
		rows[i] = buildRow(list, i)
	end

	TweenService:Create(card, TweenInfo.new(Cfg.FadeTime), {
		GroupTransparency = 0,
	}):Play()

	return {
		char = char,
		gui = bb,
		card = card,
		ultBg = ultBg,
		ultFill = ultFill,
		ultGrad = ultGrad,
		ult2Fill = ult2Fill,
		ultGlyph = ultGlyph,
		evBg = evBg,
		evFill = evFill,
		evGlyph = evGlyph,
		title = title,
		sub = sub,
		list = list,
		rows = rows,
		moves = nil,
		ult = nil,
		ultDisp = 0,
		evade = nil,
		evDisp = 0,
		col1 = Color3.fromRGB(120, 170, 255),
		col2 = Color3.fromRGB(60, 95, 205),
		lastSeen = os.clock(),
		dying = false,
		curH = cardHeight(0, false, false),
		curTop = -1,
		sizeTween = nil,
		side = "right",
		width = W,
		gap = GAP,
	}
end

local function destroyPanel(char, immediate)
	local p = panels[char]
	if not p then
		return
	end
	panels[char] = nil
	if immediate or not p.card or not p.card.Parent then
		if p.gui then
			p.gui:Destroy()
		end
		return
	end
	p.dying = true
	TweenService:Create(p.card, TweenInfo.new(Cfg.FadeTime), {
		GroupTransparency = 1,
	}):Play()
	local gui = p.gui
	task.delay(Cfg.FadeTime + 0.02, function()
		if gui then
			gui:Destroy()
		end
	end)
end

--=====================================================================
-- SCAN  (ScanHz -- touches instances, reads attributes)
--=====================================================================
local function scanCandidates()
	local wanted = {}
	local folder = charFolder()
	if not folder then
		return wanted
	end

	local mode = Cfg.Mode
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local camPos = Camera.CFrame.Position
	local refPos = myRoot and myRoot.Position or camPos
	local lookDir = Camera.CFrame.LookVector

	local origin = getAimPoint()
	local aimRadius = Camera.ViewportSize.Y / 5

	local wantAuto = (mode == "smart" or mode == "nearby" or mode == "all")
	local wantAim = (mode == "smart" or mode == "target")
	local autoLimit = (mode == "all") and Cfg.MaxDistance or Cfg.AutoRadius

	local near = {}
	local bestAim, bestScore = nil, math.huge

	for _, char in ipairs(folder:GetChildren()) do
		local root = validRoot(char)
		if root then
			local pos = root.Position

			if wantAuto then
				local d = (pos - refPos).Magnitude
				if d <= autoLimit then
					near[#near + 1] = { char = char, dist = d }
				end
			end

			if wantAim then
				local delta = pos - camPos
				local camDist = delta.Magnitude
				if camDist > 0.01 and camDist <= Cfg.MaxDistance then
					local sp, onScreen = Camera:WorldToScreenPoint(pos)
					if onScreen then
						local screenD = (Vector2.new(sp.X, sp.Y) - origin).Magnitude
						local dot = math.clamp(lookDir:Dot(delta.Unit), -1, 1)
						local angle = math.deg(math.acos(dot))
						if screenD < aimRadius or angle <= Cfg.FaceAngle then
							if screenD < bestScore then
								bestScore = screenD
								bestAim = char
							end
						end
					end
				end
			end
		end
	end

	table.sort(near, function(a, b)
		return a.dist < b.dist
	end)

	local budget = Cfg.MaxPanels
	if bestAim then
		wanted[bestAim] = true
		budget = budget - 1
	end
	for i = 1, #near do
		if budget <= 0 then
			break
		end
		local c = near[i].char
		if not wanted[c] then
			wanted[c] = true
			budget = budget - 1
		end
	end

	return wanted
end

local function scan()
	local wanted = scanCandidates()
	local now = os.clock()

	for char in pairs(wanted) do
		local root = validRoot(char)
		if root then
			local p = panels[char]
			if not p or p.dying or not p.gui.Parent then
				if p then
					destroyPanel(char, true)
				end
				p = buildPanel(char, root)
				panels[char] = p
			end
			if p.gui.Adornee ~= root then
				p.gui.Adornee = root
			end
			p.lastSeen = now
			-- Evade-only mode skips the expensive work outright: no move scan and
			-- no ult resolve. That is the point of the standalone switch -- it runs
			-- the viewer without paying for the parts you did not ask for.
			local evadeOnly = Cfg.EvadeOnly == true
			p.moves = (not evadeOnly) and collectMoves(char) or nil
			p.title.Text = char.Name
			p.inUlt = char:GetAttribute("InUlt") == true
			p.setName = char:GetAttribute("Moveset")
			p.isPlayer = Players:GetPlayerFromCharacter(char) ~= nil
			p.col1, p.col2 = ultColors(p.setName)
			p.ult = (not evadeOnly) and Cfg.ShowUlt and readUlt(char) or nil
			-- read the meter regardless of ShowEvade when this IS the evade mode
			p.evade = (evadeOnly or Cfg.ShowEvade) and readEvade(char) or nil
		end
	end

	local drop = {}
	for char, p in pairs(panels) do
		if not validRoot(char) then
			drop[#drop + 1] = char
		elseif not wanted[char] and (now - p.lastSeen) > Cfg.LostGrace then
			drop[#drop + 1] = char
		end
	end
	for _, char in ipairs(drop) do
		destroyPanel(char, false)
	end
end

--=====================================================================
-- ANIMATE  (every frame -- pure maths on cached values)
--=====================================================================
local function animate(dt)
	local now = workspace:GetServerTimeNow()
	local clk = os.clock()
	local vpHalf = Camera.ViewportSize.X * 0.5

	for _, p in pairs(panels) do
		if p.gui.Parent and not p.dying then
			-- ---- side flip, hysteresis so it cannot oscillate ----
			if Cfg.Side == "auto" then
				local adornee = p.gui.Adornee
				if adornee then
					local sp = Camera:WorldToScreenPoint(adornee.Position)
					if p.side == "right" and sp.X > vpHalf * 1.16 then
						p.side = "left"
					elseif p.side == "left" and sp.X < vpHalf * 0.84 then
						p.side = "right"
					end
				end
			else
				p.side = Cfg.Side
			end

			if p.side == "left" then
				p.card.AnchorPoint = Vector2.new(1, 0.5)
				p.card.Position = UDim2.new(0.5, -p.gap, 0.5, 0)
			else
				p.card.AnchorPoint = Vector2.new(0, 0.5)
				p.card.Position = UDim2.new(0.5, p.gap, 0.5, 0)
			end

			-- ---- ult bar ----
			local u = p.ult
			local hasUlt = u ~= nil
			p.ultBg.Visible = hasUlt

			if hasUlt then
				-- same easing the game uses on its own bar:
				--   Scale + (target - Scale) * (10 * dt)
				p.ultDisp = p.ultDisp + (u.pct - p.ultDisp) * math.clamp(10 * dt, 0, 1)
				p.ultFill.Size = UDim2.fromScale(math.clamp(p.ultDisp, 0, 1), 1)
				p.ultFill.BackgroundColor3 = p.col1
				p.ultGrad.Color = ColorSequence.new(p.col1, p.col2)

				if u.ready then
					-- gentle pulse so a ready ult reads at a glance
					local pulse = 0.06 + 0.14 * (0.5 + 0.5 * math.sin(clk * 5))
					p.ultFill.BackgroundTransparency = pulse
					p.ultGlyph.Visible = true
					p.ultGlyph.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					p.ultFill.BackgroundTransparency = 0.08
					-- full but not usable (already awakened, Yuki not downed,
					-- Haruta still holding the sword) -> dim glyph
					p.ultGlyph.Visible = u.full
					p.ultGlyph.TextColor3 = Color3.fromRGB(150, 150, 165)
				end

				if u.ult2 then
					p.ult2Fill.Visible = true
					p.ult2Fill.Size = UDim2.new(u.ult2, 0, 0, px(2))
					p.ult2Fill.BackgroundColor3 = Color3.fromHSV(clk % 1, 0.7, 1)
				else
					p.ult2Fill.Visible = false
				end
			end

			-- ---- evade bar ----
			local ev = p.evade
			local hasEv = ev ~= nil
			p.evBg.Visible = hasEv

			if hasEv then
				-- same easing as the ult bar so the two strips feel like one widget
				p.evDisp = p.evDisp + (ev - p.evDisp) * math.clamp(10 * dt, 0, 1)
				p.evFill.Size = UDim2.fromScale(math.clamp(p.evDisp, 0, 1), 1)

				if ev >= 1 then
					-- full = dash-escape ready. Pulsed, same visual language as a
					-- ready ult, so "they can escape" reads without looking twice.
					p.evFill.BackgroundColor3 = COL_EV_FULL
					p.evFill.BackgroundTransparency = 0.06 + 0.14 * (0.5 + 0.5 * math.sin(clk * 5))
					p.evGlyph.Visible = true
				else
					p.evFill.BackgroundColor3 = COL_EV_LOW
					p.evFill.BackgroundTransparency = 0.08
					p.evGlyph.Visible = false
				end
			end

			-- ---- evade-only: strip the card down to nothing but the bar ----
			-- Same scanner and same panels; we simply stop drawing everything that
			-- is not the evade strip. That is why this mode does NOT need the full
			-- cooldown viewer switched on to work.
			local evadeOnly = Cfg.EvadeOnly == true
			if p.evadeOnly ~= evadeOnly then
				p.evadeOnly = evadeOnly
				p.title.Visible = not evadeOnly
				p.sub.Visible = not evadeOnly
				p.list.Visible = not evadeOnly
				p.curTop = -1   -- force the layout below to recompute
			end
			-- a target with no readable meter has nothing to draw in this mode, so
			-- hide its card entirely rather than leaving an empty sliver floating
			p.card.Visible = (not evadeOnly) or hasEv

			-- ---- vertical layout depends on which strips are showing ----
			local ultTop = hasUlt and (px(ULT_H) + px(ULT_GAP)) or 0
			local top = ultTop + (hasEv and (px(EV_H) + px(EV_GAP)) or 0)
			if top ~= p.curTop then
				p.curTop = top
				-- evade sits directly under the ult bar, or at the very top for a
				-- target that has no ult bar at all (NPCs read nil there)
				p.evBg.Position = UDim2.fromOffset(0, ultTop)
				p.title.Position = UDim2.fromOffset(0, top)
				p.sub.Position = UDim2.fromOffset(0, top + px(TITLE_H))
				local listY = top + px(TITLE_H) + px(SUB_H) + px(SUB_GAP)
				p.list.Position = UDim2.fromOffset(0, listY)
				p.list.Size = UDim2.new(1, 0, 1, -listY)
			end

			-- ---- rows ----
			local moves = p.moves
			local shown = 0

			if not moves then
				p.sub.Text = "no moveset"
				for _, r in ipairs(p.rows) do
					r.root.Visible = false
				end
			else
				local onCd = 0

				for i = 1, Cfg.MaxRows do
					local r = p.rows[i]
					local m = moves[i]

					if not m then
						r.root.Visible = false
					else
						local remain = 0
						if m.readyAt then
							remain = m.readyAt - now
							if remain < 0 then
								remain = 0
							end
						end
						if remain > 0 then
							onCd = onCd + 1
						end

						if remain <= 0 and not m.seal and not Cfg.ShowReady then
							r.root.Visible = false
						else
							shown = shown + 1
							r.root.Visible = true
							r.name.Text = m.name
							r.key.Text = m.key and tostring(m.key) or "-"

							if m.seal then
								local sealCol = (m.seal == 2) and COL_SEAL or COL_CD
								r.time.Text = "SEAL"
								r.time.TextColor3 = sealCol
								r.name.TextColor3 = sealCol
								r.key.TextColor3 = sealCol
								r.barBg.Visible = true
								r.bar.BackgroundColor3 = sealCol
								r.bar.BackgroundTransparency = 0
								r.bar.Size = UDim2.fromScale(1, 1)
							elseif remain <= 0 then
								r.time.Text = "READY"
								r.time.TextColor3 = COL_READY
								r.name.TextColor3 = COL_NAME
								r.key.TextColor3 = COL_READY
								r.barBg.Visible = false
							else
								local col = (remain < 1) and COL_SOON or COL_CD
								r.time.Text = fmtTime(remain)
								r.time.TextColor3 = col
								r.name.TextColor3 = COL_HOT
								r.key.TextColor3 = Color3.fromRGB(150, 150, 165)
								r.barBg.Visible = true
								r.bar.BackgroundColor3 = col

								local frac = 1
								if m.total and m.total > 0 then
									frac = math.clamp(remain / m.total, 0, 1)
								end
								r.bar.Size = UDim2.fromScale(frac, 1)
								-- dim an estimated bar so it reads differently
								-- from one whose start we actually witnessed
								r.bar.BackgroundTransparency = m.exact and 0 or 0.55
							end
						end
					end
				end

				-- moveset name is the prominent part of this line
				local parts = {}
				if p.setName then
					parts[#parts + 1] = string.format(
						'<font color="%s">%s</font>',
						hex(p.col1),
						tostring(p.setName)
					)
				end
				parts[#parts + 1] = string.format(
					'<font color="%s" size="%d">%s · %d/%d</font>',
					hex(COL_SUB),
					px(9),
					p.isPlayer and "PLAYER" or "NPC",
					onCd,
					#moves
				)
				if p.inUlt then
					parts[#parts + 1] = string.format(
						'<font color="%s">AWK</font>',
						hex(COL_AWK)
					)
				end
				p.sub.Text = table.concat(parts, "  ")
			end

			-- ---- height, tweened so rows appearing doesn't snap ----
			local h = cardHeight(shown, hasUlt, hasEv, evadeOnly)
			if math.abs(h - p.curH) > 0.5 then
				p.curH = h
				if p.sizeTween then
					p.sizeTween:Cancel()
				end
				p.sizeTween = TweenService:Create(
					p.card,
					TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Size = UDim2.fromOffset(p.width, h) }
				)
				p.sizeTween:Play()
			end
		end
	end
end

--=====================================================================
-- PUBLIC API
--=====================================================================
function CD.start()
	if CD.enabled then
		return
	end
	CD.enabled = true
	scanAccum = math.huge

	loopConn = RunService.RenderStepped:Connect(function(dt)
		if not CD.enabled then
			return
		end

		scanAccum = scanAccum + dt
		local step = 1 / math.max(Cfg.ScanHz, 1)
		if scanAccum >= step then
			scanAccum = 0
			local ok, err = pcall(scan)
			if not ok then
				warn("[NH CDViewer] scan: " .. tostring(err))
			end
		end

		local ok2, err2 = pcall(animate, dt)
		if not ok2 then
			warn("[NH CDViewer] animate: " .. tostring(err2))
		end
	end)
end

function CD.stop()
	CD.enabled = false
	if loopConn then
		loopConn:Disconnect()
		loopConn = nil
	end
	local list = {}
	for char in pairs(panels) do
		list[#list + 1] = char
	end
	for _, char in ipairs(list) do
		destroyPanel(char, true)
	end
	if guiFolder then
		guiFolder:Destroy()
		guiFolder = nil
	end
end

function CD.toggle()
	if CD.enabled then
		CD.stop()
	else
		CD.start()
	end
	return CD.enabled
end

function CD.rebuild()
	local list = {}
	for char in pairs(panels) do
		list[#list + 1] = char
	end
	for _, char in ipairs(list) do
		destroyPanel(char, true)
	end
	scanAccum = math.huge
end

function CD.setMode(mode)
	if mode ~= "smart" and mode ~= "target" and mode ~= "nearby" and mode ~= "all" then
		return
	end
	Cfg.Mode = mode
	CD.rebuild()
end

function CD.setSide(side)
	if side ~= "auto" and side ~= "left" and side ~= "right" then
		return
	end
	Cfg.Side = side
end

function CD.setScale(s)
	Cfg.Scale = math.clamp(tonumber(s) or 1, 0.6, 2.5)
	CD.rebuild()
end

-- prints exactly what the game is replicating for your current target
function CD.debug()
	local wanted = scanCandidates()
	local any = false
	local now = workspace:GetServerTimeNow()
	for char in pairs(wanted) do
		any = true
		local ms = char:FindFirstChild("Moveset")
		local plr = Players:GetPlayerFromCharacter(char)
		local u = readUlt(char)
		local ev = readEvade(char)
		print("[NH CDViewer]", char.Name,
			"| moveset:", char:GetAttribute("Moveset"),
			"| moves:", ms and #ms:GetChildren() or 0,
			"| InUlt:", char:GetAttribute("InUlt"))
		print(string.format(
			"   EVADE raw=%s pct=%.2f ready=%s",
			tostring(char:GetAttribute("Evade")),
			ev or 0,
			tostring(ev ~= nil and ev >= 1)
		))
		if plr then
			print(string.format(
				"   ULT  raw=%s pct=%.2f ready=%s full=%s ult2=%s",
				tostring(plr:GetAttribute("Ultimate")),
				u and u.pct or 0,
				tostring(u and u.ready),
				tostring(u and u.full),
				tostring(u and u.ult2)
			))
		else
			print("   ULT  no Player object (NPC) -- bar hidden, as the game does")
		end
		if ms then
			for _, mv in ipairs(ms:GetChildren()) do
				local ra = mv:GetAttribute("ReadyAt")
				print(string.format(
					"   %-22s key=%-4s ReadyAt=%-18s LastUse=%-18s remain=%s",
					tostring(mv:GetAttribute("Tag") or mv.Name),
					tostring(mv:GetAttribute("Key")),
					tostring(ra),
					tostring(mv:GetAttribute("LastUse")),
					tostring(ra and (ra - now) or "n/a")
				))
			end
		end
	end
	if not any then
		print("[NH CDViewer] nobody in range and nobody aimed at")
	end
end

Players.PlayerRemoving:Connect(function(plr)
	local list = {}
	for char in pairs(panels) do
		if Players:GetPlayerFromCharacter(char) == plr then
			list[#list + 1] = char
		end
	end
	for _, char in ipairs(list) do
		destroyPanel(char, true)
	end
end)

-- [NH HUB] autostart suppressed: controlled by the Extras tab toggle.
return CD

    end)
    if not okCD then
        warn("[NH HUB] Cooldown Viewer module failed: " .. tostring(errCD))
    end
end

-- ============================================================
-- NH ITEM GRABBER v2.0  (teleport + grab, drop, live list)
-- Ported from the standalone module: Kavo UI removed, logic kept
-- 1:1 and rewired into the hub Items tab.
-- ============================================================
do
    local okIG, errIG = pcall(function()
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")

        local IG = {}
        IG.Version = "2.1-p9"
        IG.autoGrab = false
        IG.busy = false
        _G.NH_ItemGrabber = IG

        local lp = Players.LocalPlayer

        -- exact Knit paths from the standalone script
        local Services = ReplicatedStorage:WaitForChild("Knit", 20):WaitForChild("Knit", 20):WaitForChild("Services", 20)
        local cameraPath = Services:WaitForChild("AntiCheatService", 20):WaitForChild("RE", 20)
        local cameraAntiCheat = cameraPath:WaitForChild("Camera", 20)
        local dropRE = Services:WaitForChild("ItemService", 20):WaitForChild("RE", 20):WaitForChild("Drop", 20)
        local itemsFolder = Workspace:WaitForChild("Items", 20)

        local tracked = {}
        local order = {}
        local display = {}
        local map = {}

        local function getRoot()
            local c = lp.Character
            return c and c:FindFirstChild("HumanoidRootPart")
        end
        IG.getRoot = getRoot

        -- the standalone list only ever shows items that really exist
        local function valid(item)
            if not (item and item.Parent) then return false end
            if not item:IsA("BasePart") then return false end
            if item.CFrame.Y >= 1000 then return false end
            return true
        end
        IG.valid = valid

        function IG.drop()
            return pcall(function() dropRE:FireServer() end)
        end

        -- Round trip is explicit: never rely on AC to snap us back. Every Items
        -- action (selected / nearest / all / auto) uses this same serialized path.
        function IG.grab(item)
            if IG.busy then return false, "item grab already in progress" end
            if not valid(item) then return false, "item gone" end
            local character, r = lp.Character, getRoot()
            if not character or not r then return false, "no character" end
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not prompt then return false, "no proximity prompt" end
            if type(fireproximityprompt) ~= "function" then return false, "prompt input unavailable" end

            local origin = r.CFrame
            local velocity, angularVelocity = r.AssemblyLinearVelocity, r.AssemblyAngularVelocity
            local cameraParent = cameraAntiCheat.Parent
            IG.busy = true
            local ok, err = pcall(function()
                cameraAntiCheat.Parent = nil
                r.CFrame = item.CFrame
                task.wait(0.25)
                if lp.Character ~= character or getRoot() ~= r or not r.Parent then
                    error("character changed during item grab")
                end
                if not item.Parent or not prompt.Parent then error("item disappeared before pickup") end
                prompt.HoldDuration = 0
                if fireproximityprompt(prompt) == false then error("prompt input rejected") end
                task.wait(0.2)
            end)
            -- Finally-style cleanup also runs after prompt errors/timeouts. Do not
            -- teleport a NEW respawned character to the previous character's origin.
            local returned, returnError = pcall(function()
                if lp.Character ~= character or getRoot() ~= r or not r.Parent then
                    error("original character no longer exists")
                end
                r.CFrame = origin
                r.AssemblyLinearVelocity, r.AssemblyAngularVelocity = velocity, angularVelocity
            end)
            local restored, restoreError = pcall(function()
                -- A pre-existing detached remote stays detached; do not undo another
                -- feature's state or overwrite a new owner that reparented it meanwhile.
                if cameraAntiCheat.Parent == nil then cameraAntiCheat.Parent = cameraParent end
            end)
            IG.busy = false
            if not ok then return false, tostring(err) end
            if not returned then return false, "return trip failed: " .. tostring(returnError) end
            if not restored then return false, "camera restore failed: " .. tostring(restoreError) end
            return true
        end

        function IG.count()
            local n = 0
            for part in pairs(tracked) do
                if valid(part) then n = n + 1 end
            end
            return n
        end

        -- rebuild the dropdown labels, nearest first, duplicates disambiguated
        function IG.refresh()
            display = {}
            map = {}
            local r = getRoot()
            local list = {}
            for _, part in ipairs(order) do
                if valid(part) then list[#list + 1] = part end
            end
            if r then
                table.sort(list, function(a, b)
                    return (a.Position - r.Position).Magnitude < (b.Position - r.Position).Magnitude
                end)
            end
            local seen = {}
            for _, part in ipairs(list) do
                local base = part.Name
                seen[base] = (seen[base] or 0) + 1
                local label = base
                if seen[base] > 1 then label = base .. " (" .. seen[base] .. ")" end
                if r then
                    label = label .. "  [" .. tostring(math.floor((part.Position - r.Position).Magnitude + 0.5)) .. "m]"
                end
                display[#display + 1] = label
                map[label] = part
            end
            IG.display = display
            return display
        end

        function IG.partFor(label)
            return map[label]
        end

        function IG.nearest()
            local r = getRoot()
            if not r then return nil end
            local best, bestD = nil, math.huge
            for part in pairs(tracked) do
                if valid(part) then
                    local d = (part.Position - r.Position).Magnitude
                    if d < bestD then best, bestD = part, d end
                end
            end
            return best
        end

        function IG.grabAll(onProgress)
            local r = getRoot()
            local list = {}
            for part in pairs(tracked) do
                if valid(part) then list[#list + 1] = part end
            end
            if r then
                table.sort(list, function(a, b)
                    return (a.Position - r.Position).Magnitude < (b.Position - r.Position).Magnitude
                end)
            end
            local total, got = #list, 0
            for _, part in ipairs(list) do
                if valid(part) then
                    local ok = IG.grab(part)
                    if ok then got = got + 1 end
                    if onProgress then pcall(onProgress, got, total) end
                    task.wait(0.1)
                end
            end
            return got, total
        end

        local function trackItem(item)
            task.wait()
            if tracked[item] then return end
            if not valid(item) then return end
            tracked[item] = true
            order[#order + 1] = item
        end

        local function untrackItem(item)
            if not tracked[item] then return end
            tracked[item] = nil
            for i = #order, 1, -1 do
                if order[i] == item then table.remove(order, i) end
            end
        end

        for _, item in ipairs(itemsFolder:GetChildren()) do
            task.spawn(trackItem, item)
        end
        itemsFolder.ChildAdded:Connect(function(item) task.spawn(trackItem, item) end)
        itemsFolder.ChildRemoved:Connect(untrackItem)

        -- AUTO GRAB loop: keeps sweeping up whatever exists / respawns
        task.spawn(function()
            while true do
                task.wait(0.35)
                if IG.autoGrab and not IG.busy then
                    local part = IG.nearest()
                    if part then pcall(IG.grab, part) end
                end
            end
        end)

        IG.refresh()
    end)
    if not okIG then
        warn("[NH HUB] Item Grabber module failed: " .. tostring(errIG))
    end
end


-- ============================================================
-- Flash Step M1s (PreAwk Mahito M1 Pull) — on M1, if a valid target is within range, do a smooth
-- cubic ease-out pull to them with the Mahito Chase VFX. Toggle: St.flashStepM1Enabled.
-- Range is read live from St.flashStepM1Range (20-200 studs). All VFX/asset access is pcall-guarded
-- so a missing effect can never break the pull or the hub.
-- ============================================================
do
    local PULL_SPEED  = 0.18  -- seconds to reach target
    local PULL_OFFSET = 4     -- studs in front of target to land
    local PULL_MIN    = 8     -- studs: don't flash step if the enemy is already this close (dead zone)
    local fsCooldown  = false

    local Knit, FXController, ToolController, CamShaker
    local function fsEnsure()
        if ToolController then return true end
        pcall(function()
            Knit = Knit or require(ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"))
            ToolController = ToolController or Knit.GetController("ToolController")
            FXController   = FXController or Knit.GetController("FXController")
        end)
        pcall(function() CamShaker = CamShaker or require(ReplicatedStorage.Modules.CameraShaker) end)
        return ToolController ~= nil
    end

    local function fsVFX(hrp, targetHRP, dashCF, magnitude)
        pcall(function()
            local Utils  = ReplicatedStorage.Utils
            local Sounds = ReplicatedStorage.Sounds
            -- Mahito.Dash beam between us and target
            local dashBeam  = Utils.Mahito.Dash:Clone()
            dashBeam.CFrame = dashCF + dashCF.LookVector * magnitude / 2
            dashBeam.Size   = Vector3.new(5, 5, magnitude)
            dashBeam.Parent = Workspace.Effects
            TweenService:Create(dashBeam, TweenInfo.new(0.2), {
                Size = Vector3.new(0, 0, magnitude),
                CFrame = dashBeam.CFrame * CFrame.Angles(0, 0, math.pi)
            }):Play()
            Debris:AddItem(dashBeam, 0.2)
            -- RushWind burst at our current position
            local rushModel = Instance.new("Model")
            local rushWind  = Utils.Itadori.RushWind:Clone()
            rushWind.CFrame = hrp.CFrame * CFrame.new(0, -1, 0)
            rushWind.Parent = rushModel
            rushModel.Parent = Workspace.Effects
            rushModel:ScaleTo(0.6)
            rushWind.Ring:Emit(7)
            rushWind.Dash1.Dash:Emit(1)
            rushWind.Dash2.Dash:Emit(1)
            Debris:AddItem(rushModel, 2)
            -- Three staggered Shock rings
            local function spawnShock(pos, d)
                task.delay(d, function()
                    pcall(function()
                        local shock = Utils.Itadori.Shock:Clone()
                        shock.CFrame = CFrame.new(pos) * CFrame.Angles(math.pi / 2, 0, 0)
                        shock.Parent = Workspace.Effects
                        TweenService:Create(shock, TweenInfo.new(0.3), {
                            Size = Vector3.new(10, 0, 10),
                            Transparency = 1
                        }):Play()
                        Debris:AddItem(shock, 0.35)
                    end)
                end)
            end
            spawnShock(targetHRP.Position, 0)
            spawnShock(targetHRP.Position + dashCF.LookVector * 3, 0.075)
            spawnShock(hrp.Position, 0.15)
            -- Strike sound + camera snap
            pcall(function() FXController:PlaySound(Sounds.Mahito.Variants.Strike, hrp, game.SoundService.Effect) end)
            pcall(function() CamShaker.CurrentShaker:Shake(CamShaker.Presets.Snap) end)
        end)
    end

    local function fsOnMelee()
        -- Local flatten (defined here, not at do-block scope, so it doesn't consume
        -- a main-chunk local slot -- the hub's main chunk is at Lua's local limit).
        local function fsFlat(vector)
            return Vector3.new(vector.X, 0, vector.Z)
        end
        if not St.flashStepM1Enabled then return end
        if fsCooldown then return end
        if not fsEnsure() then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetHRP
        local targetHumanoid
        local targetCharacter
        local lockRecordAtStart = nil

        -- An enabled lock is authoritative. If it is enabled but currently has no
        -- valid target, fail closed instead of falling back to the mouse target.
        if St.lockOnEnabled then
            local locked = St.lockOnTarget
            if type(locked) ~= "table" then return end
            local lockedChar = locked.Char
            if typeof(lockedChar) ~= "Instance" or not lockedChar:IsA("Model") or not lockedChar.Parent then return end

            local lockedHumanoid = locked.Humanoid
            if typeof(lockedHumanoid) ~= "Instance" or not lockedHumanoid:IsA("Humanoid")
                or lockedHumanoid.Parent ~= lockedChar then
                lockedHumanoid = lockedChar:FindFirstChildOfClass("Humanoid")
            end
            local lockedRoot = locked.Core
            if typeof(lockedRoot) ~= "Instance" or not lockedRoot:IsA("BasePart")
                or not lockedRoot.Parent or not lockedRoot:IsDescendantOf(lockedChar) then
                lockedRoot = lockedChar:FindFirstChild("HumanoidRootPart")
                    or lockedChar:FindFirstChild("Torso")
            end
            if not lockedHumanoid or lockedHumanoid.Health <= 0
                or typeof(lockedRoot) ~= "Instance" or not lockedRoot:IsA("BasePart")
                or not lockedRoot.Parent or not lockedRoot:IsDescendantOf(lockedChar) then
                return
            end

            lockRecordAtStart = locked
            targetCharacter = lockedChar
            targetHumanoid = lockedHumanoid
            targetHRP = lockedRoot
        else
            local target
            pcall(function() target = ToolController:GetTarget() end)
            if typeof(target) ~= "Instance" then return end
            if target:IsA("Player") then
                target = target.Character
            elseif not target:IsA("Model") then
                target = target:FindFirstAncestorOfClass("Model")
            end
            if typeof(target) ~= "Instance" or not target:IsA("Model") or target == char then return end
            targetHumanoid = target:FindFirstChildOfClass("Humanoid")
            targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            if not targetHumanoid or targetHumanoid.Health <= 0
                or not targetHRP or not targetHRP:IsA("BasePart")
                or not targetHRP.Parent or not targetHRP:IsDescendantOf(target) then
                return
            end
            targetCharacter = target
        end

        local function fsTargetStillAllowed()
            if not St.flashStepM1Enabled or not targetCharacter or not targetCharacter.Parent
                or not targetHumanoid or targetHumanoid.Parent ~= targetCharacter
                or targetHumanoid.Health <= 0 or not targetHRP or not targetHRP.Parent
                or not targetHRP:IsDescendantOf(targetCharacter) then
                return false
            end
            if lockRecordAtStart then
                local currentLock = St.lockOnTarget
                return St.lockOnEnabled and currentLock == lockRecordAtStart
                    and currentLock.Char == targetCharacter
            end
            if not St.lockOnEnabled then return true end
            local currentLock = St.lockOnTarget
            return currentLock ~= nil and currentLock.Char == targetCharacter
        end

        local dist = (hrp.Position - targetHRP.Position).Magnitude
        -- Flash step is ONLY for closing a gap. If the enemy is already within PULL_MIN studs,
        -- skip the pull and let the normal M1 land — no more spam-stepping on tiny gaps.
        if dist <= PULL_MIN then return end
        if dist > (St.flashStepM1Range or 20) then return end

        fsCooldown = true
        task.delay(0.35, function() fsCooldown = false end)

        local dashCF    = CFrame.new(targetHRP.Position, hrp.Position)
        local magnitude = (targetHRP.Position - hrp.Position).Magnitude
        fsVFX(hrp, targetHRP, dashCF, magnitude)

        -- PREDICTIVE LEAD: extrapolate where the target will be when the pull lands.
        -- Landing at their CURRENT position against a running opponent puts you
        -- behind them; sampling their velocity over the pull window and aiming at
        -- the forecast point keeps you on top of them. The lead is capped so a fast
        -- target can't drag the destination off into the sky.
        local targetVel = fsFlat(targetHRP.AssemblyLinearVelocity)
        if targetVel.Magnitude < 1 then
            -- physics velocity can read stale/zero right after a dash; fall back to a
            -- short position-sample derivative before giving up on the lead.
            local p1 = targetHRP.Position
            task.wait(0.05)
            if not fsTargetStillAllowed() then return end
            if targetHRP and targetHRP.Parent then
                targetVel = fsFlat((targetHRP.Position - p1) / 0.05)
            end
        end
        local leadTime = math.min(PULL_SPEED + 0.05, 0.25)
        local lead = targetVel * leadTime
        local leadMag = lead.Magnitude
        if leadMag > math.max(dist * 0.55, 14) then
            lead = lead.Unit * math.max(dist * 0.55, 14)
        end

        -- Smooth pull: land PULL_OFFSET studs in front of target's PREDICTED position
        local targetDir   = (hrp.Position - targetHRP.Position).Unit
        local destination = targetHRP.Position + lead + targetDir * PULL_OFFSET
        local startPos    = hrp.Position
        local elapsed     = 0

        -- BodyVelocity burst for responsiveness
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.P        = 1e6
        local diff  = destination - startPos
        bv.Velocity = diff.Magnitude > 0.01 and diff.Unit * 80 or Vector3.new(0, 0, 0)
        bv.Parent   = hrp
        Debris:AddItem(bv, PULL_SPEED)

        -- RenderStepped cubic ease-out for smooth landing
        local pullConn
        pullConn = RunService.RenderStepped:Connect(function(dt)
            if not fsTargetStillAllowed() then
                pullConn:Disconnect()
                if bv.Parent then bv.Velocity = Vector3.new(0, 0, 0) bv:Destroy() end
                return
            end
            elapsed = elapsed + dt
            local alpha = math.min(elapsed / PULL_SPEED, 1)
            local eased = 1 - (1 - alpha) ^ 3
            if hrp and hrp.Parent and targetHRP and targetHRP.Parent then
                hrp.CFrame = CFrame.new(
                    startPos:Lerp(destination, eased),
                    Vector3.new(targetHRP.Position.X, startPos.Y, targetHRP.Position.Z)
                )
            end
            if alpha >= 1 then
                pullConn:Disconnect()
                if bv.Parent then bv.Velocity = Vector3.new(0, 0, 0) bv:Destroy() end
            end
        end)
    end

    -- Connect the game's Melee keybind once; the handler self-gates on St.flashStepM1Enabled.
    task.spawn(function()
        if _G.M1PullMeleeConn then pcall(function() _G.M1PullMeleeConn:Disconnect() end) _G.M1PullMeleeConn = nil end
        pcall(function()
            local kb = ReplicatedStorage:WaitForChild("Keybind")
            _G.M1PullMeleeConn = kb.Combat.Melee.Pressed:Connect(fsOnMelee)
        end)
    end)
end

-- [COMBAT]
Tabs.Combat:AddSection("Combat Automation")
-- Existing downslam, uppercut, and Flash Step controls stay together here.
Tabs.Combat:AddToggle("TglAutoDownslam", {Title="Auto Downslam", Default=false, Callback=function(v) St.autoDownslamEnabled = v; if v then St.autoUppercutEnabled = false; pcall(function() Fluent.Options.TglAutoUppercut:SetValue(false) end) end end})
Tabs.Combat:AddDropdown("DpDownslamMode", {Title="Auto Downslam Method", Values={"Blatant", "Legit"}, Default="Blatant", Callback=function(v) St.downslamMode = string.lower(v) end})
Tabs.Combat:AddToggle("TglAutoUppercut", {Title="Auto Uppercut", Default=false, Callback=function(v) St.autoUppercutEnabled = v; if v then St.autoDownslamEnabled = false; pcall(function() Fluent.Options.TglAutoDownslam:SetValue(false) end) end end})
Tabs.Combat:AddToggle("TglFlashStepM1", {Title="Flash Step M1s", Default=false, Callback=function(v) St.flashStepM1Enabled = v end})
Tabs.Combat:AddSlider("SldFlashStepM1Range", {Title="Flash Step Range", Min=20, Max=200, Default=20, Rounding=0, Callback=function(v) St.flashStepM1Range = v end})

Tabs.Combat:AddSection("Auto Blocking")
-- Base Auto Block now has its own option so PC/mobile shortcuts use the same
-- callback as the menu instead of silently changing only the state table.
Tabs.Combat:AddToggle("TglAutoBlockC", {Title="Auto Block", Default=false, Callback=function(v)
    St.autoBlockEnabled = v and true or false
    if not v then
        -- Do not leave Solo Block visibly enabled after the base engine stops.
        local solo = Fluent.Options.TglAutoBlockSolo
        if St.autoBlockSoloEnabled and solo then solo:SetValue(false) end
        if not St.autoDashPredictEnabled and not St.autoPunishEnabled and not St.autoProjBlockEnabled
            and not St.autoCounterEnabled and not getgenv().userIsBlocking and _G.NH_forceStopBlock then
            _G.NH_forceStopBlock()
        end
    end
end})
Tabs.Combat:AddToggle("TglAutoDashPredictC", {Title="Auto Dash Predict", Default=false, Callback=function(v)
    St.autoDashPredictEnabled = v
    if _G.NH_SetAutoDashPredict then pcall(_G.NH_SetAutoDashPredict, v) end
    if not v and not St.autoBlockEnabled and not St.autoPunishEnabled and not St.autoProjBlockEnabled
        and not getgenv().userIsBlocking and _G.NH_forceStopBlock then
        _G.NH_forceStopBlock()
    end
end})
Tabs.Combat:AddToggle("TglAutoProjBlockC", {Title="Auto Projectile Block", Default=false, Callback=function(v)
    St.autoProjBlockEnabled = v
    if not v and not St.autoBlockEnabled and not St.autoDashPredictEnabled and not St.autoPunishEnabled
        and not getgenv().userIsBlocking and _G.NH_forceStopBlock then _G.NH_forceStopBlock() end
end})
Tabs.Combat:AddToggle("TglAutoPunishC", {Title="Auto Block + Punish", Default=false, Callback=function(v) St.autoPunishEnabled = v end})
Tabs.Combat:AddToggle("TglAutoBlockBreakC", {Title="Auto Block Break", Default=false, Callback=function(v) St.autoBlockBreakEnabled = v end})

-- SOLO TARGET: auto-block one specific person only. Lock onto them (any lock-on
-- path) and every block feature serves just them -- big lag cut because the 30Hz
-- anim scanner and the per-frame projectile pass only ever look at ONE enemy.
local SoloSection = Tabs.Combat:AddSection("Solo Block Target")
SoloSection:AddParagraph({Title="How Solo Block works", Content="Enable this and lock onto someone. M1s, dash prediction, projectile casts and punish automation will only use that character; while no valid lock is selected, auto-defense waits instead of falling back to everyone."})
SoloSection:AddToggle("TglAutoBlockSolo", {Title="Auto Block Solo Target", Default=false, Callback=function(v)
    St.autoBlockSoloEnabled = v and true or false
    -- Solo block IS auto block scoped to one person, so it drives the base toggle
    -- too. Turning it off drops the solo target and releases the block engine.
    St.autoBlockEnabled = v and true or false
    -- Keep the new base option synchronized with the existing Solo Block path.
    local base = Fluent.Options.TglAutoBlockC
    if base and base.Value ~= St.autoBlockEnabled then base:SetValue(St.autoBlockEnabled) end
    if not v then
        if _G.NH_AutoBlockSolo then _G.NH_AutoBlockSolo.Clear() end
        if not getgenv().userIsBlocking and _G.NH_forceStopBlock then _G.NH_forceStopBlock() end
    end
end})
SoloSection:AddButton({Title="Clear Solo Target (re-choose)", Callback=function()
    if _G.NH_AutoBlockSolo then _G.NH_AutoBlockSolo.Clear() end
    notify("Solo Block", "Cleared. Lock onto someone else to re-choose.", 2)
end})


-- Fluent only places controls inside a section when they are added through the
-- section object returned by AddSection. Keep Auto Backdash and its platform
-- control together instead of leaving them as separate top-level Combat rows.
-- PATCH P14: ONE registry for every plain keyboard bind (Keybinds tab, Auto Backdash,
-- Combo Recorder). Fluent's Keybind:SetValue -- which SaveManager uses to restore a
-- config -- only repaints the label and never runs ChangedCallback, so a saved "P"
-- showed P while the live key stayed on its default. Every bind added here is wrapped
-- so a config load, a manual pick and a Refresh all apply the key the row shows.
do
    local KB = {entries = {}, labels = {}, flyHintShown = false}
    St.KeyBinds = KB

    -- "P" -> "P"; "MouseLeft"/"Unknown"/junk -> nil (Fluent's picker accepts mouse
    -- buttons, which used to bind Enum.KeyCode.Unknown and break the key silently).
    function KB.Normalize(key)
        if typeof(key) == "EnumItem" then key = key.Name end
        if type(key) ~= "string" or key == "" or key == "Unknown" then return nil end
        if key == "None" then return key end
        local ok, code = pcall(function() return Enum.KeyCode[key] end)
        if ok and typeof(code) == "EnumItem" then return key end
        return nil
    end

    -- Cache the row's key label (Fluent shows "..." there while you choose a key).
    function KB.TrackLabel(id, option)
        if type(option) ~= "table" then return end
        local search = _G.NH_FeatureSearch
        for _, entry in ipairs(search and search.Entries or {}) do
            if entry.id == id and entry.widget == option and typeof(entry.frame) == "Instance" then
                for _, label in ipairs(entry.frame:GetDescendants()) do
                    if label:IsA("TextLabel") and label.Parent and label.Parent:IsA("TextButton") then
                        KB.labels[#KB.labels + 1] = label
                        return
                    end
                end
                return
            end
        end
    end

    function KB.IsPicking()
        for _, label in ipairs(KB.labels) do
            if label.Parent and label.Text == "..." then return true end
        end
        local tk = St.ToggleKeybinds
        return tk ~= nil and tk.IsPicking ~= nil and tk.IsPicking() == true
    end

    -- Names of every hub action currently on `code`, excluding `selfId`.
    function KB.Users(code, selfId)
        local names = {}
        if typeof(code) ~= "EnumItem" then return names end
        for _, e in ipairs(KB.entries) do
            if e.id ~= selfId and e.code == code then names[#names + 1] = e.name end
        end
        local tk = St.ToggleKeybinds
        local groupNames = {invisKey = "Invisibility", rotateLockOnKey = "Rotate Lock-On", autoBlockKey = "Auto Block"}
        for keyField in pairs(tk and tk.groups or {}) do
            if "group:" .. keyField ~= selfId and Keys[keyField] == code then
                names[#names + 1] = groupNames[keyField] or keyField
            end
        end
        if code == Keys.stopKey then names[#names + 1] = "Stop Sweep" end
        if code == Enum.KeyCode.LeftControl or code == Enum.KeyCode.RightControl then
            names[#names + 1] = "Hide/Show Hub"
        end
        return names
    end

    -- Feedback after YOU choose a key (never during config loads).
    function KB.AfterUserPick(name, picked, code, selfId)
        if not KB.Normalize(picked) then
            notify("Keybinds", tostring(name) .. ": mouse buttons can't be bound. Kept "
                .. (typeof(code) == "EnumItem" and code.Name or "None") .. ".", 4)
            return
        end
        local others = KB.Users(code, selfId)
        if #others > 0 then
            notify("Keybinds", code.Name .. " is also bound to " .. table.concat(others, ", ")
                .. ". Pick a different key for one of them.", 5)
        end
    end

    function KB.FlyCtrlHint()
        if KB.flyHintShown then return end
        KB.flyHintShown = true
        notify("Fly", "Left Ctrl = descend while flying. Use Right Ctrl to hide/show the hub.", 5)
    end

    -- opts: Title, Default (KeyCode name), Apply(codeOrNil), optional Name / Description.
    function KB.Add(container, id, opts)
        local entry = {id = id, name = opts.Name or opts.Title, key = opts.Default, code = nil}
        local option, rawSetValue
        local function commit(raw, fromUser)
            local key = KB.Normalize(raw) or entry.key
            entry.key = key
            entry.code = key ~= "None" and Enum.KeyCode[key] or nil
            if rawSetValue and (option.Value ~= key or option.Mode ~= "Toggle") then
                pcall(rawSetValue, option, key, "Toggle")
            end
            local ok, err = pcall(opts.Apply, entry.code)
            if not ok then warn("[NH Keybinds] " .. tostring(id) .. ": " .. tostring(err)) end
            if fromUser then KB.AfterUserPick(entry.name, raw, entry.code, id) end
        end
        option = container:AddKeybind(id, {
            Title = opts.Title, Description = opts.Description,
            Default = opts.Default, Mode = "Toggle",
            -- Fluent sets option.Value to the picked key's NAME before this runs; the
            -- callback argument is a KeyCode (Unknown for mouse buttons), so read Value.
            ChangedCallback = function() commit(option and option.Value, true) end,
        })
        if type(option) ~= "table" then return option end
        rawSetValue = option.SetValue
        function option:SetValue(key, mode)
            commit(key or self.Value, false)
        end
        entry.option = option
        KB.entries[#KB.entries + 1] = entry
        commit(opts.Default, false)
        KB.TrackLabel(id, option)
        return option
    end

    -- Re-apply every bind from its row (run after the autoload config).
    function KB.Refresh()
        for _, e in ipairs(KB.entries) do
            if e.option then e.option:SetValue(e.option.Value) end
        end
    end
end

local BackdashSection = Tabs.Combat:AddSection("Auto Backdash")
BackdashSection:AddToggle("TglDashBehindTarget", {
    Title="Enable Auto Backdash",
    Default=false,
    Callback=function(v) St.dashBehindTargetEnabled = v and true or false end
})

if not mobile then
    St.KeyBinds.Add(BackdashSection, "KbDashBehindTarget", {
        Title="Keybind:", Name="Auto Backdash", Default="B",
        Apply=function(code) Keys.dashBehindTargetKey = code end
    })
else
    -- Mobile's on-screen button is the equivalent of the PC keybind, so its
    -- optional always-show control belongs in this same feature section too.
    BackdashSection:AddToggle("MbDashBehindTarget", {
        Title="Show Auto Backdash Button",
        Description="Optional: keep the BACKDASH button visible while Auto Backdash is disabled.",
        Default=false,
        Callback=function(v) _G.NH_btnManual["DashBehindBtn"] = v and true or false end
    })
end

Tabs.Combat:AddSection("Lock-On System")
Tabs.Combat:AddParagraph({Title="Lock-On Info", Content="PC: hover an enemy and press the Lock-On key to lock. Press it on them again to unlock, or on another enemy to switch.\nMobile: enable this, aim your camera so the enemy is near the middle of your screen, then press the LOCK ON button to lock onto them. Aim at someone else and press again to switch, or press while aiming at your current target (or at empty space) to unlock."})

Tabs.Combat:AddToggle("TglLockOn", {
    Title="Lock-On Enable", 
    Default=false, 
    Callback=function(v) 
        St.lockOnEnabled = v 
        if v then 
            enableLockOn() 
        else 
            disableLockOn()
        end 
    end
})
Tabs.Combat:AddDropdown("DpLockOnMethod", {Title="Lock-On Method", Values={"Body", "Camera", "Console"}, Default="Console", Callback=function(v) Cfg.LockOn.Method = v end})
Tabs.Combat:AddToggle("TglLockOnESP", {Title="Lock-On ESP (see target through walls)", Default=false, Callback=function(v) Cfg.LockOn.ESP = v; if not v then clearLockOnHighlight() end end})
Tabs.Combat:AddSlider("SldLockOnSmooth", {Title="Lock-On Smoothness", Min=0.01, Max=1, Default=0.15, Rounding=2, Callback=function(v) Cfg.LockOn.Smoothness = v end})
Tabs.Combat:AddSlider("SldLockOnDist", {Title="Max Distance", Min=10, Max=250, Default=150, Rounding=0, Callback=function(v) Cfg.LockOn.MaxDistance = v end})
Tabs.Combat:AddDropdown("DpLockOnTarget", {Title="Lock Target (player / dummy)", Values={"(press Refresh)"}, Default=1, Callback=function(v) end})
Tabs.Combat:AddButton({Title="Refresh Lock Targets", Callback=function()
    local t = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    local names = {}
    for _, v in ipairs(t) do table.insert(names, v.name) end
    if #names == 0 then names = {"(none found)"} end
    Fluent.Options.DpLockOnTarget:SetValues(names)
    notify("Lock-On", "Found " .. #names .. " targets.", 2)
end})
Tabs.Combat:AddButton({Title="Lock Selected Target", Callback=function()
    local selected = Fluent.Options.DpLockOnTarget.Value
    if not selected or selected == "(none found)" or selected == "(press Refresh)" then
        notify("Lock-On", "Pick a target from the list first.", 3); return
    end
    local targets = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    local chosen = nil
    for _, t in ipairs(targets) do if t.name == selected then chosen = t; break end end
    if not chosen then notify("Lock-On", "Target not found or dead. Refresh the list.", 3); return end
    St.lockOnEnabled = true
    St.lockOnTarget = chosen
    enableLockOn()
    notify("Lock-On", "Locked onto " .. chosen.name .. ".", 3)
end})
Tabs.Combat:AddButton({Title="Unlock / Clear Target", Callback=function()
    St.lockOnTarget = nil
    RunService:UnbindFromRenderStep("HubLockOnSystem")
    RunService:UnbindFromRenderStep("HubLockOnBody")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    clearLockOnESP()
    notify("Lock-On", "Unlocked.", 2)
end})

-- [TARGETS]
local DpTargets = Tabs.Targets:AddDropdown("DpTargetSelect", {Title="Select Target", Values={"(press Refresh)"}, Default=1, Callback=function(v) end})

Tabs.Targets:AddButton({
    Title = "Refresh Targets",
    Callback = function()
        local t = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        local names = {}
        for _, v in ipairs(t) do table.insert(names, v.name) end
        if #names == 0 then names = {"(none found)"} end
        DpTargets:SetValues(names)
        notify("Targets", "Refreshed " .. #names .. " targets.", 2)
    end
})

Tabs.Targets:AddButton({
    Title = "Attach to Selected",
    Callback = function()
        local selected = Fluent.Options.DpTargetSelect.Value
        if not selected or selected == "(none found)" or selected == "(press Refresh)" then 
            notify("Targets", "Select a valid target first.", 3) 
            return 
        end
        
        local targets = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        local targetToAttach = nil
        for _, t in ipairs(targets) do
            if t.name == selected then targetToAttach = t break end
        end
        
        if targetToAttach then
            startAttach(targetToAttach)
            notify("Attached", "Attached to " .. targetToAttach.name, 2)
        else
            notify("Targets", "Target not found or dead. Please refresh.", 3)
        end
    end
})

Tabs.Targets:AddButton({Title="Attach to closest", Callback=function()
    local t = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))[1]
    if t then startAttach(t) notify("Attached", "Attached to "..t.name, 2) end
end})

Tabs.Targets:AddButton({Title="Detach", Callback=stopAttach})

Tabs.Targets:AddSection("Rotate Target")
Tabs.Targets:AddToggle("TglRotate", {
    Title = "Rotate Selected Target",
    Default = false,
    Tooltip = "Orbit the dropdown target at high speed, always facing them. Velocity-predicted so moving/dashing targets don't drag you behind.",
    Callback = function(v)
        if not v then
            if not St.rotateFollowLockOn then St.stopRotate() end
            return
        end
        if St.rotateFollowLockOn and Fluent.Options.TglRotateLockOn then
            pcall(function() Fluent.Options.TglRotateLockOn:SetValue(false) end)
        end
        local selected = Fluent.Options.DpTargetSelect.Value
        if not selected or selected == "(none found)" or selected == "(press Refresh)" then
            notify("Rotate", "Select a valid target first.", 3)
            pcall(function() Fluent.Options.TglRotate:SetValue(false) end)
            return
        end
        local targets = getValidTargets(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        local t = nil
        for _, x in ipairs(targets) do if x.name == selected then t = x break end end
        if not t then
            notify("Rotate", "Target not found or dead. Please refresh.", 3)
            pcall(function() Fluent.Options.TglRotate:SetValue(false) end)
            return
        end
        St.startRotate(t)
        notify("Rotate", "Rotating around " .. t.name, 2)
    end
})
Tabs.Targets:AddToggle("TglRotateLockOn", {
    Title = "Rotate Locked-On Target",
    Default = false,
    Tooltip = "Enable Lock-On and lock a target, then toggle this once to orbit around them. It follows lock switches and stops when the lock is cleared.",
    Callback = function(v)
        if not v then
            if St.rotateFollowLockOn then St.stopRotate() end
            return
        end
        local lockedTarget = St.lockOnEnabled and St.lockOnTarget or nil
        if type(lockedTarget) ~= "table" then
            notify("Rotate", "Lock onto a valid target first.", 3)
            pcall(function() Fluent.Options.TglRotateLockOn:SetValue(false) end)
            return
        end
        local lockedChar = lockedTarget.Char
        local lockedHumanoid = lockedTarget.Humanoid
        local lockedCore = lockedTarget.Core
        if typeof(lockedChar) ~= "Instance" or not lockedChar:IsA("Model") or not lockedChar.Parent
            or typeof(lockedHumanoid) ~= "Instance" or not lockedHumanoid:IsA("Humanoid")
            or lockedHumanoid.Parent ~= lockedChar or lockedHumanoid.Health <= 0
            or typeof(lockedCore) ~= "Instance" or not lockedCore:IsA("BasePart")
            or not lockedCore.Parent or not lockedCore:IsDescendantOf(lockedChar) then
            notify("Rotate", "Lock onto a valid target first.", 3)
            pcall(function() Fluent.Options.TglRotateLockOn:SetValue(false) end)
            return
        end
        if Fluent.Options.TglRotate and Fluent.Options.TglRotate.Value then
            pcall(function() Fluent.Options.TglRotate:SetValue(false) end)
        end
        St.startRotate(lockedTarget, true)
        notify("Rotate", "Rotating around locked target " .. tostring(lockedTarget.name or lockedChar.Name), 2)
    end
})
-- PATCH P7: linked keybind rows share one action and one saved binding per feature.
do
    local API = {groups = {}, keyLabels = {}}
    local function normalizeKey(key)
        if typeof(key) == "EnumItem" then key = key.Name end
        if type(key) ~= "string" then return nil end
        if key == "None" then return key end
        if key == "Unknown" then return nil end
        local ok, code = pcall(function() return Enum.KeyCode[key] end)
        if not ok or not code then return nil end
        return key
    end
    local function sync(group, key)
        if group.syncing then return end
        key = normalizeKey(key) or group.key
        group.key = key
        Keys[group.keyField] = key ~= "None" and Enum.KeyCode[key] or nil
        group.syncing = true
        for _, control in ipairs(group.controls) do
            if control.option.Value ~= key or control.option.Mode ~= "Toggle" then
                control.setValue(control.option, key, "Toggle")
            end
        end
        group.syncing = false
    end
    function API.Add(container, id, title, keyField, toggleId, default)
        if mobile then return end -- matches the hub's existing PC-only keyboard controls
        local group = API.groups[keyField]
        if not group then
            group = {keyField = keyField, toggleId = toggleId, key = default, controls = {}}
            API.groups[keyField] = group
        end
        local option
        option = container:AddKeybind(id, {
            Title = title,
            Default = group.key,
            Mode = "Toggle",
            ChangedCallback = function(new)
                -- Fluent stores the picked key name before invoking this callback.
                local picked = option and option.Value or new
                sync(group, picked)
                if St.KeyBinds then St.KeyBinds.AfterUserPick(title, picked, Keys[keyField], "group:" .. keyField) end
            end
        })
        group.controls[#group.controls + 1] = {option = option, setValue = option.SetValue}
        -- Fluent's SetValue does not invoke ChangedCallback. Wrap it so config loads and
        -- changes made through either copy also update the live binding and its mirror.
        function option:SetValue(key, mode)
            sync(group, key or self.Value)
        end
        sync(group, group.key)

        -- The feature index already captures each control's row. Cache its key label
        -- once, so choosing a key cannot accidentally activate either feature.
        local search = _G.NH_FeatureSearch
        for _, entry in ipairs(search and search.Entries or {}) do
            if entry.id == id and entry.widget == option and typeof(entry.frame) == "Instance" then
                for _, label in ipairs(entry.frame:GetDescendants()) do
                    if label:IsA("TextLabel") and label.Text == group.key then
                        API.keyLabels[#API.keyLabels + 1] = label
                        break
                    end
                end
                break
            end
        end
        return option
    end
    -- Shared by keyboard shortcuts and ONLY the newly added mobile buttons.
    -- Return the actual option value: Rotate may reject an invalid/missing lock.
    function API.Toggle(toggleId)
        local option = Fluent.Options[toggleId]
        if not option then return false end
        local ok = pcall(function() option:SetValue(not option.Value) end)
        return ok and option.Value == true
    end
    function API.IsPicking()
        for _, label in ipairs(API.keyLabels) do
            if label.Parent and label.Text == "..." then return true end
        end
        return false
    end
    St.ToggleKeybinds = API
    if not mobile then
        if Cn.toggleKeybindConn then Cn.toggleKeybindConn:Disconnect() end
        Cn.toggleKeybindConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or UserInputService:GetFocusedTextBox() or API.IsPicking() then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if St.HubKeyBlocked(input.KeyCode) then return end
            for _, group in pairs(API.groups) do
                local key = Keys[group.keyField]
                if key and input.KeyCode == key then
                    API.Toggle(group.toggleId)
                end
            end
        end)
    end
end
St.ToggleKeybinds.Add(Tabs.Targets, "KbRotateLockOn", "Rotate Locked-On Keybind:",
    "rotateLockOnKey", "TglRotateLockOn", "T")
Tabs.Targets:AddSlider("SldRotateSpeed", {Title="Rotate Speed", Min=2, Max=30, Default=11, Rounding=0, Callback=function(v) Cfg.rotateSpeed = v end})
Tabs.Targets:AddSlider("SldRotateRadius", {Title="Rotate Radius", Min=2, Max=25, Default=6, Rounding=1, Callback=function(v) Cfg.rotateRadius = v end})

Tabs.Targets:AddSection("Spectate Target")
Tabs.Targets:AddDropdown("DpSpectate", {Title="Select Player", Values={"(press Refresh)"}, Default=1, Callback=function(v) _G.spectateTargetName = v end})
Tabs.Targets:AddButton({Title="Refresh Players", Callback=function()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    if #names == 0 then names = {"(none)"} end
    Fluent.Options.DpSpectate:SetValues(names)
end})
Tabs.Targets:AddButton({Title="Spectate", Callback=function()
    if _G.spectateTargetName and _G.spectateTargetName ~= "(none)" and _G.spectateTargetName ~= "(press Refresh)" then
        if ovStartSpectate(_G.spectateTargetName) then notify("Spectating", _G.spectateTargetName, 2) end
    end
end})
Tabs.Targets:AddButton({Title="Stop Spectating", Callback=function() ovStopSpectate() notify("Spectating", "Stopped.", 2) end})


-- [MOVEMENT & BF]
Tabs.Movement:AddToggle("TglFly", {Title="Enable Fly", Default=false, Callback=function(v) 
    St.flyToggleOn = v 
    if v then 
        St.flyActive=true enableFly() 
    else 
        disableFly() 
    end 
end})
Tabs.Movement:AddSlider("SldFlySpeed", {Title="Fly Speed", Min=10, Max=650, Default=150, Rounding=0, Callback=function(v) Cfg.FlySpeed = v end})
if mobile then
    Tabs.Movement:AddToggle("TglShowBoost", {Title="Show Boost Button", Default=false, Callback=function(v) _G.NH_boostVisible = v end})
    Tabs.Movement:AddToggle("TglFlyUpDown", {Title="Show Up / Down Buttons", Default=false, Callback=function(v) _G.NH_upDownVisible = v end})
end

Tabs.Movement:AddSection("Dash & Wallhop Modifiers")
Tabs.Movement:AddToggle("TglNoDashCooldown", {Title="No Dash Cooldown", Default=false, Callback=function(v) if v then enableNoDashCooldown() else disableNoDashCooldown() end end})
Tabs.Movement:AddToggle("TglWallhop", {Title="Infinite Wallhop Assist", Default=false, Callback=function(v) if v then enableNoWallhopCooldown() else St.wallhopMetaHooked=false if Cn.wallhopConn2 then Cn.wallhopConn2:Disconnect() end end end})
Tabs.Movement:AddToggle("TglDashMult", {Title="Dash Multiplier", Default=false, Callback=function(v) St.dashMultiplierEnabled = v if v then applyDashMultiplier(St.dashMultiplierValue) end end})
Tabs.Movement:AddSlider("SldDashMult", {Title="Dash Mult Value", Min=0, Max=5, Default=1, Rounding=1, Callback=function(v) St.dashMultiplierValue = v if St.dashMultiplierEnabled then applyDashMultiplier(v) end end})

-- [CHARACTERS]
-- ===== Auto Todo Black Flash =====
-- Auto follow-ups for Todo: listens on the character's Humanoid.AnimationPlayed and fires the
-- matching remote when a Black Flash setup animation plays.
--   111720035828971 -> wait .8s -> TodoService.RightActivated
--   100081544058065 -> fire Brute Force twice (.75s apart)
_G.TODOBLACKFLASH = _G.TODOBLACKFLASH or {}
local function disconnectTodoBlackFlash()
    if _G.TODOBLACKFLASH then
        for _, c in ipairs(_G.TODOBLACKFLASH) do pcall(function() c:Disconnect() end) end
    end
    _G.TODOBLACKFLASH = {}
    if _G.TODOBLACKFLASH_CHARCONN then
        pcall(function() _G.TODOBLACKFLASH_CHARCONN:Disconnect() end)
        _G.TODOBLACKFLASH_CHARCONN = nil
    end
end
local function todoBlackFlashConnectCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    table.insert(_G.TODOBLACKFLASH, humanoid.AnimationPlayed:Connect(function(track)
        if not St.todoBlackFlashEnabled then return end
        local id = track.Animation and track.Animation.AnimationId
        if id == "rbxassetid://111720035828971" then
            task.wait(.8)
            pcall(function() ReplicatedStorage.Knit.Knit.Services.TodoService.RE.RightActivated:FireServer() end)
        end
    end))
    table.insert(_G.TODOBLACKFLASH, humanoid.AnimationPlayed:Connect(function(track)
        if not St.todoBlackFlashEnabled then return end
        local id = track.Animation and track.Animation.AnimationId
        if id == "rbxassetid://100081544058065" then
            local moveset = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Moveset")
            local bf = moveset and moveset:FindFirstChild("Brute Force")
            if not bf then return end
            pcall(function() ReplicatedStorage.Knit.Knit.Services.BruteForceService.RE.Activated:FireServer(bf) end)
            task.wait(.75)
            pcall(function() ReplicatedStorage.Knit.Knit.Services.BruteForceService.RE.Activated:FireServer(bf) end)
        end
    end))
end
local function enableTodoBlackFlash()
    disconnectTodoBlackFlash()
    if LocalPlayer.Character then todoBlackFlashConnectCharacter(LocalPlayer.Character) end
    _G.TODOBLACKFLASH_CHARCONN = LocalPlayer.CharacterAdded:Connect(todoBlackFlashConnectCharacter)
end

-- ============================================================
-- TODO SWAP SYSTEM (infinite-range Boogie Woogie position swap)
-- The swap remote is server-validated by range, so we momentarily TP onto the
-- chosen target to satisfy that range check, fire the REAL Todo R-special swap
-- remote (server-sided, NOT a client teleport), then optionally TP back to our
-- original position. Requires AC bypass first (same idea as the 0.2 Kill All).
-- ============================================================
do
    local TS_SETTLE       = 0.10   -- was 0.05; ping-aware 0.10-0.18s, at least 3 physics frames
    local TS_DEFAULT_HOLD = 0.42   -- was 0.30; slightly longer origin capture window
    local TS_FOLLOW_HOLD  = 1.65   -- was 1.50; slightly longer bring-to-me hold
    local TS = {busy = false, generation = 0, status = {status = "idle"}}
    _G.NH_todoSwapStatus = function() return table.clone(TS.status) end
    LocalPlayer.CharacterRemoving:Connect(function() TS.generation += 1 end)
    -- Named teleport destinations for "Swap To Area": the swap sends the target to one of these.
    local TODO_SWAP_AREAS = {
        { name = "Restaurant",  pos = Vector3.new(-57.39, 24.15, -101.54) },
        { name = "Sewers",      pos = Vector3.new(-113.30, -40.85, -169.86) },
        { name = "Twin Towers", pos = Vector3.new(45.39, 183.53, 136.13) },
    }
    local function todoSwapAreaCF(name)
        for _, a in ipairs(TODO_SWAP_AREAS) do if a.name == name then return CFrame.new(a.pos) end end
        return nil
    end

    -- Build the target list the SAME way the AC check does: every real player
    -- (except us) PLUS every NPC / dummy humanoid in the workspace. Does not rely
    -- on Cfg.INCLUDE_NPCS, so dummies always show up in the dropdown.
    local function todoSwapCollectTargets()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local core = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                if hum and core and hum.Health > 0 then
                    table.insert(list, { name = p.Name, core = core, char = p.Character })
                end
            end
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 then
                local model = obj.Parent
                if model and model:IsA("Model") and model ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(model) then
                    local core = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
                    if core then
                        -- de-dupe identical dummy names so every dropdown entry stays uniquely selectable
                        local base, final, n = model.Name, model.Name, 1
                        local clash = true
                        while clash do
                            clash = false
                            for _, e in ipairs(list) do if e.name == final then clash = true break end end
                            if clash then n = n + 1; final = base .. " (" .. n .. ")" end
                        end
                        table.insert(list, { name = final, core = core, char = model })
                    end
                end
            end
        end
        return list
    end
    _G.NH_todoSwapTargets = todoSwapCollectTargets

    -- AC verify: the same teleport-and-check-for-snapback test the "Check AC Status"
    -- button uses. If we are NOT snapped back, AC is bypassed -> arm the system.
    -- Core AC snap test (NO notifications): briefly TP onto a random target and see if the
    -- anti-cheat snaps us back. Sets St.todoSwapAcBypassed. Returns true if SNAPPED (AC active).
    -- Shared by Todo and Anti-Team: the established Todo target-relative snap
    -- test, with cancellation, serialization and exact-character restoration.
    local todoSnapBusy=false
    local function todoSwapSnapTest(keepRunning)
        if todoSnapBusy then return nil, "Another shared AC test is finishing" end
        if keepRunning and not keepRunning() then return nil, "Stopped" end
        todoSnapBusy = true
        St.todoSwapAcBypassed = false
        _G.NH_TodoACProof = nil
        local ok, bypassed, reason = pcall(checkCycle, keepRunning)
        todoSnapBusy = false
        if not ok then return nil, "Shared Gojo AC-test error: " .. tostring(bypassed) end
        if bypassed == true then
            local proofChar = LocalPlayer.Character
            local proofHum = proofChar and proofChar:FindFirstChildOfClass("Humanoid")
            if proofChar and proofHum and proofHum.Health > 0 then
                St.todoSwapAcBypassed = true
                St.luckyCycleFound = true
                _G.NH_TodoACProof = {
                    Character = proofChar,
                    CheckedAt = os.clock(),
                    Source = "Shared Gojo 0.2 AC test",
                }
            end
            return false, reason or "Shared Gojo 0.2 test passed"
        elseif bypassed == false then
            return true, reason or "Snapback observed"
        end
        return nil, reason or "Shared AC test unavailable"
    end
    _G.NH_todoSwapSnapTest = todoSwapSnapTest

    _G.NH_todoSwapVerifyAC = function()
        local snapped, reason = todoSwapSnapTest()
        if snapped == nil then notify("Todo Range Swap", tostring(reason), 4); return false end
        if snapped then
            notify("Todo Range Swap", "AC is ACTIVE; press Start Hunt to run the shared hunt.", 4)
        else
            notify("Todo Range Swap", "Shared Gojo AC proof confirmed; swap armed.", 5)
        end
        return not snapped
    end

    _G.NH_todoSwapHuntStart = function()
        if St.huntRunning then
            notify("Todo Range Swap", "The shared Gojo 0.2 AC hunt is already running.", 3)
            return
        end
        runHunt()
    end
    _G.NH_todoSwapHuntStop = function(silent)
        if not St.huntRunning and not St.todoSwapHunting then
            if silent ~= true then notify("Todo Range Swap", "No shared AC hunt is running.", 2) end
            return
        end
        stopHunt(silent == true)
    end

    -- Fire the REAL Todo Boogie Woogie swap exactly like the working swap button:
    -- via the Knit CLIENT service signal TodoService.RightActivated:Fire(targetModel),
    -- passing the actual target character/model object (NOT a RemoteEvent, NOT a name).
    local TodoSwapKnitService = nil
    local function getTodoKnitService()
        if TodoSwapKnitService then return TodoSwapKnitService end
        pcall(function()
            local Knit = require(ReplicatedStorage.Knit.Knit)
            TodoSwapKnitService = Knit.GetService("TodoService")
        end)
        return TodoSwapKnitService
    end
    local function fireTodoSwap(targetObj)
        if not targetObj then return false end
        local svc = getTodoKnitService()
        if not svc then return false end
        return pcall(function() svc.RightActivated:Fire(targetObj) end)
    end

    -- One bounded transaction. Fire() returning successfully is only a SENT
    -- signal, never proof that range/cooldown/server validation accepted it.
    _G.NH_todoSwapExecute = function(targetName)
        if TS.busy then notify("Todo Swap", "A swap is still finishing; wait for its result.", 3); return false end
        if not St.todoSwapEnabled then notify("Todo Swap", "Enable Todo Swap first.", 3); return false end
        local acProof = rawget(_G, "NH_TodoACProof")
        if not St.todoSwapAcBypassed or not acProof or acProof.Character ~= LocalPlayer.Character then
            St.todoSwapAcBypassed = false
            notify("Todo Swap", "Run the shared Gojo 0.2 AC hunt for this life first.", 3)
            return false
        end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHRP or not myHum or myHum.Health <= 0 then notify("Todo Swap", "No live character.", 3); return false end
        if myChar:GetAttribute("Moveset") ~= "Todo" then notify("Todo Swap", "Must have the Todo moveset equipped.", 4); return false end
        if not St.Face.canDefend(myChar) then notify("Todo Swap", "Wait until you can act.", 3); return false end
        if not targetName or targetName == "" or targetName == "(press Refresh)" or targetName == "(none found)" then
            notify("Todo Swap", "Pick a target first.", 3); return false
        end
        local target
        for _, t in ipairs(todoSwapCollectTargets()) do if t.name == targetName then target = t; break end end
        local targetHum = target and target.char:FindFirstChildOfClass("Humanoid")
        if not target or not target.core or not target.core.Parent or not targetHum or targetHum.Health <= 0 then
            notify("Todo Swap", "Target not found. Refresh.", 3); return false
        end

        -- Snapshot options and exact instances BEFORE yielding. An old attempt
        -- must never teleport a new life or change modes halfway through a swap.
        local savedCF, savedVelocity, savedAngular = myHRP.CFrame, myHRP.AssemblyLinearVelocity, myHRP.AssemblyAngularVelocity
        local rootToPivot = myHRP.CFrame:ToObjectSpace(myChar:GetPivot())
        local originCF, bringToMe = savedCF, St.todoSwapReturn == true
        if St.todoSwapAreaEnabled then
            originCF = todoSwapAreaCF(St.todoSwapArea)
            if not originCF then notify("Todo Range Swap", "Pick an area first.", 3); return false end
        end
        TS.busy = true
        TS.generation += 1
        local token = TS.generation
        local result = {status = "preparing", target = target.name, bringToMe = bringToMe,
            startedAt = os.clock(), signalSent = false, arrivalObserved = false}
        TS.status = result
        local function sameLife()
            return LocalPlayer.Character == myChar and myChar.Parent and myHRP.Parent == myChar
                and myChar:FindFirstChild("HumanoidRootPart") == myHRP and myHum.Parent == myChar and myHum.Health > 0
        end
        local function active()
            local proof = rawget(_G, "NH_TodoACProof")
            return token == TS.generation and St.todoSwapEnabled and sameLife()
                and myChar:GetAttribute("Moveset") == "Todo" and St.todoSwapAcBypassed
                and proof and proof.Character == myChar and target.char.Parent
                and target.core.Parent == target.char and targetHum.Parent == target.char and targetHum.Health > 0
        end
        local function place(rootCF)
            -- PivotTo takes a MODEL pivot, not an HRP CFrame. Preserve that offset.
            myChar:PivotTo(rootCF * rootToPivot)
            myHRP.AssemblyLinearVelocity, myHRP.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        end
        local function restoreSaved()
            if not sameLife() then return end
            place(savedCF)
            if not result.signalSent then
                myHRP.AssemblyLinearVelocity, myHRP.AssemblyAngularVelocity = savedVelocity, savedAngular
            end
        end
        local ok, err = pcall(function()
            -- Resolve Knit before teleporting, not inside the critical range window.
            local svc = getTodoKnitService()
            if not svc or not svc.RightActivated then error("Knit TodoService.RightActivated unavailable") end
            if not active() then result.status = "cancelled"; return end
            local ping = 0
            local pingOK, p = pcall(function() return LocalPlayer:GetNetworkPing() end)
            if pingOK and type(p) == "number" and p == p and p > 0 and p < math.huge then ping = math.clamp(p, 0, 0.25) end
            local settle = math.clamp(TS_SETTLE + ping * 0.40, TS_SETTLE, 0.18)
            local hold = bringToMe and (TS_FOLLOW_HOLD + math.min(ping * 0.60, 0.15))
                or (TS_DEFAULT_HOLD + math.min(ping * 0.40, 0.08))
            result.settle, result.hold, result.networkLead = settle, hold, ping
            result.status = "settling_range"
            local settleUntil, frames = os.clock() + settle, 0
            repeat
                if not active() or not St.Face.canDefend(myChar) then result.status = "cancelled"; return end
                place(target.core.CFrame * CFrame.new(0, 0, 3)) -- follow a moving target during settle
                RunService.Heartbeat:Wait()
                frames += 1
            until os.clock() >= settleUntil and frames >= 3
            if not active() or not St.Face.canDefend(myChar) then result.status = "cancelled"; return end
            -- Refresh range one final time in case the target moved during the last wait.
            place(target.core.CFrame * CFrame.new(0, 0, 3))
            local targetStart = target.core.Position
            local originDistance = (targetStart - originCF.Position).Magnitude
            result.settleFrames = frames
            if not fireTodoSwap(target.char) then error("Swap signal failed") end
            result.signalSent, result.firedAt, result.status = true, os.clock(), "signal_sent"
            -- Deliberately restore the origin IMMEDIATELY after Fire, as in v109.
            -- Adding a post-Fire dwell at the target risks capturing the wrong origin.
            local holdUntil = result.firedAt + hold
            local observeUntil = result.firedAt + math.clamp(1.80 + ping * 2, 1.80, 2.30)
            repeat
                if not active() then result.status = "cancelled"; return end
                local now = os.clock()
                if now < holdUntil then place(originCF) end
                local atOrigin = (target.core.Position - originCF.Position).Magnitude
                local moved = (target.core.Position - targetStart).Magnitude
                result.originGap = atOrigin
                -- Observe arrival only when the target started outside this area.
                -- Position alone is not proof of server acceptance or causality;
                -- close-by targets are deliberately left unconfirmed.
                if originDistance > 12 and atOrigin <= 8 and moved >= 6 then
                    result.arrivalObserved = true
                    result.arrivalAt = result.arrivalAt or now
                end
                if now >= holdUntil and result.arrivalObserved then break end
                RunService.Heartbeat:Wait()
            until os.clock() >= observeUntil
            if not active() then result.status = "cancelled"; return end
            if bringToMe then place(originCF) end
            result.status = result.arrivalObserved and "target_arrival_observed" or "sent_unconfirmed"
        end)
        if not ok then result.status, result.error = "error", tostring(err) end
        if result.status == "cancelled" or result.status == "error" then
            local restored, restoreError = pcall(restoreSaved)
            if not restored then result.restoreError = tostring(restoreError) end
        end
        result.finishedAt = os.clock()
        TS.busy = false
        if result.status == "error" then
            notify("Todo Swap", "Attempt failed: " .. tostring(result.error), 4)
        elseif result.status == "sent_unconfirmed" then
            notify("Todo Swap", "Signal sent; target arrival not confirmed. Check cooldown/range before retrying.", 4)
        elseif result.status == "target_arrival_observed" then
            notify("Todo Swap", "Target arrival observed.", 2)
        end
        -- Do NOT auto-refire: a delayed first swap + a second swap can swap back.
        return result.arrivalObserved, result.status
    end

end

-- ============================================================
-- AUTO MOVE VARIANTS (World Slash / Frog / Earthquake / Shut Up)
-- Services verified live via MCP under ReplicatedStorage.Knit.Knit.Services:
--   RushService / FlameArrowService / ItadoriService / NueService / EarthquakeService.
-- Pattern mirrors Auto Todo Black Flash: use the move in-game, the variant auto-fires.
-- ============================================================
do
    local Svcs = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
    local function movesetChild(name)
        local ch = LocalPlayer.Character
        local ms = ch and ch:FindFirstChild("Moveset")
        return ms and ms:FindFirstChild(name)
    end

    -- Auto World Cutting Slash: Rush -> FlameArrow -> (0.8s) -> Itadori RightActivated, only on full ult
    _G.WORLDSLASH = _G.WORLDSLASH or {}
    local function disconnectWorldSlash()
        for _, c in ipairs(_G.WORLDSLASH) do pcall(function() c:Disconnect() end) end
        _G.WORLDSLASH = {}
        if _G.WORLDSLASH_CHARCONN then pcall(function() _G.WORLDSLASH_CHARCONN:Disconnect() end) _G.WORLDSLASH_CHARCONN = nil end
    end
    local function worldSlashConnect(character)
        local humanoid = character:WaitForChild("Humanoid")
        table.insert(_G.WORLDSLASH, humanoid.AnimationPlayed:Connect(function(track)
            if not St.autoWorldSlashEnabled then return end
            if not (track.Animation and track.Animation.AnimationId == "rbxassetid://131506102901134") then return end
            local full = false
            pcall(function() full = (LocalPlayer.PlayerGui.Main.Controls.Ultimate.Special.Fill.Size.X.Scale >= 1) end)
            if not full then return end
            local rush, open = movesetChild("Rush"), movesetChild("Open")
            pcall(function() if rush then Svcs.RushService.RE.Activated:FireServer(rush) end end)
            pcall(function() if open then Svcs.FlameArrowService.RE.Activated:FireServer(open) end end)
            task.wait(.8)
            pcall(function() Svcs.ItadoriService.RE.RightActivated:FireServer() end)
        end))
    end
    _G.NH_enableWorldSlash = function()
        disconnectWorldSlash()
        if LocalPlayer.Character then worldSlashConnect(LocalPlayer.Character) end
        _G.WORLDSLASH_CHARCONN = LocalPlayer.CharacterAdded:Connect(worldSlashConnect)
    end
    _G.NH_disableWorldSlash = disconnectWorldSlash

    -- Auto Frog Variant (Megumi / Ten Shadows): NueService.Activated with Moveset.Nue
    _G.FROGVARIANT = _G.FROGVARIANT or {}
    local function disconnectFrog()
        for _, c in ipairs(_G.FROGVARIANT) do pcall(function() c:Disconnect() end) end
        _G.FROGVARIANT = {}
        if _G.FROGVARIANT_CHARCONN then pcall(function() _G.FROGVARIANT_CHARCONN:Disconnect() end) _G.FROGVARIANT_CHARCONN = nil end
    end
    local function frogConnect(character)
        local humanoid = character:WaitForChild("Humanoid")
        table.insert(_G.FROGVARIANT, humanoid.AnimationPlayed:Connect(function(track)
            if not St.autoFrogVariantEnabled then return end
            if not (track.Animation and track.Animation.AnimationId == "rbxassetid://116432619539029") then return end
            local nue = movesetChild("Nue")
            if not nue then return end
            pcall(function() Svcs.NueService.RE.Activated:FireServer(nue) end)
        end))
    end
    _G.NH_enableFrog = function()
        disconnectFrog()
        if LocalPlayer.Character then frogConnect(LocalPlayer.Character) end
        _G.FROGVARIANT_CHARCONN = LocalPlayer.CharacterAdded:Connect(frogConnect)
    end
    _G.NH_disableFrog = disconnectFrog

    -- Auto Earthquake v3 (Mahoraga).
    --
    -- The old implementation could not make the variant consistently because it only sent a
    -- SECOND Deactivated remote after the animation reached 0.70s. By then a normal tap had
    -- already sent the user's real Deactivated input, so the server had ended the hold and
    -- committed the ordinary Earthquake. 0.70s was also earlier than the live 0.75-0.90s
    -- success window, and one hard-coded animation ID made the trigger silently die after an
    -- animation update.
    --
    -- The genuine Activated call passes through unchanged. The exact native
    -- EarthquakeService.Deactivated payload is captured at the final outbound boundary,
    -- held for 0.80s, and then replayed once. ToolController and animation paths remain
    -- fallbacks, and Effects.Crush2 is retained as completion confirmation.
    _G.NH_AutoEarthquake = (function()
        local previous = rawget(_G, "NH_AutoEarthquake")
        if type(previous) == "table" and type(previous.Destroy) == "function" then
            pcall(previous.Destroy)
        end

        local M = {
            Version = "3.1-remote-gate-0.8",
            Enabled = false,
            Config = {
                MinimumHold = 0.80,
                ReleaseDelay = 0.80,
                LegacyAnimationId = "85024950165903",
            },
        }
        local S = {
            token = 0,
            busy = false,
            character = nil,
            move = nil,
            slot = nil,
            startedAt = 0,
            releaseAt = 0,
            releaseArgs = nil,
            remoteReleaseArgs = nil,
            remoteBypass = false,
            activatedCaptured = false,
            deactivatedCaptured = false,
            lastEffect = nil,
            sawCrush2 = false,
            userReleased = false,
            suppressSlot = nil,
            suppressUntil = 0,
            source = "idle",
            lastReleaseVia = nil,
            lastReleaseAt = 0,
            lastError = nil,
            controller = nil,
            previousUseKey = nil,
            wrapper = nil,
            knownAnimationIds = {},
        }
        M.State = S

        local destroyed = false
        local animationConnections = {}
        local characterConnection = nil
        local effectsConnection = nil

        local function digits(value)
            return tostring(value or ""):match("%d+")
        end

        local function disconnectList(list)
            for _, connection in ipairs(list) do
                pcall(function() connection:Disconnect() end)
            end
            table.clear(list)
        end

        local function normalized(value)
            return string.lower(tostring(value or "")):gsub("[^%w]", "")
        end

        local function isEarthquakeMove(move)
            if typeof(move) ~= "Instance" then return false end
            if normalized(move.Name) == "earthquake" then return true end
            local service = nil
            pcall(function() service = move:GetAttribute("Service") end)
            service = normalized(service)
            return service == "earthquake" or service == "earthquakeservice"
        end

        local NUMBER_NAMES = {
            one = 1, two = 2, three = 3, four = 4,
            five = 5, six = 6, seven = 7, eight = 8, nine = 9,
        }
        local function moveSlot(move)
            if not move then return nil end
            local key = nil
            pcall(function() key = move:GetAttribute("Key") end)
            if type(key) == "number" then return key end
            local numeric = tonumber(key)
            if numeric then return numeric end
            local keyText = string.lower(tostring(key or ""))
            for name, number in pairs(NUMBER_NAMES) do
                if string.find(keyText, name, 1, true) then return number end
            end
            return nil
        end

        local function earthquakeMove(character, requestedSlot)
            local moveset = character and character:FindFirstChild("Moveset")
            if not moveset then return nil end
            local wanted = tonumber(requestedSlot)
            local exact = moveset:FindFirstChild("Earthquake")
            if exact and isEarthquakeMove(exact) then
                local key = moveSlot(exact)
                if not wanted or not key or key == wanted then return exact end
            end
            for _, move in ipairs(moveset:GetChildren()) do
                if isEarthquakeMove(move) then
                    local key = moveSlot(move)
                    if not wanted or not key or key == wanted then return move end
                end
            end
            return nil
        end

        local function serviceRemote(name)
            local service = Svcs and Svcs:FindFirstChild("EarthquakeService")
            local remotes = service and service:FindFirstChild("RE")
            local remote = remotes and remotes:FindFirstChild(name)
            return remote and remote:IsA("RemoteEvent") and remote or nil
        end

        local activatedRemote = serviceRemote("Activated")
        local deactivatedRemote = serviceRemote("Deactivated")
        local effectsRemote = serviceRemote("Effects")

        local function hasEarthquakeAncestor(object, stopAt)
            local node = object
            while node and node ~= stopAt do
                if string.find(string.lower(node.Name), "earthquake", 1, true) then return true end
                node = node.Parent
            end
            return false
        end

        local function refreshAnimationIds()
            S.knownAnimationIds[M.Config.LegacyAnimationId] = true
            local root = ReplicatedStorage:FindFirstChild("Animations")
            if not root then return end
            for _, object in ipairs(root:GetDescendants()) do
                if object:IsA("Animation") and hasEarthquakeAncestor(object, root.Parent) then
                    local id = digits(object.AnimationId)
                    if id then S.knownAnimationIds[id] = true end
                end
            end
        end

        local function isEarthquakeAnimation(track)
            local animation = track and track.Animation
            if not animation then return false end
            local id = digits(animation.AnimationId)
            if id and S.knownAnimationIds[id] then return true end
            return hasEarthquakeAncestor(animation, nil)
        end

        local function cancelRun(reason)
            S.token += 1
            S.busy = false
            S.character = nil
            S.move = nil
            S.slot = nil
            S.releaseArgs = nil
            S.remoteReleaseArgs = nil
            S.userReleased = false
            if reason then S.source = reason end
        end

        local function sendRelease()
            local controller = S.controller
            local dispatcher = S.previousUseKey
            local slot = tonumber(S.slot) or moveSlot(S.move) or 3
            local extra = S.releaseArgs or table.pack()

            -- Replay the game's exact native release payload whenever available.
            if deactivatedRemote and S.remoteReleaseArgs then
                local args = S.remoteReleaseArgs
                S.remoteBypass = true
                local result = table.pack(pcall(function()
                    deactivatedRemote:FireServer(table.unpack(args, 1, args.n or 0))
                end))
                S.remoteBypass = false
                if result[1] then return true, "captured EarthquakeService.Deactivated" end
                S.lastError = tostring(result[2])
            end

            -- Fallback to the exact ToolController release invocation.
            if controller and type(dispatcher) == "function" then
                S.remoteBypass = true
                local result = table.pack(pcall(
                    dispatcher,
                    controller,
                    slot,
                    "Deactivated",
                    table.unpack(extra, 1, extra.n or 0)
                ))
                S.remoteBypass = false
                if result[1] then return true, "ToolController" end
                S.lastError = tostring(result[2])
            end

            local move = S.move or earthquakeMove(LocalPlayer.Character, slot)
            if not deactivatedRemote or not move then
                return false, "Earthquake release path is unavailable"
            end
            S.remoteBypass = true
            local ok, err = pcall(function()
                deactivatedRemote:FireServer(move, false)
            end)
            S.remoteBypass = false
            if ok then return true, "EarthquakeService fallback" end
            return false, tostring(err)
        end

        local function releaseNow(token, source)
            if destroyed or not S.busy or token ~= S.token then return false end
            if LocalPlayer.Character ~= S.character or not S.move or not S.move.Parent then
                cancelRun("character or move changed")
                return false
            end

            local slot = tonumber(S.slot) or moveSlot(S.move) or 3
            local ok, via = sendRelease()
            if token ~= S.token then return false end
            S.busy = false
            S.lastReleaseAt = os.clock()
            S.lastReleaseVia = ok and via or nil
            S.lastError = ok and nil or tostring(via)
            S.suppressSlot = slot
            S.suppressUntil = os.clock() + 0.75
            S.source = source or S.source
            if not ok then
                warn("[NH Earthquake] " .. tostring(via))
                notify("Auto Earthquake", "Release failed; check the developer console.", 4)
            end
            return ok
        end

        local function scheduleRelease(token)
            task.spawn(function()
                while not destroyed and M.Enabled and St.autoEarthquakeEnabled
                    and token == S.token and os.clock() < S.releaseAt do
                    local remaining = S.releaseAt - os.clock()
                    if remaining > 0.035 then
                        task.wait(math.min(remaining, 0.03))
                    else
                        RunService.Heartbeat:Wait()
                    end
                end
                if not destroyed and M.Enabled and St.autoEarthquakeEnabled and token == S.token then
                    releaseNow(token, "automatic 0.80s release")
                end
            end)
        end

        local function arm(character, move, slot, source, elapsed)
            if destroyed or not M.Enabled or not St.autoEarthquakeEnabled then return false end
            if not character or character ~= LocalPlayer.Character then return false end
            move = move or earthquakeMove(character, slot)
            if not isEarthquakeMove(move) then return false end

            local now = os.clock()
            local wantedSlot = tonumber(slot) or moveSlot(move) or 3
            if S.busy and S.character == character and S.slot == wantedSlot
                and now <= S.releaseAt + 0.35 then
                return true -- the animation fallback saw the same native press
            end

            S.token += 1
            local token = S.token
            S.busy = true
            S.character = character
            S.move = move
            S.slot = wantedSlot
            S.startedAt = now - math.max(0, tonumber(elapsed) or 0)
            S.releaseAt = S.startedAt + M.Config.ReleaseDelay
            if S.releaseAt < now then S.releaseAt = now end
            S.releaseArgs = nil
            S.remoteReleaseArgs = nil
            S.userReleased = false
            S.suppressSlot = nil
            S.suppressUntil = 0
            S.activatedCaptured = (source == "EarthquakeService.Activated")
            S.deactivatedCaptured = false
            S.lastEffect = nil
            S.sawCrush2 = false
            S.source = source or "unknown"
            S.lastError = nil
            scheduleRelease(token)
            return true
        end

        -- Returning true suppresses this one outbound FireServer call.
        local function remoteGate(remote, args)
            if destroyed or not M.Enabled or not St.autoEarthquakeEnabled or S.remoteBypass then
                return false
            end

            if remote == activatedRemote then
                -- Synchronous, method-free latch so even a very fast tap is caught.
                local now = os.clock()
                local capturedMove = args and args[1] or nil
                S.token += 1
                local token = S.token
                S.busy = true
                S.character = LocalPlayer.Character
                S.move = (typeof(capturedMove) == "Instance" and capturedMove) or S.move
                S.slot = S.slot or 3
                S.startedAt = now
                S.releaseAt = now + M.Config.ReleaseDelay
                S.releaseArgs = nil
                S.remoteReleaseArgs = nil
                S.userReleased = false
                S.suppressSlot = nil
                S.suppressUntil = 0
                S.activatedCaptured = true
                S.deactivatedCaptured = false
                S.lastEffect = nil
                S.sawCrush2 = false
                S.source = "EarthquakeService.Activated"
                S.lastError = nil
                scheduleRelease(token)

                task.defer(function()
                    if destroyed or token ~= S.token then return end
                    local character = LocalPlayer.Character
                    local move = (typeof(capturedMove) == "Instance" and capturedMove)
                        or earthquakeMove(character)
                    if isEarthquakeMove(move) then
                        S.character = character
                        S.move = move
                        S.slot = moveSlot(move) or S.slot or 3
                    end
                end)
                return false
            end

            if remote == deactivatedRemote then
                local now = os.clock()
                if S.busy then
                    S.remoteReleaseArgs = args
                    S.deactivatedCaptured = true
                    S.userReleased = true
                    if now < S.releaseAt then
                        S.source = "captured native Deactivated"
                        return true
                    end

                    S.token += 1
                    S.busy = false
                    S.lastReleaseAt = now
                    S.lastReleaseVia = "user/native remote window"
                    S.suppressUntil = now + 0.75
                    return false
                elseif now < S.suppressUntil then
                    return true
                end
            end

            return false
        end

        local function effectNameFromArgs(...)
            local packed = table.pack(...)
            for i = 1, packed.n do
                local value = packed[i]
                if type(value) == "string" then
                    local name = normalized(value)
                    if name == "start" or name == "cursebuild" or name == "crush" or name == "crush2" then
                        return name
                    end
                elseif type(value) == "table" then
                    for _, key in ipairs({1, "Name", "Event", "Type", "Action"}) do
                        local candidate = value[key]
                        if type(candidate) == "string" then
                            local name = normalized(candidate)
                            if name == "start" or name == "cursebuild" or name == "crush" or name == "crush2" then
                                return name
                            end
                        end
                    end
                end
            end
            return nil
        end

        local function installEffectsListener()
            if effectsConnection then pcall(function() effectsConnection:Disconnect() end) end
            effectsConnection = nil
            if not effectsRemote then return false end
            effectsConnection = effectsRemote.OnClientEvent:Connect(function(...)
                if destroyed or not M.Enabled or not S.busy then return end
                local eventName = effectNameFromArgs(...)
                if not eventName then return end
                S.lastEffect = eventName
                if eventName == "crush2" then
                    S.sawCrush2 = true
                    local token = S.token
                    local remaining = (S.startedAt + M.Config.MinimumHold) - os.clock()
                    if remaining > 0 then
                        task.delay(remaining, function()
                            if token == S.token then releaseNow(token, "Crush2 confirmed") end
                        end)
                    else
                        releaseNow(token, "Crush2 confirmed")
                    end
                end
            end)
            return true
        end

        local function installDispatcherHook()
            local controller = nhGetToolController()
            if not controller or type(controller.UseKey) ~= "function" then return false end
            if controller._NH_autoEarthquakePatched == M then
                S.controller = controller
                return true
            end

            local previousUseKey = controller.UseKey
            local wrapper
            wrapper = function(self, slot, eventName, ...)
                local extra = table.pack(...)
                local character = LocalPlayer.Character
                local move = earthquakeMove(character, slot)
                local ours = M.Enabled and St.autoEarthquakeEnabled and isEarthquakeMove(move)

                if ours and eventName == "Activated" then
                    -- Arm BEFORE dispatch so a very fast touch release cannot beat our state flag.
                    arm(character, move, slot, "native ToolController input", 0)
                    local result = table.pack(pcall(
                        previousUseKey,
                        self,
                        slot,
                        eventName,
                        table.unpack(extra, 1, extra.n or 0)
                    ))
                    if not result[1] then
                        cancelRun("native activation failed")
                        error(result[2], 0)
                    end
                    return table.unpack(result, 2, result.n)
                elseif ours and eventName == "Deactivated" then
                    local numericSlot = tonumber(slot) or moveSlot(move) or 3
                    local now = os.clock()
                    if S.busy and S.character == character and S.slot == numericSlot then
                        S.releaseArgs = extra
                        S.userReleased = true

                        -- Let the native handler construct its real remote payload;
                        -- remoteGate suppresses only the final outbound call.
                        return previousUseKey(
                            self,
                            slot,
                            eventName,
                            table.unpack(extra, 1, extra.n or 0)
                        )
                    elseif S.suppressSlot == numericSlot and now < S.suppressUntil then
                        return nil
                    end
                end

                return previousUseKey(
                    self,
                    slot,
                    eventName,
                    table.unpack(extra, 1, extra.n or 0)
                )
            end

            S.controller = controller
            S.previousUseKey = previousUseKey
            S.wrapper = wrapper
            controller.UseKey = wrapper
            controller._NH_autoEarthquakePatched = M
            return true
        end

        local function hookCharacter(character)
            disconnectList(animationConnections)
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
                or character:WaitForChild("Humanoid", 8)
            if not humanoid then return end
            animationConnections[#animationConnections + 1] = humanoid.AnimationPlayed:Connect(function(track)
                if not M.Enabled or not St.autoEarthquakeEnabled then return end
                if not isEarthquakeAnimation(track) then return end
                local move = earthquakeMove(character)
                if not move then return end
                arm(character, move, moveSlot(move) or 3, "animation fallback", track.TimePosition)
            end)
        end

        function M.IsEarthquakeSlot(character, slot)
            return isEarthquakeMove(earthquakeMove(character or LocalPlayer.Character, slot))
        end

        function M.Start()
            if destroyed then return false end
            M.Enabled = true
            St.autoEarthquakeEnabled = true
            refreshAnimationIds()
            _G.NH_EarthquakeRemoteGate = remoteGate
            installEffectsListener()
            disconnectList(animationConnections)
            if characterConnection then pcall(function() characterConnection:Disconnect() end) end
            if LocalPlayer.Character then task.spawn(hookCharacter, LocalPlayer.Character) end
            characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                cancelRun("respawned")
                if M.Enabled then task.spawn(hookCharacter, character) end
            end)

            if not installDispatcherHook() then
                task.spawn(function()
                    for _ = 1, 40 do
                        if destroyed or not M.Enabled or installDispatcherHook() then return end
                        task.wait(0.25)
                    end
                    if M.Enabled then
                        notify("Auto Earthquake", "ToolController was not found; animation fallback only.", 4)
                    end
                end)
            end
            return true
        end

        function M.Stop()
            -- If an early physical release was swallowed, disabling must immediately finish the
            -- held move instead of leaving Earthquake stuck in a charging state.
            local wasBusy, token = S.busy, S.token
            if wasBusy then releaseNow(token, "disabled while holding") end
            M.Enabled = false
            St.autoEarthquakeEnabled = false
            cancelRun("disabled")
            disconnectList(animationConnections)
            if characterConnection then
                pcall(function() characterConnection:Disconnect() end)
                characterConnection = nil
            end
            if effectsConnection then
                pcall(function() effectsConnection:Disconnect() end)
                effectsConnection = nil
            end
            return false
        end

        function M.Status()
            return {
                version = M.Version,
                enabled = M.Enabled,
                busy = S.busy,
                source = S.source,
                slot = S.slot,
                minimumHold = M.Config.MinimumHold,
                releaseDelay = M.Config.ReleaseDelay,
                userReleaseCaptured = S.userReleased,
                activatedRemoteCaptured = S.activatedCaptured,
                deactivatedRemoteCaptured = S.deactivatedCaptured,
                lastEffect = S.lastEffect,
                sawCrush2 = S.sawCrush2,
                lastReleaseVia = S.lastReleaseVia,
                lastError = S.lastError,
                move = S.move and S.move:GetFullName() or nil,
                dispatcherHooked = S.controller ~= nil and S.wrapper ~= nil,
            }
        end

        function M.Destroy()
            if destroyed then return end
            M.Stop()
            destroyed = true
            local controller = S.controller
            if controller then
                if controller.UseKey == S.wrapper then controller.UseKey = S.previousUseKey end
                if controller._NH_autoEarthquakePatched == M then
                    controller._NH_autoEarthquakePatched = nil
                end
            end
            if rawget(_G, "NH_EarthquakeRemoteGate") == remoteGate then
                _G.NH_EarthquakeRemoteGate = nil
            end
            if rawget(_G, "NH_AutoEarthquake") == M then _G.NH_AutoEarthquake = nil end
        end

        return M
    end)()

    _G.NH_enableEq = function()
        local module = rawget(_G, "NH_AutoEarthquake")
        return module and module.Start and module.Start()
    end
    _G.NH_disableEq = function()
        local module = rawget(_G, "NH_AutoEarthquake")
        return module and module.Stop and module.Stop()
    end

    -- Auto Mahoraga Throw (aim where you look): while the Mahoraga throw animation plays,
    -- keep turning your HumanoidRootPart to face the camera's aim direction so the thrown
    -- object flies exactly where you're looking. Works on PC and mobile (aim = camera, so
    -- there is no keyboard/mouse dependency; on mobile you aim by dragging the camera).
    local mtThrowAnim = "rbxassetid://138852224035589"
    local mtActiveTrack = nil
    local mtAimConn = nil
    local mtAnimConns = {}
    local mtCharConn = nil
    local mtGui = nil
    local mtLabel = nil
    local function mtEnsureGui()
        if mtGui and mtGui.Parent then return end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
        mtGui = Instance.new("ScreenGui")
        mtGui.Name = "NH_MahoragaThrowGui"
        mtGui.ResetOnSpawn = false
        mtGui.IgnoreGuiInset = true
        mtGui.DisplayOrder = 999
        mtGui.Parent = pg
        mtLabel = Instance.new("TextLabel")
        mtLabel.Name = "StatusLabel"
        mtLabel.Size = UDim2.new(0, 150, 0, 40)
        mtLabel.Position = UDim2.new(1, -160, 1, -50)
        mtLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        mtLabel.BackgroundTransparency = 0.5
        mtLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- yellow
        mtLabel.Font = Enum.Font.GothamBold
        mtLabel.TextSize = 16
        mtLabel.Text = "Aiming"
        mtLabel.BorderSizePixel = 0
        mtLabel.Visible = false
        mtLabel.Parent = mtGui
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = mtLabel
    end
    local function mtHookChar(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        table.insert(mtAnimConns, humanoid.AnimationPlayed:Connect(function(track)
            if not St.autoMahoragaThrowEnabled then return end
            if track.Animation and track.Animation.AnimationId == mtThrowAnim then
                mtActiveTrack = track
                mtEnsureGui()
                if mtLabel then mtLabel.Visible = true end
            end
        end))
    end
    local function mtDisconnect()
        for _, c in ipairs(mtAnimConns) do pcall(function() c:Disconnect() end) end
        mtAnimConns = {}
        if mtCharConn then pcall(function() mtCharConn:Disconnect() end) mtCharConn = nil end
        if mtAimConn then pcall(function() mtAimConn:Disconnect() end) mtAimConn = nil end
        mtActiveTrack = nil
        if mtLabel then mtLabel.Visible = false end
    end
    _G.NH_enableMahoragaThrow = function()
        mtDisconnect()
        mtEnsureGui()
        if LocalPlayer.Character then mtHookChar(LocalPlayer.Character) end
        mtCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            mtActiveTrack = nil
            if mtLabel then mtLabel.Visible = false end
            mtHookChar(newChar)
        end)
        mtAimConn = RunService.Heartbeat:Connect(function()
            if not St.autoMahoragaThrowEnabled then return end
            if mtActiveTrack and (not mtActiveTrack.IsPlaying or mtActiveTrack.TimePosition >= mtActiveTrack.Length) then
                mtActiveTrack = nil
                if mtLabel then mtLabel.Visible = false end
                return
            end
            if not mtActiveTrack then return end
            local char = LocalPlayer.Character
            local myHRP = char and char:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            if not myHRP or not cam then return end
            myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + cam.CFrame.LookVector)
        end)
    end
    _G.NH_disableMahoragaThrow = mtDisconnect

    -- Auto Shut Up (Charles / Mangaka): when you use the Shut Up move, instantly turn your BACK
    -- toward the nearest enemy within range (Shut Up only lands when the target is behind you).
    -- Fires on BOTH the Shut Up animation AND the move slot-2 key, and finds targets the SAME way
    -- the aimbot/lock-on does (real players + nearby NPC humanoids), so it can't miss the enemy.
    _G.SHUTUP = _G.SHUTUP or {}
    local shutUpBusy = false
    local function disconnectShutUp()
        if _G.SHUTUP_STOP then local f = _G.SHUTUP_STOP; _G.SHUTUP_STOP = nil; pcall(f) end
        pcall(function() RunService:UnbindFromRenderStep("NH_ShutUpFace") end)
        for _, c in ipairs(_G.SHUTUP) do pcall(function() c:Disconnect() end) end
        _G.SHUTUP = {}
        if _G.SHUTUP_CHARCONN then pcall(function() _G.SHUTUP_CHARCONN:Disconnect() end) _G.SHUTUP_CHARCONN = nil end
    end
    local function shutUpNearestCore(myHrp)
        local best, bestDist = nil, 10  -- 10 studs: only snap back toward enemy if this close
        -- real players
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local core = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso")
                if hum and core and hum.Health > 0 then
                    local d = (core.Position - myHrp.Position).Magnitude
                    if d <= bestDist then bestDist = d; best = core end
                end
            end
        end
        -- nearby NPC humanoids (training dummies / bosses) within range
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 then
                local model = obj.Parent
                if model and model:IsA("Model") and model ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(model) then
                    local core = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
                    if core then
                        local d = (core.Position - myHrp.Position).Magnitude
                        if d <= bestDist then bestDist = d; best = core end
                    end
                end
            end
        end
        return best
    end
    local function shutUpStopHold()
        if _G.SHUTUP_STOP then
            local f = _G.SHUTUP_STOP
            _G.SHUTUP_STOP = nil
            pcall(f)
        end
    end
    -- Decide, every frame, which way our BACK should point. Recomputed live so it tracks a
    -- moving enemy and follows the camera under shiftlock (exactly like the BF chain does).
    local function shutUpBackDir(myHrp, lockedTarget)
        -- Priority 1: enemy within 10 studs → back faces TOWARD them (camera-independent).
        if lockedTarget and lockedTarget.Parent then
            local flat = (lockedTarget.Position - myHrp.Position) * Vector3.new(1, 0, 1)
            if flat.Magnitude >= 0.1 then return flat.Unit end
        end
        -- Priority 2: no enemy → back faces where the player is aiming.
        local camFlat = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
        local hrpFlat = myHrp.CFrame.LookVector * Vector3.new(1, 0, 1)
        local camOk = camFlat.Magnitude >= 0.1
        local hrpOk = hrpFlat.Magnitude >= 0.1
        -- Shiftlock detection that works on PC (MouseBehavior) AND mobile (the shiftlock button
        -- keeps camera + body aligned). In shiftlock the camera look IS the intended facing, so
        -- back = camera look. In free cam the camera can point INTO our back, so use body facing.
        local shiftLock = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter)
        if not shiftLock and camOk and hrpOk then
            shiftLock = camFlat.Unit:Dot(hrpFlat.Unit) > 0.85
        end
        if shiftLock and camOk then
            return camFlat.Unit
        elseif hrpOk then
            return hrpFlat.Unit
        elseif camOk then
            return camFlat.Unit
        end
        return Vector3.new(0, 0, 1)
    end
    local function shutUpFace(hrp, lockedTarget)
        local backDir = shutUpBackDir(hrp, lockedTarget)
        local pos = hrp.Position
        -- lookAt(pos, pos - backDir) makes our LookVector = -backDir, so our BACK points to backDir.
        hrp.CFrame = CFrame.lookAt(pos, pos - backDir)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    local SHUTUP_HOLD_TIME = 0.6  -- seconds to hold our back locked to the enemy (covers the grab)
    local function shutUpRotate()
        if not St.autoShutUpEnabled then return end
        if shutUpBusy then return end
        local ch = LocalPlayer.Character
        local myHrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        shutUpBusy = true

        -- Lock onto the nearest enemy once (if within 10 studs); tracked live below.
        local lockedTarget = shutUpNearestCore(myHrp)
        local prevAutoRotate = hum.AutoRotate
        hum.AutoRotate = false

        -- 1) IMMEDIATE, synchronous turn. This is what makes the move GRAB: the game samples our
        --    facing the instant the move fires, so our back must already be turned right now — not
        --    one frame later. (The old version only started turning next frame, so it whiffed.)
        pcall(function() shutUpFace(myHrp, lockedTarget) end)

        -- 2) HOLD it against shiftlock. Shiftlock + the game's camera re-rotate the character to
        --    face the camera, and they do it in different frame phases. A render-only override
        --    flickers and the server never sees it. So we reassert our facing in ALL phases:
        --    BindToRenderStep at Last (wins the on-screen frame) + Stepped + Heartbeat (win the
        --    physics/replicated state the server reads for the grab). Held for a short window.
        shutUpStopHold()
        local conns = {}
        local t0 = tick()
        local function cleanup()
            for _, cn in ipairs(conns) do pcall(function() cn:Disconnect() end) end
            pcall(function() RunService:UnbindFromRenderStep("NH_ShutUpFace") end)
            pcall(function() if hum and hum.Parent then hum.AutoRotate = prevAutoRotate end end)
        end
        _G.SHUTUP_STOP = cleanup
        local function tickFn()
            local c = LocalPlayer.Character
            local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
            if (not hrp2) or (not St.autoShutUpEnabled) or (tick() - t0 > SHUTUP_HOLD_TIME) then
                shutUpStopHold()
                return
            end
            pcall(function() shutUpFace(hrp2, lockedTarget) end)
        end
        table.insert(conns, RunService.Stepped:Connect(function() tickFn() end))
        table.insert(conns, RunService.Heartbeat:Connect(function() tickFn() end))
        pcall(function()
            RunService:BindToRenderStep("NH_ShutUpFace", Enum.RenderPriority.Last.Value, tickFn)
        end)

        task.delay(SHUTUP_HOLD_TIME + 0.1, function() shutUpBusy = false end)
    end
    _G.NH_shutUpRotate = shutUpRotate
    local function shutUpConnect(character)
        local humanoid = character:WaitForChild("Humanoid")
        table.insert(_G.SHUTUP, humanoid.AnimationPlayed:Connect(function(track)
            if not St.autoShutUpEnabled then return end
            if track.Animation and track.Animation.AnimationId == "rbxassetid://79860101129549" then
                shutUpRotate()
            end
        end))
    end
    _G.NH_enableShutUp = function()
        disconnectShutUp()
        if LocalPlayer.Character then shutUpConnect(LocalPlayer.Character) end
        _G.SHUTUP_CHARCONN = LocalPlayer.CharacterAdded:Connect(shutUpConnect)

        -- PC: fire on key 2 press (move slot 2 = Shut Up)
        table.insert(_G.SHUTUP, UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not St.autoShutUpEnabled then return end
            if input.KeyCode == Enum.KeyCode.Two then shutUpRotate() end
        end))

        -- ALL PLATFORMS: hook ToolController.UseKey, the game's own move dispatcher. This is the
        -- most reliable trigger: it runs the instant slot 2 (Shut Up) is used, BEFORE the move is
        -- sent to the server. We rotate SYNCHRONOUSLY right here so our back is already turned when
        -- the grab fires — that one-frame head start is what makes the move actually connect.
        task.spawn(function()
            local ok, Knit = pcall(function()
                return require(ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"))
            end)
            if not ok or not Knit then return end
            local tc = nil
            pcall(function() tc = Knit.GetController("ToolController") end)
            if not tc or type(tc.UseKey) ~= "function" then return end
            if tc._NH_shutUpPatched then return end
            tc._NH_shutUpPatched = true
            local origUseKey = tc.UseKey
            tc.UseKey = function(self, slot, eventName, ...)
                if slot == 2 and eventName == "Activated" and St.autoShutUpEnabled then
                    local ch2 = LocalPlayer.Character
                    local mv2 = ch2 and ch2:GetAttribute("Moveset")
                    if mv2 ~= "Haruta" then
                        pcall(shutUpRotate)  -- synchronous: turn BEFORE the move is sent
                    end
                end
                return origUseKey(self, slot, eventName, ...)
            end
            table.insert(_G.SHUTUP, {
                Disconnect = function()
                    if tc and tc._NH_shutUpPatched then
                        tc.UseKey = origUseKey
                        tc._NH_shutUpPatched = nil
                    end
                end
            })
        end)
    end
    _G.NH_disableShutUp = disconnectShutUp
end

-- ============================================================
-- AUTO COUNTER SYSTEM — PATCH P1
-- One ready moveset counter per verified threat. No Action-priority guessing,
-- velocity-only proximity detection, block/ultimate chains, or damage re-arming.
do
    Cfg.AutoCounter = { M1Range = 4, MinimumInterval = 1.0, UnknownCooldown = 6.0,
        LeadTime = 0.18, MaximumLead = 0.35 }
    local env = getgenv()
    env.AutoCounter, env.AutoCounterRange, env.NH_autoCounterRunning = false, 4, false
    St.autoCounterRange = 4
    local moves = {
        { "Manji Kick", "ManjiKickService" }, { "Head Splitter", "HeadSplitterService" },
        { "Eye Catching", "EyeCatchService" }, { "Adaptation", "AdaptationService" },
        { "Outburst", "OutburstService" }, { "Supernova", "SupernovaService" },
        { "Shut Up", "ShutUpService" }, { "Decisive Strike", "DecisiveStrikeService" },
        { "Defense Response", "DefenseResponseService" },
    }
    local moveLocks = setmetatable({}, { __mode = "k" })
    local nextFire, busyUntil = 0, 0
    St.CounterState = { lastReason = "disabled", lastMove = "", fired = 0 }
    local function readyMove(char)
        local ms = char:FindFirstChild("Moveset")
        local knit = ReplicatedStorage:FindFirstChild("Knit")
        local inner = knit and knit:FindFirstChild("Knit")
        local services = inner and inner:FindFirstChild("Services")
        if not ms or not services then return end
        local serverNow = Workspace:GetServerTimeNow()
        for _, entry in ipairs(moves) do
            local move = ms:FindFirstChild(entry[1])
            if move then
                local readyAt = tonumber(move:GetAttribute("ReadyAt"))
                if readyAt and readyAt > serverNow then continue end
                local lock = moveLocks[move]
                if lock and lock.untilT > os.clock()
                    and (not readyAt or readyAt <= (lock.readyAt or 0)) then continue end
                local service = services:FindFirstChild(entry[2])
                local re = service and service:FindFirstChild("RE")
                local remote = re and re:FindFirstChild("Activated")
                if remote and remote:IsA("RemoteEvent") then return move, remote, readyAt end
            end
        end
    end
    function St.tryCounter(threat)
        if St.bfChainActive then return false end
        if not St.autoCounterEnabled or not threat or threat.expires < os.clock() then return false end
        local now, char = os.clock(), LocalPlayer.Character
        if now < nextFire or now < busyUntil or not St.Face.canDefend(char) then return false end
        if env.userIsBlocking then return false end -- manual guard always belongs to the player
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        if threat.kind == "m1" or threat.kind == "dash" then
            local other = threat.root
            local otherChar = other and other.Parent
            local hum = otherChar and otherChar:FindFirstChildOfClass("Humanoid")
            if not other or not other.Parent or not hum or hum.Health <= 0 then return false end
            if _G.NH_IsSoloBlockTarget and not _G.NH_IsSoloBlockTarget(otherChar) then return false end
            local delta = root.Position - other.Position
            local limit = threat.kind == "m1" and Cfg.AutoCounter.M1Range or 9
            if delta.Magnitude > limit then return false end
            local flat = delta * Vector3.new(1, 0, 1)
            local look = other.CFrame.LookVector * Vector3.new(1, 0, 1)
            if flat.Magnitude > 0.1 and look.Magnitude > 0.1
                and look.Unit:Dot(flat.Unit) < math.cos(math.rad(65)) then return false end
        elseif threat.kind == "projectile" then
            if not threat.root or not threat.root.Parent then return false end
            if St.autoBlockSoloEnabled and (not threat.source or not _G.NH_IsSoloBlockTarget(threat.source)) then return false end
        else return false end
        local ping = 0
        pcall(function() ping = LocalPlayer:GetNetworkPing() * 2 end)
        if threat.impact > math.clamp(Cfg.AutoCounter.LeadTime + ping, Cfg.AutoCounter.LeadTime,
            Cfg.AutoCounter.MaximumLead) then return false end
        local move, remote, readyAt = readyMove(char)
        if not move then St.CounterState.lastReason = "no ready counter"; return false end
        -- Commit cooldown before any remote call, so duplicate event paths cannot race.
        nextFire, busyUntil = now + Cfg.AutoCounter.MinimumInterval, now + 0.35
        St.autoCounterBusy, St.autoCounterCooldown = true, Cfg.AutoCounter.MinimumInterval
        -- ReadyAt is server-time based. Unknown cooldowns use a conservative fallback.
        moveLocks[move] = { untilT = now + Cfg.AutoCounter.UnknownCooldown, readyAt = readyAt }
        -- A verified counter may face its actual attacker, but never fight a dash owner.
        if threat.root and St.Face.canRotate(char:FindFirstChildOfClass("Humanoid"))
            and St.Face.claim("counter", 0.18) then
            local direction = (threat.root.Position - root.Position) * Vector3.new(1, 0, 1)
            if direction.Magnitude > 0.01 then
                char:FindFirstChildOfClass("Humanoid").AutoRotate = false
                root.CFrame = CFrame.lookAt(root.Position, root.Position + direction.Unit)
            end
        end
        local ok = pcall(function() remote:FireServer(move) end)
        if not ok then St.CounterState.lastReason = "remote failed"; return false end
        St.DefenseBus.consume(threat.key)
        St.counterGuardUntil = now + 0.35
        if _G.NH_forceStopBlock then _G.NH_forceStopBlock() end
        St.CounterState.lastMove = move.Name; St.CounterState.lastReason = threat.kind
        St.CounterState.fired += 1
        return true
    end
    local function disable()
        St.autoCounterEnabled, env.AutoCounter, env.NH_autoCounterRunning = false, false, false
        St.autoCounterBusy, St.autoCounterCooldown, St.counterGuardUntil = false, 0, 0
        if Cn.autoCounterConn then Cn.autoCounterConn:Disconnect(); Cn.autoCounterConn = nil end
        if Cn.autoCounterCharConn then Cn.autoCounterCharConn:Disconnect(); Cn.autoCounterCharConn = nil end
        St.Face.release("counter")
        St.Face.restore(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
        St.DefenseBus.reset(); St.CounterState.lastReason = "disabled"
    end
    local function enable()
        if St.autoCounterEnabled and Cn.autoCounterConn then return end
        St.autoCounterEnabled, env.AutoCounter, env.NH_autoCounterRunning = true, true, true
        St.CounterState.lastReason = "armed"
        Cn.autoCounterConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            St.autoCounterBusy = now < busyUntil
            St.autoCounterCooldown = math.max(nextFire - now, 0)
            if now >= busyUntil then
                St.Face.release("counter")
                St.Face.restore(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
            end
            St.DefenseBus.step()
        end)
        Cn.autoCounterCharConn = LocalPlayer.CharacterAdded:Connect(function()
            nextFire, busyUntil = 0, 0
            St.counterGuardUntil, St.autoCounterBusy, St.autoCounterCooldown = 0, false, 0
            table.clear(moveLocks); St.DefenseBus.reset()
        end)
    end
    _G.NH_enableAutoCounter, _G.NH_disableAutoCounter = enable, disable
end

-- ── SECTION 1: Auto Character Moves ─────────────────────────
Tabs.Characters:AddSection("Auto Character Moves")
Tabs.Characters:AddToggle("TglTodoPerfectSwap", {Title="Auto Todo Perfect Swap", Default=false, Callback=function(v) St.todoEnabled = v end})
Tabs.Characters:AddToggle("TglTodoBlackFlash", {Title="Auto Todo Black Flash", Default=false, Callback=function(v) St.todoBlackFlashEnabled = v if v then enableTodoBlackFlash() else disconnectTodoBlackFlash() end end})
Tabs.Characters:AddToggle("TglTodoVoid", {
    Title="Todo Void",
    Description="Uses native Todo Swift Kick; lock a target or it selects the nearest live target.",
    Default=false,
    Callback=function(v)
        St.todoVoidEnabled = v and true or false
        if St.todoVoidEnabled then
            local sweep = rawget(_G, "NH_TodoSweepVariant") or rawget(getgenv(), "NH_TodoSweepVariant")
            if type(sweep) == "table" and type(sweep.SetEnabled) == "function" then
                pcall(function()
                    local option = Fluent.Options and Fluent.Options.TglTodoSweepVariant
                    if option then option:SetValue(false) end
                end)
                sweep.SetEnabled(false)
            end
        end
        local todoVoid = rawget(_G, "NH_TodoVoid")
        if type(todoVoid) == "table" and type(todoVoid.SetEnabled) == "function" then
            todoVoid.SetEnabled(St.todoVoidEnabled)
        elseif St.todoVoidEnabled then
            notify("Todo Void", "Standalone backend is unavailable.", 4)
        end
    end
})
Tabs.Characters:AddToggle("TglTodoSweepVariant", {
    Title="Todo Sweep Varient",
    Description="Toggle this on to change Todo's first move to the Pebble Throw varient.",
    Default=false,
    Callback=function(v)
        local enabled = v and true or false
        St.todoSweepVariantEnabled = enabled
        if enabled then
            pcall(function()
                local option = Fluent.Options and Fluent.Options.TglTodoVoid
                if option then option:SetValue(false) end
            end)
            local todoVoid = rawget(_G, "NH_TodoVoid")
            if type(todoVoid) == "table" and type(todoVoid.SetEnabled) == "function" then
                todoVoid.SetEnabled(false)
            end
            St.todoVoidEnabled = false
        end

        local sweep = rawget(_G, "NH_TodoSweepVariant") or rawget(getgenv(), "NH_TodoSweepVariant")
        if type(sweep) == "table" and type(sweep.SetEnabled) == "function" then
            sweep.SetEnabled(enabled)
        elseif enabled then
            St.todoSweepVariantEnabled = false
            notify("Todo Sweep Varient", "Managed backend is unavailable.", 4)
        end
    end
})
Tabs.Characters:AddToggle("TglNanami", {Title="Auto Nanami Ratio", Default=false, Callback=function(v) if v then startNanami() else stopNanami() end end})
Tabs.Characters:AddButton({Title="Instant Blackhole (Yuki)", Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dragonfly5101/Minosr/refs/heads/main/InstantBlackHole.JJS"))() end) end})
Tabs.Characters:AddToggle("TglAutoWorldSlash", {Title="Auto World Cutting Slash", Default=false, Callback=function(v) St.autoWorldSlashEnabled = v if v then _G.NH_enableWorldSlash() else _G.NH_disableWorldSlash() end end})
Tabs.Characters:AddToggle("TglAutoFrogVariant", {Title="Auto Frog Variant (Megumi)", Default=false, Callback=function(v) St.autoFrogVariantEnabled = v if v then _G.NH_enableFrog() else _G.NH_disableFrog() end end})
Tabs.Characters:AddToggle("TglAutoEarthquake", {Title="Auto Earthquake (Mahoraga)", Default=false, Callback=function(v) St.autoEarthquakeEnabled = v if v then _G.NH_enableEq() else _G.NH_disableEq() end end})
Tabs.Characters:AddParagraph({Title="Auto Mahoraga Throw Info", Content="Aim your camera where you want to throw."})
Tabs.Characters:AddToggle("TglAutoMahoragaThrow", {Title="Auto Mahoraga Throw", Default=false, Callback=function(v) St.autoMahoragaThrowEnabled = v if v then _G.NH_enableMahoragaThrow() else _G.NH_disableMahoragaThrow() end end})
Tabs.Characters:AddToggle("TglAutoShutUp", {Title="Auto Shut Up (Mangaka)", Default=false, Callback=function(v) St.autoShutUpEnabled = v if v then _G.NH_enableShutUp() else _G.NH_disableShutUp() end end})
Tabs.Characters:AddToggle("TglAutoCounter", {Title="Auto Counter", Default=false, Callback=function(v) if v then _G.NH_enableAutoCounter() else _G.NH_disableAutoCounter() end end})
Tabs.Characters:AddToggle("TglAutoGaruda", {Title="Auto Garuda Rebound (Yuki)", Default=false, Callback=function(v)
    local AG = _G.NH_AutoGaruda
    if not AG then notify("Auto Garuda", "Module failed to load.", 3) return end
    if v then
        AG.start()
        notify("Auto Garuda", "Armed. Throw Garuda Rebound - the second part fires itself.", 3)
    else
        AG.stop()
        notify("Auto Garuda", "Disabled.", 2)
    end
end})

Tabs.Characters:AddParagraph({Title="Haruta Backstab Info", Content="Equip Haruta with sword. Press 2 (PC) or tap your 2nd move (mobile) to dash behind your target and backstab. Want a separate mobile button too? Turn on 'Show Backstab UI Button'. You can enable this UI button in the Settings tab."})
Tabs.Characters:AddToggle("TglHarutaBs", {Title="Haruta Backstab", Default=false, Callback=function(v) St.harutaBackstabEnabled = v end})
if mobile then
    Tabs.Characters:AddToggle("TglHarutaBsBtn", {Title="Show Backstab UI Button", Default=false, Callback=function(v) St.harutaBsBtnEnabled = v end})
end
Tabs.Characters:AddToggle("TglAutoQTE", {Title="Auto QTE (Hiromi & Beam Clash)", Default=false, Callback=function(v) St.autoQteEnabled = v if v then startAutoQTE() else stopAutoQTE() end end})
Tabs.Characters:AddSlider("SldQTESpeed", {Title="QTE Speed (Clicks per sec)", Min=1, Max=50, Default=15, Rounding=0, Callback=function(v) St.qteSpeed = v end})
Tabs.Characters:AddButton({Title="Higuruma Vote Viewer", Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Dragonfly5101/Minosr/refs/heads/main/HigarumaVoteView.JJS"))() end) end})

-- ── SECTION 2: Black Flash Chain ─────────────────────────────
Tabs.Characters:AddSection("Black Flash Chain")
Tabs.Characters:AddParagraph({Title="Auto Black Flash Info", Content="Curved dash-behind + auto Black Flash. Uses v109 timing and native PC/mobile inputs. Start with BF Timing 0.26. Inputs are serialized; frame stalls or server rejection can still miss. Inspect _G.NH_bfTimingStatus() for the last pair."})
Tabs.Characters:AddToggle("TglAutoBF", {Title="Auto Black Flash Chain", Default=false, Callback=function(v) St.bfEnabled = v if v then bfStartAll() else bfStopAll() end end})
Tabs.Characters:AddSlider("BFDetect", {Title="Detect Range", Min=4, Max=20, Default=10, Rounding=0, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("DETECT_RANGE", v) end end})
Tabs.Characters:AddSlider("BFCurve", {Title="Curve Width", Min=0, Max=12, Default=5, Rounding=1, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("CURVE", v) end end})
Tabs.Characters:AddSlider("BFBackGap", {Title="Back Gap", Min=1, Max=8, Default=4.5, Rounding=1, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("BACKGAP", v) end end})
Tabs.Characters:AddSlider("BFLead", {Title="Predict Lead", Min=0.1, Max=0.6, Default=0.32, Rounding=2, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("PREDICT", v) end end})
Tabs.Characters:AddToggle("TglBFSmart", {Title="Smart Prediction", Default=true, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("SMART", v) end end})
Tabs.Characters:AddSlider("BFNetLead", {Title="Network Lead", Min=0, Max=2, Default=1, Rounding=2, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("NET_LEAD", v) end end})
Tabs.Characters:AddSlider("BFCam", {Title="Camera Follow Speed", Min=0.1, Max=1.5, Default=0.6, Rounding=2, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("CAM_SENS", v) end end})
Tabs.Characters:AddSlider("BFTiming", {Title="BF Timing", Min=0.15, Max=0.4, Default=0.26, Rounding=3, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("BF_TIMING", v) end end})
Tabs.Characters:AddSlider("BFSpeedCap", {Title="Dash Speed Cap", Min=120, Max=600, Default=320, Rounding=0, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("SPEEDCAP", v) end end})
Tabs.Characters:AddSlider("BFAntiFling", {Title="Anti-Fling Sens", Min=12, Max=60, Default=28, Rounding=0, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("ANTIFLING", v) end end})
Tabs.Characters:AddToggle("TglBFCamFollow", {Title="BF Camera Follow", Default=true, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("CAM_STEER", v) end end})
Tabs.Characters:AddToggle("TglBFAutoFlash", {Title="Auto Flash on Arrival", Default=true, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("AUTO_BF", v) end end})
Tabs.Characters:AddToggle("TglBFChain", {Title="Chain Reposition", Default=true, Callback=function(v) if _G.NH_bfSet then _G.NH_bfSet("CHAIN", v) end end})
if mobile then
    Tabs.Characters:AddToggle("TglBFChainBtn", {Title="Show BF Chain UI Button", Default=false, Callback=function(v) St.bfChainBtnEnabled = v end})
end

-- ── SECTION 3: 0.2 Kill All (Gojo) ──────────────────────────
Tabs.Characters:AddSection("0.2 Kill All (Gojo)")
Tabs.Characters:AddToggle("TglSweep", {Title="Sweep All", Default=false, Callback=function(v) St.sweepActive = v; if v then Workspace.FallenPartsDestroyHeight = Cfg.fallenHeight runSweep() else Workspace.FallenPartsDestroyHeight = St.originalFallenHeight end end})
Tabs.Characters:AddToggle("TglSweepOverlay", {Title="Show Sweep Target Overlay", Default=false, Callback=function(v) St.overlayEnabled = v if v then buildOverlay() else destroyOverlay() end end})
Tabs.Characters:AddButton({Title="Start Hunt", Callback=runHunt})
Tabs.Characters:AddButton({Title="Stop Hunt", Callback=stopHunt})
Tabs.Characters:AddToggle("TglDomainTP", {Title="No Domain TP", Default=false, Callback=function(v) St.noDomainTP = v end})
Tabs.Characters:AddButton({Title="Force Reset", Callback=forceReset})
Tabs.Characters:AddButton({Title="Check AC Status", Callback=checkACStatus})

-- ── Todo Range Swap (infinite range) ────────────────
Tabs.Characters:AddSection("Todo Range Swap")
Tabs.Characters:AddParagraph({Title="Todo Range Swap Info", Content="Infinite-range Boogie Woogie swap. 1) Enable Todo Range Swap. 2) If AC is active, press Start Hunt (the same Gojo hunt; press Stop Hunt to cancel). 3) Refresh + pick a player/dummy. 4) Press Swap With Selected. By default you switch places; enable Swap bring to me to stay put, or Swap To Area to send the target to the selected area. Attempts are serialized with a slightly longer, ping-aware settle/hold. Wait for the result before retrying."})
Tabs.Characters:AddToggle("TglTodoSwapEnable", {Title="Enable Todo Swap", Default=false, Callback=function(v)
    if v and not St.todoSwapAcBypassed then
        notify("Todo Range Swap", "Complete Start Hunt first to arm the shared AC proof.", 3)
        St.todoSwapEnabled = false
        pcall(function() Fluent.Options.TglTodoSwapEnable:SetValue(false) end)
        return
    end
    St.todoSwapEnabled = v
end})
Tabs.Characters:AddButton({Title="Start Hunt", Callback=runHunt})
Tabs.Characters:AddButton({Title="Stop Hunt", Callback=stopHunt})
local DpTodoSwap = Tabs.Characters:AddDropdown("DpTodoSwapTarget", {Title="Swap Target (players + dummies)", Values={"(press Refresh)"}, Default=1, Callback=function(v) St.todoSwapSelected = v end})
Tabs.Characters:AddButton({Title="Refresh Swap Targets", Callback=function()
    local names = {}
    if _G.NH_todoSwapTargets then for _, t in ipairs(_G.NH_todoSwapTargets()) do table.insert(names, t.name) end end
    if #names == 0 then names = {"(none found)"} end
    DpTodoSwap:SetValues(names)
    notify("Todo Range Swap", "Found " .. #names .. " targets.", 2)
end})
Tabs.Characters:AddToggle("TglTodoSwapReturn", {Title="Swap bring to me", Default=false, Callback=function(v) St.todoSwapReturn = v end})
Tabs.Characters:AddButton({Title="Swap With Selected", Callback=function()
    local sel = (Fluent.Options.DpTodoSwapTarget and Fluent.Options.DpTodoSwapTarget.Value) or St.todoSwapSelected
    if _G.NH_todoSwapExecute then _G.NH_todoSwapExecute(sel) end
end})
Tabs.Characters:AddDropdown("DpTodoSwapArea", {Title="Swap Area (for Swap To Area)", Values={"Restaurant", "Sewers", "Twin Towers"}, Default=1, Callback=function(v) St.todoSwapArea = v end})
Tabs.Characters:AddToggle("TglTodoSwapArea", {Title="Swap To Area (send target to spot above)", Default=false, Callback=function(v) St.todoSwapAreaEnabled = v end})

-- ================================================================
-- NH ANTI-CC v2.3.0 HUB BACKEND (MOVE-SAFE JUMP FIX)
-- Prepared synchronously but disabled until TglNoStun is enabled.
-- Nested closure avoids adding module locals to the hub main chunk.
-- ================================================================
do
    xpcall(function()
        --[[
        	NH Anti-CC  |  No Ragdoll / No Stun / Anti-Knockback / Action Unlock
        	Standalone build v2.3.0 (MOVE-SAFE JUMP FIX)

        	Platform: works on PC and mobile. No UI, no keybinds, no input hooks,
        	so there is nothing platform-specific to break. Toggle via API below
        	(hub import will wire this to a mobile-friendly toggle button).

        	=====================================================================
        	WHAT WAS ACTUALLY WRONG - TRACED LIVE IN YOUR SESSION
        	=====================================================================

        	1) THE MARKERS ARE IN Character.Info, NOT ON THE CHARACTER.
        	   MovementController reads them as:
        	     line 424  Character.Info:FindFirstChild("Block")   -> blocks dash
        	     line 428  Character.Info:FindFirstChild("Stun")    -> blocks dash
        	     line 436  Character.Info:FindFirstChild("InSkill")
        	     line 483  Character.Info:FindFirstChild("NoSprint")
        	   v2.1 destroyed markers on the Character itself, so it removed
        	   NOTHING. Live proof: after real gameplay, markers = 0 while
        	   anims = 34 and joints = 62. That is exactly why M1 and block stayed
        	   locked until the stun timer expired. THIS is the fix you asked for.

        	2) RAGDOLL IS A PRE-BUILT CONSTRAINT RIG, NOT A CREATED ONE.
        	   Character.RagdollConstraints holds 5 BallSocketConstraints that are
        	   already Enabled = true while you stand. Ragdoll works by DISABLING
        	   the 19 Motor6Ds so the BallSockets take over. That is why grepping
        	   for Instance.new("BallSocketConstraint") found nothing.
        	   So the rig is now kept rigid at ALL times, not only during a hit.

        	3) THE RAGDOLL STATE MIRROR.
        	   ChangeState/SetStateEnabled exist in exactly ONE client script,
        	   MovementController: Ragdoll > 0 -> ChangeState(Physics), else
        	   -> ChangeState(GettingUp). So instead of fighting it like v1 did,
        	   we mask Ragdoll to 0 and the game's own code stands you back up.

        	=====================================================================
        	DELIBERATELY PRESERVED - DO NOT "FIX" THESE
        	=====================================================================
        	* Knockback and ForceEsc markers are LEFT ALONE. MovementController
        	  line 415 and 1076 use them to grant the escape dash ("Q - dash, use
        	  in stun to escape"). Deleting them would remove your escape option.
        	* Block is LEFT ALONE - that is your own block state.
        	* BodyGyro is never touched - your own hover moves need it
        	  (Collapse, Hollow Purple, Dismantle, Great Serpent, Swift Kick).
        	* InSkill is NEVER removed. It marks player-owned move execution, so
        	  carry, sprint-boost, dash, flight and movement-state abilities survive.
        	* NoSprint/NoJump never open a hit window. Move-owned movers and
        	  velocity are never neutralized.

        	=====================================================================
        	HONEST LIMITS
        	=====================================================================
        	* Verified live: ragdoll state fully blocked (0 Physics samples over
        	  2.5s of held Ragdoll=1), reaction animations stopped (34 real),
        	  Motor6D re-enable (62 real), WalkSpeed restore, mover neutralizing.
        	* The M1/block unlock is a high-confidence fix but is NOT yet verified
        	  against a real hit - it went in after your last test. If M1 is ALSO
        	  gated server-side, no client script can fix that, and you will see
        	  the animation play but no damage register. Tell me which it is.
        	* AntiCheatController fails to decompile (:1051), so I could not read
        	  it. That is why there is no position-locking or CFrame anchoring
        	  here - it is the most detectable approach and I will not risk a
        	  public-server ban on an anti-cheat I could not read.
        	* Server-side damage still applies. This is a CC/mobility fix.

        	API:  NH_ANTI_CC.Start() / .Stop() / .toggle() / .Status() / .IsActive()
        ]]

        local ENV = getgenv and getgenv() or _G
        if type(ENV.NH_ANTI_CC) == "table" and type(ENV.NH_ANTI_CC.Destroy) == "function" then
        	pcall(ENV.NH_ANTI_CC.Destroy)
        end

        local Players = game:GetService("Players")
        local RS = game:GetService("RunService")
        local RepS = game:GetService("ReplicatedStorage")
        local LP = Players.LocalPlayer

        local M = {}
        M.Version = "2.3.0-move-safe-hub"
        M.Running = false
        M._bypass = false
        M.Config = {
        	MaskAttributes = true,
        	BlockStateChange = true,
        	KillInfoMarkers = true,
        	StopReactionAnims = true,
        	AntiKnockback = true,
        	RestoreSpeed = true,
        	KeepRigRigid = true,
        	HitWindow = 1.25,
        	KbThreshold = 22,
        }

        -- Only hard CC opens the anti-knockback window. NoSprint/NoJump are
        -- also used by legitimate moves, so they never classify a hit.
        local HARM = { Ragdoll = true, Stun = true, Knockback = true, Hold = true, NoJump = true, NoSprint = true }
        local HARD_ATTR = { Ragdoll = true, Stun = true, Knockback = true, Hold = true }
        local INFO_ALWAYS = { Stun = true, Hold = true }
        local MOVE_SOFT = { NoJump = true, NoSprint = true }
        local MASK_FIND = { Stun = true, Hold = true, NoJump = true, NoSprint = true }
        local BLOCKED = {
        	[Enum.HumanoidStateType.Physics] = true,
        	[Enum.HumanoidStateType.Ragdoll] = true,
        	[Enum.HumanoidStateType.FallingDown] = true,
        	[Enum.HumanoidStateType.PlatformStanding] = true,
        }
        local MOVER = {
        	BodyVelocity = true, LinearVelocity = true, BodyThrust = true,
        	VectorForce = true, BodyAngularVelocity = true, AngularVelocity = true,
        	AlignPosition = true,
        }

        local S = { conns = {}, charConns = {}, motors = {}, constraints = {}, window = 0, lastReason = "none", snap = {}, wasActive = false }
        local ST = {
        	states = 0, anims = 0, infoKilled = 0, rigFixed = 0, constraintsOff = 0,
        	kb = 0, speed = 0, movers = 0, attrs = 0, blockedCalls = 0,
        }
        M._state, M.Stats = S, ST

        local ALWAYS, WINDOWED = {}, {}
        local function collectIds()
        	ALWAYS, WINDOWED = {}, {}
        	local root = RepS:FindFirstChild("Animations")
        	if not root then return end
        	local misc = root:FindFirstChild("Misc")
        	if misc then
        		for _, sub in ipairs({ "Hits", "Ragdoll" }) do
        			local f = misc:FindFirstChild(sub)
        			if f then
        				for _, a in ipairs(f:GetDescendants()) do
        					if a:IsA("Animation") then ALWAYS[a.AnimationId] = true end
        				end
        			end
        		end
        		for _, a in ipairs(misc:GetChildren()) do
        			if a:IsA("Animation") and string.find(a.Name, "Knockback") then ALWAYS[a.AnimationId] = true end
        		end
        	end
        	for _, a in ipairs(root:GetDescendants()) do
        		if a:IsA("Animation") and not ALWAYS[a.AnimationId] then
        			local n = a.Name
        			if string.find(n, "Stun") or string.find(n, "Ragdoll") or string.find(n, "Wakeup")
        				or string.find(n, "Knock") or string.match(n, "Hit$") then
        				WINDOWED[a.AnimationId] = true
        			end
        		end
        	end
        end

        local function mark(reason)
        	S.window = os.clock() + M.Config.HitWindow
        	S.lastReason = reason
        end

        local function realAttr(inst, key)
        	if not inst then return nil end
        	local previousBypass = M._bypass
        	M._bypass = true
        	local ok, v = pcall(function() return inst:GetAttribute(key) end)
        	M._bypass = previousBypass
        	if ok then return v end
        	return nil
        end

        local function ownMoveActive()
        	local info = S.info
        	if not info or not info.Parent then return false end
        	local previousBypass = M._bypass
        	M._bypass = true
        	local ok, marker = pcall(function() return info:FindFirstChild("InSkill") end)
        	M._bypass = previousBypass
        	return ok and marker ~= nil
        end
        M.IsOwnMoveActive = ownMoveActive

        local function hardRagdollActive()
        	local value = realAttr(S.char, "Ragdoll")
        	return value == true or (type(value) == "number" and value > 0)
        end
        M.HasHardRagdoll = hardRagdollActive

        local function isActive()
        	if os.clock() < S.window then return true end
        	local r = realAttr(S.char, "Ragdoll")
        	if type(r) == "number" and r > 0 then return true end
        	return false
        end
        M.IsActive = isActive

        local function stopTrack(track)
        	local a = track.Animation
        	if not a or not a.AnimationId then return end
        	local id = a.AnimationId
        	if ALWAYS[id] or (WINDOWED[id] and isActive()) then
        		mark("reaction-animation")
        		pcall(function() track:Stop(0) end)
        		ST.anims += 1
        		task.defer(function()
        			if track.IsPlaying then pcall(function() track:Stop(0) end) end
        		end)
        	end
        end

        -- THE M1 / BLOCK / DASH UNLOCK
        local function sweepInfo(info, active)
        	if not info or not M.Config.KillInfoMarkers then return end
        	for _, c in ipairs(info:GetChildren()) do
        		-- InSkill and soft movement markers belong to native abilities.
        		if INFO_ALWAYS[c.Name] then
        			pcall(function() c:Destroy() end)
        			ST.infoKilled += 1
        			mark("info:" .. c.Name)
        		end
        	end
        end

        local function listMovers(char)
        	local out = {}
        	for _, d in ipairs(char:GetDescendants()) do
        		if MOVER[d.ClassName] then table.insert(out, d) end
        	end
        	return out
        end

        local function neutralize(d)
        	pcall(function()
        		if d:IsA("BodyVelocity") then
        			d.Velocity = Vector3.new(0, 0, 0)
        			d.MaxForce = Vector3.new(0, 0, 0)
        		elseif d:IsA("LinearVelocity") then
        			d.VectorVelocity = Vector3.new(0, 0, 0)
        			d.MaxForce = 0
        		elseif d:IsA("VectorForce") or d:IsA("BodyThrust") then
        			d.Force = Vector3.new(0, 0, 0)
        		elseif d:IsA("BodyAngularVelocity") then
        			d.AngularVelocity = Vector3.new(0, 0, 0)
        			d.MaxTorque = Vector3.new(0, 0, 0)
        		elseif d:IsA("AngularVelocity") then
        			d.AngularVelocity = Vector3.new(0, 0, 0)
        			d.MaxTorque = 0
        		elseif d:IsA("AlignPosition") then
        			d.Enabled = false
        		end
        	end)
        	pcall(function() d:Destroy() end)
        end

        local function unbind()
        	for _, c in ipairs(S.charConns) do pcall(function() c:Disconnect() end) end
        	S.charConns = {}
        end

        local function bind(char)
        	unbind()
        	if not char then return end
        	local hum = char:FindFirstChildOfClass("Humanoid")
        	if not hum then return end
        	S.char, S.hum = char, hum
        	S.root = char:FindFirstChild("HumanoidRootPart")
        	S.anim = hum:FindFirstChildOfClass("Animator")
        	S.info = char:FindFirstChild("Info")

        	S.motors, S.constraints = {}, {}
        	for _, d in ipairs(char:GetDescendants()) do
        		if d:IsA("Motor6D") then
        			table.insert(S.motors, d)
        		elseif d:IsA("BallSocketConstraint") then
        			table.insert(S.constraints, d)
        		end
        	end

        	S.baseSpeed = (hum.WalkSpeed > 0.01) and hum.WalkSpeed or 18
        	S.baseJump = (hum.JumpPower > 0.01) and hum.JumpPower or 50
        	S.baseJumpHeight = (hum.JumpHeight > 0.01) and hum.JumpHeight or 7.2

        	table.insert(S.charConns, hum.StateChanged:Connect(function(_, new)
        		if M.Running and BLOCKED[new] and (not ownMoveActive() or hardRagdollActive()) then
        			ST.states += 1
        			mark("state:" .. tostring(new.Name))
        			M._bypass = true
        			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        			M._bypass = false
        		end
        	end))

        	for key in pairs(HARM) do
        		table.insert(S.charConns, char:GetAttributeChangedSignal(key):Connect(function()
        			if not M.Running then return end
        			local v = realAttr(char, key)
        			if (type(v) == "number" and v > 0) or v == true then
        				ST.attrs += 1
        				if HARD_ATTR[key] then mark("attr:" .. key) end
        			end
        		end))
        	end

        	if S.info then
        		table.insert(S.charConns, S.info.ChildAdded:Connect(function(c)
        			if not M.Running then return end
        			if INFO_ALWAYS[c.Name] then
        				pcall(function() c:Destroy() end)
        				ST.infoKilled += 1
        				mark("info:" .. c.Name)
        			end
        		end))
        		sweepInfo(S.info, false)
        	end

        	table.insert(S.charConns, char.DescendantAdded:Connect(function(d)
        		if not M.Running then return end
        		if d:IsA("Motor6D") then
        			table.insert(S.motors, d)
        		elseif d:IsA("BallSocketConstraint") then
        			table.insert(S.constraints, d)
        		end
        	end))

        	if S.anim then
        		table.insert(S.charConns, S.anim.AnimationPlayed:Connect(function(track)
        			if M.Running and M.Config.StopReactionAnims then stopTrack(track) end
        		end))
        	end
        end

        local function step()
        	if not M.Running then return end
        	local hum, char, root = S.hum, S.char, S.root
        	if not (hum and hum.Parent and char and char.Parent) then return end

        	local ownMove = ownMoveActive()
        	local hardRagdoll = hardRagdollActive()
        	M._bypass = true
        	local st = hum:GetState()
        	if BLOCKED[st] and (not ownMove or hardRagdoll) then
        		ST.states += 1
        		mark("poll:" .. tostring(st.Name))
        		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        	end
        	M._bypass = false

        	local active = isActive()

        	sweepInfo(S.info, active)

        	-- Legitimate abilities may temporarily own joints and movement states.
        	if M.Config.KeepRigRigid and active and (not ownMove or hardRagdoll) then
        		for _, j in ipairs(S.motors) do
        			if j.Parent and not j.Enabled then
        				j.Enabled = true
        				ST.rigFixed += 1
        				mark("joint")
        			end
        		end
        	end

        	if active and not S.wasActive then
        		S.snap = {}
        		for _, d in ipairs(listMovers(char)) do S.snap[d] = true end
        	end
        	S.wasActive = active

        	if not active then
        		-- Never learn a temporary skill boost as normal recovery speed.
        		if not ownMove then
        			if hum.WalkSpeed > 0.01 then S.baseSpeed = hum.WalkSpeed end
        			if hum.JumpPower > 0.01 then S.baseJump = hum.JumpPower end
        			if hum.JumpHeight > 0.01 then S.baseJumpHeight = hum.JumpHeight end
        		end
        		return
        	end

        	-- Preserve move-owned speed, movers and states unless real ragdoll is active.
        	if ownMove and not hardRagdoll then return end

        	for _, c in ipairs(S.constraints) do
        		if c.Parent and c.Enabled then
        			c.Enabled = false
        			ST.constraintsOff += 1
        		end
        	end

        	if hum.PlatformStand then hum.PlatformStand = false end
        	if hum.Sit then hum.Sit = false end

        	if M.Config.RestoreSpeed then
        		if hum.WalkSpeed <= 0.01 then
        			hum.WalkSpeed = S.baseSpeed
        			ST.speed += 1
        		end
        		if hum.UseJumpPower then
        			if hum.JumpPower <= 0.01 then hum.JumpPower = S.baseJump end
        		elseif hum.JumpHeight <= 0.01 then
        			hum.JumpHeight = S.baseJumpHeight
        		end
        		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
        	end

        	if M.Config.AntiKnockback and root and root.Parent then
        		for _, d in ipairs(listMovers(char)) do
        			if not S.snap[d] then
        				neutralize(d)
        				ST.movers += 1
        			end
        		end
        		local v = root.AssemblyLinearVelocity
        		-- Jump-safe: only horizontal speed is classified as knockback.
        		-- Preserve Y exactly so normal PC/mobile jumps are never cancelled.
        		local horizontal = Vector3.new(v.X, 0, v.Z)
        		if horizontal.Magnitude > M.Config.KbThreshold then
        			root.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        			ST.kb += 1
        		end
        		local av = root.AssemblyAngularVelocity
        		if av.Magnitude > 4 then root.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
        	end
        end

        -- Remove a prior v2.2.1 hook on same-client reload so its old closure
        -- cannot continue applying the movement-breaking rules.
        local legacyHS = ENV.NH_AntiCC_HookState_v221Hub
        if legacyHS and type(legacyHS.old) == "function" then
        	pcall(function() hookmetamethod(game, "__namecall", legacyHS.old) end)
        end
        ENV.NH_AntiCC_HookState_v221Hub = nil

        local HS = ENV.NH_AntiCC_HookState_v230Hub
        if not HS then
        	HS = {}
        	ENV.NH_AntiCC_HookState_v230Hub = HS
        	HS.old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        		local m = ENV.NH_ANTI_CC
        		if m and m.Running and not m._bypass and not checkcaller() then
        			local method = getnamecallmethod()
        			local s = m._state
        			if method == "GetAttribute" and self == s.char then
        				local key = ...
        				if m.Config.MaskAttributes and HARM[key]
        					and not (MOVE_SOFT[key] and m.IsOwnMoveActive()) then
        					m.Stats.blockedCalls += 1
        					return 0
        				end
        			elseif method == "FindFirstChild" and (self == s.char or self == s.info) then
        				local key = ...
        				if m.Config.KillInfoMarkers and MASK_FIND[key]
        					and not (MOVE_SOFT[key] and m.IsOwnMoveActive()) then
        					m.Stats.blockedCalls += 1
        					return nil
        				end
        			elseif method == "ChangeState" and self == s.hum then
        				local target = ...
        				if m.Config.BlockStateChange and BLOCKED[target]
        					and (not m.IsOwnMoveActive() or m.HasHardRagdoll()) then
        					m.Stats.blockedCalls += 1
        					return
        				end
        			elseif method == "SetStateEnabled" and self == s.hum then
        				local target, enabled = ...
        				if BLOCKED[target] and enabled
        					and (not m.IsOwnMoveActive() or m.HasHardRagdoll()) then
        					m.Stats.blockedCalls += 1
        					return
        				end
        			end
        		end
        		return HS.old(self, ...)
        	end))
        end

        function M.Start()
        	if M.Running then return true end
        	collectIds()
        	M.Running = true
        	bind(LP.Character)
        	S.conns.step = RS.PreSimulation:Connect(step)
        	S.conns.charAdded = LP.CharacterAdded:Connect(function(c)
        		task.wait(0.35)
        		bind(c)
        	end)
        	return true
        end

        function M.Stop()
        	M.Running = false
        	for _, c in pairs(S.conns) do pcall(function() c:Disconnect() end) end
        	S.conns = {}
        	unbind()
        	if S.hum and S.hum.Parent then
        		M._bypass = true
        		for st in pairs(BLOCKED) do pcall(function() S.hum:SetStateEnabled(st, true) end) end
        		M._bypass = false
        	end
        	for _, c in ipairs(S.constraints) do
        		if c.Parent and not c.Enabled then pcall(function() c.Enabled = true end) end
        	end
        	return true
        end

        M.Destroy = M.Stop
        M.start, M.stop = M.Start, M.Stop
        function M.toggle()
        	if M.Running then return M.Stop() end
        	return M.Start()
        end

        function M.Status()
        	M._bypass = true
        	local hum = S.hum
        	local infoKids = {}
        	if S.info then
        		for _, c in ipairs(S.info:GetChildren()) do table.insert(infoKids, c.Name) end
        	end
        	local res = {
        		version = M.Version,
        		running = M.Running,
        		state = hum and tostring(hum:GetState().Name) or "nil",
        		walkSpeed = hum and hum.WalkSpeed or -1,
        		ragdollAttr = realAttr(S.char, "Ragdoll"),
        		active = isActive(),
        		lastReason = S.lastReason,
        		motorCount = #S.motors,
        		constraintCount = #S.constraints,
        		infoChildren = infoKids,
        		stats = ST,
        	}
        	M._bypass = false
        	return res
        end

        ENV.NH_ANTI_CC = M
        ENV.NH_AntiCC_Test = M
        _G.NH_ANTI_CC = M
        _G.NH_AntiCC_Test = M
        print("[NH ANTI-CC] v2.3.0 move-safe backend ready (toggle is off)")
    end, function(err)
        warn("[NH HUB] Anti-CC v2.3.0 backend failed: " .. tostring(err))
    end)
end

-- [EXTRAS]
Tabs.Extras:AddButton({Title="Hitbox Extender", Callback=function()
    if St.hitboxLoaded then return end
    St.hitboxLoaded=true
    task.spawn(function() pcall(function()
        local Knit=require(ReplicatedStorage.Knit.Knit)
        local hb=Knit.GetController("HitboxController"); local old=hb.SphereHitbox
        hb.SphereHitbox=function(self,p,offset,sz)
            local mult=40; local Size=sz*2.5; local data=old(self,p,offset,Size); local res={}
            if data and #data>0 then for _,v in pairs(data) do for i=1,mult do table.insert(res,v) end end end
            return res
        end
        notify("Hitbox","Active.",3)
    end) end)
end})

-- ── Instant Respawn ─────────────────────────────────────────
Tabs.Extras:AddSection("Instant Respawn")
Tabs.Extras:AddToggle("TglInstantRespawn", {Title="Instant Respawn", Default=false, Callback=function(v)
    St.instantRespawnEnabled = v
    _G.NH_Respawn.SetAuto(v)
    if v then
        notify("Instant Respawn", _G.NH_Respawn.CanBreak and "On - fast path ready." or "On - no replicatesignal, Reset-only path (slower).", 3)
    else
        notify("Instant Respawn", "Off.", 2)
    end
end})
Tabs.Extras:AddButton({Title="Respawn Now", Callback=function()
    task.spawn(function()
        local ok, took = _G.NH_Respawn.Await(6)
        if ok then notify("Instant Respawn", string.format("Respawned in %dms.", math.floor(took * 1000 + 0.5)), 3)
        else notify("Instant Respawn", "Timed out - server did not accept the reset.", 4) end
    end)
end})

Tabs.Extras:AddSection("Protection")
Tabs.Extras:AddToggle("TglAntiAFK", {Title="Anti-AFK", Default=false, Callback=function(v) St.antiAfkEnabled = v end})
Tabs.Extras:AddToggle("TglNoStun", {
    Title="No Stun + Knockback",
    Default=false,
    Callback=function(v)
        -- One toggle for both: the Anti-CC backend already neutralises knockback
        -- (velocity zeroing + mover disabling) as part of its stun pass, so a
        -- separate No Knockback switch was redundant. This keeps the legacy
        -- KnockBackForce override too, so nothing the old toggle did is lost.
        getgenv().KnockBackForce = v and 0 or nil
        local env = getgenv and getgenv() or _G
        local antiCC = env.NH_ANTI_CC or _G.NH_ANTI_CC
        if type(antiCC) ~= "table" then
            warn("[NH HUB] Anti-CC v2.3.0 backend is unavailable.")
            notify("No Stun + Knockback", "Anti-CC backend failed to load.", 4)
            return
        end
        local ok, err = pcall(function()
            if v then antiCC.Start() else antiCC.Stop() end
        end)
        if not ok then
            warn("[NH HUB] No Stun toggle failed: " .. tostring(err))
            notify("No Stun + Knockback", "Toggle failed; check executor console.", 4)
        end
    end
})
Tabs.Extras:AddToggle("TglInvisNoclip", {Title="Invisibility", Default=false, Callback=function(v) St.invisActive = v if v then setupInvisForChar(LocalPlayer.Character) startNoclip() else cleanupInvis(LocalPlayer.Character) if Cn.noclipConn and not (Fluent.Options.TglNoclip and Fluent.Options.TglNoclip.Value) then Cn.noclipConn:Disconnect(); Cn.noclipConn = nil end end end})
St.ToggleKeybinds.Add(Tabs.Extras, "KbInvis", "Invisibility Keybind:",
    "invisKey", "TglInvisNoclip", "I")
Tabs.Extras:AddToggle("TglShrink", {Title="Shrink Hitbox", Default=false, Callback=function(v) if v then setupShrinkForChar(LocalPlayer.Character) end end})
Tabs.Extras:AddButton({Title="Invisible Block Script", Callback=function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/NotEnoughJack/LuaFluentDependancies/refs/heads/main/InvisibleBlock.lua"))() end) end})
-- TWO independent switches over ONE viewer, both OFF by default:
--   Cooldown Viewer      -> full card (move rows + ult bar + evade bar)
--   Evade Bar Only       -> nothing but the evade strip
-- Either switch on its own starts the viewer, and it only stops once BOTH are
-- off, so neither one depends on the other being enabled. If both happen to be
-- on, the full card wins, because it already contains the evade bar anyway.
-- Kept as a global rather than a new local: this chunk is enormous and Lua caps
-- locals per scope at 200, so there is no reason to spend one here.
St.cdViewerFull = false
St.cdViewerEvadeOnly = false
_G.NH_cdvSync = function()
    local CDV = _G.NH_CDViewer
    if not CDV then notify("Cooldown Viewer", "Module failed to load.", 3) return end
    if CDV.Config then
        CDV.Config.EvadeOnly = (St.cdViewerEvadeOnly and not St.cdViewerFull) and true or false
    end
    -- start() no-ops while already running and stop() is safe while stopped,
    -- so this is fine to call on every flip of either switch.
    if St.cdViewerFull or St.cdViewerEvadeOnly then CDV.start() else CDV.stop() end
end
Tabs.Extras:AddToggle("TglCDViewer", {Title="Cooldown Viewer", Default=false, Callback=function(v)
    St.cdViewerFull = v and true or false
    _G.NH_cdvSync()
end})
Tabs.Extras:AddToggle("TglEvadeOnly", {Title="Evade Bar Only", Default=false, Callback=function(v)
    St.cdViewerEvadeOnly = v and true or false
    _G.NH_cdvSync()
end})
Tabs.Extras:AddButton({Title="Unlock Emotes", Callback=function()
    pcall(function()
        -- Emote slot visibility, updated for the new emote GUI layout.
        -- Client-side GUI only: does NOT grant server-side ownership or save unlocks.
        --
        -- What broke: the old script waited for Emotes.Emote.Page1 / Page2 / Switch.
        -- Those no longer exist (the GUI was reworked), so WaitForChild("Page1") yielded
        -- forever and nothing ran. The emote menu is now:
        --   Emotes.Emote.EmoteMenu.Page       -> ViewportFrames 1-8 (slots 5-8 hidden by default)
        --   Emotes.Emote.EmoteMenu.Pages      -> Back / Next / page label
        --   Emotes.Emote.EmoteMenu.Switch, .TextBox, .Search
        --   Menus.Group.Inventory.Items.Emotes.Equipped -> TextButtons 1-8 + Pages
        -- Re-running replaces the previous instance.
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        local env = getgenv()
        if env.EmoteUnlockCleanup then env.EmoteUnlockCleanup() end

        local TIMEOUT = 10
        local function resolve(root, path)
            local cur = root
            for _, name in ipairs(path) do
                cur = cur:WaitForChild(name, TIMEOUT)
                if not cur then
                    warn(("[emote unlock] missing '%s' (full path: %s) - the GUI was probably changed again"):format(
                        name, table.concat(path, ".")))
                    return nil
                end
            end
            return cur
        end

        local menu = resolve(playerGui, {"Emotes", "Emote", "EmoteMenu"})
        local equipped = resolve(playerGui, {"Menus", "Group", "Inventory", "Items", "Emotes", "Equipped"})
        if not menu or not equipped then return end

        local conns = {}
        local forced = {}

        -- Force a GuiObject visible and keep it that way if the game's own code hides it again.
        local function force(gui)
            if not gui or not gui:IsA("GuiObject") or forced[gui] then return end
            forced[gui] = true
            gui.Visible = true
            table.insert(conns, gui:GetPropertyChangedSignal("Visible"):Connect(function()
                if not gui.Visible then gui.Visible = true end
            end))
        end

        -- Emote slots (ViewportFrames 1-8) inside the page frame
        local page = menu:FindFirstChild("Page")
        if page then
            for _, slot in ipairs(page:GetChildren()) do
                if slot:IsA("ViewportFrame") then force(slot) end
            end
        end

        -- Page controls / search bar / switch (hidden unless the game thinks you qualify)
        for _, name in ipairs({"Pages", "Switch", "TextBox"}) do
            force(menu:FindFirstChild(name))
        end

        -- Equipped list in the inventory menu (slots 1-8)
        for _, slot in ipairs(equipped:GetChildren()) do
            if slot:IsA("GuiButton") then force(slot) end
        end
        force(equipped)

        env.EmoteUnlockCleanup = function()
            for _, c in ipairs(conns) do c:Disconnect() end
            env.EmoteUnlockCleanup = nil
        end
    end)
end})
local eNames = {} for _, e in ipairs(EMOTE_LIST) do table.insert(eNames, e.name) end
Tabs.Extras:AddDropdown("DpEmotes", {Title="Select Emote", Values=eNames, Default=1, Callback=function(v) for i, e in ipairs(EMOTE_LIST) do if e.name == v then emoteSelectedIndex = i break end end end})
Tabs.Extras:AddButton({Title="Fire Emote", Callback=fireSelectedEmote})
Tabs.Extras:AddButton({Title="Yonk Toggle", Callback=yonkToggle})
Tabs.Extras:AddSlider("SldYonkSpd", {Title="Yonk Speed", Min=0.1, Max=2, Default=1, Rounding=2, Callback=function(v) St.yonkSpeed = v if St.yonkAnimTrack then St.yonkAnimTrack:AdjustSpeed(v) end end})

-- The Record Jumps switch lives at the BOTTOM OF THE COMBOS TAB, right under
-- the recorder's own controls, so it is one tap away while you are recording
-- instead of a whole tab away. Default is ON.

-- ============================================================
-- BISECT 01: Alt Farm removed for FPS isolation.
-- ============================================================

-- [ITEMS]
local mainItemsCache = {}
-- Item ESP: through-wall highlight + name/distance billboard (green = close, red = far)
do
    local esp = {}            -- item -> {hl=Highlight, bb=BillboardGui, lbl=TextLabel}
    local espLast = 0
    local NEAR_D, FAR_D = 40, 400
    local function distColor(d)
        local t = math.clamp((d - NEAR_D) / (FAR_D - NEAR_D), 0, 1)
        return Color3.new(t, 1 - t, 0)   -- green up close -> red far away
    end
    local function partOf(inst)
        if inst:IsA("BasePart") then return inst end
        if inst:IsA("Model") then return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart") end
        return inst:FindFirstChildWhichIsA("BasePart")
    end
    local function destroyEntry(e)
        pcall(function() if e.hl then e.hl:Destroy() end end)
        pcall(function() if e.bb then e.bb:Destroy() end end)
    end
    _G.NH_clearItemEsp = function()
        for _, e in pairs(esp) do destroyEntry(e) end
        esp = {}
    end
    local function refreshItemEsp()
        local folder = Workspace:FindFirstChild("Items")
        if not folder then return end
        local ch = LocalPlayer.Character
        local myHrp = ch and ch:FindFirstChild("HumanoidRootPart")
        for item, e in pairs(esp) do
            if not item or item.Parent ~= folder then
                destroyEntry(e)
                esp[item] = nil
            end
        end
        for _, child in ipairs(folder:GetChildren()) do
            local part = partOf(child)
            if part then
                local e = esp[child]
                if not e then
                    e = {}
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "NH_ItemESP"
                        hl.Adornee = child
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = child
                        e.hl = hl
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "NH_ItemESP"
                        bb.Adornee = part
                        bb.Size = UDim2.fromOffset(230, 44)
                        bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.MaxDistance = 2000
                        bb.Parent = part
                        local lbl = Instance.new("TextLabel")
                        lbl.BackgroundTransparency = 1
                        lbl.Size = UDim2.fromScale(1, 1)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 18
                        lbl.TextStrokeTransparency = 0.3
                        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                        lbl.Text = child.Name
                        lbl.Parent = bb
                        e.bb = bb
                        e.lbl = lbl
                    end)
                    esp[child] = e
                end
                if e.lbl and myHrp then
                    local d = math.floor((part.Position - myHrp.Position).Magnitude + 0.5)
                    local col = distColor(d)
                    e.lbl.Text = string.format("%s  [%dm]", child.Name, d)
                    e.lbl.TextColor3 = col
                    if e.hl then e.hl.FillColor = col e.hl.OutlineColor = col end
                end
            end
        end
    end
    RunService.Heartbeat:Connect(function()
        if not St.itemEspEnabled then return end
        if os.clock() - espLast < 0.15 then return end
        espLast = os.clock()
        refreshItemEsp()
    end)
end
Tabs.Items:AddToggle("TglItemESP", {Title="Item ESP", Default=false, Callback=function(v) St.itemEspEnabled = v if not v then _G.NH_clearItemEsp() end end})
Tabs.Items:AddSection("Items On Map")
local DpItems = Tabs.Items:AddDropdown("DpMainItems", {Title="Select Item", Values={"(press Refresh)"}, Default=1, Callback=function(v) end})
_G.NH_refreshItemList = function(quiet)
    local IG = _G.NH_ItemGrabber
    if not IG then
        if not quiet then notify("Items", "Item grabber module failed to load.", 3) end
        return
    end
    local names = IG.refresh()
    if #names == 0 then names = {"(none found)"} end
    DpItems:SetValues(names)
    if not quiet then notify("Items", "Found " .. IG.count() .. " items.", 2) end
end
local function nhSelectedItem()
    local IG = _G.NH_ItemGrabber
    if not IG then notify("Items", "Item grabber module failed to load.", 3) return nil end
    local sel = Fluent.Options.DpMainItems and Fluent.Options.DpMainItems.Value
    if not sel or sel == "(none found)" or sel == "(press Refresh)" then
        notify("Items", "Press Refresh Items, then pick one.", 3)
        return nil
    end
    local part = IG.partFor(sel)
    if not part then
        notify("Items", "That item is gone. Refreshing.", 3)
        _G.NH_refreshItemList(true)
        return nil
    end
    return part, sel
end
Tabs.Items:AddButton({Title="Grab Selected Item", Callback=function()
    local part, label = nhSelectedItem()
    if not part then return end
    task.spawn(function()
        local IG = _G.NH_ItemGrabber
        local ok = IG.grab(part)
        if ok then notify("Items", "Grabbed: " .. tostring(label), 2) else notify("Items", "Failed: " .. tostring(label), 3) end
        _G.NH_refreshItemList(true)
    end)
end})
Tabs.Items:AddButton({Title="Drop Item", Callback=function()
    local IG = _G.NH_ItemGrabber
    if not IG then notify("Items", "Item grabber module failed to load.", 3) return end
    if IG.drop() then notify("Items", "Dropped held item.", 2) else notify("Items", "Drop failed.", 3) end
end})
Tabs.Items:AddButton({Title="Refresh Items", Callback=function() _G.NH_refreshItemList(false) end})
Tabs.Items:AddButton({Title="Grab Nearest Item", Callback=function()
    local IG = _G.NH_ItemGrabber
    if not IG then notify("Items", "Item grabber module failed to load.", 3) return end
    task.spawn(function()
        local part = IG.nearest()
        if not part then notify("Items", "No items on the map.", 3) return end
        local name = part.Name
        local ok = IG.grab(part)
        if ok then notify("Items", "Grabbed: " .. name, 2) else notify("Items", "Failed: " .. name, 3) end
        _G.NH_refreshItemList(true)
    end)
end})
Tabs.Items:AddButton({Title="Grab All Items", Callback=function()
    local IG = _G.NH_ItemGrabber
    if not IG then notify("Items", "Item grabber module failed to load.", 3) return end
    task.spawn(function()
        notify("Items", "Grabbing every item, nearest first.", 2)
        local got, total = IG.grabAll()
        notify("Items", "Grabbed " .. tostring(got) .. "/" .. tostring(total) .. " items.", 3)
        _G.NH_refreshItemList(true)
    end)
end})
Tabs.Items:AddToggle("TglAutoGrabItems", {Title="Auto Grab Items (loop)", Default=false, Callback=function(v)
    local IG = _G.NH_ItemGrabber
    if not IG then notify("Items", "Item grabber module failed to load.", 3) return end
    IG.autoGrab = v
    notify("Items", v and "Auto grab ON - sweeping items as they spawn." or "Auto grab OFF.", 2)
end})
Tabs.Items:AddToggle("TglItemAutoList", {Title="Auto Refresh List", Default=false, Callback=function(v)
    _G.NH_itemAutoList = v
    if v and not _G.NH_itemAutoListLoop then
        _G.NH_itemAutoListLoop = true
        task.spawn(function()
            while _G.NH_itemAutoList do
                task.wait(2)
                if _G.NH_itemAutoList and _G.NH_refreshItemList then pcall(_G.NH_refreshItemList, true) end
            end
            _G.NH_itemAutoListLoop = false
        end)
    end
end})
task.spawn(function()
    task.wait(2)
    if _G.NH_refreshItemList then pcall(_G.NH_refreshItemList, true) end
end)

-- [KEYBINDS]
if not mobile then
    -- PC: real keyboard keybinds. These mirrors share their inline feature bindings.
    St.ToggleKeybinds.Add(Tabs.Keybinds, "KbInvisMaster", "Invisibility Key",
        "invisKey", "TglInvisNoclip", "I")
    St.ToggleKeybinds.Add(Tabs.Keybinds, "KbRotateLockOnMaster", "Rotate Locked-On Target Key",
        "rotateLockOnKey", "TglRotateLockOn", "T")
    St.ToggleKeybinds.Add(Tabs.Keybinds, "KbAutoBlock", "Auto Block Key",
        "autoBlockKey", "TglAutoBlockC", "K")
    -- PATCH P14: St.KeyBinds.Add applies the key on config load too (not only on pick).
    St.KeyBinds.Add(Tabs.Keybinds, "KbSweep", {Title="Sweep Key", Name="Sweep", Default="E", Apply=function(code) Keys.sweepKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbHunt", {Title="Hunt Key", Name="Hunt", Default="Y", Apply=function(code) Keys.huntKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbBF", {Title="BF Dash Key", Name="BF Dash", Default="G", Apply=function(code) Keys.bfKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbFly", {Title="Fly Key", Name="Fly", Default="X", Apply=function(code) Keys.flyKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbLock", {Title="Lock-On Key", Name="Lock-On", Default="C", Apply=function(code) Keys.lockOnKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbYonk", {Title="Yonk Key", Name="Yonk", Default="J", Apply=function(code) Keys.yonkKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbEmote", {Title="Auto Emote Key", Name="Auto Emote", Default="Z", Apply=function(code) Keys.emoteKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbHarutaBs", {Title="Haruta Backstab Key (default: 2)", Name="Haruta Backstab", Default="Two", Apply=function(code) Keys.harutaBsKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbBFChain", {Title="BF Chain Key (default: 3)", Name="BF Chain", Default="Three", Apply=function(code) Keys.bfChainKey = code end})
    St.KeyBinds.Add(Tabs.Keybinds, "KbVoid", {Title="Void Key", Name="Void / Reset", Default="V", Apply=function(code) Keys.voidKey = code end})
else
    -- MOBILE: phones can't bind keyboard keys, so instead each box below drops a draggable
    -- on-screen button for that function. Matching feature toggles now surface their
    -- buttons automatically; these switches are optional always-show pins.
    local function mbBtn(key, title, btnName)
        Tabs.Keybinds:AddToggle(key, {Title=title, Default=false, Callback=function(v) _G.NH_btnManual[btnName] = v end})
    end
    -- Visibility only: switching a row on surfaces the button; taps run the
    -- action. Switching it off hides that new button without disabling its feature.
    mbBtn("MbInvis", "Show Invisibility Button", "InvisBtn")
    mbBtn("MbRotateLockOn", "Show Rotate Locked-On Target Button", "RotateLockOnBtn")
    mbBtn("MbAutoBlock", "Show Auto Block Button", "AutoBlockBtn")
    mbBtn("MbVoid", "Show Void / Reset Button (PC: V)", "VoidBtn")
    mbBtn("MbStopSweep", "Show Stop Sweep Button (PC: H)", "StopSweepBtn")
    mbBtn("MbCRStop", "Show Combo Panic Stop Button (PC: Backspace)", "CRStopBtn")
    mbBtn("MbSweep", "Show Sweep Button", "SweepBtn")
    mbBtn("MbHunt", "Show Hunt Button", "HuntBtn")
    mbBtn("MbBackstab", "Show Backstab Button", "BsBtn")
    mbBtn("MbBFChain", "Show BF Chain Button", "BFChainBtn")
    -- Feature-backed buttons appear automatically while enabled. These switches
    -- can still keep Backstab/BF Chain visible before their feature is enabled.
    mbBtn("MbYonk", "Show Yonk Button", "YonkBtn")
    -- COMBO RECORDER. REC replaces the PC record key (F8) and AUTO COMBO replaces
    -- the play key (F9). Both are tap-on / tap-again-off, exactly like the keys.
    Tabs.Keybinds:AddToggle("MbCRRec", {
        Title = "Show Combo Record Button (PC: F8)",
        Description = "Tap to start recording a combo, tap again to stop and save it.",
        Default = false,
        Callback = function(v) _G.NH_btnManual["CRRecBtn"] = v and true or false end,
    })
    Tabs.Keybinds:AddToggle("MbCRPlay", {
        Title = "Show Auto Combo Button (PC: F9)",
        Description = "Tap to run the recorded combo on your target, tap again to cancel it mid-combo.",
        Default = false,
        Callback = function(v) _G.NH_btnManual["CRPlayBtn"] = v and true or false end,
    })
    -- These can be pinned manually, but their matching feature also surfaces them
    -- automatically so mobile never requires a second trip to this tab.
    mbBtn("MbFly", "Show Fly Button", "FlyBtn")
    mbBtn("MbBoost", "Show Fly Boost Button", "FlyBoostBtn")
    mbBtn("MbBF", "Show Black Flash Button", "BFBtn")
    mbBtn("MbLock", "Show Lock-On Button", "LockBtn")
    -- SOLO BLOCK's mobile button can be pinned manually, but enabling the feature
    -- also surfaces it automatically (same auto-visibility rule as the others).
    mbBtn("MbSoloBlock", "Show Solo Block Button", "SoloBlockBtn")
    -- Auto Backdash's mobile button control lives with the feature in Combat.
    -- Show Emote Button moved here from Settings -- uses the canonical emote overlay toggle.
    Tabs.Keybinds:AddToggle("TglMainOverlay", {Title="Show Emote Button", Default=false, Callback=function(v) if _G.ToggleMainOverlay then _G.ToggleMainOverlay(v) end end})
end

-- [SETTINGS]
Tabs.Settings:AddSection("Float Overlays & Visuals")
if mobile then
    Tabs.Settings:AddSlider("SldBtnSize", {Title="Mobile Button Size", Min=0.6, Max=1.8, Default=1, Rounding=2, Callback=function(v) if _G.NH_ApplyBtnScale then _G.NH_ApplyBtnScale(v) end end})
    Tabs.Settings:AddToggle("TglLockBtns", {Title="Lock Buttons In Place (no dragging)", Default=false, Callback=function(v) _G.NH_btnLocked = v end})
end

Tabs.Settings:AddSection("Target Offsets")
Tabs.Settings:AddDropdown("DpSweepMode", {Title="Sweep Mode", Values={"normal", "faster"}, Default="normal", Callback=function(v) Cfg.sweepMode = v end})
Tabs.Settings:AddDropdown("DpTPPriority", {Title="TP Priority", Values={"normal", "hppct"}, Default="normal", Callback=function(v) Cfg.tpPriority = v end})
Tabs.Settings:AddDropdown("DpTPMode", {Title="TP Mode", Values={"Under", "Behind"}, Default="Under", Callback=function(v) Cfg.tpMode = string.lower(v) end})
Tabs.Settings:AddDropdown("DpTPMethod", {Title="TP Method", Values={"Default", "Smart"}, Default="Default", Callback=function(v) Cfg.tpMethod = string.lower(v) end})
Tabs.Settings:AddSlider("SldOffsetX", {Title="Offset X", Min=-10, Max=10, Default=0, Rounding=1, Callback=function(v) Cfg.offsetX = v end})
Tabs.Settings:AddSlider("SldOffsetY", {Title="Offset Y", Min=-10, Max=10, Default=0, Rounding=1, Callback=function(v) Cfg.offsetY = v end})
Tabs.Settings:AddSlider("SldOffsetZ", {Title="Offset Z", Min=0, Max=15, Default=2, Rounding=1, Callback=function(v) Cfg.offsetZ = v end})
Tabs.Settings:AddSlider("SldFallen", {Title="Fallen Height (0=NaN)", Min=-500, Max=500, Default=-1000, Rounding=0, Callback=function(v) Cfg.fallenHeight = (v==0) and (0/0) or v end})

-- ============================================================
-- NH COMBO RECORDER   (integrated module)
--
-- Record a combo once, name it, replay it on a keybind.
--
-- Targeting is deliberately NOT a setting, because it is already
-- decided by something you can see:
--   * locked on with the hub Lock-On  -> that person and only ever that
--     person. If they die or you lose them mid combo, playback STOPS
--     rather than turning on whoever is standing next to you.
--   * not locked on                   -> the closest enemy.
--
-- Facing safety is leased, never held: AutoRotate is only off while a
-- combo is actively steering, it is handed back the frame the combo
-- ends, and a guard ticks whether or not anything is playing, so
-- "stuck staring at the enemy" is not reachable.
-- ============================================================
do
local okCR, errCR = pcall(function()

local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HubSt             = St     -- hub state table, for the Lock-On bridge

-- a re-execute of the hub must not leave two namecall hooks stacked
if _G.NH_ComboRec and _G.NH_ComboRec._destroy then pcall(_G.NH_ComboRec._destroy) end

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local RCfg = {
    SampleHz      = 30,
    Speed         = 1.00,
    DriveMove     = true,
    DriveJump     = true,
    -- Extras > "Record Jumps". ON: your jumps are written to the tape and the
    -- replay really jumps. OFF: jumps are ignored on both sides (old behaviour).
    RecordJumps   = true,
    AirLift       = true,   -- a press recorded airborne hops first if we are grounded
    AirLiftWait   = 0.30,   -- max seconds to wait for take-off before firing anyway

    -- DASH AIMING. A recorded dash direction is meaningless on its own: it was
    -- pointed at wherever the enemy stood at the time, and they have moved
    -- since. These re-point every dash at whoever you are actually fighting.
    DashAim       = true,   -- always dash AT the current target
    DashBehind    = true,   -- a dash you curved round them replays as a back-dash
    DashTurnDeg   = 35,     -- orbit past this many degrees counts as "you turned"
    DashBackAngle = 110,    -- ending past this far round them counts as behind
    DashSettle    = 0.35,   -- record: wait this long before measuring where a dash ended
    DashWait      = 0.50,   -- playback: max wait for a curved dash to arrive
    DashSide      = true,   -- replay side/back dashes at the angle you recorded
    DashFaceMax   = 135,    -- deg. never leave you facing further than this off them

    -- REACH / ABORT. This is what stops a tape miming M1s at open air.
    -- M1 GATE: a real M1 in this game connects inside ~6 studs, so the replay may
    -- only throw one when we are 5 studs or closer -- otherwise it runs the gap
    -- instead of swinging at nothing. This is the "punching air" fix: MeleeRange
    -- used to be 18, so an M1 fired from across the street and whiffed.
    MeleeRange    = 5,      -- M1-class press must be THIS close to the target to fire
    MeleeAirSlack = 2,      -- slight extra when the press was recorded airborne
    RunToEnemy    = true,   -- close the gap instead of skipping the press
    AbortIfFar    = true,   -- nobody reachable at all -> end the run, do not fake it
    AbortRange    = 90,     -- past this the combo is abandoned outright

    MaxSeconds    = 120,   -- hard safety ceiling only, not a normal stop
    TargetRange   = 150,
    LockAngle     = 35,
    Slots         = 6,
    Folder        = "NH_ComboRec",

    -- TAIL TRIM ONLY -- there is no auto-stop timer any more. You press Start,
    -- you press Stop, and NOTHING closes the tape behind your back. The dead
    -- time between your last move and your Stop press is trimmed off when the
    -- tape is saved, so playback still ends on your last move and never stares
    -- or walks around afterwards. That was the only job auto-stop was doing,
    -- and the trim does it without cutting your combo short.
    AutoStop      = false,
    AutoStopIdle  = 1.60,
    TrimTail      = true,
    TailPad       = 0.18,
    ReleaseTail   = true,

    -- range engine
    RangeGuard    = true,
    PlaybackRange = 14,
    RangeSlack    = 6,
    MaxRange      = 70,
    RangeWait     = 4.0,
    AirSlack      = 10,
    Lunge         = true,
    LungeGap      = 20,

    EngageRange   = 60,
    RunTimeout    = 20.0,
    PauseOnStun   = true,

    -- your own camera turn always wins over playback steering
    PlayerTurn    = true,
    OverrideRate  = 55,
    OverrideHold  = 0.40,
    FaceDeadzone  = 0.75,  -- deg. below this we do not rewrite facing at all

    IgnoreService = {
        AntiCheatService = true, AnalyticsService = true, ChatService = true,
        DataService = true, LogService = true,
    },
    IgnoreEvent = {
        Heartbeat = true, Ping = true, Report = true,
        Position = true, Analytics = true, Log = true,
    },
}

-- F8 / F9 / Backspace are free in the hub (E Y H G X J C V Z 2 3 are taken)
local RKeys = {
    record = Enum.KeyCode.F8,
    play   = Enum.KeyCode.F9,
    stop   = Enum.KeyCode.Backspace,
}

local RSt = {
    alive = true, recording = false, playing = false,
    gen = 0, beat = 0, recStart = 0,
    jumpConns = {}, pendingJump = false, lastJumpAt = 0, lastDriveJump = 0,
    driveOn = false, driveVec = nil,
    -- SPRINT CAMERA-LOCK: while closing a gap this holds the model the camera should
    -- face. The game only sustains the Sprint attribute when our movement aligns with
    -- the camera's forward axis, so running at an enemy the camera isn't pointed at
    -- makes the game drop Sprint and we crawl. Facing the camera at the target during
    -- the gap-close is what turns the walk into a real sprint.
    camFace = nil,
    slot = 1, slots = {},
    status = "idle", target = nil,
    eventCount = 0, sampleCount = 0,
    stepIndex = 0, stepCount = 0,
    fired = 0, skipped = 0,
    lastLine = "", lastError = nil,
}

local K, E, R, UI = {}, {}, {}, {}

----------------------------------------------------------------------
-- CORE HELPERS
----------------------------------------------------------------------
local conns = {}
function K.track(conn) conns[#conns + 1] = conn; return conn end
function K.disconnectAll()
    for _, conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end
    table.clear(conns)
end

function K.push(fmt, ...)
    local ok, line = pcall(string.format, fmt, ...)
    if not ok then line = tostring(fmt) end
    RSt.lastLine = line
    print("[Combo Recorder] " .. line)
    return line
end
function K.safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        RSt.lastError = tostring(err)
        K.push("error: %s", tostring(err))
    end
    return ok, err
end

-- Generation ownership. Bumping this retires every thread instantly, which
-- a boolean cannot arbitrate.
function K.nextGen() RSt.gen = RSt.gen + 1; return RSt.gen end
function K.owns(gen) return RSt.alive and RSt.gen == gen end
function K.busy() return RSt.recording or RSt.playing end
function K.beat() RSt.beat = os.clock() end

function K.round(n, places)
    local mult = 10 ^ (places or 4)
    if type(n) ~= "number" or n ~= n or n == math.huge or n == -math.huge then return 0 end
    return math.floor(n * mult + 0.5) / mult
end
function K.myChar()
    local c = LocalPlayer.Character
    if c and c.Parent then return c end
    return nil
end
function K.myHRP()
    local c = K.myChar()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
function K.myHum()
    local c = K.myChar()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
function K.yawOf(dir) return math.deg(math.atan2(dir.X, dir.Z)) end
function K.dirOfYaw(deg)
    local r = math.rad(deg)
    return Vector3.new(math.sin(r), 0, math.cos(r))
end
function K.flat(v)
    local f = Vector3.new(v.X, 0, v.Z)
    if f.Magnitude < 0.001 then return nil end
    return f.Unit
end
function K.angDelta(a, b) return (a - b + 180) % 360 - 180 end
function K.displayName(model)
    if not model then return "nobody" end
    local player = Players:GetPlayerFromCharacter(model)
    if player then return player.DisplayName or player.Name end
    return model.Name
end

-- Info children are ValueObjects: absent means allowed, and present-but-false
-- ALSO means allowed. Never cache them.
function K.infoOf(c) return c and c:FindFirstChild("Info") or nil end
function K.charAttr(c, name)
    if not c then return nil end
    local ok, v = pcall(function() return c:GetAttribute(name) end)
    return ok and v or nil
end
function K.flagOn(c, name)
    local info = K.infoOf(c)
    if not info then return false end
    local v = info:FindFirstChild(name)
    if not v then return false end
    local ok, val = pcall(function() return v.Value end)
    if ok and val == false then return false end
    return true
end
function K.myFlag(name) return K.flagOn(K.myChar(), name) end
function K.airborne()
    local hum = K.myHum()
    return hum ~= nil and hum.FloorMaterial == Enum.Material.Air
end
-- FATAL ends a run. Death only.
function K.fatalState()
    local c = K.myChar()
    if not c then return "no character" end
    local hum = K.myHum()
    if not hum or hum.Health <= 0 then return "dead" end
    if K.charAttr(c, "Dead") then return "dead" end
    return nil
end

----------------------------------------------------------------------
-- TARGETING  +  HUB LOCK-ON BRIDGE
----------------------------------------------------------------------
function K.enemyFolder() return Workspace:FindFirstChild("Characters") end
function K.isEnemy(model)
    local me = K.myChar()
    if not me or not model or model == me then return false end
    if typeof(model) ~= "Instance" or not model:IsA("Model") then return false end
    if model.Name == "HarutaSwordNPC" then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end
    if K.charAttr(model, "Dead") then return false end
    if K.charAttr(model, "HitboxNPC") then
        local owner = model:FindFirstChild("Owner")
        if owner and owner.Value == me then return false end
    end
    return true
end
function K.candidates()
    local out = {}
    local folder = K.enemyFolder()
    if not folder then return out end
    for _, model in ipairs(folder:GetChildren()) do
        if K.isEnemy(model) then table.insert(out, model) end
    end
    return out
end
function K.targetPart(model)
    return model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart) or nil
end
function K.targetValid(model)
    return model ~= nil and model.Parent ~= nil and K.isEnemy(model)
end
-- flat distance: vertical separation during a leap must not read as range
function K.distanceTo(model)
    local hrp, other = K.myHRP(), K.targetPart(model)
    if not hrp or not other then return math.huge end
    return (Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
        - Vector3.new(other.Position.X, 0, other.Position.Z)).Magnitude
end
function K.nearestEnemy(maxDist)
    local best, bestD = nil, maxDist or RCfg.TargetRange
    for _, model in ipairs(K.candidates()) do
        local d = K.distanceTo(model)
        if d < bestD then best, bestD = model, d end
    end
    return best
end
-- the enemy you were actually pointed at. Recording only: this is what lets a
-- tape store enemy-relative yaw and therefore follow a DIFFERENT enemy later.
function K.lookedAtEnemy()
    local hrp = K.myHRP()
    if not hrp then return nil end
    local look = K.flat(hrp.CFrame.LookVector)
    if not look then return nil end
    local myYaw = K.yawOf(look)
    local best, bestScore = nil, nil
    for _, model in ipairs(K.candidates()) do
        local other = K.targetPart(model)
        if other then
            local delta = other.Position - hrp.Position
            local d, dir = delta.Magnitude, K.flat(delta)
            if dir and d <= RCfg.TargetRange then
                local off = math.abs(K.angDelta(myYaw, K.yawOf(dir)))
                local score = off + d * 0.25
                if off <= RCfg.LockAngle and (not bestScore or score < bestScore) then
                    best, bestScore = model, score
                end
            end
        end
    end
    return best
end

-- THE LOCK-ON BRIDGE.
-- Reads the hub's own lock-on state. No option, no toggle, no dropdown: if
-- the hub says you are locked onto someone, that IS the instruction.
function K.hubLocked()
    if type(HubSt)=="table"and HubSt.lockOnEnabled then
        local entry=HubSt.lockOnTarget
        local char=type(entry)=="table"and entry.Char or nil
        if char and char.Parent and K.isEnemy(char)then return char end
    end
    -- On an Anti-Team alt, use the target already being pursued by the link.
    local stand=rawget(_G,"StandState")
    local linked=type(stand)=="table"and stand.IsAbusing
        and(stand.ActivePursuitModel or stand.UtilTarget)or nil
    if linked and K.targetValid(linked)then return linked end
    return nil
end

-- Playback target: locked person, else closest person. Nothing else.
function K.acquireTarget()
    local locked = K.hubLocked()
    if locked then return locked end
    return K.nearestEnemy(RCfg.EngageRange)
end

-- Re-acquire DURING a combo. ctx.pinned is set when the run began locked on;
-- a pinned run will never silently walk over to somebody else.
function K.acquireFor(ctx)
    if ctx and ctx.pinned then
        if K.targetValid(ctx.target) then return ctx.target end
        local locked = K.hubLocked()
        if locked then return locked end
        return nil
    end
    return K.acquireTarget()
end

-- what counts as a press that must actually reach the enemy
function K.isAttackEvent(event)
    if not event then return false end
    if event.svc == "BlockService" then return false end
    if event.svc == "MovementService" then return false end
    if event.ev == "Deactivated" or event.ev == "RightDeactivated" then return false end
    return event.ev == "Activated" or event.ev == "RightActivated"
        or event.ev == "LeftActivated" or event.ev == "Special"
        or event.ev == "Awaken" or event.ev == "Ultimate" or event.ev == "M1"
end

-- A dash is NOT an attack -- it must never be range-gated like a punch -- but
-- it does have to be re-aimed, so it gets its own test.
function K.isDashEvent(event)
    if not event then return false end
    if string.find(tostring(event.ev or ""), "Dash", 1, true) then return true end
    return event.svc == "MovementService"
end

-- M1-class presses only. These are the ones that genuinely have to be at
-- punching distance; specials and ultimates keep their recorded reach.
function K.isMeleeEvent(event)
    if not event then return false end
    if not K.isAttackEvent(event) then return false end
    local ev = event.ev
    return ev == "Activated" or ev == "M1" or ev == "LeftActivated"
end

-- Where I am standing AROUND a target, measured against the way THEY are
-- facing: 0 is dead in front of them, +/-180 is dead behind. This is the only
-- frame in which "I dashed round to their back" still means the same thing on
-- playback, when both of us are somewhere else entirely.
function K.orbitAngle(model)
    local hrp, other = K.myHRP(), K.targetPart(model)
    if not hrp or not other then return nil end
    local toMe = K.flat(hrp.Position - other.Position)
    local look = K.flat(other.CFrame.LookVector)
    if not toMe or not look then return nil end
    return K.angDelta(K.yawOf(toMe), K.yawOf(look))
end

----------------------------------------------------------------------
-- FACING CONTROLLER
--   WINDOWED : AutoRotate is off only while a window is live
--   TOKENED  : a new window retires the previous one on the spot
--   YIELDING : your own camera turn wins, mid combo
--   GUARDED  : the net runs whether or not anything is playing
----------------------------------------------------------------------
local lease  = { open = false, owner = nil, saved = nil }
local facing = { token = 0, activeUntil = 0, overrideUntil = 0, camYaw = nil, camAt = 0, autoOff = false }

local function camYaw()
    local cam = Workspace.CurrentCamera
    if not cam then return nil end
    local dir = K.flat(cam.CFrame.LookVector)
    if not dir then return nil end
    return K.yawOf(dir)
end

-- the single place AutoRotate is ever touched
local function setAutoOff(off)
    local hum = K.myHum()
    if not hum then return end
    if off then
        if facing.autoOff then return end
        facing.autoOff = true
        pcall(function() hum.AutoRotate = false end)
    else
        if not facing.autoOff then return end
        facing.autoOff = false
        local want = lease.saved
        if want == nil then want = true end
        pcall(function() hum.AutoRotate = want end)
    end
end

-- Did YOU just turn the camera? Measured as a RATE, so a deliberate flick
-- counts and idle jitter does not. Works for mouse, gamepad and mobile drag
-- alike because it needs no input hooks.
function E.playerTurning()
    local now = os.clock()
    if now < facing.overrideUntil then return true end
    if not RCfg.PlayerTurn then return false end
    local yaw = camYaw()
    if not yaw then return false end
    local prev, prevAt = facing.camYaw, facing.camAt
    facing.camYaw, facing.camAt = yaw, now
    if prev == nil then return false end
    local dt = now - prevAt
    if dt < 0.004 or dt > 0.5 then return false end
    if math.abs(K.angDelta(yaw, prev)) / dt >= (tonumber(RCfg.OverrideRate) or 55) then
        facing.overrideUntil = now + (tonumber(RCfg.OverrideHold) or 0.4)
        setAutoOff(false)   -- give it back this frame, not next tick
        return true
    end
    return false
end

function E.facingOpen(gen)
    local hum = K.myHum()
    if not hum then return false end
    if not lease.open then
        lease.saved = hum.AutoRotate
        lease.open = true
    end
    lease.owner = gen
    facing.token = facing.token + 1
    facing.activeUntil, facing.overrideUntil = 0, 0
    facing.camYaw, facing.camAt = camYaw(), os.clock()
    return true
end

function E.facingClose(gen)
    if not lease.open then return end
    if gen ~= nil and lease.owner ~= nil and lease.owner ~= gen then return end
    facing.token = facing.token + 1
    facing.activeUntil, facing.overrideUntil = 0, 0
    setAutoOff(false)
    local want = lease.saved
    if want == nil then want = true end
    lease.open, lease.owner, lease.saved = false, nil, nil
    local hum = K.myHum()
    if hum then pcall(function() hum.AutoRotate = want end) end
end

-- unconditional teardown, used on respawn and panic
function E.facingRelease()
    facing.token = facing.token + 1
    facing.activeUntil, facing.overrideUntil, facing.autoOff = 0, 0, false
    lease.open, lease.owner, lease.saved = false, nil, nil
    local hum = K.myHum()
    if hum then pcall(function() hum.AutoRotate = true end) end
end

-- Safety net, ticked whether or not something is playing:
--   playing, no live window -> hand turning back NOW, mid combo
--   idle, lease open        -> release it
--   idle, AutoRotate off    -> force it true
function E.facingGuard()
    if K.busy() then
        if lease.open and os.clock() >= facing.activeUntil then setAutoOff(false) end
        return
    end
    if lease.open then
        E.facingClose(lease.owner)
        K.push("facing lease was left open, released")
        return
    end
    -- only correct what WE could have caused: never fight shiftlock or
    -- another hub feature that is holding AutoRotate off on purpose
    if facing.autoOff then
        local hum = K.myHum()
        facing.autoOff = false
        if hum and hum.AutoRotate == false then
            pcall(function() hum.AutoRotate = true end)
            K.push("restored camera-follow turning")
        end
    end
end

function E.facingTick(hold)
    facing.activeUntil = math.max(facing.activeUntil, os.clock() + (hold or 0.12))
    setAutoOff(true)
end
function E.facingIdle()
    facing.activeUntil = 0
    setAutoOff(false)
end

-- Rotation only: position is copied straight through, so there is no
-- positional delta and therefore no rubber-banding.
function E.applyYaw(deg, force)
    if not lease.open then return false end
    if not force and os.clock() < facing.overrideUntil then return false end
    local hrp = K.myHRP()
    if not hrp then return false end
    local p = hrp.Position
    return (pcall(function() hrp.CFrame = CFrame.new(p, p + K.dirOfYaw(deg)) end))
end

function E.yawToward(model)
    local hrp, other = K.myHRP(), K.targetPart(model)
    if not hrp or not other then return nil end
    local dir = K.flat(other.Position - hrp.Position)
    if not dir then return nil end
    return K.yawOf(dir)
end

function E.faceTarget(model, offsetDeg)
    local yaw = E.yawToward(model)
    if not yaw then return false end
    if lease.open then E.facingTick(0.10) end
    return E.applyYaw(yaw + (offsetDeg or 0))
end
-- Same contract as E.faceTarget, but aims at a bearing instead of a model.
-- Side dashes need this: the facing that makes a recorded Left/Right press
-- travel the right way is usually NOT straight at the enemy.
function E.faceYaw(deg)
    if not deg then return false end
    if lease.open then E.facingTick(0.10) end
    return E.applyYaw(deg)
end

function E.stopMoving()
    local hum, c = K.myHum(), K.myChar()
    RSt.driveVec = nil
    RSt.camFace = nil
    if hum then pcall(function() hum:Move(Vector3.zero, false) end) end
    if c then pcall(function() c:SetAttribute("Sprint", false) end) end
end

----------------------------------------------------------------------
-- MOVEMENT DRIVE   (this is what makes playback behave on a phone)
--
-- Roblox's own PlayerModule re-writes Humanoid:Move() on EVERY RenderStepped
-- frame from whatever the controls currently say -- the thumbstick on mobile,
-- WASD on PC -- and it writes a ZERO vector when you are not touching them.
-- A Move() issued from a Heartbeat loop therefore gets stomped flat again
-- before the next physics step. On a touch device the stick is always
-- publishing, which is exactly why following and movement were unreliable
-- there while they mostly survived on PC.
--
-- Rather than DISABLING the controls -- which hides the mobile thumbstick and
-- jump button, and would fight the hub's own touch-restore code further up
-- this file -- we simply write LAST. This binds to RenderStep at a priority
-- after the control module, so the recorder's vector is the one physics
-- actually reads. The on-screen controls stay put the whole time and are
-- yours again the moment the tape ends.
----------------------------------------------------------------------
local DRIVE_BIND = "NH_ComboRecDrive"

-- publish a world-space direction; nil or zero means "stand still"
function E.drive(worldDir)
    RSt.driveVec = worldDir
    local hum = K.myHum()
    if hum then pcall(function() hum:Move(worldDir or Vector3.zero, false) end) end
end

function E.disarmDrive()
    RSt.driveOn  = false
    RSt.driveVec = nil
    RSt.camFace  = nil
    pcall(function() RunService:UnbindFromRenderStep(DRIVE_BIND) end)
end

function E.armDrive()
    if RSt.driveOn then return true end
    RSt.driveOn = true
    local ok = pcall(function()
        RunService:BindToRenderStep(DRIVE_BIND, Enum.RenderPriority.Character.Value + 1, function()
            -- self-healing: never outlive the module or the run
            if not RSt.alive then return E.disarmDrive() end
            if not RSt.driveOn or not RSt.playing then return end
            local hum = K.myHum()
            if not hum then return end
            pcall(function() hum:Move(RSt.driveVec or Vector3.zero, false) end)
            -- SPRINT CAMERA-LOCK. The game's MovementController recomputes the Sprint
            -- attribute every frame from cameraLook:Dot(moveDirection) and drops it
            -- below 0.5 -- so a run at the enemy becomes a walk the instant the camera
            -- isn't pointed at them. This binding runs at Character+1, AFTER the
            -- CameraModule (Camera.Value), so pointing the camera here is the last
            -- word for the frame and the game keeps Sprint: the gap-close sprints.
            local face = RSt.camFace
            if face then
                local part = K.targetPart(face)
                local cam = workspace.CurrentCamera
                if part and cam then
                    local from = cam.CFrame.Position
                    local dir = (part.Position - from) * Vector3.new(1, 0, 1)
                    if dir.Magnitude > 0.1 then
                        pcall(function() cam.CFrame = CFrame.lookAt(from, from + dir.Unit) end)
                    end
                end
                -- re-assert Sprint from the last write position; the game keeps it as
                -- long as the camera lock keeps movement inside its forward cone
                local mc = K.myChar()
                if mc then pcall(function() mc:SetAttribute("Sprint", true) end) end
            end
        end)
    end)
    if not ok then RSt.driveOn = false end
    return ok
end

----------------------------------------------------------------------
-- KNIT / MOVESET ACCESS
----------------------------------------------------------------------
function E.servicesFolder()
    local knit = ReplicatedStorage:FindFirstChild("Knit")
    if not knit then return nil end
    local inner = knit:FindFirstChild("Knit") or knit
    return inner:FindFirstChild("Services")
end
function E.serviceRE(serviceName, eventName)
    if not serviceName or not eventName then return nil end
    local services = E.servicesFolder()
    if not services then return nil end
    local svc = services:FindFirstChild(serviceName)
    if not svc then return nil end
    local re = svc:FindFirstChild("RE")
    if not re then return nil end
    return re:FindFirstChild(eventName)
end
function E.movesetFolder()
    local c = K.myChar()
    return c and c:FindFirstChild("Moveset") or nil
end
function E.isMoveValue(inst)
    if typeof(inst) ~= "Instance" then return false end
    local p = inst.Parent
    if not p or p.Name ~= "Moveset" then return false end
    return inst:GetAttribute("Service") ~= nil or inst:GetAttribute("Key") ~= nil
end
-- by name first, then by KEY, so a replay still lands if the move was renamed
-- or you are on a different but similarly-shaped moveset
function E.findMove(name, key)
    local folder = E.movesetFolder()
    if not folder then return nil end
    local direct = name and folder:FindFirstChild(name)
    if direct then return direct end
    if key then
        for _, mv in ipairs(folder:GetChildren()) do
            if mv:GetAttribute("Key") == key then return mv end
        end
    end
    return nil
end

----------------------------------------------------------------------
-- MOVEMENT / RANGE
----------------------------------------------------------------------
local movementController = nil
function E.movementController()
    if movementController and rawget(movementController, "Dash") then return movementController end
    movementController = nil
    -- 1) EXECUTOR PATH: scan the Lua registry for the live controller table.
    if type(getreg) == "function" then
        pcall(function()
            for _, item in pairs(getreg()) do
                if typeof(item) == "table" and rawget(item, "Name") == "MovementController"
                    and type(rawget(item, "Dash")) == "function" then
                    movementController = item
                    break
                end
            end
        end)
    end
    -- 2) MOBILE / LOCKED-DOWN EXECUTOR PATH.
    --    Plenty of phone executors never expose getreg at all. Without it the
    --    scan above resolved nothing, so E.dash quietly returned false and
    --    BOTH the side-dash replay and the range lunge degraded to a walk --
    --    on mobile only, which is exactly the kind of thing that reads as
    --    "the combo just does not work on my phone". Knit hands out the very
    --    same controller table through an ordinary require, with no executor
    --    globals involved. Non-yielding lookups only: this runs mid-playback
    --    and must never stall the tape.
    if not movementController then
        pcall(function()
            local root  = ReplicatedStorage:FindFirstChild("Knit")
            local inner = root and root:FindFirstChild("Knit")
            if not inner then return end
            local Knit = require(inner)
            if type(Knit) ~= "table" or type(Knit.GetController) ~= "function" then return end
            local mc = Knit.GetController("MovementController")
            if typeof(mc) == "table" and type(rawget(mc, "Dash")) == "function" then
                movementController = mc
            end
        end)
    end
    return movementController
end
function E.dash(dir)
    local c = K.myChar()
    if not c then return false end
    if K.myFlag("NoDash") or K.myFlag("Stun") then return false end
    local rag = tonumber(K.charAttr(c, "Ragdoll"))
    if rag and rag > 0 then return false end
    local mc = E.movementController()
    if not mc then return false end
    return pcall(function() mc:Dash(LocalPlayer, c, dir or "Forward") end)
end

-- Dash to the BACK of the target using the hub's OWN curved-dash engine -- the
-- same one Auto Block Break and the Black Flash chain already use. That engine
-- runs at them and turns onto their back mid-dash, which is exactly the arc a
-- recorded "dash with a turn in it" is describing. Returns false when the
-- engine is missing or busy, and the caller falls back to an aimed straight
-- dash so a combo never stalls on it.
function E.dashBehind(target, onArrive)
    if not RCfg.DashBehind then return false end
    if not K.targetValid(target) then return false end
    if type(_G.NH_dashBehind) ~= "function" then return false end
    local ok, res = pcall(_G.NH_dashBehind, target, onArrive)
    return ok and res == true
end

-- RECORD SIDE of the dash fix. Where a dash ENDS cannot be known at the moment
-- it is fired, so we stamp the start geometry now and finish the stamp from the
-- record loop once the dash has actually settled.
function E.beginDashStamp(rec)
    if not rec then return end
    local tgt = K.lookedAtEnemy() or K.nearestEnemy(RCfg.TargetRange)
    if not K.targetValid(tgt) then return end
    local a0 = K.orbitAngle(tgt)
    if not a0 then return end
    rec.dash = { a0 = K.round(a0, 1), d0 = K.round(K.distanceTo(tgt), 2) }

    -- WHICH WAY THE DASH ACTUALLY WENT.
    -- A side dash is "hold A, tap dash" -- the game reads your movement input to
    -- decide Left/Right/Back/Forward, so the stick/keys at this instant ARE the
    -- dash direction. Store that bearing twice:
    --   off = measured against your own facing, which recovers the cardinal
    --   rel = measured against the line to the enemy, which is the part that
    --         still has to mean something once they have moved
    local hrp, hum = K.myHRP(), K.myHum()
    local part = K.targetPart(tgt)
    if hrp and hum and part then
        local lv    = hrp.CFrame.LookVector
        local look  = Vector3.new(lv.X, 0, lv.Z)
        local toTgt = Vector3.new(part.Position.X - hrp.Position.X, 0, part.Position.Z - hrp.Position.Z)
        if look.Magnitude > 0.01 and toTgt.Magnitude > 0.1 then
            local charYaw = K.yawOf(look)
            local dashYaw = charYaw                 -- no input held = plain forward dash
            local mv = hum.MoveDirection
            if mv and mv.Magnitude > 0.1 then
                dashYaw = K.yawOf(Vector3.new(mv.X, 0, mv.Z))
            end
            rec.dash.off = K.round(K.angDelta(dashYaw, charYaw), 1)
            rec.dash.rel = K.round(K.angDelta(dashYaw, K.yawOf(toTgt)), 1)
        end
    end

    RSt.pendingDash = { rec = rec, target = tgt, at = os.clock() }
end

function E.dashStampTick()
    local pend = RSt.pendingDash
    if not pend then return end
    if not RSt.recording then RSt.pendingDash = nil; return end
    if os.clock() - pend.at < (tonumber(RCfg.DashSettle) or 0.35) then return end
    RSt.pendingDash = nil
    local rec, tgt = pend.rec, pend.target
    if not rec or not rec.dash or not K.targetValid(tgt) then return end
    local a1 = K.orbitAngle(tgt)
    if not a1 then return end
    rec.dash.a1    = K.round(a1, 1)
    rec.dash.d1    = K.round(K.distanceTo(tgt), 2)
    rec.dash.orbit = K.round(K.angDelta(a1, rec.dash.a0), 1)
    rec.dash.back  = (math.abs(a1) >= (tonumber(RCfg.DashBackAngle) or 110)) and 1 or 0
end
-- Humanoid.Jump on its own is only a REQUEST, and the humanoid quietly drops it
-- if it samples the flag in the wrong state -- which is why a replayed jump used
-- to do nothing at all. Driving the state change as well makes the take-off
-- actually happen, and the rate limit stops a run of jump samples turning into a
-- stutter of half take-offs.
function E.jump(force)
    local hum = K.myHum()
    if not hum then return false end
    if not force and os.clock() - (RSt.lastDriveJump or 0) < 0.12 then return false end
    RSt.lastDriveJump = os.clock()
    pcall(function() hum.Jump = true end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    return true
end

-- how close THIS press needs us to be, from the distance it was recorded at
function E.rangeFor(recordedDist, wasAir, event)
    local want = RCfg.PlaybackRange
    local rec = tonumber(recordedDist)
    if rec and rec > want then want = rec + RCfg.RangeSlack end
    if wasAir then want = want + RCfg.AirSlack end
    if want > RCfg.MaxRange then want = RCfg.MaxRange end
    -- MELEE CAP -- the thin-air fix. The recorded distance was being used as
    -- the licence to swing, so an M1 you happened to record at 40 studs came
    -- back as "anything under 46 studs is fine" and the replay threw it from
    -- across the street. A punch has to be a punch's length away, whatever the
    -- tape says. Specials and ultimates are left alone, they have real reach.
    if K.isMeleeEvent(event) then
        local cap = tonumber(RCfg.MeleeRange) or 18
        if wasAir then cap = cap + (tonumber(RCfg.MeleeAirSlack) or 4) end
        if want > cap then want = cap end
    end
    return want
end
function E.inRange(model, want)
    if not K.targetValid(model) then return false end
    return K.distanceTo(model) <= (want or RCfg.PlaybackRange)
end
-- Returns true/false. A false NEVER ends a run: the caller skips that one
-- press and carries on in order.
function E.ensureRange(ctx, gen, want, timeout, opts)
    opts = opts or {}
    want = want or RCfg.PlaybackRange
    timeout = timeout or RCfg.RangeWait

    if not K.targetValid(ctx.target) then ctx.target = K.acquireFor(ctx) end
    if not K.targetValid(ctx.target) then return false end
    RSt.target = ctx.target

    E.faceTarget(ctx.target, 0)
    if K.distanceTo(ctx.target) <= want then return true end

    ctx.rangeHold = true
    RSt.camFace = ctx.target
    RSt.status = string.format("closing to %.0f studs", want)

    local start, lunged, jumped = os.clock(), false, false
    while K.owns(gen) and os.clock() - start < timeout do
        if not K.targetValid(ctx.target) then
            ctx.target = K.acquireFor(ctx)
            if not K.targetValid(ctx.target) then break end
            RSt.target = ctx.target
            RSt.camFace = ctx.target
        end
        local gap = K.distanceTo(ctx.target)
        if gap <= want then
            E.stopMoving()
            E.faceTarget(ctx.target, 0)
            ctx.rangeHold = false
            RSt.camFace = nil
            return true
        end
        E.faceTarget(ctx.target, 0)
        if opts.air and not jumped and not K.airborne() then
            jumped = true
            E.jump()
        end
        if (opts.lunge or opts.air) and RCfg.Lunge and not lunged and gap >= RCfg.LungeGap then
            lunged = true
            E.dash("Forward")
        end
        local hum, hrp, other = K.myHum(), K.myHRP(), K.targetPart(ctx.target)
        if not hum or not hrp or not other then break end
        local dir = K.flat(other.Position - hrp.Position)
        if dir then
            local c = K.myChar()
            if c then pcall(function() c:SetAttribute("Sprint", true) end) end
            -- same drive channel as playback, so closing the gap survives the
            -- thumbstick's zero write on mobile
            E.drive(dir)
        end
        RunService.Heartbeat:Wait()
    end

    E.stopMoving()
    ctx.rangeHold = false
    RSt.camFace = nil
    return false
end

----------------------------------------------------------------------
-- VALUE ENCODING   (reads and writes the same slot format as before)
----------------------------------------------------------------------
local function pathOf(inst)
    local parts, node, guard = {}, inst, 0
    while node and node ~= game and guard < 16 do
        table.insert(parts, 1, node.Name)
        node = node.Parent
        guard = guard + 1
    end
    return table.concat(parts, "|")
end
local function resolvePath(path)
    local node = game
    for part in string.gmatch(path or "", "[^|]+") do
        local nxt = node:FindFirstChild(part)
        if not nxt then
            local ok, svc = pcall(game.GetService, game, part)
            nxt = ok and svc or nil
        end
        if not nxt then return nil end
        node = nxt
    end
    return node
end

local encodeValue
local function encodeTable(tbl, depth)
    local out = { k = "tbl", n = 0, v = {} }
    local count = 0
    for i = 1, 12 do if tbl[i] ~= nil then count = i end end
    out.n = count
    for i = 1, count do out.v[i] = encodeValue(tbl[i], depth + 1) end
    return out
end
encodeValue = function(v, depth)
    depth = depth or 0
    if depth > 3 then return { k = "nil" } end
    local t = typeof(v)
    if v == nil then
        return { k = "nil" }
    elseif t == "number" then
        return { k = "lit", v = K.round(v, 5) }
    elseif t == "string" or t == "boolean" then
        return { k = "lit", v = v }
    elseif t == "EnumItem" then
        return { k = "enum", v = tostring(v) }
    elseif t == "Vector3" then
        local hrp = K.myHRP()
        local mag = v.Magnitude
        -- a unit-ish, mostly-flat vector is a DIRECTION: store it relative to
        -- the character so the replay points the new way, not the old way
        if hrp and mag > 0.05 and mag < 1.6 and math.abs(v.Y) < 0.9 then
            local lv = hrp.CFrame:VectorToObjectSpace(v)
            return { k = "dir", x = K.round(lv.X, 4), y = K.round(lv.Y, 4),
                z = K.round(lv.Z, 4), m = K.round(mag, 4) }
        end
        return { k = "vec3", x = K.round(v.X, 3), y = K.round(v.Y, 3), z = K.round(v.Z, 3) }
    elseif t == "CFrame" then
        local p, l = v.Position, v.LookVector
        return { k = "cf", x = K.round(p.X, 3), y = K.round(p.Y, 3), z = K.round(p.Z, 3),
            yaw = K.round(K.yawOf(Vector3.new(l.X, 0, l.Z)), 3) }
    elseif t == "Instance" then
        local me = K.myChar()
        if me and v == me then return { k = "self" } end
        if v == LocalPlayer then return { k = "selfplayer" } end
        if E.isMoveValue(v) then
            local owner = v.Parent and v.Parent.Parent
            if owner == me then
                return { k = "move", name = v.Name, key = v:GetAttribute("Key") }
            end
        end
        if v:IsA("Model") and K.isEnemy(v) then return { k = "enemy", name = v.Name } end
        local folder = K.enemyFolder()
        if folder and v.Parent == folder and me and v ~= me then
            return { k = "enemy", name = v.Name }
        end
        if me and v:IsDescendantOf(me) then return { k = "selfpart", name = v.Name } end
        return { k = "inst", path = pathOf(v), name = v.Name }
    elseif t == "table" then
        return encodeTable(v, depth)
    end
    return { k = "nil" }
end

local function decodeValue(e, ctx)
    if type(e) ~= "table" then return nil end
    local kind = e.k
    if kind == "nil" then
        return nil
    elseif kind == "lit" then
        return e.v
    elseif kind == "enum" then
        local node = nil
        for part in string.gmatch(e.v or "", "[^%.]+") do
            if part == "Enum" then
                node = Enum
            elseif node then
                local ok, nxt = pcall(function() return node[part] end)
                node = ok and nxt or nil
            end
        end
        return node
    elseif kind == "vec3" then
        return Vector3.new(e.x, e.y, e.z)
    elseif kind == "dir" then
        local hrp = K.myHRP()
        local localVec = Vector3.new(e.x, e.y, e.z)
        return hrp and hrp.CFrame:VectorToWorldSpace(localVec) or localVec
    elseif kind == "cf" then
        local pos = Vector3.new(e.x, e.y, e.z)
        return CFrame.new(pos, pos + K.dirOfYaw(e.yaw))
    elseif kind == "self" then
        return K.myChar()
    elseif kind == "selfplayer" then
        return LocalPlayer
    elseif kind == "selfpart" then
        local c = K.myChar()
        return c and c:FindFirstChild(e.name) or nil
    elseif kind == "move" then
        return E.findMove(e.name, e.key)
    elseif kind == "enemy" then
        -- every recorded enemy reference is retargeted to the CURRENT victim,
        -- and a pinned (locked-on) run can only ever resolve to that person
        if ctx and K.targetValid(ctx.target) then return ctx.target end
        local fresh = K.acquireFor(ctx)
        if ctx then ctx.target = fresh end
        return fresh
    elseif kind == "inst" then
        return resolvePath(e.path)
    elseif kind == "tbl" then
        local out = {}
        for i = 1, (e.n or 0) do out[i] = decodeValue(e.v[i], ctx) end
        return out
    end
    return nil
end

----------------------------------------------------------------------
-- REMOTE HOOK
--   The hot path reads the namecall method and does nothing but a table
--   insert. Never call an Instance method inside __namecall before the
--   original is dispatched: it rewrites the thread-local namecall method
--   and the real call gets misrouted.
----------------------------------------------------------------------
local queue, queueN = {}, 0
local hookInstalled = false
local originalNamecall = nil
local wrapC = newcclosure or function(f) return f end
local getMethod = getnamecallmethod
local isOurCall = checkcaller
local probeN = 0     -- ticks on EVERY namecall, so we can prove the hook is alive

-- PERF: getnamecallmethod() used to be called on every single namecall in the
-- game -- thousands per second, forever, even when idle. It now only runs
-- while we are actually recording. This alone removes a constant frame cost.
local function onNamecall(self, ...)
    probeN = probeN + 1
    if RSt.recording and not RSt.playing then
        local method = getMethod and getMethod() or nil
        if method == "FireServer" and not (isOurCall and isOurCall()) then
            queueN = queueN + 1
            queue[queueN] = { clock = os.clock(), remote = self, args = table.pack(...) }
        end
    end
    return originalNamecall(self, ...)
end

local function installHook(force)
    if hookInstalled and not force then return true end
    hookInstalled = false
    local ok = pcall(function()
        if hookmetamethod then
            originalNamecall = hookmetamethod(game, "__namecall", wrapC(onNamecall))
        else
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            originalNamecall = mt.__namecall
            mt.__namecall = wrapC(onNamecall)
            setreadonly(mt, true)
        end
    end)
    if ok and originalNamecall then
        hookInstalled = true
        K.push("remote hook installed")
    else
        K.push("NO HOOK: this executor blocks metamethod hooks")
    end
    return hookInstalled
end

-- THE "I PRESSED RECORD AND IT CAUGHT NOTHING" FIX.
-- The hub hooks __namecall itself (wallhop, ~line 172) and re-locks the game
-- metatable, and auto-downslam hooks it again on demand. Any of those, or any
-- other script you run, can land on top of us and silently swallow our
-- capture -- while our "installed" flag still says everything is fine. So we
-- stop trusting the flag: we make one throwaway method call and check our
-- counter actually moved. If it did not, we re-wrap whatever is on top now.
local function ensureHook()
    if hookInstalled then
        local before = probeN
        pcall(function() return game:GetService("Players") end)
        if probeN > before then return true end
        K.push("hook was overwritten by another script, re-installing")
    end
    return installHook(true)
end

local function restoreHook()
    if not hookInstalled or not originalNamecall then return end
    pcall(function()
        if hookmetamethod then
            hookmetamethod(game, "__namecall", originalNamecall)
        else
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = originalNamecall
            setreadonly(mt, true)
        end
    end)
    hookInstalled, originalNamecall = false, nil
end

local function classifyRemote(remote)
    if typeof(remote) ~= "Instance" then return nil end
    local event, re = remote.Name, remote.Parent
    if not re then return nil end
    local service = re.Parent
    if not service then return nil end
    if re.Name == "RE" or re.Name == "RF" then
        local svcName = service.Name
        if RCfg.IgnoreService[svcName] or RCfg.IgnoreEvent[event] then return nil end
        if string.find(svcName, "AntiCheat") or string.find(event, "Heartbeat") then return nil end
        return { service = svcName, event = event, path = pathOf(remote) }
    end
    if RCfg.IgnoreEvent[event] then return nil end
    return { service = nil, event = event, path = pathOf(remote) }
end

----------------------------------------------------------------------
-- JUMP CAPTURE   (latched -- no sample rate can miss it)
--
-- THE BUG: sampleMotion read Humanoid.Jump straight off the humanoid. That
-- property is only true for a frame or two at take-off, and the tape samples at
-- 30Hz, so the sampler landed either side of that window far more often than on
-- it and the jump was simply never written down. sample.air (FloorMaterial)
-- meanwhile stays set for the WHOLE flight, so every press you made in the air
-- was still stamped air = 1. Replay therefore fired the AERIAL version of the
-- move while the character stood flat on the floor.
--
-- THE FIX: latch the humanoid's own Jumping / StateChanged signal, which fires
-- exactly once per real jump -- spacebar on PC and the touch jump button on
-- mobile both land here -- and let the next sample consume the latch.
----------------------------------------------------------------------
function K.jumpsOn()
    if HubSt and HubSt.crRecordJumps ~= nil then return HubSt.crRecordJumps and true or false end
    return RCfg.RecordJumps ~= false
end

function E.disarmJumpWatch()
    for _, c in ipairs(RSt.jumpConns or {}) do pcall(function() c:Disconnect() end) end
    RSt.jumpConns = {}
    RSt.pendingJump = false
end

function E.armJumpWatch()
    E.disarmJumpWatch()
    local hum = K.myHum()
    if not hum then return false end
    local function latch()
        if RSt.recording and not RSt.playing and K.jumpsOn() then
            RSt.pendingJump = true
            RSt.lastJumpAt = os.clock()
        end
    end
    pcall(function()
        RSt.jumpConns[#RSt.jumpConns + 1] = hum.Jumping:Connect(function(active)
            if active then latch() end
        end)
    end)
    pcall(function()
        RSt.jumpConns[#RSt.jumpConns + 1] = hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Jumping then latch() end
        end)
    end)
    return true
end

----------------------------------------------------------------------
-- RECORD
----------------------------------------------------------------------
-- Every captured press is stamped with the distance and the airborne state
-- it was ACTUALLY taken at, sampled at 30Hz. Playback honours that instead
-- of one fixed range.
local recBuffer, recConn = nil, nil
local lastDist, lastAir = nil, 0
local lastEventAt, stopping = 0, false
local saveToSlot

local function drainQueue(into, t0)
    if queueN == 0 then return end
    local batch, count = queue, queueN
    queue, queueN = {}, 0
    for i = 1, count do
        local item = batch[i]
        if item then
            local okClass, id = pcall(classifyRemote, item.remote)
            if okClass and id then
                local encoded = {}
                local n = item.args.n or 0
                for a = 1, n do
                    local okEnc, res = pcall(encodeValue, item.args[a], 0)
                    encoded[a] = okEnc and res or { k = "nil" }
                end
                local rec = {
                    t = K.round(item.clock - t0, 4),
                    svc = id.service, ev = id.event, path = id.path,
                    n = n, args = encoded,
                    d = lastDist and K.round(lastDist, 2) or nil,
                    air = lastAir,
                }
                into[#into + 1] = rec
                -- a dash only means something relative to the person you dashed
                -- at, so stamp that geometry onto the event
                if K.isDashEvent(rec) then
                    -- SIDE-DASH FIX (record half). Keep the EXACT cardinal the
                    -- game sent ("Left"/"Right"/"Back"/"Front"). Playback needs it
                    -- to PERFORM a real client-side dash, not just tell the server.
                    local a1 = rec.args and rec.args[1]
                    if a1 and a1.k == "lit" and type(a1.v) == "string"
                        and (a1.v == "Left" or a1.v == "Right"
                            or a1.v == "Back" or a1.v == "Front") then
                        rec.cardinal = a1.v
                    end
                    K.safe(E.beginDashStamp, rec)
                end
                RSt.eventCount = #into
                lastEventAt = item.clock or os.clock()
            end
        end
    end
end

-- Locked samples store enemy-relative yaw, unlocked samples store yaw
-- relative to the start. That is what makes a replay follow a NEW enemy.
local function sampleMotion(t0, baseYaw)
    local hrp, hum = K.myHRP(), K.myHum()
    if not hrp then return nil end
    local look = K.flat(hrp.CFrame.LookVector)
    if not look then return nil end
    local myYaw = K.yawOf(look)
    local sample = { t = K.round(os.clock() - t0, 3) }
    local enemy = K.lookedAtEnemy()
    if enemy then
        local other = K.targetPart(enemy)
        local dir = other and K.flat(other.Position - hrp.Position)
        if dir then
            sample.lock = 1
            sample.a = K.round(K.angDelta(myYaw, K.yawOf(dir)), 2)
            sample.d = K.round(K.distanceTo(enemy), 2)
            lastDist = sample.d
        else
            enemy = nil
        end
    end
    if not enemy then
        sample.lock = 0
        sample.a = K.round(K.angDelta(myYaw, baseYaw), 2)
        local near = K.nearestEnemy(RCfg.TargetRange)
        if near then lastDist = K.round(K.distanceTo(near), 2) end
    end
    if hum then
        local move = hum.MoveDirection
        if move.Magnitude > 0.05 then
            local lv = hrp.CFrame:VectorToObjectSpace(move)
            sample.mx, sample.mz = K.round(lv.X, 3), K.round(lv.Z, 3)
        end
        -- consume the latch set by the real Jumping signal, and keep reading
        -- hum.Jump as a second chance in case we happen to land right on it
        if K.jumpsOn() then
            if RSt.pendingJump or hum.Jump then
                sample.j = 1
                RSt.pendingJump = false
            end
        else
            RSt.pendingJump = false
        end
        if hum.FloorMaterial == Enum.Material.Air then
            sample.air = 1
            lastAir = 1
        else
            lastAir = 0
        end
    end
    return sample
end

function R.record()
    if RSt.recording then return R.stop() end
    -- A playback that died still holding the flag used to block recording
    -- FOREVER, with nothing on screen to say why. Recording now always wins:
    -- we tear the old run down and start clean.
    if RSt.playing then R.cancel("record") end
    if not ensureHook() then
        RSt.status = "hook blocked"
        UI.setRecording(false)
        notify("Combo Recorder", "This executor blocks remote hooks, so moves cannot be captured.", 5)
        UI.refresh()
        return false
    end
    local hrp = K.myHRP()
    if not hrp then
        RSt.status = "no character"
        UI.setRecording(false)
        notify("Combo Recorder", "No character yet. Respawn, then record.", 3)
        UI.refresh()
        return false
    end
    local look = K.flat(hrp.CFrame.LookVector) or Vector3.new(0, 0, 1)
    local t0 = os.clock()
    queue, queueN = {}, 0
    lastDist, lastAir = nil, 0
    lastEventAt, stopping = 0, false
    E.armJumpWatch()
    recBuffer = {
        version = 3, name = "",
        char = K.myChar() and K.charAttr(K.myChar(), "Character") or "unknown",
        t0 = t0, baseYaw = K.yawOf(look), events = {}, motion = {}, duration = 0,
    }
    RSt.recording = true
    RSt.recStart = t0
    RSt.eventCount, RSt.sampleCount = 0, 0
    RSt.pendingDash = nil
    RSt.status = "RECORDING"
    K.push("recording started")
    UI.setRecording(true)
    notify("Combo Recorder", "Recording. Do your combo.", 2)

    local interval, nextSample = 1 / math.max(5, RCfg.SampleHz), 0
    recConn = K.track(RunService.Heartbeat:Connect(function()
        if not RSt.recording or not recBuffer then return end
        local elapsed = os.clock() - t0
        if elapsed >= nextSample then
            nextSample = elapsed + interval
            local sample = sampleMotion(t0, recBuffer.baseYaw)
            if sample then
                recBuffer.motion[#recBuffer.motion + 1] = sample
                RSt.sampleCount = #recBuffer.motion
            end
        end
        if queueN > 0 then K.safe(drainQueue, recBuffer.events, t0) end
        -- finish a dash's geometry stamp once the dash has actually landed
        if RSt.pendingDash then K.safe(E.dashStampTick) end

        -- NO AUTO-STOP. This is what was ending your recording on its own
        -- part-way through a combo: any pause longer than the idle window --
        -- repositioning, dashing in, waiting out a cooldown -- counted as
        -- "finished" and closed the tape. The tape now ends when YOU say so.

        if elapsed > RCfg.MaxSeconds and not stopping then
            stopping = true
            K.push("hit the %ds ceiling, stopping", RCfg.MaxSeconds)
            task.spawn(R.stop)
        end
    end))
    return true
end

function R.stop()
    if not RSt.recording then return false end
    RSt.recording = false
    E.disarmJumpWatch()
    if recConn then pcall(function() recConn:Disconnect() end); recConn = nil end
    local buf = recBuffer
    recBuffer = nil
    if not buf then RSt.status = "idle"; return false end
    K.safe(drainQueue, buf.events, buf.t0)

    -- pull the whole tape forward so it starts on your first move
    local firstT = buf.events[1] and buf.events[1].t or 0
    if firstT > 0.15 then
        local shift = firstT - 0.05
        for _, event in ipairs(buf.events) do event.t = K.round(event.t - shift, 4) end
        local kept = {}
        for _, sample in ipairs(buf.motion) do
            local nt = K.round(sample.t - shift, 3)
            if nt >= -0.05 then sample.t = math.max(0, nt); kept[#kept + 1] = sample end
        end
        buf.motion = kept
    end

    -- TAIL TRIM. The tape ENDS at your last move, not at the moment you got
    -- round to pressing stop. Everything after the last captured press is
    -- dead time, and keeping it is what made playback carry on steering and
    -- walking you for seconds after the combo was over.
    local lastEvent = 0
    for _, event in ipairs(buf.events) do if event.t > lastEvent then lastEvent = event.t end end
    local lastSample = 0
    for _, sample in ipairs(buf.motion) do if sample.t > lastSample then lastSample = sample.t end end

    local endAt = math.max(lastSample, lastEvent)
    if RCfg.TrimTail and #buf.events > 0 then
        endAt = math.max(lastEvent, math.min(endAt, lastEvent + math.max(0, tonumber(RCfg.TailPad) or 0)))
        local kept = {}
        for _, sample in ipairs(buf.motion) do
            if sample.t <= endAt + 0.001 then kept[#kept + 1] = sample end
        end
        local dropped = #buf.motion - #kept
        buf.motion = kept
        RSt.sampleCount = #kept
        local dead = lastSample - endAt
        if dead > 0.05 then
            K.push("trimmed %.2fs of dead time (%d samples) after your last move", dead, dropped)
        end
    end
    buf.lastEvent = K.round(lastEvent, 3)
    buf.duration, buf.t0 = K.round(endAt, 3), nil
    RSt.status = "idle"
    UI.setRecording(false)
    -- An empty tape must NEVER overwrite a good one, and you must be TOLD.
    -- A silent empty save is exactly what "it didn't capture my shit" looks
    -- like from the outside.
    if #buf.events == 0 then
        K.push("nothing captured, no moves fired")
        notify("Combo Recorder", "Captured 0 moves. Slot " .. RSt.slot .. " left as it was.", 4)
        UI.refresh()
        return false
    end
    K.push("captured %d moves, %.2fs", #buf.events, buf.duration)
    saveToSlot(RSt.slot, buf)
    notify("Combo Recorder", string.format("Saved %d moves to slot %d.", #buf.events, RSt.slot), 3)
    UI.syncSlots()
    return true
end

----------------------------------------------------------------------
-- STORAGE
----------------------------------------------------------------------
local canWrite = (typeof(writefile) == "function") and (typeof(isfile) == "function")
local function slotFile(i) return RCfg.Folder .. "/slot" .. tostring(i) .. ".json" end
local function ensureFolder()
    if not canWrite then return false end
    return pcall(function()
        if typeof(isfolder) == "function" and not isfolder(RCfg.Folder) then makefolder(RCfg.Folder) end
    end)
end
local function writeSlot(i, tape)
    if not ensureFolder() then return false end
    return pcall(function() writefile(slotFile(i), HttpService:JSONEncode(tape)) end)
end
local function readSlot(i)
    if not canWrite then return nil end
    local ok, result = pcall(function()
        if isfile(slotFile(i)) then return HttpService:JSONDecode(readfile(slotFile(i))) end
        return nil
    end)
    return ok and result or nil
end
saveToSlot = function(i, tape)
    if tape.name == nil or tape.name == "" then tape.name = string.format("Combo %d", i) end
    RSt.slots[i] = tape
    local saved = writeSlot(i, tape)
    K.push("saved to slot %d as \"%s\"%s", i, tape.name, saved and "" or " (memory only)")
    return true
end
function R.rename(name)
    local tape = RSt.slots[RSt.slot]
    if not tape then K.push("slot %d is empty", RSt.slot); return false end
    if not name or name == "" then return false end
    tape.name = tostring(name)
    writeSlot(RSt.slot, tape)
    K.push("slot %d renamed to \"%s\"", RSt.slot, tape.name)
    UI.syncSlots()
    return true
end
function R.delete(i)
    i = i or RSt.slot
    RSt.slots[i] = nil
    pcall(function()
        if canWrite and typeof(delfile) == "function" and isfile(slotFile(i)) then delfile(slotFile(i)) end
    end)
    K.push("slot %d cleared", i)
    UI.syncSlots()
    return true
end
function R.loadAll()
    for i = 1, RCfg.Slots do
        local tape = readSlot(i)
        if tape and tape.events then RSt.slots[i] = tape end
    end
end

----------------------------------------------------------------------
-- PLAYBACK
----------------------------------------------------------------------
local function fireRecorded(event, ctx)
    local remote = nil
    if event.svc then remote = E.serviceRE(event.svc, event.ev) end
    if not remote and event.path then remote = resolvePath(event.path) end
    if not remote then K.push("missing remote %s", tostring(event.svc or event.path)); return false end
    local args = {}
    local argCount = event.n or 0
    for i = 1, argCount do args[i] = decodeValue(event.args[i], ctx) end

    -- Physical input normally supplies the Todo Sweep/Pebble variant payload.
    -- Auto Combo bypasses input and fires the saved remote itself, so let the
    -- managed module rewrite this one call whenever its Characters toggle is on.
    local sweep = rawget(_G, "NH_TodoSweepVariant")
        or rawget(getgenv(), "NH_TodoSweepVariant")
    if type(sweep) == "table" and type(sweep.RewriteRecordedCall) == "function" then
        local okRewrite, rewrittenArgs, rewrittenCount, changed = pcall(
            sweep.RewriteRecordedCall, event, args, argCount
        )
        if okRewrite and type(rewrittenArgs) == "table" then
            args = rewrittenArgs
            argCount = tonumber(rewrittenCount) or argCount
            if changed then K.push("Todo Pebble Throw variant applied") end
        elseif not okRewrite then
            K.push("Todo variant playback bridge failed: %s", tostring(rewrittenArgs))
        end
    end

    local ok, err = pcall(function() remote:FireServer(table.unpack(args, 1, argCount)) end)
    if not ok then K.push("fire failed: %s", tostring(err)); return false end
    return true
end

local function applyFacing(sample, ctx)
    if ctx.rangeHold then return end
    -- your own camera turn wins here too: playback stops writing your facing
    -- for a moment instead of fighting you for it
    if E.playerTurning() then return end
    local hrp = K.myHRP()
    if not hrp then return end
    local desired = nil
    if sample.lock == 1 then
        if not K.targetValid(ctx.target) then ctx.target = K.acquireFor(ctx) end
        if K.targetValid(ctx.target) then
            local base = E.yawToward(ctx.target)
            if base then desired = base + sample.a end
        end
    end
    if not desired then desired = ctx.baseYaw + sample.a end
    -- DEADZONE. Without this the root CFrame is rewritten every single frame
    -- even when the angle has not really changed, and that constant
    -- sub-degree correction is exactly what reads as jitter.
    local look = K.flat(hrp.CFrame.LookVector)
    if look and math.abs(K.angDelta(desired, K.yawOf(look))) < (RCfg.FaceDeadzone or 0.75) then
        return
    end
    -- book the steer window so AutoRotate is only off while playback is
    -- really driving, and comes back the moment the tape ends
    E.facingTick(0.15)
    E.applyYaw(desired)
end

local function applyMovement(sample, ctx, jumpSeen)
    if ctx.rangeHold then return end
    local hum, hrp = K.myHum(), K.myHRP()
    if not hum or not hrp then return end
    if RCfg.DriveMove then
        -- published through E.drive so the RenderStep re-assert keeps it alive
        -- against the control module's per-frame zero write
        if sample.mx or sample.mz then
            local localDir = Vector3.new(sample.mx or 0, 0, sample.mz or 0)
            E.drive(hrp.CFrame:VectorToWorldSpace(localDir))
        else
            E.drive(Vector3.zero)
        end
    end
    -- jumpSeen carries a jump out of any sample the cursor had to skip past,
    -- so a hop is never lost to a slow frame
    local wantJump = (sample.j == 1) or (jumpSeen == true)
    if RCfg.DriveJump and K.jumpsOn() and wantJump and not ctx.jumped then
        ctx.jumped = true
        E.jump()
    elseif not wantJump then
        ctx.jumped = false
    end
end

-- A tape can legitimately end on a press whose release you never captured,
-- because you stopped recording while still holding the key. Fire that one
-- release so playback does not leave a move charging for ever. Deliberately
-- narrow: only the FINAL press, only on a service that really does take a
-- release, and only when the tape proves you release that move elsewhere.
local function closeDanglingHolds(tape)
    local events = tape.events or {}
    local last = events[#events]
    if not last or not last.svc then return end
    if last.ev ~= "Activated" and last.ev ~= "RightActivated" then return end
    local releaseEv = last.ev == "RightActivated" and "RightDeactivated" or "Deactivated"
    local proven = false
    for _, event in ipairs(events) do
        if event.svc == last.svc and event.ev == releaseEv then proven = true; break end
    end
    if not proven then return end
    local remote = E.serviceRE(last.svc, releaseEv)
    if not remote then return end
    pcall(function() remote:FireServer() end)
    K.push("released the hold the tape ended on")
end

-- A press that cannot reach is SKIPPED and the rest of the tape still plays
-- in order. Only death, the timeout, a cancel, or losing a LOCKED target
-- ends a playback.
local function runPlayback(tape, myGen, startTarget, pinned)
    local hrp = K.myHRP()
    if not hrp then K.push("no character"); return false end

    E.facingOpen(myGen)
    E.armDrive()
    local ctx = {
        target = startTarget,
        baseYaw = K.yawOf(K.flat(hrp.CFrame.LookVector) or Vector3.new(0, 0, 1)),
        jumped = false, rangeHold = false, pinned = pinned,
    }
    RSt.target = ctx.target
    E.faceTarget(ctx.target, 0)

    local speed = math.clamp(RCfg.Speed, 0.25, 3)
    local lead=math.max(0,tonumber(tape.events[1] and tape.events[1].t) or 0)
    for _,sample in ipairs(tape.motion or {}) do
        if (tonumber(sample.t) or 0)>=lead then break end
        if sample.j==1 or math.abs(tonumber(sample.mx) or 0)>0.01 or math.abs(tonumber(sample.mz) or 0)>0.01 then
            lead=0;break
        end
    end
    local t0 = os.clock()-lead/speed
    local duration = tape.duration or 0
    local runStart = os.clock()

    -- HARD END AT THE LAST MOVE. The cut-off is recomputed from the events
    -- themselves, not taken on trust from tape.duration, so combos saved
    -- before the tail trim existed stop at your last move as well instead of
    -- steering and walking you through their dead tail.
    local lastEvent = tonumber(tape.lastEvent) or 0
    if lastEvent <= 0 then
        for _, event in ipairs(tape.events or {}) do
            if (event.t or 0) > lastEvent then lastEvent = event.t end
        end
    end
    local endAt = duration
    if RCfg.TrimTail and lastEvent > 0 then
        endAt = math.min(duration, lastEvent + math.max(0, tonumber(RCfg.TailPad) or 0))
    end
    if endAt <= 0 then endAt = duration end
    RSt.fired, RSt.skipped = 0, 0
    RSt.stepCount = #tape.events
    K.push("playing \"%s\" on %s%s", tostring(tape.name), K.displayName(ctx.target),
        pinned and " (locked)" or "")

    -- motion thread: facing + movement, on its own cursor
    task.spawn(function()
        local idx, motion = 1, tape.motion or {}
        while K.owns(myGen) and RSt.playing do
            if ctx.rangeHold then
                -- freeze the motion cursor too, or a range wait silently eats
                -- the samples that were meant to come after it
                RunService.Heartbeat:Wait()
            else
                K.beat()
                local now = (os.clock() - t0) * speed
                if now > endAt then break end
                -- A jump lives in ONE sample. The cursor used to leap straight
                -- over it whenever two samples fell inside a single frame, which
                -- silently dropped the hop. Every sample we pass now still gets
                -- its jump honoured.
                local jumpSeen = false
                while motion[idx + 1] and motion[idx + 1].t <= now do
                    idx = idx + 1
                    if motion[idx].j == 1 then jumpSeen = true end
                end
                local sample = motion[idx]
                if sample then
                    K.safe(applyFacing, sample, ctx)
                    K.safe(applyMovement, sample, ctx, jumpSeen)
                end
                RunService.Heartbeat:Wait()
            end
        end
        -- the motion cursor is done: drop the controls and hand turning back
        if K.owns(myGen) then
            K.safe(E.stopMoving)
            K.safe(E.facingIdle)
        end
    end)

    for i, event in ipairs(tape.events) do
        if not K.owns(myGen) then return false end
        K.beat()
        if os.clock() - runStart > RCfg.RunTimeout then
            K.push("playback timeout")
            break
        end
        if K.fatalState() then
            K.push("died mid combo, stopping")
            break
        end
        -- LOCKED RUNS ARE EXCLUSIVE. If the person you locked is gone, the
        -- combo ends. It never rolls onto a bystander.
        if pinned and not K.targetValid(ctx.target) and not K.hubLocked() then
            K.push("locked target is gone, stopping")
            break
        end

        -- wait for this press's timestamp
        while K.owns(myGen) do
            local now = (os.clock() - t0) * speed
            if now >= event.t then break end
            local remaining = (event.t - now) / speed
            if remaining > 0.03 then task.wait(math.min(remaining, 0.05)) else RunService.Heartbeat:Wait() end
        end
        if not K.owns(myGen) then return false end

        RSt.stepIndex = i

        local allowed = true
        if RCfg.RangeGuard and K.isAttackEvent(event) then
            local wasAir = (tonumber(event.air) or 0) == 1
            local want = E.rangeFor(event.d, wasAir, event)

            -- ABORT RATHER THAN MIME IT. If the person is gone, or so far off
            -- that closing the gap would not be a combo any more, the run ends
            -- cleanly here instead of standing in the open throwing punches at
            -- nothing.
            if not K.targetValid(ctx.target) then ctx.target = K.acquireFor(ctx) end
            if RCfg.AbortIfFar and (not K.targetValid(ctx.target)
                or K.distanceTo(ctx.target) > (tonumber(RCfg.AbortRange) or 90)) then
                K.push("nobody in range, aborting the combo")
                notify("Combo Recorder", "No one close enough -- combo aborted.", 3)
                break
            end

            if not E.inRange(ctx.target, want) then
                if RCfg.RunToEnemy then
                    local holdAt = os.clock()
                    allowed = E.ensureRange(ctx, myGen, want, RCfg.RangeWait, { air = wasAir, lunge = true })
                    -- rebase the clock so the gaps you recorded stay intact
                    t0 = t0 + (os.clock() - holdAt)
                    if not K.owns(myGen) then return false end
                else
                    -- running is switched off: the press is SKIPPED, never
                    -- thrown at a target that is not there
                    allowed = false
                end
            end
            if allowed then E.faceTarget(ctx.target, 0) end
        end

        -- AERIAL PRESSES GET A REAL JUMP. Every press is stamped with the
        -- airborne state it was taken in. Firing an air move with both feet on
        -- the floor is exactly what made a replay launch the aerial variant
        -- while standing still. If this press was recorded in the air and we are
        -- grounded, hop first and give the state a few frames to flip, then
        -- rebase the clock so the gaps you recorded stay intact.
        if allowed and RCfg.AirLift and RCfg.DriveJump and K.jumpsOn()
            and (tonumber(event.air) or 0) == 1 and not K.airborne() then
            local liftAt = os.clock()
            if E.jump() then
                local waitUntil = liftAt + (tonumber(RCfg.AirLiftWait) or 0.30)
                while K.owns(myGen) and os.clock() < waitUntil and not K.airborne() do
                    RunService.Heartbeat:Wait()
                end
            end
            t0 = t0 + (os.clock() - liftAt)
            if not K.owns(myGen) then return false end
        end

        -- DASHES ARE RE-AIMED, NEVER REPLAYED BLIND.
        -- The recorded direction pointed at wherever the enemy was standing at
        -- the time. Firing that raw sends you sailing past someone who has
        -- since moved -- the exact miss you were seeing. So the dash is first
        -- re-pointed at the CURRENT target, and if the recording shows you
        -- curved around them, it is handed to the hub's curved-dash engine,
        -- which runs in and turns onto their back mid-dash.
        local dashHandled = false
        if allowed and RCfg.DashAim and K.isDashEvent(event) then
            if not K.targetValid(ctx.target) then ctx.target = K.acquireFor(ctx) end
            if K.targetValid(ctx.target) then
                local info   = event.dash
                -- A plain side dash also swings you around them, so ending up
                -- off to their flank must NOT be mistaken for a dash-behind.
                -- Both conditions now have to hold: you travelled a real arc
                -- AND you finished behind them.
                local curved = RCfg.DashBehind and info ~= nil
                    and (info.back == 1)
                    and math.abs(tonumber(info.orbit) or 0) >= (tonumber(RCfg.DashTurnDeg) or 35)
                local dashAt = os.clock()
                ctx.rangeHold = true      -- the motion cursor must not fight the dash
                if curved then
                    local arrived = false
                    if E.dashBehind(ctx.target, function() arrived = true end) then
                        dashHandled = true
                        local waitUntil = dashAt + (tonumber(RCfg.DashWait) or 0.50)
                        while K.owns(myGen) and not arrived and os.clock() < waitUntil do
                            RunService.Heartbeat:Wait()
                        end
                    end
                end
                if not dashHandled then
                    -- REBUILD THE DASH AGAINST THE LIVE TARGET.
                    -- rel is the bearing you dashed at measured off the line to
                    -- the enemy, so re-hanging it on the CURRENT line puts the
                    -- dash exactly where it sat in the recording: straight in if
                    -- you went straight in, out to their flank if you cut to
                    -- their flank. off then recovers the facing that turns that
                    -- bearing back into the same Left/Right/Back press you made.
                    local tgtYaw = E.yawToward(ctx.target)
                    local rel    = info and tonumber(info.rel) or nil
                    local off    = info and tonumber(info.off) or nil
                    if RCfg.DashSide and tgtYaw and rel and off then
                        local dashYaw = tgtYaw + rel
                        local faceYaw = dashYaw - off
                        -- never leave us facing away from the fight
                        local skew = K.angDelta(faceYaw, tgtYaw)
                        local lim  = tonumber(RCfg.DashFaceMax) or 135
                        if math.abs(skew) > lim then
                            faceYaw = tgtYaw + ((skew > 0) and lim or -lim)
                        end
                        E.faceYaw(faceYaw)
                        -- feed the movement input as well. The game picks the
                        -- dash cardinal off your stick, so THIS is what makes a
                        -- side dash come out sideways instead of forward.
                        E.drive(K.dirOfYaw(dashYaw))
                    else
                        -- old tape with no bearing recorded: aim it at them
                        E.faceTarget(ctx.target, 0)
                    end
                    -- one frame for the new facing and MoveDirection to land
                    -- before the dash reads them
                    RunService.Heartbeat:Wait()
                end
                ctx.rangeHold = false
                t0 = t0 + (os.clock() - dashAt)   -- keep your recorded gaps intact
                if not K.owns(myGen) then return false end
            end
        end

        -- ===== SIDE-DASH FIX (playback half) =====
        -- A MovementService dash ("Left"/"Right"/"Back"/"Front") only TELLS
        -- the server where you went. The displacement itself is created
        -- CLIENT-side by MovementController:Dash (the BodyVelocity burst) --
        -- the real game does BOTH on every dash: Dash:FireServer(dir) AND a
        -- local Dash() call. Playback only ever re-fired the remote, so a
        -- recorded side dash replayed as NOTHING and you just walked the
        -- drive vector. Front dashes looked fine because they leave as the
        -- moveset's Chase remote, whose movement is server-driven.
        --
        -- The facing was already re-aimed above (faceYaw = dashYaw - off),
        -- so dashing the recorded cardinal now travels the re-aimed bearing:
        -- a side dash toward the enemy stays a side dash toward the enemy,
        -- wherever they are standing now. Runs whether or not DashAim is on.
        -- The cardinal is read straight back out of the recorded remote args,
        -- so tapes recorded BEFORE this fix replay correctly too.
        if allowed and not dashHandled and K.isDashEvent(event)
            and string.find(tostring(event.ev or ""), "Dash", 1, true) then
            local cardinal = event.cardinal
            if not cardinal then
                local a1 = event.args and event.args[1]
                if a1 and a1.k == "lit" and type(a1.v) == "string"
                    and (a1.v == "Left" or a1.v == "Right"
                        or a1.v == "Back" or a1.v == "Front") then
                    cardinal = a1.v
                end
            end
            -- ResetDash and friends carry no cardinal: nothing to perform.
            if cardinal then K.safe(E.dash, cardinal) end
        end

        if dashHandled then
            RSt.fired = RSt.fired + 1
        elseif allowed then
            if fireRecorded(event, ctx) then RSt.fired = RSt.fired + 1 end
        else
            RSt.skipped = RSt.skipped + 1
            K.push("skipped a move, could not close the gap")
        end
        RSt.status = string.format("playing %d/%d", i, #tape.events)
    end

    -- Wait out the tail only as far as the LAST MOVE. A recording that was
    -- left rolling while you reached for the stop key does not get to keep
    -- steering you, walking you, or holding your AutoRotate hostage.
    while K.owns(myGen) and (os.clock() - t0) * speed <= endAt do
        K.beat()
        RunService.Heartbeat:Wait()
    end
    E.stopMoving()
    E.disarmDrive()
    E.facingIdle()
    if RCfg.ReleaseTail then K.safe(closeDanglingHolds, tape) end
    K.push("done: %d fired, %d skipped", RSt.fired, RSt.skipped)
    return true
end

function R.play(slot)
    slot = slot or RSt.slot
    local tape = RSt.slots[slot]
    if RSt.recording then R.stop() end
    if not tape then
        K.push("slot %d is empty, record something first", slot)
        RSt.status = "slot " .. slot .. " empty"
        notify("Combo Recorder", "Slot " .. slot .. " is empty.", 3)
        UI.refresh()
        return false
    end
    if RSt.playing then
        R.cancel("restart")
    end

    -- locked person, else closest person
    local locked = K.hubLocked()
    local target = locked or K.nearestEnemy(RCfg.EngageRange)
    if not K.targetValid(target) then
        RSt.status = "nobody in range"
        K.push("no one close enough to combo")
        notify("Combo Recorder",
            locked and "Your locked target is out of range." or "Nobody close enough.", 3)
        UI.refresh()
        return false
    end

    local myGen = K.nextGen()
    RSt.playing, RSt.slot, RSt.target = true, slot, target
    RSt.playStart = os.clock()   -- watchdog reference, see HOUSEKEEPING
    RSt.status = "starting"

    task.spawn(function()
        local ok, err = pcall(runPlayback, tape, myGen, target, locked ~= nil)
        if not ok then
            RSt.lastError = tostring(err)
            K.push("playback error: %s", tostring(err))
        end
        if K.owns(myGen) then
            RSt.playing = false
            RSt.status = "idle"
            RSt.stepIndex = 0
            E.stopMoving()
            E.disarmDrive()
            E.facingIdle()
            E.facingClose(myGen)
        end
        UI.refresh()
    end)
    return true
end

-- one teardown for every way a run can end
function R.cancel(why)
    RSt.gen = RSt.gen + 1        -- retires every thread on the spot
    local was = RSt.recording or RSt.playing
    if RSt.recording then
        RSt.recording = false
        E.disarmJumpWatch()
        if recConn then pcall(function() recConn:Disconnect() end); recConn = nil end
        recBuffer = nil
    end
    RSt.playing = false
    RSt.stepIndex = 0
    RSt.status = "idle"
    K.safe(E.stopMoving)
    K.safe(E.disarmDrive)
    K.safe(E.facingRelease)
    UI.setRecording(false)
    if was then K.push("stopped (%s)", tostring(why or "manual")) end
    UI.refresh()
    return true
end

function R.toggleRecord()
    if RSt.recording then return R.stop() end
    if RSt.playing then R.cancel("record") end
    return R.record()
end

-- Play is a TOGGLE everywhere -- key, menu button, mobile button -- so there
-- is one rule to remember. Press it mid-combo and the combo stops right
-- there, with your turning handed straight back.
function R.playToggle(slot)
    if RSt.playing then return R.cancel("play") end
    if RSt.recording then R.stop() end
    return R.play(slot)
end

----------------------------------------------------------------------
-- UI   (Fluent tab)
----------------------------------------------------------------------
local function keyName(kc)
    if typeof(kc) ~= "EnumItem" then return "?" end
    return kc.Name
end
local function toKeyCode(v)
    if typeof(v) == "EnumItem" then return v end
    if type(v) == "string" then
        local ok, kc = pcall(function() return Enum.KeyCode[v] end)
        if ok and typeof(kc) == "EnumItem" then return kc end
    end
    return nil
end

function UI.slotLabel(i)
    local tape = RSt.slots[i]
    if tape then
        return string.format("%d. %s  (%d moves, %.1fs)", i, tostring(tape.name),
            #(tape.events or {}), tape.duration or 0)
    end
    return string.format("%d. empty", i)
end
function UI.slotValues()
    local out = {}
    for i = 1, RCfg.Slots do out[i] = UI.slotLabel(i) end
    return out
end
function UI.syncSlots()
    if not UI.slotDrop then return end
    pcall(function() UI.slotDrop:SetValues(UI.slotValues()) end)
    pcall(function() UI.slotDrop:SetValue(UI.slotLabel(RSt.slot)) end)
    UI.refresh()
end

function UI.refresh()
    if not UI.status then return end
    -- ONE short line. The old status was four lines of wrapped text, which is
    -- what was overlapping itself on a phone.
    local line
    if RSt.recording then
        line = string.format('REC   %.1fs   %d moves   -> slot %d',
            math.max(0, os.clock() - (RSt.recStart or os.clock())), RSt.eventCount, RSt.slot)
    elseif RSt.playing then
        line = string.format('PLAYING   %d/%d   -> %s',
            RSt.stepIndex, RSt.stepCount, K.displayName(RSt.target))
    else
        local tape = RSt.slots[RSt.slot]
        if tape then
            line = string.format('Slot %d   "%s"   %d moves   %.1fs',
                RSt.slot, tostring(tape.name), #(tape.events or {}), tape.duration or 0)
        else
            line = string.format('Slot %d   empty', RSt.slot)
        end
    end
    local locked = K.hubLocked()
    if locked then
        line = line .. '   |   LOCKED: ' .. K.displayName(locked)
    else
        line = line .. '   |   target: closest'
    end
    pcall(function() UI.status:SetDesc(line) end)
end

-- There is no switch to keep in sync any more, so this only repaints the
-- status line. Kept as one entry point so every state change still has a
-- single place to route through.
function UI.setRecording(_on)
    UI.refresh()
end

function UI.build()
    local tab = Tabs.Combos
    if not tab then return end

    UI.status = tab:AddParagraph({ Title = "Status", Content = "Loading..." })

    -- Two plain buttons, one directly under the other. Nothing here changes
    -- state unless you press it.
    tab:AddButton({
        Title = "Start Recording",
        Description = "Begins capturing into the slot below.",
        Callback = function() K.safe(R.record) end,
    })
    tab:AddButton({
        Title = "Stop Recording",
        Description = "Ends the recording and saves it to the slot.",
        Callback = function() K.safe(R.stop) end,
    })

    tab:AddSection("Your Combos")
    UI.slotDrop = tab:AddDropdown("CRSlot", {
        Title = "Combo Slot",
        Description = "Recording saves here, and the play key plays this one.",
        Values = UI.slotValues(),
        Default = 1,
        Callback = function(value)
            local n = tonumber(string.match(tostring(value), "^(%d+)%."))
            if n and n >= 1 and n <= RCfg.Slots then
                RSt.slot = n
                UI.refresh()
            end
        end,
    })
    tab:AddInput("CRName", {
        Title = "Name This Combo",
        Default = "",
        Placeholder = "type a name, press enter",
        Numeric = false,
        Finished = true,
        Callback = function(text)
            if text and text ~= "" then K.safe(R.rename, text) end
        end,
    })
    tab:AddButton({
        Title = "Play / Stop Combo",
        Description = "Runs on whoever you are locked onto, else the closest person. Press again to stop.",
        Callback = function() K.safe(R.playToggle, RSt.slot) end,
    })
    tab:AddButton({
        Title = "Delete This Combo",
        Callback = function() K.safe(R.delete, RSt.slot) end,
    })

    -- Keyboard-only pickers: phones use the REC / AUTO COMBO / STOP buttons instead
    -- (Keybinds tab), and a touch tap leaves Fluent's picker stuck on "...".
    if not mobile then
        tab:AddSection("Keys")
        St.KeyBinds.Add(tab, "CRKeyRecord", {
            Title = "Record Key", Name = "Combo Record", Default = "F8",
            Apply = function(code) RKeys.record = code; pcall(UI.refresh) end,
        })
        St.KeyBinds.Add(tab, "CRKeyPlay", {
            Title = "Play / Stop Key", Name = "Combo Play / Stop", Default = "F9",
            Apply = function(code) RKeys.play = code; pcall(UI.refresh) end,
        })
        St.KeyBinds.Add(tab, "CRKeyStop", {
            Title = "Panic Stop Key", Name = "Combo Panic Stop", Default = "Backspace",
            Apply = function(code) RKeys.stop = code; pcall(UI.refresh) end,
        })
    end

    tab:AddSection("Speed")
    tab:AddSlider("CRSpeed", {
        Title = "Playback Speed",
        Min = 0.5, Max = 2, Default = 1, Rounding = 2,
        Callback = function(v) RCfg.Speed = math.clamp(tonumber(v) or 1, 0.25, 3) end,
    })

    -- EXTRA SETTINGS -- last section on the tab, so the jump switch is right
    -- there beside Start/Stop instead of buried in another tab.
    tab:AddSection("Extras")
    tab:AddToggle("CRRecordJumps", {
        Title = "Record Jumps",
        Description = "On: your jumps are recorded and replayed, and air moves fire in the air. Off: jumps are ignored on both sides.",
        Default = true,
        Callback = function(v)
            local on = v and true or false
            HubSt.crRecordJumps = on
            RCfg.RecordJumps    = on
            RCfg.DriveJump      = on
            UI.refresh()
        end,
    })
    tab:AddToggle("CRRunToEnemy", {
        Title = "Run To Enemy",
        Description = "On: if a move cannot reach, close the distance and carry on. Off: that move is skipped instead.",
        Default = true,
        Callback = function(v) RCfg.RunToEnemy = v and true or false end,
    })
    tab:AddToggle("CRAbortIfFar", {
        Title = "Abort If Nobody Near",
        Description = "Ends the combo instead of swinging at empty air when there is no one to hit.",
        Default = true,
        Callback = function(v) RCfg.AbortIfFar = v and true or false end,
    })
    tab:AddToggle("CRDashAim", {
        Title = "Aim Dashes At Enemy",
        Description = "Re-points every recorded dash at whoever you are fighting now, instead of where they used to be.",
        Default = true,
        Callback = function(v) RCfg.DashAim = v and true or false end,
    })
    tab:AddToggle("CRDashBehind", {
        Title = "Dash Behind On Turn",
        Description = "If you curved round them while recording, the replay runs in and turns onto their back mid-dash.",
        Default = true,
        Callback = function(v) RCfg.DashBehind = v and true or false end,
    })
    tab:AddToggle("CRDashSide", {
        Title = "Keep Side Dash Angle",
        Description = "Side and back dashes replay at the angle you recorded them, relative to the enemy. Off: every dash goes straight at them.",
        Default = true,
        Callback = function(v) RCfg.DashSide = v and true or false end,
    })
end

----------------------------------------------------------------------
-- INPUT
----------------------------------------------------------------------
K.track(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode
    if St.HubKeyBlocked and St.HubKeyBlocked(kc) then return end
    if kc == RKeys.record then
        K.safe(R.toggleRecord)
    elseif kc == RKeys.play then
        K.safe(R.playToggle, RSt.slot)   -- same key stops it mid-combo
    elseif kc == RKeys.stop then
        K.safe(R.cancel, "key")
    end
end))

----------------------------------------------------------------------
-- HOUSEKEEPING
--   The facing guard ticks whether or not anything is playing, and a stall
--   watchdog cleans up a thread that died while holding your rotation.
----------------------------------------------------------------------
K.track(LocalPlayer.CharacterAdded:Connect(function()
    RSt.gen = RSt.gen + 1
    RSt.recording, RSt.playing = false, false
    RSt.beat, RSt.stepIndex = 0, 0
    RSt.status = "idle"
    if recConn then pcall(function() recConn:Disconnect() end); recConn = nil end
    E.disarmJumpWatch()
    K.safe(E.disarmDrive)
    recBuffer = nil
    facing.camYaw, facing.overrideUntil, facing.autoOff = nil, 0, false
    lease.open, lease.owner, lease.saved = false, nil, nil
    movementController = nil
    task.wait(0.6)
    K.safe(E.facingRelease)
    UI.refresh()
end))

task.spawn(function()
    while RSt.alive do
        K.safe(E.facingGuard)
        -- The old test needed RSt.beat, so a run that died on its very first
        -- step never beat, was never cleaned up, and left RSt.playing stuck on
        -- -- which then blocked every later record and play. It now falls back
        -- to the start time, so there is no unreachable case.
        if RSt.playing then
            local ref = (RSt.beat > 0) and RSt.beat or (RSt.playStart or 0)
            if ref > 0 and os.clock() - ref > 5.0 then
                K.push("playback thread stalled, cleaned up")
                K.safe(R.cancel, "stalled")
            end
        end
        UI.refresh()
        task.wait(0.2)
    end
end)

----------------------------------------------------------------------
-- BOOT
----------------------------------------------------------------------
R.loadAll()
UI.build()
UI.syncSlots()
UI.refresh()

_G.NH_ComboRec = {
    Version  = "1.0",
    Config   = RCfg,
    State    = RSt,
    Keys     = RKeys,
    record   = function() return R.toggleRecord() end,
    stop     = function() return R.stop() end,
    play     = function(i) return R.play(i) end,
    playToggle = function(i) return R.playToggle(i) end,
    cancel   = function() return R.cancel("api") end,
    rename   = function(n) return R.rename(n) end,
    delete   = function(i) return R.delete(i) end,
    target   = function() return K.acquireTarget() end,
    -- nil argument reads the current setting, true/false sets it
    recordJumps = function(v)
        if v == nil then return K.jumpsOn() end
        HubSt.crRecordJumps = v and true or false
        RCfg.RecordJumps = HubSt.crRecordJumps
        RCfg.DriveJump = HubSt.crRecordJumps
        return HubSt.crRecordJumps
    end,
    _destroy = function()
        RSt.alive = false
        RSt.recording, RSt.playing = false, false
        if recConn then pcall(function() recConn:Disconnect() end); recConn = nil end
        pcall(E.disarmJumpWatch)
        pcall(E.disarmDrive)
        pcall(E.facingRelease)
        pcall(restoreHook)
        K.disconnectAll()
    end,
}

print(string.format("[NH Combo Recorder] ready  |  record %s  |  play %s  |  stop %s",
    keyName(RKeys.record), keyName(RKeys.play), keyName(RKeys.stop)))
print("[NH Combo Recorder] locked on -> that person only. Not locked on -> closest person.")

end)

if not okCR then
    warn("[NH Combo Recorder] load failed: " .. tostring(errCR))
    pcall(function()
        Fluent:Notify({ Title = "Combo Recorder", Content = "Module failed to load, check console.", Duration = 6 })
    end)
end
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
-- Mobile visibility options are intentionally NOT ignored: their clean defaults are
-- false, while an autoload config can restore the user's chosen visible buttons.
-- Linked rows save only the canonical inline IDs; mirrors are updated automatically.
SaveManager:SetIgnoreIndexes({"ATAura","ATLock","ATAutoUltimate","ATAutoSoda","ATInvisibility","ATBindPlayer","ATTarget","ATCombo","ATProtectPlayer","AFRunning","AFTarget","KbInvisMaster","KbRotateLockOnMaster"})
InterfaceManager:SetFolder("NiggaHub")
SaveManager:SetFolder("NiggaHub/cfg")
InterfaceManager:BuildInterfaceSection(Tabs.Settings) 
SaveManager:BuildConfigSection(Tabs.Settings)

local searchBuildOk, searchBuildResult = pcall(function()
    return _G.NH_FeatureSearch.BuildUI()
end)
if not searchBuildOk then
    warn("[NH Search] Build failed: " .. tostring(searchBuildResult))
elseif searchBuildResult ~= true then
    warn("[NH Search] Could not attach the global search bar to Fluent's window.")
end
Window:SelectTab(1)
local autoloadOk,autoloadError=pcall(function() SaveManager:LoadAutoloadConfig() end)
-- SaveManager restores each option in its own task; once they've run, re-apply every
-- bind from what its row shows so the live key can never lag behind the label.
pcall(function() St.KeyBinds.TrackLabel("MenuKeybind", Fluent.Options.MenuKeybind) end)
pcall(function() St.KeyBinds.Refresh() end)
task.defer(function() pcall(function() St.KeyBinds.Refresh() end) end)
getgenv().NH_HubBooting = false
if not autoloadOk then warn("[NH Config] "..tostring(autoloadError)) end
Fluent:Notify({Title="Nigga Hub", Content="Ultimate Edition Loaded.", Duration=5})

-- ============================================================
-- FLOAT BUTTONS & INPUT HANDLING
-- ============================================================
local function createFloatButton(id, text, defX, defY, c1, c2, action, isHoldBtn, iconAsset, anchorMode, immediateOnRelease)
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui")); gui.Name = id; gui.ResetOnSpawn = false; gui.Enabled = false
    -- Render ABOVE in-game effect overlays (e.g. the Black Flash effect ScreenGui,
    -- DisplayOrder ~1000) so the mobile float buttons never get covered/"disappear"
    -- for a few seconds during/after a blackflash chain. Kept just under the green
    -- master toggle dot (99999) so that stays on top.
    gui.DisplayOrder = 99998
    gui.IgnoreGuiInset = true

    local BASE = 60
    local f, s, l, b
    local userMoved = false   -- becomes true once YOU drag this button, so auto-anchor stops fighting you

    -- NATIVE-STYLE: clone the game's OWN mobile "Block" button so EVERY float button shares the
    -- native semi-transparent control art. Icon buttons (Fly / Lock-On) show their image; all the
    -- other buttons show their NAME as text. The clone lives in OUR managed ScreenGui so the
    -- game's Controls.Mobile show/hide pass can never hide/flicker it, and we drive it with the
    -- same robust drag/tap engine below. Falls back to a plain frame if the native button is gone.
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local controls = pg and pg:FindFirstChild("Controls")
        local mob = controls and controls:FindFirstChild("Mobile")
        local jump = mob and mob:FindFirstChild("Jump")
        local src = (jump and jump:FindFirstChild("Block")) or (mob and mob:FindFirstChild("Block"))
        if src then
            local clone = src:Clone()
            clone.Name = "NHBtn"
            clone.AnchorPoint = Vector2.new(0, 0)
            clone.Size = UDim2.fromOffset(BASE, BASE)
            clone.Position = UDim2.fromOffset(defX, defY)
            clone.Visible = true
            clone.Active = true
            pcall(function() clone.AutoButtonColor = false end)
            -- NO highlight box / outline: strip any UIStroke from the native art.
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("UIStroke") then d:Destroy() end
            end
            clone.Parent = gui
            local img = clone:FindFirstChildWhichIsA("ImageLabel")
            if iconAsset then
                if img then
                    img.Image = iconAsset; img.ImageColor3 = Color3.fromRGB(255,255,255); img.ImageTransparency = 0; img.Visible = true
                elseif clone:IsA("ImageButton") then
                    clone.Image = iconAsset; clone.ImageColor3 = Color3.fromRGB(255,255,255)
                end
            else
                -- TEXT button: hide the native icon glyph, but KEEP a visible semi-transparent
                -- rounded backing (same translucent look the icon buttons have) and show the NAME.
                if img then img.Visible = false; img.ImageTransparency = 1 end
                pcall(function() clone.ImageTransparency = 1 end)
                pcall(function() if clone:IsA("TextButton") then clone.Text = "" end end)
                -- Force a consistent translucent button background so the text isn't just floating.
                pcall(function()
                    clone.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                    clone.BackgroundTransparency = 0.35
                end)
                if not clone:FindFirstChildOfClass("UICorner") then
                    -- Full circle (radius = 50% of the square) so text buttons match the round
                    -- Fly / Lock-On look exactly, just with their NAME instead of an icon.
                    Instance.new("UICorner", clone).CornerRadius = UDim.new(1, 0)
                end
                -- NATIVE DETAILING: every Roblox mobile control button has a thin outer rim plus a
                -- smaller inset ring. Re-create that here so text buttons match the Fly / Lock-On
                -- look (which get it from their icon art) instead of being a flat circle.
                local rim = Instance.new("UIStroke")
                rim.Name = "NHRim"
                rim.Color = Color3.fromRGB(255, 255, 255)
                rim.Transparency = 0.5
                rim.Thickness = 1.5
                rim.Parent = clone
                local ring = Instance.new("Frame")
                ring.Name = "NHRing"
                ring.AnchorPoint = Vector2.new(0.5, 0.5)
                ring.Position = UDim2.fromScale(0.5, 0.5)
                ring.Size = UDim2.fromScale(0.74, 0.74)
                ring.BackgroundTransparency = 1
                ring.ZIndex = 2
                ring.Parent = clone
                Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
                local ringStroke = Instance.new("UIStroke", ring)
                ringStroke.Color = Color3.fromRGB(255, 255, 255)
                ringStroke.Transparency = 0.78
                ringStroke.Thickness = 1
                local lbl = Instance.new("TextLabel")
                lbl.Name = "NHLbl"
                lbl.AnchorPoint = Vector2.new(0.5, 0.5)
                lbl.Position = UDim2.fromScale(0.5, 0.5)
                lbl.Size = UDim2.new(1, -8, 1, -8)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = Color3.fromRGB(255,255,255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextScaled = true
                lbl.TextWrapped = true
                lbl.ZIndex = 50
                lbl.Parent = clone
                local cons = Instance.new("UITextSizeConstraint", lbl); cons.MaxTextSize = 14
                l = lbl
            end
            f = clone; b = clone; s = nil
        end
    end)

    if not f then
        f = Instance.new("Frame", gui); f.Size = UDim2.fromOffset(BASE,BASE); f.Position = UDim2.fromOffset(defX, defY); f.BackgroundColor3 = Color3.fromRGB(20,20,26); f.BackgroundTransparency = 0.35; Instance.new("UICorner", f).CornerRadius=UDim.new(1,0)
        local frim = Instance.new("UIStroke", f); frim.Color = Color3.fromRGB(255,255,255); frim.Transparency = 0.5; frim.Thickness = 1.5
        l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,-6,1,-6); l.Position = UDim2.fromScale(0.5,0.5); l.AnchorPoint = Vector2.new(0.5,0.5); l.BackgroundTransparency=1; l.Text = text; l.TextColor3 = Color3.fromRGB(255,255,255); l.Font = Enum.Font.GothamBold; l.TextScaled = true; l.TextWrapped = true
        local consF = Instance.new("UITextSizeConstraint", l); consF.MaxTextSize = 14
        b = Instance.new("TextButton", f); b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency=1; b.Text = ""
        s = nil
    end

    f.Active = true
    b.Active = true

    -- Register for the Settings > "Mobile Button Size" resize slider.
    table.insert(_G.NH_floatBtns, {f = f, base = BASE})
    if _G.NH_btnScale and _G.NH_btnScale ~= 1 then
        local sz = math.floor(BASE * _G.NH_btnScale); f.Size = UDim2.fromOffset(sz, sz)
    end

    -- AUTO-ANCHOR: Fly sits just above the Special button, Lock-On just above the Jump button --
    -- placed right where the reference script keeps them (low-right, by the native controls). Runs
    -- once the native controls are ready and never overrides a button you've dragged yourself.
    if anchorMode then
        task.spawn(function()
            for _ = 1, 60 do
                if userMoved then return end
                local done = false
                pcall(function()
                    local pg = LocalPlayer:FindFirstChild("PlayerGui")
                    local jmp = pg and pg:FindFirstChild("Controls") and pg.Controls:FindFirstChild("Mobile") and pg.Controls.Mobile:FindFirstChild("Jump")
                    -- Place FLY just ABOVE the Special button and LOCK-ON just above the Jump/Block
                    -- button, with a small gap -- right where the reference script sits them. We no
                    -- longer multiply by block-heights (that math shoved Fly off the top of screen).
                    local target
                    if anchorMode == "fly" then
                        target = jmp and (jmp:FindFirstChild("Special") or jmp:FindFirstChild("Block"))
                    else
                        target = (jmp and jmp:FindFirstChild("Block")) or jmp
                    end
                    if target and target.AbsoluteSize.X > 0 and target.AbsolutePosition.Y > 0 then
                        local ap, asz = target.AbsolutePosition, target.AbsoluteSize
                        local bs = f.AbsoluteSize
                        local bw = (bs.X > 0 and bs.X or BASE)
                        local bh = (bs.Y > 0 and bs.Y or BASE)
                        local gap = math.floor(bh * 0.1)  -- small gap: keeps Fly just a tad above Special (lowered per request)
                        -- centre horizontally on the target button, sit just above it
                        local x = ap.X + (asz.X - bw) * 0.5
                        local y = ap.Y - bh - gap
                        if anchorMode ~= "fly" then
                            -- Lock-On tucks one slot to the LEFT so it never overlaps Fly
                            x = ap.X + (asz.X - bw) * 0.5 - (bw + gap)
                        end
                        local vpc = Camera.ViewportSize
                        x = math.clamp(x, 4, math.max(4, vpc.X - bw - 4))
                        y = math.clamp(y, 4, math.max(4, vpc.Y - bh - 4))
                        if not userMoved then f.Position = UDim2.fromOffset(math.floor(x), math.floor(y)) end
                        done = true
                    end
                end)
                if done then return end
                task.wait(0.1)
            end
        end)
    end

    -- No highlight box / outline by request: tap-and-tap-again buttons show no colored state.
    -- Kept as a no-op so the drag engine's existing applyColor() calls stay valid.
    local function applyColor(active)
    end

    local drag = false
    local moved = false
    local dragOr = Vector2.zero
    local frOr = Vector2.zero
    local activeInput = nil    -- the exact InputObject driving this button
    local holdActive = false   -- whether action(true) is currently engaged (hold buttons)
    local DRAG_THRESHOLD = 8
    -- SMOOTH DRAG: the finger sets a target offset and a RenderStepped loop eases the
    -- frame toward it, so dragging glides instead of stepping between touch samples.
    local dragTarget = nil
    local dragRender = nil
    local function stopDragRender()
        if dragRender then dragRender:Disconnect(); dragRender = nil end
    end

    local function releaseHold()
        if holdActive then
            holdActive = false
            applyColor(false)
            task.spawn(function() action(false) end)
        end
    end

    -- Idempotent finish: safe to call from the button's own event OR the global watchdog.
    local function finishInput()
        if not drag and not holdActive and activeInput == nil then return end
        local wasMoved = moved
        drag = false
        activeInput = nil
        stopDragRender()
        if dragTarget then f.Position = UDim2.fromOffset(dragTarget.X, dragTarget.Y); dragTarget = nil end
        if isHoldBtn then
            releaseHold()
        else
            if not wasMoved then
                if immediateOnRelease then
                    local ok,st=pcall(action)
                    if ok and st~=nil then applyColor(st and true or false)end
                else
                    task.spawn(function()
                        local st=action()
                        if st~=nil then applyColor(st and true or false)end
                    end)
                end
            end
        end
        moved = false
    end

    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag = true
            moved = false
            activeInput = i
            dragOr = Vector2.new(i.Position.X, i.Position.Y)
            frOr = Vector2.new(f.Position.X.Offset, f.Position.Y.Offset)
            stopDragRender()
            dragTarget = frOr
            dragRender = RunService.RenderStepped:Connect(function()
                if not drag or not dragTarget then return end
                local cur2 = Vector2.new(f.Position.X.Offset, f.Position.Y.Offset)
                local nxt = cur2:Lerp(dragTarget, 0.5)
                f.Position = UDim2.fromOffset(nxt.X, nxt.Y)
            end)
            if isHoldBtn then
                holdActive = true
                applyColor(true)
                task.spawn(function() action(true) end)
            end
        end
    end)

    -- Dragging now works for ALL buttons (tap and hold). Hold buttons stay
    -- active while you slide them around; tap buttons won't fire if dragged.
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if _G.NH_btnLocked then return end
        if i ~= activeInput and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local cur = Vector2.new(i.Position.X, i.Position.Y)
            if (cur - dragOr).Magnitude > DRAG_THRESHOLD then moved = true; userMoved = true end
            local nx, ny = frOr.X + (cur.X - dragOr.X), frOr.Y + (cur.Y - dragOr.Y)
            -- clamp inside the screen so a button can never be flung to a "random place" / off-screen
            local vpc = Camera.ViewportSize
            nx = math.clamp(nx, 0, math.max(0, vpc.X - f.AbsoluteSize.X))
            ny = math.clamp(ny, 0, math.max(0, vpc.Y - f.AbsoluteSize.Y))
            dragTarget = Vector2.new(nx, ny)
        end
    end)

    b.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            finishInput()
        end
    end)

    -- STUCK-KEY SAFETY NET: if the finger slides off the button (or the input is
    -- otherwise lost), the button's own InputEnded may never fire. The global
    -- UserInputService.InputEnded always fires for the same InputObject, so we
    -- release here too. finishInput() is idempotent, so there is no double-fire.
    UserInputService.InputEnded:Connect(function(i)
        if activeInput ~= nil and i == activeInput then
            finishInput()
        end
    end)

    return gui
end

local vp = Camera.ViewportSize

if mobile then
    -- 1. Main feature buttons. Each one is HIDDEN until its feature is toggled ON
    --    (from the menu/green UI dot). When the feature turns off, its button hides.
    --    EMOTE is an instant tap-to-fire button (no on/off); it shows when you enable it in Settings.
    local flyGui = createFloatButton("FlyBtn", "FLY", vp.X-80, vp.Y-160, Color3.fromRGB(30,100,30), Color3.fromRGB(80,255,80), function()
        -- FLY starts/stops the actual flight MOTION. Your UP / DOWN / BOOST control buttons
        -- only show while you are ACTIVELY flying (St.flyActive) -- press FLY to stop and they
        -- hide; press FLY again to resume flying and they reappear.
        if not St.flyToggleOn then
            if Fluent.Options.TglFly then Fluent.Options.TglFly:SetValue(true) end
            return true
        end
        if St.flyActive then
            St.flyActive = false; disableFly(); return false
        else
            St.flyActive = true; enableFly(); return true
        end
    end, false, "rbxassetid://6684647765", "fly")

    local bfGui = createFloatButton("BFBtn", "BLACK FLASH", vp.X-160, vp.Y-160, Color3.fromRGB(160,80,255), Color3.fromRGB(255,200,50), function()
        if St.bfEnabled then bfTriggerDash() return true end return false
    end, false)

    local bsGui = createFloatButton("BsBtn", "BACKSTAB", vp.X-240, vp.Y-240, Color3.fromRGB(160,40,40), Color3.fromRGB(255,80,80), function()
        -- Mobile UI button tap: only if harutaBackstabEnabled. Check char validity and notify if wrong.
        if not St.harutaBackstabEnabled then return false end
        local ch = LocalPlayer.Character
        local mv = ch and ch:GetAttribute("Moveset")
        if mv ~= "Haruta" then
            notify("Haruta Backstab", "Need Haruta (Lucky Coward) equipped.", 3)
            return false
        end
        local assets = ch:FindFirstChild("SetAssets")
        if not (assets and assets:FindFirstChild("HarutaSword")) then
            notify("Haruta Backstab", "Need sword in hand to backstab.", 3)
            return false
        end
        if _G.NH_triggerHarutaBackstab then _G.NH_triggerHarutaBackstab() end
        return true
    end, false)

    local bfChainGui = createFloatButton("BFChainBtn", "BF CHAIN", vp.X-320, vp.Y-240, Color3.fromRGB(100,40,160), Color3.fromRGB(200,80,255), function()
        -- The separate "show" setting controls visibility only; it must not
        -- disable a button surfaced automatically by the actual BF toggle.
        if not St.bfEnabled then
            notify("BF Chain", "Enable Auto Black Flash Chain first.", 3)
            return false
        end
        bfTriggerDash()
        return true
    end, false)

    local lockGui = createFloatButton("LockBtn", "LOCK ON", vp.X-80, vp.Y-240, Color3.fromRGB(30,80,220), Color3.fromRGB(80,200,255), function()
        -- MOBILE LOCK-ON (aim + press, 100% drag-proof):
        --   * Point your CAMERA at an enemy (put them near the middle of your screen).
        --   * Press LOCK ON -> locks whoever is nearest your screen centre.
        --   * Aim at a different enemy + press -> switches the lock onto them.
        --   * Press again while aiming at your CURRENT target (or at empty sky) -> unlocks.
        -- Raw screen taps NEVER lock anymore, so dragging the camera can't grab a random player.
        if not St.lockOnEnabled then notify("Lock-On", "Enable Lock-On in the menu first.", 2); return false end
        local mc = LocalPlayer.Character
        local myHRP = mc and mc:FindFirstChild("HumanoidRootPart")
        local aim = getTargetNearestScreenCenter(myHRP)
        if aim then
            if St.lockOnTarget and St.lockOnTarget.Char and St.lockOnTarget.Char == aim.Char then
                -- aiming at the one you're already locked to -> release
                St.lockOnTarget = nil
                St.lockOnArmed = false
                RunService:UnbindFromRenderStep("HubLockOnSystem")
                RunService:UnbindFromRenderStep("HubLockOnBody")
                local h = mc and mc:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate = true end
                clearLockOnESP()
                notify("Lock-On", "Unlocked.", 2)
                return false
            end
            St.lockOnTarget = aim
            St.lockOnArmed = false
            enableLockOn()
            notify("Lock-On", "Locked onto " .. aim.name .. ". Aim + press to switch.", 2)
            return true
        end
        -- nothing under your aim near the centre of the screen
        if St.lockOnTarget then
            St.lockOnTarget = nil
            St.lockOnArmed = false
            RunService:UnbindFromRenderStep("HubLockOnSystem")
            RunService:UnbindFromRenderStep("HubLockOnBody")
            local h = mc and mc:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate = true end
            clearLockOnESP()
            notify("Lock-On", "Unlocked.", 2)
            return false
        end
        notify("Lock-On", "Aim at an enemy (centre of screen) and press LOCK ON.", 2)
        return false
    end, false, "rbxassetid://11738355467", "lock")

    -- SOLO BLOCK: enable, then lock onto someone with LOCK ON to make auto-block
    -- serve ONLY them (cyan marker for 3s, then silent). Press again to disable
    -- and clear the solo target so you can re-choose.
    local soloBlockGui = createFloatButton("SoloBlockBtn", "SOLO BLK", vp.X-320, vp.Y-160, Color3.fromRGB(0, 110, 150), Color3.fromRGB(90, 220, 255), function()
        if not St.autoBlockSoloEnabled then
            if Fluent.Options.TglAutoBlockSolo then Fluent.Options.TglAutoBlockSolo:SetValue(true) end
            notify("Solo Block", "Enabled. Lock onto someone (LOCK ON) to pick your solo target.", 4)
            return true
        end
        if Fluent.Options.TglAutoBlockSolo then Fluent.Options.TglAutoBlockSolo:SetValue(false) end
        notify("Solo Block", "Disabled. Target cleared.", 2)
        return false
    end, false)
    -- Active state: cyan glow while a live solo target is assigned.
    task.spawn(function()
        while true do
            task.wait(0.15)
            pcall(function()
                local frame = soloBlockGui:FindFirstChild("NHBtn") or soloBlockGui:FindFirstChildWhichIsA("Frame") or soloBlockGui:FindFirstChildWhichIsA("ImageButton") or soloBlockGui:FindFirstChildWhichIsA("TextButton")
                if frame then
                    local solo = _G.NH_AutoBlockSolo
                    if St.autoBlockSoloEnabled and solo and solo.IsActive() then
                        frame.BackgroundColor3 = Color3.fromRGB(0, 170, 220)
                        frame.BackgroundTransparency = 0.1
                    else
                        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                        frame.BackgroundTransparency = 0.35
                    end
                end
            end)
        end
    end)

    -- Mobile equivalent of the PC Backdash key. Using createFloatButton gives it
    -- the same native clone, rim, inset ring, scaling, and drag behavior.
    local dashBehindGui = createFloatButton("DashBehindBtn", "BACKDASH", vp.X-320, vp.Y-320, Color3.fromRGB(120,70,210), Color3.fromRGB(205,155,255), function()
        if not St.dashBehindTargetEnabled then
            notify("Auto Backdash", "Enable Auto Backdash in Combat first.", 2)
            return false
        end
        if _G.NH_triggerDashBehindTarget then
            return _G.NH_triggerDashBehindTarget() and true or false
        end
        return false
    end, false)

    local sweepGui = createFloatButton("SweepBtn", "SWEEP", vp.X-160, vp.Y-240, Color3.fromRGB(40,160,90), Color3.fromRGB(90,255,150), function()
        if Fluent.Options.TglSweep then Fluent.Options.TglSweep:SetValue(not Fluent.Options.TglSweep.Value); return Fluent.Options.TglSweep.Value end return false
    end, false)

    local huntGui = createFloatButton("HuntBtn", "HUNT", vp.X-160, vp.Y-320, Color3.fromRGB(200,40,40), Color3.fromRGB(40,200,40), function()
        if St.huntRunning then
            St.huntRunning = false
            St.acBypassHunting = false
            notify("Hunt", "Stopped.", 3)
            return false
        end
        task.spawn(runHunt)
        return true
    end, false)
    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(function()
                local frame = huntGui:FindFirstChild("NHBtn") or huntGui:FindFirstChildWhichIsA("Frame") or huntGui:FindFirstChildWhichIsA("ImageButton") or huntGui:FindFirstChildWhichIsA("TextButton")
                if frame then
                    if St.huntRunning then
                        frame.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
                        frame.BackgroundTransparency = 0.25
                    else
                        frame.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                        frame.BackgroundTransparency = 0.25
                    end
                end
            end)
        end
    end)

    local yonkGui = createFloatButton("YonkBtn", "YONK", vp.X-240, vp.Y-320, Color3.fromRGB(200,80,200), Color3.fromRGB(255,150,255), function()
        yonkToggle(); return St.yonkEnabled
    end, false)

    local emoteGui = createFloatButton("EmoteBtn", "EMOTE", vp.X-160, vp.Y-400, Color3.fromRGB(60,160,200), Color3.fromRGB(120,220,255), function()
        fireSelectedEmote(); return false
    end, false)

    -- BOOST is a flight control but behaves like a NORMAL main button: it shows
    -- whenever Fly is enabled (same native transparent style) and is hideable via
    -- the "Show Boost Button" toggle. It is independent of the "Show Up / Down" toggle.
    local boostGui = createFloatButton("FlyBoostBtn", "BOOST", vp.X-240, vp.Y-160, Color3.fromRGB(200,50,50), Color3.fromRGB(255,100,100), function(state) flyKeys.Boost = state end, true)

    local crRecGui = createFloatButton("CRRecBtn", "REC", vp.X-240, vp.Y-400, Color3.fromRGB(150,40,40), Color3.fromRGB(255,90,90), function()
        local CR = _G.NH_ComboRec
        if not CR then notify("Combo Recorder", "Module not loaded.", 2); return false end
        CR.record()
        return (CR.State and CR.State.recording) or false
    end, false)

    local crPlayGui = createFloatButton("CRPlayBtn", "AUTO COMBO", vp.X-320, vp.Y-400, Color3.fromRGB(40,120,160), Color3.fromRGB(90,210,255), function()
        local CR = _G.NH_ComboRec
        if not CR then notify("Combo Recorder", "Module not loaded.", 2); return false end
        CR.playToggle()
        return (CR.State and CR.State.playing) or false
    end, false, nil, nil, true)

    for _, g in ipairs({flyGui, bfGui, bsGui, bfChainGui, lockGui, soloBlockGui, dashBehindGui, sweepGui, huntGui, yonkGui, emoteGui, boostGui, crRecGui, crPlayGui}) do
        table.insert(_G.mainFloatGuis, g)
    end

    -- AUTO VISIBILITY. Enabling a feature is now enough to surface its mobile
    -- button. Its manual-pin switch can still show it while the feature is off.
    local function manualOn(name)
        return (_G.NH_btnManual and _G.NH_btnManual[name]) and true or false
    end
    local featureVisible = {
        -- The recorder pair also waits for the module to finish loading, otherwise
        -- the button would be tappable before there is anything behind it.
        {gui = crRecGui,  on = function()
            local cr = _G.NH_ComboRec
            return cr ~= nil and (manualOn("CRRecBtn") or (cr.State and cr.State.recording == true))
        end},
        {gui = crPlayGui, on = function()
            local cr = _G.NH_ComboRec
            return cr ~= nil and (manualOn("CRPlayBtn") or (cr.State and cr.State.playing == true))
        end},
        {gui = flyGui,    on = function() return manualOn("FlyBtn") or St.flyToggleOn == true end},
        {gui = boostGui,  on = function()
            return St.flyActive == true or (manualOn("FlyBoostBtn") and _G.NH_boostVisible ~= false)
        end},
        {gui = bfGui,     on = function() return manualOn("BFBtn") or St.bfEnabled == true end},
        {gui = lockGui,   on = function() return manualOn("LockBtn") or St.lockOnEnabled == true end},
        {gui = soloBlockGui, on = function() return manualOn("SoloBlockBtn") or St.autoBlockSoloEnabled == true end},
        {gui = dashBehindGui, on = function()
            return manualOn("DashBehindBtn") or St.dashBehindTargetEnabled == true
        end},
        {gui = sweepGui,  on = function() return manualOn("SweepBtn") or St.sweepActive == true end},
        {gui = huntGui,   on = function() return manualOn("HuntBtn") or St.huntRunning == true end},
        {gui = yonkGui,   on = function() return manualOn("YonkBtn") or St.yonkEnabled == true end},
        {gui = bsGui,      on = function()
            return manualOn("BsBtn") or St.harutaBsBtnEnabled == true or St.harutaBackstabEnabled == true
        end},
        {gui = bfChainGui, on = function()
            return manualOn("BFChainBtn") or St.bfChainBtnEnabled == true or St.bfEnabled == true
        end},
        {gui = emoteGui,   on = function() return _G.mainOverlayMaster == true end},
    }
    RunService.Heartbeat:Connect(function()
        for _, e in ipairs(featureVisible) do
            if e.gui and e.gui.Parent then
                local want = e.on() and true or false
                if e.gui.Enabled ~= want then e.gui.Enabled = want end
            end
        end
        -- Active flight always gets its controls without a second menu toggle.
        local udWant = (St.flyActive or (St.flyToggleOn and _G.NH_upDownVisible)) and true or false
        for _, g in ipairs(_G.flyFloatGuis) do
            if g and g.Parent and g.Enabled ~= udWant then g.Enabled = udWant end
        end
    end)

    -- 2. Fly Controls Overlays (Up/Down)
    table.insert(_G.flyFloatGuis, createFloatButton("FlyUpBtn", "UP", vp.X-80, vp.Y-320, Color3.fromRGB(30,150,150), Color3.fromRGB(80,255,255), function(state) flyKeys.Up = state end, true))
    -- moved up from vp.Y-80 (it was sitting at the very bottom edge / off-screen on
    -- phones) to sit right above the UP button in the same right-hand column.
    table.insert(_G.flyFloatGuis, createFloatButton("FlyDownBtn", "DOWN", vp.X-80, vp.Y-400, Color3.fromRGB(150,80,30), Color3.fromRGB(255,150,80), function(state) flyKeys.Down = state end, true))

    _G.mainOverlayMaster = false
    _G.ToggleFlyControls(false)

    -- PATCH P8: fill only the missing keybind equivalents. Keep ALL pre-existing
    -- buttons above unchanged, including their native art, defaults and actions.
    do
        -- Extend the existing 80px grid to the left. If a preferred slot is off
        -- screen/occupied (portrait or a larger saved scale), find another free
        -- grid slot for the NEW button only. Never reposition an existing control.
        local function freeSlot(preferredX, preferredY)
            local size = math.floor(60 * (_G.NH_btnScale or 1))
            local maxX, maxY = math.max(4, vp.X - size - 4), math.max(4, vp.Y - size - 4)
            local function vacant(x, y)
                for _, entry in ipairs(_G.NH_floatBtns) do
                    local frame = entry.f
                    if frame and frame.Parent then
                        local p, sz = frame.Position, frame.Size
                        if x < p.X.Offset + sz.X.Offset + 8 and x + size + 8 > p.X.Offset
                            and y < p.Y.Offset + sz.Y.Offset + 8 and y + size + 8 > p.Y.Offset then
                            return false
                        end
                    end
                end
                return true
            end
            local x, y = math.clamp(preferredX, 4, maxX), math.clamp(preferredY, 4, maxY)
            if vacant(x, y) then return x, y end
            local step = math.max(80, size + 8)
            local columns, rows = math.ceil((vp.X - 4) / step), math.ceil((vp.Y - 4) / step)
            for pass = 1, 2 do
                local first, last = pass == 1 and 5 or 1, pass == 1 and columns or math.min(4, columns)
                for column = first, last do
                    for row = 2, rows do
                        local cx = math.clamp(vp.X - column * step, 4, maxX)
                        local cy = math.clamp(vp.Y - row * step, 4, maxY)
                        if cx >= 4 and cy >= 4 and cx <= maxX and cy <= maxY and vacant(cx, cy) then
                            return cx, cy
                        end
                    end
                end
            end
            -- Use the lowest grid row only when the higher rows are full.
            -- This keeps compact screens from stacking new controls on old ones.
            for column = columns, 1, -1 do
                local cx = math.clamp(vp.X - column * step, 4, maxX)
                local cy = math.clamp(vp.Y - step, 4, maxY)
                if vacant(cx, cy) then return cx, cy end
            end
            -- Very small screens may have no free grid slot. Keep the new button
            -- in bounds; the standard drag/size controls can still reposition it.
            return x, y
        end
        local function addMissing(id, text, column, row, action, ready)
            local x, y = freeSlot(vp.X - column * 80, vp.Y - row * 80)
            local gui = createFloatButton(id, text, x, y,
                Color3.fromRGB(60, 100, 160), Color3.fromRGB(120, 200, 255), action, false)
            table.insert(_G.mainFloatGuis, gui)
            table.insert(featureVisible, {gui = gui, on = function()
                return manualOn(id) and (ready == nil or ready())
            end})
        end
        addMissing("InvisBtn", "INVIS", 5, 2, function()
            return St.ToggleKeybinds.Toggle("TglInvisNoclip")
        end)
        addMissing("RotateLockOnBtn", "ROTATE", 5, 3, function()
            return St.ToggleKeybinds.Toggle("TglRotateLockOn")
        end)
        addMissing("AutoBlockBtn", "AUTO BLOCK", 5, 4, function()
            return St.ToggleKeybinds.Toggle("TglAutoBlockC")
        end)
        addMissing("VoidBtn", "VOID / RESET", 5, 5, function()
            forceReset() -- exactly the existing V-key reset, NOT Todo Void
            return false
        end)
        addMissing("StopSweepBtn", "STOP SWEEP", 6, 2, function()
            if Fluent.Options.TglSweep then Fluent.Options.TglSweep:SetValue(false) end
            return false
        end)
        addMissing("CRStopBtn", "COMBO STOP", 6, 3, function()
            local cr = _G.NH_ComboRec
            if not cr then notify("Combo Recorder", "Module not loaded.", 2); return false end
            cr.cancel() -- exactly the existing Backspace panic-stop path
            return false
        end, function() return _G.NH_ComboRec ~= nil end)
    end
    -- Mobile UI Toggle (Green Dot)
    local uiToggleGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    uiToggleGui.Name = "FluentUIToggleDot"
    uiToggleGui.ResetOnSpawn = false
    uiToggleGui.DisplayOrder = 99999

    local dotFrame = Instance.new("Frame", uiToggleGui)
    dotFrame.Size = UDim2.fromOffset(45, 45)
    dotFrame.Position = UDim2.fromOffset(vp.X / 2 - 22, 10)
    dotFrame.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    dotFrame.Active = true
    
    local dotCorner = Instance.new("UICorner", dotFrame)
    dotCorner.CornerRadius = UDim.new(1, 0)
    
    local dotStroke = Instance.new("UIStroke", dotFrame)
    dotStroke.Color = Color3.fromRGB(20, 100, 20)
    dotStroke.Thickness = 2.5
    
    local dotBtn = Instance.new("TextButton", dotFrame)
    dotBtn.Size = UDim2.new(1, 0, 1, 0)
    dotBtn.BackgroundTransparency = 1
    dotBtn.Text = "UI"
    dotBtn.TextColor3 = Color3.fromRGB(0, 50, 0)
    dotBtn.Font = Enum.Font.GothamBold
    dotBtn.TextSize = 14
    dotBtn.Active = true
    
    local dotDrag, dotDragOr, dotFrOr, dotMoved = false, Vector2.zero, Vector2.zero, false
    local dotPressT = 0
    local dotActiveInput = nil -- the exact finger/mouse dragging the dot (ignore other touches)
    -- The green dot shares the exact manager used by PC Ctrl and the native
    -- minimize button, so all three paths can always hide and reopen the Root.
    local function toggleHub()
        HubUI.Toggle()
    end
    dotBtn.InputBegan:Connect(function(i) 
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
            dotDrag = true; dotMoved = false; dotActiveInput = i; dotDragOr = i.Position; dotFrOr = dotFrame.Position; dotPressT = os.clock() 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if not dotDrag then return end
        -- only the finger/mouse that grabbed the dot moves it (no multi-touch teleporting)
        if i ~= dotActiveInput and i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then 
            local _ddx, _ddy = (i.Position.X - dotDragOr.X), (i.Position.Y - dotDragOr.Y)
            if (_ddx*_ddx + _ddy*_ddy) > 100 then dotMoved = true end
            local nx, ny = dotFrOr.X.Offset + _ddx, dotFrOr.Y.Offset + _ddy
            local vpc = Camera.ViewportSize
            nx = math.clamp(nx, 0, math.max(0, vpc.X - dotFrame.AbsoluteSize.X))
            ny = math.clamp(ny, 0, math.max(0, vpc.Y - dotFrame.AbsoluteSize.Y))
            dotFrame.Position = UDim2.fromOffset(nx, ny) 
        end 
    end)
    dotBtn.InputEnded:Connect(function(i) 
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
            dotDrag = false; dotActiveInput = nil
            -- TAP (not a drag) => toggle the hub. We treat it as a tap when the finger
            -- barely moved OR the press was quick. The old "any movement = drag" check made
            -- tiny-finger-wobble taps do nothing, which is a big reason the dot felt dead.
            if (not dotMoved) or (os.clock() - dotPressT) < 0.25 then
                toggleHub()
            end
        end 
    end)
end

local function getTargetFromScreen(position2D)
    local closest = nil
    -- TIGHT tap radius: you must tap ON (or right next to) an enemy on screen to lock
    -- them. The old code used a 400px cap which on a phone is most of the screen, so
    -- tapping anywhere grabbed the nearest enemy = the "locks onto random people" bug.
    local minPixelDist = 70
    local maxWorldDist = Cfg.LockOn.MaxDistance
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, t in ipairs(getValidTargets(myHRP)) do
        if t.Core and t.Humanoid.Health > 0 then
            local worldDist = (t.Core.Position - myHRP.Position).Magnitude
            if worldDist <= maxWorldDist then
                local screenPos, onScreen = Camera:WorldToViewportPoint(t.Core.Position)
                if onScreen then
                    local pixelDist = (Vector2.new(screenPos.X, screenPos.Y) - position2D).Magnitude
                    if pixelDist < minPixelDist then
                        minPixelDist = pixelDist
                        closest = t
                    end
                end
            end
        end
    end
    return closest
end

local function getTargetUnderMouse(mouse)
    if not (mouse and mouse.Target) then return nil end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    for _, t in ipairs(getValidTargets(myHRP)) do
        if t.Char and mouse.Target:IsDescendantOf(t.Char) and t.Humanoid and t.Humanoid.Health > 0 then
            return t
        end
    end
    return nil
end

-- Shared lock-on click resolution so PC and mobile behave identically:
--   * click/tap an enemy you are NOT locked onto   -> lock (or switch) onto them
--   * click/tap the SAME enemy you ARE locked onto -> release the lock (disable)
-- Returns "locked", "unlocked", or "none".
local function resolveLockClick(clickedTarget)
    if not clickedTarget then return "none" end
    if St.lockOnTarget and St.lockOnTarget.Char and St.lockOnTarget.Char == clickedTarget.Char then
        -- same target -> toggle the lock OFF (system stays enabled / in standby)
        St.lockOnTarget = nil
        RunService:UnbindFromRenderStep("HubLockOnSystem")
        RunService:UnbindFromRenderStep("HubLockOnBody")
        local mc = LocalPlayer.Character
        local h = mc and mc:FindFirstChildOfClass("Humanoid")
        if h then h.AutoRotate = true end
        clearLockOnESP()
        notify("Lock-On", "Unlocked from " .. clickedTarget.name .. ".", 2)
        return "unlocked"
    end
    -- different / new target -> lock or switch onto them
    St.lockOnTarget = clickedTarget
    enableLockOn()
    notify("Lock-On", "Locked onto " .. clickedTarget.name .. ".", 2)
    return "locked"
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard and St.HubKeyBlocked(inp.KeyCode) then return end
    
    if St.lockOnEnabled then
        local isMobileTouch = (mobile and inp.UserInputType == Enum.UserInputType.Touch)
        local isPCKeybind = (not mobile and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Keys.lockOnKey)

        if isMobileTouch then
            -- MOBILE: locking is handled ENTIRELY by the on-screen LOCK ON button (aim your
            -- camera at an enemy + press). Raw screen taps deliberately do NOTHING here, so
            -- dragging / rotating the camera can never lock onto a random player. This is the
            -- fix for the old "tap anywhere and it locks onto someone" behaviour.
        elseif isPCKeybind then
            -- PC: press the lock-on keybind while hovering an enemy to lock.
            --   * press it on a different enemy -> switch the lock to them
            --   * press it on the locked enemy  -> release the lock
            --   * press it with nothing hovered -> release any current lock
            local mouse = LocalPlayer:GetMouse()
            local clickedTarget = getTargetUnderMouse(mouse) or getTargetFromScreen(Vector2.new(mouse.X, mouse.Y))
            local res = resolveLockClick(clickedTarget)
            if res == "none" then
                if St.lockOnTarget then
                    St.lockOnTarget = nil
                    RunService:UnbindFromRenderStep("HubLockOnSystem")
                    RunService:UnbindFromRenderStep("HubLockOnBody")
                    local mc = LocalPlayer.Character
                    local h = mc and mc:FindFirstChildOfClass("Humanoid")
                    if h then h.AutoRotate = true end
                    clearLockOnESP()
                    notify("Lock-On", "Lock released.", 2)
                else
                    notify("Lock-On", "No target under your cursor.", 2)
                end
            end
        end
    end

    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = inp.KeyCode
    
    if k == Keys.sweepKey then if Fluent.Options.TglSweep then Fluent.Options.TglSweep:SetValue(not Fluent.Options.TglSweep.Value) end
    elseif k == Keys.huntKey then runHunt()
    elseif k == Keys.bfKey then if St.bfEnabled then bfTriggerDash() end
    elseif k == Keys.dashBehindTargetKey then
        if St.dashBehindTargetEnabled and _G.NH_triggerDashBehindTarget then
            _G.NH_triggerDashBehindTarget()
        end
    elseif k == Keys.flyKey then if Fluent.Options.TglFly then Fluent.Options.TglFly:SetValue(not Fluent.Options.TglFly.Value) end
    elseif k == Keys.yonkKey then yonkToggle()
    elseif k == Keys.emoteKey then fireSelectedEmote()
    elseif k == Keys.harutaBsKey then
        -- PC key 2: only fires Haruta Backstab if harutaBackstabEnabled AND we are Haruta.
        -- If the feature is off OR we're not Haruta, let the game handle key 2 normally (no notification).
        if St.harutaBackstabEnabled and _G.NH_triggerHarutaBackstab then
            local ch = LocalPlayer.Character
            local mv = ch and ch:GetAttribute("Moveset")
            if mv == "Haruta" then
                task.spawn(_G.NH_triggerHarutaBackstab)
            end
            -- if not Haruta, do nothing - game gets the key input normally
        end
    elseif k == Keys.bfChainKey then
        -- PC key 3: let Auto Earthquake own Mahoraga's Earthquake slot. Without this
        -- guard the BF chain started at the same time and could cancel/interfere with it.
        local eq = rawget(_G, "NH_AutoEarthquake")
        local earthquakeOwnsSlot = St.autoEarthquakeEnabled
            and type(eq) == "table" and type(eq.IsEarthquakeSlot) == "function"
            and eq.IsEarthquakeSlot(LocalPlayer.Character, 3)
        if St.bfEnabled and not earthquakeOwnsSlot
            and not St.bfSyntheticInput
            and not (St.bfIsSyntheticKey and St.bfIsSyntheticKey(k)) then bfTriggerDash() end
    elseif k == Keys.voidKey then forceReset()
    elseif k == Keys.stopKey then if Fluent.Options.TglSweep then Fluent.Options.TglSweep:SetValue(false) end end
    
    if k==Enum.KeyCode.W then flyKeys.W=true 
    elseif k==Enum.KeyCode.A then flyKeys.A=true 
    elseif k==Enum.KeyCode.S then flyKeys.S=true 
    elseif k==Enum.KeyCode.D then flyKeys.D=true 
    elseif k==Enum.KeyCode.Space then flyKeys.Up=true 
    elseif k==Enum.KeyCode.LeftControl then flyKeys.Down=true 
    elseif k==Enum.KeyCode.LeftShift then flyKeys.Boost=true end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = inp.KeyCode
    if k==Enum.KeyCode.W then flyKeys.W=false 
    elseif k==Enum.KeyCode.A then flyKeys.A=false 
    elseif k==Enum.KeyCode.S then flyKeys.S=false 
    elseif k==Enum.KeyCode.D then flyKeys.D=false 
    elseif k==Enum.KeyCode.Space then flyKeys.Up=false 
    elseif k==Enum.KeyCode.LeftControl then flyKeys.Down=false 
    elseif k==Enum.KeyCode.LeftShift then flyKeys.Boost=false end
end)

    pcall(function() _G.NH_Window = Window end)
end

local jjsOk = pcall(jjsRun)
if not jjsOk then
	warn(jjs.failed and "E605" or "E604")
end

pcall(function()
	VUniverse.Jjs = { Ready = jjsOk == true, Vendor = not jjs.failed }
end)

do
	pcall(function()
		local tab = UI.Window:MakeTab({ Name = "咒术", Icon = "zap" })
		if not tab then return end
		tab:AddParagraph({
			Title = "脚本状态",
			Content = jjsOk
				and "脚本已加载，使用它自带的窗口（Ctrl 显示或隐藏）。"
				or "脚本加载失败，故障码见下方说明。",
		})
		if not jjsOk then
			tab:AddParagraph({
				Title = "故障码",
				Content = jjs.failed and "E605 依赖下载失败（Fluent / SaveManager / InterfaceManager）"
					or "E604 脚本运行时报错",
			})
		end
		tab:AddButton({
			Name = "显示 / 隐藏脚本窗口",
			Callback = function()
				pcall(function()
					local window = rawget(_G, "NH_Window")
					local root = window and window.Root
					if root then root.Visible = not root.Visible end
				end)
			end,
		})
	end)
end
