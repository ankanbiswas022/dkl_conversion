# dkl_conversion

This is a collection of routines for utilizing the DKL color space, written by Nicholas Blauch in the Cowell and Huber Labs at UMass Amherst.

A good starting point to understanding these routines is the file dkl_example.m . 
This file demonstrates the production of an isoluminant plane and optional gamma-based (il)luminance-correction.

Explicit (il)luminance-correction was developed by NB in order to accomodate isoluminant colors with high dynamic range, given the observation
that explicit gamma-correction via a look-up-table (LUT) results in very washed out colors, and does not result in completely isoluminant colors. 

questions?
email nblauch@icloud.com or create an issue on github
