function mat = mvpa_evrel_getMatrix(chunk)
% Place every accuracy from struct to NxN matrix, N is nuber of codnitions we decoded
% It's only 12 data points, no need to loop
%
% TO-DO: 
% - make it flexible to new matrix sizes ->  form 2 to ncond^2, it's (x, nCond-1 * iteraition +x)  

posistionsToFill = [2 17; 3 33; 4 49; 5 65; 6 81; 7 97; 8 113; 9 129; 10 145; 11 161; 12 177; 13 193; 14 209; 15 225; 16 241; 
                    19 34; 20 50; 21 66; 22 82; 23 98; 24 114; 25 130; 26 146; 27 162; 28 178; 29 194; 30 210; 31 226; 32 242;
                    36 51; 37 67; 38 83; 39 99; 40 115; 41 131; 42 147; 43 163; 44 179; 45 195; 46 211; 47 227; 48 243;
                    53 68; 54 84; 55 100; 56 116; 57 132; 58 148; 59 164; 60 180; 61 196; 62 212; 63 228; 64 244; 
                    70 85; 71 101; 72 117; 73 133; 74 149; 75 165; 76 181; 77 197; 78 213; 79 229; 80 245;
                    87 102; 88 118; 89 134; 90 150; 91 166; 92 182; 93 198; 94 214; 95 230; 96 246;
                    104 119; 105 135; 106 151; 107 167; 108 183; 109 199; 110 215; 111 231; 112 247;
                    121 136; 122 152; 123 168; 124 184; 125 200; 126 216; 127 232; 128 248;
                    138 153; 139 169; 140 185; 141 201; 142 217; 143 233; 144 249;
                    155 170; 156 186; 157 202; 158 218; 159 234; 160 250; 
                    172 187; 173 203; 174 219; 175 235; 176 251;
                    189 204; 190 220; 191 236; 192 252; 
                    206 221; 207 237; 208 253;
                    223 238; 224 254; 
                    240 255];
mvpaMat = nan(16);

for iMat = 1:size(posistionsToFill,1) % for each one of our positions in the matrix

    % get this accuracy and put it in the matrix place
    thisAccu = chunk(iMat).accuracy;
    mvpaMat(posistionsToFill(iMat,:)) = thisAccu;
end

mat = mvpaMat;

end