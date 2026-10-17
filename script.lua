local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local FLY_SPEEDS = {90, 130, 170, 220}
local flySpeedIndex = 1
local FLY_SPEED = FLY_SPEEDS[flySpeedIndex]
local FARM_HEIGHTS = {20, 30, 45, 60}
local farmHeightIndex = 2
local FARM_HEIGHT = FARM_HEIGHTS[farmHeightIndex]
local CRUISE_HEIGHTS = {50, 90, 150}
local cruiseIndex = 1
local CRUISE_HEIGHT = CRUISE_HEIGHTS[cruiseIndex]
local FARM_APPROACH = 80
local FAST_RANGE = 60
local MOB_LEVEL_SLACK = 5
local WEAPONS = {"Melee", "Sword", "Blox Fruit"}
local BLUR_SIZE = 14
local BOSS_RANGE = 1500
local BOSS_TIMEOUT = 150
local MATERIAL_DWELL = 300

local EXTRA_BOSS_NAMES = {}

local FORCE_QUEST = nil

local ACCENT   = Color3.fromRGB(59, 130, 246)
local ACCENT2  = Color3.fromRGB(34, 211, 238)
local TEXT     = Color3.fromRGB(240, 240, 250)
local MUTED    = Color3.fromRGB(170, 172, 200)
local RED      = Color3.fromRGB(220, 70, 90)
local GOOD     = Color3.fromRGB(52, 199, 120)

local LANG
do
    local selGui = Instance.new("ScreenGui")
    selGui.Name = "VitaHubLang"
    selGui.ResetOnSpawn = false
    selGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okP = pcall(function() selGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not okP or not selGui.Parent then selGui.Parent = player:WaitForChild("PlayerGui") end

    local function round(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r)
        c.Parent = obj
    end

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 360, 0, 200)
    panel.Position = UDim2.new(0.5, -180, 0.5, -100)
    panel.BackgroundColor3 = Color3.new(1, 1, 1)
    panel.BackgroundTransparency = 0.22
    panel.BorderSizePixel = 0
    panel.Parent = selGui
    round(panel, 20)

    local pg = Instance.new("UIGradient")
    pg.Color = ColorSequence.new(Color3.fromRGB(30, 74, 160), Color3.fromRGB(8, 20, 48))
    pg.Rotation = 55
    pg.Parent = panel

    local ps = Instance.new("UIStroke")
    ps.Color = Color3.new(1, 1, 1)
    ps.Thickness = 1.6
    ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ps.Parent = panel

    local psg = Instance.new("UIGradient")
    psg.Rotation = 45
    psg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.88),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    psg.Parent = ps

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 0, 0, 22)
    title.Size = UDim2.new(1, 0, 0, 36)
    title.BackgroundTransparency = 1
    title.Text = "VitaHub"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 30
    title.Parent = panel
    local tg = Instance.new("UIGradient")
    tg.Color = ColorSequence.new(ACCENT, ACCENT2)
    tg.Rotation = 20
    tg.Parent = title

    local sub = Instance.new("TextLabel")
    sub.Position = UDim2.new(0, 0, 0, 64)
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.BackgroundTransparency = 1
    sub.Text = "Выбери язык  /  Choose your language"
    sub.TextColor3 = MUTED
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 14
    sub.Parent = panel

    local function langButton(text, x, code)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 150, 0, 54)
        b.Position = UDim2.new(0, x, 0, 112)
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        b.AutoButtonColor = false
        b.BackgroundColor3 = Color3.new(1, 1, 1)
        b.BackgroundTransparency = 0.88
        b.BorderSizePixel = 0
        b.Parent = panel
        round(b, 14)

        local st = Instance.new("UIStroke")
        st.Color = Color3.new(1, 1, 1)
        st.Transparency = 0.7
        st.Thickness = 1
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        st.Parent = b

        b.MouseEnter:Connect(function()
            b.BackgroundColor3 = ACCENT
            b.BackgroundTransparency = 0.25
        end)
        b.MouseLeave:Connect(function()
            b.BackgroundColor3 = Color3.new(1, 1, 1)
            b.BackgroundTransparency = 0.88
        end)
        b.Activated:Connect(function() LANG = code end)
    end

    langButton("Русский", 20, "ru")
    langButton("English", 190, "en")

    while not LANG do
        if not selGui.Parent then LANG = "en" break end
        task.wait(0.1)
    end
    pcall(function() selGui:Destroy() end)
end

local I18N = {
    ru = {
        status_wait = "Ожидание",
        cancelled = "Полёт отменён",
        turn_off_farm = "Сначала выключи автофарм / Factory",
        no_fruits = "Фруктов на карте нет",
        fly_fruit = "Лечу к фрукту (%d студов), высота %d",
        arrived = "Прилетел",
        net_missing = "Ремоуты fast attack не найдены, работает только клик",
        no_spawns = "нет споунов моба %s",
        mob_strong = "моб %s слишком сильный (Lv. %d)",
        quest_skipped = "Пропущен квест %s (Lv %d): %s",
        quest_skipped_log = "[VitaHub] пропущен %s:%s (req %d) - %s",
        abandon_fail = "Не удалось отменить старый квест, проверь вручную",
        status_attack = "%s | игрок %d | моб %s | %s x%d",
        no_quest = "Не нашёл квест под твой уровень, автофарм выключен",
        quest_log = "[VitaHub] квест %s:%s, моб %s x%d, req %d, игрок lvl %d",
        taking_quest = "Беру квест: %s",
        quest_failed = "Квест не взялся: %s, бью мобов без него",
        quest_taken = "Квест %s (от lvl %d), мобы %s x%d, игрок lvl %d",
        waiting_mobs = "Жду мобов: %s",
        waiting_respawn = "Жду респавн",
        farm_off = "Автофарм выкл",
        factory_wait = "Factory: жду Core (Sea 2)",
        call_error = "ошибка вызова",
        commf_missing = "CommF_ не найден",
        gacha_got = "получено (см. инвентарь)",
        max = "максимум",
        stat_max3 = "Можно выбрать максимум 3 стата",
        hint = "RightShift -\nскрыть меню",
        tg_boss = "Авто-босс",
        boss_found = "Босс %s на острове! Иду бить",
        boss_killed = "Босс %s побеждён, возвращаюсь к мобам",
        boss_giveup = "Босс %s: не вышло, возвращаюсь к мобам",
        sec_materials = "АВТО-МАТЕРИАЛЫ",
        sec_pick_materials = "ВЫБЕРИ МАТЕРИАЛЫ",
        mat_select_all = "Выбрать все",
        mat_clear = "Снять все",
        mat_none = "Материалы: нет доступных целей (проверь море и уровень)",
        mat_farming = "Фарм материала: %s",
        mat_status = "%s | моб %s (ур. %s) | игрок %d",
        mat_info = "Выбрано: %d  |  Море: %s",
        gacha_lvl = "нужен 50+ уровень (у тебя %d)",
        gacha_beli = "не хватает Beli: нужно ~%d, есть %d",
        gacha_ok = "фрукт получен! следующий ролл через 2 ч",
        gacha_fail = "ролл не удался (ответ: %s). Возможно, идёт откат 2 ч",
        gacha_fly = "Лечу к NPC гачи...",
        gacha_msg = "игра пишет: %s",
        gacha_next = "  |  след. ролл: %s",
        sec_speed = "СКОРОСТЬ ПОЛЁТА",
        sec_raid = "АВТО-РЕЙД",
        sec_raid_type = "ТИП РЕЙДА",
        raid_sea = "Рейды есть только в Sea 2 и Sea 3",
        raid_no_stand = "Не нашёл кнопку запуска рейда",
        raid_no_click = "В твоём executor нет fireclickdetector",
        raid_starting = "Запускаю рейд: %s",
        raid_not_started = "Рейд не запустился, повтор через минуту",
        raid_fight = "Рейд: остров %d",
        raid_status = "Рейд | остров %d | моб %s",
        raid_done = "Рейд завершён",
        sec_tp = "ТЕЛЕПОРТ ПО ОСТРОВАМ",
        tp_info = "Море: %s  |  Островов: %d",
        tp_empty = "Острова не найдены, нажми «Обновить список»",
        tp_refresh = "Обновить список",
        tp_go = "Лететь: %s",
        tp_pick = "Выбери остров из списка",
        tp_cancel = "Отменить полёт",
        tp_flying = "Лечу на остров: %s",
        tp_arrived = "Прилетел на остров: %s",
        sec_chests = "СУНДУКИ",
        tg_chest_stop = "Стоп при Fist of Darkness или чаше",
        chest_info = "Сундуков рядом: %d  |  Собрано: %d",
        chest_going = "Иду к сундуку, рядом %d",
        chest_none = "Сундуков не видно",
        chest_rare = "Выпал %s! Сбор сундуков остановлен",
        sec_swords = "МЕЧИ",
        sec_styles = "СТИЛИ БОЯ",
        sec_abilities = "СИЛЫ",
        shop_buy = "Купить %s",
        shop_info = "Магазин: %s",
        shop_buying = "Покупаю: %s...",
        shop_ok = "%s: куплено",
        shop_msg = "%s: игра пишет: %s",
        shop_reply = "%s: ответ %s",
        shop_noreply = "%s: нет ответа, подойди к NPC и повтори",
        sec_story = "КВЕСТЫ МОРЕЙ",
        tg_story2 = "Авто квест 2 море Ice Admiral",
        tg_story3 = "Авто квест 3 море Rip Indra",
        story_info = "Квест: %s",
        story_need_sea = "Этот квест делается в Sea %d",
        story_need_level = "Нужен %d уровень",
        story_talk = "Иду к NPC: %s",
        story_npc_missing = "NPC не найден: %s",
        story_wait_boss = "Жду босса: %s",
        story_fight = "Бью босса: %s",
        story_call = "Вызов %s: %s",
        story_boss_fail = "Босс не найден: %s",
        story_done = "Квест моря выполнен",
        sec_ken = "НАБЛЮДЕНИЕ",
        ken_info = "Observation: %s",
        ken_going = "Лечу к мобам: %s",
        ken_status = "Уклоняюсь от %s, дистанция %d",
        ken_heal = "Мало здоровья, отхожу вверх",
        ken_no_mobs = "Нет мобов для Observation: %s",
        sec_mastery = "МАСТЕРИ ОРУЖИЯ",
        mastery_info = "Мастери: %s",
        mastery_status = "%s: %d из %d",
        mastery_nolevel = "%s: мастери не читается, фарм идёт",
        mastery_missing = "Нет оружия: %s",
        mastery_done = "Мастери %s достигнуто: %d",
        tg_sound = "Звуки и оповещения",
        shop_sea = "%s: нужно другое море. %s",
        shop_fly = "Лечу к учителю: %s",
        sec_radius = "РАДИУС",
        tg_predict = "Упреждение",
        tg_ignore_team = "Не целиться в свою команду",
        tg_target_hl = "Подсветка цели",
        sec_pvp_extra = "ДОПОЛНИТЕЛЬНО",
        tg_auto_buso = "Авто Buso Haki",
        pvp_target = "Цель: %s | HP %d | %d м",
        pvp_none = "Цель: нет",
        pvp_no_hook = "Silent Aim недоступен: в executor нет hookmetamethod",
        sec_farm = "ФАРМ",
        tg_autofarm = "Автофарм",
        sec_weapon = "ОРУЖИЕ",
        sec_farm_height = "ВЫСОТА ФАРМА",
        sec_auto = "АВТО",
        tg_gacha = "Auto Gacha",
        sec_stats = "СТАТЫ",
        tg_split = "Разделение",
        btn_stop_stats = "Остановить прокачку",
        btn_start_stats = "Начать прокачку",
        sec_cruise = "ВЫСОТА ПОЛЁТА",
        sec_misc = "ПРОЧЕЕ",
        tg_flyfruit = "Полёт к фрукту",
        tg_blur = "Blur фона",
        killed = "VitaHub остановлен, GUI удалён",
        lvl_label = "Твой Лвл : ",
        next_label = "Следующий Остров : ",
        stats_info = "Очков: %d  |  Качаю: %s",
        storage_info = "Хранилище: ",
        gacha_info = "Ответ сервера: ",
        loaded = "VitaHub v1.0 загружен. RightShift - скрыть меню",
    },
    en = {
        status_wait = "Idle",
        cancelled = "Flight cancelled",
        turn_off_farm = "Turn off Auto Farm / Factory first",
        no_fruits = "No fruits on the map",
        fly_fruit = "Flying to fruit (%d studs), altitude %d",
        arrived = "Arrived",
        net_missing = "Fast attack remotes not found, clicks only",
        no_spawns = "no spawns for mob %s",
        mob_strong = "mob %s is too strong (Lv. %d)",
        quest_skipped = "Skipped quest %s (Lv %d): %s",
        quest_skipped_log = "[VitaHub] skipped %s:%s (req %d) - %s",
        abandon_fail = "Couldn't abandon the old quest, check it manually",
        status_attack = "%s | player %d | mob %s | %s x%d",
        no_quest = "No quest found for your level, Auto Farm turned off",
        quest_log = "[VitaHub] quest %s:%s, mob %s x%d, req %d, player lvl %d",
        taking_quest = "Taking quest: %s",
        quest_failed = "Quest not accepted: %s, fighting mobs without it",
        quest_taken = "Quest %s (from lvl %d), mobs %s x%d, player lvl %d",
        waiting_mobs = "Waiting for mobs: %s",
        waiting_respawn = "Waiting for respawn",
        farm_off = "Auto Farm off",
        factory_wait = "Factory: waiting for Core (Sea 2)",
        call_error = "call error",
        commf_missing = "CommF_ not found",
        gacha_got = "received (check inventory)",
        max = "max",
        stat_max3 = "You can select up to 3 stats",
        hint = "RightShift -\nhide menu",
        tg_boss = "Auto Boss",
        boss_found = "Boss %s is here! Going to fight",
        boss_killed = "Boss %s defeated, back to mobs",
        boss_giveup = "Boss %s: couldn't finish, back to mobs",
        sec_materials = "AUTO MATERIALS",
        sec_pick_materials = "SELECT MATERIALS",
        mat_select_all = "Select all",
        mat_clear = "Clear all",
        mat_none = "Materials: no available targets (check sea and level)",
        mat_farming = "Farming material: %s",
        mat_status = "%s | mob %s (lv %s) | player %d",
        mat_info = "Selected: %d  |  Sea: %s",
        gacha_lvl = "need level 50+ (you have %d)",
        gacha_beli = "not enough Beli: need ~%d, have %d",
        gacha_ok = "fruit rolled! next roll in 2 h",
        gacha_fail = "roll failed (reply: %s). Maybe the 2h cooldown is active",
        gacha_fly = "Flying to the gacha NPC...",
        gacha_msg = "game says: %s",
        gacha_next = "  |  next roll: %s",
        sec_speed = "FLIGHT SPEED",
        sec_raid = "AUTO RAID",
        sec_raid_type = "RAID TYPE",
        raid_sea = "Raids exist only in Sea 2 and Sea 3",
        raid_no_stand = "Raid start button not found",
        raid_no_click = "Your executor has no fireclickdetector",
        raid_starting = "Starting raid: %s",
        raid_not_started = "Raid didn't start, retrying in a minute",
        raid_fight = "Raid: island %d",
        raid_status = "Raid | island %d | mob %s",
        raid_done = "Raid finished",
        sec_tp = "ISLAND TELEPORT",
        tp_info = "Sea: %s  |  Islands: %d",
        tp_empty = "No islands found, press \"Refresh list\"",
        tp_refresh = "Refresh list",
        tp_go = "Fly to: %s",
        tp_pick = "Pick an island from the list",
        tp_cancel = "Cancel flight",
        tp_flying = "Flying to island: %s",
        tp_arrived = "Arrived at island: %s",
        sec_chests = "CHESTS",
        tg_chest_stop = "Stop on Fist of Darkness or Chalice",
        chest_info = "Chests nearby: %d  |  Collected: %d",
        chest_going = "Going to a chest, %d nearby",
        chest_none = "No chests in sight",
        chest_rare = "%s dropped! Chest farm stopped",
        sec_swords = "SWORDS",
        sec_styles = "FIGHTING STYLES",
        sec_abilities = "ABILITIES",
        shop_buy = "Buy %s",
        shop_info = "Shop: %s",
        shop_buying = "Buying: %s...",
        shop_ok = "%s: bought",
        shop_msg = "%s: game says: %s",
        shop_reply = "%s: reply %s",
        shop_noreply = "%s: no reply, stand next to the NPC and try again",
        sec_story = "SEA QUESTS",
        tg_story2 = "Auto Quest Sea 2 Ice Admiral",
        tg_story3 = "Auto Quest Sea 3 Rip Indra",
        story_info = "Quest: %s",
        story_need_sea = "This quest is done in Sea %d",
        story_need_level = "Level %d required",
        story_talk = "Going to NPC: %s",
        story_npc_missing = "NPC not found: %s",
        story_wait_boss = "Waiting for boss: %s",
        story_fight = "Fighting boss: %s",
        story_call = "Call %s: %s",
        story_boss_fail = "Boss not found: %s",
        story_done = "Sea quest finished",
        sec_ken = "OBSERVATION",
        ken_info = "Observation: %s",
        ken_going = "Flying to mobs: %s",
        ken_status = "Dodging %s, distance %d",
        ken_heal = "Low health, retreating up",
        ken_no_mobs = "No mobs for Observation: %s",
        sec_mastery = "WEAPON MASTERY",
        mastery_info = "Mastery: %s",
        mastery_status = "%s: %d of %d",
        mastery_nolevel = "%s: can't read mastery, farming anyway",
        mastery_missing = "Weapon not found: %s",
        mastery_done = "%s mastery reached: %d",
        tg_sound = "Sounds",
        shop_sea = "%s: wrong sea. %s",
        shop_fly = "Flying to the teacher: %s",
        sec_radius = "RADIUS",
        tg_predict = "Prediction",
        tg_ignore_team = "Ignore teammates",
        tg_target_hl = "Target Highlight",
        sec_pvp_extra = "EXTRA",
        tg_auto_buso = "Auto Buso Haki",
        pvp_target = "Target: %s | HP %d | %d m",
        pvp_none = "Target: none",
        pvp_no_hook = "Silent Aim unavailable: executor has no hookmetamethod",
        sec_farm = "FARM",
        tg_autofarm = "Auto Farm",
        sec_weapon = "WEAPON",
        sec_farm_height = "FARM HEIGHT",
        sec_auto = "AUTO",
        tg_gacha = "Auto Gacha",
        sec_stats = "STATS",
        tg_split = "Split",
        btn_stop_stats = "Stop leveling",
        btn_start_stats = "Start leveling",
        sec_cruise = "FLIGHT HEIGHT",
        sec_misc = "OTHER",
        tg_flyfruit = "Fly to fruit",
        tg_blur = "Background blur",
        killed = "VitaHub stopped, GUI removed",
        lvl_label = "Your Lvl : ",
        next_label = "Next Island : ",
        stats_info = "Points: %d  |  Leveling: %s",
        storage_info = "Storage: ",
        gacha_info = "Server reply: ",
        loaded = "VitaHub v1.0 loaded. RightShift - hide menu",
    },
}

