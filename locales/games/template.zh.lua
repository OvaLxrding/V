-- Game pack: games/template.lua  (slug: template)
-- Loaded only when that game module is active and the interface is Chinese.
-- Copy this file to locales/games/<slug>.zh.lua for every new game.
--
-- Two sections, pick whichever fits:
--   map  - key is the exact English string the module writes; the render hook
--          matches it automatically, so the module needs no code change.
--   keys - semantic keys for text built at runtime (numbers, concatenation),
--          read through t("key") / I18N:T("key").
--
-- Save as UTF-8 without BOM.

return {
	name = "Template",

	map = {
		-- tab / section (AddSection upper-cases its title)
		["Movement"] = "移动",
		["MOVEMENT"] = "移动",
		["Module"] = "模块",
		["MODULE"] = "模块",

		-- paragraph
		["Game module - template"] = "游戏模块 · 模板",

		-- toggles / sliders / buttons
		["Custom WalkSpeed"] = "自定义行走速度",
		["WalkSpeed value"] = "行走速度值",
		["Custom JumpPower"] = "自定义跳跃力",
		["JumpPower value"] = "跳跃力值",
		["Infinite jump"] = "无限跳跃",
		["Unload module (restore default movement)"] = "卸载模块（恢复默认移动）",

		-- notifications
		["Template unloaded"] = "模板已卸载",
		["Movement reset to defaults; loops disconnected."] = "移动已恢复默认，循环已断开。",
		["Game module loaded"] = "游戏模块已加载",
		["Template ready; tab injected into global UI.Window."] = "模板就绪，标签页已注入全局 UI。",
	},

	-- Runtime text with numbers: %s / %d keep their meaning.
	patterns = {
		{ "Game: %s\nGameId: %d | PlaceId: %d\nThis tab is injected by games/template.lua as a chain demo.",
			"游戏：%s\nGameId：%d | PlaceId：%d\n此标签页由 games/template.lua 注入，用作链路示例。" },
	},

	-- Optional semantic keys, read with
	--   local t = I18N:Scope("template")   -- inside the game module
	--   t("speedLabel", 32)
	keys = {
		speedLabel = "当前速度：%d",
		jumpLabel = "当前跳跃力：%d",
	},
}
