import random
import sys

# 對應 TESTBED 資料夾的路徑
INPUT_FILE = "../00_TESTBED/input.txt"
GOLDEN_FILE = "../00_TESTBED/golden.txt"

# ==========================================
# 主程式
# ==========================================
def main():
    # 1. 接收從 Verilog 傳遞過來的參數
    if len(sys.argv) < 4:
        print("Usage: python3 pattern_ip.py <num_patterns> <seed> <ip_width>")
        sys.exit(1)

    patnum = int(sys.argv[1])
    seed = int(sys.argv[2])
    ip_width = int(sys.argv[3])

    random.seed(seed)

    # 2. 開啟檔案寫入
    with open(INPUT_FILE, 'w') as f_in, open(GOLDEN_FILE, 'w') as f_out:
        
        for i in range(patnum):
            # 產生初始 Characters (依據 IP_WIDTH 倒序產生)
            # 例如 IP_WIDTH=8，則產生 [7, 6, 5, 4, 3, 2, 1, 0]
            in_character = list(range(ip_width - 1, -1, -1))
            
            # 產生對應的 Weights
            if i == 0:
                # 第一筆測資: All 0 corner case (測試 weight 相同時的 char 優先級)
                in_weight = [0] * ip_width
            elif i == 1:
                # 第二筆測資: All 31 corner case
                in_weight = [31] * ip_width
            else:
                # 一般隨機測資 (5-bit weight: 0~31)
                in_weight = [random.randint(0, 31) for _ in range(ip_width)]
            
            # ==========================================
            # 寫入 input.txt
            # ==========================================
            char_str = " ".join(map(str, in_character))
            weight_str = " ".join(map(str, in_weight))
            
            f_in.write(f"{char_str}\n")
            f_in.write(f"{weight_str}\n\n")
            
            # ==========================================
            # 計算 Golden 答案並寫入 golden.txt
            # ==========================================
            # 將 weight 與 character 打包成 tuple 列表: [(weight, char), ...]
            nodes = list(zip(in_weight, in_character))
            
            # 排序邏輯:
            # x[0] 是 weight, x[1] 是 character
            # 預設 sort 會依據數值由小到大排
            nodes.sort(key=lambda x: (x[0], x[1]))
            
            # 關鍵反轉邏輯 (配合 Verilog 高低位元映射):
            # 在 SORT_IP 中，最小的數值最終會被推到二維陣列的 index 0，並被打包到輸出的 LSB。
            # 而在 PATTERN_IP.v 讀檔時，Python 輸出的「最後一個元素」會被放進 LSB。
            # 因此，我們必須用 reverse() 讓最大值排在最前面，最小值排在最後面，才能完美吻合硬體波形。
            nodes.reverse()
            
            # 提取排序後的 characters
            out_character = [node[1] for node in nodes]
            
            out_char_str = " ".join(map(str, out_character))
            f_out.write(f"{out_char_str}\n\n")

if __name__ == "__main__":
    main()