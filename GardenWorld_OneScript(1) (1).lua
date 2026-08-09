--==============================================================
-- 🌿 GARDEN WORLD - ONE SCRIPT
-- Roblox Studio : place this Script in ServerScriptService
--==============================================================

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")

local SAVE = DataStoreService:GetDataStore("GardenWorld_OneScript_V1")
local START_MONEY = 500
local MAX_PLOTS = 8

--========================
-- CROPS
--========================
local Crops = {
	Carrot={r="Common",buy=10,sell=18,grow=45,stock=40,color=Color3.fromRGB(255,125,45)},
	Lettuce={r="Common",buy=14,sell=24,grow=55,stock=36,color=Color3.fromRGB(100,200,90)},
	Potato={r="Common",buy=16,sell=28,grow=60,stock=34,color=Color3.fromRGB(180,145,95)},
	Tomato={r="Common",buy=20,sell=34,grow=70,stock=30,color=Color3.fromRGB(220,55,45)},
	Onion={r="Common",buy=22,sell=38,grow=75,stock=28,color=Color3.fromRGB(220,180,180)},
	Corn={r="Uncommon",buy=35,sell=62,grow=100,stock=20,color=Color3.fromRGB(255,220,70)},
	Cucumber={r="Uncommon",buy=42,sell=75,grow=115,stock=18,color=Color3.fromRGB(65,165,75)},
	BellPepper={r="Uncommon",buy=50,sell=90,grow=125,stock=16,color=Color3.fromRGB(70,190,80)},
	Wheat={r="Uncommon",buy=60,sell=110,grow=140,stock=15,color=Color3.fromRGB(220,185,65)},
	Strawberry={r="Rare",buy=80,sell=145,grow=160,stock=10,color=Color3.fromRGB(235,50,105)},
	Blueberry={r="Rare",buy=105,sell=190,grow=190,stock=9,color=Color3.fromRGB(65,90,225)},
	Pumpkin={r="Rare",buy=140,sell=250,grow=230,stock=7,color=Color3.fromRGB(255,120,35)},
	Watermelon={r="Rare",buy=180,sell=330,grow=260,stock=6,color=Color3.fromRGB(50,180,85)},
	Lavender={r="Epic",buy=300,sell=560,grow=360,stock=4,color=Color3.fromRGB(150,90,210)},
	CrystalFlower={r="Epic",buy=500,sell=950,grow=500,stock=3,color=Color3.fromRGB(100,220,255)},
	GoldenApple={r="Legendary",buy=1200,sell=2700,grow=900,stock=1,color=Color3.fromRGB(255,205,45)},
	MoonFlower={r="Mythic",buy=3000,sell=7200,grow=1500,stock=1,color=Color3.fromRGB(120,120,255)},
}

local rarityFactor={Common=1,Uncommon=.7,Rare=.45,Epic=.25,Legendary=.12,Mythic=.08}

--========================
-- 17 EVENTS
--========================
local Events = {
	{"☀️ Sunny Morning",240,1,1,"Sunny",0,1},
	{"🌧️ Spring Rain",180,2,1,"Rain",0,1.05},
	{"💰 Market Boom",180,1,2,"Sunny",0,1.1},
	{"🌅 Golden Hour",150,1.5,1.5,"Golden",0,.9},
	{"🌙 Moonlight Garden",180,1.25,1.75,"Moon",0,.8},
	{"🌸 Flower Festival",180,1.75,1.25,"Flower",0,1.15},
	{"🍂 Autumn Harvest",180,1.5,1.5,"Autumn",0,.95},
	{"☀️ Summer Heat",150,1.25,1.25,"Sunny",0,1.08},
	{"❄️ Frosty Night",150,.75,2.5,"Frost",0,.75},
	{"☄️ Meteor Shower",120,2,2,"Stars",0,1.25},
	{"🦋 Butterfly Bloom",180,1.8,1.3,"Flower",0,1.18},
	{"🌬️ Windy Fields",150,1.3,1.4,"Wind",0,.92},
	{"⛈️ Thunderstorm",120,2.2,1.2,"Storm",0,.7},
	{"🌫️ Mystic Fog",150,1.6,1.8,"Fog",0,.82},
	{"🌈 Rainbow Rain",180,2,1.8,"Rainbow",0,1.22},
	{"🎪 Harvest Carnival",210,1.7,2.2,"Carnival",0,1.3},
	{"⭐ Starlight Festival",180,2.5,2.5,"Stars",0,1.35},
}

