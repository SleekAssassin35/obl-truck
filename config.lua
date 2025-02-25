Config              = {}

Config.SQLScript    = "oxmysql" -- Kullanılacak SQL veritabanı scripti: oxmysql, ghmattimysql veya mysql-async seçeneklerinden biri

Config.Npc          = { -- NPC ayarları (görev başlatma noktası)
    {
        pos            = vector3(995.51, -2905.55, 4.9), -- NPC'nin haritadaki konumu (x, y, z koordinatları)
        heading        = 173.25, -- NPC'nin baktığı yön (derece cinsinden)
        model          = "a_m_m_farmer_01", -- NPC'nin karakter modeli (örneğin, çiftçi modeli)
        blipSprite     = 477, -- Haritada görünecek blip simgesi (477 = kamyon simgesi)
        blipColor      = 0, -- Blip'in rengi (0 = beyaz)
        blipText       = "Nakliyat", -- Blip üzerindeki yazı (görev adı)
        blipShortRange = true, -- Blip sadece yakına gelince mi görünsün? (true = evet)
        blipSize      = 0.8, -- Blip'in boyutu (1.0 normal boyut, 0.8 biraz daha küçük)
    }
}

Config.trucks       = { -- Kamyon ayarları
    -- Eğer tek kamyon kullanmak isterseniz diğerlerini yorum satırına alın, daha fazla eklemek isterseniz modele ekleme yapın
    model = { -- Kullanılabilir kamyon modelleri
        'phantom', -- Büyük tır modeli
        'phantom3', -- Phantom'un başka bir versiyonu
        'packer', -- Düz kamyon modeli
        'hauler', -- Çekici kamyon modeli
    },
    truckPos = vector4(977.07, -2927.02, 4.9, 84.14) -- Kamyonun spawn konumu ve yönü (x, y, z, h - heading)
}

Config.TrailerPos   = vector4(980.36, -2913.64, 4.9, 86.91) -- Römorkun spawn konumu ve yönü (x, y, z, h - heading)

