#!/bin/bash

# For AFM and PFA, the following versions are done (2x3x6 = 36)
# - concepts global, concepts within problem (wp)
# - opportunities count, opportunities and their occurence (N), opportunities and log1p of their occurence (LN)
# - all skills (A), changed skills (B), changed with removals (C), all with removals (D), all sparsed by lm (Alm), all sparsed by rfe (Arfe)
# 36 AFM models, 36 PFA models = 72

./code/modelAFM_fit.sh
./code/modelAFMN_fit.sh
./code/modelAFMLN_fit.sh
./code/modelAFMwp_fit.sh
./code/modelAFMwpN_fit.sh
./code/modelAFMwpLN_fit.sh
# each of 6 produces 6 skill versions