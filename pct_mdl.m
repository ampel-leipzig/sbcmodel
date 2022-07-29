
data_le_pct = data_le(~isnan(data_le.PCT),:) ;
data_le_val_pct = data_le_val(~isnan(data_le_val.PCT),:) ;
data_gw_pct = data_gw(~isnan(data_gw.PCT),:) ;

max_splits_pct = 10 ;
% using the usual label variable train new models with cbc and pct
[pct_mdl_auc, pct_mdl_perf, pct_mdls] = RUSBoost_kfold(data_le_pct(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT','PCT'}),data_le_pct.Label, ntrees, max_splits_pct, learn_rate ) ;


%%

treeTemp = templateTree('MaxNumSplits', max_splits_pct);
% train full pct model
pct_mdl_full = fitcensemble(data_le_pct(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT','PCT'}),data_le_pct.Label,'Method','RUSBoost', ...
    'NumLearningCycles',ntrees,'Learners',treeTemp, ...
    'LearnRate', learn_rate ,'ScoreTransform','none', ...
    'nprint',100);

% get scores for validation
[~, gw_pct_mdl_scores] = pct_mdl_full.predict(data_gw_pct(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT','PCT'})) ;
[~, le_val_pct_mdl_scores] = pct_mdl_full.predict(data_le_val_pct(:,{'Age','Sex','HGB','RBC','WBC','MCV','PLT','PCT'})) ;

le_val_pct_mdl_scores = le_val_pct_mdl_scores(:,2) ;
gw_pct_mdl_scores = gw_pct_mdl_scores(:,2) ;


% overwrite .Scores with the scores from the newly trained pct model(s)
for i=1:5
   data_le_pct.Scores(pct_mdl_perf{i}.idx_test) = pct_mdl_perf{i}.scores ;
end
data_gw_pct.Scores = gw_pct_mdl_scores ;
data_le_val_pct.Scores = le_val_pct_mdl_scores ;
%% evaluate pct and pct model

[~,~,~,le_pct_auc] = perfcurve(data_le_pct.Label, data_le_pct.PCT, 'Sepsis') ;
[~,~,~,le_pctmdl_auc] = perfcurve(data_le_pct.Label, data_le_pct.Scores, 'Sepsis') ;
data_le_pct.Scores = 1./(1+exp(-median(data_le_pct.Scores)*(data_le_pct.Scores-median(data_le_pct.Scores)))) ;
temp_le_pctmdl_label = data_le_pct.Label=="Sepsis" ;
[~,le_pctmdl_auc_ci] = auc([temp_le_pctmdl_label data_le_pct.Scores],0.05, 'mann-whitney') ;
[~,le_pct_auc_ci] = auc([temp_le_pctmdl_label data_le_pct.PCT], 0.05, 'mann-whitney') ;
clear temp_le_pct_mdl_label

[le_val_pct_rocx,le_val_pct_rocy,~,le_val_pct_auc] = perfcurve(data_le_val_pct.Label, data_le_val_pct.PCT, 'Sepsis') ;
[le_val_pctmdl_rocx,le_val_pctmdl_rocy,~,le_val_pctmdl_auc] = perfcurve(data_le_val_pct.Label, data_le_val_pct.Scores, 'Sepsis') ;
data_le_val_pct.Scores = 1./(1+exp(-median(data_le_val_pct.Scores)*(data_le_val_pct.Scores-median(data_le_val_pct.Scores)))) ;
temp_le_val_pctmdl_label = data_le_val_pct.Label=="Sepsis" ;
[~,le_val_pctmdl_auc_ci] = auc([temp_le_val_pctmdl_label data_le_val_pct.Scores],0.05, 'mann-whitney') ;
[~,le_val_pct_auc_ci] = auc([temp_le_val_pctmdl_label data_le_val_pct.PCT],0.05, 'mann-whitney') ;
clear temp_le_val_pct_mdl_label

[gw_pct_rocx,gw_pct_rocy,~,gw_pct_auc] = perfcurve(data_gw_pct.Label, data_gw_pct.PCT, 'Sepsis') ;
[gw_pctmdl_rocx,gw_pctmdl_rocy,~,gw_pctmdl_auc] = perfcurve(data_gw_pct.Label, data_gw_pct.Scores, 'Sepsis') ;
data_gw_pct.Scores = 1./(1+exp(-median(data_gw_pct.Scores)*(data_gw_pct.Scores-median(data_gw_pct.Scores)))) ;
temp_gw_pctmdl_label = data_gw_pct.Label=="Sepsis" ;
[~,gw_pctmdl_auc_ci] = auc([temp_gw_pctmdl_label data_gw_pct.Scores],0.05, 'mann-whitney') ;
[~,gw_pct_auc_ci] = auc([temp_gw_pctmdl_label data_gw_pct.PCT],0.05, 'mann-whitney') ;
clear temp_gw_pct_mdl_label

%%
if 0
temp_h_vec = [6 12 24 36 9999999];
for i = 1:numel(temp_h_vec)
    
temp_label_le_val = data_le_val_pct.SecToIcu <= temp_h_vec(i)*3600 & data_le_val_pct.Diagnosis=="Sepsis";
[~, ~, ~,le_val_pct_aucs(i)] = perfcurve(temp_label_le_val, data_le_val_pct.PCT, 1);
[~, ~, ~,le_val_pctbc_aucs(i)] = perfcurve(temp_label_le_val, data_le_val_pct.Scores, 1);

temp_label_le = data_le_pct.SecToIcu <= temp_h_vec(i)*3600 & data_le_pct.Diagnosis=="Sepsis";
[~, ~, ~,le_pct_aucs(i)] = perfcurve(temp_label_le, data_le_pct.PCT, 1);
[~, ~, ~,le_pctbc_aucs(i)] = perfcurve(temp_label_le, data_le_pct.Scores, 1);

temp_label_gw = data_gw_pct.SecToIcu <= temp_h_vec(i)*3600 & data_gw_pct.Diagnosis=="Sepsis";
[~, ~, ~,gw_pct_aucs(i)] = perfcurve(temp_label_gw, data_gw_pct.PCT, 1);
[~, ~, ~,gw_pctbc_aucs(i)] = perfcurve(temp_label_gw, data_gw_pct.Scores, 1);

end
end
%%
if 0
plt1 = plot(le_pctbc_aucs,'x-'); hold on
plt2 = plot(le_val_pctbc_aucs, 'o-');
plt3 = plot(gw_pctbc_aucs, '^-');
xlim([0 6])
ylim([0.6 1])
legend('LeT (14-19) cbc/pct model', 'LeV (20/21) cbc/pct model', 'Greifswald cbc/pct model')
grid on
xticks([1 2 3 4 5])
xticklabels(["0-6h" "0-12h" "0-24h" "0-36h" "all"])

title("AUCs for 3 datasets and different prediction times",'Interpreter','none')
xlabel("Validation Label",'Interpreter', 'none');
ylabel("AUCs",'Interpreter', 'none');

set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)
set(plt1, 'LineWidth', 2.5)
set(plt2, 'LineWidth', 2.5)
set(plt3, 'LineWidth', 2.5)
hold off



plt1 = plot(le_val_pct_aucs,'x-'); hold on
plt2 = plot(le_val_pctbc_aucs,'o-');

xlim([0 6])
ylim([0.6 1])
legend('PCT LeVal (20/21)', 'BCmdl LeVal (20/21)')
grid on
xticks([1 2 3 4 5])
xticklabels(["0-6h" "0-12h" "0-24h" "0-36h" "all"])

title("AUCs for 3 datasets and different prediction times",'Interpreter','none')
xlabel("Validation Label",'Interpreter', 'none');
ylabel("AUCs",'Interpreter', 'none');


set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)
set(plt1, 'LineWidth', 2.5)
set(plt2, 'LineWidth', 2.5)
hold off


close all
fig1 = figure(1) ;
fig1.Position = [10 10 1000 800] ;
set(0,'DefaultLineLineWidth',2.5) ;
set(0, 'DefaultLineMarkerSize', 12) ;

plt1 = plot(le_pct_aucs,'x-'); hold on
plt2 = plot(le_pctbc_aucs,'o-');

xlim([0 6])
ylim([0.6 1])
legend('PCT LeT (14-19)', 'CBC/PCT model LeT (14-19)')
grid on
xticks([1 2 3 4 5])
xticklabels(["0-6h" "0-12h" "0-24h" "0-36h" "all"])

title("AUCs for 3 datasets and different prediction times",'Interpreter','none')
xlabel("Validation Label",'Interpreter', 'none');
ylabel("AUCs",'Interpreter', 'none');

set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)
hold off


close all
fig1 = figure(1) ;
fig1.Position = [10 10 1000 800] ;
set(0,'DefaultLineLineWidth',2.5) ;
set(0, 'DefaultLineMarkerSize', 12) ;
plt1 = plot(gw_pct_aucs,'x-'); hold on
plt2 = plot(gw_pctbc_aucs,'o-');

xlim([0 6])
ylim([0.6 1])
legend('PCT GW (15-20)', 'CBC/PCT model GW (15-20)')
grid on
xticks([1 2 3 4 5])
xticklabels(["0-6h" "0-12h" "0-24h" "0-36h" "all"])

title("AUCs for 3 datasets and different prediction times",'Interpreter','none')
xlabel("Validation Label",'Interpreter', 'none');
ylabel("AUCs",'Interpreter', 'none');

set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)
hold off


close all
fig1 = figure(1) ;
fig1.Position = [10 10 1000 800] ;
set(0,'DefaultLineLineWidth',2.5) ;
set(0, 'DefaultLineMarkerSize', 12) ;
hold on ;
plt_le_bcmdl = plot(le_pctbc_aucs,'x-'); 
plt_leval_bcmdl = plot(le_val_pctbc_aucs, 'o-');
plt_gw_bcmdl = plot(gw_pctbc_aucs, '^-');
plt_le_pct = plot(le_pct_aucs,'x-');
plt_leval_pct = plot(le_val_pct_aucs, 'o-');
plt_gw_pct = plot(gw_pct_aucs, '-^');
xlim([0 6])
ylim([0.6 1])
legend('CBC-PCT model LeT (14-19) ', 'CBC-PCT model LeV (20/21)', 'CBC-PCT model Greifswald',...
    'PCT LeT (14-19)', 'PCT LeV (20/21)', 'PCT Greifswald')
grid on
xticks([1 2 3 4 5])
xticklabels(["0-6h" "0-12h" "0-24h" "0-36h" "all"])

title("AUCs for 3 datasets and different prediction times",'Interpreter','none')
xlabel("Validation Label",'Interpreter', 'none');
ylabel("AUCs",'Interpreter', 'none');

set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)
%set(plt_le_bcmdl, 'LineWidth', 2.5)
%set(plt_leval_bcmdl, 'LineWidth', 2.5)
%set(plt_gw_bcmdl, 'LineWidth', 2.5)
%set(plt_le_pct, 'LineWidth', 2.5)
%set(plt_leval_pct, 'LineWidth', 2.5)
%set(plt_gw_pct, 'LineWidth', 2.5)
%plt_le_bcmdl.MarkerSize = 15 ;
fname = num2str(time_window2) + "h_mdl_all_plots.png";
fpath = fullfile('./Results', fname) ;
saveas(fig1,fpath , 'png');
hold off

mean(pct_mdl_auc)-le_pct_aucs(1)+le_val_pctbc_aucs(1)-le_val_pct_aucs(1)+gw_pctbc_aucs(1)-gw_pct_aucs(1)
le_val_pctbc_aucs(1)-le_val_pct_aucs(1)
end