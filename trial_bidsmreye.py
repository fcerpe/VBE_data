#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 13 12:24:05 2024
@author: costantino_ai

This script analyzes multiple NIFTI files, printing relevant information and warnings.
It checks for differences in TR across files and warns about empty or NaN slices.
"""

import nibabel as nib
import numpy as np


def analyze_nifti(file_path, file_type):
    """
    Analyze a single NIFTI file and print relevant information.

    Args:
    file_path (str): Path to the NIFTI file
    file_type (str): Type of the file (e.g., 'BIDS', 'fMRIPrep MNI', 'fMRIPrep T1w')

    Returns:
    float: TR value of the file
    """
    print(f"\n--- Analyzing {file_type} file: {file_path} ---")

    img = nib.load(file_path)
    data = img.get_fdata()

    # Print basic information
    print(f"Data shape: {img.shape}")
    print(f"Voxel size: {img.header.get_zooms()}")

    # Get and print TR
    tr = img.header["pixdim"][4]
    print(f"TR: {tr} seconds")

    # Check for empty slices
    empty_slices = [i for i in range(data.shape[2]) if np.all(data[:, :, i] == 0)]
    if empty_slices:
        print(f"WARNING: Empty slices found at indices: {empty_slices}")
    else:
        print("No empty slices found.")

    # Check for NaNs
    nan_count = np.isnan(data).sum()
    if nan_count > 0:
        print(f"WARNING: Found {nan_count} NaN values in the data.")
    else:
        print("No NaN values found in the data.")

    return tr


def main():
    # Define file paths
    files = {
        "BIDS": "/Volumes/fcerpe_phd/VBE_data/inputs/raw/sub-006/ses-001/func/sub-006_ses-001_task-visualLocalizer_run-001_bold.nii.gz",
        "fMRIPrep MNI": "/Volumes/fcerpe_phd/VBE_data/outputs/derivatives/bidspm-preproc/sub-006/ses-001/func/sub-006_ses-001_task-visualLocalizer_run-001_space-IXI549Space_desc-preproc_bold.nii.gz",
        "fMRIPrep T1w": "/Volumes/fcerpe_phd/VBE_data/outputs/derivatives/bidspm-preproc/sub-006/ses-001/func/sub-006_ses-001_task-visualLocalizer_run-001_space-individual_desc-preproc_bold.nii.gz",
    }

    tr_values = {}

    # Analyze each file
    for file_type, file_path in files.items():
        tr_values[file_type] = analyze_nifti(file_path, file_type)

    # Check for TR differences
    if len(set(tr_values.values())) > 1:
        print("\nWARNING: TR values differ across files:")
        for file_type, tr in tr_values.items():
            print(f"{file_type}: {tr} seconds")
    else:
        print("\nAll files have the same TR value.")


if __name__ == "__main__":
    main()