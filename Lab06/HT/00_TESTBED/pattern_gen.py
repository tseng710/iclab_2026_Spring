import random
import os

# 設定要產生的 Pattern 數量
PAT_NUM = 1000

# Character index mapping: A=0, B=1, C=2, E=3, I=4, L=5, O=6, V=7
ILOVE = [4, 5, 6, 7, 3]  # I, L, O, V, E
ICLAB = [4, 2, 5, 0, 1]  # I, C, L, A, B

class Node:
    def __init__(self, weight, prio, id):
        self.weight = weight
        self.prio = prio
        self.id = id
        self.left = None
        self.right = None

def generate_pattern():
    random.seed(42)
    base_dir = os.path.dirname(os.path.abspath(__file__))
    in_path = os.path.join(base_dir, 'input.txt')
    out_path = os.path.join(base_dir, 'output.txt')

    with open(in_path, 'w') as f_in, open(out_path, 'w') as f_out:
        for _ in range(PAT_NUM):
            weights = [random.randint(1, 7) for _ in range(8)]
            mode = random.randint(0, 1)
            
            f_in.write(" ".join(map(str, weights)) + f" {mode}\n")
            
            active_nodes = [Node(weights[i], 15 - i, i) for i in range(8)]
            
            for step in range(7):
                # Sort ascending by weight; for same weight, higher prio number
                # (lower priority: New subtree > Old subtree > V > ... > A) comes first
                # so they get picked as "smaller"
                active_nodes.sort(key=lambda x: (x.weight, x.prio))
                right_node = active_nodes.pop(0)  # smallest
                left_node = active_nodes.pop(0)   # second smallest (bigger -> left)
                
                new_weight = left_node.weight + right_node.weight
                new_prio = 15 - (8 + step)
                
                parent = Node(new_weight, new_prio, -1)
                parent.left = left_node
                parent.right = right_node
                active_nodes.append(parent)
            
            codes = {}
            def traverse(node, path):
                if node.id != -1:
                    codes[node.id] = path
                if node.left:
                    traverse(node.left, path + '0')
                if node.right:
                    traverse(node.right, path + '1')
            
            root = active_nodes[0]
            traverse(root, "")
            
            output_order = ILOVE if mode == 0 else ICLAB
            
            bitstream = []
            for idx in output_order:
                bitstream.extend(list(codes[idx]))
            
            f_out.write(f"{len(bitstream)} " + " ".join(bitstream) + "\n")

    print(f"[Python] Successfully generated {PAT_NUM} random patterns to {base_dir}!")

if __name__ == '__main__':
    generate_pattern()