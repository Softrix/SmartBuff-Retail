-------------------------------------------------------------------------------
-- SmartBuff cache load/save/sync helpers
-- Load order: after SmartBuff.globals.lua, before SmartBuff.buffs.lua and SmartBuff.lua
-------------------------------------------------------------------------------

local SG = SMARTBUFF_GLOBALS;

-- Load cache from SavedVariables (init structures, invalidate on version change)
function SMARTBUFF_LoadCache()
  if (not SmartBuffBuffListCache) then
    SmartBuffBuffListCache = {
      version = nil,
      lastUpdate = 0,
      expectedCounts = {
        SCROLL = 0,
        FOOD = 0,
        POTION = 0,
        SELF = 0,
        GROUP = 0,
        ITEM = 0,
        TOTAL = 0
      },
      enabledBuffs = {}
    };
  end

  if (SmartBuffBuffListCache.version and SmartBuffBuffListCache.version ~= SMARTBUFF_VERSION) then
    SmartBuffBuffListCache.version = nil;
    SmartBuffBuffListCache.lastUpdate = 0;
    wipe(SmartBuffBuffListCache.expectedCounts);
    wipe(SmartBuffBuffListCache.enabledBuffs);
  end

  if (not SmartBuffToyCache) then
    SmartBuffToyCache = { version = nil, lastUpdate = 0, toyCount = 0, toybox = {} };
  end

  if (SmartBuffToyCache.version and SmartBuffToyCache.version ~= SMARTBUFF_VERSION) then
    SmartBuffToyCache.version = nil;
    SmartBuffToyCache.lastUpdate = 0;
    SmartBuffToyCache.toyCount = 0;
    wipe(SmartBuffToyCache.toybox);
  end

  if (not SmartBuffItemSpellCache) then
    SmartBuffItemSpellCache = { version = nil, lastUpdate = 0, items = {}, spells = {}, itemIDs = {}, itemData = {}, needsRefresh = {} };
  end

  if (not SmartBuffItemSpellCache.itemData) then
    SmartBuffItemSpellCache.itemData = {};
  end
  if (not SmartBuffItemSpellCache.needsRefresh) then
    SmartBuffItemSpellCache.needsRefresh = {};
  end

  if (SmartBuffItemSpellCache.version and SmartBuffItemSpellCache.version ~= SMARTBUFF_VERSION) then
    SmartBuffItemSpellCache.version = nil;
    SmartBuffItemSpellCache.lastUpdate = 0;
    wipe(SmartBuffItemSpellCache.items);
    wipe(SmartBuffItemSpellCache.spells);
    wipe(SmartBuffItemSpellCache.itemIDs);
    wipe(SmartBuffItemSpellCache.itemData);
    wipe(SmartBuffItemSpellCache.needsRefresh);
  end

  if (not SmartBuffBuffRelationsCache) then
    SmartBuffBuffRelationsCache = { version = nil, lastUpdate = 0, chains = {}, links = {} };
  end

  if (SmartBuffBuffRelationsCache.version and SmartBuffBuffRelationsCache.version ~= SMARTBUFF_VERSION) then
    SmartBuffBuffRelationsCache.version = nil;
    SmartBuffBuffRelationsCache.lastUpdate = 0;
    wipe(SmartBuffBuffRelationsCache.chains);
    wipe(SmartBuffBuffRelationsCache.links);
  end

  -- ValidSpells: invalidate on addon version change so stale true/false from previous version is cleared
  if (not SmartBuffValidSpells) then
    SmartBuffValidSpells = { version = nil, lastUpdate = 0, spells = {} };
  end
  if (SmartBuffValidSpells.version and SmartBuffValidSpells.version ~= SMARTBUFF_VERSION) then
    SMARTBUFF_ClearValidSpells();
  end

  return SmartBuffBuffListCache;
end

