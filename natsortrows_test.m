function natsortrows_test()
% Test function for NATSORTROWS.
%
% (c) 2014-2025 Stephen Cobeldick
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
% * natsortrows.m & test_nso_fun.m from <www.mathworks.com/matlabcentral/fileexchange/47433>
%
% See also NATSORTROWS TEST_NSO_FUN ARBSORT_TEST NATSORT_TEST NATSORTFILES_TEST
obj = test_nso_fun(@natsortrows);
nsrMain(obj) % count
obj.start()
nsrMain(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortrows_test
function nsrMain(chk)
%
try categorical(0); isc=true; catch; isc=false; chk.warn('No categorical class.'); end %#ok<CTCH,WNTAG>
try cell2table({}); ist=true; catch; ist=false; chk.warn('No (time)table class.'); end %#ok<CTCH,WNTAG>
try pad(strings()); iss=true; catch; iss=false; chk.warn('No string class.'); end %#ok<CTCH,WNTAG>
%
if iss
	txf = @string;
	tbf = @array2table;
else
	txf = @cellstr;
	tbf = @cell2table;
end
%
%% Mfile Examples %%
%
chk.i(...
	txf({'A2','X';'A10','Y';'A10','X';'A1','X'})).o(...
	txf({'A1','X';'A2','X';'A10','X';'A10','Y'}))
%
Aa =                       {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
Ba =                       {'A','2','Y';'B','2','X';'B','10','X';'A','20','X';'A','100','X'};
chk.i(Aa               ).o({'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'})
chk.i(Aa, [],  'ascend').o({'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'}) % not in Mfile
chk.i(Aa, [], 'descend').o({'B','10','X';'B','2','X';'A','100','X';'A','20','X';'A','2','Y'})
chk.i(Aa, [], [2,-3]).o(Ba)
chk.i(Aa, [], [false,true,true], {'ascend','descend'}).o(Ba)
chk.i(Aa, [], {'ascend','descend'}, [false,true,true]).o(Ba) % not in Mfile
chk.i(Aa, [], {'ignore','ascend','descend'}).o(Ba)
%
if ist
	T = cell2table(Aa, 'VariableNames',{'V1','V2','V3'});
	chk.i(T, [], [2,-3]).o(T([4,1,3,5,2],:))
	chk.i(T, [], [2,-3]).o(T([4,1,3,5,2],:), [4;1;3;5;2]) % not in Mfile
	chk.i(T, [], {'V2','V3'},{'ascend','descend'}).o(T([4,1,3,5,2],:))
	chk.i(T, [], {'V2','V3'},{'ascend','descend'}).o(T([4,1,3,5,2],:), [4;1;3;5;2]) % not in Mfile
end
%
Ab =                                                   {'ABCD';'3e45';'67.8';'+Inf';'-12';'+9';'NaN'};
chk.i(Ab, '[+-]?(NaN|Inf|\d+\.?\d*([eE][+-]?\d+)?)').o({'-12';'+9';'67.8';'3e45';'+Inf';'NaN';'ABCD'})
%
%% HTML Examples %%
%
Aa = txf({'A2','X';'A10','Y';'A10','X';'A1','X'});
Ba = txf({'A1','X';'A2','X';'A10','X';'A10','Y'});
chk.i(Aa).o(Ba)
if isc
	chk.i(categorical(Aa)).o(categorical(Ba))
end
%
Ab =                     txf({'1.3','X';'1.10','X';'1.2','X'});
chk.i(Ab             ).o(txf({'1.2','X';'1.3','X';'1.10','X'}), [3;1;2])
chk.i(Ab, '\d+\.?\d*').o(txf({'1.10','X';'1.2','X';'1.3','X'}), [2;3;1])
%
Ac = txf({'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'});
Bc = txf({'A','2','Y';'B','2','X';'B','10','X';'A','20','X';'A','100','X'});
chk.i(Ac, [], [2,-3]).o(Bc, [4;1;3;5;2])
chk.i(Ac, [], [2,3], {'ascend','descend'}).o(Bc, [4;1;3;5;2])
chk.i(Ac, [], [false,true,true], {'ascend','descend'}).o(Bc, [4;1;3;5;2])
chk.i(Ac, [], {'ignore','ascend','descend'}).o(Bc, [4;1;3;5;2])
%
if ist
	T = tbf(Ac,'RowNames',{'R20','R1','R10','R2','R9'},'VariableNames',{'V1','V2','V3'});
	chk.i(T, [], 'Row'                           ).o(T([2,4,5,3,1],:), [2;4;5;3;1]) % first-dimension name
	chk.i(T, [], 'RowNames'                      ).o(T([2,4,5,3,1],:), [2;4;5;3;1])
	chk.i(T, [], {'V2','V3'},{'ascend','descend'}).o(T([4,1,3,5,2],:), [4;1;3;5;2])
	chk.i(T, [],       [2,3],{'ascend','descend'}).o(T([4,1,3,5,2],:), [4;1;3;5;2])
	chk.i(T, [],    {'ignore','ascend','descend'}).o(T([4,1,3,5,2],:), [4;1;3;5;2]) % not in HTML
end
%
Ae =                        txf({'B','X';'10','X';'1','X';'A','X';'2','X'});
chk.i(Ae, [],  'descend').o(txf({'B','X';'A','X';'10','X';'2','X';'1','X'}), [1;4;2;5;3])
chk.i(Ae, [], 'char<num').o(txf({'A','X';'B','X';'1','X';'2','X';'10','X'}), [4;1;3;5;2])
chk.i(Ae).o(@i, @i, {{'B';10;1;'A';2},{'X';'X';'X';'X';'X'}}) % not in HTML
%
Df = {{'abc',2,'xyz',[];'abc',10,'xy',99;'abc',2,'xyz',[];'abc',1,'xyz',[]},{'Y';'X';'X';'X'}};
Af =        txf({'abc2xyz','Y';'abc10xy99','X';'abc2xyz','X';'abc1xyz','X'});
chk.i(Af).o(txf({'abc1xyz','X';'abc2xyz','X';'abc2xyz','Y';'abc10xy99','X'}), [4;3;1;2])
chk.i(Af).o(@i, [4;3;1;2], Df) % not in HTML
chk.i(Af).o(@i, @i, Df)
%
Ag =                     txf({'v10.2','b';'v2.5','b';'v2.40','a';'v1.9','b'});
chk.i(Ag             ).o(txf({'v1.9','b';'v2.5','b';'v2.40','a';'v10.2','b'}), [4;2;3;1])
chk.i(Ag, '\d+\.?\d*').o(txf({'v1.9','b';'v2.40','a';'v2.5','b';'v10.2','b'}), [4;3;2;1])
chk.i(Ag             ).o(@i, [4;2;3;1], {{'v',10,'.',2;'v',2,'.',5;'v',2,'.',40;'v',1,'.',9},{'b';'b';'a';'b'}}) % not in HTML
chk.i(Ag, '\d+\.?\d*').o(@i, [4;3;2;1], {{'v',10.2;'v',2.5;'v',2.4;'v',1.9},{'b';'b';'a';'b'}}) % not in HTML
%
Ah =                    txf({'1,3'; '1,10'; '1,2'});
chk.i(Ah, '\d+,?\d*').o(txf({'1,10'; '1,2'; '1,3'}))
chk.i(Ah, '\d+,?\d*').o(txf({'1,10'; '1,2'; '1,3'}), [2;3;1]) % not in HTML
chk.i(Ah, '\d+,?\d*').o(@i, [2;3;1], {{1.3;1.1;1.2}}) % not in HTML
%
%% Index Stability %%
%
rmf = @(s,r,c)repmat({s},r,c);
chk.i(rmf('',0,1)).o(rmf('',0,1), (1:0).', {cell(0,0)})
chk.i(rmf('',1,1)).o(rmf('',1,1), (1:1).', {cell(1,0)})
chk.i(rmf('',2,1)).o(rmf('',2,1), (1:2).', {cell(2,0)})
chk.i(rmf('',3,1)).o(rmf('',3,1), (1:3).', {cell(3,0)})
chk.i(rmf('',4,1)).o(rmf('',4,1), (1:4).', {cell(4,0)})
chk.i(rmf('',5,1)).o(rmf('',5,1), (1:5).', {cell(5,0)})
chk.i(rmf('',6,1)).o(rmf('',6,1), (1:6).', {cell(6,0)})
chk.i(rmf('',7,1)).o(rmf('',7,1), (1:7).', {cell(7,0)})
chk.i(rmf('',8,1)).o(rmf('',8,1), (1:8).', {cell(8,0)})
chk.i(rmf('',9,1)).o(rmf('',9,1), (1:9).', {cell(9,0)})
chk.i(rmf('',0,1), [],  'ascend').o(rmf('',0,1), (1:0).', {cell(0,0)})
chk.i(rmf('',1,1), [],  'ascend').o(rmf('',1,1), (1:1).', {cell(1,0)})
chk.i(rmf('',2,1), [],  'ascend').o(rmf('',2,1), (1:2).', {cell(2,0)})
chk.i(rmf('',3,1), [],  'ascend').o(rmf('',3,1), (1:3).', {cell(3,0)})
chk.i(rmf('',4,1), [],  'ascend').o(rmf('',4,1), (1:4).', {cell(4,0)})
chk.i(rmf('',5,1), [],  'ascend').o(rmf('',5,1), (1:5).', {cell(5,0)})
chk.i(rmf('',6,1), [],  'ascend').o(rmf('',6,1), (1:6).', {cell(6,0)})
chk.i(rmf('',7,1), [],  'ascend').o(rmf('',7,1), (1:7).', {cell(7,0)})
chk.i(rmf('',8,1), [],  'ascend').o(rmf('',8,1), (1:8).', {cell(8,0)})
chk.i(rmf('',9,1), [],  'ascend').o(rmf('',9,1), (1:9).', {cell(9,0)})
chk.i(rmf('',0,1), [], 'descend').o(rmf('',0,1), (1:0).', {cell(0,0)})
chk.i(rmf('',1,1), [], 'descend').o(rmf('',1,1), (1:1).', {cell(1,0)})
chk.i(rmf('',2,1), [], 'descend').o(rmf('',2,1), (1:2).', {cell(2,0)})
chk.i(rmf('',3,1), [], 'descend').o(rmf('',3,1), (1:3).', {cell(3,0)})
chk.i(rmf('',4,1), [], 'descend').o(rmf('',4,1), (1:4).', {cell(4,0)})
chk.i(rmf('',5,1), [], 'descend').o(rmf('',5,1), (1:5).', {cell(5,0)})
chk.i(rmf('',6,1), [], 'descend').o(rmf('',6,1), (1:6).', {cell(6,0)})
chk.i(rmf('',7,1), [], 'descend').o(rmf('',7,1), (1:7).', {cell(7,0)})
chk.i(rmf('',8,1), [], 'descend').o(rmf('',8,1), (1:8).', {cell(8,0)})
chk.i(rmf('',9,1), [], 'descend').o(rmf('',9,1), (1:9).', {cell(9,0)})
%
U =                       {'2';'3';'2';'1';'2'};
chk.i(U, [],  'ascend').o({'1';'2';'2';'2';'3'}, [4;1;3;5;2])
chk.i(U, [], 'descend').o({'3';'2';'2';'2';'1'}, [2;1;3;5;4])
chk.i(U).o(@i, @i, {{2;3;2;1;2}})
%
V =                       {'x';'z';'y';'';'z';'';'x';'y'};
chk.i(V, [],  'ascend').o({'';'';'x';'x';'y';'y';'z';'z'},[4;6;1;7;3;8;2;5])
chk.i(V, [], 'descend').o({'z';'z';'y';'y';'x';'x';'';''},[2;5;3;8;1;7;4;6])
%
W =                       {'2x';'2z';'2y';'2';'2z';'2';'2x';'2y'};
chk.i(W, [],  'ascend').o({'2';'2';'2x';'2x';'2y';'2y';'2z';'2z'},[4;6;1;7;3;8;2;5])
chk.i(W, [], 'descend').o({'2z';'2z';'2y';'2y';'2x';'2x';'2';'2'},[2;5;3;8;1;7;4;6])
%
%% Column & Direction %%
%
inpA = {'B','2','X';'A','100','X';'B','10','X';'A','2','Y';'A','20','X'};
idaB = {'A','100','X';'A','20','X';'B','10','X';'B','2','X';'A','2','Y'};
iiiX = [1;2;3;4;5];
chk.i(inpA, [], 'ignore').o(inpA, iiiX)
chk.i(inpA, [], [-2,-3], {'ignore','ignore'}).o(inpA, iiiX)
chk.i(inpA, [], {'ignore','ignore','ignore'}).o(inpA, iiiX)
%
idaX = [2;5;3;1;4];
chk.i(inpA, [], [-2,+3]).o(idaB, idaX)
chk.i(inpA, [], [-2,-3], {'descend','ascend'}          ).o(idaB, idaX)
chk.i(inpA, [], [+2,+3], {'descend','ascend'}          ).o(idaB, idaX)
chk.i(inpA, [], {'descend','ascend'}, [+2,-3]          ).o(idaB, idaX)
chk.i(inpA, [], [false,true,true], {'descend','ascend'}).o(idaB, idaX)
chk.i(inpA, [], {'descend','ascend'}, [false,true,true]).o(idaB, idaX)
chk.i(inpA, [], {'ignore','descend','ascend'}          ).o(idaB, idaX)
%
aaiB = {'A','2','Y';'A','20','X';'A','100','X';'B','2','X';'B','10','X'};
ddiB = {'B','10','X';'B','2','X';'A','100','X';'A','20','X';'A','2','Y'};
chk.i(inpA, [],           [true,true]             ).o(aaiB)
chk.i(inpA, [], 'ascend', [true,true]             ).o(aaiB)
chk.i(inpA, [], [true,true], 'ascend'             ).o(aaiB)
chk.i(inpA, [], [true,true], {'ascend','ascend'}  ).o(aaiB)
chk.i(inpA, [], 'descend', [true,true]            ).o(ddiB)
chk.i(inpA, [], [true,true], 'descend'            ).o(ddiB)
chk.i(inpA, [], [true,true], {'descend','descend'}).o(ddiB)
chk.i(inpA, [], [+1,+2]                           ).o(aaiB)
chk.i(inpA, [], 'ascend', [+1,+2]                 ).o(aaiB)
chk.i(inpA, [], [+1,+2], 'ascend'                 ).o(aaiB)
chk.i(inpA, [], [+1,+2], {'ascend','ascend'}      ).o(aaiB)
chk.i(inpA, [], 'descend', [+1,+2]                ).o(ddiB)
chk.i(inpA, [], [+1,+2], 'descend'                ).o(ddiB)
chk.i(inpA, [], [+1,+2], {'descend','descend'}    ).o(ddiB)
%
%% SORTROWS Examples %%
%
% <https://www.mathworks.com/help/matlab/ref/double.sortrows.html>
%
n2c = @(C) cellfun(@num2str,C,'uni',0);
%
AC = n2c({95,27,95,79,67,70,69;95,7,48,95,75,3,31;95,7,48,65,74,27,95;95,7,14,3,39,4,3;76,15,42,84,65,9,43;76,97,91,93,17,82,38});
BC = n2c({76,15,42,84,65,9,43;76,97,91,93,17,82,38;95,7,14,3,39,4,3;95,7,48,65,74,27,95;95,7,48,95,75,3,31;95,27,95,79,67,70,69});
CC = n2c({95,7,48,95,75,3,31;95,7,48,65,74,27,95;95,7,14,3,39,4,3;76,15,42,84,65,9,43;95,27,95,79,67,70,69;76,97,91,93,17,82,38});
DC = n2c({76,97,91,93,17,82,38;76,15,42,84,65,9,43;95,7,14,3,39,4,3;95,7,48,95,75,3,31;95,27,95,79,67,70,69;95,7,48,65,74,27,95});
EC = n2c({95,7,48,95,75,3,31;76,97,91,93,17,82,38;76,15,42,84,65,9,43;95,27,95,79,67,70,69;95,7,48,65,74,27,95;95,7,14,3,39,4,3});
%
chk.i(AC).o(BC)
chk.i(AC, [],            2          ).o(CC)
chk.i(AC, [], [false,true]          ).o(CC) % not in help
chk.i(AC, [],                  [1,7]).o(DC)
chk.i(AC, [], [true,false(1,5),true]).o(DC) % not in help
chk.i(AC, [], -4                    ).o(EC, [2;6;5;1;3;4]) % not in help
chk.i(AC, [],  4, 'descend'         ).o(EC, [2;6;5;1;3;4])
chk.i(AC, [],                                      [false(1,3),true], 'descend').o(EC, [2;6;5;1;3;4]) % not in help
chk.i(AC, [], {'ignore','ignore','ignore','descend','ignore','ignore','ignore'}).o(EC, [2;6;5;1;3;4]) % not in help
%
if ist
	% Table (modified to char vectors with different numbers of digits but same order):
	LastName = {'Smith';'Johnson';'Williams';'Jones';'Brown'};
	Age = {'38';'243';'38';'140';'1049'};
	Height = {'1071';'269';'64';'167';'64'};
	Weight = {'1076';'363';'131';'233';'19'};
	BloodPressure = {'124','93';'109','77';'125','83';'117','75';'122','80'};
	%BloodPressure = [124,93;109,77;125,83;117,75;122,80];
	tblA = table(Age,Height,Weight,BloodPressure,'RowNames',LastName);
	%
	chk.i(tblA                                            ).o(tblA([3,1,4,2,5],:))
	chk.i(tblA,[],'RowNames'                              ).o(tblA([5,2,4,1,3],:), [5;2;4;1;3]);
	chk.i(tblA,[],{'Height','Weight'},{'ascend','descend'}).o(tblA([3,5,4,2,1],:))
end
%
%% Table Systematic One %%
%
if ist
	%
	chk.i(tblA, [], 'ignore').o(tblA)
	chk.i(tblA, [], {'ignore','ignore','ignore','ignore'}).o(tblA)
	%
	X1a = [1,3,4,2,5];
	X1d = [5,2,4,1,3];
	X2a = [3,5,4,2,1];
	X2d = [1,2,4,3,5];
	X3a = [5,3,4,2,1];
	X3d = [1,2,4,3,5];
	%
	chk.i(tblA,[], +1).o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], +2).o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], +3).o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], -1).o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[], -2).o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[], -3).o(tblA(X3d,:), X3d(:));
	%
	chk.i(tblA,[], -1,  'ascend').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], -1, 'descend').o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[], -2,  'ascend').o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], -2, 'descend').o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[], -3,  'ascend').o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], -3, 'descend').o(tblA(X3d,:), X3d(:));
	chk.i(tblA,[],  'ascend', -1).o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], 'descend', -1).o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[],  'ascend', -2).o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], 'descend', -2).o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[],  'ascend', -3).o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], 'descend', -3).o(tblA(X3d,:), X3d(:));
	%
	chk.i(tblA,[],    'Age').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], 'Height').o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], 'Weight').o(tblA(X3a,:), X3a(:));
	%
	chk.i(tblA,[],    'Age',  'ascend').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[],    'Age', 'descend').o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[], 'Height',  'ascend').o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], 'Height', 'descend').o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[], 'Weight',  'ascend').o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], 'Weight', 'descend').o(tblA(X3d,:), X3d(:));
	chk.i(tblA,[],  'ascend',    'Age').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], 'descend',    'Age').o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[],  'ascend', 'Height').o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], 'descend', 'Height').o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[],  'ascend', 'Weight').o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], 'descend', 'Weight').o(tblA(X3d,:), X3d(:));
	%
	chk.i(tblA,[],   true,  'ascend').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[],   true, 'descend').o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[],  'ascend',   true).o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], 'descend',   true).o(tblA(X1d,:), X1d(:));
	%
	chk.i(tblA,[], [true,false,false,false],  'ascend').o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], [true,false,false,false], 'descend').o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[], [false,true,false,false],  'ascend').o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], [false,true,false,false], 'descend').o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[], [false,false,true,false],  'ascend').o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], [false,false,true,false], 'descend').o(tblA(X3d,:), X3d(:));
	chk.i(tblA,[],  'ascend', [true,false,false,false]).o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], 'descend', [true,false,false,false]).o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[],  'ascend', [false,true,false,false]).o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], 'descend', [false,true,false,false]).o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[],  'ascend', [false,false,true,false]).o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], 'descend', [false,false,true,false]).o(tblA(X3d,:), X3d(:));
	%
	chk.i(tblA,[], { 'ascend','ignore','ignore','ignore'}).o(tblA(X1a,:), X1a(:));
	chk.i(tblA,[], {'descend','ignore','ignore','ignore'}).o(tblA(X1d,:), X1d(:));
	chk.i(tblA,[], {'ignore', 'ascend','ignore','ignore'}).o(tblA(X2a,:), X2a(:));
	chk.i(tblA,[], {'ignore','descend','ignore','ignore'}).o(tblA(X2d,:), X2d(:));
	chk.i(tblA,[], {'ignore','ignore', 'ascend','ignore'}).o(tblA(X3a,:), X3a(:));
	chk.i(tblA,[], {'ignore','ignore','descend','ignore'}).o(tblA(X3d,:), X3d(:));
	%
