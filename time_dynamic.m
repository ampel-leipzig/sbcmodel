sepsis_datapoints = data_le(data_le.Diagnosis == "Sepsis",:) ;

%% S50


detected_datapoints_s50 = sepsis_datapoints(sepsis_datapoints.Scores>=th_s50,:) ;

median_predTime_h_s50 = median(detected_datapoints_s50.SecToIcu./3600) ;
mean_predTime_h_s50 = mean(detected_datapoints_s50.SecToIcu./3600) ;
clear detected_datapoints_s50


%%


detected_datapoints_s90 = sepsis_datapoints(sepsis_datapoints.Scores>=th_s90,:) ;
detected_datapoints_s90 = detected_datapoints_s90( detected_datapoints_s90.SecToIcu<=7*24*3600,:);

median_predTime_h_s90 = median(detected_datapoints_s90.SecToIcu./3600) ;
mean_predTime_h_s90 = mean(detected_datapoints_s90.SecToIcu./3600) ;

clear detected_datapoints_s90

%%

% leipzig validation
temp_h_vec = [6 12 24 48 168 672 9999999];
temp_h_vec_2 = [0 6 12 24 48 168 672] ;
for i = 1:numel(temp_h_vec)
temp_excl = data_le_val.SecToIcu./3600 < temp_h_vec_2(i) & data_le_val.Diagnosis=="Sepsis" ;
temp_label_le_val = data_le_val.SecToIcu./3600 <= temp_h_vec(i) & data_le_val.Diagnosis=="Sepsis";

[~, ~, ~,le_val_mdl_time_aucs(i)] = perfcurve(temp_label_le_val(~temp_excl), data_le_val.Scores(~temp_excl), 1);
n_auc_analysis_le_val(i) = sum(temp_label_le_val(~temp_excl)) ;
end
clear temp_label_le_val


% mimic
%temp_h_vec = [6 12 24 48 72 9999999];
%temp_h_vec_2 = [0 6 12 24 48 72 ] ;
for i = 1:numel(temp_h_vec)
temp_excl = data_mimic.SecToIcu./3600 < temp_h_vec_2(i) & data_mimic.Diagnosis=="Sepsis" ;
temp_label_mimic = data_mimic.SecToIcu <= temp_h_vec(i)*3600 & data_mimic.Diagnosis=="Sepsis";
[~, ~, ~,mimic_mdl_time_aucs(i)] = perfcurve(temp_label_mimic(~temp_excl), data_mimic.Scores(~temp_excl), 1);
n_auc_analysis_mimic(i) = sum(temp_label_mimic(~temp_excl)) ;
end
clear temp_label_mimic

% gw
%temp_h_vec = [6 12 24 48 72 9999999];
%temp_h_vec_2 = [0 6 12 24 48 72 ] ;
for i = 1:numel(temp_h_vec)
temp_excl = data_gw.SecToIcu./3600 < temp_h_vec_2(i) & data_gw.Diagnosis=="Sepsis" ;
temp_label_gw = data_gw.SecToIcu./3600 <= temp_h_vec(i) & data_gw.Diagnosis=="Sepsis";
[~, ~, ~,gw_mdl_time_aucs(i)] = perfcurve(temp_label_gw(~temp_excl), data_gw.Scores(~temp_excl), 1);
n_auc_analysis_gw(i) = sum(temp_label_gw(~temp_excl)) ;
end
clear temp_label_gw

%%
%
close all
fig1 = figure(1);
fig1.Position = [10 10 1200 800] ;
set(0,'DefaultLineLineWidth',2.5) ;

plt_leval = plot(1:numel(temp_h_vec),flip(le_val_mdl_time_aucs), 'b' );
hold on
plt_mimic = plot(1:numel(temp_h_vec),flip(mimic_mdl_time_aucs) ,'Color',[1 0.7 0]) ;
plt_gw = plot(1:numel(temp_h_vec) ,flip(gw_mdl_time_aucs), 'k');

% y axis
ylim([0.5 1])

% x axis
xticks([1 2 3 4 5 6 7])
xticklabels(flip(["0-6h","6-12h","12-24h","1d-2d","2d-7d","7d-28d", ">28d"]) )
xlim([0.5 7.5])

%title("CBC models AUC for different labeling times ",'Interpreter','none')
xlabel("Time-window before ICU admission",'Interpreter', 'none');
ylabel("AUC",'Interpreter', 'none');
legend("UMLV dataset",...
    "MIMIC dataset", "GW dataset", 'Location', 'best')


set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)

grid on
