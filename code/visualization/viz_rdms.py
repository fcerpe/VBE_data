#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb  6 15:11:39 2025

@author: cerpelloni
"""

import os
import glob
import json
import urllib
import torch
import torch.nn as nn
import torchvision.models as models
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


## Plot distances as Representational Dissimilarity Matrices (RDMs)

# Create a heatmap with letters labels (in english to make it easier to read)
plt.figure()

base_labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
               'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

repeated_labels = base_labels * 3

# Create new labels with sequence indicators
scripts = ['Braille', 'Line', 'Latin']
new_labels = []
for l in range(3):
    new_labels.extend([label for label in base_labels])
        
ax = sns.heatmap(dist_matrix, 
                 cmap='viridis', 
                 annot=False, 
                 xticklabels = False, 
                 yticklabels = False)

# Customize the heatmap
if b == 0:
    script = 'BR'
else: 
    script = 'LN'

title = f'ReLU stage {i}'
ax.set_title(title, fontsize = 15)

# Add sequence indicators as subtitles for the axis
for j, script in enumerate(scripts):
    plt.text(-8, 26 * j + 13, script, rotation = 90, fontsize = 12, verticalalignment = 'center')
    plt.text(26 * j + 13, 85, script, rotation = 0, fontsize = 12, horizontalalignment = 'center')

ax.yaxis.set_tick_params(rotation = 0)
for label in ax.get_yticklabels():
    label.set_verticalalignment('center')

ax.set_aspect('equal')

# Save plot
savename = f'vbs_alexnet-letters_stage-{i}_plot-rdm-all-scripts.png'
savepath = os.path.join('figures', savename)
plt.savefig(savepath, dpi = 600)

# Show the plot
plt.show()

# labels = ['A','B','C','D','E','F','G','H','I','J','K','L','M', 
#           'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'] 

# ax = sns.heatmap(dist_matrix, 
#                  cmap = 'viridis', 
#                  annot = False, 
#                  xticklabels = labels, 
#                  yticklabels = labels)

# # Customize the heatmap
# if b == 0:
#     script = 'BR'
# else: 
#     script = 'LN'
    
# title = (f'Batch {script} - ReLU stage {i}')

# ax.set_title(title, fontsize = 15)

# ax.yaxis.set_tick_params(rotation = 0)
# for label in ax.get_yticklabels():
#     label.set_verticalalignment('center')

# ax.set_aspect('equal')

# # # Save plot
# savename = (f'vbs_alexnet-letters_batch-{script}_stage-{i}_resize-squared.png')
# savepath = os.path.join('figures', savename)
# plt.savefig(savepath, dpi = 600)

# # Show the plot
# plt.show()