-- Put your own permitted Roblox audio IDs in the 6th value above.
-- Example: {"☀️ Sunny Morning",240,1,1,"Sunny",123456789,1}

local data={}
local plotOf={}
local ownerOf={}
local plots={}
local world=workspace:FindFirstChild("GardenWorld")

if world then world:Destroy() end
world=Instance.new("Folder")
world.Name="GardenWorld"
world.Parent=workspace

local plantsFolder=Instance.new("Folder")
plantsFolder.Name="Plants"
plantsFolder.Parent=world

local eventIndex=1
local eventStarted=os.time()
local stockRotation=math.floor(os.time()/180)

--========================
-- BUILD HELPERS
--========================
local function part(parent,name,size,pos,color,material)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.Position=pos
	p.Anchored=true
	p.Color=color
	p.Material=material or Enum.Material.SmoothPlastic
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function label(parent,text)
	local gui=Instance.new("BillboardGui")
	gui.Size=UDim2.fromOffset(260,55)
	gui.StudsOffset=Vector3.new(0,5,0)
	gui.AlwaysOnTop=true
	gui.Parent=parent
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundTransparency=1
	t.Text=text
	t.TextScaled=true
	t.Font=Enum.Font.GothamBold
	t.TextColor3=Color3.new(1,1,1)
	t.TextStrokeTransparency=.3
	t.Parent=gui
end

local function prompt(p,action,object)
	local x=Instance.new("ProximityPrompt")
	x.ActionText=action
	x.ObjectText=object
	x.HoldDuration=.2
	x.MaxActivationDistance=12
	x.RequiresLineOfSight=false
	x.Parent=p
	return x
end

local function message(player,text)
	local gui=player:FindFirstChildOfClass("PlayerGui")
	if not gui then return end
	local old=gui:FindFirstChild("GardenMessage")
	if old then old:Destroy() end
	local s=Instance.new("ScreenGui")
	s.Name="GardenMessage"
	s.ResetOnSpawn=false
	s.Parent=gui
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromOffset(600,55)
	t.Position=UDim2.new(.5,-300,0,80)
	t.BackgroundColor3=Color3.fromRGB(25,30,35)
	t.TextColor3=Color3.new(1,1,1)
	t.TextScaled=true
	t.Font=Enum.Font.GothamBold
	t.Text=text
	t.Parent=s
	task.delay(3,function() if s then s:Destroy() end end)
end

--========================
-- MAP
--========================
part(world,"Grass",Vector3.new(300,1,250),Vector3.new(0,-.5,0),Color3.fromRGB(80,145,70),Enum.Material.Grass)
part(world,"RoadX",Vector3.new(300,.2,20),Vector3.new(0,.1,0),Color3.fromRGB(65,65,65),Enum.Material.Asphalt)
part(world,"RoadZ",Vector3.new(20,.2,250),Vector3.new(0,.11,0),Color3.fromRGB(65,65,65),Enum.Material.Asphalt)

Lighting.ClockTime=14
Lighting.Brightness=2
Lighting.GlobalShadows=true

-- Trees
for i=1,40 do
	local x=((i*47)%270)-135
	local z=((i*83)%220)-110
	if math.abs(x)>30 or math.abs(z)>15 then
		part(world,"TreeTrunk",Vector3.new(1.5,6,1.5),Vector3.new(x,3,z),Color3.fromRGB(105,70,40),Enum.Material.Wood)
		local crown=part(world,"TreeCrown",Vector3.new(6,6,6),Vector3.new(x,7,z),Color3.fromRGB(45,135,60),Enum.Material.Grass)
		crown.Shape=Enum.PartType.Ball
	end
end

-- Shops
local function shop(name,pos,color,text)
	local m=Instance.new("Model")
	m.Name=name
	m.Parent=world
	local b=part(m,"Building",Vector3.new(30,12,20),pos,color,Enum.Material.Brick)
	part(m,"Roof",Vector3.new(32,1,22),pos+Vector3.new(0,7,0),color)
	part(m,"Door",Vector3.new(5,8,.5),pos+Vector3.new(0,-2,10.3),Color3.fromRGB(50,40,30),Enum.Material.Wood)
	label(b,text)
	return m,b
end

