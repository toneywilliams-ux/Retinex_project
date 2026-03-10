# Retinex_project

## goal:

Input: Low-light RGB image (1920×1080)
Output: Enhanced image with better brightness and details





## flow:
Input RGB Image
      │
      ▼
Maximum Channel (Gi)
      │
      ▼
Coarse Illumination (Pci)
      │
      ▼
Edge Preserving Filter
      │
      ▼
Refined Illumination (Fm)
      │
      ▼
Reflectance Calculation
      │
      ▼
Illumination Modification
      │
      ▼
Final Image Reconstruction


Step-1: Max channel calculation ( max (R, G, B))

      - As low RGB image we need to make the RGB max which is why we use Maximum channel.

Step-2: Coarse illumination estimation ( max (max (R, G, B)))
      - as we need some window as the illumination changes slowly across space, so using a local window helps estimate the local lighting condition.
      - we use {line buffers + sliding window}
      - in paper they have used this simplification method where they make the 11 x 11 sliding window into a 1 x 11 window by takinf the maxi
