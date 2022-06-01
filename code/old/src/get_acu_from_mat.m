a = [];
for i = 1569:1624
    a = vertcat(a, accu(i).accuracy);
end
s3_locR_tmaps = a;

%%

a = [];
for i = 1:240
    a = vertcat(a, mvpa.raw.sub002.locL.t_maps.raw(i).accuracy);
end
s2_locL_tmaps = a;

a = [];
for i = 1:240
    a = vertcat(a, mvpa.raw.sub002.pfsL.t_maps.raw(i).accuracy);
end
s2_pfsL_tmaps = a;

a = [];
for i = 1:56
    a = vertcat(a, mvpa.raw.sub002.locR.t_maps.raw(i).accuracy);
end
s2_locR_tmaps = a;

a = [];
for i = 1:240
    a = vertcat(a, mvpa.raw.sub002.pfsR.t_maps.raw(i).accuracy);
end
s2_pfsR_tmaps = a;

%%

s1_beta = horzcat(s1_vwfa_beta, s1_locL_beta, s1_pfsL_beta, s1_locR_beta, s1_pfsR_beta);
s2_beta = horzcat(s2_vwfa_beta, s2_locL_beta, s2_pfsL_beta, s2_locR_beta, s2_pfsR_beta);
s3_beta = horzcat(s3_vwfa_beta, s3_locL_beta, s3_pfsL_beta, s3_locR_beta, s3_pfsR_beta);

s1_tmaps = horzcat(s1_vwfa_tmaps, s1_locL_tmaps, s1_pfsL_tmaps, s1_locR_tmaps, s1_pfsR_tmaps);
s2_tmaps = horzcat(s2_vwfa_tmaps, s2_locL_tmaps, s2_pfsL_tmaps, s2_locR_tmaps, s2_pfsR_tmaps);
s3_tmaps = horzcat(s3_vwfa_tmaps, s3_locL_tmaps, s3_pfsL_tmaps, s3_locR_tmaps, s3_pfsR_tmaps);