local function T(key, ...)
    local pack = I18N[LANG] or I18N.ru
    local str = pack[key] or I18N.ru[key] or key
    if select("#", ...) > 0 then
        local ok, res = pcall(string.format, str, ...)
        return ok and res or str
    end
    return str
end

local alive = true
local connections = {}
local function track(c) table.insert(connections, c) return c end

local weaponIndex = 1
local farmMobName = nil
local farmMobSet = nil

local function baseName(n)
    return (n:gsub("%s*%[.-%]%s*$", ""))
end

local function normName(s)
    s = baseName(s):lower():gsub("[^%w]", "")
    return (s:gsub("%d+$", ""))
end

local flying = false
local currentTween
local noclipConn
local statusText = T("status_wait")
local gachaStatus = "-"

local state = {
    fastAttack = false,
    espFruits = false,
    espPlayers = false,
    autoFarm = false,
    autoFactory = false,
    autoStats = false,
    autoGacha = false,
    autoStore = false,
    autoBoss = true,
    autoMaterials = false,
    autoRaid = false,
    autoChest = false,
    autoStory = false,
    chestStop = true,
    splitStats = false,
    blur = true,
    sound = true,
    autoKen = false,
}

local STAT_NAMES = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}
local STAT_LABELS = {"Melee", "Defense", "Sword", "Gun", "Fruit"}
local statIndex = 1
local splitSel = {}
local splitRot = 0
local matSel = {}
local storeStatus = "-"
local storeTried = setmetatable({}, {__mode = "k"})

local refreshGui = function() end

local notify
local toastGui
local uiSound

do
    toastGui = Instance.new("ScreenGui")
    toastGui.Name = "VitaHubToasts"
    toastGui.ResetOnSpawn = false
    toastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toastGui.DisplayOrder = 50
    local okT = pcall(function() toastGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not okT or not toastGui.Parent then toastGui.Parent = player:WaitForChild("PlayerGui") end

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -16, 0, 16)
    holder.Size = UDim2.new(0, 330, 1, -32)
    holder.BackgroundTransparency = 1
    holder.Parent = toastGui

    local holderLayout = Instance.new("UIListLayout")
    holderLayout.Padding = UDim.new(0, 8)
    holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
    holderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    holderLayout.Parent = holder

    local function mkSound(speed, volume)
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxasset://sounds/electronicpingshort.wav"
        snd.PlaybackSpeed = speed
        snd.Volume = volume
        snd.Parent = toastGui
        return snd
    end

    local sounds = {
        click = mkSound(1.9, 0.35),
        on = mkSound(1.6, 0.45),
        off = mkSound(1.05, 0.4),
        toast = mkSound(1.3, 0.7),
        alert = mkSound(0.85, 0.7),
    }

    uiSound = function(kind)
        if not state.sound then return end
        local snd = sounds[kind]
        if snd then
            pcall(function()
                snd.TimePosition = 0
                snd:Play()
            end)
        end
    end

    local counter = 0
    local live = {}

    local function round(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r)
        c.Parent = obj
        return c
    end

    local function show(text, danger)
        counter = counter + 1
        local accent = danger and RED or ACCENT
        local duration = danger and 5.5 or 4

        while #live >= 5 do
            local old = table.remove(live, 1)
            pcall(function() old:Destroy() end)
        end

        local wrapper = Instance.new("Frame")
        wrapper.Size = UDim2.new(1, 0, 0, 0)
        wrapper.AutomaticSize = Enum.AutomaticSize.Y
        wrapper.BackgroundTransparency = 1
        wrapper.LayoutOrder = counter
        wrapper.Parent = holder
        table.insert(live, wrapper)

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.Position = UDim2.new(1.2, 0, 0, 0)
        card.BackgroundColor3 = Color3.new(1, 1, 1)
        card.BackgroundTransparency = 0.6
        card.BorderSizePixel = 0
        card.Parent = wrapper
        round(card, 14)

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new(Color3.fromRGB(30, 74, 160), Color3.fromRGB(8, 20, 48))
        grad.Rotation = 55
        grad.Parent = card

        local stroke = Instance.new("UIStroke")
        stroke.Color = accent
        stroke.Thickness = 1.4
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = card

        local strokeGrad = Instance.new("UIGradient")
        strokeGrad.Rotation = 45
        strokeGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.05),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 0.1),
        })
        strokeGrad.Parent = stroke

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.Parent = card

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.Parent = content

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content

        local head = Instance.new("Frame")
        head.Size = UDim2.new(1, 0, 0, 16)
        head.BackgroundTransparency = 1
        head.LayoutOrder = 1
        head.Parent = content

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0, 0, 0.5, -4)
        dot.BackgroundColor3 = accent
        dot.BorderSizePixel = 0
        dot.Parent = head
        round(dot, 4)

        local title = Instance.new("TextLabel")
        title.Position = UDim2.new(0, 16, 0, 0)
        title.Size = UDim2.new(1, -16, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = "VitaHub"
        title.TextColor3 = MUTED
        title.Font = Enum.Font.GothamBold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = head

        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, 0, 0, 0)
        msg.AutomaticSize = Enum.AutomaticSize.Y
        msg.BackgroundTransparency = 1
        msg.Text = tostring(text)
        msg.TextColor3 = TEXT
        msg.Font = Enum.Font.GothamMedium
        msg.TextSize = 14
        msg.TextWrapped = true
        msg.TextXAlignment = Enum.TextXAlignment.Left
        msg.TextYAlignment = Enum.TextYAlignment.Top
        msg.LayoutOrder = 2
        msg.Parent = content

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 3)
        bar.BackgroundColor3 = accent
        bar.BorderSizePixel = 0
        bar.LayoutOrder = 3
        bar.Parent = content
        round(bar, 2)

        TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0),
        }):Play()
        TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 0.2 }):Play()
        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3),
        }):Play()

        uiSound(danger and "alert" or "toast")

        task.delay(duration, function()
            if not wrapper.Parent then return end

            local out = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1.2, 0, 0, 0),
            })
            out:Play()
            out.Completed:Wait()
            if not wrapper.Parent then return end

            local h = wrapper.AbsoluteSize.Y
            wrapper.AutomaticSize = Enum.AutomaticSize.None
            wrapper.Size = UDim2.new(1, 0, 0, h)
            local collapse = TweenService:Create(wrapper, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 0) })
            collapse:Play()
            collapse.Completed:Wait()

            for i, w in ipairs(live) do
                if w == wrapper then
                    table.remove(live, i)
                    break
                end
            end
            pcall(function() wrapper:Destroy() end)
        end)
    end

    notify = function(text, danger)
        local ok = pcall(show, text, danger)
        if not ok then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "VitaHub", Text = tostring(text), Duration = 3,
                })
            end)
        end
    end
end

local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getPlayerLevel()
    local ok, lvl = pcall(function() return player.Data.Level.Value end)
    return ok and lvl or 1
end

local function getPoints()
    local ok, pts = pcall(function() return player.Data.Points.Value end)
    return ok and pts or 0
end

local function getCommF()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("CommF_")
end

track(player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end))

local function getFruits()
    local fruits = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:find("Fruit") then
            table.insert(fruits, obj)
        end
    end
    return fruits
end

local function updateFruitESP()
    for _, fruit in ipairs(getFruits()) do
        local handle = fruit:FindFirstChild("Handle")
        if handle and not handle:FindFirstChild("FruitESP") then
            local g = Instance.new("BillboardGui")
            g.Name = "FruitESP"
            g.Adornee = handle
            g.Size = UDim2.new(0, 120, 0, 30)
            g.AlwaysOnTop = true

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = fruit.Name
            label.TextColor3 = Color3.fromRGB(255, 200, 0)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.Parent = g
            g.Parent = handle
        end
    end
end

local function clearFruitESP()
    for _, fruit in ipairs(getFruits()) do
        local handle = fruit:FindFirstChild("Handle")
        local e = handle and handle:FindFirstChild("FruitESP")
        if e then e:Destroy() end
    end
end

local function updatePlayerESP()
    local myRoot = getRoot()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local ch = plr.Character
            local hr = ch and ch:FindFirstChild("HumanoidRootPart")
            if ch and hr then
                if not ch:FindFirstChild("VH_Highlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "VH_Highlight"
                    h.FillColor = ACCENT2
                    h.FillTransparency = 0.7
                    h.OutlineColor = Color3.new(1, 1, 1)
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = ch
                end

                local g = hr:FindFirstChild("VH_PlayerESP")
                if not g then
                    g = Instance.new("BillboardGui")
                    g.Name = "VH_PlayerESP"
                    g.Adornee = hr
                    g.Size = UDim2.new(0, 140, 0, 34)
                    g.StudsOffset = Vector3.new(0, 3.5, 0)
                    g.AlwaysOnTop = true

                    local l = Instance.new("TextLabel")
                    l.Name = "L"
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextColor3 = Color3.new(1, 1, 1)
                    l.TextStrokeTransparency = 0.3
                    l.Font = Enum.Font.GothamBold
                    l.TextSize = 13
                    l.Parent = g
                    g.Parent = hr
                end

                local l = g:FindFirstChild("L")
                if l then
                    local d = myRoot and (hr.Position - myRoot.Position).Magnitude or 0
                    l.Text = ("%s\n%d m"):format(plr.DisplayName, d)
                end
            end
        end
    end
end

local function clearPlayerESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        local ch = plr.Character
        if ch then
            local h = ch:FindFirstChild("VH_Highlight")
            if h then h:Destroy() end
            local hr = ch:FindFirstChild("HumanoidRootPart")
            local g = hr and hr:FindFirstChild("VH_PlayerESP")
            if g then g:Destroy() end
        end
    end
end

local stopFarmPhysics, flyToPos

local function stopFlying()
    flying = false
    if not (state.autoFarm or state.autoFactory) then
        stopFarmPhysics()
    end
    refreshGui()
end

local function flyToNearestFruit()
    if flying then
        stopFlying()
        notify(T("cancelled"))
        return
    end
    if state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid or state.autoChest or state.autoStory or state.autoKen then
        notify(T("turn_off_farm"))
        return
    end

    local root = getRoot()
    if not root then return end

    local nearest, minDist = nil, math.huge
    for _, fruit in ipairs(getFruits()) do
        local handle = fruit:FindFirstChild("Handle")
        if handle then
            local dist = (handle.Position - root.Position).Magnitude
            if dist < minDist then nearest, minDist = handle, dist end
        end
    end

    if not nearest then
        notify(T("no_fruits"))
        return
    end

    flying = true
    refreshGui()
    notify(T("fly_fruit", math.floor(minDist), CRUISE_HEIGHT))

    task.spawn(function()
        local ok = flyToPos(nearest.Position + Vector3.new(0, 3, 0), function()
            return not flying or not alive or not nearest.Parent
        end)
        if flying then
            local r = getRoot()
            if ok and r and nearest.Parent then r.CFrame = nearest.CFrame end
            stopFlying()
            if ok then notify(T("arrived")) end
        end
    end)
end

task.spawn(function()
    while alive do
        if state.fastAttack or state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid or state.autoStory then
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(1280, 672))
        end
        task.wait(0.1)
    end
end)

local RegisterAttack, RegisterHit
local netWarned = false

local function findNet()
    if RegisterAttack and RegisterHit then return end
    local mods = ReplicatedStorage:FindFirstChild("Modules")
    local net = mods and mods:FindFirstChild("Net")
    if net then
        RegisterAttack = net:FindFirstChild("RE/RegisterAttack")
        RegisterHit = net:FindFirstChild("RE/RegisterHit")
    end
end

