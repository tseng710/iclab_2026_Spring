import random

def generate_dram(filename="dram.dat"):
    with open(filename, "w") as f:
        # 總共 128 間店 (Shop No. 0 ~ 127)
        for i in range(128):
            base_addr = 0x10000 + i * 16

            # 1. 產生合法的隨機數值 (避免一開始就極端值導致無法測試)
            flour  = random.randint(100, 3000)
            butter = random.randint(100, 3000)
            milk   = random.randint(100, 3000)
            sugar  = random.randint(100, 3000)
            fruit  = random.randint(100, 3000)

            # 日期生成 (遵守二月 28 天的硬規則)
            month = random.randint(1, 12)
            if month in [1, 3, 5, 7, 8, 10, 12]:
                day = random.randint(1, 31)
            elif month in [4, 6, 9, 11]:
                day = random.randint(1, 30)
            else:
                day = random.randint(1, 28)

            level   = random.randint(0, 100)
            staff   = random.randint(0, 100)
            # 給足夠的初始資金，以免狂噴 Balance_Warn 導致其他測資打不到
            balance = random.randint(50000, 5000000) 

            # 🚨 關鍵：Sales 必須嚴格小於升級門檻
            threshold = max(10, 10 * (level // 10))
            sales = random.randint(0, threshold - 1)

            # 2. 將資料打包成 32-bit Word (與 Spec 記憶體圖表對齊)
            # Word 0: {Milk[11:0], Sugar[11:0], Day[7:0]}
            word0 = (milk << 20) | (sugar << 8) | day
            
            # Word 1: {Flour[11:0], Butter[11:0], Month[7:0]}
            word1 = (flour << 20) | (butter << 8) | month
            
            # Word 2: {Balance[23:0], Level[7:0]}
            word2 = (balance << 8) | level
            
            # Word 3: {Fruit[11:0], Sales[11:0], Staff[7:0]}
            word3 = (fruit << 20) | (sales << 8) | staff

            # 3. 轉成 Hex 並以 Little-Endian 寫入 (Byte 0 -> Byte 1 -> Byte 2 -> Byte 3)
            def format_word(addr, word):
                b0 = word & 0xFF
                b1 = (word >> 8) & 0xFF
                b2 = (word >> 16) & 0xFF
                b3 = (word >> 24) & 0xFF
                return f"@{addr:X}\n{b0:02X} {b1:02X} {b2:02X} {b3:02X}\n"

            f.write(format_word(base_addr + 0, word0))
            f.write(format_word(base_addr + 4, word1))
            f.write(format_word(base_addr + 8, word2))
            f.write(format_word(base_addr + 12, word3))

    print(f"✅ Successfully generated {filename} from @10000 to @107FF")

if __name__ == "__main__":
    # 將檔案生成到你的 TESTBED 目錄下
    generate_dram("../00_TESTBED/DRAM/dram.dat")