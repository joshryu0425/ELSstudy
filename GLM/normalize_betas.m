function normalize_betas(data_dir,subj)
%% directories and data
    % mrVista for loading niftis
    if ispc % assume we're in josh's local machine
        mrVista_dir     = 'Z:\users\lrborch\ELSReward\Codes\vistasoft-master';
    else % assume we're in sherlock
        mrVista_dir = '/oak/stanford/groups/iang/users/lrborch/ELSReward/Codes/vistasoft-master';
    end
    addpath(genpath(mrVista_dir))
    
    if contains(subj,'T1'), datafolder = 'T1';
    elseif contains(subj,'TK1'), datafolder = 'TK1';
    end
    
    glmlist = {'glm_nsubjSpace','glm_normSpace'};
for glmN = 1:length(glmlist)
    disp(['Normalizing ' glmlist{glmN} '....'])
    glmdir      = fullfile(data_dir,datafolder,subj,glmlist{glmN}); 
    
    outroi_dir  = fullfile(glmdir,'rois'); if ~exist(outroi_dir), mkdir(outroi_dir);,end
   
%% create a residual std file
    resfiles    = dir(fullfile(glmdir,'Res_*.nii'));
    resnii      = readFileNifti(fullfile(glmdir,resfiles(1).name));
    ressqsum    = (resnii.data).^2;
    
    for resT = 2:length(resfiles)
        resnii      = readFileNifti(fullfile(glmdir,resfiles(resT).name));
        ressqsum    = ressqsum + (resnii.data).^2;
    end
    
    resStd          = sqrt(ressqsum./length(resfiles));
    resnii.data     = resStd;
    resnii          = readFileNifti(fullfile(glmdir,resfiles(1).name));
    resnii.fname    = fullfile(glmdir,'ResSTD.nii');
    writeFileNifti(resnii)
    
%% normalize betas
% betasnr_001   - divide beta by std of res
% betaPCraw_001  - divide beta by constant regressor (mean activation level)
% load(fullfile(glmdir,'SPM.mat'))
blockbetanii        = readFileNifti(fullfile(glmdir,'beta_0018.nii'));

for betaN = 1:11
    betafile        = fullfile(glmdir,sprintf('beta_%04d.nii',betaN));
    betanii         = readFileNifti(betafile);
    
    betasnr_nii         = betanii;
    betasnr_nii.data    = (betanii.data)./resStd;
    betasnr_nii.fname   = fullfile(glmdir,sprintf('betaSNR_%04d.nii',betaN));
    writeFileNifti(betasnr_nii);
    
    betaPCraw_nii        = betanii;
    betaPCraw_nii.data   = (betanii.data)./(blockbetanii.data);
    betaPCraw_nii.fname  = fullfile(glmdir,sprintf('betaPCraw_%04d.nii',betaN));
    writeFileNifti(betaPCraw_nii);
end
end

end