end
%
%% Table Systematic Two %%
%
if ist
	%
	X1a2a = [3,1,4,2,5];
	X1a2d = [1,3,4,2,5];
	X1a3a = [3,1,4,2,5];
	X1a3d = [1,3,4,2,5];
	X1d2a = [5,2,4,3,1];
	X1d2d = [5,2,4,1,3];
	X1d3a = [5,2,4,3,1];
	X1d3d = [5,2,4,1,3];
	X2a1a = [3,5,4,2,1];
	X2a1d = [5,3,4,2,1];
	X2a3a = [5,3,4,2,1];
	X2a3d = [3,5,4,2,1];
	X2d1a = [1,2,4,3,5];
	X2d1d = [1,2,4,5,3];
	X2d3a = [1,2,4,5,3];
	X2d3d = [1,2,4,3,5];
	X3a1a = [5,3,4,2,1];
	X3a1d = [5,3,4,2,1];
	X3a2a = [5,3,4,2,1];
	X3a2d = [5,3,4,2,1];
	X3d1a = [1,2,4,3,5];
	X3d1d = [1,2,4,3,5];
	X3d2a = [1,2,4,3,5];
	X3d2d = [1,2,4,3,5];
	%
	chk.i(tblA, [], [+1,+2]).o(tblA(X1a2a,:), X1a2a(:))
	chk.i(tblA, [], [+1,-2]).o(tblA(X1a2d,:), X1a2d(:))
	chk.i(tblA, [], [+1,+3]).o(tblA(X1a3a,:), X1a3a(:))
	chk.i(tblA, [], [+1,-3]).o(tblA(X1a3d,:), X1a3d(:))
	chk.i(tblA, [], [-1,+2]).o(tblA(X1d2a,:), X1d2a(:))
	chk.i(tblA, [], [-1,-2]).o(tblA(X1d2d,:), X1d2d(:))
	chk.i(tblA, [], [-1,+3]).o(tblA(X1d3a,:), X1d3a(:))
	chk.i(tblA, [], [-1,-3]).o(tblA(X1d3d,:), X1d3d(:))
	chk.i(tblA, [], [+2,+1]).o(tblA(X2a1a,:), X2a1a(:))
	chk.i(tblA, [], [+2,-1]).o(tblA(X2a1d,:), X2a1d(:))
	chk.i(tblA, [], [+2,+3]).o(tblA(X2a3a,:), X2a3a(:))
	chk.i(tblA, [], [+2,-3]).o(tblA(X2a3d,:), X2a3d(:))
	chk.i(tblA, [], [-2,+1]).o(tblA(X2d1a,:), X2d1a(:))
	chk.i(tblA, [], [-2,-1]).o(tblA(X2d1d,:), X2d1d(:))
	chk.i(tblA, [], [-2,+3]).o(tblA(X2d3a,:), X2d3a(:))
	chk.i(tblA, [], [-2,-3]).o(tblA(X2d3d,:), X2d3d(:))
	chk.i(tblA, [], [+3,+1]).o(tblA(X3a1a,:), X3a1a(:))
	chk.i(tblA, [], [+3,-1]).o(tblA(X3a1d,:), X3a1d(:))
	chk.i(tblA, [], [+3,+2]).o(tblA(X3a2a,:), X3a2a(:))
	chk.i(tblA, [], [+3,-2]).o(tblA(X3a2d,:), X3a2d(:))
	chk.i(tblA, [], [-3,+1]).o(tblA(X3d1a,:), X3d1a(:))
	chk.i(tblA, [], [-3,-1]).o(tblA(X3d1d,:), X3d1d(:))
	chk.i(tblA, [], [-3,+2]).o(tblA(X3d2a,:), X3d2a(:))
	chk.i(tblA, [], [-3,-2]).o(tblA(X3d2d,:), X3d2d(:))
	%
	%% Systematic Cell Array %%
	%
	txtA = tblA{:,1:3};
	%
	chk.i(txtA, [], 'ignore').o(txtA)
	chk.i(txtA, [], {'ignore','ignore','ignore'}).o(txtA)
	%
	chk.i(txtA, [], [+1,+2]).o(txtA(X1a2a,:), X1a2a(:))
	chk.i(txtA, [], [+1,-2]).o(txtA(X1a2d,:), X1a2d(:))
	chk.i(txtA, [], [+1,+3]).o(txtA(X1a3a,:), X1a3a(:))
	chk.i(txtA, [], [+1,-3]).o(txtA(X1a3d,:), X1a3d(:))
	chk.i(txtA, [], [-1,+2]).o(txtA(X1d2a,:), X1d2a(:))
	chk.i(txtA, [], [-1,-2]).o(txtA(X1d2d,:), X1d2d(:))
	chk.i(txtA, [], [-1,+3]).o(txtA(X1d3a,:), X1d3a(:))
	chk.i(txtA, [], [-1,-3]).o(txtA(X1d3d,:), X1d3d(:))
	chk.i(txtA, [], [+2,+1]).o(txtA(X2a1a,:), X2a1a(:))
	chk.i(txtA, [], [+2,-1]).o(txtA(X2a1d,:), X2a1d(:))
	chk.i(txtA, [], [+2,+3]).o(txtA(X2a3a,:), X2a3a(:))
	chk.i(txtA, [], [+2,-3]).o(txtA(X2a3d,:), X2a3d(:))
	chk.i(txtA, [], [-2,+1]).o(txtA(X2d1a,:), X2d1a(:))
	chk.i(txtA, [], [-2,-1]).o(txtA(X2d1d,:), X2d1d(:))
	chk.i(txtA, [], [-2,+3]).o(txtA(X2d3a,:), X2d3a(:))
	chk.i(txtA, [], [-2,-3]).o(txtA(X2d3d,:), X2d3d(:))
	chk.i(txtA, [], [+3,+1]).o(txtA(X3a1a,:), X3a1a(:))
	chk.i(txtA, [], [+3,-1]).o(txtA(X3a1d,:), X3a1d(:))
	chk.i(txtA, [], [+3,+2]).o(txtA(X3a2a,:), X3a2a(:))
	chk.i(txtA, [], [+3,-2]).o(txtA(X3a2d,:), X3a2d(:))
	chk.i(txtA, [], [-3,+1]).o(txtA(X3d1a,:), X3d1a(:))
	chk.i(txtA, [], [-3,-1]).o(txtA(X3d1d,:), X3d1d(:))
	chk.i(txtA, [], [-3,+2]).o(txtA(X3d2a,:), X3d2a(:))
	chk.i(txtA, [], [-3,-2]).o(txtA(X3d2d,:), X3d2d(:))
	%
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsrMain