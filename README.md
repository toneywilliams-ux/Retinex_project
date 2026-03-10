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



Step-1: Maximum Channel Calculation
  Gi​(x,y)=max(R,G,B)
Why?
A. Edges exist strongly in at least one color channel.
    Taking max:
      preserves edge information
      provides a good guidance image
      The paper calls this Guidance Image Gi.

      
  
