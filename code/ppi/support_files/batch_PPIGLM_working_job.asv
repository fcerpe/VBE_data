%-----------------------------------------------------------------------
% Job saved on 17-Aug-2023 16:31:50 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = {'/Users/cerpelloni/Desktop/GitHub/VisualBraille_data/outputs/derivatives/spm-PPI/sub-006/PPI'};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.75;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {'yourScansHere'};
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).name = 'PPI-interaction';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(1).val = [PPI.ppi];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).name = 'VWFA-BOLD';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(2).val = [PPI.Y];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(3).name = 'Psych_FW-SFW';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(3).val = [PPI.P];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(4).name = 'Block 1';
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.regress(4).val = [kron([1 0]',ones(358,1))];
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'PPI-interaction';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
