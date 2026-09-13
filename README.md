# Pixel-to-Mesh Modeling for Tow-Steered Composite Laminates

This repository contains the source code associated with the paper:

"Vibration Analysis of Tow-steered Composite Laminates using Pixel-to-Mesh Modeling"

## Authors
Md Raqibul Hasan Prince

Soumik Dutta

Wei Zhao

## Overview
The code implements the pixel-to-mesh modeling framework for
tow-steered composite laminates manufactured using automated fiber placement.

The major steps include:

1. Construction of individual tow geometries
2. Generation of binary tow images
3. One-to-one pixel-to-finite-element assignment
4. Identification of gap, normal-layup, and overlap regions
5. Assignment of local fiber-path orientations and laminate properties
6. Generation of finite-element input models
7. Reproduction of selected vibration-analysis examples

## Requirements
MATLAB R2024b above

MSC NASTRAN [2023]

## Reproducing the Results

To reproduce the results presented in the paper, run the corresponding example scripts in the `examples/` directory. Each example provides the model setup and analysis workflow for a case examined in the paper.


## License
MIT License

## Citation

If you use this code in your research, please cite the software using the following BibTeX entry:

```bibtex
@software{Prince_Pixel_to_Mesh,
  author  = {Prince, Md Raqibul Hasan and Dutta, Soumik and Zhao, Wei},
  title   = {Pixel-to-Mesh Modeling for Tow-Steered Composite Laminates},
  license = {MIT},
  url     = {https://github.com/zhaowei0566/Pixel-to-Mesh-VAT-Model}
}
```