local function netAttack()
    local root = getRoot()
    local folder = Workspace:FindFirstChild("Enemies")
    if not root or not folder then return end

    findNet()
    if not (RegisterAttack and RegisterHit) then
        if not netWarned then
            netWarned = true
            notify(T("net_missing"))
        end
        return
    end

    local onlyMob = (state.autoFarm or state.autoFactory) and farmMobName or nil
    local range = math.max(FAST_RANGE, FARM_HEIGHT + 30)
    local onlySet = state.autoMaterials and farmMobSet or nil

    local list = {}
    for _, e in ipairs(folder:GetChildren()) do
        local hum = e:FindFirstChildOfClass("Humanoid")
        local er = e:FindFirstChild("HumanoidRootPart")
        if hum and er and hum.Health > 0
            and (er.Position - root.Position).Magnitude <= range
            and (not onlyMob or baseName(e.Name) == onlyMob)
            and (not onlySet or onlySet[baseName(e.Name)]) then
            list[#list + 1] = {e, er}
        end
    end
    if #list == 0 then return end

    local first = list[1][1]:FindFirstChild("Head") or list[1][2]
    RegisterAttack:FireServer(0.1)
    RegisterHit:FireServer(first, list)
end

task.spawn(function()
    while alive do
        if state.fastAttack or state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid or state.autoStory then
            pcall(netAttack)
        end
        task.wait(0.05)
    end
end)

local farmNoclip
local farmTween

local forcedWeapon = nil

local function equipWeapon()
    local char = player.Character
    local hum = getHumanoid()
    if not char or not hum then return end

    if forcedWeapon then
        local held = char:FindFirstChild(forcedWeapon)
        if held and held:IsA("Tool") then return held end
        local tool = player.Backpack:FindFirstChild(forcedWeapon)
        if tool and tool:IsA("Tool") then
            hum:UnequipTools()
            hum:EquipTool(tool)
            return tool
        end
    end

    local want = WEAPONS[weaponIndex]

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.ToolTip == want then return tool end
            hum:UnequipTools()
            break
        end
    end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == want then
            hum:EquipTool(tool)
            return tool
        end
    end
end

local function startFarmPhysics()
    local root = getRoot()
    if not root then return end
    if not root:FindFirstChild("FarmHold") then
        local hold = Instance.new("BodyVelocity")
        hold.Name = "FarmHold"
        hold.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        hold.Velocity = Vector3.zero
        hold.Parent = root
    end
    if not farmNoclip then
        farmNoclip = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
end

function stopFarmPhysics()
    if farmTween then farmTween:Cancel() farmTween = nil end
    if farmNoclip then farmNoclip:Disconnect() farmNoclip = nil end
    local root = getRoot()
    local hold = root and root:FindFirstChild("FarmHold")
    if hold then hold:Destroy() end
end

local function tweenTo(dest, abort)
    local root = getRoot()
    if not root then return false end

    local dist = (dest - root.Position).Magnitude
    if dist < 1 then return true end

    local t = TweenService:Create(
        root,
        TweenInfo.new(math.max(dist / FLY_SPEED, 0.05), Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(dest)}
    )
    farmTween = t
    t:Play()

    while t.PlaybackState == Enum.PlaybackState.Playing do
        if abort and abort() then
            t:Cancel()
            farmTween = nil
            return false
        end
        task.wait(0.1)
    end
    farmTween = nil
    return true
end

function flyToPos(dest, abort)
    local root = getRoot()
    if not root then return false end
    startFarmPhysics()

    local pos = root.Position
    local flat = (Vector3.new(dest.X, 0, dest.Z) - Vector3.new(pos.X, 0, pos.Z)).Magnitude

    if flat > 120 then
        local cruiseY = math.max(pos.Y, dest.Y) + CRUISE_HEIGHT
        if not tweenTo(Vector3.new(pos.X, cruiseY, pos.Z), abort) then return false end
        if not tweenTo(Vector3.new(dest.X, cruiseY, dest.Z), abort) then return false end
    end

    return tweenTo(dest, abort)
end

local QuestData
local function loadQuests()
    if QuestData then return QuestData end
    local ok, res = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Quests", 5))
    end)
    if ok and type(res) == "table" then QuestData = res end
    return QuestData
end

