-- config.lua
-- Configuration and constants for ModernAutoFish

local Config = {}

-- Main Configuration
Config.Settings = {
    mode = "smart",  -- Default to smart mode
    autoRecastDelay = 0.4,
    safeModeChance = 70,
    secure_max_actions_per_minute = 12000000,
    secure_detection_cooldown = 5,
    enabled = false,
    antiAfkEnabled = false,
    enhancementEnabled = false,
    autoReconnectEnabled = false,
    autoModeEnabled = false
}

-- Fish Rarity Categories
Config.FishRarity = {
    MYTHIC = {
        "Hawks Turtle", "Dotted Stingray", "Hammerhead Shark", "Manta Ray", 
        "Abyss Seahorse", "Blueflame Ray", "Prismy Seahorse", "Loggerhead Turtle"
    },
    LEGENDARY = {
        "Blue Lobster", "Greenbee Grouper", "Starjam Tang", "Yellowfin Tuna",
        "Chrome Tuna", "Magic Tang", "Enchanted Angelfish", "Lavafin Tuna", 
        "Lobster", "Bumblebee Grouper"
    },
    EPIC = {
        "Domino Damsel", "Panther Grouper", "Unicorn Tang", "Dorhey Tang",
        "Moorish Idol", "Cow Clownfish", "Astra Damsel", "Firecoal Damsel",
        "Longnose Butterfly", "Sushi Cardinal"
    },
    RARE = {
        "Scissortail Dartfish", "White Clownfish", "Darwin Clownfish", 
        "Korean Angelfish", "Candy Butterfly", "Jewel Tang", "Charmed Tang",
        "Kau Cardinal", "Fire Goby"
    },
    UNCOMMON = {
        "Maze Angelfish", "Tricolore Butterfly", "Flame Angelfish", 
        "Yello Damselfish", "Vintage Damsel", "Coal Tang", "Magma Goby",
        "Banded Butterfly", "Shrimp Goby"
    },
    COMMON = {
        "Orangy Goby", "Specked Butterfly", "Corazon Damse", "Copperband Butterfly",
        "Strawberry Dotty", "Azure Damsel", "Clownfish", "Skunk Tilefish",
        "Yellowstate Angelfish", "Vintage Blue Tang", "Ash Basslet", 
        "Volcanic Basslet", "Boa Angelfish", "Jennifer Dottyback", "Reef Chromis"
    }
}

-- Location mapping for heatmap
Config.LocationMap = {
    ["Kohana Volcano"] = {x = -594, z = 149},
    ["Crater Island"] = {x = 1010, z = 5078},
    ["Kohana"] = {x = -650, z = 711},
    ["Lost Isle"] = {x = -3618, z = -1317},
    ["Stingray Shores"] = {x = 45, z = 2987},
    ["Esoteric Depths"] = {x = 1944, z = 1371},
    ["Weather Machine"] = {x = -1488, z = 1876},
    ["Tropical Grove"] = {x = -2095, z = 3718},
    ["Coral Reefs"] = {x = -3023, z = 2195}
}

-- Island locations for teleport
Config.IslandLocations = {
    ["🏝️Kohana Volcano"] = CFrame.new(-594.971252, 396.65213, 149.10907),
    ["🏝️Crater Island"] = CFrame.new(1010.01001, 252, 5078.45117),
    ["🏝️Kohana"] = CFrame.new(-650.971191, 208.693695, 711.10907),
    ["🏝️Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
    ["🏝️Stingray Shores"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
    ["🏝️Esoteric Depths"] = CFrame.new(1944.77881, 393.562927, 1371.35913),
    ["🏝️Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["🏝️Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
    ["🏝️Coral Reefs"] = CFrame.new(-3023.97119, 337.812927, 2195.60913),
    ["🦈 TREASURE"] = CFrame.new(-3599.90, -275.96, -1640.84),
    ["🎣 STRINGRY"] = CFrame.new(102.05, 29.64, 3054.35),
    ["❄️ ICE LAND"] = CFrame.new(1990.55, 3.09, 3021.91),
    ["🌋 CRATER"] = CFrame.new(990.45, 21.06, 5059.85),
    ["🌴 TROPICAL"] = CFrame.new(-2093.80, 6.26, 3654.30),
    ["🗿 STONE"] = CFrame.new(-2636.19, 124.87, -27.49),
    ["🎲 ENCHANT STONE"] = CFrame.new(3237.61, -1302.33, 1398.04),
    ["⚙️ MACHINE"] = CFrame.new(-1551.25, 2.87, 1920.26)
}

-- Weather types
Config.WeatherTypes = {
    "All", "Rain", "Storm", "Sunny", "Cloudy", "Fog", "Wind"
}

-- UI Theme Colors
Config.Colors = {
    Background = Color3.fromRGB(28,28,34),
    Panel = Color3.fromRGB(35,35,42),
    Button = Color3.fromRGB(60,120,180),
    ButtonHover = Color3.fromRGB(80,140,200),
    Text = Color3.fromRGB(235,235,235),
    TextSecondary = Color3.fromRGB(200,200,200),
    Success = Color3.fromRGB(100,200,100),
    Warning = Color3.fromRGB(255,200,100),
    Error = Color3.fromRGB(200,100,100),
    Accent = Color3.fromRGB(100,200,255)
}

return Config