-- Clear ValidSpells cache and ensure .spells is a table so the next buff list build re-validates.
-- Used on version change (LoadCache), spell-change events, login/reload (PLAYER_ENTERING_WORLD), and Reset Buffs.
function SMARTBUFF_ClearValidSpells()
  if (not SmartBuffValidSpells) then
    SmartBuffValidSpells = { version = nil, lastUpdate = 0, spells = {} };
    return;
  end
  SmartBuffValidSpells.version = nil;
  SmartBuffValidSpells.lastUpdate = 0;
  if (SmartBuffValidSpells.spells) then
    wipe(SmartBuffValidSpells.spells);
  end
  -- Ensure .spells exists so the filter block in SetBuff always runs (no skip when .spells is nil)
  SmartBuffValidSpells.spells = SmartBuffValidSpells.spells or {};
end

-- Sync item/spell cache with expected list from buffs.lua (remove extras, add missing, flag needsRefresh)
function SMARTBUFF_SyncItemSpellCache()
  if (not SmartBuffItemSpellCache) then
    SmartBuffItemSpellCache = { version = nil, lastUpdate = 0, items = {}, spells = {}, itemIDs = {}, itemData = {}, needsRefresh = {} };
  end
  if (not SmartBuffItemSpellCache.items) then SmartBuffItemSpellCache.items = {}; end
  if (not SmartBuffItemSpellCache.spells) then SmartBuffItemSpellCache.spells = {}; end
  if (not SmartBuffItemSpellCache.itemIDs) then SmartBuffItemSpellCache.itemIDs = {}; end
  if (not SmartBuffItemSpellCache.itemData) then SmartBuffItemSpellCache.itemData = {}; end
  if (not SmartBuffItemSpellCache.needsRefresh) then SmartBuffItemSpellCache.needsRefresh = {}; end

  local cache = SmartBuffItemSpellCache;
  local expected = SMARTBUFF_ExpectedData;

  if (not expected or not expected.items or not expected.spells) then
    return;
  end

  for varName, _ in pairs(cache.items) do
    if (not expected.items[varName]) then
      cache.items[varName] = nil;
      cache.itemIDs[varName] = nil;
      cache.itemData[varName] = nil;
      cache.needsRefresh[varName] = nil;
    end
  end

  for varName, _ in pairs(cache.spells) do
    if (not expected.spells[varName]) then
      cache.spells[varName] = nil;
      cache.needsRefresh[varName] = nil;
    end
  end

  for varName, itemId in pairs(expected.items) do
    if (not cache.items[varName]) then
      cache.items[varName] = nil;
      cache.itemIDs[varName] = itemId;
      cache.itemData[varName] = nil;
      cache.needsRefresh[varName] = true;
    else
      cache.needsRefresh[varName] = true;
    end
  end

  for varName, spellId in pairs(expected.spells) do
    if (not cache.spells[varName]) then
      cache.spells[varName] = nil;
      cache.needsRefresh[varName] = true;
    else
      cache.needsRefresh[varName] = true;
    end
  end

  cache.version = SMARTBUFF_VERSION;
  cache.lastUpdate = GetTime();
end

-- Load buff relationships (chains and links) from cache
function SMARTBUFF_LoadBuffRelationsCache()
  local cache = SmartBuffBuffRelationsCache;
  if (not cache or not cache.version or cache.version ~= SMARTBUFF_VERSION) then
    return;
  end

  if (cache.chains and SG) then
    for key, value in pairs(cache.chains) do
      if (type(value) == "table") then
        SG[key] = value;
      end
    end
  end

  if (cache.links and SG) then
    for key, value in pairs(cache.links) do
      if (type(value) == "table") then
        SG[key] = value;
      end
    end
  end
end

-- Save buff relationships (chains and links) to cache
function SMARTBUFF_SaveBuffRelationsCache()
  if (not SmartBuffBuffRelationsCache) then
    SmartBuffBuffRelationsCache = { version = nil, lastUpdate = 0, chains = {}, links = {} };
  end

  local cache = SmartBuffBuffRelationsCache;
  cache.version = SMARTBUFF_VERSION;
  cache.lastUpdate = GetTime();

  wipe(cache.chains);
  if (SG) then
    for key, value in pairs(SG) do
      if (type(key) == "string" and string.match(key, "^Chain") and type(value) == "table") then
        cache.chains[key] = value;
      end
    end
  end

  wipe(cache.links);
  if (SG) then
    for key, value in pairs(SG) do
      if (type(key) == "string" and string.match(key, "^Link") and type(value) == "table") then
        cache.links[key] = value;
      end
    end
  end
