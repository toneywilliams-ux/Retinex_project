# Retinex-Based Low-Light Image Enhancement on FPGA

*A simplified step‑by‑step explanation with block diagrams and pipeline diagrams*


here is the top module of this project [1_max_channel.v](https://github.com/toneywilliams-ux/Retinex_project/blob/f3d1cdf0ddd2b69e1a2bb271740bafc520f0265e/1_max_channel.v)
---

# 1. What Problem Are We Solving?

Low‑light images are dark and lose details. This affects systems like:

* autonomous driving
* surveillance cameras
* robotics

The goal is to **brighten the image while keeping edges and textures**.

To do this we use the **Retinex algorithm**, inspired by human vision.

---

# 2. Core Idea of Retinex

Retinex assumes an image is made of two parts:

```
Image = Illumination × Reflectance
```

Where

* **Illumination (E)** → lighting conditions
* **Reflectance (R)** → real object colors and edges

So:

```
P(x,y) = E(x,y) × R(x,y)
```

The enhancement process is:

1. Estimate illumination
2. Extract reflectance
3. Improve illumination
4. Recombine the image

---

# 3. Overall FPGA Pipeline

The FPGA processes **one pixel per clock cycle** using a pipeline.

## System Block Diagram

```
RGB Image
   │
   ▼
Max Channel
   │
   ▼
Sliding Window
   │
   ▼
Coarse Illumination
   │
   ▼
Edge Preserving Filter
   │
   ▼
Refined Illumination
   │
   ▼
Reflectance Estimation
   │
   ▼
Illumination Enhancement
   │
   ▼
Image Reconstruction
   │
   ▼
Enhanced Image
```

---

# 4. Stage 1 — Maximum Channel

### What it does

From the RGB pixel we select the largest value:

```
Gi(x,y) = max(R,G,B)
```

### Why?

Edges usually appear strongly in at least one channel. Taking the max helps preserve edges when estimating illumination.

### Block Diagram

```
   R
   │
   ├──► MAX ──► Gi
   │
   G
   │
   B
```

### Hardware Used

Only **comparators**.

This stage is very cheap in FPGA resources.

---

# 5. Stage 2 — Sliding Window Generator

Many image algorithms need **neighboring pixels**.

This design uses an **11×11 window**.

Instead of storing the whole frame we use **line buffers**.

### Sliding Window Architecture

```
Pixel Stream
     │
     ▼
┌───────────┐
│ Line Buf1 │
└───────────┘
     │
┌───────────┐
│ Line Buf2 │
└───────────┘
     │
   ...
     │
┌───────────┐
│ Line Buf10│
└───────────┘
```

This generates a **11×11 neighborhood every clock cycle**.

### Advantage

```
Memory needed = image width × 10
```

instead of storing the entire image.

---

# 6. Stage 3 — Coarse Illumination

Now we estimate the local brightness.

```
Pci(x,y) = maximum value in local window
```

### Block Diagram

```
11×11 Window
     │
     ▼
Column MAX
     │
     ▼
Window MAX
     │
     ▼
Pci(x,y)
```

### Why?

Illumination usually changes **slowly across an image**, so the local maximum is a good approximation of lighting.

---

# 7. Stage 4 — Edge Preserving Filter

The coarse illumination may look blocky.

So we smooth it **without destroying edges**.

### Simplified Idea

Instead of filtering all 121 pixels we use:

```
minimum value from each column
```

So

```
11×11 → 11 values
```

### Filter Diagram

```
Pci_min(1..11)
      │
      ▼
Weight Calculation
      │
      ▼
Weighted Sum
      │
      ▼
Refined Illumination Fm
```

### Why This Trick?

It reduces hardware cost dramatically.

---

# 8. Exponential Approximation

The filter uses a weight:

```
exp()
```

Exponentials are expensive in hardware.

### FPGA Friendly Solution

Use **piecewise linear approximation**.

```
exp(x)
  │
  ▼
8 linear segments
```

Implemented using

```
shift operations
adders
```

No multipliers required.

---

# 9. Stage 5 — Refined Illumination

After filtering we obtain:

```
Fm(x,y)
```

This is the **final illumination map**.

Properties:

* smooth
* preserves edges
* no block artifacts

---

# 10. Stage 6 — Reflectance Extraction

Now we separate the object information.

```
R(x,y) = P(x,y) / Fm(x,y)
```

### Hardware Problem

Division is expensive.

### FPGA Trick

Instead of division we use:

```
P / Fm  =  P × (1/Fm)
```

### Block Diagram

```
Fm
 │
 ▼
Reciprocal LUT
 │
 ▼
1/Fm
 │
 ▼
Multiplier
 │
 ▼
Reflectance R
```

### Why LUTs?

Division hardware:

* slow
* large
* many cycles

LUT approach:

* 1 clock cycle
* small hardware
* faster

---

# 11. Stage 7 — Illumination Enhancement

Next we brighten the illumination.

Formula:

```
Emod = Fm / (2 − Fm)
```

### Implementation

Again implemented using a **lookup table**.

```
Fm
 │
 ▼
LUT
 │
 ▼
Emod
```

This avoids complex arithmetic.

---

# 12. Stage 8 — Image Reconstruction

Finally we combine reflectance and improved illumination.

```
Enhanced Image = Emod × R
```

### Block Diagram

```
Reflectance R
     │
     ▼
Multiplier
     ▲
     │
Emod
```

This produces the final enhanced pixel.

---

# 13. Full Pipeline Diagram

```
Clock Cycle Pipeline

Stage1   Stage2   Stage3   Stage4   Stage5   Stage6   Stage7   Stage8
│        │        │        │        │        │        │        │
Max → Window → Illum → Filter → Fm → Reflect → Enhance → Output
```

Each stage works **simultaneously**.

After the pipeline fills:

```
1 pixel output every clock
```

---

# 14. Why This FPGA Design Works Well

Key optimizations used:

### Sliding Windows

Avoid full frame storage.

### LUTs instead of Division

Much faster and smaller hardware.

### Piecewise Linear Functions

Replace complex math.

### 1D Filter Instead of 2D

Huge reduction in multipliers.

---

# 15. Final Processing Flow

```
Input Pixel
     │
     ▼
Max Channel
     │
     ▼
Sliding Window
     │
     ▼
Coarse Illumination
     │
     ▼
Edge Preserving Filter
     │
     ▼
Refined Illumination
     │
     ▼
Reflectance Extraction
     │
     ▼
Illumination Enhancement
     │
     ▼
Reconstruction
     │
     ▼
Enhanced Pixel
```

---

# 16. Result

The FPGA can process:

```
1920 × 1080 resolution
60 frames per second
```

with relatively low hardware resources.

This makes the design suitable for **real‑time embedded vision systems**.
