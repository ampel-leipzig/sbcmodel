

dataset = readtable('../Data/20220530-sbcdata-greifswald-leipzig-mimic.csv') ;

dataset.Diagnosis = string(dataset.Diagnosis) ;
dataset.Center = string(dataset.Center) ;
dataset.Sender = string(dataset.Sender) ;
dataset.TargetIcu = string(dataset.TargetIcu) ;

dataset.Excluded = string(dataset.Excluded)=="TRUE" ;


% add label variable
dataset.Label = dataset.Diagnosis ;
%%
time_window1 = 0;
time_window2 = 6;

%% filter data

% exclude icu patients
excl = (dataset.SecToIcu < 0 ) ;
excl = excl | contains(dataset.Sender, "ICU") ;
excl_icu = contains(dataset.Sender, "ICU") ;

% include patients before time window (make them look like control cases)
dataset.Label(dataset.SecToIcu>time_window2*3600) = "Control" ;

% enforce time window
excl = excl | ~(dataset.Label=="Control" | (dataset.SecToIcu >= time_window1*3600 & dataset.SecToIcu <= time_window2*3600)) ;
excl_timewindow = ~(dataset.Label=="Control" | (dataset.SecToIcu >= time_window1*3600 & dataset.SecToIcu <= time_window2*3600)) ;

% exclude patients not admitted to medical icu
excl = excl | (dataset.Diagnosis=="Sepsis" & ~contains(dataset.TargetIcu, "MICU")) ;
excl_not_micu = (dataset.Diagnosis=="Sepsis" & ~contains(dataset.TargetIcu, "MICU")) ;

% remove incomplete blood counts (any of the variables is NaN)
excl = excl | any(isnan(table2array(dataset(:,{'HGB','MCV','PLT','RBC','WBC'}))),2) ;
excl_incomplete = any(isnan(table2array(dataset(:,{'HGB','MCV','PLT','RBC','WBC'}))),2) ;

% exclude SIRS patients
excl = excl | contains(dataset.Label, "SIRS") ;
excl_sirs = contains(dataset.Label, "SIRS") ;

excl = excl |  dataset.Episode~=1 ;
excl_episode = dataset.Episode~=1 ;


dataset.HGB(isnan(dataset.HGB))= -1 ;
dataset.Index = (1:numel(dataset.Id))' ;

% introduce a numeric variable for 'Center':
dataset.Center_numerical = int32(dataset.Center=="Leipzig") ;
dataset.Center_numerical(dataset.Center=="Greifswald") = 2 ;
dataset.Center_numerical(dataset.Center=="MIMIC-IV") = 3 ;

%Find the unique combinations of id and time in the table. Return the index vector ic.
[un_id_time_center,un_idx,ic] = unique(dataset(:,{'Id','Time','Center_numerical'}),'rows');
%Count the number of times each combination appears. Specify ic as the first input to accumarray and 1 as the second input so that the function counts repeated subscripts in ic. Summarize the results.
counts_id_time = accumarray(ic,1);
% Concatenate the unique ID/Time combinations and their respective count of
% appearance to a table
value_counts = [table(dataset.Index(un_idx)) un_id_time_center, table(counts_id_time)] ;
% join this table with the actual dataset table to get the counts for all
% appearances of each unique combination
temp_tbl = innerjoin(value_counts, dataset) ;
temp_tbl = sortrows(temp_tbl,'Var1','ascend');
% exclude all duplicate datapoints ( all datapoints that dont have a unique
% id+time combination)
excl = excl | (temp_tbl.counts_id_time > 1) ;
excl_doubled = (temp_tbl.counts_id_time > 1) ;
clear temp_tbl ; clear counts_id_time ; clear value_counts ; clear un_id_time ;
clear ic ;
dataset.HGB(dataset.HGB==-1) = NaN ;
%dataset.Center_numerical = [] ;
excl = excl | dataset.Diagnosis=="SIRS" ;

%dataset = dataset( ~excl , :) ;
dataset.Excl_matlab = excl ;
dataset.excl_icu = excl_icu ;
dataset.excl_timewindow = excl_timewindow ;
dataset.excl_not_micu = excl_not_micu ;
dataset.excl_incomplete = excl_incomplete ;
dataset.excl_sirs = excl_sirs ;
dataset.excl_episode = excl_episode ;
dataset.excl_doubled = excl_doubled ;

dataset = removevars(dataset, {'Center_numerical','Index'}) ;

% seperate datasets
data_le_val = dataset(dataset.Center=="Leipzig" & dataset.Set=="Validation" & ~dataset.Excl_matlab,:) ;
data_le = dataset(dataset.Center=="Leipzig" & dataset.Set=="Training" & ~dataset.Excl_matlab,:) ;
data_gw = dataset(dataset.Center=="Greifswald" & ~dataset.Excl_matlab,:) ;
data_mimic = dataset(dataset.Center=="MIMIC-IV" & ~dataset.Excl_matlab,:) ;