local seedShop,seedBuilding=shop("SeedShop",Vector3.new(-55,5,-78),Color3.fromRGB(65,155,90),"🌱 SEED SHOP")
local sellShop,sellBuilding=shop("SellMarket",Vector3.new(55,5,-78),Color3.fromRGB(210,150,60),"🛒 SELL MARKET")
local wheelShop,wheelBuilding=shop("LuckyWheel",Vector3.new(0,5,82),Color3.fromRGB(150,85,200),"🎡 LUCKY WHEEL")

--========================
-- PLOTS
--========================
for row=1,2 do
	for col=1,4 do
		local id=(row-1)*4+col
		local x=(col-2.5)*55
		local z=(row==1 and -25 or 30)

		local m=Instance.new("Model")
		m.Name="Plot"..id
		m.Parent=world

		local soil=part(m,"Soil",Vector3.new(44,1,44),Vector3.new(x,0,z),Color3.fromRGB(105,70,42),Enum.Material.Ground)
		plots[id]=m
		m:SetAttribute("OwnerUserId",0)

		part(m,"FenceN",Vector3.new(44,2,.5),Vector3.new(x,1,z-22),Color3.fromRGB(116,82,48),Enum.Material.Wood)
		part(m,"FenceS",Vector3.new(44,2,.5),Vector3.new(x,1,z+22),Color3.fromRGB(116,82,48),Enum.Material.Wood)
		part(m,"FenceW",Vector3.new(.5,2,44),Vector3.new(x-22,1,z),Color3.fromRGB(116,82,48),Enum.Material.Wood)
		part(m,"FenceE",Vector3.new(.5,2,44),Vector3.new(x+22,1,z),Color3.fromRGB(116,82,48),Enum.Material.Wood)

		local s=part(m,"Sign",Vector3.new(7,3,.5),Vector3.new(x,3,z-20),Color3.fromRGB(60,45,32),Enum.Material.Wood)
		label(s,"GARDEN "..id)
	end
end

--========================
-- DATA
--========================
local function newData()
	return {
		Money=START_MONEY,
		Seeds={Carrot=3},
		Harvests={},
		Crops={},
		Upgrades={Growth=0,Capacity=0,Soil=0},
		LastLogout=os.time()
	}
end

local function load(player)
	local ok,result=pcall(function()
		return SAVE:GetAsync("P_"..player.UserId)
	end)
	if ok and type(result)=="table" then
		result.Seeds=result.Seeds or {}
		result.Harvests=result.Harvests or {}
		result.Crops=result.Crops or {}
		result.Upgrades=result.Upgrades or {Growth=0,Capacity=0,Soil=0}
		result.Money=result.Money or START_MONEY
		return result
	end
	return newData()
end

local function save(player)
	if not data[player] then return end
	data[player].LastLogout=os.time()
	pcall(function()
		SAVE:SetAsync("P_"..player.UserId,data[player])
	end)
end

local function growthMultiplier(d)
	return Events[eventIndex][3]*(1+.08*(d.Upgrades.Growth or 0))
end

local function sellMultiplier(d)
	return Events[eventIndex][4]*(1+.05*(d.Upgrades.Soil or 0))
end

local function capacity(d)
	return 6+(d.Upgrades.Capacity or 0)*2
end

local function ready(d,crop)
	local cfg=Crops[crop.Name]
	return cfg and os.time()-crop.PlantedAt >= cfg.grow/growthMultiplier(d)
end

