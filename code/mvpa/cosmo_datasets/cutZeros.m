elements = dir('data_*');
for i = 1:size(elements,1) 
    this = load_nii(elements(i).name);
    this.img(this.img == 0) = NaN;
    save_nii(this, elements(i).name);
end
