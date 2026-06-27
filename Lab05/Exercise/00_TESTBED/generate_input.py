import sys
import numpy as np
import random

# ==========================================
#  Helper Functions
# ==========================================
def clip_to_uint8(val):
    return np.clip(val, 0, 255).astype(np.uint8)

def clip_to_int8(val):
    return np.clip(val, -128, 127).astype(np.int8)

def right_shift_signed(val, shift):
    # Numpy 的 right_shift 在處理 signed integer 時等同於 Verilog 的 arithmetic shift (>>>)
    return np.right_shift(val.astype(np.int32), shift)

# ==========================================
#  Model Layers
# ==========================================
def down_conv(image, weight):
    # image: 64x64, uint8
    # weight: 16x3x3, int8 (16 output channels, 1 input channel)
    out = np.zeros((16, 16, 16), dtype=np.uint8)
    
    # Zero padding of size 1 for 3x3 kernel
    padded_img = np.pad(image, 1, mode='constant', constant_values=0).astype(np.int32)
    
    for oc in range(16):
        for h_out in range(16):
            for w_out in range(16):
                # Stride is 4
                h_center = h_out * 4 + 1
                w_center = w_out * 4 + 1
                
                patch = padded_img[h_center-1:h_center+2, w_center-1:w_center+2]
                mac = np.sum(patch * weight[oc])
                
                # Norm & Activation
                shifted = right_shift_signed(mac, 6) + 128
                out[oc, h_out, w_out] = clip_to_uint8(shifted)
    return out

# ==========================================
# 步驟 1: 第一段 Linear Transformation (產生 Q, K, V)
# 斷點: 第一次做完 linear transformation 之後
# ==========================================
def transformer_step1_qkv(feature_map, w_q, w_k, w_v):
    # 1. Feature Map Reordering
    X = np.zeros((256, 16), dtype=np.int32)
    for h in range(16):
        for w in range(16):
            for c in range(16):
                X[h*16 + w, c] = feature_map[c, h, w]
                
    # 2. Subtract midpoint
    X_calc = X - 128
    
    # 3. Linear Projections (16x16 Matrix Multiplications)
    Q_raw = np.matmul(X_calc, w_q)
    K_raw = np.matmul(X_calc, w_k)
    V_raw = np.matmul(X_calc, w_v)
    
    Q = clip_to_int8(right_shift_signed(Q_raw, 4))
    K = clip_to_int8(right_shift_signed(K_raw, 4))
    V = clip_to_int8(right_shift_signed(V_raw, 4))
    
    return Q, K, V

# ==========================================
# 步驟 2: Attention 機制 (計算 Z)
# 斷點: 第二次 linear transformation 之前
# ==========================================
def transformer_step2_attention(Q, K, V):
    # 4. Attention 計算
    Attn_raw = np.matmul(Q.astype(np.int32), K.astype(np.int32).T)
    Attn_div = right_shift_signed(Attn_raw, 2) # Divide by 4 (round down)
    
    clip_point = np.clip(Attn_div, -2048, 2047)
    
    # fixpoint 是 256x256 的 Attention Map (類似 Softmax 的結果)
    fixpoint = clip_to_uint8(right_shift_signed(clip_point, 4) + 128) 
    
    Attn_out_raw = np.matmul(fixpoint.astype(np.int32), V.astype(np.int32))
    
    # Attn_out 是 256x16 的矩陣，這就是進入 FFN (第二次 Linear) 前的資料 (通常稱為 Z)
    Attn_out = clip_to_int8(right_shift_signed(Attn_out_raw, 16))
    
    return Attn_out, fixpoint

# ==========================================
# 步驟 3: 第二段 Linear Transformation (FFN) 與重組
# 斷點: 第二次做完 linear transformation 之後
# ==========================================
def transformer_step3_ffn(Attn_out, w_ffn):
    # 5. Feed Forward Network (FFN)
    FFN_raw = np.matmul(Attn_out.astype(np.int32), w_ffn)
    FFN_norm = right_shift_signed(FFN_raw, 4)
    FFN_out = clip_to_uint8(FFN_norm + 128)
    
    # 6. Reorder back to 16x16x16 (對應寫回 Feature Map SRAM 的過程)
    out_fm = np.zeros((16, 16, 16), dtype=np.uint8)
    for h in range(16):
        for w in range(16):
            for c in range(16):
                out_fm[c, h, w] = FFN_out[h*16 + w, c]
                
    return out_fm

def up_conv(feature_map, weight):
    # feature_map: 16x16x16
    # weight: 16x3x3 (1 output channel, 16 input channels)
    out = np.zeros((16, 16), dtype=np.uint8)
    
    # Zero padding of size 1 on spatial dims only
    padded_fm = np.pad(feature_map, ((0,0), (1,1), (1,1)), mode='constant', constant_values=0).astype(np.int32)
    
    for h_out in range(16):
        for w_out in range(16):
            # Stride is 1
            h_center = h_out + 1
            w_center = w_out + 1
            
            mac = 0
            for ic in range(16):
                patch = padded_fm[ic, h_center-1:h_center+2, w_center-1:w_center+2]
                mac += np.sum(patch * weight[ic])
                
            shifted = right_shift_signed(mac, 6) + 128
            out[h_out, w_out] = clip_to_uint8(shifted)
    return out

