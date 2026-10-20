-- V Hub locale pack / Simplified Chinese
-- Data only: this file never runs as part of the hub boot chain.
-- Keys are the exact English strings the UI emits; values are what the user sees.
-- Save this file as UTF-8 WITHOUT BOM. The loader rejects invalid UTF-8 instead
-- of rendering garbage, so a wrong encoding simply falls back to English.

return {
	version = 1,
	lang = "zh",
	name = "中文",

	map = {
		-- window / shell
		["SCRIPT HUB - AURORA"] = "脚本中枢 · 极光",
		["AURORA INTERFACE"] = "极光界面",
		["PREMIUM"] = "高级版",
		["Home"] = "主页",
		["Settings"] = "设置",
		["Aimbot"] = "自瞄",
		["ESP"] = "透视",

		-- tabs / sections (AddSection upper-cases its title)
		["Status"] = "状态",
		["STATUS"] = "状态",
		["Params"] = "参数",
		["PARAMS"] = "参数",
		["Target"] = "目标",
		["TARGET"] = "目标",
		["Draw"] = "绘制",
		["DRAW"] = "绘制",
		["Info"] = "信息",
		["INFO"] = "信息",
		["Filter"] = "筛选",
		["FILTER"] = "筛选",
		["Config"] = "配置",
		["CONFIG"] = "配置",
		["Feature colors"] = "功能配色",
		["FEATURE COLORS"] = "功能配色",
		["About"] = "关于",
		["ABOUT"] = "关于",
		["Run"] = "运行",
		["RUN"] = "运行",
		["Theme Colors"] = "主题配色",
		["THEME COLORS"] = "主题配色",
		["Layout"] = "布局",
		["LAYOUT"] = "布局",
		["Language"] = "语言",
		["LANGUAGE"] = "语言",

		-- settings: language
		["Interface language"] = "界面语言",
		["English"] = "英文",
		["Chinese"] = "中文",
		["Language pack unavailable"] = "语言包不可用",

		-- settings: theme / layout
		["Theme"] = "主题",
		["Dark"] = "深色",
		["Light"] = "浅色",
		["Primary"] = "主色",
		["Secondary (gradient end)"] = "辅色（渐变终点）",
		["Reset to default colors"] = "恢复默认配色",
		["Colors reset"] = "配色已重置",
		["Accent restored to default aurora gradient"] = "强调色已恢复为默认极光渐变",
		["Sidebar align"] = "侧栏对齐",
		["Top"] = "顶部",
		["Center"] = "居中",
		["Free-drag launcher"] = "启动器可自由拖动",

		-- generic element text
		["None"] = "无",
		["Items"] = "项",
		["Notifications"] = "通知",
		["Initializing..."] = "初始化中…",
		["Config loaded"] = "配置已加载",
		["This tab requires authorization"] = "此标签页需要授权",
		["press a key"] = "请按下一个按键",
		["Notice"] = "提示",
		["Default"] = "默认",

		-- aimbot
		["Enable aimbot"] = "启用自瞄",
		["Auto aim"] = "自动瞄准",
		["Show FOV circle"] = "显示 FOV 圈",
		["FOV circle"] = "FOV 圈",
		["FOV range"] = "FOV 范围",
		["FOV color"] = "FOV 颜色",
		["Smoothing"] = "平滑度",
		["Target part"] = "目标部位",
		["Head"] = "头部",
		["Torso"] = "躯干",
		["UpperTorso"] = "上躯干",
		["LowerTorso"] = "下躯干",
		["HumanoidRootPart"] = "根部件",
		["Snaps the crosshair to the nearest target inside the FOV each frame; lower smooth = faster."] = "每帧把准星吸附到 FOV 内最近的目标；平滑值越低，吸附越快。",

		-- esp
		["Enable ESP"] = "启用透视",
		["Box"] = "方框",
		["Skeleton"] = "骨骼",
		["Tracers"] = "射线",
		["Highlight"] = "高亮",
		["Circle"] = "圆形",
		["ESP color"] = "透视颜色",
		["Names & HP"] = "名称与血量",
		["Health bar"] = "血条",
		["Enemies only"] = "仅敌人",
		["Max distance"] = "最大距离",
		["BoxHandleAdornment"] = "方框绘制",
		["LineHandleAdornment"] = "线条绘制",

		-- config page
		["Profile name"] = "配置名称",
		["Type a name then save"] = "输入名称后保存",
		["Save / overwrite profile"] = "保存 / 覆盖配置",
		["Delete selected profile"] = "删除所选配置",
		["Detecting..."] = "检测中…",
		["Using universal config"] = "使用通用配置",
		["Game library"] = "游戏库",
		["Environment"] = "环境",
		["No registration needed"] = "无需登记",
		["All features available"] = "全部功能可用",
		["All toggles read UI Flags directly; changes apply instantly and restore on next launch."] = "所有开关直接读取界面开关值，改动即时生效，并在下次启动时恢复。",
		["Current game registered"] = "当前游戏已登记",
		["Game config created"] = "游戏配置已创建",
		["Removed from game list"] = "已从游戏列表移除",

		-- run / exit
		["Exit script"] = "退出脚本",
		["Exited"] = "已退出",
		["All features stopped; UI is being cleaned."] = "所有功能已停止，正在清理界面。",
		["The button below stops aimbot/ESP, cleans ESP/FOV/nameplates and destroys all UI and traces."] = "下方按钮会停止自瞄与透视，清除透视标记、FOV 圈与名牌，并销毁全部界面与残留。",

		-- notifications
		["Config saved"] = "配置已保存",
		["Config deleted"] = "配置已删除",
		["Config overwritten"] = "配置已覆盖",
		["Config ready"] = "配置就绪",
		["Config reloaded"] = "配置已重载",
		["Config scope switched"] = "配置作用域已切换",
		["Config switched"] = "配置已切换",
		["Cannot register"] = "无法登记",
		["Register failed"] = "登记失败",
		["Cannot remove"] = "无法移除",
		["Switch failed"] = "切换失败",
		["Save failed"] = "保存失败",
		["Delete failed"] = "删除失败",
	},

	-- Runtime strings built with string.format: patterns are tried after the
	-- exact map misses. %s / %d keep their meaning, everything else is literal.
	patterns = {
		{ "Restored %s local settings", "已恢复 %s 的本地设置" },
		{ "Game: %s\nGameId: %d\nPlaceId: %d\nHttpSpy: %s\nChain: load -> UI -> universe -> game modules",
			"游戏：%s\nGameId：%d\nPlaceId：%d\nHttpSpy：%s\n链路：load -> UI -> universe -> 游戏模块" },
		{ "Matched: %s\nMatched by: %s\nDispatched: %s", "命中：%s\n匹配方式：%s\n派发：%s" },
		{ "Current game (PlaceId %d) is not in the library; running generic features only.\nTo add support: edit GAME_LIBRARY in universe.lua.",
			"当前游戏（PlaceId %d）不在游戏库中，仅运行通用功能。\n如需支持：在 universe.lua 的 GAME_LIBRARY 中添加。" },
		{ "Added %s", "已添加 %s" },
		{ "%s item(s)", "%s 项" },
	},
}
