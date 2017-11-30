#!/bin/bash

# For AFM and PFA, the following versions are done (2x3x6 = 36)
# - concepts global, concepts within problem (wp)
# - opportunities count, opportunities and their occurence (N), opportunities and log1p of their occurence (LN)
# - all skills (A), changed skills (B), changed with removals (C), all with removals (D), all sparsed by lm (Alm), all sparsed by rfe (Arfe)
# 36 AFM models, 36 PFA models = 72

./code/modelPFA_fit.sh
./code/modelPFAN_fit.sh
./code/modelPFALN_fit.sh
./code/modelPFAwp_fit.sh
./code/modelPFAwpN_fit.sh
./code/modelPFAwpLN_fit.sh
# each of 6 produces 6 skill versions