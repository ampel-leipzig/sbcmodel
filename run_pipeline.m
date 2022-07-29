clear all; close all; clc;

ntrees = 700 ;
maxSplits = 40 ;
learn_rate = 1 ;
fileID = fopen('results.txt','a') ;

% seed from paper: 1714400672
current_random_seed = 1714400672;
rng(current_random_seed)
load_datasets ;

oversampling_factor = [10] ;

training_le;

% Copyright (c) 2014 Brian Lau [brian.lau@upmc.fr](mailto:brian.lau@upmc.fr)
% see [LICENSE](https://github.com/brian-lau/MatlabAUC/blob/master/LICENSE)
addpath('./External Code/auc_tools')

gw_validation;

mimic_val;
le_val;
thresholds_and_ppv ;

time_dynamic;

mean(aucs)
display(mimic_auc)
display(gw_auc)
print_str = num2str(time_window2) + ";" ;
print_str = print_str + num2str(oversampling_factor) +";";
print_str = print_str + num2str(mean(aucs)) + ";" ;
print_str = print_str + num2str(median_predTime_h_s50) + ";";
print_str = print_str + num2str(gw_auc) + ";" ;
print_str = print_str + num2str(mimic_auc) + ";" ;
print_str = print_str + num2str(le_val_auc) + ";" ;
print_str = print_str + num2str(current_random_seed) + ";" ;
print_str = print_str + num2str(ntrees) + ";";
print_str = print_str + num2str(maxSplits) + ";";
print_str = print_str + num2str(learn_rate) + ";\n";
fprintf(fileID,print_str) ;

%%

pct_mdl;

