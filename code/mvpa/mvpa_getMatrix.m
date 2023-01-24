function mat = mvpa_getMatrix(chunk, triangle)
% Place every accuracy from struct to NxN matrix, N is nuber of codnitions we decoded
% It's only 12 data points, no need to loop
%
% TO-DO: 
% - make it flexible to new matrix sizes ->  form 2 to ncond^2, it's (x, 8-1 * iteraition +x)

posistionsToFill = [2 9; 3 17; 4 25; 11 18; 12 26; 20 27; 38 45; 39 53; 40 61; 47 54; 48 62; 56 63];
mvpaMat = nan(8);

if triangle
    for iMat = 1:size(posistionsToFill,1) % for each one of our positions in the matrix
    
        % get this accuracy and put it in the matrix place
        thisAccu = chunk(iMat).accuracy;
        mvpaMat(posistionsToFill(iMat,1)) = thisAccu;
    end
else
    for iMat = 1:size(posistionsToFill,1) % for each one of our positions in the matrix
    
        % get this accuracy and put it in the matrix place
        thisAccu = chunk(iMat).accuracy;
        mvpaMat(posistionsToFill(iMat,:)) = thisAccu;
    end
end

mat = mvpaMat;

end