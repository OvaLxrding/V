--[[ Protected by Lua Guard ]]

( function (...) if type(Services) ~= "\116\097\098\108\101" then warn("\091\086\032\085\110\105\118\101\114\115\101\093\032\32570\23569\20840\23616\032\083\101\114\118\105\099\101\115\032\8212\8212\032\108\111\097\100\046\108\117\097\032\26410\36816\34892\65292\38142\36335\20013\27490\12290") return false end
 if type(UI) ~= "\116\097\098\108\101" or type(UI.VLib) ~= "\116\097\098\108\101" or type(UI.Window) ~= "\116\097\098\108\101" then warn("\091\086\032\085\110\105\118\101\114\115\101\093\032\20840\23616\032\085\073\032\19981\23436\25972\032\8212\8212\032\117\105\046\108\117\097\032\38454\27573\26410\21152\36733\25104\21151\65292\38142\36335\20013\27490\12290") return false end
 if UI.Tabs and UI.Tabs.Aimbot then warn("\091\086\032\085\110\105\118\101\114\115\101\093\032\39029\31614\24050\25346\36733\65292\36339\36807\37325\22797\25191\34892\65288\22914\38656\37325\36733\35831\37325\36305\032\108\111\097\100\046\108\117\097\65289\12290") return false end
 local Players = Services.Players local RunService = Services.RunService local HttpService = Services.HttpService local _lIllIIlIll = Services.Workspace local _lIIllIlIll = _lIllIIlIll:FindFirstChild("\084\101\114\114\097\105\110") local _lllllIllII = UI.VLib local _IIIIlIIIIl = UI.Window local _IlllIIlIlI = _lllllIllII.Flags local _lIIlIlllII = {} if type(getgenv) == "\102\117\110\099\116\105\111\110" then getgenv().V_TOKEN = _lIIlIlllII end
 local _llIIIIllIl = { [0x2E50B] = { _lIIIllllIl = "\078\097\116\117\114\097\108\032\068\105\115\097\115\116\101\114\032\083\117\114\118\105\118\097\108", _IlIIIlllII = "\103\097\109\101\115\047\116\101\109\112\108\097\116\101\046\108\117\097" }, [0x70C1162232FF] = { _lIIIllllIl = "\27979\35797\24213\26495", _IlIIIlllII = "\103\097\109\101\115\047\116\101\109\112\108\097\116\101\046\108\117\097" }, } local function _IIIlIllIII() local _IllIlllIll = tonumber(game.PlaceId) or 0x0 if _IllIlllIll > 0x0 and _llIIIIllIl[_IllIlllIll] then return _llIIIIllIl[_IllIlllIll], "\080\108\097\099\101\073\100" end
 return nil, nil end
 local _lIlIllIIlI, GameMatchedBy = _IIIlIllIII() UI.Game = _lIlIllIIlI local _IIlIllIIII = { _lllllIlllI = {}, count = 0x0 } local function _llllIllIll(level, message) if _IIlIllIIII.seen[message] then return end
 _IIlIllIIII.seen[message] = true _IIlIllIIII.count = _IIlIllIIII.count + 0x1 if level == "\119\097\114\110" or level == "\101\114\114\111\114" then warn("\091\086\093\032" .. message) else print("\091\086\093\032" .. message) end
 end
 local function _llIllIllII(title, content, time) if not _lllllIllII then return end
 _lllllIllII:MakeNotification({ Name = title, Content = content, Time = time or 4.5 }) end
 local function _llIlIIIlll(_llIlIIlIlI, title, content, time) if _IIlIllIIII.seen[_llIlIIlIlI] then return end
 _IIlIllIIII.seen[_llIlIIlIlI] = true _llIllIllII(title, content, time) end
 local function _IlIlIllIII(className) local _lIllllIIll, _IIlIIIIlIl = pcall(Instance.new, className) if _lIllllIIll and _IIlIIIIlIl then return _IIlIIIIlIl end
 return nil end
 local function _IIIlIIllIl(_IIlIIIIlIl, property, sample) local _lIllllIIll = pcall( function () _IIlIIIIlIl[property] = sample end
 ) return _lIllllIIll end
 local _lIlIIIllll = { terrain = _lIIllIlIll ~= nil, _IlIIIIlIII = false, boxAdornment = false, lineAdornment = false, adornmentThickness = {}, adornmentZIndex = {}, problems = {}, } local function _IIllIIIIIl() local _IlIIIIlIII = _IlIlIllIII("\072\105\103\104\108\105\103\104\116") if _IlIIIIlIII then _lIlIIIllll.highlight = true _IlIIIIlIII:Destroy() else _lIlIIIllll.problems[#_lIlIIIllll.problems + 0x1] = "\072\105\103\104\108\105\103\104\116\032\19981\21487\29992" end
 local _IIIIIllIll = { { ClassName = "\066\111\120\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116", Key = "\098\111\120\065\100\111\114\110\109\101\110\116" }, { ClassName = "\076\105\110\101\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116", Key = "\108\105\110\101\065\100\111\114\110\109\101\110\116" }, } for _lIIlllIIlI, _IIlIIlllll in ipairs(_IIIIIllIll) do local _IIlIIIIlIl = _IlIlIllIII(_IIlIIlllll.ClassName) if _IIlIIIIlIl then _lIlIIIllll[_IIlIIlllll.Key] = true _lIlIIIllll.adornmentThickness[_IIlIIlllll.ClassName] = _IIIlIIllIl(_IIlIIIIlIl, "\084\104\105\099\107\110\101\115\115", 0x1) _lIlIIIllll.adornmentZIndex[_IIlIIlllll.ClassName] = _IIIlIIllIl(_IIlIIIIlIl, "\090\073\110\100\101\120", 0x0) _IIlIIIIlIl:Destroy() else _lIlIIIllll.problems[#_lIlIIIllll.problems + 0x1] = _IIlIIlllll.ClassName .. "\032\19981\21487\29992" end
 end
 if not _lIlIIIllll.terrain then _lIlIIIllll.problems[#_lIlIIIllll.problems + 0x1] = "\24403\21069\22330\26223\27809\26377\032\084\101\114\114\097\105\110" end
 for index = 0x1, #_lIlIIIllll.problems do _llllIllIll("\119\097\114\110", "\33021\21147\25506\27979\65306" .. _lIlIIIllll.problems[index]) end
 end
 _IIllIIIIIl() local _lIIlIIIIlI = {} local _IIIIIIllIl = {} local _lIIllIlIll = false local function _lIlIllIIII(definition) local _IIlIllllII = { Id = definition.Id, Label = definition.Label, Flag = definition.Flag, Hard = definition.Hard == true, Reason = definition.Reason, Check = definition.Check or function () return true end
 , } _lIIlIIIIlI[_IIlIllllII.Id] = _IIlIllllII _IIIIIIllIl[#_IIIIIIllIl + 0x1] = _IIlIllllII end
 local function _IIIIIIllII() if Players.LocalPlayer then return true end
 return false, "\26410\26816\27979\21040\26412\22320\29609\23478\65288\21487\33021\36824\22312\21152\36733\25110\22312\22823\21381\65289" end
 local function _IIlIIIIlII() if _lIllIIlIll.CurrentCamera then return true end
 return false, "\24403\21069\27809\26377\21487\29992\30456\26426" end
 local function _llIIIlIlll() if not _lIlIIIllll.lineAdornment then return false, "\24403\21069\25191\34892\22120\19981\25903\25345\32447\26465\32472\21046" end
 if not _lIlIIIllll.terrain then return false, "\24403\21069\22330\26223\27809\26377\032\084\101\114\114\097\105\110\65292\26080\27861\32472\21046\19990\30028\32447\26465" end
 return true end
 _lIlIllIIII({ Id = "\097\105\109\098\111\116", Label = "\33258\30596", Flag = "\065\073\077\066\079\084", Check = function () local _lIllllIIll, reason = _IIIIIIllII() if not _lIllllIIll then return false, reason end
 return _IIlIIIIlII() end
 , }) _lIlIllIIII({ Id = "\101\115\112", Label = "\36879\35270", Flag = "\069\083\080", Check = function () local _lIllllIIll, reason = _IIIIIIllII() if not _lIllllIIll then return false, reason end
 return _IIlIIIIlII() end
 , }) _lIlIllIIII({ Id = "\104\105\103\104\108\105\103\104\116", Label = "\25551\36793\39640\20142", Flag = "\069\083\080\095\072\073\071\072\076\073\071\072\084", Hard = true, Check = function () if _lIlIIIllll.highlight then return true end
 return false, "\24403\21069\28216\25103\19981\25903\25345\032\072\105\103\104\108\105\103\104\116" end
 , }) _lIlIllIIII({ Id = "\098\111\120", Label = "\26041\26694", Flag = "\069\083\080\095\066\079\088", Hard = true, Check = function () if _lIlIIIllll.boxAdornment then return true end
 return false, "\24403\21069\28216\25103\19981\25903\25345\032\066\111\120\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116" end
 , }) _lIlIllIIII({ Id = "\115\107\101\108\101\116\111\110", Label = "\39592\39612\39592\26550", Flag = "\069\083\080\095\083\075\069\076\069\084\079\078", Hard = true, Check = _llIIIlIlll, }) _lIlIllIIII({ Id = "\116\114\097\099\101\114\115", Label = "\36861\36394\32447", Flag = "\069\083\080\095\084\082\065\067\069\082\083", Hard = true, Check = _llIIIlIlll, }) _lIlIllIIII({ Id = "\110\097\109\101\115", Label = "\21517\23383\19982\34880\37327", Flag = "\069\083\080\095\078\065\077\069\083" }) _lIlIllIIII({ Id = "\104\101\097\108\116\104\098\097\114", Label = "\36523\20307\34880\37327\26465", Flag = "\069\083\080\095\072\069\065\076\084\072\066\065\082" }) _lIlIllIIII({ Id = "\102\111\118", Label = "\35270\37326\22280", Flag = "\065\073\077\066\079\084\095\083\072\079\087\070\079\086" }) local function _lIIIIlIllI(_lIllIllIII) local _IIlIllllII = _lIIlIIIIlI[_lIllIllIII] if not _IIlIllllII then return true end
 local _lIllllIIll, reason = _IIlIllllII.Check() if _lIllllIIll then return true end
 return false, reason or _IIlIllllII.Reason or "\24403\21069\29615\22659\19981\25903\25345" end
 local function _IllIllIIll(_lIllIllIII) local _lIllllIIll, reason = _lIIIIlIllI(_lIllIllIII) if _lIllllIIll then return true end
 local _IIlIllllII = _lIIlIIIIlI[_lIllIllIII] local _lllIIIIIIl = _IIlIllllII and _IIlIllllII.Label or _lIllIllIII if _lIIllIlIll then _llIlIIIlll("\102\101\097\116\117\114\101\045" .. _lIllIllIII, "\21151\33021\19981\21487\29992", string.format("\037\115\65306\037\115", _lllIIIIIIl, tostring(reason))) else _llllIllIll("\119\097\114\110", string.format("\21551\21160\38454\27573\65306\037\115\032\19981\21487\29992\65288\037\115\65289", _lllIIIIIIl, tostring(reason))) end
 return false end
 local function _IlIllllIIl() local _IllIlllllI, missing = {}, {} for _lIIlllIIlI, _IIlIllllII in ipairs(_IIIIIIllIl) do local _lIllllIIll, reason = _lIIIIlIllI(_IIlIllllII.Id) if _lIllllIIll then _IllIlllllI[#_IllIlllllI + 0x1] = _IIlIllllII.Label else missing[#missing + 0x1] = string.format("\037\115\65288\037\115\65289", _IIlIllllII.Label, tostring(reason)) end
 end
 return _IllIlllllI, missing end
 local function _IlIlIIllII() local _lIIlllIIlI, missing = _IlIllllIIl() if #missing > 0x0 then _llIlIIIlll("\102\101\097\116\117\114\101\045\115\117\109\109\097\114\121", "\37096\20998\21151\33021\19981\21487\29992", table.concat(missing, "\12289"), 0x7) end
 end
 local function _lIllIlIIlI() local _llIllllIll = {} for _lIIlllIIlI, _IIlIllllII in ipairs(_IIIIIIllIl) do if _IIlIllllII.Hard and _IIlIllllII.Flag then local _lIlIIIIIII = _IlllIIlIlI[_IIlIllllII.Flag] local _lIllllIIll = _lIIIIlIllI(_IIlIllllII.Id) if _lIlIIIIIII and _lIlIIIIIII.Value == true and not _lIllllIIll then _lIlIIIIIII:Set(false) _llIllllIll[#_llIllllIll + 0x1] = _IIlIllllII.Label end
 end
 end
 if #_llIllllIll > 0x0 then _llIlIIIlll("\117\110\115\117\112\112\111\114\116\101\100\045\111\102\102", "\24050\20851\38381\19981\25903\25345\30340\21151\33021", table.concat(_llIllllIll, "\12289"), 0x6) _llllIllIll("\119\097\114\110", "\24050\20851\38381\19981\25903\25345\30340\21151\33021\65306" .. table.concat(_llIllllIll, "\12289")) end
 end
 local function _IIllllIlIl() if type(gethui) == "\102\117\110\099\116\105\111\110" then local _lIllllIIll, _IIIlIlIlII = pcall(gethui) if _lIllllIIll and _IIIlIlIlII then return _IIIlIlIlII end
 if not _lIllllIIll then _llllIllIll("\119\097\114\110", "\103\101\116\104\117\105\032\35843\29992\22833\36133\65292\22238\36864\21040\032\080\108\097\121\101\114\071\117\105\65306" .. tostring(_IIIlIlIlII)) end
 end
 local _IlllIlIlll = Players.LocalPlayer local _lIIIlllIll = _IlllIlIlll and _IlllIlIlll:FindFirstChildOfClass("\080\108\097\121\101\114\071\117\105") if _lIIIlllIll then return _lIIIlllIll end
 return Services.CoreGui end
 local function _lIlIlIlIIl() return _lIllIIlIll.CurrentCamera end
 local function _IlIIlIlIIl() return Players.LocalPlayer end
 local function _IIlllIllIl(_lIIIllllIl, _IlIIlIIlII) local _lIlIIIIIII = _IlllIIlIlI[_lIIIllllIl] if _lIlIIIIIII ~= nil and _lIlIIIIIII.Value ~= nil then return _lIlIIIIIII.Value end
 return _IlIIlIIlII end
 local function _lIIIIllIII(_lIIIllllIl) return _IIlllIllIl(_lIIIllllIl, false) == true end
 local function _lIIllIIlIl(_lIIIllllIl, _IlIIlIIlII) local _lllIllIIII = tonumber(_IIlllIllIl(_lIIIllllIl, _IlIIlIIlII)) if _lllIllIIII == nil then return _IlIIlIIlII end
 return _lllIllIIII end
 local function _lIllIllIII() local _lIlIlIllII = _IIllllIlIl() local _IllIllIlII = _lIlIlIllII:FindFirstChild("\086\070\079\086") if _IllIllIlII then _IllIllIlII:Destroy() end
 local _lIIlIIIIlI = _lIlIlIllII:FindFirstChild("\086\065\100\111\114\110\109\101\110\116\115") if _lIIlIIIIlI then _lIIlIIIIlI:Destroy() end
 for _lIIlllIIlI, _IlllIlIlll in ipairs(Players:GetPlayers()) do local _IIIIIIlllI = _IlllIlIlll.Character if _IIIIIIlllI then for _lIIlllIIlI, _lIIIllllIl in ipairs({ "\086\069\083\080", "\086\069\083\080\072\112" }) do local _IlIIIlIIlI = _IIIIIIlllI:FindFirstChild(_lIIIllllIl, true) if _IlIIIlIIlI then _IlIIIlIIlI:Destroy() end
 end
 local _IlIIIIlIII = _IIIIIIlllI:FindFirstChild("\086\072\076") if _IlIIIIlIII then _IlIIIIlIII:Destroy() end
 end
 end
 end
 local _lIlIllIlll = getgenv and getgenv().V_RUNTIME if _lIlIllIlll then if _lIlIllIlll.render then _lIlIllIlll.render:Disconnect() end
 if _lIlIllIlll.heartbeat then _lIlIllIlll.heartbeat:Disconnect() end
 if _lIlIllIlll.clear then local _lIllllIIll, err = pcall(_lIlIllIlll.clear) if not _lIllllIIll then _llllIllIll("\119\097\114\110", "\28165\29702\19978\19968\36718\032\069\083\080\032\22833\36133\65306" .. tostring(err)) end
 end
 end
 _lIllIllIII() local _IIIllllIIl = { Objects = {}, AdornFolder = nil, } local _IIlIIIIlII = { FovGui = nil, FovFrame = nil, FovStroke = nil, FovUnavailable = false, } local _llllIllllI = Color3.fromRGB(0xFF, 0x40, 0x40) local function _IlllIlIIII() return _IIlllIllIl("\069\083\080\095\067\079\076\079\082", _llllIllllI) end
 local function _lIlIIllIll() if _IIIllllIIl.AdornFolder and _IIIllllIIl.AdornFolder.Parent then return _IIIllllIIl.AdornFolder end
 local _IIIlIlIlII = _IIllllIlIl() if not _IIIlIlIlII then _lIlIIIllll.boxAdornment = false _lIlIIIllll.lineAdornment = false _llIlIIIlll("\097\100\111\114\110\045\110\111\045\112\097\114\101\110\116", "\21151\33021\19981\21487\29992", "\25214\19981\21040\21487\29992\30340\032\071\085\073\032\23481\22120\65292\26041\26694\032\047\032\39592\26550\032\047\032\36861\36394\32447\24050\20572\29992", 0x6) _llllIllIll("\119\097\114\110", "\25214\19981\21040\21487\29992\30340\032\071\085\073\032\23481\22120\65292\26041\26694\032\047\032\39592\26550\032\047\032\36861\36394\32447\24050\20572\29992") return nil end
 local _lIIlIIIIlI = Instance.new("\070\111\108\100\101\114") _lIIlIIIIlI.Name = "\086\065\100\111\114\110\109\101\110\116\115" local _lIllllIIll = pcall( function () _lIIlIIIIlI.Parent = _IIIlIlIlII end
 ) if not _lIllllIIll then _lIIlIIIIlI:Destroy() _lIlIIIllll.boxAdornment = false _lIlIIIllll.lineAdornment = false _llIlIIIlll("\097\100\111\114\110\045\110\111\045\109\111\117\110\116", "\21151\33021\19981\21487\29992", "\26080\27861\25346\36733\32472\21046\23481\22120\65292\26041\26694\032\047\032\39592\26550\032\047\032\36861\36394\32447\24050\20572\29992", 0x6) _llllIllIll("\119\097\114\110", "\26080\27861\25346\36733\032\065\100\111\114\110\109\101\110\116\032\23481\22120\65292\26041\26694\032\047\032\39592\26550\032\047\032\36861\36394\32447\24050\20572\29992") return nil end
 _IIIllllIIl.AdornFolder = _lIIlIIIIlI return _lIIlIIIIlI end
 local function _llIlIllIIl(_llIIIllIII) return Color3.fromRGB( math.floor(0xFF - 0xAF * _llIIIllIII), math.floor(0x3C + 0xA0 * _llIIIllIII), 0x3C ) end
 local _IllIlIllll = { { "\072\101\097\100", "\085\112\112\101\114\084\111\114\115\111" }, { "\085\112\112\101\114\084\111\114\115\111", "\076\111\119\101\114\084\111\114\115\111" }, { "\085\112\112\101\114\084\111\114\115\111", "\076\101\102\116\085\112\112\101\114\065\114\109" }, { "\076\101\102\116\085\112\112\101\114\065\114\109", "\076\101\102\116\076\111\119\101\114\065\114\109" }, { "\076\101\102\116\076\111\119\101\114\065\114\109", "\076\101\102\116\072\097\110\100" }, { "\085\112\112\101\114\084\111\114\115\111", "\082\105\103\104\116\085\112\112\101\114\065\114\109" }, { "\082\105\103\104\116\085\112\112\101\114\065\114\109", "\082\105\103\104\116\076\111\119\101\114\065\114\109" }, { "\082\105\103\104\116\076\111\119\101\114\065\114\109", "\082\105\103\104\116\072\097\110\100" }, { "\076\111\119\101\114\084\111\114\115\111", "\076\101\102\116\085\112\112\101\114\076\101\103" }, { "\076\101\102\116\085\112\112\101\114\076\101\103", "\076\101\102\116\076\111\119\101\114\076\101\103" }, { "\076\101\102\116\076\111\119\101\114\076\101\103", "\076\101\102\116\070\111\111\116" }, { "\076\111\119\101\114\084\111\114\115\111", "\082\105\103\104\116\085\112\112\101\114\076\101\103" }, { "\082\105\103\104\116\085\112\112\101\114\076\101\103", "\082\105\103\104\116\076\111\119\101\114\076\101\103" }, { "\082\105\103\104\116\076\111\119\101\114\076\101\103", "\082\105\103\104\116\070\111\111\116" }, { "\072\101\097\100", "\084\111\114\115\111" }, { "\084\111\114\115\111", "\076\101\102\116\032\065\114\109" }, { "\084\111\114\115\111", "\082\105\103\104\116\032\065\114\109" }, { "\084\111\114\115\111", "\076\101\102\116\032\076\101\103" }, { "\084\111\114\115\111", "\082\105\103\104\116\032\076\101\103" }, } local function _lIllllIIIl(instance, _IIIlIlIlII) if not instance then return false end
 local _lIllllIIll = pcall( function () instance.Parent = _IIIlIlIlII end
 ) return _lIllllIIll end
 local function _llllllIllI(className, thickness, transparency) local _IIIlIlIlII = _lIlIIllIll() if not _IIIlIlIlII then return nil end
 local _lllIIlllII = Instance.new(className) _lllIIlllII.Color3 = _IlllIlIIII() _lllIIlllII.Transparency = transparency if _lIlIIIllll.adornmentThickness[className] then _lllIIlllII.Thickness = thickness end
 _lllIIlllII.AlwaysOnTop = true if _lIlIIIllll.adornmentZIndex[className] then _lllIIlllII.ZIndex = 0x0 end
 _lllIIlllII.Visible = false if _lIIllIlIll then _lllIIlllII.Adornee = _lIIllIlIll end
 _lllIIlllII.Parent = _IIIlIlIlII return _lllIIlllII end
 local function _IIIlIlIIlI(_IIlIIIIlIl) if _IIlIIIIlIl.Highlight then _IIlIIIIlIl.Highlight:Destroy() end
 if _IIlIIIIlIl.Billboard then _IIlIIIIlIl.Billboard:Destroy() end
 if _IIlIIIIlIl.HpBillboard then _IIlIIIIlIl.HpBillboard:Destroy() end
 if _IIlIIIIlIl.Box then _IIlIIIIlIl.Box:Destroy() end
 if _IIlIIIIlIl.Tracer then _IIlIIIIlIl.Tracer:Destroy() end
 for _lIIlllIIlI, bone in ipairs(_IIlIIIIlIl.Bones or {}) do if bone.Line then bone.Line:Destroy() end
 end
 end
 local function _IIIIlIIlIl(_IIlIIIIlIl) if not (_IIlIIIIlIl.Billboard and _IIlIIIIlIl.NameLabel and _IIlIIIIlIl.HpBillboard and _IIlIIIIlIl.HBg and _IIlIIIIlIl.HFg) then return false end
 if _lIlIIIllll.highlight and not _IIlIIIIlIl.Highlight then return false end
 if _lIlIIIllll.boxAdornment and not _IIlIIIIlIl.Box then return false end
 if _lIlIIIllll.lineAdornment and _lIlIIIllll.terrain then if not _IIlIIIIlIl.Tracer or #_IIlIIIIlIl.Bones == 0x0 then return false end
 end
 return true end
 local function _llIlIllIll(_IlllIlIlll) local _IIlIIIIlIl = { Char = nil, Bones = {} } if _lIlIIIllll.highlight then local _IlIIIIlIII = Instance.new("\072\105\103\104\108\105\103\104\116") _IlIIIIlIII.Name = "\086\072\076" _IlIIIIlIII.FillColor = _IlllIlIIII() _IlIIIIlIII.OutlineColor = Color3.fromRGB(0xFF, 0xFF, 0xFF) _IlIIIIlIII.FillTransparency = 0.85 _IlIIIIlIII.OutlineTransparency = 0.05 _IlIIIIlIII.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop _IIlIIIIlIl.Highlight = _IlIIIIlIII end
 if _lIlIIIllll.boxAdornment then _IIlIIIIlIl.Box = _llllllIllI("\066\111\120\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116", 0x1, 0.35) end
 if _lIlIIIllll.lineAdornment and _lIlIIIllll.terrain then for _lIIlllIIlI, pair in ipairs(_IllIlIllll) do local _llIlIlIlII = _llllllIllI("\076\105\110\101\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116", 1.5, 0x0) if _llIlIlIlII then _IIlIIIIlIl.Bones[#_IIlIIIIlIl.Bones + 0x1] = { Line = _llIlIlIlII, A = pair[0x1], B = pair[0x2] } end
 end
 _IIlIIIIlIl.Tracer = _llllllIllI("\076\105\110\101\072\097\110\100\108\101\065\100\111\114\110\109\101\110\116", 1.5, 0.2) end
 local _IlIlllllIl = Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105") _IlIlllllIl.Name = "\086\069\083\080" _IlIlllllIl.Size = UDim2.new(0x0, 0x96, 0x0, 0x16) _IlIlllllIl.StudsOffset = Vector3.new(0x0, 3.1, 0x0) _IlIlllllIl.AlwaysOnTop = true _IlIlllllIl.MaxDistance = 0xBB8 _IlIlllllIl.ResetOnSpawn = false local _lIlIllIlIl = Instance.new("\084\101\120\116\076\097\098\101\108") _lIlIllIlIl.Size = UDim2.new(0x1, 0x0, 0x1, 0x0) _lIlIllIlIl.BackgroundTransparency = 0x1 _lIlIllIlIl.Font = Enum.Font.GothamBold _lIlIllIlIl.TextSize = 0xE _lIlIllIlIl.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF) _lIlIllIlIl.TextStrokeTransparency = 0.35 _lIlIllIlIl.Text = _IlllIlIlll.DisplayName _lIlIllIlIl.Parent = _IlIlllllIl local _llllIlIIlI = Instance.new("\066\105\108\108\098\111\097\114\100\071\117\105") _llllIlIIlI.Name = "\086\069\083\080\072\112" _llllIlIIlI.Size = UDim2.new(0x0, 0xA, 0x0, 0x3C) _llllIlIIlI.StudsOffset = Vector3.new(-2.2, 0x0, 0x0) _llllIlIIlI.AlwaysOnTop = true _llllIlIIlI.MaxDistance = 0xBB8 _llllIlIIlI.ResetOnSpawn = false local _IIIlIlIIIl = Instance.new("\070\114\097\109\101") _IIIlIlIIIl.Size = UDim2.new(0x1, 0x0, 0x1, 0x0) _IIIlIlIIIl.BackgroundColor3 = Color3.fromRGB(0x14, 0x14, 0x18) _IIIlIlIIIl.BackgroundTransparency = 0.25 _IIIlIlIIIl.BorderSizePixel = 0x0 _IIIlIlIIIl.Parent = _llllIlIIlI local _IlIlIllIlI = Instance.new("\085\073\067\111\114\110\101\114") _IlIlIllIlI.CornerRadius = UDim.new(0x1, 0x0) _IlIlIllIlI.Parent = _IIIlIlIIIl local _IIlIIIIIll = Instance.new("\070\114\097\109\101") _IIlIIIIIll.AnchorPoint = Vector2.new(0x0, 0x1) _IIlIIIIIll.Position = UDim2.new(0x0, 0x1, 0x1, -0x1) _IIlIIIIIll.Size = UDim2.new(0x1, -0x2, 0x1, -0x2) _IIlIIIIIll.BackgroundColor3 = _llIlIllIIl(0x1) _IIlIIIIIll.BorderSizePixel = 0x0 _IIlIIIIIll.Parent = _IIIlIlIIIl local _lIIlIIIIlI = Instance.new("\085\073\067\111\114\110\101\114") _lIIlIIIIlI.CornerRadius = UDim.new(0x1, 0x0) _lIIlIIIIlI.Parent = _IIlIIIIIll _IIlIIIIlIl.Billboard = _IlIlllllIl _IIlIIIIlIl.NameLabel = _lIlIllIlIl _IIlIIIIlIl.HpBillboard = _llllIlIIlI _IIlIIIIlIl.HBg = _IIIlIlIIIl _IIlIIIIlIl.HFg = _IIlIIIIIll return _IIlIIIIlIl end
 local function _llIIllIIlI() if not _lIIIIllIII("\069\083\080") then return end
 local _IlllllIllI = _IlIIlIlIIl() if not _IlllllIllI then return end
 local _IlllIllIII = _lIIllIIlIl("\069\083\080\095\068\073\083\084\065\078\067\069", 0x190) local _IIIlIlIlII = _lIIIIllIII("\069\083\080\095\078\065\077\069\083") local _IIIIIIIlII = _lIIIIllIII("\069\083\080\095\072\069\065\076\084\072\066\065\082") local _IIlIllllIl = _lIIIIllIII("\069\083\080\095\084\069\065\077\067\072\069\067\075") local _IllIIIlIll = (_IlllIllIII >= 0x7CF) and 0x186A0 or _IlllIllIII for _lIIlllIIlI, _IlllIlIlll in ipairs(Players:GetPlayers()) do if _IlllIlIlll ~= _IlllllIllI then local _IIIIIIlllI = _IlllIlIlll.Character local _lllllllIII = _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") local _IllIIllIII = _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\101\097\100") local _IIllIIlIlI = _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100") local _IllIIllIll = _IIIIIIlllI and _lllllllIII and _IllIIllIII and _IIllIIlIlI and _IIllIIlIlI.Health > 0x0 if _IllIIllIll and _IIlIllllIl and _IlllllIllI.Team and _IlllIlIlll.Team == _IlllllIllI.Team then _IllIIllIll = false end
 if _IllIIllIll then local _IIlIIIIlIl = _IIIllllIIl.Objects[_IlllIlIlll] local _lllIIIIlII = not _IIlIIIIlIl or _IIlIIIIlIl.Char ~= _IIIIIIlllI if not _lllIIIIlII then _lllIIIIlII = not _IIIIlIIlIl(_IIlIIIIlIl) end
 if _lllIIIIlII then if _IIlIIIIlIl then _IIIlIlIIlI(_IIlIIIIlIl) end
 _IIlIIIIlIl = _llIlIllIll(_IlllIlIlll) _IIlIIIIlIl.Char = _IIIIIIlllI _IIIllllIIl.Objects[_IlllIlIlll] = _IIlIIIIlIl end
 if _IIlIIIIlIl.Billboard.Parent ~= _IllIIllIII then if not _lIllllIIIl(_IIlIIIIlIl.Billboard, _IllIIllIII) then _IIIlIlIIlI(_IIlIIIIlIl) _IIlIIIIlIl = _llIlIllIll(_IlllIlIlll) _IIlIIIIlIl.Char = _IIIIIIlllI _IIIllllIIl.Objects[_IlllIlIlll] = _IIlIIIIlIl _lIllllIIIl(_IIlIIIIlIl.Billboard, _IllIIllIII) end
 end
 if _IIlIIIIlIl.HpBillboard.Parent ~= _lllllllIII then if not _lIllllIIIl(_IIlIIIIlIl.HpBillboard, _lllllllIII) then _IIIlIlIIlI(_IIlIIIIlIl) _IIlIIIIlIl = _llIlIllIll(_IlllIlIlll) _IIlIIIIlIl.Char = _IIIIIIlllI _IIIllllIIl.Objects[_IlllIlIlll] = _IIlIIIIlIl _lIllllIIIl(_IIlIIIIlIl.Billboard, _IllIIllIII) _lIllllIIIl(_IIlIIIIlIl.HpBillboard, _lllllllIII) end
 end
 _IIlIIIIlIl.Billboard.MaxDistance = _IllIIIlIll _IIlIIIIlIl.HpBillboard.MaxDistance = _IllIIIlIll _IIlIIIIlIl.Billboard.Enabled = true _IIlIIIIlIl.NameLabel.Visible = _IIIlIlIlII _IIlIIIIlIl.NameLabel.Text = _IlllIlIlll.DisplayName .. "\032\091" .. math.floor(_IIllIIlIlI.Health) .. "\072\080\093" _IIlIIIIlIl.HpBillboard.Enabled = true _IIlIIIIlIl.HBg.Visible = _IIIIIIIlII and true or false local _llIIIllIII = math.clamp(_IIllIIlIlI.Health / math.max(_IIllIIlIlI.MaxHealth, 0x1), 0x0, 0x1) _IIlIIIIlIl.HFg.Size = UDim2.new(0x1, -0x2, _llIIIllIII, -0x2) _IIlIIIIlIl.HFg.BackgroundColor3 = _llIlIllIIl(_llIIIllIII) _IIlIIIIlIl.Active = true else local _IIlIIIIlIl = _IIIllllIIl.Objects[_IlllIlIlll] if _IIlIIIIlIl then _IIlIIIIlIl.Active = false _lIllllIIIl(_IIlIIIIlIl.Highlight, nil) _lIllllIIIl(_IIlIIIIlIl.Billboard, nil) _lIllllIIIl(_IIlIIIIlIl.HpBillboard, nil) if _IIlIIIIlIl.Box then _IIlIIIIlIl.Box.Visible = false end
 if _IIlIIIIlIl.Tracer then _IIlIIIIlIl.Tracer.Visible = false end
 for _lIIlllIIlI, bone in ipairs(_IIlIIIIlIl.Bones or {}) do if bone.Line then bone.Line.Visible = false end
 end
 end
 end
 end
 end
 for _IlllIlIlll, _IIlIIIIlIl in pairs(_IIIllllIIl.Objects) do if not Players:FindFirstChild(_IlllIlIlll.Name) then _IIIlIlIIlI(_IIlIIIIlIl) _IIIllllIIl.Objects[_IlllIlIlll] = nil end
 end
 end
 local function _lllIIIIIlI() for _lIIlllIIlI, _IIlIIIIlIl in pairs(_IIIllllIIl.Objects) do _IIIlIlIIlI(_IIlIIIIlIl) end
 table.clear(_IIIllllIIl.Objects) end
 local function _IllIIIIllI() if not _lIIIIllIII("\069\083\080") then return end
 local _llIIlIlIIl = _lIlIlIlIIl() if not _llIIlIlIIl then return end
 local _IlllllIllI = _IlIIlIlIIl() if not _IlllllIllI then return end
 local _IIIlIllIII = _IlllIlIIII() local _IlllIllIII = _lIIllIIlIl("\069\083\080\095\068\073\083\084\065\078\067\069", 0x190) local _IIlIIIIllI = _lIIIIllIII("\069\083\080\095\072\073\071\072\076\073\071\072\084") local _lllIlIlIlI = _lIIIIllIII("\069\083\080\095\066\079\088") local _IIlIIlIIII = _lIIIIllIII("\069\083\080\095\083\075\069\076\069\084\079\078") local _lllllllIlI = _lIIIIllIII("\069\083\080\095\084\082\065\067\069\082\083") local _lIIIIllIII = _llIIlIlIIl.CFrame.Position local _IIIllIllIl = _IlllllIllI.Character local _lIIIIIIlll = _IIIllIllIl and _IIIllIllIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") for _lIIlllIIlI, _IIlIIIIlIl in pairs(_IIIllllIIl.Objects) do local _IIIIIIlllI = _IIlIIIIlIl.Char local _IIllIIlIlI = _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100") local _lllllllIII = _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") local _lIllIlIIII = _IIlIIIIlIl.Active and _IIIIIIlllI and _IIIIIIlllI.Parent and _IIllIIlIlI and _IIllIIlIlI.Health > 0x0 and _lllllllIII if _lIllIlIIII then local _lIIlllIIlI, onScreen = _llIIlIlIIl:WorldToScreenPoint(_lllllllIII.Position) local _IlIIIllIII = (_lllllllIII.Position - _lIIIIllIII).Magnitude local _Illlllllll = (_IlllIllIII >= 0x7CF) or (_IlIIIllIII <= _IlllIllIII) local _IIIIlIIIlI = onScreen and _Illlllllll if _IIlIIIIlIl.Highlight then local _lIlIlIIlIl = (_IIlIIIIllI and _IIIIlIIIlI) and _IIIIIIlllI or nil if _IIlIIIIlIl.Highlight.Parent ~= _lIlIlIIlIl then _lIllllIIIl(_IIlIIIIlIl.Highlight, _lIlIlIIlIl) end
 if _lIlIlIIlIl then _IIlIIIIlIl.Highlight.FillColor = _IIIlIllIII _IIlIIIIlIl.Highlight.OutlineColor = _IIIlIllIII end
 end
 if _IIlIIIIlIl.Box then if _lllIlIlIlI and _IIIIlIIIlI then _IIlIIIIlIl.Box.Adornee = _lllllllIII _IIlIIIIlIl.Box.Size = Vector3.new(0x4, 6.5, 0x2) _IIlIIIIlIl.Box.Color3 = _IIIlIllIII _IIlIIIIlIl.Box.Visible = true else _IIlIIIIlIl.Box.Visible = false end
 end
 if _IIlIIIIlIl.Bones and #_IIlIIIIlIl.Bones > 0x0 then for _lIIlllIIlI, bone in ipairs(_IIlIIIIlIl.Bones) do if bone and bone.Line then local _lIIIlIIIll = _IIIIIIlllI:FindFirstChild(bone.A) local _lIIlIlIIII = _IIIIIIlllI:FindFirstChild(bone.B) if _IIlIIlIIII and _IIIIlIIIlI and _lIIIlIIIll and _lIIlIlIIII then local _llIIllIlII, pb = _lIIIlIIIll.Position, _lIIlIlIIII.Position bone.Line.Adornee = _lIIllIlIll bone.Line.CFrame = CFrame.lookAt(_llIIllIlII, pb) bone.Line.Length = (pb - _llIIllIlII).Magnitude bone.Line.Color3 = _IIIlIllIII bone.Line.Visible = true else bone.Line.Visible = false end
 end
 end
 end
 if _IIlIIIIlIl.Tracer then if _lllllllIlI and _lIIIIIIlll and _Illlllllll then local _IIlIIllIII, to = _lIIIIIIlll.Position, _lllllllIII.Position _IIlIIIIlIl.Tracer.Adornee = _lIIllIlIll _IIlIIIIlIl.Tracer.CFrame = CFrame.lookAt(_IIlIIllIII, to) _IIlIIIIlIl.Tracer.Length = (to - _IIlIIllIII).Magnitude _IIlIIIIlIl.Tracer.Color3 = _IIIlIllIII _IIlIIIIlIl.Tracer.Visible = true else _IIlIIIIlIl.Tracer.Visible = false end
 end
 end
 end
 end
 local _IIIlIIIIlI = { ["\22836\37096"] = "\072\101\097\100", ["\36527\24178\040\26681\041"] = "\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116", ["\36527\24178"] = "\084\111\114\115\111", ["\19978\21322\36523"] = "\085\112\112\101\114\084\111\114\115\111", ["\19979\21322\36523"] = "\076\111\119\101\114\084\111\114\115\111", } local function _IIIIIlIIII() local _lllIIIIIIl = _IIlllIllIl("\065\073\077\066\079\084\095\080\065\082\084", "\22836\37096") return _IIIlIIIIlI[_lllIIIIIIl] or "\072\101\097\100" end
 local function _llIIllIIII(_IIIIIIlllI) local _llIIIIllIl = _IIIIIIlllI:FindFirstChild(_IIIIIlIIII()) or _IIIIIIlllI:FindFirstChild("\072\101\097\100") if _llIIIIllIl then return _llIIIIllIl.Position end
 local _lllllllIII = _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") return _lllllllIII and _lllllllIII.Position or nil end
 local function _lIlIIlllll() if not _lIIIIllIII("\065\073\077\066\079\084") then return nil end
 local _llIIlIlIIl = _lIlIlIlIIl() if not _llIIlIlIIl then return nil end
 local _IlllllIllI = _IlIIlIlIIl() if not _IlllllIllI then return nil end
 local _IIIllIIIlI = _llIIlIlIIl.ViewportSize / 0x2 local _IllIllIlII = _lIIllIIlIl("\065\073\077\066\079\084\095\070\079\086", 0x96) local _llIlIllIll = _IIIIIlIIII() local _IIIIlIllII, bestDist = nil, math.huge for _lIIlllIIlI, enemy in ipairs(Players:GetPlayers()) do if enemy ~= _IlllllIllI then local _IIIIIIlllI = enemy.Character if _IIIIIIlllI and _IIIIIIlllI:FindFirstChild("\072\117\109\097\110\111\105\100") and _IIIIIIlllI.Humanoid.Health > 0x0 then local _llIIIIllIl = _IIIIIIlllI:FindFirstChild(_llIlIllIll) or _IIIIIIlllI:FindFirstChild("\072\101\097\100") if _llIIIIllIl then local _IIlllIIIIl, onScreen = _llIIlIlIIl:WorldToViewportPoint(_llIIIIllIl.Position) if onScreen then local _IlIIIllIII = (Vector2.new(_IIlllIIIIl.X, _IIlllIIIIl.Y) - _IIIllIIIlI).Magnitude if _IlIIIllIII <= _IllIllIlII and _IlIIIllIII < bestDist then _IIIIlIllII, bestDist = enemy, _IlIIIllIII end
 end
 end
 end
 end
 end
 return _IIIIlIllII end
 local function _IIIIllllIl() if not _lIIIIllIII("\065\073\077\066\079\084") then return end
 local _llIIlIlIIl = _lIlIlIlIIl() if not _llIIlIlIIl then return end
 local _lllllIlIll = _lIlIIlllll() if not _lllllIlIll then return end
 local _IIIllIIIlI = _llIIllIIII(_lllllIlIll.Character) if not _IIIllIIIlI then return end
 local _lIlIlllIll = CFrame.lookAt(_llIIlIlIIl.CFrame.Position, _IIIllIIIlI) local _IlIIIlIIII = math.max(_lIIllIIlIl("\065\073\077\066\079\084\095\083\077\079\079\084\072", 0x1), 0x1) if _IlIIIlIIII <= 0x1 then _llIIlIlIIl.CFrame = _lIlIlllIll else _llIIlIlIIl.CFrame = _llIIlIlIIl.CFrame:Lerp(_lIlIlllIll, 0x1 / _IlIIIlIIII) end
 end
 local function _lllIIlIIII() if _IIlIIIIlII.FovGui and _IIlIIIIlII.FovGui.Parent then return true end
 if _IIlIIIIlII.FovUnavailable then return false end
 local _IIIlIlIlII = _IIllllIlIl() if not _IIIlIlIlII then _IIlIIIIlII.FovUnavailable = true _llIlIIIlll("\102\111\118\045\110\111\045\112\097\114\101\110\116", "\21151\33021\19981\21487\29992", "\25214\19981\21040\21487\29992\30340\032\071\085\073\032\23481\22120\65292\35270\37326\22280\24050\20572\29992", 0x6) _llllIllIll("\119\097\114\110", "\25214\19981\21040\21487\29992\30340\032\071\085\073\032\23481\22120\65292\35270\37326\22280\24050\20572\29992") return false end
 local _llllllIIII = Services.GuiService:GetGuiInset() local _IllIllIlII = _lIIllIIlIl("\065\073\077\066\079\084\095\070\079\086", 0x96) local _IlIIIlIIlI = Instance.new("\083\099\114\101\101\110\071\117\105") _IlIIIlIIlI.Name = "\086\070\079\086" _IlIIIlIIlI.ResetOnSpawn = false _IlIIIlIIlI.IgnoreGuiInset = false _IlIIIlIIlI.DisplayOrder = 0x3E6 local _lIllllIIll, err = pcall( function () _IlIIIlIIlI.Parent = _IIIlIlIlII end
 ) if not _lIllllIIll then _IlIIIlIIlI:Destroy() _IIlIIIIlII.FovUnavailable = true _llIlIIIlll("\102\111\118\045\110\111\045\109\111\117\110\116", "\21151\33021\19981\21487\29992", "\35270\37326\22280\25346\36733\22833\36133\65292\24050\20572\29992", 0x6) _llllIllIll("\119\097\114\110", "\35270\37326\22280\25346\36733\22833\36133\65292\24050\20572\29992\65306" .. tostring(err)) return false end
 local _lllIllIlII = Instance.new("\070\114\097\109\101") _lllIllIlII.Name = "\067\105\114\099\108\101" _lllIllIlII.AnchorPoint = Vector2.new(0.5, 0.5) _lllIllIlII.Position = UDim2.new(0.5, 0x0, 0.5, _llllllIIII.Y / 0x2) _lllIllIlII.Size = UDim2.fromOffset(_IllIllIlII * 0x2, _IllIllIlII * 0x2) _lllIllIlII.BackgroundTransparency = 0x1 _lllIllIlII.Parent = _IlIIIlIIlI local _lllIlIlIII = Instance.new("\085\073\067\111\114\110\101\114") _lllIlIlIII.CornerRadius = UDim.new(0x1, 0x0) _lllIlIlIII.Parent = _lllIllIlII local _llIlllIIII = Instance.new("\085\073\083\116\114\111\107\101") _llIlllIIII.Color = _IIlllIllIl("\070\079\086\095\067\079\076\079\082", _llllIllllI) _llIlllIIII.Thickness = 0x2 _llIlllIIII.Transparency = 0x0 _llIlllIIII.ApplyStrokeMode = Enum.ApplyStrokeMode.Border _llIlllIIII.Parent = _lllIllIlII _IIlIIIIlII.FovGui = _IlIIIlIIlI _IIlIIIIlII.FovFrame = _lllIllIlII _IIlIIIIlII.FovStroke = _llIlllIIII return true end
 local function _llIIIIIIll() if not _lIIIIllIII("\065\073\077\066\079\084\095\083\072\079\087\070\079\086") then if _IIlIIIIlII.FovGui then _IIlIIIIlII.FovGui.Enabled = false end
 return end
 if not _lllIIlIIII() then return end
 if not (_IIlIIIIlII.FovFrame and _IIlIIIIlII.FovStroke) then return end
 local _IllIllIlII = _lIIllIIlIl("\065\073\077\066\079\084\095\070\079\086", 0x96) _IIlIIIIlII.FovGui.Enabled = true _IIlIIIIlII.FovFrame.Size = UDim2.fromOffset(_IllIllIlII * 0x2, _IllIllIlII * 0x2) _IIlIIIIlII.FovStroke.Color = _IIlllIllIl("\070\079\086\095\067\079\076\079\082", _llllIllllI) _IIlIIIIlII.FovStroke.Thickness = 0x2 end
 local _IlIlIIlIIl = nil local _lIIIllIlII = nil local _IllIIIllll = 0x0 local function _IIIIIlIlIl() if _IlIlIIlIIl then return end
 _IlIlIIlIIl = RunService.RenderStepped:Connect( function () if _lIIIIllIII("\065\073\077\066\079\084") then _IIIIllllIl() end
 if _lIIIIllIII("\069\083\080") then _IllIIIIllI() end
 end
 ) _lIIIllIlII = RunService.Heartbeat:Connect( function (delta) if not _lIIIIllIII("\069\083\080") then return end
 _IllIIIllll = _IllIIIllll + delta if _IllIIIllll >= 0.12 then _IllIIIllll = 0x0 _llIIllIIlI() end
 end
 ) end
 local _IIllIlIIII = false local function _lIlllIIIll() if _IlIlIIlIIl then _IlIlIIlIIl:Disconnect() _IlIlIIlIIl = nil end
 if _lIIIllIlII then _lIIIllIlII:Disconnect() _lIIIllIlII = nil end
 _lllIIIIIlI() if _IIIllllIIl.AdornFolder then _IIIllllIIl.AdornFolder:Destroy() _IIIllllIIl.AdornFolder = nil end
 if _IIlIIIIlII.FovGui then _IIlIIIIlII.FovGui:Destroy() _IIlIIIIlII.FovGui = nil _IIlIIIIlII.FovFrame = nil _IIlIIIIlII.FovStroke = nil end
 _lIllIllIII() end
 local function _IlIIlIlIlI() if type(getgenv) ~= "\102\117\110\099\116\105\111\110" then return end
 local _IlIIIIlIll = getgenv() _IlIIIIlIll.VLib = nil _IlIIIIlIll.VWindow = nil _IlIIIIlIll.UI = nil _IlIIIIlIll.VUniverse = nil _IlIIIIlIll.V_ESP = nil _IlIIIIlIll.V_AIMBOT = nil _IlIIIIlIll.V_CONFIG = nil _IlIIIIlIll.V_RUNTIME = nil _IlIIIIlIll.V_SHUTDOWN = nil _IlIIIIlIll.V_ENV = nil if _IlIIIIlIll.V_TOKEN == _lIIlIlllII then _IlIIIIlIll.V_TOKEN = nil end
 end
 local function _IllIIllIIl() if _IIllIlIIII then return end
 _IIllIlIIII = true _lIlllIIIll() local _IIIIlIllII, notifyErr = pcall( function () _lllllIllII:MakeNotification({ Name = "\24050\36864\20986", Content = "\25152\26377\21151\33021\24050\20572\27490\65292\30028\38754\27491\22312\28165\29702\12290", Time = 0x2, }) end
 ) if not _IIIIlIllII then _llllIllIll("\119\097\114\110", "\36864\20986\25552\31034\21019\24314\22833\36133\65306" .. tostring(notifyErr)) end
 task.delay(0.75, function () local _IlIllIlIII, destroyErr = pcall( function () _lllllIllII:Destroy() end
 ) if not _IlIllIlIII then _llllIllIll("\119\097\114\110", "\36864\20986\26102\38144\27585\30028\38754\22833\36133\65306" .. tostring(destroyErr)) end
 _IlIIlIlIlI() print("\091\086\093\032\33050\26412\24050\36864\20986\65306\24490\29615\24050\26029\24320\65292\30028\38754\19982\36816\34892\30165\36857\24050\28165\29702\12290") end
 ) end
 local _IIlIlIIlll = { Root = "\086\067\111\109\098\097\116", IndexFile = "\103\097\109\101\115\046\106\115\111\110", ProfileFile = "\112\114\111\102\105\108\101\115\046\106\115\111\110", LegacyFile = "\112\114\111\102\105\108\101\115\046\106\115\111\110", UniversalKey = "\117\110\105\118\101\114\115\097\108", MaxProfiles = 0x5, Format = 0x3, Scope = nil, GameList = {}, Data = { _IIllIIIIlI = nil, _IIIIllIlIl = {}, profiles = {}, meta = {} }, Defaults = nil, Syncing = false, Ready = false, } local _lIllIlIIlI local _llIIIIIIIl local _lllIllIlll local _lIllllIlII = { folders = type(isfolder) == "\102\117\110\099\116\105\111\110" and type(makefolder) == "\102\117\110\099\116\105\111\110", read = type(isfile) == "\102\117\110\099\116\105\111\110" and type(readfile) == "\102\117\110\099\116\105\111\110", write = type(writefile) == "\102\117\110\099\116\105\111\110", } _lIllllIlII.full = _lIllllIlII.folders and _lIllllIlII.read and _lIllllIlII.write local function _llllIIlIlI(_lIllIIllIl, child) if _lIllIIllIl:sub(-0x1) == "\047" then return _lIllIIllIl .. child end
 return _lIllIIllIl .. "\047" .. child end
 local function _lllIllIllI(path) if not _lIllllIlII.folders then return false, "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\22841\25805\20316" end
 if isfolder(path) then return true end
 local _IlIllIlIIl = "" for segment in string.gmatch(path, "\091\094\047\092\092\093\043") do _IlIllIlIIl = (_IlIllIlIIl == "") and segment or (_IlIllIlIIl .. "\047" .. segment) if not isfolder(_IlIllIlIIl) then local _lIllllIIll, err = pcall(makefolder, _IlIllIlIIl) if not _lIllllIIll then return false, "\21019\24314\30446\24405\22833\36133\65288" .. _IlIllIlIIl .. "\65289\65306" .. tostring(err) end
 end
 end
 if isfolder(path) then return true end
 return false, "\21019\24314\30446\24405\22833\36133\65306" .. path end
 local function _IllIllIIll(path) return _lIllllIlII.read and isfile(path) or false end
 local function _lllIIlIllI(path) if not _lIllllIlII.read then return nil, { _llIllIllII = "\117\110\115\117\112\112\111\114\116\101\100", message = "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\35835\21462" } end
 if not isfile(path) then return nil, nil end
 local _lIlIIlIIII, _IllIIIlIlI = pcall(readfile, path) if not _lIlIIlIIII then return nil, { _llIllIllII = "\105\111", message = "\35835\21462\37197\32622\22833\36133\65306" .. tostring(_IllIIIlIlI) } end
 if type(_IllIIIlIlI) ~= "\115\116\114\105\110\103" or _IllIIIlIlI:match("\094\037\115\042\036") then return nil, { _llIllIllII = "\101\109\112\116\121", message = "\37197\32622\25991\20214\20026\31354" } end
 local _lllIIIlIll, decoded = pcall(HttpService.JSONDecode, HttpService, _IllIIIlIlI) if not _lllIIIlIll then return nil, { _llIllIllII = "\099\111\114\114\117\112\116", message = "\074\083\079\078\032\35299\26512\22833\36133\65306" .. tostring(decoded) } end
 if type(decoded) ~= "\116\097\098\108\101" then return nil, { _llIllIllII = "\115\104\097\112\101", message = "\37197\32622\26681\33410\28857\19981\26159\23545\35937" } end
 return decoded, nil end
 local function _IllIlIIIll(path, _lIlIIllIII) if not _lIllllIlII.write then return false, "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\20889\20837" end
 local _lIIlIIIIlI = path:match("\094\040\046\042\041\047\091\094\047\093\043\036") if _lIIlIIIIlI then local _lIllllIIll, err = _lllIllIllI(_lIIlIIIIlI) if not _lIllllIIll then return false, err end
 end
 local _lIllIIlIII, _IllIIIIllI = pcall(HttpService.JSONEncode, HttpService, _lIlIIllIII) if not _lIllIIlIII then return false, "\37197\32622\24207\21015\21270\22833\36133\65306" .. tostring(_IllIIIIllI) end
 local _IIlIIllIll, err = pcall(writefile, path, _IllIIIIllI) if not _IIlIIllIll then return false, "\20889\20837\37197\32622\22833\36133\65306" .. tostring(err) end
 return true end
 local function _IlllIlIlll(path, backupPath) if not (_lIllllIlII.read and _lIllllIlII.write) or not isfile(path) then return end
 local _lIlIIlIIII, _IllIIIlIlI = pcall(readfile, path) if not _lIlIIlIIII then _llllIllIll("\119\097\114\110", "\22791\20221\22833\36133\65288\35835\21462\65289\65306" .. tostring(_IllIIIlIlI)) return end
 local _lIIlIIIIlI = backupPath:match("\094\040\046\042\041\047\091\094\047\093\043\036") if _lIIlIIIIlI then local _IIlIlIlllI = _lllIllIllI(_lIIlIIIIlI) if not _IIlIlIlllI then return end
 end
 local _IIlIIllIll, err = pcall(writefile, backupPath, _IllIIIlIlI) if not _IIlIIllIll then _llllIllIll("\119\097\114\110", "\22791\20221\22833\36133\65288\20889\20837\65289\65306" .. tostring(err)) else _llllIllIll("\105\110\102\111", "\24050\22791\20221\21040\032" .. backupPath) end
 end
 local _IIlllllllI = {} for _IllIlllIll, _IIlIIlllll in pairs(_llIIIIllIl) do _IIlllllllI[_IllIlllIll] = _IIlIIlllll.name end
 local function _IlllIlIlIl(_lIIIllllIl, _IllIlllIll) if type(_lIIIllllIl) ~= "\115\116\114\105\110\103" then return "\080\108\097\099\101\073\100\032" .. tostring(_IllIlllIll) end
 _lIIIllllIl = _lIIIllllIl:match("\094\037\115\042\040\046\045\041\037\115\042\036") if _lIIIllllIl == "" or _lIIIllllIl == "\080\108\097\099\101" then return "\080\108\097\099\101\073\100\032" .. tostring(_IllIlllIll) end
 return _lIIIllllIl end
 local function _lIlIlIIIll(_IllIlllIll, _lIIIllllIl, _IlllIIllII) local _llIlIIllll = os.time() return { PlaceId = _IllIlllIll, Name = _IlllIlIlIl(_lIIIllllIl, _IllIlllIll), AddedAt = tonumber(_IlllIIllII) or _llIlIIllll, LastSeenAt = _llIlIIllll, } end
 local function _lIIIlIIlII(_IllIIIlIlI) local _lIIIllIlll = {} local _IllIllIlII = 0x0 local _IlIIIlllII = _IllIIIlIlI if type(_IlIIIlllII) == "\116\097\098\108\101" and type(_IlIIIlllII.games) == "\116\097\098\108\101" then _IlIIIlllII = _IlIIIlllII.games end
 if type(_IlIIIlllII) ~= "\116\097\098\108\101" then return _lIIIllIlll, _IllIllIlII end
 for _llIlIIlIlI, _IIlIIlllll in pairs(_IlIIIlllII) do local _IllIlllIll local _lIIIllllIl local _IlllIIllII local _IlIlIIllII if type(_IIlIIlllll) == "\116\097\098\108\101" then _IllIlllIll = tonumber(_IIlIIlllll.PlaceId) or tonumber(_llIlIIlIlI) _lIIIllllIl = _IIlIIlllll.Name _IlllIIllII = tonumber(_IIlIIlllll.AddedAt) _IlIlIIllII = tonumber(_IIlIIlllll.LastSeenAt) else _IllIlllIll = tonumber(_llIlIIlIlI) _lIIIllllIl = _IIlIIlllll end
 if _IllIlllIll and _IllIlllIll > 0x0 and _IllIlllIll % 0x1 == 0x0 then local _lIlIIIllll = _lIlIlIIIll(_IllIlllIll, _lIIIllllIl, _IlllIIllII) if _IlIlIIllII then _lIlIIIllll.LastSeenAt = _IlIlIIllII end
 _lIIIllIlll[tostring(_IllIlllIll)] = _lIlIIIllll else _IllIllIlII = _IllIllIlII + 0x1 end
 end
 return _lIIIllIlll, _IllIllIlII end
 local function _lllIlllIll() local _lIlIIIIIll = {} if not _lIllllIlII.folders or type(listfiles) ~= "\102\117\110\099\116\105\111\110" then return _lIlIIIIIll end
 local _lIllllIIll, listing = pcall(listfiles, _IIlIlIIlll.Root) if not _lIllllIIll or type(listing) ~= "\116\097\098\108\101" then return _lIlIIIIIll end
 for _lIIlllIIlI, _lIlIIIllll in ipairs(listing) do if type(_lIlIIIllll) == "\115\116\114\105\110\103" then local _lIllIIllIl = _lIlIIIllll:match("\040\091\094\047\092\092\093\043\041\036") or _lIlIIIllll local _lIlIIIIlIl = _lIllIIllIl:match("\094\040\037\100\043\041\036") local _IllIlllIll = _lIlIIIIlIl and tonumber(_lIlIIIIlIl) if _IllIlllIll and _IllIlllIll > 0x0 and isfolder(_llllIIlIlI(_IIlIlIIlll.Root, _lIllIIllIl)) then _lIlIIIIIll[tostring(_IllIlllIll)] = _lIlIlIIIll(_IllIlllIll, nil) end
 end
 end
 return _lIlIIIIIll end
 local function _IllllIlIlI() local _lIIIllIlll = {} for _llIlIIlIlI, _lIIIllllIl in pairs(_IIlllllllI) do local _IllIlllIll = tonumber(_llIlIIlIlI) if _IllIlllIll and _IllIlllIll > 0x0 then _lIIIllIlll[tostring(_IllIlllIll)] = _lIlIlIIIll(_IllIlllIll, _lIIIllllIl) end
 end
 for _llIlIIlIlI, _IIlIIlllll in pairs(_lllIlllIll()) do _lIIIllIlll[_llIlIIlIlI] = _IIlIIlllll end
 return _lIIIllIlll end
 local function _llIIIIlllI() if not _lIllllIlII.write then return false, "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\20889\20837" end
 local _lIllllIIll, err = _IllIlIIIll(_llllIIlIlI(_IIlIlIIlll.Root, _IIlIlIIlll.IndexFile), { format = _IIlIlIIlll.Format, _lIIIllIlll = _IIlIlIIlll.GameList, }) if not _lIllllIIll then _llllIllIll("\119\097\114\110", "\28216\25103\21015\34920\20889\20837\22833\36133\65306" .. tostring(err)) end
 return _lIllllIIll, err end
 local function _IlIllllIlI() local _IlllIIlIll = _llllIIlIlI(_IIlIlIIlll.Root, _IIlIlIIlll.IndexFile) local _lIlIIllIII, issue = _lllIIlIllI(_IlllIIlIll) local _lIIIllIlll = {} local _IllIllIlII = 0x0 if _lIlIIllIII then _lIIIllIlll, _IllIllIlII = _lIIIlIIlII(_lIlIIllIII) else _lIIIllIlll = _IllllIlIlI() if issue and issue.kind ~= "\117\110\115\117\112\112\111\114\116\101\100" then _IlllIlIlll(_IlllIIlIll, _llllIIlIlI(_IIlIlIIlll.Root, "\103\097\109\101\115\046\099\111\114\114\117\112\116\046\106\115\111\110")) _llIlIIIlll("\103\097\109\101\115\045\105\115\115\117\101", "\28216\25103\21015\34920\35835\21462\24322\24120", issue.message .. "\65307\24050\25353\30446\24405\37325\24314", 0x6) _llllIllIll("\119\097\114\110", "\28216\25103\21015\34920\65306" .. issue.message) end
 _IIlIlIIlll.GameList = _lIIIllIlll if _lIllllIlII.write then _llIIIIlllI() end
 end
 _IIlIlIIlll.GameList = _lIIIllIlll if _IllIllIlII > 0x0 then _llllIllIll("\105\110\102\111", string.format("\28216\25103\21015\34920\20013\26377\032\037\100\032\39033\26684\24335\26080\25928\65292\24050\24573\30053", _IllIllIlII)) end
 end
 function _IIlIlIIlll.isKnown(_IllIlllIll) local _lIllIllIII = tonumber(_IllIlllIll) if not _lIllIllIII or _lIllIllIII <= 0x0 then return false end
 return _IIlIlIIlll.GameList[tostring(_lIllIllIII)] ~= nil end
 function _IIlIlIIlll.getGames() local _llIllllIIl = {} for _lIIlllIIlI, _IIlIIlllll in pairs(_IIlIlIIlll.GameList) do _llIllllIIl[#_llIllllIIl + 0x1] = _IIlIIlllll end
 table.sort(_llIllllIIl, function (_lIIIlIIIll, _lIIlIlIIII) return _lIIIlIIIll.PlaceId < _lIIlIlIIII.PlaceId end
 ) return _llIllllIIl end
 local function _IllIllllIl(_llIllIllII, _IllIlllIll, _IIlIIlllll) local _llIlIIlIlI = (_llIllIllII == "\103\097\109\101") and tostring(_IllIlllIll) or _IIlIlIIlll.UniversalKey local _lIIlIIIIlI = _llllIIlIlI(_IIlIlIIlll.Root, _llIlIIlIlI) return { Kind = _llIllIllII, Key = _llIlIIlIlI, PlaceId = tonumber(_IllIlllIll) or 0x0, Name = (_llIllIllII == "\103\097\109\101") and (_IIlIIlllll and _IIlIIlllll.Name or ("\080\108\097\099\101\073\100\032" .. tostring(_IllIlllIll))) or "\36890\29992\37197\32622", Folder = _lIIlIIIIlI, Path = _llllIIlIlI(_lIIlIIIIlI, _IIlIlIIlll.ProfileFile), } end
 function _IIlIlIIlll.resolveScope() local _IllIlllIll = tonumber(game.PlaceId) or 0x0 if _IllIlllIll > 0x0 and _IIlIlIIlll.isKnown(_IllIlllIll) then return _IllIllllIl("\103\097\109\101", _IllIlllIll, _IIlIlIIlll.GameList[tostring(_IllIlllIll)]) end
 return _IllIllllIl("\117\110\105\118\101\114\115\097\108", _IllIlllIll, nil) end
 function _IIlIlIIlll.getScope() return _IIlIlIIlll.Scope end
 local function _IllIIlIllI(_IllIlllIII) if not _IllIlllIII then return "\26410\21021\22987\21270" end
 if _IllIlllIII.Kind == "\103\097\109\101" then return string.format("\037\115\65288\080\108\097\099\101\073\100\032\037\100\65289", _IllIlllIII.Name, _IllIlllIII.PlaceId) end
 return string.format("\36890\29992\37197\32622\65288\080\108\097\099\101\073\100\032\037\100\032\26410\25910\24405\65289", _IllIlllIII.PlaceId) end
 local function _lIIllIlIIl(_lllIllIIII) if type(_lllIllIIII) ~= "\116\097\098\108\101" then return _lllIllIIII end
 local _IIlIIIllIl = {} for _llIlIIlIlI, _lIlIIIllll in pairs(_lllIllIIII) do _IIlIIIllIl[_llIlIIlIlI] = _lIIllIlIIl(_lIlIIIllll) end
 return _IIlIIIllIl end
 local function _lIlIlIIIIl(_IIIlIllIII) return { __color = true, _IIlllIIIII = math.floor(_IIIlIllIII.R * 0xFF + 0.5), _lIlllllIlI = math.floor(_IIIlIllIII.G * 0xFF + 0.5), _lIIlIlIIII = math.floor(_IIIlIllIII.B * 0xFF + 0.5), } end
 local function _IlllIllllI(_lIlIIIIIII) if not _lIlIIIIIII then return nil end
 local _lllIllIIII = _lIlIIIIIII.Value if _lIlIIIIIII.Type == "\067\111\108\111\114\112\105\099\107\101\114" then if typeof(_lllIllIIII) ~= "\067\111\108\111\114\051" then return nil end
 return _lIlIlIIIIl(_lllIllIIII) end
 if _lIlIIIIIII.Type == "\068\114\111\112\100\111\119\110" then if type(_lllIllIIII) ~= "\115\116\114\105\110\103" then return nil end
 if _lIlIIIIIII.Options and not table.find(_lIlIIIIIII.Options, _lllIllIIII) then return _lIlIIIIIII.Options[0x1] end
 return _lllIllIIII end
 if type(_lllIllIIII) == "\098\111\111\108\101\097\110" or type(_lllIllIIII) == "\110\117\109\098\101\114" or type(_lllIllIIII) == "\115\116\114\105\110\103" then return _lllIllIIII end
 return nil end
 local function _lIIIIIlIlI() local _IIllIIlllI = {} for flag, _lIlIIIIIII in pairs(_IlllIIlIlI) do local _IllIIIIllI = _IlllIllllI(_lIlIIIIIII) if _IllIIIIllI ~= nil then _IIllIIlllI[flag] = _IllIIIIllI end
 end
 return _IIllIIlllI end
 local function _IlllllIIll(flag, _lIlIIIIIII) local _IllllIlIlI = _IIlIlIIlll.Defaults if _IllllIlIlI and _IllllIlIlI[flag] ~= nil then return _lIIllIlIIl(_IllllIlIlI[flag]) end
 return _IlllIllllI(_lIlIIIIIII) end
 local function _IlIlllIIII(_IllIIIlIlI) if type(_IllIIIlIlI) ~= "\116\097\098\108\101" then return nil, "\39068\33394\26684\24335\26080\25928" end
 local _IIlllIIIII = tonumber(_IllIIIlIlI.r or _IllIIIlIlI.R) local _lIlllllIlI = tonumber(_IllIIIlIlI.g or _IllIIIlIlI.G) local _lIIlIlIIII = tonumber(_IllIIIlIlI.b or _IllIIIlIlI.B) if not _IIlllIIIII or not _lIlllllIlI or not _lIIlIlIIII then return nil, "\39068\33394\20998\37327\19981\26159\25968\23383" end
 if _IIlllIIIII < 0x0 or _IIlllIIIII > 0xFF or _lIlllllIlI < 0x0 or _lIlllllIlI > 0xFF or _lIIlIlIIII < 0x0 or _lIIlIlIIII > 0xFF then return nil, "\39068\33394\20998\37327\36229\20986\032\048\045\050\053\053" end
 return Color3.fromRGB(_IIlllIIIII, _lIlllllIlI, _lIIlIlIIII) end
 local function _IllIlIllll(_lIIIllllIl) if _lIIIllllIl == "\085\110\107\110\111\119\110" then return true end
 if Enum.KeyCode[_lIIIllllIl] then return true end
 if Enum.UserInputType[_lIIIllllIl] then return true end
 return false end
 local function _lIlIlIlIll(_lIlIIIIIII, _IllIIIlIlI) local _llIllIllII = _lIlIIIIIII.Type if _llIllIllII == "\084\111\103\103\108\101" then if type(_IllIIIlIlI) ~= "\098\111\111\108\101\097\110" then return nil, "\38656\35201\032\116\114\117\101\047\102\097\108\115\101" end
 return _IllIIIlIlI elseif _llIllIllII == "\083\108\105\100\101\114" then local _lIIlIIllII = tonumber(_IllIIIlIlI) if not _lIIlIIllII or _lIIlIIllII ~= _lIIlIIllII or _lIIlIIllII == math.huge or _lIIlIIllII == -math.huge then return nil, "\38656\35201\26377\25928\25968\23383" end
 return _lIIlIIllII elseif _llIllIllII == "\068\114\111\112\100\111\119\110" then if type(_IllIIIlIlI) ~= "\115\116\114\105\110\103" then return nil, "\38656\35201\23383\31526\20018" end
 if _lIlIIIIIII.Options and not table.find(_lIlIIIIIII.Options, _IllIIIlIlI) then return nil, "\36873\39033\19981\23384\22312\65288" .. _IllIIIlIlI .. "\65289" end
 return _IllIIIlIlI elseif _llIllIllII == "\067\111\108\111\114\112\105\099\107\101\114" then return _IlIlllIIII(_IllIIIlIlI) elseif _llIllIllII == "\084\101\120\116\098\111\120" then if type(_IllIIIlIlI) ~= "\115\116\114\105\110\103" then return nil, "\38656\35201\23383\31526\20018" end
 return _IllIIIlIlI elseif _llIllIllII == "\066\105\110\100" then if type(_IllIIIlIlI) ~= "\115\116\114\105\110\103" then return nil, "\38656\35201\25353\38190\21517\31216" end
 if not _IllIlIllll(_IllIIIlIlI) then return nil, "\26410\30693\25353\38190\65288" .. _IllIIIlIlI .. "\65289" end
 return _IllIIIlIlI end
 return nil, "\26410\30693\25511\20214\31867\22411" end
 local function _lIIlllIllI(_IIllIIlllI) local _IIlIIIllIl = { values = {}, removed = {}, added = {}, fixed = {} } local _IlIIIlllII = (type(_IIllIIlllI) == "\116\097\098\108\101") and _IIllIIlllI or {} for flag in pairs(_IlIIIlllII) do if type(flag) ~= "\115\116\114\105\110\103" or _IlllIIlIlI[flag] == nil then _IIlIIIllIl.removed[#_IIlIIIllIl.removed + 0x1] = tostring(flag) end
 end
 for flag, _lIlIIIIIII in pairs(_IlllIIlIlI) do local _IllIIIlIlI = _IlIIIlllII[flag] if _IllIIIlIlI == nil then local _lllIllIIII = _IlllllIIll(flag, _lIlIIIIIII) if _lllIllIIII ~= nil then _IIlIIIllIl.values[flag] = _lllIllIIII _IIlIIIllIl.added[#_IIlIIIllIl.added + 0x1] = flag end
 else local _lllIllIIII, reason = _lIlIlIlIll(_lIlIIIIIII, _IllIIIlIlI) if _lllIllIIII == nil then local _IlIIlIIlII = _IlllllIIll(flag, _lIlIIIIIII) if _IlIIlIIlII ~= nil then _IIlIIIllIl.values[flag] = _IlIIlIIlII end
 _IIlIIIllIl.fixed[#_IIlIIIllIl.fixed + 0x1] = string.format("\037\115\65288\037\115\65289", flag, tostring(reason)) else _IIlIIIllIl.values[flag] = _IllIIIlIlI end
 end
 end
 table.sort(_IIlIIIllIl.removed) table.sort(_IIlIIIllIl.added) table.sort(_IIlIIIllIl.fixed) return _IIlIIIllIl end
 local function _llIIIIllII(_IIllIIlllI) local _llIIIIIllI = { applied = 0x0, invalid = {} } local _IIllIlIlll = {} for flag in pairs(_IlllIIlIlI) do _IIllIlIlll[#_IIllIlIlll + 0x1] = flag end
 table.sort(_IIllIlIlll) _IIlIlIIlll.Syncing = true for _lIIlllIIlI, flag in ipairs(_IIllIlIlll) do local _lIlIIIIIII = _IlllIIlIlI[flag] local _IllIIIlIlI = _IIllIIlllI[flag] if _IllIIIlIlI == nil then _llIIIIIllI.invalid[#_llIIIIIllI.invalid + 0x1] = flag .. "\65288\32570\22833\65289" else local _lllIllIIII, reason = _lIlIlIlIll(_lIlIIIIIII, _IllIIIlIlI) if _lllIllIIII == nil then _llIIIIIllI.invalid[#_llIIIIIllI.invalid + 0x1] = string.format("\037\115\65288\037\115\65289", flag, tostring(reason)) else _lIlIIIIIII:Set(_lllIllIIII) _llIIIIIllI.applied = _llIIIIIllI.applied + 0x1 end
 end
 end
 _IIlIlIIlll.Syncing = false return _llIIIIIllI end
 local function _IlIIllIIII(_lIIlllIIII) local _IIlIlIIlII = {} if #_lIIlllIIII.removed > 0x0 then _IIlIlIIlII[#_IIlIlIIlII + 0x1] = "\31227\38500\032" .. #_lIIlllIIII.removed .. "\032\39033" end
 if #_lIIlllIIII.added > 0x0 then _IIlIlIIlII[#_IIlIlIIlII + 0x1] = "\34917\20805\032" .. #_lIIlllIIII.added .. "\032\39033" end
 if #_lIIlllIIII.fixed > 0x0 then _IIlIlIIlII[#_IIlIlIIlII + 0x1] = "\20462\27491\032" .. #_lIIlllIIII.fixed .. "\032\39033" end
 return table.concat(_IIlIlIIlII, "\032\183\032") end
 local function _llIIlIlIIl(title, _llIllllIIl) if #_llIllllIIl == 0x0 then return end
 local _IIIIlIIlII = {} for index = 0x1, math.min(#_llIllllIIl, 0x8) do _IIIIlIIlII[#_IIIIlIIlII + 0x1] = _llIllllIIl[index] end
 _llllIllIll("\105\110\102\111", title .. table.concat(_IIIIlIIlII, "\044\032") .. (#_llIllllIIl > 0x8 and "\032\8230" or "")) end
 local function _lIIllIllII(_lIIIllllIl, _lIIlllIIII) local _llIIlllIII = _IlIIllIIII(_lIIlllIIII) if _llIIlllIII == "" then return "" end
 _llIlIIIlll("\115\121\110\099\124" .. (_IIlIlIIlll.Scope and _IIlIlIIlll.Scope.Key or "\063") .. "\124" .. _lIIIllllIl .. "\124" .. _llIIlllIII, "\37197\32622\24050\33258\21160\21516\27493", string.format("\12300\037\115\12301\037\115", _lIIIllllIl, _llIIlllIII), 0x6) _llIIlIlIIl(string.format("\37197\32622\12300\037\115\12301\31227\38500\24050\19979\32447\39033\65306", _lIIIllllIl), _lIIlllIIII.removed) _llIIlIlIIl(string.format("\37197\32622\12300\037\115\12301\34917\20805\26032\22686\39033\65306", _lIIIllllIl), _lIIlllIIII.added) _llIIlIlIIl(string.format("\37197\32622\12300\037\115\12301\20462\27491\26080\25928\20540\65306", _lIIIllllIl), _lIIlllIIII.fixed) return _llIIlllIII end
 local function _IlIIIIIIIl() local _IIllIlIlll = {} for _lIIlllIIlI, _lIIIllllIl in ipairs(_IIlIlIIlll.Data.order) do if _IIlIlIIlll.Data.profiles[_lIIIllllIl] then _IIllIlIlll[#_IIllIlIlll + 0x1] = _lIIIllllIl end
 end
 return _IIllIlIlll end
 local function _lIlllllIll() local _lllllIlllI = {} local _IIIIllIlIl = {} for _lIIlllIIlI, _lIIIllllIl in ipairs(_IIlIlIIlll.Data.order or {}) do if type(_lIIIllllIl) == "\115\116\114\105\110\103" and _IIlIlIIlll.Data.profiles[_lIIIllllIl] and not _lllllIlllI[_lIIIllllIl] then _lllllIlllI[_lIIIllllIl] = true _IIIIllIlIl[#_IIIIllIlIl + 0x1] = _lIIIllllIl end
 end
 for _lIIIllllIl in pairs(_IIlIlIIlll.Data.profiles) do if not _lllllIlllI[_lIIIllllIl] then _lllllIlllI[_lIIIllllIl] = true _IIIIllIlIl[#_IIIIllIlIl + 0x1] = _lIIIllllIl end
 end
 _IIlIlIIlll.Data.order = _IIIIllIlIl end
 local function _IlllIIIlII(_IllIIIlIlI, _llIIIIIllI) local _IIlIIIllIl = { _IIllIIIIlI = nil, _IIIIllIlIl = {}, profiles = {}, meta = {} } if type(_IllIIIlIlI) ~= "\116\097\098\108\101" then return _IIlIIIllIl end
 if type(_IllIIIlIlI.meta) == "\116\097\098\108\101" then _IIlIIIllIl.meta = _lIIllIlIIl(_IllIIIlIlI.meta) end
 if type(_IllIIIlIlI.profiles) == "\116\097\098\108\101" then for _lIIIllllIl, _IIllIIlllI in pairs(_IllIIIlIlI.profiles) do if type(_lIIIllllIl) == "\115\116\114\105\110\103" and _lIIIllllIl ~= "" and type(_IIllIIlllI) == "\116\097\098\108\101" then _IIlIIIllIl.profiles[_lIIIllllIl] = _IIllIIlllI else _llIIIIIllI.droppedProfiles = _llIIIIIllI.droppedProfiles + 0x1 end
 end
 end
 if type(_IllIIIlIlI.order) == "\116\097\098\108\101" then for _lIIlllIIlI, _lIIIllllIl in ipairs(_IllIIIlIlI.order) do if type(_lIIIllllIl) == "\115\116\114\105\110\103" and _lIIIllllIl ~= "" then _IIlIIIllIl.order[#_IIlIIIllIl.order + 0x1] = _lIIIllllIl else _llIIIIIllI.droppedOrder = _llIIIIIllI.droppedOrder + 0x1 end
 end
 end
 if type(_IllIIIlIlI.active) == "\115\116\114\105\110\103" then _IIlIIIllIl.active = _IllIIIlIlI.active end
 return _IIlIIIllIl end
 local function _IIllIIlIlI(silent) if not _IIlIlIIlll.Scope then return false, "\37197\32622\20316\29992\22495\26410\21021\22987\21270" end
 if not _lIllllIlII.write then if not silent then _llIlIIIlll("\110\111\045\119\114\105\116\101", "\37197\32622\26410\20889\20837\30913\30424", "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\20889\20837\65292\37197\32622\20165\22312\26412\27425\20250\35805\26377\25928", 0x6) end
 return false, "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\20889\20837" end
 local _lIllllIIll, err = _IllIlIIIll(_IIlIlIIlll.Scope.Path, _IIlIlIIlll.Data) if not _lIllllIIll then _llllIllIll("\119\097\114\110", err) _llIlIIIlll("\119\114\105\116\101\045\102\097\105\108\124" .. _IIlIlIIlll.Scope.Key, "\37197\32622\26410\20889\20837\30913\30424", tostring(err), 0x5) return false, err end
 return true end
 local function _lIlIIIIIIl() if not _lIllIlIIlI then return end
 local _IIllIlIlll = _IlIIIIIIIl() _lIllIlIIlI:Refresh(_IIllIlIlll) _IIlIlIIlll.Syncing = true local _IIllIIIIlI = _IIlIlIIlll.Data.active if _IIllIIIIlI and _IIlIlIIlll.Data.profiles[_IIllIIIIlI] then _lIllIlIIlI:Set(_IIllIIIIlI) elseif _IIllIlIlll[0x1] then _IIlIlIIlll.Data.active = _IIllIlIlll[0x1] _lIllIlIIlI:Set(_IIllIlIlll[0x1]) end
 _IIlIlIIlll.Syncing = false if _lllIllIlll and _IIlIlIIlll.Data.active then _lllIllIlll:Set(_IIlIlIIlll.Data.active) end
 if _llIIIIIIIl then _llIIIIIIIl:Set(string.format("\24403\21069\37197\32622\65306\037\115\032\183\032\26412\20316\29992\22495\20849\032\037\100\032\20010", _IIlIlIIlll.Data.active or "\26410\36873\25321", #_IIllIlIlll)) end
 end
 function _IIlIlIIlll.loadScope(_IllIlllIII) _IIlIlIIlll.Ready = false _IIlIlIIlll.Scope = _IllIlllIII local _lIlIIllIII, issue = _lllIIlIllI(_IllIlllIII.Path) local _llIIIIIllI = { droppedProfiles = 0x0, droppedOrder = 0x0 } local _lIIIIlIllI = not _IllIllIIll(_IllIlllIII.Path) if issue then if issue.kind == "\117\110\115\117\112\112\111\114\116\101\100" then _llIlIIIlll("\102\115\045\117\110\115\117\112\112\111\114\116\101\100", "\37197\32622\25552\31034", "\24403\21069\25191\34892\22120\19981\25903\25345\25991\20214\23384\20648\65292\37197\32622\20165\22312\26412\27425\20250\35805\26377\25928", 0x6) _llllIllIll("\105\110\102\111", issue.message) else if issue.kind ~= "\101\109\112\116\121" then _IlllIlIlll(_IllIlllIII.Path, _llllIIlIlI(_IllIlllIII.Folder, "\112\114\111\102\105\108\101\115\046\099\111\114\114\117\112\116\046\106\115\111\110")) end
 _llIlIIIlll("\115\099\111\112\101\045\105\115\115\117\101\124" .. _IllIlllIII.Key, "\37197\32622\35835\21462\24322\24120", issue.message .. "\65307\24050\20351\29992\40664\35748\37197\32622", 0x6) _llllIllIll("\119\097\114\110", string.format("\20316\29992\22495\032\037\115\65288\037\115\65289\65306\037\115", _IllIlllIII.Key, _IllIlllIII.Path, issue.message)) end
 end
 _IIlIlIIlll.Data = _IlllIIIlII(_lIlIIllIII, _llIIIIIllI) _lIlllllIll() if _llIIIIIllI.droppedProfiles > 0x0 then _llllIllIll("\105\110\102\111", string.format("\24050\24573\30053\032\037\100\032\20010\26684\24335\26080\25928\30340\37197\32622\26723\26696", _llIIIIIllI.droppedProfiles)) end
 if _llIIIIIllI.droppedOrder > 0x0 then _llllIllIll("\105\110\102\111", string.format("\24050\24573\30053\032\037\100\032\20010\26080\25928\30340\37197\32622\39034\24207\39033", _llIIIIIllI.droppedOrder)) end
 if #_IIlIlIIlll.Data.order == 0x0 then _lIIIIlIllI = true local _IIllIIlllI = _IIlIlIIlll.Defaults and _lIIllIlIIl(_IIlIlIIlll.Defaults) or _lIIIIIlIlI() _IIlIlIIlll.Data.profiles["\40664\35748"] = _IIllIIlllI _IIlIlIIlll.Data.order = { "\40664\35748" } _IIlIlIIlll.Data.active = "\40664\35748" end
 if not _IIlIlIIlll.Data.active or not _IIlIlIIlll.Data.profiles[_IIlIlIIlll.Data.active] then local _IlIIlIIlII = _IIlIlIIlll.Data.order[0x1] if _IIlIlIIlll.Data.active and _IlIIlIIlII then _llllIllIll("\105\110\102\111", "\19978\27425\20351\29992\30340\37197\32622\19981\23384\22312\65292\24050\22238\36864\21040\12300" .. _IlIIlIIlII .. "\12301") end
 _IIlIlIIlll.Data.active = _IlIIlIIlII end
 local _lIIIllllIl = _IIlIlIIlll.Data.active local _lIIlllIIII = _lIIlllIllI(_IIlIlIIlll.Data.profiles[_lIIIllllIl]) _IIlIlIIlll.Data.profiles[_lIIIllllIl] = _lIIlllIIII.values _llIIIIllII(_lIIlllIIII.values) _IIlIlIIlll.Data.meta = (type(_IIlIlIIlll.Data.meta) == "\116\097\098\108\101") and _IIlIlIIlll.Data.meta or {} _IIlIlIIlll.Data.meta.format = _IIlIlIIlll.Format _IIlIlIIlll.Data.meta.scope = _IllIlllIII.Kind _IIlIlIIlll.Data.meta.placeId = (_IllIlllIII.Kind == "\103\097\109\101") and _IllIlllIII.PlaceId or 0x0 _IIlIlIIlll.Data.meta.gameName = (_IllIlllIII.Kind == "\103\097\109\101") and _IllIlllIII.Name or nil _IIlIlIIlll.Data.meta.savedAt = os.time() _IIlIlIIlll.Ready = true _lIlIIIIIIl() if _lIllllIlII.write then local _IlIIIlllII, err = _IIllIIlIlI(true) if not _IlIIIlllII then _llllIllIll("\119\097\114\110", err) end
 end
 return { _lIIIIlIllI = _lIIIIlIllI, _lIIIllllIl = _lIIIllllIl, _llIIlllIII = _lIIllIllII(_lIIIllllIl, _lIIlllIIII), } end
 function _IIlIlIIlll.boot() if not _lIllllIlII.full then _llIlIIIlll("\115\116\111\114\097\103\101\045\108\105\109\105\116\101\100", "\37197\32622\23384\20648\21463\38480", "\24403\21069\25191\34892\22120\30340\25991\20214\33021\21147\19981\23436\25972\65292\37197\32622\21487\33021\26080\27861\25345\20037\21270", 0x7) end
 _IlIllllIlI() local _IllIlllIII = _IIlIlIIlll.resolveScope() if _IllIlllIII.Kind == "\103\097\109\101" then local _IIlIIlllll = _IIlIlIIlll.GameList[tostring(_IllIlllIII.PlaceId)] if _IIlIIlllll then _IIlIIlllll.LastSeenAt = os.time() local _IllIlIlllI = tostring(game.Name or "") if _IIlIIlllll.Name:match("\094\080\108\097\099\101\073\100\032") and _IllIlIlllI ~= "" and _IllIlIlllI ~= "\080\108\097\099\101" then _IIlIIlllll.Name = _IllIlIlllI end
 _IllIlllIII.Name = _IIlIIlllll.Name _llIIIIlllI() end
 end
 local _IIlIIIllIl = _IIlIlIIlll.loadScope(_IllIlllIII) local _llIIIlIlll = _llllIIlIlI(_IIlIlIIlll.Root, _IIlIlIIlll.LegacyFile) if _IllIllIIll(_llIIIlIlll) then _llllIllIll("\105\110\102\111", "\26816\27979\21040\26087\29256\37197\32622\032" .. _llIIIlIlll .. "\65292\25353\28216\25103\38548\31163\21518\19981\20877\35835\21462\35813\25991\20214\65288\21407\25991\20214\26410\25913\21160\65289") end
 if _IIlIIIllIl.fresh then if _IllIlllIII.Kind == "\103\097\109\101" then _llIllIllII("\26412\28216\25103\37197\32622\24050\21019\24314", string.format("\24050\20026\12300\037\115\12301\24314\31435\19987\29992\37197\32622\65292\25152\26377\24320\20851\40664\35748\20851\38381\12290", _IllIlllIII.Name), 0x6) else _llIllIllII("\20351\29992\36890\29992\37197\32622", string.format("\24403\21069\032\080\108\097\099\101\073\100\032\037\100\032\26410\25910\24405\65292\24050\21551\29992\36890\29992\37197\32622\65292\25152\26377\24320\20851\40664\35748\20851\38381\12290", _IllIlllIII.PlaceId), 0x7) end
 else _llIllIllII("\37197\32622\24050\23601\32490", string.format("\037\115\032\183\032\37197\32622\12300\037\115\12301\037\115", _IllIIlIllI(_IllIlllIII), _IIlIIIllIl.name or "\40664\35748", _IIlIIIllIl.summary ~= "" and ("\65288" .. _IIlIIIllIl.summary .. "\65289") or "")) end
 return true end
 function _IIlIlIIlll.reload() if not _IIlIlIIlll.Scope then return false, "\37197\32622\23578\26410\21021\22987\21270" end
 if not _lIllllIlII.read then return false, "\24403\21069\25191\34892\22120\19981\25903\25345\35835\21462\37197\32622" end
 local _IIlIIIllIl = _IIlIlIIlll.loadScope(_IIlIlIIlll.Scope) _llIllIllII("\37197\32622\24050\37325\26032\36733\20837", string.format("\037\115\032\183\032\12300\037\115\12301\037\115", _IllIIlIllI(_IIlIlIIlll.Scope), _IIlIIIllIl.name or "\40664\35748", _IIlIIIllIl.summary ~= "" and ("\65288" .. _IIlIIIllIl.summary .. "\65289") or ""), 0x5) return true end
 function _IIlIlIIlll.switchScope(_IllIlllIII) if not _IllIlllIII then return false, "\20316\29992\22495\26080\25928" end
 if _IIlIlIIlll.Scope and _IIlIlIIlll.Scope.Key == _IllIlllIII.Key then return _IIlIlIIlll.reload() end
 local _IIlIIIllIl = _IIlIlIIlll.loadScope(_IllIlllIII) _llIllIllII("\24050\20999\25442\37197\32622\20316\29992\22495", string.format("\037\115\037\115", _IllIIlIllI(_IllIlllIII), _IIlIIIllIl.fresh and "\65288\24050\21019\24314\40664\35748\37197\32622\65292\20840\37096\20851\38381\65289" or ""), 0x6) return true end
 function _IIlIlIIlll.registerGame(_IllIlllIll, _lIIIllllIl) local _lIllIllIII = tonumber(_IllIlllIll) if not _lIllIllIII or _lIllIllIII <= 0x0 or _lIllIllIII % 0x1 ~= 0x0 then return false, "\080\108\097\099\101\073\100\032\26080\25928" end
 if _IIlIlIIlll.isKnown(_lIllIllIII) then return false, "\35813\28216\25103\24050\22312\28216\25103\21015\34920\20013" end
 _IIlIlIIlll.GameList[tostring(_lIllIllIII)] = _lIlIlIIIll(_lIllIllIII, _lIIIllllIl) local _IlIIIlllII, err = _llIIIIlllI() if not _IlIIIlllII and _lIllllIlII.write then _llllIllIll("\119\097\114\110", err) end
 return true end
 function _IIlIlIIlll.unregisterGame(_IllIlllIll) local _lIllIllIII = tonumber(_IllIlllIll) if not _lIllIllIII or not _IIlIlIIlll.isKnown(_lIllIllIII) then return false, "\35813\28216\25103\19981\22312\28216\25103\21015\34920\20013" end
 _IIlIlIIlll.GameList[tostring(_lIllIllIII)] = nil local _IlIIIlllII, err = _llIIIIlllI() if not _IlIIIlllII and _lIllllIlII.write then _llllIllIll("\119\097\114\110", err) end
 if _lIllIllIII == (tonumber(game.PlaceId) or 0x0) then _IIlIlIIlll.loadScope(_IIlIlIIlll.resolveScope()) end
 return true end
 function _IIlIlIIlll.registerCurrentGame() local _IllIlllIll = tonumber(game.PlaceId) or 0x0 if _IllIlllIll <= 0x0 then _llIllIllII("\26080\27861\25910\24405", "\24403\21069\032\080\108\097\099\101\073\100\032\26080\25928\65288\083\116\117\100\105\111\032\26410\21457\24067\22330\26223\19981\25903\25345\19987\29992\37197\32622\65289") return false end
 if _IIlIlIIlll.isKnown(_IllIlllIll) then _llIllIllII("\26080\38656\25910\24405", "\24403\21069\28216\25103\24050\22312\28216\25103\21015\34920\20013") return false end
 local _IllIlIlllI = tostring(game.Name or "") local _lIllllIIll, err = _IIlIlIIlll.registerGame(_IllIlllIll, _IllIlIlllI) if not _lIllllIIll then _llIllIllII("\25910\24405\22833\36133", tostring(err)) return false end
 local _IIlIIIllIl = _IIlIlIIlll.loadScope(_IIlIlIIlll.resolveScope()) _llIllIllII("\24050\25910\24405\24403\21069\28216\25103", string.format("\080\108\097\099\101\073\100\032\037\100\032\24050\21152\20837\28216\25103\21015\34920\037\115\12290", _IllIlllIll, _IIlIIIllIl.fresh and "\65292\19987\29992\37197\32622\40664\35748\20840\37096\20851\38381" or "\65292\24050\36733\20837\21407\26377\19987\29992\37197\32622"), 0x7) return true end
 function _IIlIlIIlll.unregisterCurrentGame() local _IllIlllIll = tonumber(game.PlaceId) or 0x0 if _IllIlllIll <= 0x0 or not _IIlIlIIlll.isKnown(_IllIlllIll) then _llIllIllII("\26080\27861\31227\20986", "\24403\21069\28216\25103\19981\22312\28216\25103\21015\34920\20013") return false end
 _IIlIlIIlll.unregisterGame(_IllIlllIll) _llIllIllII("\24050\31227\20986\28216\25103\21015\34920", string.format( "\080\108\097\099\101\073\100\032\037\100\032\24050\25913\20026\20351\29992\36890\29992\37197\32622\65307\19987\29992\37197\32622\20445\30041\22312\032\037\115", _IllIlllIll, _llllIIlIlI(_IIlIlIIlll.Root, tostring(_IllIlllIll))), 0x8) return true end
 function _IIlIlIIlll.apply(_lIIIllllIl, silent) if not _IIlIlIIlll.Ready then return false, "\37197\32622\23578\26410\36733\20837" end
 if type(_lIIIllllIl) ~= "\115\116\114\105\110\103" or not _IIlIlIIlll.Data.profiles[_lIIIllllIl] then return false, "\37197\32622\19981\23384\22312" end
 local _lIIlllIIII = _lIIlllIllI(_IIlIlIIlll.Data.profiles[_lIIIllllIl]) _IIlIlIIlll.Data.profiles[_lIIIllllIl] = _lIIlllIIII.values _llIIIIllII(_lIIlllIIII.values) local _llIIlllIII = _lIIllIllII(_lIIIllllIl, _lIIlllIIII) _IIlIlIIlll.Data.active = _lIIIllllIl _IIllIIlIlI(true) _lIlIIIIIIl() if not silent then _llIllIllII("\24050\20999\25442\37197\32622", string.format("\037\115\032\183\032\037\115\037\115", _lIIIllllIl, _IllIIlIllI(_IIlIlIIlll.Scope), _llIIlllIII ~= "" and ("\032\183\032" .. _llIIlllIII) or "")) end
 return true end
 function _IIlIlIIlll.save(rawName) if not _IIlIlIIlll.Ready then _llIllIllII("\20445\23384\22833\36133", "\37197\32622\23578\26410\23601\32490") return false end
 local _lIIIllllIl = tostring(rawName or ""):match("\094\037\115\042\040\046\045\041\037\115\042\036") if _lIIIllllIl == "" then _llIllIllII("\20445\23384\22833\36133", "\37197\32622\21517\31216\19981\33021\20026\31354") return false end
 if #_lIIIllllIl > 0x18 then _llIllIllII("\20445\23384\22833\36133", "\21517\31216\26368\22810\032\050\052\032\20010\23383\31526") return false end
 local _lIIIIlllII = _IIlIlIIlll.Data.profiles[_lIIIllllIl] ~= nil if not _lIIIIlllII and #_IlIIIIIIIl() >= _IIlIlIIlll.MaxProfiles then _llIllIllII("\20445\23384\22833\36133", string.format("\27599\20010\20316\29992\22495\26368\22810\032\037\100\032\20010\37197\32622", _IIlIlIIlll.MaxProfiles)) return false end
 local _IIllIIlllI = _lIIIIIlIlI() if next(_IIllIIlllI) == nil then _llIllIllII("\20445\23384\22833\36133", "\24403\21069\27809\26377\21487\20445\23384\30340\37197\32622\39033\65288\30028\38754\21487\33021\23578\26410\23601\32490\65289") return false end
 _IIlIlIIlll.Data.profiles[_lIIIllllIl] = _IIllIIlllI if not _lIIIIlllII then _IIlIlIIlll.Data.order[#_IIlIlIIlll.Data.order + 0x1] = _lIIIllllIl end
 _IIlIlIIlll.Data.active = _lIIIllllIl _IIlIlIIlll.Data.meta = { format = _IIlIlIIlll.Format, _IllIlllIII = _IIlIlIIlll.Scope.Kind, _IllIlllIll = (_IIlIlIIlll.Scope.Kind == "\103\097\109\101") and _IIlIlIIlll.Scope.PlaceId or 0x0, gameName = (_IIlIlIIlll.Scope.Kind == "\103\097\109\101") and _IIlIlIIlll.Scope.Name or nil, savedAt = os.time(), } local _IlIIIlllII, err = _IIllIIlIlI(true) if not _IlIIIlllII then _llIllIllII("\25552\31034", tostring(err) .. "\65307\37197\32622\20165\20445\30041\22312\26412\27425\20250\35805", 0x6) end
 _lIlIIIIIIl() _llIllIllII(_lIIIIlllII and "\24050\35206\30422\37197\32622" or "\24050\20445\23384\37197\32622", string.format("\037\115\032\183\032\037\115", _lIIIllllIl, _IllIIlIllI(_IIlIlIIlll.Scope))) return true end
 function _IIlIlIIlll.remove(_lIIIllllIl) if not _IIlIlIIlll.Ready then _llIllIllII("\21024\38500\22833\36133", "\37197\32622\23578\26410\23601\32490") return false end
 if not _lIIIllllIl or not _IIlIlIIlll.Data.profiles[_lIIIllllIl] then _llIllIllII("\21024\38500\22833\36133", "\35831\36873\25321\19968\20010\24050\20445\23384\30340\37197\32622") return false end
 if #_IlIIIIIIIl() <= 0x1 then _llIllIllII("\21024\38500\22833\36133", "\27599\20010\20316\29992\22495\33267\23569\20445\30041\19968\20010\37197\32622") return false end
 _IIlIlIIlll.Data.profiles[_lIIIllllIl] = nil for index = #_IIlIlIIlll.Data.order, 0x1, -0x1 do if _IIlIlIIlll.Data.order[index] == _lIIIllllIl then table.remove(_IIlIlIIlll.Data.order, index) end
 end
 if _IIlIlIIlll.Data.active == _lIIIllllIl then local _lIIlIIlIlI = _IIlIlIIlll.Data.order[0x1] _IIlIlIIlll.Data.active = _lIIlIIlIlI local _lIIlllIIII = _lIIlllIllI(_IIlIlIIlll.Data.profiles[_lIIlIIlIlI]) _IIlIlIIlll.Data.profiles[_lIIlIIlIlI] = _lIIlllIIII.values _llIIIIllII(_lIIlllIIII.values) _lIIllIllII(_lIIlIIlIlI, _lIIlllIIII) end
 _IIllIIlIlI(true) _lIlIIIIIIl() _llIllIllII("\24050\21024\38500\37197\32622", _lIIIllllIl) return true end
 local _IlIIllIIII = _IIIIlIIIIl:MakeTab({ Name = "\33258\30596", Icon = "\099\114\111\115\115\104\097\105\114" }) local _IIIllllIll = _IlIIllIIII:AddSection({ Name = "\29366\24577" }) _IIIllllIll:AddParagraph({ Title = "\33258\21160\30596\20934", Content = "\24320\21551\21518\27599\19968\24103\23558\20934\26143\21560\38468\21040\35270\37326\22280\20869\26368\36817\30340\30446\26631\65292\24179\28369\24230\36234\23567\36319\38543\36234\24555\12290", }) local _lIlIIIIlIl = _IlIIllIIII:AddSection({ Name = "\21442\25968" }) _lIlIIIIlIl:AddToggle({ Name = "\21551\29992\33258\30596", Flag = "\065\073\077\066\079\084", Default = false, Callback = function () _IIIIIlIlIl() local _lIllllIIll, reason = _lIIIIlIllI("\097\105\109\098\111\116") if not _lIllllIIll then _llIlIIIlll("\097\105\109\098\111\116\045\119\097\105\116", "\33258\30596\24050\24320\21551", "\31561\24453\29615\22659\23601\32490\21518\33258\21160\29983\25928\65306" .. tostring(reason), 0x5) end
 end
 , }) _lIlIIIIlIl:AddToggle({ Name = "\26174\31034\35270\37326\22280", Flag = "\065\073\077\066\079\084\095\083\072\079\087\070\079\086", Default = false, Callback = function () _llIIIIIIll() end
 , }) _lIlIIIIlIl:AddSlider({ Name = "\35270\37326\33539\22260", Flag = "\065\073\077\066\079\084\095\070\079\086", Min = 0x1E, Max = 0x1F4, Default = 0x96, Increment = 0x5, ValueName = "\112\120", Callback = function () _llIIIIIIll() end
 , }) _lIlIIIIlIl:AddSlider({ Name = "\24179\28369\24230", Flag = "\065\073\077\066\079\084\095\083\077\079\079\084\072", Min = 0x1, Max = 0x14, Default = 0x1, Increment = 0x1, }) local _lllIllllII = _IlIIllIIII:AddSection({ Name = "\30446\26631" }) _lllIllllII:AddDropdown({ Name = "\30446\26631\37096\20301", Flag = "\065\073\077\066\079\084\095\080\065\082\084", Options = { "\22836\37096", "\36527\24178\040\26681\041", "\36527\24178", "\19978\21322\36523", "\19979\21322\36523" }, Default = "\22836\37096", }) local _IIIIIIIIll = _IIIIlIIIIl:MakeTab({ Name = "\36879\35270", Icon = "\101\121\101" }) local _IIIllllIIl = _IIIIIIIIll:AddSection({ Name = "\32472\21046" }) _IIIllllIIl:AddToggle({ Name = "\21551\29992\36879\35270", Flag = "\069\083\080", Default = false, Callback = function (_lllIllIIII) if not _lllIllIIII then _lllIIIIIlI() return end
 _IIIIIlIlIl() local _lIllllIIll, reason = _lIIIIlIllI("\101\115\112") if not _lIllllIIll then _llIlIIIlll("\101\115\112\045\119\097\105\116", "\36879\35270\24050\24320\21551", "\31561\24453\29615\22659\23601\32490\21518\33258\21160\29983\25928\65306" .. tostring(reason), 0x5) end
 end
 , }) _IIIllllIIl:AddToggle({ Name = "\25551\36793\39640\20142", Flag = "\069\083\080\095\072\073\071\072\076\073\071\072\084", Default = false, Callback = function (_lllIllIIII) if _lllIllIIII and not _IllIllIIll("\104\105\103\104\108\105\103\104\116") then _IlllIIlIlI["\069\083\080\095\072\073\071\072\076\073\071\072\084"]:Set(false) end
 end
 , }) _IIIllllIIl:AddToggle({ Name = "\26041\26694", Flag = "\069\083\080\095\066\079\088", Default = false, Callback = function (_lllIllIIII) if _lllIllIIII and not _IllIllIIll("\098\111\120") then _IlllIIlIlI["\069\083\080\095\066\079\088"]:Set(false) end
 end
 , }) _IIIllllIIl:AddToggle({ Name = "\39592\39612\39592\26550", Flag = "\069\083\080\095\083\075\069\076\069\084\079\078", Default = false, Callback = function (_lllIllIIII) if _lllIllIIII and not _IllIllIIll("\115\107\101\108\101\116\111\110") then _IlllIIlIlI["\069\083\080\095\083\075\069\076\069\084\079\078"]:Set(false) end
 end
 , }) local _lIllIIllll = _IIIIIIIIll:AddSection({ Name = "\20449\24687" }) _lIllIIllll:AddToggle({ Name = "\21517\23383\19982\34880\37327", Flag = "\069\083\080\095\078\065\077\069\083", Default = false }) _lIllIIllll:AddToggle({ Name = "\36523\20307\34880\37327\26465", Flag = "\069\083\080\095\072\069\065\076\084\072\066\065\082", Default = false }) _lIllIIllll:AddToggle({ Name = "\36861\36394\32447", Flag = "\069\083\080\095\084\082\065\067\069\082\083", Default = false, Callback = function (_lllIllIIII) if _lllIllIIII and not _IllIllIIll("\116\114\097\099\101\114\115") then _IlllIIlIlI["\069\083\080\095\084\082\065\067\069\082\083"]:Set(false) end
 end
 , }) local _IIlIIllIIl = _IIIIIIIIll:AddSection({ Name = "\36807\28388" }) _IIlIIllIIl:AddToggle({ Name = "\21482\26174\31034\25932\20154", Flag = "\069\083\080\095\084\069\065\077\067\072\069\067\075", Default = false }) _IIlIIllIIl:AddSlider({ Name = "\26174\31034\36317\31163", Flag = "\069\083\080\095\068\073\083\084\065\078\067\069", Min = 0x32, Max = 0x7D0, Default = 0x190, Increment = 0x32, ValueName = "\109", }) local _lIlIlIIlll = _IIIIlIIIIl:GetSettingsTab() UI.Tabs.Aimbot = _IlIIllIIII UI.Tabs.Esp = _IIIIIIIIll UI.Tabs.Settings = _lIlIlIIlll local _IllIlIIIll = _lIlIlIIlll:AddSection({ Name = "\37197\32622\31649\29702" }) _lllIllIlll = _IllIlIIIll:AddTextbox({ Name = "\37197\32622\21517\31216", Default = "\40664\35748", PlaceholderText = "\36755\20837\21517\31216\21518\20445\23384", }) _IllIlIIIll:AddButton({ Name = "\20445\23384\032\047\032\35206\30422\24403\21069\37197\32622", Callback = function () _IIlIlIIlll.save(_lllIllIlll:Get()) end
 , }) _lIllIlIIlI = _IllIlIIIll:AddDropdown({ Name = "\24050\20445\23384\37197\32622", Options = { "\40664\35748" }, Default = "\40664\35748", Callback = function (_lllIllIIII) if _IIlIlIIlll.Syncing or not _IIlIlIIlll.Ready then return end
 local _lIllllIIll, reason = _IIlIlIIlll.apply(_lllIllIIII) if not _lIllllIIll then _llIllIllII("\20999\25442\22833\36133", tostring(reason)) _lIlIIIIIIl() end
 end
 , }) _IllIlIIIll:AddButton({ Name = "\21024\38500\36873\20013\37197\32622", Callback = function () _IIlIlIIlll.remove(_lIllIlIIlI.Value) end
 , }) _llIIIIIIIl = _IllIlIIIll:AddLabel("\27491\22312\36733\20837\37197\32622\8230") local _llllIlllII = _lIlIlIIlll:AddSection({ Name = "\21151\33021\39068\33394" }) _llllIlllII:AddColorpicker({ Name = "\36879\35270\39068\33394", Flag = "\069\083\080\095\067\079\076\079\082", Default = _llllIllllI, }) _llllIlllII:AddColorpicker({ Name = "\35270\37326\22280\39068\33394", Flag = "\070\079\086\095\067\079\076\079\082", Default = _llllIllllI, Callback = function () _llIIIIIIll() end
 , }) local _lIIlllIIll = _lIlIlIIlll:AddSection({ Name = "\20851\20110" }) _lIIlllIIll:AddLabel("\086\032\067\111\109\098\097\116\032\083\117\105\116\101\032\183\032\065\117\114\111\114\097\032\050\046\048") _lIIlllIIll:AddParagraph({ Title = "\35828\26126", Content = "\25152\26377\24320\20851\30340\21028\23450\22343\30452\25509\35835\21462\032\085\073\032\30340\032\070\108\097\103\115\65307\20462\25913\21518\31435\21363\29983\25928\65292\37197\32622\20250\22312\19979\27425\21551\21160\26102\33258\21160\24674\22797\12290", }) local _IIIlllIllI = _lIIlllIIll:AddParagraph({ Title = "\36816\34892\29615\22659", Content = "\27491\22312\26816\27979\8230", }) local function _lIlllllIll() if not _IIIlllIllI then return end
 local _lIIlllIIlI, missing = _IlIllllIIl() if #missing == 0x0 then _IIIlllIllI:Set("\20840\37096\21151\33021\21487\29992") else _IIIlllIllI:Set("\19981\21487\29992\65306" .. table.concat(missing, "\12289")) end
 end
 local _IlIIIIlIIl = _lIlIlIIlll:AddSection({ Name = "\36816\34892" }) _IlIIIIlIIl:AddParagraph({ Title = "\35828\26126", Content = "\28857\20987\19979\26041\25353\38062\23558\20572\27490\33258\30596\19982\36879\35270\65292\28165\29702\032\069\083\080\12289\35270\37326\22280\19982\22836\39030\20449\24687\65292\24182\38144\27585\20840\37096\30028\38754\19982\36816\34892\30165\36857\12290", }) _IlIIIIlIIl:AddButton({ Name = "\36864\20986\33050\26412", Callback = function () _IllIIllIIl() end
 , }) _IIlIlIIlll.Defaults = _lIIIIIlIlI() _IIIIIlIlIl() _llIIIIIIll() _IIlIlIIlll.boot() _lIllIlIIlI() _IlIlIIllII() _lIlllllIll() _lIIllIlIll = true task.spawn( function () while getgenv().V_TOKEN == _lIIlIlllII and _lllllIllII:IsRunning() do task.wait(0x5) if getgenv().V_TOKEN ~= _lIIlIlllII or not _lllllIllII:IsRunning() then break end
 if _IIlIlIIlll.Ready and _IIlIlIIlll.Scope then local _IllIlllIII = _IIlIlIIlll.resolveScope() if _IllIlllIII.Key ~= _IIlIlIIlll.Scope.Key then _IIlIlIIlll.switchScope(_IllIlllIII) end
 end
 _lIlllllIll() end
 end
 ) if getgenv then getgenv().VLib = _lllllIllII getgenv().VWindow = _IIIIlIIIIl getgenv().V_ESP = _IIIllllIIl getgenv().V_AIMBOT = _IIlIIIIlII getgenv().V_CONFIG = _IIlIlIIlll getgenv().V_SHUTDOWN = _IllIIllIIl getgenv().V_RUNTIME = { render = _IlIlIIlIIl, heartbeat = _lIIIllIlII, clear = _lllIIIIIlI, stop = _IllIIllIIl, } getgenv().V_ENV = { capabilities = _lIlIIIllll, features = _lIIlIIIIlI, _lIIIIlIllI = _lIIIIlIllI, } getgenv().VUniverse = { GameId = game.GameId, PlaceId = game.PlaceId, _lIlIllIIlI = _lIlIllIIlI, GameMatchedBy = GameMatchedBy, _IlllIIlIlI = _IlllIIlIlI, _IIIIlIIIIl = _IIIIlIIIIl, } end
 if UI.Tabs and UI.Tabs.Home then pcall( function () UI.Tabs.Home:AddParagraph({ Title = "\28216\25103\24211\26816\27979", Content = _lIlIllIIlI and string.format("\24050\21629\20013\65306\037\115\092\110\21305\37197\26041\24335\65306\037\115\092\110\24050\35843\24230\33050\26412\65306\037\115", tostring(_lIlIllIIlI.name), tostring(GameMatchedBy), tostring(_lIlIllIIlI.source)) or string.format("\24403\21069\28216\25103\65288\080\108\097\099\101\073\100\032\037\100\65289\19981\22312\28216\25103\24211\20013\65292\20165\36816\34892\36890\29992\21151\33021\12290\092\110\26032\22686\25903\25345\65306\32534\36753\032\117\110\105\118\101\114\115\101\046\108\117\097\032\30340\032\071\065\077\069\095\076\073\066\082\065\082\089\12290", tonumber(game.PlaceId) or 0x0), }) end
 ) end
 if _lIlIllIIlI then print("\091\086\032\085\110\105\118\101\114\115\101\093\032\21629\20013\28216\25103\24211\65306" .. tostring(_lIlIllIIlI.name) .. "\65288" .. tostring(GameMatchedBy) .. "\032\21305\37197\65289") if type(UI.RunModule) ~= "\102\117\110\099\116\105\111\110" then warn("\091\086\032\085\110\105\118\101\114\115\101\093\032\32570\23569\032\085\073\046\082\117\110\077\111\100\117\108\101\65288\108\111\097\100\046\108\117\097\032\29256\26412\36807\26087\65289\65292\28216\25103\24211\33050\26412\26410\25191\34892\12290") else local _IIlIlIlllI = UI.RunModule(_lIlIllIIlI.source, "\086\032\071\097\109\101\032\183\032" .. tostring(_lIlIllIIlI.name or "\077\111\100\117\108\101")) if not _IIlIlIlllI then warn("\091\086\032\085\110\105\118\101\114\115\101\093\032\28216\25103\24211\33050\26412\26410\25104\21151\25191\34892\65306" .. tostring(_lIlIllIIlI.source)) end
 end
 else print("\091\086\032\085\110\105\118\101\114\115\101\093\032\24403\21069\28216\25103\19981\22312\28216\25103\24211\20013\65292\20165\36816\34892\36890\29992\21151\33021\12290") end
 return true end
 )(...)
