# RTL source set

The latest RTL snapshot from the working Vivado source set is stored here. `retinex_top_level.v` is the top module. The three `.mem` files are required by the lookup-table modules and should be added as memory initialization files in Vivado.

| Stage | Modules |
|---|---|
| Guidance and coarse illumination | `rgb_to_gi.v`, `line_buffer_10x.v`, `max3.v`, `col_max_11.v`, `window_max_generator.v` |
| Edge-preserving illumination refinement | `col_min_11.v`, `filter_node.v`, `linear_approx_gamma.v`, `edge_preserving_filter.v` |
| Reflectance and output | `reflectance_calc.v`, `illumination_modifier.v`, `retinex_top_level.v` |
| Lookup tables | `inverse_lut.mem`, `inverse_fm_lut.mem`, `e_mod_lut.mem` |

The top-level file currently sets `IMG_W` to 100. Keep that value consistent with the testbench and the input image dimensions. The historical root-level RTL filenames were replaced with this newer module set; the earlier files remain available in Git history.
