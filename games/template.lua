--[[ Protected by Lua Guard ]]

( function (...) if type(Services) ~= "\116\097\098\108\101" then warn("\091\086\032\071\097\109\101\093\032\32570\23569\20840\23616\032\083\101\114\118\105\099\101\115\032\8212\8212\032\108\111\097\100\046\108\117\097\032\26410\36816\34892\65292\28216\25103\33050\26412\25298\32477\21551\21160\12290") return false end
 if type(UI) ~= "\116\097\098\108\101" or type(UI.Window) ~= "\116\097\098\108\101" or type(UI.VLib) ~= "\116\097\098\108\101" then warn("\091\086\032\071\097\109\101\093\032\32570\23569\20840\23616\032\085\073\032\8212\8212\032\117\105\046\108\117\097\032\38454\27573\32570\22833\65292\28216\25103\33050\26412\25298\32477\21551\21160\12290") return false end
 if type(VUniverse) ~= "\116\097\098\108\101" then warn("\091\086\032\071\097\109\101\093\032\32570\23569\032\086\085\110\105\118\101\114\115\101\032\8212\8212\032\117\110\105\118\101\114\115\101\046\108\117\097\032\26410\36816\34892\65292\38142\36335\19981\23436\25972\65292\28216\25103\33050\26412\25298\32477\21551\21160\12290") return false end
 local Players = Services.Players local RunService = Services.RunService local _IIIllllIll = Services.UserInputService local _lllllIllll = UI.Window local _lIlIlIlIlI = UI.VLib local _IllIIIIlII = _lIlIlIlIlI.Flags local _llIllIllII = Players.LocalPlayer if UI.Tabs.GameTemplate then warn("\091\086\032\071\097\109\101\093\032\27169\26495\39029\31614\24050\23384\22312\65292\36339\36807\37325\22797\21152\36733\12290") return true end
 local function _lllIllIlII(name, fallback) local _llIlIIlIll = _IllIIIIlII[name] if _llIlIIlIll ~= nil and _llIlIIlIll.Value ~= nil then return _llIlIIlIll.Value end
 return fallback end
 local function _IIIIllIIlI(name) return _lllIllIlII(name, false) == true end
 local function _IllIllIlII(name, fallback) local _IlIllIIlll = tonumber(_lllIllIlII(name, fallback)) if _IlIllIIlll == nil then return fallback end
 return _IlIllIIlll end
 local _IlIIlIIIII = { heartbeat = nil, jumpConn = nil, } local function _IIllIIIIII() local _lIIIllIlII = _llIllIllII.Character return _lIIIllIlII and _lIIIllIlII:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") end
 local function _IIIIIIIlll() if _IlIIlIIIII.heartbeat then return end
 _IlIIlIIIII.heartbeat = RunService.Heartbeat:Connect( function () local _IllllIllIl = _IIllIIIIII() if not _IllllIllIl then return end
 if _IIIIllIIlI("\084\080\076\095\083\080\069\069\068") then _IllllIllIl.WalkSpeed = _IllIllIlII("\084\080\076\095\083\080\069\069\068\095\086\065\076\085\069", 0x20) end
 if _IIIIllIIlI("\084\080\076\095\074\085\077\080") then _IllllIllIl.UseJumpPower = true _IllllIllIl.JumpPower = _IllIllIlII("\084\080\076\095\074\085\077\080\095\086\065\076\085\069", 0x78) end
 end
 ) _IlIIlIIIII.jumpConn = _IIIllllIll.JumpRequest:Connect( function () if not _IIIIllIIlI("\084\080\076\095\073\078\070\074\085\077\080") then return end
 local _IllllIllIl = _IIllIIIIII() if _IllllIllIl and _IllllIllIl.Health > 0x0 then _IllllIllIl:ChangeState(Enum.HumanoidStateType.Jumping) end
 end
 ) end
 local function _IllIlllllI() if _IlIIlIIIII.heartbeat then _IlIIlIIIII.heartbeat:Disconnect() _IlIIlIIIII.heartbeat = nil end
 if _IlIIlIIIII.jumpConn then _IlIIlIIIII.jumpConn:Disconnect() _IlIIlIIIII.jumpConn = nil end
 end
 local function _IIllllIIll() _IllIlllllI() local _IllllIllIl = _IIllIIIIII() if _IllllIllIl then _IllllIllIl.WalkSpeed = 0x10 _IllllIllIl.UseJumpPower = true _IllllIllIl.JumpPower = 0x32 end
 UI.Tabs.GameTemplate = nil pcall( function () _lIlIlIlIlI:MakeNotification({ Name = "\27169\26495\24050\21368\36733", Content = "\31227\21160\21442\25968\24050\24674\22797\40664\35748\65292\24490\29615\24050\26029\24320\12290", Time = 0x3, }) end
 ) end
 local _IIllllllII = _lllllIllll:MakeTab({ Name = "\31227\21160\22686\24378", Icon = "\122\097\112" }) UI.Tabs.GameTemplate = _IIllllllII _IIllllllII:AddParagraph({ Title = "\28216\25103\24211\33050\26412\032\183\032\27169\26495", Content = string.format( "\24403\21069\28216\25103\65306\037\115\092\110\071\097\109\101\073\100\65306\037\100\032\124\032\080\108\097\099\101\073\100\65306\037\100\092\110\26412\39029\31614\30001\032\103\097\109\101\115\047\116\101\109\112\108\097\116\101\046\108\117\097\032\27880\20837\65292\20165\20316\38142\36335\28436\31034\12290", tostring(VUniverse.GameEntry and VUniverse.GameEntry.name or "\26410\30693"), tonumber(VUniverse.GameId) or 0x0, tonumber(VUniverse.PlaceId) or 0x0 ), }) local _llIlIIlllI = _IIllllllII:AddSection({ Name = "\31227\21160" }) _llIlIIlllI:AddToggle({ Name = "\33258\23450\20041\31227\36895", Flag = "\084\080\076\095\083\080\069\069\068", Default = false, Callback = function (_IlIllIIlll) if _IlIllIIlll then _IIIIIIIlll() end
 end
 , }) _llIlIIlllI:AddSlider({ Name = "\31227\36895\25968\20540", Flag = "\084\080\076\095\083\080\069\069\068\095\086\065\076\085\069", Min = 0x10, Max = 0xC8, Default = 0x20, Increment = 0x2, }) _llIlIIlllI:AddToggle({ Name = "\33258\23450\20041\36339\21147", Flag = "\084\080\076\095\074\085\077\080", Default = false, Callback = function (_IlIllIIlll) if _IlIllIIlll then _IIIIIIIlll() end
 end
 , }) _llIlIIlllI:AddSlider({ Name = "\36339\21147\25968\20540", Flag = "\084\080\076\095\074\085\077\080\095\086\065\076\085\069", Min = 0x32, Max = 0x12C, Default = 0x78, Increment = 0x5, }) _llIlIIlllI:AddToggle({ Name = "\26080\38480\36339\36291", Flag = "\084\080\076\095\073\078\070\074\085\077\080", Default = false, Callback = function (_IlIllIIlll) if _IlIllIIlll then _IIIIIIIlll() end
 end
 , }) local _llIIlIIlIl = _IIllllllII:AddSection({ Name = "\27169\22359" }) _llIIlIIlIl:AddButton({ Name = "\21368\36733\26412\27169\22359\65288\24674\22797\40664\35748\31227\21160\21442\25968\65289", Callback = _IIllllIIll, }) _IIIIIIIlll() pcall( function () _lIlIlIlIlI:MakeNotification({ Name = "\28216\25103\27169\22359\24050\21152\36733", Content = "\27169\26495\21151\33021\23601\32490\65292\39029\31614\24050\27880\20837\20840\23616\032\085\073\046\087\105\110\100\111\119\12290", Time = 0x4, }) end
 ) return true end
 )(...)
