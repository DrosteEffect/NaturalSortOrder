function test_nso_fun_check()
% Quick sanity check of the NaturalSortOrder test class.
%
% (c) 2012-2026 Stephen Cobeldick
%
%% Dependencies %%
%
% * MATLAB R2017a or later.
% * test_nso_fun.m from <www.mathworks.com/matlabcentral/fileexchange/34464>
%
% See also TEST_NSO_FUN
obj = test_nso_fun(@deal);
mainfun(obj) % count
obj.start()
mainfun(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%test_nso_fun_check
function mainfun(chk)
% All should pass:
chk.i([],'',{},"X").o([],'',{},"X")
chk.i(123:4567,NaN).o(123:4567,NaN)
% 1st should pass, 2nd should fail:
chk.i([],[]).o([],'') % double vs char
chk.i([],[]).o([],"") % double vs string
chk.i([],'').o([],{}) % char vs cell
chk.i(true,true,true).o(true,false,true) % true vs false
chk.i(false,[false,false]).o(false,[false,true]) % false vs true
chk.i([1,2,3,4],[5,6,Inf]).o([1,2,3,4],[5,6,NaN]) % Inf vs NaN
chk.i([1,2,3,4],[5,6,7,8]).o([1,2,3,4],[5,6,NaN]) % 4 vs 3 elements
chk.i([1,2,3,4],[5,6,7,8]).o([1,2,3,4],[5;6;7;8]) % row vs column
chk.i(nan(2,3),nan(4,5,6)).o(nan(2,3),nan(4,5,0)) % 120 vs 0 elements
chk.i("",cat(3,"hi","me")).o("",cat(3,"hi","me","!")) % 2 vs 3 elements
chk.i('hello','hello you').o('hello','hello world') % 'you' vs 'world'
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mainfun