Config.Trailers     = { -- Römork ayarları
    {
        model = {model ='docktrailer', title = "Liman Römorku"}, -- Römork modeli ve görünen adı
        type = { "none", "highValue", "fragile", "rare" }, -- Taşınabilecek yük türleri: normal, değerli, kırılacak, nadir
    },
    {
        model = {model='tr4', title="TR4"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trailers', title = "Römorklar"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trailers2', title = "Römorklar2"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trailers3', title = "Römorklar3"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trailers4', title = "Römorklar4"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trailerlogs', title = "Kütük Römorku"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='tanker', title = "Tanker"},
        type = { "tanker", "highValue", "rare" }, -- Tanker türü yükler için
    },
    {
        model = {model ='tanker2', title = "Tanker2"},
        type = { "tanker", "highValue", "rare" },
    },
    {
        model = {model ='armytanker', title = "Ordu Tankeri"},
        type = { "tanker", "highValue", "military", "rare" }, -- Askeri yükler için
    },
    {
        model = {model ='tr2', title = "TR2"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='tr3', title = "TR3"},
        type = { "highValue", "fragile", "rare" },
    },
    {
        model = {model ='trflat', title = "Düz TR"},
        type = { "none", "rare" },
    },
    {
        model = {model ='tvtrailer', title = "TV Römorku"},
        type = { "none", "highValue", "fragile", "rare" },
    },
    {
        model = {model ='armytrailer2', title = "Ordu Römorku 2"},
        type = { "highValue", "fragile", "rare", "military" },
    },
    {
        model = {model ='freighttrailer', title = "Yük Römorku"},
        type = { "none", "highValue", "military", "rare" },
    },
}

Config.Destinations = { -- Teslimat noktaları (hepsi vector3 formatında)
    -- Daha fazla yer eklemek isterseniz buraya vector3 ekleyin
    -- Yakın mesafeler
    vector3(794.62, -2503.07, 21.49), -- Teslimat noktası koordinatları (x, y, z)
    vector3(837.28, -1932.01, 28.97),
    vector3(505.26, -2170.98, 5.94),
    vector3(840.56, -2338.88, 30.33),
    vector3(1080.21, -1968.84, 31.01),
    vector3(1373.48, -2076.1, 51.99),
    vector3(1206.89, -1268.08, 35.23),

    -- Orta mesafeler
    vector3(2552.56, 418.81, 108.46),
    vector3(-693.42, -2455.46, 13.86),
    vector3(975.1, 3.44, 81.04),
    vector3(-409.95, 1174.72, 325.64),
    vector3(195.3, 1244.39, 225.46),
    vector3(-1818.81, 809.12, 138.67),
    vector3(-1032.55, -2217.31, 8.98),
    vector3(-573.49, -1785.96, 22.58),
    vector3(111.34, -1567.28, 29.6),
    vector3(-183.78, -1036.16, 27.18),
    vector3(-99.14, -1017.28, 27.28),
    vector3(-477.82, -950.19, 23.93),

    -- Uzak mesafeler
    vector3(-2066.8, -306.5, 13.14),
    vector3(1205.74, 2640.51, 37.82),
    vector3(1967.0, 3834.66, 32.0),
    vector3(2673.03, 3514.46, 52.71),
    vector3(2932.48, 4305.73, 50.83),
    vector3(1701.89, 4943.56, 42.1),
    vector3(1714.59, 4801.79, 41.74),
    vector3(1717.95, 6420.36, 33.32),
    vector3(182.3, 6631.64, 31.58),
    vector3(53.39, 6546.81, 30.87),
    vector3(7.21, 6274.99, 31.24),
    vector3(-573.38, 5370.22, 70.23),
    vector3(1214.78, 1874.33, 78.83),
    vector3(-3173.86, 1102.05, 20.82),
    vector3(-2531.77, 2343.78, 33.06),
    vector3(1269.61, 1904.01, 79.7),
    vector3(757.26, 2531.78, 73.14),
    vector3(586.52, 2788.35, 42.19),
    vector3(1857.77, 2541.62, 45.67),
    vector3(1767.54, 3307.87, 41.16),
    vector3(1981.8, 3783.07, 32.18),
    vector3(2688.34, 3455.82, 55.78),
    vector3(3478.78, 3669.16, 33.89),
    vector3(79.93, 6366.98, 31.23),
    vector3(-468.46, 6038.97, 31.34),
    vector3(-674.8, 5787.17, 17.33),
    vector3(-570.61, 5252.79, 70.47),
    --
    vector3(918.51, -1946.3, 30.55),
    vector3(179.38, -1544.66, 28.58),
    vector3(298.55, -1245.9, 29.29),
    vector3(461.82, -1230.34, 30.02),
    vector3(1449.85, -1690.97, 65.83),
    vector3(1082.95, -2264.08, 30.24),
    vector3(348.52, 350.88, 104.42),
    vector3(-356.59, 6081.35, 31.47),
    vector3(1443.68, 6577.68, 13.62),
    vector3(2897.75, 4381.97, 50.38),
    vector3(2753.36, 1645.11, 24.59),
    --
}

Config.CompanySettings = { -- Şirket ayarları
    CompanyRegisterCost = 50000, -- Şirket kurma maliyeti (ücretsiz yapmak için 0 yapın)
    Payment      = { -- Ödeme ayarları
        distanceMultiplier = 1, -- Mesafeye bağlı gelir çarpanı (mesafe * bu sayı = ek gelir)
        basePayment = 500, -- Temel ödeme miktarı (her görevde sabit kazanç)
        deposit = 250, -- Kamyonu kullanmak için ödenen depozito (kullanılmasın istiyorsanız 0 yapın)
    },
    Exp          = { -- Deneyim (XP) ayarları
        distanceExp = 0.05, -- Mesafeye bağlı kazanılan deneyim (mesafe * bu sayı = XP)
        baseExp = 100, -- Temel deneyim (her görevde sabit XP)
        typeExp = { -- Yük türüne göre kazanılan ek deneyim
            none = 10, -- Normal yük
            highValue = 100, -- Değerli yük
            fragile = 75, -- Kırılacak yük
            rare = 175, -- Nadir yük
            tanker = 225, -- Tanker yükü
            military = 250, -- Askeri yük
        },
        lvlUpLimit = 1000 -- Seviye atlamak için gereken deneyim miktarı
    },
    Garage = { -- Garaj ayarları
        UpgradeGarageCost = 5000, -- Garaj yükseltme maliyeti
        GarageCapacity = 1, -- Garaj seviyesi başına kapasite (örneğin, seviye 1 = 1 araç)
    },
    Employee = { -- Çalışan ayarları
        levelPerMoney = 500, -- Çalışan seviyesine bağlı gelir: seviye * 500 = min gelir, min * 2 = max gelir
        salary = 100, -- Çalışan seviyesine bağlı maaş: seviye * 100 = maaş (maaş olmasın istiyorsanız 0 yapın)
        employeeIncomeTimeout = 2700, -- Çalışan gelir zaman aşımı (saniye): 60 = 1 dk, 2700 = 45 dk, 3600 = 1 saat
        employeeSalaryTimeout = 2700, -- Çalışan maaş zaman aşımı (saniye): 60 = 1 dk, 2700 = 45 dk, 3600 = 1 saat
        names = { -- Çalışan isim havuzu (rastgele isimler için)
            "John", "Jack", "James", "Jill", "Jenny", "Jesse", "Adam", "Alex", "Aaron", "Ben",
            "Carl", "Dan", "David", "Edward", "Fred", "Frank", "George", "Hal", "Hank", "Ike",
            "John", "Jack", "Joe", "Larry", "Monte", "Matthew",
        },
        surnames = { -- Çalışan soyisim havuzu (rastgele soyisimler için)
            "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore",
            "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson",
            "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker",
            "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott",
            "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez",
            "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins",
            "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy",
            "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres",
            "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders",
            "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins",
            "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler",
            "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz",
            "Hayes",
        },
    }
}