local function getSpawnPositions(mob)
    local list = {}
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local folder = origin and origin:FindFirstChild("EnemySpawns")

    if folder then
        for _, p in ipairs(folder:GetChildren()) do
            if p:IsA("BasePart") and baseName(p.Name) == mob then
                list[#list + 1] = p.Position
            end
        end

        if #list == 0 then
            local want = normName(mob)
            for _, p in ipairs(folder:GetChildren()) do
                if p:IsA("BasePart") and normName(p.Name) == want then
                    list[#list + 1] = p.Position
                end
            end
        end
    end

    if #list == 0 then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, e in ipairs(enemies:GetChildren()) do
                local er = e:FindFirstChild("HumanoidRootPart")
                if er and baseName(e.Name) == mob then
                    list[#list + 1] = er.Position
                end
            end
        end
    end

    return list
end

local function getMobLevel(mob)
    local hum = mob:FindFirstChildOfClass("Humanoid")
    local str = (hum and hum.DisplayName or "") .. " " .. mob.Name
    local lv = str:match("%[Lv%.%s*(%d+)%]")
    return lv and tonumber(lv) or nil
end

local function mobLevelOk(mob)
    local ml = getMobLevel(mob)
    return not ml or ml <= getPlayerLevel() + MOB_LEVEL_SLACK
end

local function liveMobLevel(mobName)
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    for _, mob in ipairs(folder:GetChildren()) do
        if baseName(mob.Name) == mobName then
            local ml = getMobLevel(mob)
            if ml then return ml end
        end
    end
    return nil
end

local function skipReason(c, lvl)
    if #getSpawnPositions(c.mob) == 0 then
        return T("no_spawns", c.mob)
    end
    local ml = liveMobLevel(c.mob)
    if ml and ml > lvl + MOB_LEVEL_SLACK then
        return T("mob_strong", c.mob, ml)
    end
    return nil
end

local warnedSkips = {}

local function pickQuest()
    local quests = loadQuests()
    if not quests then return nil end

    local lvl = getPlayerLevel()

    if FORCE_QUEST then
        local tier = quests[FORCE_QUEST.name] and quests[FORCE_QUEST.name][FORCE_QUEST.idx]
        if type(tier) == "table" and type(tier.Task) == "table" then
            local mob, cnt
            for m, c in pairs(tier.Task) do mob, cnt = m, c end
            if mob then
                return { name = FORCE_QUEST.name, idx = FORCE_QUEST.idx, mob = mob,
                         count = type(cnt) == "number" and cnt or 1, req = tier.LevelReq or 0 }
            end
        end
    end

    local cands = {}
    for qName, tiers in pairs(quests) do
        if type(tiers) == "table" then
            for idx, data in pairs(tiers) do
                if type(data) == "table"
                    and type(data.LevelReq) == "number"
                    and type(data.Task) == "table"
                    and data.LevelReq <= lvl then

                    local mob, cnt
                    for m, c in pairs(data.Task) do
                        mob, cnt = m, c
                    end
                    if mob and type(cnt) == "number" and cnt > 1 then
                        cands[#cands + 1] = { name = qName, idx = idx, mob = mob, count = cnt, req = data.LevelReq }
                    end
                end
            end
        end
    end

    table.sort(cands, function(a, b)
        if a.req ~= b.req then return a.req > b.req end
        return tostring(a.name) .. ":" .. tostring(a.idx) < tostring(b.name) .. ":" .. tostring(b.idx)
    end)

    local skipped = {}
    for _, c in ipairs(cands) do
        local why = skipReason(c, lvl)
        if not why then
            local top = skipped[1]
            if top and lvl - c.req >= 25 then
                local key = tostring(top.name) .. ":" .. tostring(top.idx)
                if not warnedSkips[key] then
                    warnedSkips[key] = true
                    notify(T("quest_skipped", tostring(top.name), top.req, top.why))
                end
            end
            for i = 1, math.min(3, #skipped) do
                print(T("quest_skipped_log",
                    tostring(skipped[i].name), tostring(skipped[i].idx), skipped[i].req, skipped[i].why))
            end
            return c
        end
        c.why = why
        skipped[#skipped + 1] = c
    end

    return nil
end

local function questActive()
    local ok, vis = pcall(function() return player.PlayerGui.Main.Quest.Visible end)
    return ok and vis == true
end

local function questMentionsMob(mob)
    local ok, qgui = pcall(function() return player.PlayerGui.Main.Quest end)
    if not ok or not qgui then return nil end

    local want = mob:lower()
    local stem = want:gsub("y$", "")
    local sawText = false

    for _, d in ipairs(qgui:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text ~= "" then
            sawText = true
            local txt = d.Text:lower()
            if txt:find(want, 1, true) or txt:find(stem, 1, true) then
                return true
            end
        end
    end
    return sawText and false or nil
end

local function ensureQuest(q, abort)
    local comm = getCommF()
    if not comm then return false end

    if questActive() then
        if questMentionsMob(q.mob) == true then
            return true
        end

        for _ = 1, 3 do
            if abort() then return false end
            pcall(function() comm:InvokeServer("AbandonQuest") end)
            task.wait(0.6)
            if not questActive() then break end
        end
        if questActive() then
            notify(T("abandon_fail"))
        end
    end

    for _ = 1, 3 do
        if abort() then return false end
        pcall(function() comm:InvokeServer("StartQuest", q.name, q.idx) end)
        task.wait(0.8)
        if questActive() then return true end
    end
    return false
end

local function getNearestQuestMob(mobName)
    local folder = Workspace:FindFirstChild("Enemies")
    local root = getRoot()
    if not folder or not root then return end

    local best, bestDist = nil, math.huge
    for _, mob in ipairs(folder:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local mroot = mob:FindFirstChild("HumanoidRootPart")
        if hum and mroot and hum.Health > 0 and baseName(mob.Name) == mobName and mobLevelOk(mob) then
            local d = (mroot.Position - root.Position).Magnitude
            if d < bestDist then best, bestDist = mob, d end
        end
    end
    return best
end

local function attackMob(mob, q, abort)
    local mroot = mob:FindFirstChild("HumanoidRootPart")
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if not mroot or not hum then return end

    statusText = q.status or T("status_attack",
        q.mob, getPlayerLevel(), tostring(getMobLevel(mob) or "?"), tostring(q.name), q.count)

    local r = getRoot()
    if r and (mroot.Position - r.Position).Magnitude > FARM_APPROACH then
        if not flyToPos(mroot.Position + Vector3.new(0, FARM_HEIGHT, 0), abort) then return end
    end
    startFarmPhysics()

    local conn
    conn = RunService.Heartbeat:Connect(function()
        local root = getRoot()
        if alive and not abort() and root and mroot.Parent and hum.Health > 0 then
            local pos = mroot.Position + Vector3.new(0, FARM_HEIGHT, 0)
            root.CFrame = CFrame.new(pos, mroot.Position)
        else
            conn:Disconnect()
        end
    end)

    while not abort() and mroot.Parent and hum.Health > 0 do
        task.wait()
    end
    if conn then conn:Disconnect() end
    return hum.Health <= 0
end

local bossQuestCache
local bossCooldown = {}

local function getBossQuests()
    if bossQuestCache then return bossQuestCache end
    local quests = loadQuests()
    if not quests then return {} end

    local list = {}
    for qName, tiers in pairs(quests) do
        if type(tiers) == "table" then
            for idx, data in pairs(tiers) do
                if type(data) == "table"
                    and type(data.LevelReq) == "number"
                    and type(data.Task) == "table" then
                    local mob, cnt
                    for m, c in pairs(data.Task) do mob, cnt = m, c end
                    if mob and cnt == 1 then
                        list[#list + 1] = { name = qName, idx = idx, mob = mob, count = 1, req = data.LevelReq }
                    end
                end
            end
        end
    end
    bossQuestCache = list
    return list
end

local function findBoss()
    local folder = Workspace:FindFirstChild("Enemies")
    local root = getRoot()
    if not folder or not root then return nil end

    local lvl = getPlayerLevel()
    local map = {}
    for _, bq in ipairs(getBossQuests()) do
        if bq.req <= lvl and (not map[bq.mob] or bq.req > map[bq.mob].req) then
            map[bq.mob] = bq
        end
    end
    for _, name in ipairs(EXTRA_BOSS_NAMES) do
        if not map[name] then map[name] = { mob = name, count = 1, req = 0 } end
    end

    local best, bestBq, bestDist = nil, nil, math.huge
    for _, e in ipairs(folder:GetChildren()) do
        local name = baseName(e.Name)
        local bq = map[name]
        local hum = e:FindFirstChildOfClass("Humanoid")
        local er = e:FindFirstChild("HumanoidRootPart")
        if bq and hum and er and hum.Health > 0
            and (bossCooldown[name] or 0) < os.clock()
            and mobLevelOk(e) then
            local d = (er.Position - root.Position).Magnitude
            if d <= BOSS_RANGE and d < bestDist then
                best, bestBq, bestDist = e, bq, d
            end
        end
    end
    return best, bestBq
end

local function fightBoss(boss, bq, abort)
    local bossName = baseName(boss.Name)
    local hum = boss:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    notify(T("boss_found", bossName))
    farmMobName = bossName

    if bq.name then
        statusText = T("taking_quest", tostring(bq.name))
        ensureQuest(bq, abort)
    end

    local t0 = os.clock()
    local function bossAbort()
        return abort() or not boss.Parent or os.clock() - t0 > BOSS_TIMEOUT
    end

    equipWeapon()
    local killed = attackMob(boss, { mob = bossName, name = bq.name or "Boss", count = 1 }, bossAbort)
    killed = killed or hum.Health <= 0

    if killed then
        notify(T("boss_killed", bossName))
        bossCooldown[bossName] = os.clock() + 20
    else
        if not abort() then notify(T("boss_giveup", bossName)) end
        bossCooldown[bossName] = os.clock() + 120
    end
    return killed
end

local function farmCycle()
    local function on() return alive and state.autoFarm end
    local abort = function() return not on() end

    local q = pickQuest()
    if not q then
        notify(T("no_quest"))
        state.autoFarm = false
        refreshGui()
        return true
    end
    farmMobName = q.mob
    print(T("quest_log",
        tostring(q.name), tostring(q.idx), q.mob, q.count, q.req, getPlayerLevel()))

    local root = getRoot()
    if not root then return false end
    local spawns = getSpawnPositions(q.mob)
    if #spawns == 0 then return false end
    table.sort(spawns, function(a, b)
        return (a - root.Position).Magnitude < (b - root.Position).Magnitude
    end)
    local anchor = spawns[1]
    local cluster = {}
    for _, p in ipairs(spawns) do
        if (p - anchor).Magnitude <= 250 then
            cluster[#cluster + 1] = p
        end
    end

    statusText = T("taking_quest", tostring(q.name))
    if not ensureQuest(q, abort) then
        notify(T("quest_failed", tostring(q.name)))
    end
    local detect = questActive()
    notify(T("quest_taken",
        tostring(q.name), q.req, q.mob, q.count, getPlayerLevel()))

    local kills = 0
    local spIdx, lastSeen = 1, os.clock()
    local lastTry, lastPick = os.clock(), os.clock()
    local lastBossCheck = 0

    while on() do
        local hum = getHumanoid()
        if not getRoot() or not hum or hum.Health <= 0 then return true end

        if detect then
            if not questActive() and os.clock() - lastTry > 2 then
                lastTry = os.clock()
                ensureQuest(q, abort)
            end
        elseif kills >= q.count then
            kills = 0
            ensureQuest(q, abort)
        end

        if os.clock() - lastPick > 5 then
            lastPick = os.clock()
            local nq = pickQuest()
            if nq and nq.req > q.req then
                return true
            end
        end

        if state.autoBoss and os.clock() - lastBossCheck > 2 then
            lastBossCheck = os.clock()
            local boss, bq = findBoss()
            if boss then
                fightBoss(boss, bq, abort)
                farmMobName = q.mob
                if on() then
                    statusText = T("taking_quest", tostring(q.name))
                    ensureQuest(q, abort)
                end
                lastSeen = os.clock()
            end
        end

        equipWeapon()
        local mob = getNearestQuestMob(q.mob)

        if mob then
            lastSeen = os.clock()
            if attackMob(mob, q, abort) then kills = kills + 1 end
        else
            statusText = T("waiting_mobs", q.mob)
            if os.clock() - lastSeen > 3 then
                spIdx = spIdx % #cluster + 1
                flyToPos(cluster[spIdx] + Vector3.new(0, FARM_HEIGHT, 0), abort)
                lastSeen = os.clock()
            end
            task.wait(0.3)
        end
    end

    return true
end

task.spawn(function()
    while alive do
        if state.autoFarm then
            local hum = getHumanoid()
            if not getRoot() or not hum or hum.Health <= 0 then
                statusText = T("waiting_respawn")
                task.wait(1)
            else
                local ok = farmCycle()
                if not ok and alive and state.autoFarm then task.wait(2) end
            end
        else
            if not state.autoFactory and not state.autoMaterials and not state.autoRaid and not state.autoChest and not state.autoStory and not state.autoKen and not flying then
                if not state.autoFarm and not state.autoStats and not state.autoGacha then
                    statusText = T("farm_off")
                end
                farmMobName = nil
                stopFarmPhysics()
            end
            task.wait(0.3)
        end
        task.wait()
    end
    stopFarmPhysics()
end)

local MATERIALS = {
    { id = "angel_wings", name = "Angel Wings",
      mobs = { [1] = {"God's Guard", "Shanda", "Royal Squad", "Royal Soldier"} } },
    { id = "leather", name = "Leather",
      mobs = { [1] = {"Pirate", "Brute"}, [2] = {"Swan Pirate"}, [3] = {"Jungle Pirate"} } },
    { id = "scrap_metal", name = "Scrap Metal",
      mobs = { [1] = {"Pirate", "Brute"}, [2] = {"Swan Pirate"}, [3] = {"Jungle Pirate"} } },
    { id = "magma_ore", name = "Magma Ore",
      mobs = { [1] = {"Military Soldier", "Military Spy"}, [2] = {"Lava Pirate", "Magma Ninja"} } },
    { id = "fish_tail", name = "Fish Tail",
      mobs = { [1] = {"Fishman Warrior", "Fishman Commando"},
               [3] = {"Fishman Raider", "Fisherman Raider", "Fishman Captain"} } },
    { id = "yeti_fur", name = "Yeti Fur",
      mobs = { [1] = {"Yeti"} } },
    { id = "ectoplasm", name = "Ectoplasm",
      mobs = { [2] = {"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"} } },
    { id = "mystic_droplet", name = "Mystic Droplet",
      mobs = { [2] = {"Sea Soldier", "Water Fighter"} } },
    { id = "radioactive", name = "Radioactive Material",
      mobs = { [2] = {"Factory Staff"} } },
    { id = "vampire_fang", name = "Vampire Fang",
      mobs = { [2] = {"Vampire"} } },
    { id = "bones", name = "Bones",
      mobs = { [3] = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Possessed Mummy"} } },
    { id = "demonic_wisp", name = "Demonic Wisp",
      mobs = { [3] = {"Demonic Soul"} } },
    { id = "nightmare_catcher", name = "Nightmare Catcher",
      mobs = { [3] = {"Reborn Skeleton", "Living Zombie"} } },
    { id = "dragon_scale", name = "Dragon Scale",
      mobs = { [3] = {"Dragon Crew Warrior", "Dragon Crew Archer"} } },
    { id = "fire_flower", name = "Fire Flower",
      mobs = { [3] = {"Dragon Wizard"} } },
    { id = "conjured_cocoa", name = "Conjured Cocoa",
      mobs = { [3] = {"Cocoa Warrior", "Chocolate Bar Battler"} } },
    { id = "mini_tusk", name = "Mini Tusk",
      mobs = { [3] = {"Mythological Pirate"} } },
    { id = "gunpowder", name = "Gunpowder",
      mobs = { [3] = {"Pistol Billionaire"} } },
}

local function currentSea()
    local id = game.PlaceId
    if id == 2753915549 then return 1 end
    if id == 4442272183 then return 2 end
    if id == 7449423635 then return 3 end
    return nil
end

local function matInSea(mat)
    local sea = currentSea()
    if not sea then return true end
    return mat.mobs[sea] ~= nil
end

local function matSeaTag(mat)
    local seas = {}
    for sea in pairs(mat.mobs) do seas[#seas + 1] = sea end
    table.sort(seas)
    return "Sea " .. table.concat(seas, "/")
end

local mobReqCache
local function getMobReq(name)
    local quests = loadQuests()
    if not quests then return nil end
    if not mobReqCache then
        mobReqCache = {}
        for _, tiers in pairs(quests) do
            if type(tiers) == "table" then
                for _, d in pairs(tiers) do
                    if type(d) == "table" and type(d.LevelReq) == "number" and type(d.Task) == "table" then
                        for m in pairs(d.Task) do
                            if not mobReqCache[m] or d.LevelReq < mobReqCache[m] then
                                mobReqCache[m] = d.LevelReq
                            end
                        end
                    end
                end
            end
        end
    end
    return mobReqCache[name]
end

local function getMaterialTargets()
    local sea = currentSea()
    local lvl = getPlayerLevel()
    local list = {}

    for _, mat in ipairs(MATERIALS) do
        if matSel[mat.id] then
            local mobs = {}
            if sea then
                mobs = mat.mobs[sea] or {}
            else
                for _, group in pairs(mat.mobs) do
                    for _, m in ipairs(group) do mobs[#mobs + 1] = m end
                end
            end

            local usable = {}
            for _, m in ipairs(mobs) do
                local req = getMobReq(m)
                if (not req or req <= lvl + MOB_LEVEL_SLACK) and #getSpawnPositions(m) > 0 then
                    usable[#usable + 1] = m
                end
            end

            if #usable > 0 then
                list[#list + 1] = { id = mat.id, name = mat.name, mobs = usable }
            end
        end
    end
    return list
end

local function getNearestMobOf(set)
    local folder = Workspace:FindFirstChild("Enemies")
    local root = getRoot()
    if not folder or not root then return end

    local best, bestDist = nil, math.huge
    for _, mob in ipairs(folder:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local mroot = mob:FindFirstChild("HumanoidRootPart")
        if hum and mroot and hum.Health > 0 and set[baseName(mob.Name)] and mobLevelOk(mob) then
            local d = (mroot.Position - root.Position).Magnitude
            if d < bestDist then best, bestDist = mob, d end
        end
    end
    return best
end

local function farmMaterial(tgt, abort)
    local mobSet = {}
    for _, m in ipairs(tgt.mobs) do mobSet[m] = true end
    farmMobSet = mobSet

    local root = getRoot()
    if not root then return end

    local spawns = {}
    for _, m in ipairs(tgt.mobs) do
        for _, p in ipairs(getSpawnPositions(m)) do spawns[#spawns + 1] = p end
    end
    if #spawns == 0 then return end

    table.sort(spawns, function(a, b)
        return (a - root.Position).Magnitude < (b - root.Position).Magnitude
    end)
    local anchor = spawns[1]
    local cluster = {}
    for _, p in ipairs(spawns) do
        if (p - anchor).Magnitude <= 250 then cluster[#cluster + 1] = p end
    end

    notify(T("mat_farming", tgt.name))
    local t0 = os.clock()
    local function stop()
        return abort() or os.clock() - t0 >= MATERIAL_DWELL
    end

    local spIdx, lastSeen = 1, os.clock()
    while not stop() do
        local hum = getHumanoid()
        if not getRoot() or not hum or hum.Health <= 0 then return end

        equipWeapon()
        local mob = getNearestMobOf(mobSet)
        if mob then
            lastSeen = os.clock()
            local name = baseName(mob.Name)
            attackMob(mob, {
                mob = name, name = tgt.name, count = 0,
                status = T("mat_status", tgt.name, name, tostring(getMobLevel(mob) or "?"), getPlayerLevel()),
            }, stop)
        else
            statusText = T("waiting_mobs", table.concat(tgt.mobs, ", "))
            if os.clock() - lastSeen > 3 then
                spIdx = spIdx % #cluster + 1
                flyToPos(cluster[spIdx] + Vector3.new(0, FARM_HEIGHT, 0), stop)
                lastSeen = os.clock()
            end
            task.wait(0.3)
        end
    end
end

task.spawn(function()
    local idx = 1
    while alive do
        if state.autoMaterials then
            local hum = getHumanoid()
            if not getRoot() or not hum or hum.Health <= 0 then
                statusText = T("waiting_respawn")
                task.wait(1)
            else
                local targets = getMaterialTargets()
                if #targets == 0 then
                    statusText = T("mat_none")
                    task.wait(2)
                else
                    if idx > #targets then idx = 1 end
                    farmMaterial(targets[idx], function()
                        return not (alive and state.autoMaterials)
                    end)
                    idx = idx % #targets + 1
                    task.wait(0.5)
                end
            end
        else
            farmMobSet = nil
            task.wait(0.5)
        end
        task.wait()
    end
end)

local RAID_TYPES = {
    "Flame", "Ice", "Quake", "Light", "Dark", "String",
    "Magma", "Human: Buddha", "Sand", "Bird: Phoenix", "Dough",
}
local raidIdx = 1
local RAID_RADIUS = 450

local function raidIslands()
    local list = {}
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return list end

    for i = 1, 5 do
        local isl = locs:FindFirstChild("Island " .. i)
        if isl then
            local pos
            if isl:IsA("BasePart") then
                pos = isl.Position
            elseif isl:IsA("Model") then
                pos = isl:GetPivot().Position
            end
            if pos then list[#list + 1] = { idx = i, pos = pos } end
        end
    end
    return list
end

local function raidStandButton()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end

    local sea = currentSea()
    local summon
    if sea == 2 then
        local ci = map:FindFirstChild("CircleIsland")
        summon = ci and ci:FindFirstChild("RaidSummon")
    elseif sea == 3 then
        local bc = map:FindFirstChild("Boat Castle")
        summon = bc and bc:FindFirstChild("RaidSummon2")
    end

    local btn = summon and summon:FindFirstChild("Button")
    local main = btn and btn:FindFirstChild("Main")
    local cd = main and main:FindFirstChildOfClass("ClickDetector")
    if main and cd then return main, cd end
    return nil
end

local function startRaid(abort)
    local sea = currentSea()
    if sea ~= 2 and sea ~= 3 then return false, "raid_sea" end
    if not fireclickdetector then return false, "raid_no_click" end

    local main, cd = raidStandButton()
    if not main then return false, "raid_no_stand" end

    statusText = T("raid_starting", RAID_TYPES[raidIdx])
    if not flyToPos(main.Position + Vector3.new(0, 4, 0), abort) then return false end

    local comm = getCommF()
    if comm then
        pcall(function() comm:InvokeServer("RaidsNpc", "Select", RAID_TYPES[raidIdx]) end)
        task.wait(1)
    end
    pcall(function() fireclickdetector(cd) end)

    local t0 = os.clock()
    while os.clock() - t0 < 25 do
        if abort() then return false end
        if #raidIslands() > 0 then return true end
        task.wait(0.5)
    end
    return false, "raid_not_started"
end

local function nearestRaidMob(center)
    local folder = Workspace:FindFirstChild("Enemies")
    local root = getRoot()
    if not folder or not root then return nil end

    local best, bestDist = nil, math.huge
    for _, e in ipairs(folder:GetChildren()) do
        local hum = e:FindFirstChildOfClass("Humanoid")
        local er = e:FindFirstChild("HumanoidRootPart")
        if hum and er and hum.Health > 0 and (er.Position - center).Magnitude <= RAID_RADIUS then
            local d = (er.Position - root.Position).Magnitude
            if d < bestDist then best, bestDist = e, d end
        end
    end
    return best
end

local function fightRaid(abort)
    local function active() return #raidIslands() > 0 end

    while active() and not abort() do
        for _, isl in ipairs(raidIslands()) do
            if abort() or not active() then return end
            if not flyToPos(isl.pos + Vector3.new(0, FARM_HEIGHT, 0), abort) then return end

            local t0, lastSeen = os.clock(), os.clock()
            while not abort() and active() and os.clock() - t0 < 150 do
                local hum = getHumanoid()
                if not getRoot() or not hum or hum.Health <= 0 then return end

                equipWeapon()
                local mob = nearestRaidMob(isl.pos)
                if mob then
                    lastSeen = os.clock()
                    local name = baseName(mob.Name)
                    attackMob(mob, {
                        mob = name, name = "Raid", count = 0,
                        status = T("raid_status", isl.idx, name),
                    }, abort)
                else
                    statusText = T("raid_fight", isl.idx)
                    if os.clock() - lastSeen > 4 then break end
                    task.wait(0.3)
                end
            end
        end
        task.wait(1)
    end
end

task.spawn(function()
    while alive do
        if state.autoRaid then
            local abort = function() return not (alive and state.autoRaid) end
            local hum = getHumanoid()

            if not getRoot() or not hum or hum.Health <= 0 then
                statusText = T("waiting_respawn")
                task.wait(1)
            elseif #raidIslands() > 0 then
                fightRaid(abort)
                if not abort() and #raidIslands() == 0 then
                    notify(T("raid_done"))
                    task.wait(10)
                end
            else
                local started, why = startRaid(abort)
                if not started and not abort() then
                    statusText = T(why or "raid_not_started")
                    task.wait(60)
                end
            end
        else
            task.wait(0.5)
        end
        task.wait()
    end
end)

local tpIslands = {}
local tpSelected = nil

local TP_HIDE = { ["volcano cave"] = true }

local function cleanIslandList(list)
    local out, uc, wp = {}, nil, nil
    for _, isl in ipairs(list) do
        local low = isl.name:lower()
        if TP_HIDE[low] or isl.name:match("%d%d%d+$") then

        elseif low == "underwater city" then
            uc = isl
        elseif low == "whirlpool" then
            wp = isl
        else
            out[#out + 1] = isl
        end
    end

    if uc and wp then
        uc.pos = wp.pos
        out[#out + 1] = uc
    elseif uc then
        out[#out + 1] = uc
    elseif wp then
        wp.name = "Underwater City"
        out[#out + 1] = wp
    end
    return out
end

local function scanIslands()
    local list, seen = {}, {}

    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if locs then
        for _, obj in ipairs(locs:GetChildren()) do
            local name = obj.Name
            if not name:match("^Island %d") and not seen[name] then
                local pos
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    pos = obj:GetPivot().Position
                end
                if pos then
                    seen[name] = true
                    list[#list + 1] = { name = name, pos = pos }
                end
            end
        end
    end

    if #list < 3 then
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetChildren()) do
                if obj:IsA("Model") and not seen[obj.Name] then
                    local ok, pos = pcall(function() return obj:GetPivot().Position end)
                    if ok then
                        seen[obj.Name] = true
                        list[#list + 1] = { name = obj.Name, pos = pos }
                    end
                end
            end
        end
    end

    list = cleanIslandList(list)
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

local function flyToIsland()
    if flying then
        stopFlying()
        notify(T("cancelled"))
        return
    end
    if state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid or state.autoChest or state.autoStory or state.autoKen then
        notify(T("turn_off_farm"))
        return
    end

    local isl
    for _, i in ipairs(tpIslands) do
        if i.name == tpSelected then isl = i end
    end
    if not isl then
        notify(T("tp_pick"))
        return
    end

    flying = true
    refreshGui()
    notify(T("tp_flying", isl.name))

    task.spawn(function()
        local ok = flyToPos(isl.pos + Vector3.new(0, 25, 0), function()
            return not flying or not alive
        end)
        if flying then
            stopFlying()
            if ok then notify(T("tp_arrived", isl.name)) end
        end
    end)
end

local function getCore()
    local folder = Workspace:FindFirstChild("Enemies")
    local core = folder and folder:FindFirstChild("Core")
    if core and core:FindFirstChild("HumanoidRootPart") then
        local hum = core:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return core end
    end
    return nil
end

task.spawn(function()
    while alive do
        if state.autoFactory and not state.autoFarm then
            local hum = getHumanoid()
            local core = getCore()
            if hum and hum.Health > 0 and core then
                farmMobName = "Core"
                equipWeapon()
                attackMob(core, { mob = "Core", name = "Factory", count = 1 }, function()
                    return not (alive and state.autoFactory) or state.autoFarm
                end)
            else
                statusText = T("factory_wait")
                if farmMobName == "Core" then farmMobName = nil end
                task.wait(2)
            end
        else
            task.wait(0.5)
        end
        task.wait()
    end
end)

task.spawn(function()
    while alive do
        if state.autoStats then
            local total = getPoints()
            if total > 0 then
                local comm = getCommF()
                if comm then
                    local targets = {}
                    if state.splitStats then
                        for i = 1, #STAT_NAMES do
                            if splitSel[i] then targets[#targets + 1] = STAT_NAMES[i] end
                        end
                    end
                    if #targets == 0 then targets = { STAT_NAMES[statIndex] } end

                    local n = #targets
                    local share = math.floor(total / n)
                    local rest = total - share * n

                    local amounts = {}
                    for k = 1, n do amounts[k] = share end
                    for r = 1, rest do
                        local k = ((splitRot + r) % n) + 1
                        amounts[k] = amounts[k] + 1
                    end
                    splitRot = (splitRot + rest) % n

                    for k, stat in ipairs(targets) do
                        if amounts[k] > 0 then
                            pcall(function() comm:InvokeServer("AddPoint", stat, amounts[k]) end)
                            task.wait(0.15)
                        end
                    end
                end
            end
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end)

local function fruitRemoteName(tool)
    local attr = tool:GetAttribute("OriginalName")
    if type(attr) == "string" and attr ~= "" then return attr end

    local base = tool.Name:gsub("%s*Fruit%s*$", "")
    base = base:gsub("^%s+", "")
    return base .. "-" .. base
end

task.spawn(function()
    while alive do
        if state.autoStore then
            local comm = getCommF()
            if comm then
                local containers = { player.Backpack, player.Character }
                for _, container in ipairs(containers) do
                    if container then
                        for _, tool in ipairs(container:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                local last = storeTried[tool]
                                if not last or os.clock() - last > 10 then
                                    storeTried[tool] = os.clock()
                                    local fname = fruitRemoteName(tool)
                                    local ok, res = pcall(function()
                                        return comm:InvokeServer("StoreFruit", fname, tool)
                                    end)
                                    if not ok then
                                        storeStatus = T("call_error")
                                    else
                                        storeStatus = fname .. ": " .. tostring(res)
                                    end
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            else
                storeStatus = T("commf_missing")
            end
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end)

local GACHA_COOLDOWN = 7200
local gachaNext = nil
local gachaBackoff = 30
local gachaResume = 0

local function getBeli()
    local ok, v = pcall(function() return player.Data.Beli.Value end)
    if ok and type(v) == "number" then return v end
    return nil
end

local function snapshotFruitTools()
    local set = {}
    for _, container in ipairs({ player.Backpack, player.Character }) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find("Fruit") then
                    set[tool] = true
                end
            end
        end
    end
    return set
end

local function describeReply(res)
    if res == nil then return "nil" end
    if type(res) == "table" then return "table" end
    return type(res) .. ":" .. tostring(res)
end

local function findGachaNpc()
    local folder = Workspace:FindFirstChild("NPCs")
    if not folder then return nil end
    for _, n in ipairs(folder:GetChildren()) do
        local nm = n.Name:lower()
        if nm:find("gacha") or nm:find("zioles") or nm:find("cousin") then
            local part
            if n:IsA("Model") then
                part = n.PrimaryPart or n:FindFirstChild("HumanoidRootPart")
            elseif n:IsA("BasePart") then
                part = n
            end
            if part then return part end
        end
    end
    return nil
end

local function captureMessages(fn)
    local msgs = {}
    local pg = player:FindFirstChild("PlayerGui")
    local conn
    if pg then
        conn = pg.DescendantAdded:Connect(function(d)
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                task.delay(0.15, function()
                    local ok, txt = pcall(function() return d.Text end)
                    if ok and type(txt) == "string" then
                        txt = (txt:gsub("<[^>]+>", ""))
                        if #txt > 2 and #msgs < 4 and not d:FindFirstAncestor("VitaHubGui") then
                            msgs[#msgs + 1] = txt
                        end
                    end
                end)
            end
        end)
    end

    local ok, res = pcall(fn)
    task.wait(1.5)
    if conn then conn:Disconnect() end
    return ok, res, msgs
end

local function buyOnce(comm, cost)
    local before = snapshotFruitTools()
    local beliBefore = getBeli()

    local ok, res, msgs = captureMessages(function()
        return comm:InvokeServer("Cousin", "Buy")
    end)
    if not ok then return false, nil, msgs, true end
    print("[VitaHub] gacha reply: " .. describeReply(res) .. (#msgs > 0 and (" | game: " .. table.concat(msgs, " / ")) or ""))

    local function purchased()
        for tool in pairs(snapshotFruitTools()) do
            if not before[tool] then return true end
        end
        local now = getBeli()
        if beliBefore and now and now <= beliBefore - cost * 0.4 then return true end
        return false
    end

    local success = (res == 1 or res == true) or purchased()
    if not success then
        for _, d in ipairs({ 0.5, 1.5 }) do
            task.wait(d)
            if purchased() then
                success = true
                break
            end
        end
    end
    return success, res, msgs, false
end

local function rollGacha()
    local lvl = getPlayerLevel()
    if lvl < 50 then
        gachaStatus = T("gacha_lvl", lvl)
        return 30
    end

    local cost = 25000 + 150 * (lvl - 1)
    local beli = getBeli()
    if beli and beli < cost * 0.8 then
        gachaStatus = T("gacha_beli", math.floor(cost * 0.8), math.floor(beli))
        return 30
    end

    local comm = getCommF()
    if not comm then
        gachaStatus = T("commf_missing")
        return 30
    end

    local success, res, msgs, errored = buyOnce(comm, cost)
    if errored then
        gachaStatus = T("call_error")
        return 30
    end

    if not success and res == nil and #msgs == 0 then
        local npc = findGachaNpc()
        local busy = state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid or state.autoChest or state.autoStory or state.autoKen or flying
        local root = getRoot()
        if npc and root and not busy and (root.Position - npc.Position).Magnitude > 30 then
            gachaStatus = T("gacha_fly")
            local arrived = flyToPos(npc.Position + Vector3.new(0, 4, 0), function()
                return not (alive and state.autoGacha)
            end)
            if arrived then
                success, res, msgs, errored = buyOnce(comm, cost)
            end
            stopFarmPhysics()
            if errored then
                gachaStatus = T("call_error")
                return 30
            end
        end
    end

    if success then
        gachaStatus = T("gacha_ok")
        gachaNext = os.clock() + GACHA_COOLDOWN
        gachaBackoff = 30
        return GACHA_COOLDOWN
    end

    if #msgs > 0 then
        gachaStatus = T("gacha_msg", table.concat(msgs, " / "))
    elseif type(res) == "string" and res ~= "" then
        gachaStatus = res
    else
        gachaStatus = T("gacha_fail", describeReply(res))
    end
    local waitFor = gachaBackoff
    gachaBackoff = math.min(gachaBackoff * 2, 300)
    return waitFor
end

task.spawn(function()
    while alive do
        if state.autoGacha and os.clock() >= gachaResume then
            local ok, delay = pcall(rollGacha)
            if not ok then
                gachaStatus = T("call_error")
                delay = 30
            end
            gachaResume = os.clock() + (delay or 30)
        end
        task.wait(0.5)
    end
end)

local Chest = { found = 0, collected = 0 }

do
    local CollectionService = game:GetService("CollectionService")
    local visited = setmetatable({}, { __mode = "k" })

    local function chestPos(obj)
        if obj:IsA("BasePart") then return obj.Position end
        if obj:IsA("Model") then
            local ok, p = pcall(function() return obj:GetPivot().Position end)
            if ok then return p end
        end
        return nil
    end

    local function getChests()
        local list, seen = {}, {}

        local ok, tagged = pcall(function() return CollectionService:GetTagged("_ChestTagged") end)
        if ok then
            for _, c in ipairs(tagged) do
                if not seen[c] and c:IsDescendantOf(Workspace) then
                    local pos = chestPos(c)
                    if pos then
                        seen[c] = true
                        list[#list + 1] = { obj = c, pos = pos }
                    end
                end
            end
        end

        if #list == 0 then
            for _, c in ipairs(Workspace:GetChildren()) do
                if (c:IsA("BasePart") or c:IsA("Model")) and c.Name:match("^Chest%d") and not seen[c] then
                    local pos = chestPos(c)
                    if pos then
                        seen[c] = true
                        list[#list + 1] = { obj = c, pos = pos }
                    end
                end
            end
        end
        return list
    end

    local function rareCount()
        local n, name = 0, nil
        for _, container in ipairs({ player.Backpack, player.Character }) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        local low = tool.Name:lower():gsub("[^%w]", "")
                        if low:find("fistofdarkness", 1, true)
                            or low:find("godschalice", 1, true)
                            or low:find("godchalice", 1, true) then
                            n = n + 1
                            name = tool.Name
                        end
                    end
                end
            end
        end
        return n, name
    end

    task.spawn(function()
        local wasOn, baseline = false, 0
        while alive do
            if state.autoChest then
                local hum = getHumanoid()
                local root = getRoot()

                if not wasOn then
                    wasOn = true
                    baseline = rareCount()
                    Chest.collected = 0
                end

                if not root or not hum or hum.Health <= 0 then
                    statusText = T("waiting_respawn")
                    task.wait(1)
                else
                    local count, rareName = rareCount()
                    if state.chestStop and count > baseline then
                        state.autoChest = false
                        stopFarmPhysics()
                        notify(T("chest_rare", rareName or "Fist of Darkness"))
                        refreshGui()
                    else
                        local list = getChests()
                        Chest.found = #list

                        local best, bestDist
                        for _, c in ipairs(list) do
                            local t = visited[c.obj]
                            if not t or os.clock() - t > 20 then
                                local d = (c.pos - root.Position).Magnitude
                                if not bestDist or d < bestDist then best, bestDist = c, d end
                            end
                        end

                        if best then
                            statusText = T("chest_going", #list)
                            local abort = function() return not (alive and state.autoChest) end
                            if flyToPos(best.pos + Vector3.new(0, 3, 0), abort) then
                                local r = getRoot()
                                if r then r.CFrame = CFrame.new(best.pos) end
                                task.wait(0.5)
                                visited[best.obj] = os.clock()
                                if not best.obj.Parent or not best.obj:IsDescendantOf(Workspace) then
                                    Chest.collected = Chest.collected + 1
                                end
                            end
                        else
                            statusText = T("chest_none")
                            task.wait(3)
                        end
                    end
                end
            else
                wasOn = false
                task.wait(0.5)
            end
            task.wait()
        end
    end)
end

local Shop = { status = "-" }

do
    local function seaSet(...)
        local t = {}
        for _, v in ipairs({ ... }) do t[v] = true end
        return t
    end

    Shop.swords = {
        { name = "Cutlass",           args = { "BuyItem", "Cutlass" } },
        { name = "Katana",            args = { "BuyItem", "Katana" } },
        { name = "Iron Mace",         args = { "BuyItem", "Iron Mace" } },
        { name = "Dual Katana",       args = { "BuyItem", "Duel Katana" } },
        { name = "Triple Katana",     args = { "BuyItem", "Triple Katana" } },
        { name = "Pipe",              args = { "BuyItem", "Pipe" } },
        { name = "Dual-Headed Blade", args = { "BuyItem", "Dual-Headed Blade" } },
        { name = "Bisento",           args = { "BuyItem", "Bisento" } },
        { name = "Soul Cane",         args = { "BuyItem", "Soul Cane" } },
    }

    Shop.styles = {
        { name = "Black Leg",
          attempts = { { "BuyBlackLeg" }, { "BuyBlackLeg", true } },
          npc = { "dark step", "black leg", "phoeyu" },
          where = "Dark Step Teacher, Pirate Village Sea 1, 150,000 Beli" },
        { name = "Electro",
          attempts = { { "BuyElectro" }, { "BuyElectro", true } },
          npc = { "mad scientist", "electro" },
          where = "Mad Scientist, Skylands Sea 1, 500,000 Beli" },
        { name = "Fishman Karate",
          attempts = { { "BuyFishmanKarate" }, { "BuyFishmanKarate", true } },
          npc = { "water kung", "fishman karate" },
          where = "Water Kung Fu Teacher, Underwater City, 750,000 Beli" },
        { name = "Dragon Claw",
          attempts = { { "BlackbeardReward", "DragonClaw", "2" } },
          seas = seaSet(2),
          npc = { "sabi" },
          where = "Sabi, Kingdom of Rose Sea 2, 1,500 Fragments" },
        { name = "Superhuman",
          attempts = { { "BuySuperhuman" }, { "BuySuperhuman", true } },
          seas = seaSet(2, 3),
          npc = { "martial arts" },
          where = "Martial Arts Master, Snow Mountain Sea 2, 3,000,000 Beli, 300 mastery on Dark Step Electric Water Kung Fu Dragon Breath" },
        { name = "Death Step",
          attempts = { { "BuyDeathStep" }, { "BuyDeathStep", true } },
          seas = seaSet(2),
          npc = { "death step" },
          where = "Death Step teacher, Library Sea 2, 2,500,000 Beli, 5,000 Fragments, 400 Dark Step, Library Key" },
        { name = "Sharkman Karate",
          attempts = { { "BuySharkmanKarate" }, { "BuySharkmanKarate", true } },
          seas = seaSet(2, 3),
          npc = { "daigrock", "sharkman" },
          where = "Daigrock, Forgotten Island Sea 2, 2,500,000 Beli, 5,000 Fragments, 400 Water Kung Fu, Water Key" },
        { name = "Electric Claw",
          attempts = { { "BuyElectricClaw" }, { "BuyElectricClaw", true } },
          seas = seaSet(3),
          npc = { "previous hero" },
          where = "Previous Hero, Floating Turtle Sea 3, 3,000,000 Beli, 5,000 Fragments, 400 Electro" },
        { name = "Dragon Talon",
          attempts = { { "BuyDragonTalon" }, { "BuyDragonTalon", true } },
          seas = seaSet(3),
          npc = { "uzoth" },
          where = "Uzoth, Hydra Island Sea 3, 3,000,000 Beli, 5,000 Fragments, 400 Dragon Breath" },
        { name = "Godhuman",
          attempts = { { "BuyGodhuman" }, { "BuyGodhuman", true } },
          seas = seaSet(3),
          npc = { "ancient monk" },
          where = "Ancient Monk, Temple of Time Sea 3, 5,000,000 Beli, 5,000 Fragments, 400 mastery on the five elite styles, materials" },
        { name = "Sanguine Art",
          attempts = { { "BuySanguineArt" }, { "BuySanguineArt", true } },
          seas = seaSet(3),
          npc = { "sanguine" },
          where = "Sanguine Art teacher, Sea 3, special materials" },
    }

    Shop.abilities = {
        { name = "Buso Haki", args = { "BuyHaki", "Buso" },  npc = { "ability teacher" } },
        { name = "Geppo",     args = { "BuyHaki", "Geppo" }, npc = { "ability teacher" } },
        { name = "Soru",      args = { "BuyHaki", "Soru" },  npc = { "ability teacher" } },
        { name = "Ken Haki",  args = { "KenTalk", "Buy" } },
    }

    local function findNpcPart(patterns)
        local folder = Workspace:FindFirstChild("NPCs")
        if not folder then return nil end
        for _, n in ipairs(folder:GetChildren()) do
            local low = n.Name:lower()
            for _, pat in ipairs(patterns) do
                if low:find(pat, 1, true) then
                    local part
                    if n:IsA("Model") then
                        part = n.PrimaryPart or n:FindFirstChild("HumanoidRootPart")
                    elseif n:IsA("BasePart") then
                        part = n
                    end
                    if part then return part end
                end
            end
        end
        return nil
    end

    local function shopBusy()
        return state.autoFarm or state.autoFactory or state.autoMaterials or state.autoRaid
            or state.autoChest or state.autoStory or state.autoKen or flying
    end

    local buying = false

    function Shop.buy(item)
        if buying then return end

        local comm = getCommF()
        if not comm then
            Shop.status = T("commf_missing")
            return
        end

        local sea = currentSea()
        if item.seas and sea and not item.seas[sea] then
            Shop.status = T("shop_sea", item.name, item.where or "")
            return
        end

        buying = true
        task.spawn(function()
            Shop.status = item.where and (item.name .. ": " .. item.where) or T("shop_buying", item.name)

            if item.npc and not shopBusy() then
                local part = findNpcPart(item.npc)
                local root = getRoot()
                if part and root and (part.Position - root.Position).Magnitude > 25 then
                    Shop.status = T("shop_fly", item.name)
                    flyToPos(part.Position + Vector3.new(0, 4, 0), function() return not alive end)
                    stopFarmPhysics()
                    task.wait(0.4)
                end
            end

            local attempts = item.attempts or { item.args }
            local ok, res, msgs = true, nil, {}
            for _, args in ipairs(attempts) do
                ok, res, msgs = captureMessages(function()
                    return comm:InvokeServer(table.unpack(args))
                end)
                print("[VitaHub] shop " .. item.name .. " " .. tostring(args[1]) .. ": " .. describeReply(res))
                if not ok or #msgs > 0 or res == 1 or res == true or (type(res) == "string" and res ~= "") then
                    break
                end
            end

            if not ok then
                Shop.status = item.name .. ": " .. T("call_error")
            elseif #msgs > 0 then
                Shop.status = T("shop_msg", item.name, table.concat(msgs, " / "))
            elseif res == 1 or res == true then
                Shop.status = T("shop_ok", item.name)
            elseif type(res) == "string" and res ~= "" then
                Shop.status = item.name .. ": " .. res
            elseif res == nil then
                Shop.status = T("shop_noreply", item.name) .. (item.where and (" | " .. item.where) or "")
            else
                Shop.status = T("shop_reply", item.name, describeReply(res))
            end
            buying = false
        end)
    end
end

local PvP = {
    silent = false, predict = true, team = true, highlight = true, buso = false,
    radiusIdx = 3, radii = { 100, 200, 300, 500 }, target = nil, status = "-",
}

do
    local mouse = player:GetMouse()
    local hooked = false

    local function pickTarget()
        local myRoot = getRoot()
        if not myRoot then return nil end
        local radius = PvP.radii[PvP.radiusIdx]
        local best, bestDist
        for _, plr in ipairs(Players:GetPlayers()) do
            local mate = PvP.team and plr.Team ~= nil and plr.Team == player.Team
            if plr ~= player and not mate then
                local ch = plr.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local d = (hrp.Position - myRoot.Position).Magnitude
                    if d <= radius and (not bestDist or d < bestDist) then
                        best, bestDist = plr, d
                    end
                end
            end
        end
        return best, bestDist
    end

    function PvP.aimPos()
        local plr = PvP.target
        local ch = plr and plr.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local pos = hrp.Position
        if PvP.predict then
            pos = pos + hrp.AssemblyLinearVelocity * 0.12
        end
        return pos
    end

    local function installHooks()
        if hooked then return true end
        if not (hookmetamethod and getnamecallmethod and newcclosure and checkcaller) then
            return false
        end

        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if PvP.silent and PvP.target and self == mouse and not checkcaller() then
                if key == "Hit" then
                    local pos = PvP.aimPos()
                    if pos then return CFrame.new(pos) end
                elseif key == "Target" then
                    local ch = PvP.target.Character
                    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                    if hrp then return hrp end
                end
            end
            return oldIndex(self, key)
        end))

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            if PvP.silent and PvP.target and not checkcaller() then
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local owner = self.Parent
                    local char = player.Character
                    if owner and char and owner:IsA("Tool") and owner.Parent == char then
                        local pos = PvP.aimPos()
                        if pos then
                            local args = { ... }
                            local changed = false
                            for i = 1, select("#", ...) do
                                local a = args[i]
                                if typeof(a) == "Vector3" then
                                    args[i] = pos
                                    changed = true
                                elseif typeof(a) == "CFrame" then
                                    args[i] = CFrame.new(pos)
                                    changed = true
                                end
                            end
                            if changed then
                                return oldNamecall(self, table.unpack(args, 1, select("#", ...)))
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end))

        hooked = true
        return true
    end

    task.spawn(function()
        local hl
        while alive do
            if PvP.silent then
                local plr, dist = pickTarget()
                PvP.target = plr
                local ch = plr and plr.Character
                if plr and ch then
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    PvP.status = T("pvp_target", plr.DisplayName, hum and math.floor(hum.Health) or 0, math.floor(dist or 0))
                    if PvP.highlight then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.FillColor = RED
                            hl.OutlineColor = Color3.new(1, 1, 1)
                            hl.FillTransparency = 0.7
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        hl.Adornee = ch
                        hl.Parent = ch
                    elseif hl then
                        hl.Adornee = nil
                    end
                else
                    PvP.status = T("pvp_none")
                    if hl then hl.Adornee = nil end
                end
            else
                PvP.target = nil
                PvP.status = T("pvp_none")
                if hl then
                    hl:Destroy()
                    hl = nil
                end
            end
            task.wait(0.1)
        end
        if hl then hl:Destroy() end
    end)

    task.spawn(function()
        while alive do
            if PvP.buso then
                local ch = player.Character
                if ch and not ch:FindFirstChild("HasBuso") then
                    local comm = getCommF()
                    if comm then pcall(function() comm:InvokeServer("Buso") end) end
                end
            end
            task.wait(2)
        end
    end)

    function PvP.toggleSilent()
        if PvP.silent then
            PvP.silent = false
        elseif installHooks() then
            PvP.silent = true
        else
            notify(T("pvp_no_hook"))
        end
        refreshGui()
    end

    function PvP.setRadius(i)
        PvP.radiusIdx = i
        refreshGui()
    end

    function PvP.togglePredict()
        PvP.predict = not PvP.predict
        refreshGui()
    end

    function PvP.toggleTeam()
        PvP.team = not PvP.team
        refreshGui()
    end

    function PvP.toggleHighlight()
        PvP.highlight = not PvP.highlight
        refreshGui()
    end

    function PvP.toggleBuso()
        PvP.buso = not PvP.buso
        refreshGui()
    end
end

local Story = { status = "-", mode = 2 }

do
    local function npcPart(patterns)
        local folder = Workspace:FindFirstChild("NPCs")
        if not folder then return nil end
        for _, n in ipairs(folder:GetChildren()) do
            local low = n.Name:lower()
            for _, pat in ipairs(patterns) do
                if low:find(pat, 1, true) then
                    local part
                    if n:IsA("Model") then
                        part = n.PrimaryPart or n:FindFirstChild("HumanoidRootPart")
                    elseif n:IsA("BasePart") then
                        part = n
                    end
                    if part then return part end
                end
            end
        end
        return nil
    end

    local function goNpc(patterns, label, abort)
        local part = npcPart(patterns)
        if not part then
            Story.status = T("story_npc_missing", label)
            return false
        end
        Story.status = T("story_talk", label)
        return flyToPos(part.Position + Vector3.new(0, 4, 0), abort)
    end

    local function invoke(...)
        local comm = getCommF()
        if not comm then return nil end
        local args = { ... }
        local ok, res, msgs = captureMessages(function()
            return comm:InvokeServer(table.unpack(args))
        end)
        print("[VitaHub] story " .. tostring(args[1]) .. " " .. tostring(args[2] or "") .. ": " .. describeReply(res))
        local shown = #msgs > 0 and table.concat(msgs, " / ") or describeReply(res)
        Story.status = T("story_call", tostring(args[1]), shown)
        return res
    end

    local function findBossModel(patterns)
        local folder = Workspace:FindFirstChild("Enemies")
        if not folder then return nil end
        for _, e in ipairs(folder:GetChildren()) do
            local low = e.Name:lower()
            for _, pat in ipairs(patterns) do
                if low:find(pat, 1, true) then
                    local hum = e:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
                        return e
                    end
                end
            end
        end
        return nil
    end

    local function fightBoss(patterns, label, spawnNames, abort, stopAtHalf)
        local waited = 0
        while not abort() do
            local boss = findBossModel(patterns)
            if boss then
                waited = 0
                local hum = boss:FindFirstChildOfClass("Humanoid")

                local function halfDone()
                    return stopAtHalf and hum.Health <= hum.MaxHealth * 0.5
                end

                if halfDone() then return true end
                equipWeapon()

                local function stopFn()
                    return abort() or not boss.Parent or hum.Health <= 0 or halfDone()
                end

                attackMob(boss, {
                    mob = baseName(boss.Name), name = label, count = 1,
                    status = T("story_fight", label),
                }, stopFn)

                if hum.Health <= 0 or halfDone() then return true end
            else
                Story.status = T("story_wait_boss", label)
                if waited % 15 == 0 then
                    for _, nm in ipairs(spawnNames) do
                        local sp = getSpawnPositions(nm)
                        if #sp > 0 then
                            flyToPos(sp[1] + Vector3.new(0, FARM_HEIGHT, 0), abort)
                            break
                        end
                    end
                end
                task.wait(1)
                waited = waited + 1
                if waited > 120 then return false end
            end
        end
        return false
    end

    local function runSea2(abort)
        local sea = currentSea()
        if sea and sea ~= 1 then
            Story.status = T("story_need_sea", 1)
            return false, true
        end
        if getPlayerLevel() < 700 then
            Story.status = T("story_need_level", 700)
            return false, true
        end

        goNpc({ "detective" }, "Military Detective", abort)
        if abort() then return false end
        invoke("DressrosaQuestProgress", "Detective")

        if not fightBoss({ "ice admiral" }, "Ice Admiral", { "Ice Admiral" }, abort, false) then
            if not abort() then Story.status = T("story_boss_fail", "Ice Admiral") end
            return false, true
        end

        goNpc({ "detective" }, "Military Detective", abort)
        if abort() then return false end
        invoke("DressrosaQuestProgress", "Detective")

        goNpc({ "captain" }, "Experienced Captain", abort)
        if abort() then return false end
        invoke("TravelDressrosa")
        return true
    end

    local function runSea3(abort)
        local sea = currentSea()
        if sea and sea ~= 2 then
            Story.status = T("story_need_sea", 2)
            return false, true
        end
        if getPlayerLevel() < 1500 then
            Story.status = T("story_need_level", 1500)
            return false, true
        end

        if findBossModel({ "don swan" }) then
            fightBoss({ "don swan" }, "Don Swan", { "Don Swan" }, abort, false)
            if abort() then return false end
        end

        goNpc({ "red head", "redhead" }, "King Red Head", abort)
        if abort() then return false end
        invoke("ZQuestProgress", "Check")
        invoke("ZQuestProgress", "Begin")

        if not fightBoss({ "rip_indra", "rip indra" }, "Rip Indra", { "rip_indra True Form", "rip_indra" }, abort, true) then
            if not abort() then Story.status = T("story_boss_fail", "Rip Indra") end
            return false, true
        end

        goNpc({ "captain" }, "Mr. Captain", abort)
        if abort() then return false end
        invoke("TravelZou")
        return true
    end

    task.spawn(function()
        while alive do
            if state.autoStory then
                local abort = function() return not (alive and state.autoStory) end
                local hum = getHumanoid()

                if not getRoot() or not hum or hum.Health <= 0 then
                    Story.status = T("waiting_respawn")
                    task.wait(1)
                else
                    local ok, fatal
                    if Story.mode == 2 then
                        ok, fatal = runSea2(abort)
                    else
                        ok, fatal = runSea3(abort)
                    end

                    if not abort() then
                        if ok then
                            notify(T("story_done"))
                        elseif fatal then
                            notify(Story.status)
                        end
                        if ok or fatal then
                            state.autoStory = false
        state.autoKen = false
                            stopFarmPhysics()
                            refreshGui()
                        else
                            task.wait(5)
                        end
                    end
                end
            else
                task.wait(0.5)
            end
            task.wait()
        end
    end)
end

local function seaForLevel(l)
    if l < 700 then return "Sea 1" end
    if l < 1500 then return "Sea 2" end
    return "Sea 3"
end

local Ken = { status = "-" }

do
    local VIM = game:GetService("VirtualInputManager")

    local function fireKen()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local commE = remotes and remotes:FindFirstChild("CommE")
        if commE then
            pcall(function() commE:FireServer("Ken", true) end)
            return
        end
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
    end

    local function farmDodges(q, abort)
        local spawns = getSpawnPositions(q.mob)
        if #spawns == 0 then
            Ken.status = T("ken_no_mobs", q.mob)
            task.wait(3)
            return
        end

        local root = getRoot()
        if not root then return end
        table.sort(spawns, function(a, b)
            return (a - root.Position).Magnitude < (b - root.Position).Magnitude
        end)
        local anchor = spawns[1]
        local cluster, sum = {}, Vector3.zero
        for _, p in ipairs(spawns) do
            if (p - anchor).Magnitude <= 250 then
                cluster[#cluster + 1] = p
                sum = sum + p
            end
        end
        local center = sum / #cluster

        Ken.status = T("ken_going", q.mob)
        if not flyToPos(center + Vector3.new(0, 4, 0), abort) then return end

        local lastKen, lastSeen, spIdx = 0, os.clock(), 1
        while not abort() do
            local hum, r = getHumanoid(), getRoot()
            if not hum or not r or hum.Health <= 0 then return end

            if os.clock() - lastKen > 4 then
                lastKen = os.clock()
                fireKen()
            end

            if hum.Health < hum.MaxHealth * 0.4 then
                Ken.status = T("ken_heal")
                flyToPos(r.Position + Vector3.new(0, 150, 0), abort)
                local t0 = os.clock()
                while not abort() and hum.Health < hum.MaxHealth * 0.9 and os.clock() - t0 < 90 do
                    task.wait(1)
                end
                if abort() then return end
                flyToPos(center + Vector3.new(0, 4, 0), abort)
            else
                local mob = getNearestQuestMob(q.mob)
                if mob then
                    lastSeen = os.clock()
                    local mroot = mob:FindFirstChild("HumanoidRootPart")
                    if mroot then
                        local dist = (mroot.Position - r.Position).Magnitude
                        Ken.status = T("ken_status", q.mob, math.floor(dist))
                        if dist > 22 then
                            flyToPos(mroot.Position + Vector3.new(6, 3, 0), abort)
                        end
                    end
                else
                    Ken.status = T("waiting_mobs", q.mob)
                    if os.clock() - lastSeen > 6 then
                        spIdx = spIdx % #cluster + 1
                        flyToPos(cluster[spIdx] + Vector3.new(0, 4, 0), abort)
                        lastSeen = os.clock()
                    end
                end
                task.wait(0.4)
            end
        end
    end

    task.spawn(function()
        while alive do
            if state.autoKen then
                local abort = function() return not (alive and state.autoKen) end
                local hum, root = getHumanoid(), getRoot()

                if not root or not hum or hum.Health <= 0 then
                    Ken.status = T("waiting_respawn")
                    task.wait(1)
                else
                    local q = pickQuest()
                    if not q then
                        Ken.status = T("no_quest")
                        notify(T("no_quest"))
                        state.autoKen = false
                        stopFarmPhysics()
                        refreshGui()
                    else
                        farmDodges(q, abort)
                    end
                end
            else
                task.wait(0.5)
            end
            task.wait()
        end
    end)
end

local Mastery = {
    idx = 1, targetIdx = 3, active = false, status = "-",
    weapons = { "Cursed Dual Katana", "True Triple Katana", "Soul Guitar", "Godhuman", "Superhuman" },
    labels = { "CDK", "TTK", "Soul Guitar", "GH", "SH" },
    targets = { 400, 500, 600 },
}

do
    local function findTool(name)
        local c = player.Character
        local t = (c and c:FindFirstChild(name)) or player.Backpack:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
        return nil
    end

    local function masteryOf(tool)
        local v = tool:FindFirstChild("Level")
        if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
        local attr = tool:GetAttribute("Level")
        if type(attr) == "number" then return attr end
        return nil
    end

    local function stopMastery()
        Mastery.active = false
        forcedWeapon = nil
        state.autoFarm = false
        stopFarmPhysics()
        refreshGui()
    end

    task.spawn(function()
        while alive do
            if Mastery.active then
                local name = Mastery.weapons[Mastery.idx]
                local label = Mastery.labels[Mastery.idx]
                local target = Mastery.targets[Mastery.targetIdx]

                if not state.autoFarm then
                    Mastery.active = false
                    forcedWeapon = nil
                    refreshGui()
                else
                    local tool = findTool(name)
                    if not tool then
                        Mastery.status = T("mastery_missing", name)
                        notify(T("mastery_missing", name))
                        stopMastery()
                    else
                        forcedWeapon = name
                        local lv = masteryOf(tool)
                        if lv then
                            Mastery.status = T("mastery_status", label, lv, target)
                            if lv >= target then
                                notify(T("mastery_done", label, lv))
                                stopMastery()
                            end
                        else
                            Mastery.status = T("mastery_nolevel", label)
                        end
                    end
                end
            elseif forcedWeapon then
                forcedWeapon = nil
            end
            task.wait(2)
        end
    end)
end

local nextCacheLvl, nextCacheText
local function nextIslandText(lvl)
    if nextCacheLvl == lvl and nextCacheText then return nextCacheText end

    local quests = loadQuests()
    if not quests then return "-" end

    local nextReq
    for _, tiers in pairs(quests) do
        if type(tiers) == "table" then
            for _, d in pairs(tiers) do
                if type(d) == "table" and type(d.LevelReq) == "number" and type(d.Task) == "table"
                    and d.LevelReq > lvl and (not nextReq or d.LevelReq < nextReq) then
                    local cnt
                    for _, c in pairs(d.Task) do cnt = c end
                    if type(cnt) == "number" and cnt > 1 then
                        nextReq = d.LevelReq
                    end
                end
            end
        end
    end

    nextCacheLvl = lvl
    nextCacheText = nextReq and (seaForLevel(nextReq) .. " • Lv " .. nextReq) or T("max")
    return nextCacheText
end

local function toggleFast()
    state.fastAttack = not state.fastAttack
    refreshGui()
end

local function toggleFruitESP()
    state.espFruits = not state.espFruits
    if not state.espFruits then clearFruitESP() end
    refreshGui()
end

local function togglePlayerESP()
    state.espPlayers = not state.espPlayers
    if not state.espPlayers then clearPlayerESP() end
    refreshGui()
end

local function toggleFarm()
    if flying then stopFlying() end
    state.autoFarm = not state.autoFarm
    if state.autoFarm then
        warnedSkips = {}
        state.autoMaterials = false
        state.autoRaid = false
        state.autoChest = false
        state.autoStory = false
        state.autoKen = false
        farmMobSet = nil
    end
    refreshGui()
end

local function toggleFactory()
    if flying then stopFlying() end
    state.autoFactory = not state.autoFactory
    if state.autoFactory then
        state.autoMaterials = false
        state.autoRaid = false
        state.autoChest = false
        state.autoStory = false
        state.autoKen = false
    end
    if not state.autoFactory then
        if farmMobName == "Core" then farmMobName = nil end
        if not state.autoFarm then stopFarmPhysics() end
    end
    refreshGui()
end

local function toggleStats()
    state.autoStats = not state.autoStats
    refreshGui()
end

local function toggleGacha()
    state.autoGacha = not state.autoGacha
    if state.autoGacha and not (gachaNext and os.clock() < gachaNext) then
        gachaResume = 0
        gachaBackoff = 30
    end
    refreshGui()
end

local function toggleStore()
    state.autoStore = not state.autoStore
    refreshGui()
end

local function toggleBoss()
    state.autoBoss = not state.autoBoss
    refreshGui()
end

local function toggleRaid()
    if flying then stopFlying() end
    state.autoRaid = not state.autoRaid
    if state.autoRaid then
        state.autoFarm = false
        state.autoFactory = false
        state.autoMaterials = false
        state.autoChest = false
        state.autoStory = false
        state.autoKen = false
        farmMobSet = nil
    else
        stopFarmPhysics()
    end
    refreshGui()
end

local function toggleChest()
    if flying then stopFlying() end
    state.autoChest = not state.autoChest
    if state.autoChest then
        state.autoFarm = false
        state.autoFactory = false
        state.autoMaterials = false
        state.autoRaid = false
        state.autoStory = false
        state.autoKen = false
        farmMobSet = nil
    else
        stopFarmPhysics()
    end
    refreshGui()
end

local function toggleChestStop()
    state.chestStop = not state.chestStop
    refreshGui()
end

local function toggleStory(mode)
    if flying then stopFlying() end
    if state.autoStory and Story.mode == mode then
        state.autoStory = false
        stopFarmPhysics()
    else
        Story.mode = mode
        state.autoStory = true
        state.autoKen = false
        state.autoFarm = false
        state.autoFactory = false
        state.autoMaterials = false
        state.autoRaid = false
        state.autoChest = false
        farmMobSet = nil
    end
    refreshGui()
end

local function toggleSea2() toggleStory(2) end
local function toggleSea3() toggleStory(3) end

local function toggleKen()
    if flying then stopFlying() end
    state.autoKen = not state.autoKen
    if state.autoKen then
        state.autoFarm = false
        state.autoFactory = false
        state.autoMaterials = false
        state.autoRaid = false
        state.autoChest = false
        state.autoStory = false
        farmMobSet = nil
    else
        stopFarmPhysics()
    end
    refreshGui()
end

function Mastery.toggle()
    if Mastery.active then
        Mastery.active = false
        forcedWeapon = nil
        state.autoFarm = false
        stopFarmPhysics()
    else
        Mastery.active = true
        forcedWeapon = Mastery.weapons[Mastery.idx]
        if not state.autoFarm then toggleFarm() end
    end
    refreshGui()
end

function Mastery.setWeapon(i)
    Mastery.idx = i
    if Mastery.active then forcedWeapon = Mastery.weapons[i] end
    refreshGui()
end

function Mastery.setTarget(i)
    Mastery.targetIdx = i
    refreshGui()
end

local function toggleSound()
    state.sound = not state.sound
    refreshGui()
end

local function toggleMaterials()
    if flying then stopFlying() end
    state.autoMaterials = not state.autoMaterials
    if state.autoMaterials then
        state.autoFarm = false
        state.autoFactory = false
        state.autoRaid = false
        state.autoChest = false
        state.autoStory = false
        state.autoKen = false
    else
        farmMobSet = nil
        stopFarmPhysics()
    end
    refreshGui()
end

local function selectAllMaterials()
    for _, mat in ipairs(MATERIALS) do
        if matInSea(mat) then matSel[mat.id] = true end
    end
    refreshGui()
end

local function clearMaterials()
    matSel = {}
    refreshGui()
end

local function toggleSplit()
    state.splitStats = not state.splitStats
    if state.splitStats and next(splitSel) == nil then
        splitSel[statIndex] = true
    end
    refreshGui()
end

local function setWeapon(i)
    weaponIndex = i
    local hum = getHumanoid()
    if hum then hum:UnequipTools() end
    refreshGui()
end

local function setStat(i)
    if state.splitStats then
        if splitSel[i] then
            splitSel[i] = nil
        else
            local count = 0
            for _ in pairs(splitSel) do count = count + 1 end
            if count >= 3 then
                notify(T("stat_max3"))
                return
            end
            splitSel[i] = true
        end
    else
        statIndex = i
    end
    refreshGui()
end

local function setFarmHeight(i)
    farmHeightIndex = i
    FARM_HEIGHT = FARM_HEIGHTS[i]
    refreshGui()
end

local function setCruiseHeight(i)
    cruiseIndex = i
    CRUISE_HEIGHT = CRUISE_HEIGHTS[i]
    refreshGui()
end

local function setFlySpeed(i)
    flySpeedIndex = i
    FLY_SPEED = FLY_SPEEDS[i]
    refreshGui()
end

local function buildGui()

local gui = Instance.new("ScreenGui")
gui.Name = "VitaHubGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 10)
    c.Parent = obj
    return c
end

local function brandGradient(obj)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(ACCENT, ACCENT2)
    g.Rotation = 20
    g.Parent = obj
    return g
end

local function glass(obj, transp, strokeT)
    obj.BackgroundColor3 = Color3.new(1, 1, 1)
    obj.BackgroundTransparency = transp or 0.9
    obj.BorderSizePixel = 0
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(1, 1, 1)
    s.Transparency = strokeT or 0.8
    s.Thickness = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local W, H = 600, 420

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
main.BackgroundColor3 = Color3.new(1, 1, 1)
main.BackgroundTransparency = 0.22
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
corner(main, UDim.new(0, 20))

local mainGrad = Instance.new("UIGradient")
mainGrad.Color = ColorSequence.new(Color3.fromRGB(30, 74, 160), Color3.fromRGB(8, 20, 48))
mainGrad.Rotation = 55
mainGrad.Parent = main

local mainScale = Instance.new("UIScale")
mainScale.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.new(1, 1, 1)
mainStroke.Thickness = 1.6
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local strokeGrad = Instance.new("UIGradient")
strokeGrad.Rotation = 45
strokeGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 0.88),
    NumberSequenceKeypoint.new(1, 0.2),
})
strokeGrad.Parent = mainStroke

local sheen = Instance.new("Frame")
sheen.Name = "Sheen"
sheen.Size = UDim2.new(1, 0, 0.42, 0)
sheen.BackgroundColor3 = Color3.new(1, 1, 1)
sheen.BorderSizePixel = 0
sheen.Active = false
sheen.Parent = main
corner(sheen, UDim.new(0, 20))

local sheenGrad = Instance.new("UIGradient")
sheenGrad.Rotation = 90
sheenGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.84),
    NumberSequenceKeypoint.new(1, 1),
})
sheenGrad.Parent = sheen

local blur = Instance.new("BlurEffect")
blur.Name = "VH_Blur"
blur.Size = 0
pcall(function() blur.Parent = Lighting end)

local function applyBlur()
    local target = (state.blur and main.Visible) and BLUR_SIZE or 0
    pcall(function()
        TweenService:Create(blur, TweenInfo.new(0.25), {Size = target}):Play()
    end)
end

local function toggleBlur()
    state.blur = not state.blur
    applyBlur()
    refreshGui()
end

local function makeDraggable(handle, target, onClick)
    local dragging, moved = false, false
    local dragStart, startPos

    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart, startPos = input.Position, target.Position
        end
    end))

    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if d.Magnitude > 6 then moved = true end
            if moved then
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end))

    track(UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved and onClick then onClick() end
        end
    end))
end

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundTransparency = 1
header.Parent = main

local titleLbl = Instance.new("TextLabel")
titleLbl.Position = UDim2.new(0, 20, 0, 8)
titleLbl.Size = UDim2.new(0, 220, 0, 28)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "VitaHub"
titleLbl.TextColor3 = Color3.new(1, 1, 1)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 24
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = header
brandGradient(titleLbl)

local subLbl = Instance.new("TextLabel")
subLbl.Position = UDim2.new(0, 20, 0, 36)
subLbl.Size = UDim2.new(0, 220, 0, 14)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Blox Fruits  •  v1.0"
subLbl.TextColor3 = MUTED
subLbl.Font = Enum.Font.Gotham
subLbl.TextSize = 12
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.Parent = header

makeDraggable(header, main)

local function windowButton(text, x, tint, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0, 14)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.AutoButtonColor = false
    b.Parent = header
    glass(b, 0.88, 0.7)
    if tint then b.BackgroundColor3 = tint b.BackgroundTransparency = 0.45 end
    corner(b, UDim.new(1, 0))
    b.Activated:Connect(callback)
    return b
end

local function infoPill(x, w)
    local pill = Instance.new("Frame")
    pill.Position = UDim2.new(0, x, 0, 58)
    pill.Size = UDim2.new(0, w, 0, 26)
    pill.Parent = main
    glass(pill, 0.88, 0.72)
    corner(pill, UDim.new(0, 13))

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = TEXT
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Text = ""
    l.Parent = pill
    return l
end

local lvlLabel = infoPill(16, 170)
local nextLabel = infoPill(194, W - 194 - 16)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.new(0, 14, 0, 98)
sidebar.Size = UDim2.new(0, 128, 0, H - 98 - 14)
sidebar.BackgroundTransparency = 1
sidebar.Parent = main

local updaters = {}
local orders = {}
local function nextOrder(p)
    orders[p] = (orders[p] or 0) + 1
    return orders[p]
end

local tabNames = {"Combat", "Visuals", "Auto", "Teleport", "Shop", "PvP", "Misc"}
local pages = {}
local tabButtons = {}
local currentTab = "Combat"

for i, name in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.Position = UDim2.new(0, 0, 0, (i - 1) * 40)
    b.Text = name
    b.TextColor3 = TEXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.Parent = sidebar
    glass(b, 0.9, 0.8)
    corner(b, UDim.new(0, 12))
    tabButtons[name] = b
end

local hint = Instance.new("TextLabel")
hint.Position = UDim2.new(0, 0, 1, -34)
hint.Size = UDim2.new(1, 0, 0, 32)
hint.BackgroundTransparency = 1
hint.Text = T("hint")
hint.TextColor3 = MUTED
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = sidebar

local CONTENT_X, CONTENT_Y = 152, 98
local CONTENT_W = W - CONTENT_X - 14
local CONTENT_H = H - CONTENT_Y - 14 - 34

local function makePage(name)
    local sf = Instance.new("ScrollingFrame")
    sf.Name = name
    sf.Position = UDim2.new(0, CONTENT_X, 0, CONTENT_Y)
    sf.Size = UDim2.new(0, CONTENT_W, 0, CONTENT_H)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = ACCENT
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.Parent = main

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = sf

    local pd = Instance.new("UIPadding")
    pd.PaddingRight = UDim.new(0, 6)
    pd.PaddingBottom = UDim.new(0, 4)
    pd.Parent = sf

    pages[name] = sf
    return sf
end

local combatPage = makePage("Combat")
local visualsPage = makePage("Visuals")
local autoPage = makePage("Auto")
local tpPage = makePage("Teleport")
local shopPage = makePage("Shop")
local pvpPage = makePage("PvP")
local miscPage = makePage("Misc")

local function setTab(name)
    local changed = (currentTab ~= name)
    currentTab = name
    for n, p in pairs(pages) do p.Visible = (n == name) end
    local page = pages[name]
    if page and changed then
        page.Position = UDim2.new(0, CONTENT_X + 22, 0, CONTENT_Y)
        TweenService:Create(page, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, CONTENT_X, 0, CONTENT_Y),
        }):Play()
    end
    refreshGui()
end

local function pressFx(btn)
    local sc = Instance.new("UIScale")
    sc.Parent = btn
    local tin = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    btn.MouseButton1Down:Connect(function() TweenService:Create(sc, tin, { Scale = 0.96 }):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(sc, tin, { Scale = 1 }):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(sc, tin, { Scale = 1 }):Play() end)
end

for name, b in pairs(tabButtons) do
    pressFx(b)
    b.Activated:Connect(function()
        uiSound("click")
        setTab(name)
    end)
end

table.insert(updaters, function()
    for name, b in pairs(tabButtons) do
        local sel = (name == currentTab)
        b.BackgroundColor3 = sel and ACCENT or Color3.new(1, 1, 1)
        b.BackgroundTransparency = sel and 0.15 or 0.9
    end
end)

local function sectionLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = MUTED
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = nextOrder(parent)
    l.Parent = parent
end

local function makeToggle(parent, text, hotkey, getFn, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = nextOrder(parent)
    row.Parent = parent
    glass(row, 0.9, 0.8)
    corner(row, UDim.new(0, 12))

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Size = UDim2.new(1, -76, 1, 0)
    label.BackgroundTransparency = 1
    label.RichText = true
    label.Text = text .. (hotkey ~= "" and ('  <font color="#9a9cc0" size="11">' .. hotkey .. "</font>") or "")
    label.TextColor3 = TEXT
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -52, 0.5, -11)
    pill.BackgroundColor3 = Color3.fromRGB(110, 112, 140)
    pill.BackgroundTransparency = 0.4
    pill.BorderSizePixel = 0
    pill.Parent = row
    corner(pill, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    corner(knob, UDim.new(1, 0))

    pressFx(row)
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.82 }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.9 }):Play()
    end)
    row.Activated:Connect(function()
        callback()
        task.defer(function() uiSound(getFn() and "on" or "off") end)
    end)

    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    table.insert(updaters, function()
        local on = getFn()
        TweenService:Create(pill, info, {
            BackgroundColor3 = on and ACCENT or Color3.fromRGB(110, 112, 140),
            BackgroundTransparency = on and 0.05 or 0.4,
        }):Play()
        TweenService:Create(knob, info, {
            Position = on and UDim2.new(0, 20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
    end)
end

local function makeSegment(parent, labels, getIdx, onSelect, isSel)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.LayoutOrder = nextOrder(parent)
    row.Parent = parent

    local n = #labels
    local buttons = {}
    for i = 1, n do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / n, -6, 1, 0)
        b.Position = UDim2.new((i - 1) / n, 3, 0, 0)
        b.AutoButtonColor = false
        b.Text = labels[i]
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 13
        b.TextColor3 = TEXT
        b.Parent = row
        glass(b, 0.9, 0.8)
        corner(b, UDim.new(0, 10))
        pressFx(b)
        b.Activated:Connect(function()
            uiSound("click")
            onSelect(i)
        end)
        buttons[i] = b
    end

    table.insert(updaters, function()
        for i, b in ipairs(buttons) do
            local sel
            if isSel then sel = isSel(i) else sel = (i == getIdx()) end
            b.BackgroundColor3 = sel and ACCENT or Color3.new(1, 1, 1)
            b.BackgroundTransparency = sel and 0.15 or 0.9
        end
    end)
end

local function makeButton(parent, getText, getActive, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1, 1, 1)
    b.LayoutOrder = nextOrder(parent)
    b.Parent = parent
    glass(b, 0.9, 0.7)
    corner(b, UDim.new(0, 12))
    pressFx(b)
    b.Activated:Connect(function()
        uiSound("click")
        callback()
    end)

    table.insert(updaters, function()
        b.Text = getText()
        local on = getActive()
        b.BackgroundColor3 = on and GOOD or ACCENT
        b.BackgroundTransparency = on and 0.25 or 0.35
    end)
end

local function makeInfo(parent)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.TextColor3 = MUTED
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Text = ""
    l.LayoutOrder = nextOrder(parent)
    l.Parent = parent
    return l
end

sectionLabel(combatPage, T("sec_farm"))
makeToggle(combatPage, T("tg_autofarm"), "F4", function() return state.autoFarm end, toggleFarm)
makeToggle(combatPage, "Fast Attack", "F6", function() return state.fastAttack end, toggleFast)
makeToggle(combatPage, T("tg_boss"), "", function() return state.autoBoss end, toggleBoss)
sectionLabel(combatPage, T("sec_mastery"))
makeToggle(combatPage, "Auto Mastery", "", function() return Mastery.active end, Mastery.toggle)
makeSegment(combatPage, Mastery.labels, function() return Mastery.idx end, Mastery.setWeapon)
makeSegment(combatPage, {"400", "500", "600"}, function() return Mastery.targetIdx end, Mastery.setTarget)
local masteryInfo = makeInfo(combatPage)

sectionLabel(combatPage, T("sec_weapon"))
makeSegment(combatPage, {"Melee", "Sword", "Fruit"}, function() return weaponIndex end, setWeapon)
sectionLabel(combatPage, T("sec_farm_height"))
makeSegment(combatPage, {"20", "30", "45", "60"}, function() return farmHeightIndex end, setFarmHeight)

sectionLabel(visualsPage, "ESP")
makeToggle(visualsPage, "ESP Fruits", "F2", function() return state.espFruits end, toggleFruitESP)
makeToggle(visualsPage, "ESP Players", "", function() return state.espPlayers end, togglePlayerESP)

sectionLabel(autoPage, T("sec_ken"))
makeToggle(autoPage, "Auto Observation", "", function() return state.autoKen end, toggleKen)
local kenInfo = makeInfo(autoPage)

sectionLabel(autoPage, T("sec_story"))
makeToggle(autoPage, T("tg_story2"), "", function() return state.autoStory and Story.mode == 2 end, toggleSea2)
makeToggle(autoPage, T("tg_story3"), "", function() return state.autoStory and Story.mode == 3 end, toggleSea3)
local storyInfo = makeInfo(autoPage)

sectionLabel(autoPage, T("sec_raid"))
makeToggle(autoPage, "Auto Raid", "", function() return state.autoRaid end, toggleRaid)
sectionLabel(autoPage, T("sec_raid_type"))
makeSegment(autoPage, {"Flame", "Ice", "Quake", "Light", "Dark", "String"},
    function() return raidIdx end,
    function(i) raidIdx = i; refreshGui() end,
    function(i) return raidIdx == i end)
makeSegment(autoPage, {"Magma", "Buddha", "Sand", "Phoenix", "Dough"},
    function() return raidIdx end,
    function(i) raidIdx = i + 6; refreshGui() end,
    function(i) return raidIdx == i + 6 end)

sectionLabel(autoPage, T("sec_materials"))
makeToggle(autoPage, "Auto Materials", "", function() return state.autoMaterials end, toggleMaterials)
local matInfo = makeInfo(autoPage)
makeButton(autoPage, function() return T("mat_select_all") end, function() return false end, selectAllMaterials)
makeButton(autoPage, function() return T("mat_clear") end, function() return false end, clearMaterials)

sectionLabel(autoPage, T("sec_pick_materials"))
for _, mat in ipairs(MATERIALS) do
    if matInSea(mat) then
        makeToggle(autoPage, mat.name, matSeaTag(mat), function() return matSel[mat.id] == true end, function()
            matSel[mat.id] = not matSel[mat.id] or nil
            refreshGui()
        end)
    end
end

sectionLabel(tpPage, T("sec_tp"))
local tpInfo = makeInfo(tpPage)
makeButton(tpPage,
    function()
        if flying then return T("tp_cancel") end
        if tpSelected then return T("tp_go", tpSelected) end
        return T("tp_pick")
    end,
    function() return flying end,
    flyToIsland)

local tpListFrame
local tpRows = {}
local function rebuildIslandList()
    for _, r in ipairs(tpRows) do pcall(function() r.btn:Destroy() end) end
    tpRows = {}
    tpIslands = scanIslands()

    local stillThere = false
    for _, isl in ipairs(tpIslands) do
        if isl.name == tpSelected then stillThere = true end
    end
    if not stillThere then tpSelected = nil end

    for i, isl in ipairs(tpIslands) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.AutoButtonColor = false
        b.Text = isl.name
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 13
        b.TextColor3 = TEXT
        b.LayoutOrder = i
        b.Parent = tpListFrame
        glass(b, 0.9, 0.8)
        corner(b, UDim.new(0, 10))
        b.Activated:Connect(function()
            tpSelected = isl.name
            refreshGui()
        end)
        tpRows[#tpRows + 1] = { btn = b, name = isl.name }
    end
    refreshGui()
end

makeButton(tpPage, function() return T("tp_refresh") end, function() return false end, function()
    rebuildIslandList()
end)

tpListFrame = Instance.new("Frame")
tpListFrame.Size = UDim2.new(1, 0, 0, 0)
tpListFrame.AutomaticSize = Enum.AutomaticSize.Y
tpListFrame.BackgroundTransparency = 1
tpListFrame.LayoutOrder = nextOrder(tpPage)
tpListFrame.Parent = tpPage

local tpLay = Instance.new("UIListLayout")
tpLay.Padding = UDim.new(0, 6)
tpLay.SortOrder = Enum.SortOrder.LayoutOrder
tpLay.Parent = tpListFrame

table.insert(updaters, function()
    for _, r in ipairs(tpRows) do
        local sel = (r.name == tpSelected)
        r.btn.BackgroundColor3 = sel and ACCENT or Color3.new(1, 1, 1)
        r.btn.BackgroundTransparency = sel and 0.15 or 0.9
    end
end)

rebuildIslandList()
task.delay(4, function()
    if alive then rebuildIslandList() end
end)

local shopInfo = makeInfo(shopPage)
local function shopSection(title, items)
    sectionLabel(shopPage, title)
    for _, item in ipairs(items) do
        makeButton(shopPage,
            function() return T("shop_buy", item.name) end,
            function() return false end,
            function() Shop.buy(item) end)
    end
end
shopSection(T("sec_swords"), Shop.swords)
shopSection(T("sec_styles"), Shop.styles)
shopSection(T("sec_abilities"), Shop.abilities)

sectionLabel(pvpPage, "SILENT AIM")
makeToggle(pvpPage, "Silent Aim", "", function() return PvP.silent end, PvP.toggleSilent)
sectionLabel(pvpPage, T("sec_radius"))
makeSegment(pvpPage, { "100", "200", "300", "500" }, function() return PvP.radiusIdx end, PvP.setRadius)
makeToggle(pvpPage, T("tg_predict"), "", function() return PvP.predict end, PvP.togglePredict)
makeToggle(pvpPage, T("tg_ignore_team"), "", function() return PvP.team end, PvP.toggleTeam)
makeToggle(pvpPage, T("tg_target_hl"), "", function() return PvP.highlight end, PvP.toggleHighlight)
local pvpInfo = makeInfo(pvpPage)
sectionLabel(pvpPage, T("sec_pvp_extra"))
makeToggle(pvpPage, T("tg_auto_buso"), "", function() return PvP.buso end, PvP.toggleBuso)

sectionLabel(miscPage, T("sec_auto"))
makeToggle(miscPage, "Auto Factory Core", "", function() return state.autoFactory end, toggleFactory)
makeToggle(miscPage, T("tg_gacha"), "", function() return state.autoGacha end, toggleGacha)
local gachaInfo = makeInfo(miscPage)
makeToggle(miscPage, "Auto Store Fruit", "", function() return state.autoStore end, toggleStore)
local storeInfo = makeInfo(miscPage)

sectionLabel(miscPage, T("sec_chests"))
makeToggle(miscPage, "Auto Chests", "", function() return state.autoChest end, toggleChest)
makeToggle(miscPage, T("tg_chest_stop"), "", function() return state.chestStop end, toggleChestStop)
local chestInfo = makeInfo(miscPage)

sectionLabel(miscPage, T("sec_stats"))
makeToggle(miscPage, T("tg_split"), "", function() return state.splitStats end, toggleSplit)
makeSegment(miscPage, STAT_LABELS, function() return statIndex end, setStat, function(i)
    if state.splitStats then return splitSel[i] == true end
    return statIndex == i
end)
makeButton(miscPage,
    function() return state.autoStats and T("btn_stop_stats") or T("btn_start_stats") end,
    function() return state.autoStats end,
    toggleStats)
local statsInfo = makeInfo(miscPage)

sectionLabel(miscPage, T("sec_cruise"))
makeSegment(miscPage, {"50", "90", "150"}, function() return cruiseIndex end, setCruiseHeight)
sectionLabel(miscPage, T("sec_speed"))
makeSegment(miscPage, {"90", "130", "170", "220"}, function() return flySpeedIndex end, setFlySpeed)

sectionLabel(miscPage, T("sec_misc"))
makeToggle(miscPage, T("tg_flyfruit"), "F3", function() return flying end, flyToNearestFruit)
makeToggle(miscPage, T("tg_blur"), "", function() return state.blur end, toggleBlur)
makeToggle(miscPage, T("tg_sound"), "", function() return state.sound end, toggleSound)

local statusRow = Instance.new("Frame")
statusRow.Position = UDim2.new(0, CONTENT_X, 1, -14 - 26)
statusRow.Size = UDim2.new(0, CONTENT_W, 0, 26)
statusRow.Parent = main
glass(statusRow, 0.88, 0.75)
corner(statusRow, UDim.new(0, 13))

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 12, 0.5, -4)
dot.BackgroundColor3 = MUTED
dot.BorderSizePixel = 0
dot.Parent = statusRow
corner(dot, UDim.new(1, 0))

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0, 28, 0, 0)
status.Size = UDim2.new(1, -36, 1, 0)
status.BackgroundTransparency = 1
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextTruncate = Enum.TextTruncate.AtEnd
status.TextColor3 = MUTED
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Text = ""
status.Parent = statusRow

refreshGui = function()
    for _, update in ipairs(updaters) do update() end
    dot.BackgroundColor3 = (state.autoFarm or state.autoFactory) and GOOD or MUTED
end

local circle = Instance.new("TextButton")
circle.Size = UDim2.new(0, 52, 0, 52)
circle.Position = main.Position
circle.BackgroundColor3 = Color3.new(1, 1, 1)
circle.BackgroundTransparency = 0.15
circle.BorderSizePixel = 0
circle.Text = "VH"
circle.TextColor3 = Color3.new(1, 1, 1)
circle.Font = Enum.Font.GothamBlack
circle.TextSize = 17
circle.AutoButtonColor = false
circle.Active = true
circle.Visible = false
circle.Parent = gui
corner(circle, UDim.new(1, 0))
brandGradient(circle).Rotation = 45

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.new(1, 1, 1)
circleStroke.Thickness = 1.5
circleStroke.Transparency = 0.5
circleStroke.Parent = circle

local guiShown = true
local function setGuiVisible(v)
    guiShown = v
    if v then
        main.Position = circle.Position
        mainScale.Scale = 0.88
        main.Visible = true
        circle.Visible = false
        TweenService:Create(mainScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1,
        }):Play()
        applyBlur()
    else
        circle.Position = main.Position
        TweenService:Create(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0.9,
        }):Play()
        task.delay(0.18, function()
            if not guiShown then
                main.Visible = false
                circle.Visible = true
                applyBlur()
            end
        end)
    end
end

makeDraggable(circle, circle, function() setGuiVisible(true) end)

local function killAll()
    alive = false
    state.autoFarm, state.fastAttack = false, false
    state.espFruits, state.espPlayers = false, false
    state.autoFactory, state.autoStats, state.autoGacha = false, false, false
    state.autoStore = false
    state.autoMaterials = false
    state.autoRaid = false
    state.autoChest = false
    state.autoStory = false
    state.autoKen = false
    Mastery.active = false
    forcedWeapon = nil
    PvP.silent = false
    PvP.buso = false
    stopFlying()
    stopFarmPhysics()
    clearFruitESP()
    clearPlayerESP()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    pcall(function() blur:Destroy() end)
    gui:Destroy()
    pcall(function() toastGui:Destroy() end)
    notify(T("killed"))
end

windowButton("-", -76, nil, function() setGuiVisible(false) end)
windowButton("X", -40, RED, killAll)

task.spawn(function()
    while alive do
        local lvl = getPlayerLevel()
        lvlLabel.Text = T("lvl_label") .. lvl
        nextLabel.Text = T("next_label") .. nextIslandText(lvl)
        local names = {}
        if state.splitStats then
            for i = 1, #STAT_LABELS do
                if splitSel[i] then names[#names + 1] = STAT_LABELS[i] end
            end
        else
            names[1] = STAT_LABELS[statIndex]
        end
        statsInfo.Text = T("stats_info", getPoints(), table.concat(names, " + "))
        storeInfo.Text = T("storage_info") .. storeStatus
        chestInfo.Text = T("chest_info", Chest.found, Chest.collected)
        storyInfo.Text = T("story_info", Story.status)
        kenInfo.Text = T("ken_info", Ken.status)
        masteryInfo.Text = T("mastery_info", Mastery.status)
        pvpInfo.Text = PvP.status
        shopInfo.Text = T("shop_info", Shop.status)
        local selCount = 0
        for _ in pairs(matSel) do selCount = selCount + 1 end
        local sea = currentSea()
        matInfo.Text = T("mat_info", selCount, sea and ("Sea " .. sea) or "?")
        if #tpIslands > 0 then
            tpInfo.Text = T("tp_info", sea and ("Sea " .. sea) or "?", #tpIslands)
        else
            tpInfo.Text = T("tp_empty")
        end
        local gtxt = T("gacha_info") .. gachaStatus
        if state.autoGacha and gachaNext and gachaNext > os.clock() then
            local left = math.floor(gachaNext - os.clock())
            gtxt = gtxt .. T("gacha_next", string.format("%d:%02d:%02d",
                math.floor(left / 3600), math.floor((left % 3600) / 60), left % 60))
        end
        gachaInfo.Text = gtxt
        status.Text = statusText
        task.wait(0.5)
    end
end)

task.spawn(function()
    while alive do
        if state.espFruits then updateFruitESP() end
        task.wait(2)
    end
end)

task.spawn(function()
    while alive do
        if state.espPlayers then pcall(updatePlayerESP) end
        task.wait(0.5)
    end
end)

track(UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local k = input.KeyCode

    if k == Enum.KeyCode.F2 then toggleFruitESP()
    elseif k == Enum.KeyCode.F3 then flyToNearestFruit()
    elseif k == Enum.KeyCode.F4 then toggleFarm()
    elseif k == Enum.KeyCode.F5 then setWeapon(weaponIndex % #WEAPONS + 1)
    elseif k == Enum.KeyCode.F6 then toggleFast()
    elseif k == Enum.KeyCode.RightShift then setGuiVisible(not main.Visible)
    end
end))

setTab("Combat")
applyBlur()
notify(T("loaded"))

end

buildGui()
