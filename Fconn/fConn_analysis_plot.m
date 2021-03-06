% addpath(genpath('/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis'));
% data_dir = '/oak/stanford/groups/iang/users/lrborch/204b/Data/';
% roilist_file = '/oak/stanford/groups/iang/users/lrborch/204b/Codes/analysis/aseg+aparc_selected.mat';
% subj         = '006-T1'; 
% analysis_folder = ['Analysis_190520'];

function fConn_analysis_plot(data_dir,subj,analysis_folder)    
    roitoplot_names = {'Left-Hippocampus';'Right-Hippocampus';'Left-Amygdala';'Right-Amygdala';...
        'Left-Accumbens-area'; 'Right-Accumbens-area';'ctx-lh-insula';'ctx-rh-insula'};
    roitoplot_idx  = [8,18,9,19,10,20,57,93];
    
    GLMout_dir = fullfile(data_dir,subj,'GLManalysis',analysis_folder);
    fconndir = fullfile(GLMout_dir,'fconn'); if ~exist(fconndir), mkdir(fconndir); end
    load(fullfile(GLMout_dir,'fconn.mat'))
    
    disp('plotting error connectivities...')
    plot_connMat(corr_errs.pearson,roiList,1:length(roiList),...
        fullfile(fconndir,'errs_pearson_full')) 
    plot_connMat(corr_errs.td,roiList,1:length(roiList),...
        fullfile(fconndir,'errs_td_full'))
    plot_connMat(corr_errs.pearson,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'errs_pearson')) 
    plot_connMat(corr_errs.td,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'errs_td'))
    
    disp('plotting signal connectivities...')
    plot_connMat(corr_sign.pearson,roiList,1:length(roiList),...
        fullfile(fconndir,'sign_pearson_full')) 
    plot_connMat(corr_sign.td,roiList,1:length(roiList),...
        fullfile(fconndir,'sign_td_full'))
    plot_connMat(corr_sign.pearson,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'sign_pearson'))
    plot_connMat(corr_sign.td,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'sign_td'))
    
    disp('plotting tc connectivities...')
    plot_connMat(corr_tc.pearson,roiList,1:length(roiList),...
        fullfile(fconndir,'tc_pearson_full')) 
    plot_connMat(corr_tc.td,roiList,1:length(roiList),...
        fullfile(fconndir,'tc_td_full'))
    plot_connMat(corr_tc.pearson,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'tc_pearson'))
    plot_connMat(corr_tc.td,roitoplot_names,roitoplot_idx,...
        fullfile(fconndir,'tc_td'))
    
     disp('done plotting connecitivities...')
end

function plot_connMat(mat,roitoplot_names,roitoplot_idx,savename) 
    validx = find(~isnan(mat(1,roitoplot_idx)));
    roitoplot_names = roitoplot_names(validx);
    roitoplot_idx   = roitoplot_idx(validx);
    
    connMat = nan(length(roitoplot_idx));
    for idx1 = 1:length(roitoplot_idx)
        connMat(idx1,idx1) = mat(roitoplot_idx(idx1),roitoplot_idx(idx1));
        for idx2 = (idx1+1):length(roitoplot_idx)
            connMat(idx1,idx2) = mat(roitoplot_idx(idx1),roitoplot_idx(idx2));
        end
    end
    fid = figure('Position',[183 59 1676 919]);
    imagesc(connMat);colorbar;
    set(gca, 'XTick', 1:length(roitoplot_idx), 'XTickLabel', roitoplot_names);
    xtickangle(75)
    set(gca, 'YTick', 1:length(roitoplot_idx), 'YTickLabel', roitoplot_names);
    saveas(fid,[savename '.fig']);
    saveas(fid,[savename '.png']);
end