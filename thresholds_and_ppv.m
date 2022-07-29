%%

[meanMdl_rocx, meanMdl_rocy, meanMdl_th, meanMdl_auc] = perfcurve(data_le_val.Label, data_le_val.Scores, "Sepsis") ;

prev_le = mean(data_le.Label=="Sepsis") ;
prev_le_val = mean(data_le_val.Label=="Sepsis") ;

% find 90% sens threshold
idx_th_s50 = find(meanMdl_rocy >= 0.5 ) ;
% find 50% sens threshold
idx_th_s90 = find(meanMdl_rocy >= 0.9 ) ;

idx_th_s50 = idx_th_s50(1) ;
idx_th_s90 = idx_th_s90(1) ;

th_s50 = meanMdl_th(idx_th_s50) ;
th_s90 = meanMdl_th(idx_th_s90) ;

spec_s50 = 1-meanMdl_rocx(idx_th_s50) ;
sens_s50 = meanMdl_rocy(idx_th_s50) ;

spec_s90 = 1-meanMdl_rocx(idx_th_s90) ;
sens_s90 = meanMdl_rocy(idx_th_s90) ;

% Positive predictive value
ppv_s90 = calc_ppv(sens_s90, spec_s90, prev_le_val) ;
ppv_s50 = calc_ppv(sens_s50, spec_s50, prev_le_val) ;

clear idx_th_spec ; clear idx_th_sens ;
%%
disp("The 90% sens threshold is:")
th_s90
disp("Then the spec is:")
spec_s90

disp("The 50% sens threshold is:")
th_s50
disp("Then the sens is:")
sens_s50
disp("The spec is:")
spec_s50


%%

do_plots = false;
if do_plots
lim_x = 0.1 ;
lim_y = 0.7 ;
prev = linspace(0,lim_x,1001) ;

ppvs_s90 = calc_ppv(sens_s90, spec_s90, prev) ;
ppvs_s50 = calc_ppv(sens_s50, spec_s50, prev) ;

figure(2)
hold on
grid on
%grid minor
plt_thsens = plot(prev, ppvs_s90) ;
plt_thspec = plot(prev, ppvs_s50) ;

title("Positive predictive value for different prevalences ",'Interpreter','none')
xlabel("Prevalence (%)",'Interpreter', 'none');
ylabel("Positive predictive value (%)",'Interpreter', 'none');

set(gca, 'FontSize', 24)
set(gca, 'LineWidth', 2)

set(gca,'FontSize',24)
[~, hobj, ~, ~]= legend(["90% sensitivity threshold" "50% sensitivity threshold"],...
    'Location', 'northwest') ;
set(plt_thsens, 'LineWidth', 2)
set(plt_thspec, 'LineWidth', 2)
xticks(0:0.02:lim_x)
yticks(0:0.1:lim_y)
yticklabels(0:10:lim_y*100)
hl = findobj(hobj,'type','line');
set(hl,'LineWidth',2);
xticklabels(0:2:10)
ylim([0 lim_y])
hold off


clear ppvs_s50; clear ppvs_s90 ;
end