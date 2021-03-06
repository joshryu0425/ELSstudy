% generateContrasts
% 2019/09/30
% subjID = '009-T1';

function generateContrasts(subjID)

disp([subjID ' running generate Contrasts'])

basedir             = setbasepath;

if contains(subjID,'T1'), folder = 'T1';
elseif contains(subjID,'TK1'), folder = 'TK1';
end

mrVista_dir = fullfile(basedir,'Codes','vistasoft-master');addpath(genpath(mrVista_dir));
spmdir      = fullfile(basedir,'Codes','spm12');addpath(spmdir);

%% define betas and contrasts
disp([subjID ' defining contrasts'])
betaNorms       = {'beta','betaSNR', 'betaPCraw'};

% 8 contrasts
contrastNames   = {'antGain - neut', 'antLoss - neut', 'antGain - antLoss', ...
    'gain - neut', 'loss - neut', 'gain - loss', ...
    'gain - antGain', 'loss - antLoss'};

% antGain - neut
contrastVectors{1} = zeros(1,11); contrastVectors{1}(1) = 1;  contrastVectors{1}(3) = -1; 
% antLoss - neut
contrastVectors{2} = zeros(1,11); contrastVectors{2}(2) = 1;  contrastVectors{2}(3) = -1;
% antGain - antLoss
contrastVectors{3} = zeros(1,11); contrastVectors{3}(1) = 1;  contrastVectors{3}(2) = -1; 
% gain - neut
contrastVectors{4} = zeros(1,11); contrastVectors{4}(4) = 1;  contrastVectors{4}(6) = -1;
% loss - neut
contrastVectors{5} = zeros(1,11); contrastVectors{5}(5) = 1;  contrastVectors{5}(6) = -1; 
% gain - loss
contrastVectors{6} = zeros(1,11); contrastVectors{6}(4) = 1;  contrastVectors{6}(5) = -1; 
% gain - antGain
contrastVectors{7} = zeros(1,11); contrastVectors{7}(4) = 1;  contrastVectors{7}(1) = -1; 
% loss - antLoss
contrastVectors{8} = zeros(1,11); contrastVectors{8}(5) = 1;  contrastVectors{8}(2) = -1; 

%% initialize and run spm
disp([subjID ' running spm'])
spm('defaults', 'fmri')
spm_jobman('initcfg')
spm_get_defaults('cmdline',true)

glmlist = {'glm_nsubjSpace','glm_normSpace'};
for glmN = 1:length(glmlist)
    disp([subjID ' calculating contrasts for ' glmlist{glmN}])

    glmdir      = fullfile(basedir,'Data',folder,subjID,glmlist{glmN}); 
    spmmat      = fullfile(glmdir,'SPM.mat');
    contrastdir = fullfile(glmdir,'contrasts'); 
    if ~exist(contrastdir,'dir'),mkdir(contrastdir);,end
    
    load(fullfile(glmdir,'SPM.mat'),'SPM')
    varNames = {SPM.Vbeta.descrip};varNames = varNames(1:11);
    takeoutprefix = @(x)(x(29:end-6));
    varNames = cellfun(takeoutprefix, varNames, 'UniformOutput',false);

    matlabbatch{1}.spm.stats.con.spmmat = {spmmat};   
    for contrastN = 1:8
        matlabbatch{1}.spm.stats.con.consess{contrastN}.tcon.name = contrastNames{contrastN};
        matlabbatch{1}.spm.stats.con.consess{contrastN}.tcon.weights = contrastVectors{contrastN};
        matlabbatch{1}.spm.stats.con.consess{contrastN}.tcon.sessrep = 'none';
    end
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run',matlabbatch);
    cd(glmdir);
    save(['matlabbatch' glmlist{glmN} '_constratDef.mat'],'matlabbatch')
    
    % copy the raw beta contrasts
    for contrastN = 1:8
        fromfile    = fullfile(glmdir,sprintf('con_%04d.nii',contrastN));
        tofile      = fullfile(contrastdir,['raw_' contrastNames{contrastN} '.nii']);
        copyfile(fromfile,tofile)
    end
    
    % make non-raw beta contrasts
    for betaTypeN = 1:3 % do raw Beta again to check.
    for contrastN = 1:8
        betaN_pos = find(contrastVectors{contrastN} == 1);
        betaN_neg = find(contrastVectors{contrastN} == -1);
        
        betafile_pos        = fullfile(glmdir,sprintf([betaNorms{betaTypeN} '_%04d.nii'],betaN_pos));
        betanii_pos         = readFileNifti(betafile_pos);
        betafile_neg        = fullfile(glmdir,sprintf([betaNorms{betaTypeN} '_%04d.nii'],betaN_neg));
        betanii_neg         = readFileNifti(betafile_neg);

        contrast_nii         = betanii_pos;
        contrast_nii.data    = (betanii_pos.data) - (betanii_neg.data);
        contrast_nii.fname   = ...
            fullfile(contrastdir,[betaNorms{betaTypeN} '_' contrastNames{contrastN} '.nii']);
        writeFileNifti(contrast_nii);
    end
    end
end

disp([subjID ' contrasts generated'])
end