end

-- Save cache to SavedVariables (buff list counts, enabled snapshot, toy count)
function SMARTBUFF_SaveCache(counts, enabledBuffsSnapshot, toyCount)
  local cache = SmartBuffBuffListCache;
  if (not cache) then
    SMARTBUFF_LoadCache();
    cache = SmartBuffBuffListCache;
  end

  cache.version = SMARTBUFF_VERSION;
  cache.lastUpdate = GetTime();

  if (counts) then
    cache.expectedCounts.SCROLL = counts.SCROLL or 0;
    cache.expectedCounts.FOOD = counts.FOOD or 0;
    cache.expectedCounts.POTION = counts.POTION or 0;
    cache.expectedCounts.SELF = counts.SELF or 0;
    cache.expectedCounts.GROUP = counts.GROUP or 0;
    cache.expectedCounts.ITEM = counts.ITEM or 0;
    cache.expectedCounts.TOTAL = counts.TOTAL or 0;
  end

  if (enabledBuffsSnapshot) then
    wipe(cache.enabledBuffs);
    for _, buffName in ipairs(enabledBuffsSnapshot) do
      table.insert(cache.enabledBuffs, buffName);
    end
  end

  if (toyCount ~= nil) then
    if (not SmartBuffToyCache) then
      SmartBuffToyCache = { version = nil, lastUpdate = 0, toyCount = 0, toybox = {} };
    end
    SmartBuffToyCache.toyCount = toyCount;
    SmartBuffToyCache.version = SMARTBUFF_VERSION;
    SmartBuffToyCache.lastUpdate = GetTime();

    if (SG and SG.ToyboxByID) then
      wipe(SmartBuffToyCache.toybox);
      for id, toyData in pairs(SG.ToyboxByID) do
        if (toyData and toyData[2]) then
          SmartBuffToyCache.toybox[id] = toyData[2];
        end
      end
    end
  end
end