--========================
-- PLANT VISUALS
--========================
local function clearPlants(player)
	local prefix=tostring(player.UserId).."_"
	for _,x in ipairs(plantsFolder:GetChildren()) do
		if x.Name:sub(1,#prefix)==prefix then x:Destroy() end
	end
end

local function createPlant(player,index,cropName)
	local d=data[player]
	local cfg=Crops[cropName]
	local plot=plots[plotOf[player]]
	if not d or not cfg or not plot then return end

	local soil=plot.Soil
	local row=math.floor((index-1)/4)
	local col=(index-1)%4
	local pos=soil.Position+Vector3.new(-15+col*10,1.2,-15+row*10)

	local model=Instance.new("Model")
	model.Name=player.UserId.."_"..index
	model.Parent=plantsFolder

	local stem=part(model,"Stem",Vector3.new(.55,2,.55),pos,Color3.fromRGB(55,145,65),Enum.Material.Grass)
	local fruit=part(model,"Fruit",Vector3.new(2,2,2),pos+Vector3.new(0,1.4,0),cfg.color)
	fruit.Shape=Enum.PartType.Ball
	model.PrimaryPart=stem

	local isReady=ready(d,d.Crops[index])
	model:ScaleTo(isReady and 1.5 or .65)

	if isReady then
		label(fruit,"READY • "..cropName)
		local p=prompt(fruit,"Récolter",cropName)
		p.Triggered:Connect(function(plr)
			if plr~=player then return end
			local latest=data[player]
			local crop=latest and latest.Crops[index]
			if not crop or not ready(latest,crop) then return end

			latest.Harvests[crop.Name]=(latest.Harvests[crop.Name] or 0)+1
			table.remove(latest.Crops,index)

			clearPlants(player)
			for i,c in ipairs(latest.Crops) do createPlant(player,i,c.Name) end
			message(player,"🌾 Récolté : "..crop.Name)
		end)
	end
end

local function redraw(player)
	clearPlants(player)
	for i,crop in ipairs(data[player].Crops) do
		createPlant(player,i,crop.Name)
	end
end

--========================
-- PLAYER MENU
-- One server Script can create UI, but button input needs a LocalScript.
-- Therefore this one-script edition uses ProximityPrompts for gameplay.
-- A compact command system is also included below.
--========================

local function buySeed(player,name)
	local d=data[player]
	local cfg=Crops[name]
	if not d or not cfg then return end

	if d.Money<cfg.buy then
		message(player,"💰 Pas assez d'argent.")
		return
	end

	local maxStock=math.max(1,math.floor(cfg.stock*(rarityFactor[cfg.r] or .5)))
	local bought=d.Seeds[name] or 0

	if bought>=maxStock then
		message(player,"📦 Stock limité : "..name.." est épuisé.")
		return
	end

	d.Money-=cfg.buy
	d.Seeds[name]=bought+1
	message(player,"🌱 Graine achetée : "..name)
end

local function plantSeed(player,name)
	local d=data[player]
	if not d then return end
	if #d.Crops>=capacity(d) then
		message(player,"🌿 Jardin plein.")
		return
	end
	if (d.Seeds[name] or 0)<1 then
		message(player,"🌱 Tu n'as pas de "..name..".")
		return
	end

	d.Seeds[name]-=1
	table.insert(d.Crops,{Name=name,PlantedAt=os.time()})
	redraw(player)
	message(player,"🌱 "..name.." plantée.")
end

local function sellAll(player)
	local d=data[player]
	if not d then return end

	local total=0
	local count=0

	for name,amount in pairs(d.Harvests) do
		local cfg=Crops[name]
		if cfg and amount>0 then
			total+=cfg.sell*amount
			count+=amount
			d.Harvests[name]=0
		end
	end

	total=math.floor(total*sellMultiplier(d))
	d.Money+=total
	message(player,("🛒 %d récoltes vendues : $%d"):format(count,total))
end

local function wheel(player)
	local d=data[player]
	if not d then return end

	local prizes={
		{"50 coins",50,nil,35},
		{"100 coins",100,nil,25},
		{"250 coins",250,nil,18},
		{"500 coins",500,nil,10},
		{"Strawberry",0,"Strawberry",7},
		{"Lavender",0,"Lavender",4},
		{"Golden Apple",0,"GoldenApple",1},
	}

	local total=0
	for _,p in ipairs(prizes) do total+=p[4] end

	local r=math.random()*total
	for _,p in ipairs(prizes) do
		r-=p[4]
		if r<=0 then
			if p[3] then
				d.Seeds[p[3]]=(d.Seeds[p[3]] or 0)+1
			else
				d.Money+=p[2]
			end
			message(player,"🎡 Roue : "..p[1])
			return
		end
	end
end

local function upgrade(player,name)
	local d=data[player]
	if not d then return end

	local bases={Growth=250,Capacity=300,Soil=400}
	local max=10
	local level=d.Upgrades[name] or 0

	if level>=max then
		message(player,"⬆️ Niveau maximum.")
		return
	end

	local cost=bases[name]*(level+1)
	if d.Money<cost then
		message(player,"💰 Il faut $"..cost)
		return
	end

	d.Money-=cost
	d.Upgrades[name]=level+1
	message(player,"⬆️ "..name.." niveau "..level+1)
end

--========================
-- SHOP PROMPTS
--========================
prompt(seedBuilding,"Acheter","Graines").Triggered:Connect(function(player)
	message(player,"🌱 Pour acheter : utilise le chat avec !buy NomDePlante")
end)

prompt(sellBuilding,"Vendre","Récoltes").Triggered:Connect(function(player)
	sellAll(player)
end)

prompt(wheelBuilding,"Tourner","Roue").Triggered:Connect(function(player)
	wheel(player)
end)

--========================
-- CHAT COMMANDS
--========================
local function lower(s)
	return string.lower(s or "")
end

local function words(text)
	local t={}
	for w in string.gmatch(text,"%S+") do table.insert(t,w) end
	return t
end

local function command(player,text)
	local a=words(text)
	local cmd=lower(a[1])

	if cmd=="!help" then
		message(player,"🌿 !buy Carrot | !plant Carrot | !sell | !wheel | !upgrade Growth")
	elseif cmd=="!sell" then
		sellAll(player)
	elseif cmd=="!wheel" then
		wheel(player)
	elseif cmd=="!buy" and a[2] then
		local wanted=a[2]
		for name in pairs(Crops) do
			if lower(name)==lower(wanted) then
				buySeed(player,name)
				return
			end
		end
		message(player,"❌ Graine inconnue.")
	elseif cmd=="!plant" and a[2] then
		for name in pairs(Crops) do
			if lower(name)==lower(a[2]) then
				plantSeed(player,name)
				return
			end
		end
		message(player,"❌ Plante inconnue.")
	elseif cmd=="!upgrade" and a[2] then
		local n=a[2]
		n=n:sub(1,1):upper()..n:sub(2):lower()
		if n=="Growth" or n=="Capacity" or n=="Soil" then upgrade(player,n) end
	end
end

local function connectChat(player)
	player.Chatted:Connect(function(text)
		if text:sub(1,1)=="!" then command(player,text) end
	end)
end

--========================
-- PLOTS / PLAYERS
--========================
local function claim(player)
	for i=1,MAX_PLOTS do
		if not ownerOf[i] then
			ownerOf[i]=player
			plotOf[player]=i
			plots[i]:SetAttribute("OwnerUserId",player.UserId)

			local sign=plots[i]:FindFirstChild("Sign")
			if sign then
				for _,g in ipairs(sign:GetChildren()) do
					if g:IsA("BillboardGui") then
						for _,t in ipairs(g:GetChildren()) do
							if t:IsA("TextLabel") then
								t.Text=player.DisplayName.."'s GARDEN"
							end
						end
					end
				end
			end

			return i
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	data[player]=load(player)

	-- Offline growth is automatic because crops use absolute timestamps.
	claim(player)
	redraw(player)
	connectChat(player)

	player.CharacterAdded:Connect(function()
		task.wait(2)
		message(player,"🌿 Bienvenue ! Tape !help dans le chat.")
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	save(player)
	clearPlants(player)

	local id=plotOf[player]
	if id then ownerOf[id]=nil end
	plotOf[player]=nil
	data[player]=nil
end)

--========================
-- EVENT LOOP
--========================
task.spawn(function()
	while true do
		task.wait(10)

		if os.time()-eventStarted>=Events[eventIndex][2] then
			eventIndex=eventIndex%#Events+1
			eventStarted=os.time()

			local e=Events[eventIndex]
			if e[5]=="Moon" or e[5]=="Stars" then
				Lighting.ClockTime=0
			elseif e[5]=="Golden" then
				Lighting.ClockTime=17
			else
				Lighting.ClockTime=14
			end

			Lighting.Brightness=(e[5]=="Fog") and 1 or 2

			for player in pairs(data) do
				message(player,"✨ EVENT : "..e[1])
				redraw(player)
			end
		end

		local rotation=math.floor(os.time()/180)
		if rotation~=stockRotation then
			stockRotation=rotation
			for player in pairs(data) do
				message(player,"📦 Le stock des graines est renouvelé !")
			end
		end

		for player in pairs(data) do
			-- Refresh ready plants so their size/prompt changes.
			redraw(player)
		end
	end
end)

game:BindToClose(function()
	for player in pairs(data) do
		save(player)
	end
end)

print("🌿 GARDEN WORLD ONE-SCRIPT chargé !")