def interpolate(fm, mode):
    out = np.zeros((64, 64), dtype=np.uint8)
    fm = fm.astype(np.int32)
    
    if mode == 0:
        for r in range(16):
            for c in range(16):
                for kr in range(4):
                    for kc in range(4):
                        out[r*4 + kr, c*4 + kc] = fm[r, c]
                        
    elif mode == 1: # X-direction
        for r in range(16):
            for c in range(15):
                step = right_shift_signed(fm[r, c+1] - fm[r, c], 2)
                for k in range(4):
                    val = fm[r, c] + k * step
                    for kr in range(4):
                        out[r*4 + kr, c*4 + k] = clip_to_uint8(val)
            # Extrapolation
            step = right_shift_signed(fm[r, 15] - fm[r, 14], 2)
            for k in range(4):
                val = clip_to_uint8(fm[r, 15] + k * step)
                for kr in range(4):
                    out[r*4 + kr, 15*4 + k] = val
                    
    elif mode == 2: # Y-direction
        for c in range(16):
            for r in range(15):
                step = right_shift_signed(fm[r+1, c] - fm[r, c], 2)
                for k in range(4):
                    val = fm[r, c] + k * step
                    for kc in range(4):
                        out[r*4 + k, c*4 + kc] = clip_to_uint8(val)
            # Extrapolation
            step = right_shift_signed(fm[15, c] - fm[14, c], 2)
            for k in range(4):
                val = clip_to_uint8(fm[15, c] + k * step)
                for kc in range(4):
                    out[15*4 + k, c*4 + kc] = val
    return out

# ==========================================
#  Main Logic
# ==========================================
def main():
    if len(sys.argv) < 4:
        print("Usage: python3 generate_input.py <num_patterns> <seed> <debug_target>")
        sys.exit(1)

    num_patterns = int(sys.argv[1])
    seed = int(sys.argv[2])
    debug_target = int(sys.argv[3]) 

    random.seed(seed)
    np.random.seed(seed)

    if debug_target == -1:
        f_out = open("input.txt", "w")

    # =========================================================================
    # 🌟 修改 1: 產生 Weights。將原本在 for 迴圈內的權重生成移到這裡。
    # 這樣所有 Pattern 就會共用這唯一的一組權重，符合規格書要求。
    # =========================================================================
    w_down = np.random.randint(-8, 8, size=(16, 3, 3), dtype=np.int8)
    w_q = np.random.randint(-8, 8, size=(16, 16), dtype=np.int8)
    w_k = np.random.randint(-8, 8, size=(16, 16), dtype=np.int8)
    w_v = np.random.randint(-8, 8, size=(16, 16), dtype=np.int8)
    w_ffn = np.random.randint(-8, 8, size=(16, 16), dtype=np.int8)
    w_up = np.random.randint(-8, 8, size=(16, 3, 3), dtype=np.int8)

    for p in range(num_patterns):
        # 1. Random Parameters (每次都新產生設定)
        iterations = random.randint(1,5)
        mode = random.randint(0, 2)
        
        # (Image 每次都新產生)
        image = np.random.randint(0, 256, size=(64, 64), dtype=np.uint8)
        
        # 3. Model Inference (計算時，會使用上面的共用權重 w_down, w_q 等)
        current_image = image.copy()
        
        for i in range(iterations):
            fm_down = down_conv(current_image, w_down)
            
            Q, K, V = transformer_step1_qkv(fm_down, w_q, w_k, w_v)
            Attn_out, attn_map = transformer_step2_attention(Q, K, V)
            fm_trans = transformer_step3_ffn(Attn_out, w_ffn)

            fm_up = up_conv(fm_trans, w_up)
            
            interpolated = interpolate(fm_up, mode)
            scaled_noise = right_shift_signed(interpolated, 3)
            
            # Denoise (with clip to uint8)
            current_image = clip_to_uint8(current_image.astype(np.int32) - scaled_noise)
            np.savetxt(f"current_image_log_{i}.txt", current_image, fmt='%d')
            
        golden_output = current_image
        np.savetxt(f"golden_output.txt", golden_output, fmt='%d')
        
        # 4. Output Logic
        if debug_target == p:
            print(f"\n\033[0;35m[PYTHON DEBUGGER] Pattern {p} Details\033[m")
            print(f"Iterations: {iterations}, Mode: {mode}")
            print(f"pixels of Golden: {golden_output}")
            print(f"\033[0;33m========================================\033[m\n")
            return 

        if debug_target == -1:
            # First line: iter mode
            f_out.write(f"{iterations} {mode}\n")
            
            # =================================================================
            # 🌟 修改 2: 寫入 Weights。
            # 只在 p == 0 (第一張圖) 的時候，才把權重寫入 input.txt
            # =================================================================
            if p == 0:
                weights_flat = np.concatenate([
                    w_down.flatten(), w_q.flatten(), w_k.flatten(), 
                    w_v.flatten(), w_ffn.flatten(), w_up.flatten()
                ])
                for w in weights_flat:
                    f_out.write(f"{(w & 0x0F):01x}\n")
                
            # Image
            for val in image.flatten():
                f_out.write(f"{val:02x}\n")
                
            # Golden Output
            for val in golden_output.flatten():
                f_out.write(f"{val:02x}\n")
            
            if (p + 1) % 10 == 0:
                print(f"  Pattern {p + 1:4d} generated.")

    if debug_target == -1:
        f_out.close()
        print(f"\n[SUCCESS] Generated {num_patterns} patterns to input.txt!")

if __name__ == "__main__":
    main()