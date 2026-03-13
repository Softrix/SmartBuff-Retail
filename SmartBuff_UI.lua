-- SmartBuff_UI.lua
-- GUI element helpers: tooltip attachment, GroupBuffHelp frame.
-- Tooltips moved from XML to Lua to reduce XML bloat (~470 lines removed).

function SmartBuff_GroupBuffHelp_Toggle()
  if SmartBuff_GroupBuffHelp:IsVisible() then
    SmartBuff_GroupBuffHelp:Hide();
  else
    SmartBuff_GroupBuffHelp_Text:SetText(SMARTBUFF_GROUPBUFFHELP or "");
    SmartBuff_GroupBuffHelp:Show();
  end
end

local TTC = { SMARTBUFF_TTC_R, SMARTBUFF_TTC_G, SMARTBUFF_TTC_B, SMARTBUFF_TTC_A };

-- Attach a tooltip to a frame. text can be string, or table {line1, line2} for multi-line.
-- opts: { anchor = "ANCHOR_RIGHT", onLeave = function() end }
function SmartBuff_AttachTooltip(frame, text, opts)
  if not frame then return end
  opts = opts or {};
  local anchor = opts.anchor or "ANCHOR_RIGHT";
  local onLeave = opts.onLeave;

  frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, anchor);
    local resolved = (type(text) == "function") and text() or text;
    if type(resolved) == "table" then
      GameTooltip:SetText(resolved[1], TTC[1], TTC[2], TTC[3], TTC[4]);
      for i = 2, #resolved do
        GameTooltip:AddLine(resolved[i], TTC[1], TTC[2], TTC[3], TTC[4]);
      end
      GameTooltip:AppendText("");
    else
      GameTooltip:SetText(resolved, TTC[1], TTC[2], TTC[3], TTC[4]);
    end
  end);

  frame:SetScript("OnLeave", function(self)
    GameTooltip:Hide();
    if onLeave then onLeave(); end
  end);
end

