# frozen_string_literal: true

initial_tags = ["Appliance", "Art", "ATV/UTV,Snowmobile", "Auto part", "Aviation", "Baby & kid stuff", "Bicycle part", "Bicycle", "Boat part", "Boat", "Book",
                "Cars/Truck", "CD/DVD/VHS", "Cell Phone", "Clothing/Accessory", "Jewelry", "Collectible", "Computer part", "Computer", "Electronics", "Farm/garden", "Furniture",
                "Heavy equipment", "Household item", "Material", "Motorcycle part", "Motorcycle/Scooter", "Musical instrument", "Photo/Video", "RV", "Sporting Goods",
                "Tcket", "Tool", "Toy/Game", "Trailer", "Video game", "Pet"]
initial_tags.each { |t| Tag.create(name: t, main_category: true) }