-- Print cache statistics (cBuffs optional: pass from SmartBuff.lua for "Current Buff List" line)
function SMARTBUFF_PrintCacheStats(cBuffs)
  local addMsg = SMARTBUFF_AddMsg;
  if (not addMsg) then return; end

  addMsg("=== SmartBuff Cache Statistics ===", true);

  local buffCache = SmartBuffBuffListCache;
  if (buffCache) then
    addMsg("BuffListCache: version=" .. tostring(buffCache.version) .. ", lastUpdate=" .. tostring(buffCache.lastUpdate), true);
    if (buffCache.expectedCounts) then
      addMsg("  Expected: SCROLL=" .. buffCache.expectedCounts.SCROLL .. ", FOOD=" .. buffCache.expectedCounts.FOOD .. ", POTION=" .. buffCache.expectedCounts.POTION .. ", SELF=" .. buffCache.expectedCounts.SELF .. ", GROUP=" .. buffCache.expectedCounts.GROUP .. ", ITEM=" .. buffCache.expectedCounts.ITEM .. ", TOTAL=" .. buffCache.expectedCounts.TOTAL, true);
    end
  else
    addMsg("BuffListCache: not initialized", true);
  end

  local toyCache = SmartBuffToyCache;
  if (toyCache) then
    addMsg("ToyCache: version=" .. tostring(toyCache.version) .. ", lastUpdate=" .. tostring(toyCache.lastUpdate), true);
    addMsg("  ToyCount: " .. tostring(toyCache.toyCount), true);
    local toyCacheCount = 0;
    if (toyCache.toybox) then for _ in pairs(toyCache.toybox) do toyCacheCount = toyCacheCount + 1; end end
    addMsg("  Toys in cache: " .. toyCacheCount, true);
  else
    addMsg("ToyCache: not initialized", true);
  end

  local itemSpellCache = SmartBuffItemSpellCache;
  if (itemSpellCache) then
    addMsg("ItemSpellCache: version=" .. tostring(itemSpellCache.version) .. ", lastUpdate=" .. tostring(itemSpellCache.lastUpdate), true);
    local itemCount, spellCount, needsRefreshCount = 0, 0, 0;
    if (itemSpellCache.items) then for _ in pairs(itemSpellCache.items) do itemCount = itemCount + 1; end end
    if (itemSpellCache.spells) then for _ in pairs(itemSpellCache.spells) do spellCount = spellCount + 1; end end
    if (itemSpellCache.needsRefresh) then
      for _, needsRefresh in pairs(itemSpellCache.needsRefresh) do if (needsRefresh) then needsRefreshCount = needsRefreshCount + 1; end end
    end
    addMsg("  Items: " .. itemCount .. ", Spells: " .. spellCount .. ", NeedsRefresh: " .. needsRefreshCount, true);
    local nilItems, nilSpells = 0, 0;
    if (itemSpellCache.items) then for _, itemLink in pairs(itemSpellCache.items) do if (not itemLink) then nilItems = nilItems + 1; end end end
    if (itemSpellCache.spells) then for _, spellInfo in pairs(itemSpellCache.spells) do if (not spellInfo) then nilSpells = nilSpells + 1; end end end
    if (nilItems > 0 or nilSpells > 0) then addMsg("  WARNING: Nil entries - Items: " .. nilItems .. ", Spells: " .. nilSpells, true); end
  else
    addMsg("ItemSpellCache: not initialized", true);
  end

  local validSpells = SmartBuffValidSpells;
  if (validSpells) then
    local validCount, invalidCount = 0, 0;
    if (validSpells.spells) then
      for _, isValid in pairs(validSpells.spells) do
        if (isValid == true) then validCount = validCount + 1; elseif (isValid == false) then invalidCount = invalidCount + 1; end
      end
    end
    addMsg("ValidSpells: version=" .. tostring(validSpells.version) .. ", Valid: " .. validCount .. ", Invalid: " .. invalidCount, true);
  else
    addMsg("ValidSpells: not initialized", true);
  end

  local expected = SMARTBUFF_ExpectedData;
  if (expected) then
    local expectedItems, expectedSpells = 0, 0;
    if (expected.items) then for _ in pairs(expected.items) do expectedItems = expectedItems + 1; end end
    if (expected.spells) then for _ in pairs(expected.spells) do expectedSpells = expectedSpells + 1; end end
    addMsg("ExpectedData: Items: " .. expectedItems .. ", Spells: " .. expectedSpells, true);
  end

  if (cBuffs) then
    local currentCount = 0;
    for i, _ in pairs(cBuffs) do
      if (type(i) == "number" and cBuffs[i] and cBuffs[i].BuffS) then currentCount = currentCount + 1; end
    end
    addMsg("Current Buff List: " .. currentCount .. " buffs", true);
  end

  addMsg("=== End Cache Statistics ===", true);
end

-- Invalidate all buff-related caches (version cleared so next load repopulates)
function SMARTBUFF_InvalidateBuffCache()
  if (SmartBuffBuffListCache) then
    SmartBuffBuffListCache.version = nil;
    SmartBuffBuffListCache.lastUpdate = 0;
    wipe(SmartBuffBuffListCache.expectedCounts);
    wipe(SmartBuffBuffListCache.enabledBuffs);
  end

  if (SmartBuffToyCache) then
    SmartBuffToyCache.version = nil;
    SmartBuffToyCache.lastUpdate = 0;
    SmartBuffToyCache.toyCount = 0;
    wipe(SmartBuffToyCache.toybox);
  end

  if (SmartBuffItemSpellCache) then
    SmartBuffItemSpellCache.version = nil;
    SmartBuffItemSpellCache.lastUpdate = 0;
    wipe(SmartBuffItemSpellCache.items);
    wipe(SmartBuffItemSpellCache.spells);
    wipe(SmartBuffItemSpellCache.itemIDs);
    if (SmartBuffItemSpellCache.itemData) then wipe(SmartBuffItemSpellCache.itemData); end
    if (SmartBuffItemSpellCache.needsRefresh) then wipe(SmartBuffItemSpellCache.needsRefresh); end
  end

  if (SmartBuffBuffRelationsCache) then
    SmartBuffBuffRelationsCache.version = nil;
    SmartBuffBuffRelationsCache.lastUpdate = 0;
    wipe(SmartBuffBuffRelationsCache.chains);
    wipe(SmartBuffBuffRelationsCache.links);
  end
end