function SmartBuff_SetupTooltips()
  local t = SmartBuff_AttachTooltip;

  t(_G["SmartBuffSplashFrameOptions_btnFontStyle"], SMARTBUFF_OFTT_SPLASHSTYLE);
  t(SmartBuff_MiniMapButton, { SMARTBUFF_TITLE, SMARTBUFF_MINIMAP_TT }, { anchor = "ANCHOR_LEFT" });

  t(SmartBuffOptionsFrame_cbSB, SMARTBUFF_OFTT);
  t(SmartBuffOptionsFrame_cbAuto, SMARTBUFF_OFTT_AUTO);
  t(SmartBuffOptionsFrameAutoTimer, SMARTBUFF_OFTT_AUTOTIMER);
  t(SmartBuffOptionsFrame_cbAutoCombat, SMARTBUFF_OFTT_AUTOCOMBAT);
  t(SmartBuffOptionsFrame_cbAutoChat, SMARTBUFF_OFTT_AUTOCHAT);
  t(SmartBuffOptionsFrame_cbAutoSplash, SMARTBUFF_OFTT_AUTOSPLASH);
  t(SmartBuffOptionsFrame_cbAutoSound, SMARTBUFF_OFTT_AUTOSOUND);
  t(SmartBuffOptionsFrame_sldCharges, SMARTBUFF_OFTT_CHECKCHARGES);
  t(SmartBuffOptionsFrame_sldSplashDuration, SMARTBUFF_OFTT_SPLASHDURATION);
  t(SmartBuffOptionsFrameRebuffTimer, SMARTBUFF_OFTT_REBUFFTIMER);
  t(SmartBuffOptionsFrame_cbAutoSwitchTmp, SMARTBUFF_OFTT_AUTOSWITCHTMP);
  t(SmartBuffOptionsFrame_cbAutoSwitchTmpInst, SMARTBUFF_OFTT_AUTOSWITCHTMPINST);
  t(SmartBuffOptionsFrame_cbLinkGrpBuffCheck, SMARTBUFF_OFTT_LINKGRPBUFFCHECK);
  t(SmartBuffOptionsFrame_cbLinkSelfBuffCheck, SMARTBUFF_OFTT_LINKSELFBUFFCHECK);
  t(SmartBuffOptionsFrame_cbBuffPvP, SMARTBUFF_OFTT_BUFFPVP);
  t(SmartBuffOptionsFrame_cbBuffTarget, SMARTBUFF_OFTT_BUFFTARGET);
  t(SmartBuffOptionsFrame_cbScrollWheelUp, SMARTBUFF_OFTT_SCROLLWHEELUP);
  t(SmartBuffOptionsFrame_cbScrollWheelDown, SMARTBUFF_OFTT_SCROLLWHEELDOWN);
  t(SmartBuffOptionsFrame_cbBuffInCities, SMARTBUFF_OFTT_BUFFINCITIES);
  t(SmartBuffOptionsFrame_cbInShapeshift, SMARTBUFF_OFTT_INSHAPESHIFT);
  t(SmartBuffOptionsFrame_cbInCombat, SMARTBUFF_OFTT_INCOMBAT);
  t(SmartBuffOptionsFrameBLDuration, SMARTBUFF_OFTT_BLDURATION);
  t(SmartBuffOptionsFrame_cbHideMmButton, SMARTBUFF_OFTT_HIDEMMBUTTON);
  t(SmartBuffOptionsFrame_cbHideSAButton, SMARTBUFF_OFTT_HIDESABUTTON);
  t(SmartBuffOptionsFrame_cbRetainTemplate, SMARTBUFF_OFTT_RETAINTEMPLATE);
  t(SmartBuffOptionsFrame_cbSelfFirst, SMARTBUFF_OFTT_SELFFIRST);
  t(SmartBuffOptionsFrameRBT, SMARTBUFF_OFTT_RBT);
  t(SmartBuffOptionsFrameResetAll, SMARTBUFF_OFTT_RESETALL);
  t(SmartBuffOptionsFrameResetBuffs, SMARTBUFF_OFTT_RESETBUFFS);
  t(SmartBuffOptionsFrameResetOrder, SMARTBUFF_OFTT_RESETLIST);
  t(SmartBuffOptionsFrameNews, SMARTBUFF_OFTT_NEWS);
  t(SmartBuffOptionsFrameDone, SMARTBUFF_OFTT_DONE);
  t(SmartBuffOptionsFrame_cbIncludeToys, SMARTBUFF_OFTT_INCLUDETOYS);
  t(SmartBuffOptionsFrame_btnPlaySound, SMARTBUFF_OFTT_PLAYSOUND);
  t(SmartBuffOptionsFrame_sldSounds, SMARTBUFF_OFTT_SOUNDSELECT);
  t(SmartBuffOptionsFrame_cbFixBuffIssue, SMARTBUFF_OFTT_FIXBUFF);

  t(SmartBuff_BuffSetup_cbSelf, function() return SmartBuff_GetSelfTooltipText(SMARTBUFF_BSTT_SELFONLY); end);
  t(SmartBuff_BuffSetup_cbSelfNot, function() return SmartBuff_GetSelfTooltipText(SMARTBUFF_BSTT_SELFNOT); end);
  t(SmartBuff_BuffSetup_cbCombatIn, SMARTBUFF_BSTT_COMBATIN);
  t(SmartBuff_BuffSetup_cbCombatOut, SMARTBUFF_BSTT_COMBATOUT);
  t(SmartBuff_BuffSetup_txtManaLimit, SMARTBUFF_BSTT_MANALIMIT);
  t(SmartBuff_BuffSetup_cbSkipBGResQueue, SMARTBUFF_BSTT_SKIPBGRES);
  t(SmartBuff_BuffSetup_cbMH, SMARTBUFF_BSTT_MAINHAND);
  t(SmartBuff_BuffSetup_cbOH, SMARTBUFF_BSTT_OFFHAND);
  t(SmartBuff_BuffSetup_cbRH, SMARTBUFF_BSTT_RANGED);
  t(SmartBuff_BuffSetup_cbReminder, SMARTBUFF_BSTT_REMINDER);
  t(SmartBuff_BuffSetup_btnPriorityList, SMARTBUFF_BSTT_ADDLIST);
  t(SmartBuff_BuffSetup_btnIgnoreList, SMARTBUFF_BSTT_IGNORELIST);
  t(SmartBuff_BuffSetup_RBTime, SMARTBUFF_BSTT_REBUFFTIMER, {
    onLeave = function() SmartBuff_BuffSetup_OnClick(); end
  });

  t(SmartBuff_PlayerSetup_Add, SMARTBUFF_PSTT_ADD);
  t(SmartBuff_PlayerSetup_Remove, SMARTBUFF_PSTT_REMOVE);
  t(SmartBuff_PlayerSetup_Up, SMARTBUFF_PSTT_UP);
  t(SmartBuff_PlayerSetup_Down, SMARTBUFF_PSTT_DOWN);
  t(SmartBuff_PlayerSetup_Resize, SMARTBUFF_PSTT_RESIZE, {
    onLeave = function() SmartBuff_BuffSetup_OnClick(); end
  });
  t(SmartBuff_PlayerSetup_Clear, SMARTBUFF_PSTT_CLEAR);
  t(SmartBuff_BuffSetup_btnInfo, SMARTBUFF_GROUPBUFFHELP_TT or "Open group buff configuration help");

  for i = 1, 19 do
    if SMARTBUFF_CLASSES and SMARTBUFF_CLASSES[i] then
      t(_G["SmartBuff_BuffSetup_ClassIcon" .. i], SMARTBUFF_CLASSES[i]);
    end
  end
end

-- Deferred: frames do not exist when this file loads (XML scripts run before frame definitions).
-- Called from SMARTBUFF_OnLoad after all frames are created.
