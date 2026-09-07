# Pixel-to-Mesh-VAT-Vibration
Pixel to mesh modeling approach for VAT laminates


# Pixel-to-Mesh Modeling of Tow-Steered Composite Laminates

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

Source code associated with:

**Vibration Analysis of Tow-steered Composite Laminates using Pixel-to-Mesh Modeling**

Md Raqibul Hasan Prince, Soumik Dutta, and Wei Zhao  
Oklahoma State University

## Overview

This repository contains the source code and example models for the
pixel-to-mesh modeling framework developed for automated-fiber-placement
(AFP) manufactured tow-steered composite laminates.

In the proposed approach, each individual deposited tow is represented
using a binary image on a common pixel grid. Each pixel corresponds
directly to one finite element.

For each tow:

- `1` indicates that the tow occupies the corresponding pixel/element.
- `0` indicates that no material from that tow occupies the
  corresponding pixel/element.
- The local fiber-path orientation of the tow is stored for each
  occupied element.

The contributions from all deposited tows are accumulated for each ply.

An element containing:

- no tow in a ply is classified as a gap;
- one tow is classified as normal layup;
- two or more tows is classified as an overlap.

Overlapping tows are retained as separate material layers according to
their deposition sequence, including their corresponding local
fiber-path orientations and ply thicknesses.

The resulting element-wise laminate definitions are exported for
finite element analysis.

## Main capabilities

The repository implements:

1. Variable-angle fiber-path generation
2. Individual tow geometry construction
3. Multiple-tow AFP course generation
4. Tow-overlap modeling
5. Tow-drop and cut/restart modeling
6. Binary-image generation for individual tows
7. One-to-one pixel-to-finite-element assignment
8. Element-wise tow accumulation
9. Gap/normal-layup/overlap identification
10. Local fiber-orientation assignment
11. Element-wise laminate construction
12. Finite element model generation
13. MSC NASTRAN model export
14. Modal-result postprocessing

## Repository structure

```text
src/          Core pixel-to-mesh source code
examples/     Cases corresponding to the manuscript
data/         Material properties and reference results
configs/      Input parameters for manuscript cases
results/      Generated results (not required source files)
docs/         Detailed methodology and reproduction documentation