# From Hardcoded to Generic Vedic Multiplier: A Human + AI Co-Design Journey

This project started with the mindset of creating the **fastest multiplier possible** by combining two efficient arithmetic designs: the **Carry Look-Ahead (CLA) adder** and the **Vedic multiplier** — merging the best of both worlds.

This project has always followed a Human + AI Co-Design approach, where I built the foundational designs, studied the strengths and weaknesses of AI-generated hardware code, and learned how to guide AI tools like Gemini, Claude, and ChatGPT effectively. It wasn’t just about code generation — it was about understanding the AI's decisions, correcting mistakes, and using it strategically to streamline and optimize hardware designs.

---

## Carry Look-Ahead Adder

The file `cla_4bit.v` contains a **4-bit Carry Look-Ahead Adder** designed manually by me. After providing the carry-generate and propagate logic to Gemini, it successfully generated a **generic N-bit Carry Look-Ahead Adder (`cla_nbit.v`)**.

This implementation uses:
- A 4-bit CLA block as the base building block.
- Generate and propagate logic to compute carry signals between the blocks.
- Generatinal connection of N-bit adders using multiple 4-bit CLA units.

---

## Vedic Multiplier

I began my journey by creating a **2-bit Vedic multiplier**, followed by a **4-bit implementation**.  
To extend this further, I designed 8, 16, 32, 64, 128, and even 256-bit multipliers using a **hierarchical approach**.

Initially, I planned to write separate top modules for each bit width, but realized that using **Verilog `generate` blocks and parameters** made it much cleaner and scalable — like a **fractal structure** that repeats itself at different levels.

In early experiments, when I prompted AI tools like Claude, Gemini, and ChatGPT, they initially generated N-bit multipliers by combining 2-bit multipliers with adders based on the **Booth algorithm** (which I didn’t want).  
After refining the prompts and approach, Gemini was able to generate a **recursive module** where:
- The multiplier module would call itself recursively.
- At the base case (2-bit), it would implement a simple 2-bit Vedic multiplier.
- Each recursive level would combine partial products using CLA adders.

---

## How the Recursive Vedic Multiplier Works

Consider the following line from the code:
```verilog
vedic_nbit_mul #(.WIDTH(HALF_WIDTH)) m1 (
  .a(a[HALF_WIDTH-1:0]),
  .b(b[HALF_WIDTH-1:0]),
  .m(p0_sub)
);
```
- An 8-bit multiplier will divide the problem into four 4-bit multipliers, handling the top-left, top-right, bottom-left, and bottom-right portions of the partial product matrix.
- Each 4-bit multiplier will then divide itself into four 2-bit multipliers, following the same pattern.
- These partial products are then combined using Carry Look-Ahead (CLA) adders at each stage.
- The process continues until reaching the base case — the 2-bit Vedic multiplier.
- After all partial results are computed, they are combined through CLA adders to produce the final result.
 
`
2   2   2  2   2  2   2  2  2   2   2  2   2  2   2  2   
 \_/    \_/    \_/    \_/    \_/    \_/    \_/    \_/ 
  |      |      |      |      |      |      |      |
  4      4      4      4      4      4      4      4 
   \_____/       \_____/      \_____/       \_____/
      |            |             |            |
       \__________/               \__________/ 
            |                          |
            8                          8
             \________________________/
                          |
                          16
`  
