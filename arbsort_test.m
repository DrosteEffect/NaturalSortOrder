function arbsort_test()
% Test function for ARBSORT.
%
% (c) 2014-2026 Stephen Cobeldick
%
%% Dependencies %%
%
% * MATLAB R2017a or later.
% * arbsort.m & testfun_nso.m from <www.mathworks.com/matlabcentral/fileexchange/132263>
%
% See also ARBSORT TEST_NSO_FUN NATSORT_TEST NATSORTFILES_TEST NATSORTROWS_TEST
obj = test_nso_fun(@arbsort);
astMain(obj) % count
obj.start()
astMain(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%arbsort_test
function astMain(chk)
%
try pad(strings(01)); iss=true; catch; iss=false; chk.warn('No string class.'); end %#ok<NASGU,CTCH,WNTAG>
try words2num('one'); isw=true; catch; isw=false; chk.warn('No WORDS2NUM() found.'); end %#ok<CTCH,WNTAG>
try sip2num('123 M'); isp=true; catch; isp=false; chk.warn('No SIP2NUM() found.'); end %#ok<CTCH,WNTAG>
%
%% Mfile Examples %%
%
S = ["small","medium","large"];
A =           ["LargeBurger", "MediumCoffee", "SmallCoffee", "MediumBurger"];
chk.i(A, S).o(["SmallCoffee"  "MediumBurger"  "MediumCoffee"  "LargeBurger"])
chk.i(A, S).o(@i, [3,4,2,1]) % not in Mfile
chk.i(A, S).o(@i, @i, {'Large','Burger';'Medium','Coffee';'Small','Coffee';'Medium','Burger'},[2,0])
%
alfabeto = num2cell(['A':'N','Ñ','O':'Z']);
Ae =                  {'yo', 'os', 'la', 'ño', 'va', 'ni', 'de', 'ña'};
chk.i(Ae, alfabeto).o({'de', 'la', 'ni', 'ña', 'ño', 'os', 'va', 'yo'})
chk.i(Ae, alfabeto).o(@i, [7,3,6,8,4,2,5,1],{...
	'y','o';...
	'o','s';...
	'l','a';...
	'ñ','o';...
	'v','a';...
	'n','i';...
	'd','e';...
	'ñ','a'},[2,2]) % Not in Mfile
%
Ra = [...
	"ä", "ö", "ü", "ß";...  row 1: match text
	"ae","oe","ue","ss"]; % row 2: replacement text
Aa =                               ["Füße", "Fuß", "Für", "Fusion"];
chk.i(Aa,Ra                    ).o(["Für", "Füße", "Fusion", "Fuß"])
chk.i(Aa,Ra                    ).o(["Für", "Füße", "Fusion", "Fuß"],[3,1,4,2],{'Fuesse';'Fuss';'Fuer';'Fusion'}, 0) % not in Mfile
chk.i(Aa,["ß";"ss"]            ).o(["Für", "Fusion", "Fuß", "Füße"])
chk.i(Aa,["ß";"ss"]            ).o(["Für", "Fusion", "Fuß", "Füße"],[3,4,2,1],{'Fusse';'Fuss';'Fur';'Fusion'}, 0) % not in Mfile
chk.i(Aa,["ß";"ss"],"ignoredia").o(["Für", "Fusion", "Fuß", "Füße"])                                             % not in Mfile
chk.i(Aa,["ß";"ss"],"ignoredia").o(["Für", "Fusion", "Fuß", "Füße"],[3,4,2,1],{'Fusse';'Fuss';'Fur';'Fusion'}, 0) % not in Mfile
chk.i(Aa,["ß";"ss"], "matchdia").o(["Fusion", "Fuß", "Für", "Füße"])                                             % not in Mfile
chk.i(Aa,["ß";"ss"], "matchdia").o(["Fusion", "Fuß", "Für", "Füße"],[4,2,3,1],{'Füsse';'Fuss';'Für';'Fusion'}, 0) % not in Mfile
%
Sb = {'XS','S','M','L','XL'};
Ab =            {'L', 'XS', 'S', 'M', 'XL', 'S', 'M', 'XL', 'XS', 'L'};
chk.i(Ab, Sb).o({'XS', 'XS', 'S', 'S', 'M', 'M', 'L', 'L', 'XL', 'XL'}, [2,9,3,6,4,7,1,10,5,8])
chk.i(Ab, Sb).o(@i, [2,9,3,6,4,7,1,10,5,8]) % not in Mfile
%
Sc1 = ["train","test"];
Sc2 = ["low","medium","high"];
Dc = {'medium','_','test';'high','_','train';'low','_','train';'high','_','test';'medium','_','train';'low','_','test'};
Ac =                  ["medium_test", "high_train", "low_train", "high_test", "medium_train", "low_test"];
chk.i(Ac, Sc1, Sc2).o(["low_train", "low_test", "medium_train", "medium_test", "high_train", "high_test"])
chk.i(Ac, Sc1, Sc2).o(@i, [3,6,5,1,2,4], Dc, [3,0,2]) % Not in Mfile
chk.i(Ac, Sc1, Sc2).o(@i, @i, Dc, [3,0,2]) % Not in Mfile
%
if isw % download WORDS2NUM from FEX 52925.
	Ad = ["test_three", "test_one", "test_ninetynine", "test_two"];
	Bd = ["test_one", "test_two", "test_three", "test_ninetynine"];
	chk.i(Ad, @words2num).o(Bd)
	chk.i(Ad, @words2num).o(Bd, [2,4,1,3]) % not in Mfile
	chk.i(Ad, @words2num).o(@i, [2,4,1,3], {'test_',3;'test_',1;'test_',99;'test_',2}, [0,2]) % Not in Mfile
end
%
%% HTML Examples %%
%
Da = {'Rose';'Rosy';'Rosa';'Rose'};
Aa = ["Rosé","Rosy","Rosa","Rose"];
Ba = ["Rosa","Rosé","Rose","Rosy"];
chk.i(Aa).o(Ba);
chk.i(Aa).o(Ba, [3,1,4,2], Da, 0) % not in HTML
chk.i(Aa).o(@i, [3,1,4,2], Da, 0) % not in HTML
%
Ab  = ["SmallTea";"MediumCoffee";"LargeTea";"SmallCoffee";"MediumTea";"LargeCoffee"];
Sb1 = ["small","medium","large"];
Sb2 = ["tea","coffee"];
Ob1 = ["SmallCoffee";"SmallTea";"MediumCoffee";"MediumTea";"LargeCoffee";"LargeTea"];
Ob2 = ["SmallTea";"SmallCoffee";"MediumTea";"MediumCoffee";"LargeTea";"LargeCoffee"];
chk.i(Ab,Sb1     ).o(Ob1)
chk.i(Ab,Sb1     ).o(Ob1,[4;1;2;5;6;3],{'Small','Tea';'Medium','Coffee';'Large','Tea';'Small','Coffee';'Medium','Tea';'Large','Coffee'}, [2,0]) % not in HTML
chk.i(Ab,Sb1, Sb2).o(Ob2)
chk.i(Ab,Sb1, Sb2).o(Ob2,[1;4;5;2;3;6],{"Small","Tea";"Medium","Coffee";"Large","Tea";"Small","Coffee";"Medium","Tea";"Large","Coffee"}, [2,3]) % not in HTML
%
if isw % download WORDS2NUM from FEX 52925.
	Ac =                   ["test_one", "test_zero", "test_ninetynine", "test_two"];
	chk.i(Ac,@words2num).o(["test_zero", "test_one", "test_two", "test_ninetynine"])
	chk.i(Ac,@words2num).o(["test_zero", "test_one", "test_two", "test_ninetynine"],[2,1,4,3],{'test_',1;'test_',0;'test_',99;'test_',2}, [0,2]) % not in HTML
end
%
Rd = [...
	"Æ", "Œ";...  row1: match text
	"AE","OE"]; % row2: replacement text
Ad =           ["bœuf","bæ","boz","boa","bzz","baa","baz"];
chk.i(Ad,Rd).o(["baa","bæ","baz","boa","bœuf","boz","bzz"])
chk.i(Ad,Rd).o(["baa","bæ","baz","boa","bœuf","boz","bzz"],[6,2,7,4,1,3,5],{'bOEuf';'bAE';'boz';'boa';'bzz';'baa';'baz'}, 0) % not in HTML
%
Se = ["S","M","L"];
Ae =                      ["S", "Medium", "L", "Small", "Large", "M"];
chk.i(Ae,Se, "partial").o(["S", "Small", "M", "Medium", "L", "Large"])
chk.i(Ae,Se, "partial").o(["S", "Small", "M", "Medium", "L", "Large"],[1,4,6,2,3,5],{'S',[],[],[],[],[];'M','ediu','m',[],[],[];'L',[],[],[],[],[];'S',[],'m','a','l','l';'L','arge',[],[],[],[];'M',[],[],[],[],[]}, [2,0,2,0,2,2]) % not in HTML
chk.i(Ae,Se,   "whole").o(["S", "M", "L", "Large", "Medium", "Small"])
chk.i(Ae,Se,   "whole").o(["S", "M", "L", "Large", "Medium", "Small"],[1,6,3,5,2,4],{[],'S';'Medium',[];[],'L';'Small',[];'Large',[];[],'M'}, [0,2]) % not in HTML
%
Sf = ["S","M","L"];
Af =                         ["S", "m", "L", "s", "l", "M"];
chk.i(Af,Sf, "ignorecase").o(["S", "s", "m", "M", "L", "l"])
chk.i(Af,Sf, "ignorecase").o(["S", "s", "m", "M", "L", "l"],[1,4,2,6,3,5],{'S';'m';'L';'s';'l';'M'}, 2) % not in HTML
chk.i(Af,Sf,  "matchcase").o(["S", "M", "L", "l", "m", "s"])
chk.i(Af,Sf,  "matchcase").o(["S", "M", "L", "l", "m", "s"],[1,6,3,5,2,4],{[],'S';'m',[];[],'L';'s',[];'l',[];[],'M'}, [0,2]) % not in HTML
%
Ag =                     ["Zoë","Zoz","Zoa"];
chk.i(Ag, "ignoredia").o(["Zoa", "Zoë", "Zoz"])
chk.i(Ag, "ignoredia").o(["Zoa", "Zoë", "Zoz"],[3,1,2],{'Zoe';'Zoz';'Zoa'}, 0) % not in HTML
chk.i(Ag,  "matchdia").o(["Zoa", "Zoz", "Zoë"])
chk.i(Ag,  "matchdia").o(["Zoa", "Zoz", "Zoë"],[3,2,1],{'Zoë';'Zoz';'Zoa'}, 0) % not in HTML
%
Sh = ["\s","s"];
Ah =                      ["_s","s"," s","\s"];
chk.i(Ah,Sh,  "regexp").o([" s","s","\s","_s"])
chk.i(Ah,Sh,  "regexp").o([" s","s","\s","_s"],[3,2,4,1],{'_','s',[];[],'s',[];[],' ','s';'\','s',[]}, [0,2,2]) % not in HTML
chk.i(Ah,Sh, "literal").o(["\s","s"," s","_s"])
chk.i(Ah,Sh, "literal").o(["\s","s"," s","_s"],[4,2,3,1],{'_','s';[],'s';' ','s';[],'\s'}, [0,2]) % not in HTML
%
Si = ["low","mid","high"];
Ai =           ["testHigh","testLow","testMid","testLow"];
chk.i(Ai,Si).o(["testLow","testLow","testMid","testHigh"],[2,4,3,1])
chk.i(Ai,Si).o(@i, @i, {'test','High';'test','Low';'test','Mid';'test','Low'}, [0,2])
%
alfabeto = num2cell(['A':'N','Ñ','O':'Z']); % Spanish alphabet.
Aj =                  ["yo", "os", "la", "ño", "va", "ni", "de", "ña"];
chk.i(Aj, alfabeto).o(["de", "la", "ni", "ña", "ño", "os", "va", "yo"])
%
Ak =                  ["radio", "rana", "rastrillo", "ráfaga", "rápido"];
chk.i(Ak, alfabeto).o(["radio", "ráfaga", "rana", "rápido", "rastrillo"])
%
Al =                  ["Bruzn","Bruijn","Bruin","Bruyn","Bruijn"];
alfabet = [num2cell('A':'Y'),{'Ĳ|IJ','Z'}]; % Winkler Prins
chk.i(Al, alfabet).o(["Bruin", "Bruyn", "Bruijn", "Bruijn", "Bruzn"])
chk.i(Al, alfabet).o(["Bruin", "Bruyn", "Bruijn", "Bruijn", "Bruzn"],[3,4,2,5,1]) % not in HTML
alfabet = [num2cell('A':'X'),{'Ĳ|IJ|Y','Z'}]; % telephone
chk.i(Al, alfabet).o(["Bruin", "Bruijn", "Bruyn", "Bruijn", "Bruzn"])
chk.i(Al, alfabet).o(["Bruin", "Bruijn", "Bruyn", "Bruijn", "Bruzn"],[3,2,4,5,1]) % not in HTML
%
abece = ["a|á","b","c","cs","d","dz","dzs","e|é","f","g","gy","h","i|í","j","k","l","ly","m","n","ny","o|ó","ö|ő","p","q","r","s","sz","t","ty","u|ú","ü|ű","v","w","x","y","z","zs"];
Ahu = ["apa", "asz", "csak", "cukor", "dzsungel", "dzűmmög", "ár"];
Bhu = ["apa", "ár", "asz", "cukor", "csak", "dzűmmög", "dzsungel"];
chk.i(Ahu,abece).o(Bhu)
chk.i(Ahu,abece).o(Bhu, [1,7,2,4,3,6,5], {'a','p','a',[],[],[]; 'a','sz',[],[],[],[]; 'cs','a','k',[],[],[]; 'c','u','k','o','r',[]; 'dzs','u','n','g','e','l'; 'dz','ű','m','m','ö','g'; 'á','r',[],[],[],[]}, [2,2,2,2,2,2]) % not in HTML
%
vardagar = ["Mån(dag)?","Tis(dag)?","Ons(dag)?","Tors(dag)?","Fre(dag)?","Lör(dag)?","Sön(dag)?"];
alfabet  = num2cell(['A':'Z','ÅÄÖ']); % Swedish alphabet.
Am =                           ["ö_Tis", "å_Tis", "a_Tis", "z_Tors", "z_Lör", "ä_Tis", "z_Mån"];
chk.i(Am, vardagar, alfabet).o(["a_Tis", "z_Mån", "z_Tors", "z_Lör", "å_Tis", "ä_Tis", "ö_Tis"])
chk.i(Am, vardagar, alfabet).o(@i, [3,7,4,5,2,6,1], {...
	'ö','_','Tis' ;...
	'å','_','Tis' ;...
	'a','_','Tis' ;...
	'z','_','Tors';...
	'z','_','Lör' ;...
	'ä','_','Tis' ;...
	'z','_','Mån'}, [3,0,2]) % not in HTML
%
Sn = ["\s*SMALL","\s*MEDIUM","\s*LARGE"];
An = ['Y  large';'X medium';'Z  large';'X  small';'X  large'];
Bn = ['X  small';'X medium';'X  large';'Y  large';'Z  large'];
chk.i(An,Sn).o(Bn)
chk.i(An,Sn).o(Bn, [4;2;5;1;3]) % not in HTML
chk.i(An,Sn).o(@i, [4;2;5;1;3], {'Y','  large';'X',' medium';'Z','  large';'X','  small';'X','  large'}, [0,2]) % not in HTML
%
if isp % download SIP2NUM from FEX 53886.
	Ao =                  ["test9.9µV","test10mV","test13nV","test2mV","test1nV"];
	chk.i(Ao, @sip2num).o(["test1nV","test13nV","test9.9µV","test2mV","test10mV"])
	chk.i(Ao, @sip2num).o(@i, [5,3,1,4,2], {...
		'test',9.9e-06,'V';...
		'test',1.0e-02,'V';...
		'test',1.3e-08,'V';...
		'test',2.0e-03,'V';...
		'test',1.0e-09,'V'}, [0,2,0]) % not in HTML
end
%
%% Edge-Cases
%
chk.i({}).o({});
chk.i(cell(0,1,2)).o(cell(0,1,2))
chk.i(cell(2,1,0)).o(cell(2,1,0))
chk.i( string([])).o( string([]))
%
chk.i(   "").o(   "")
chk.i(  "0").o(  "0")
chk.i(  "X").o(  "X")
chk.i(  "_").o(  "_")
chk.i( {''}).o( {''})
chk.i({'A'}).o({'A'})
chk.i({'Z'}).o({'Z'})
chk.i({'9'}).o({'9'})
%
%% Non-ASCII %%
%
chk.i(["AF","ǣ","ad","Ǣ"], ["Æ|Ǣ";"AE"]).o(["ad","ǣ","Ǣ","AF"])
%
%% Index Stability %%
%
chk.i(["A","A","A"]           ).o(["A","A","A"], [1,2,3])
chk.i(["A","A","A"],  'ascend').o(["A","A","A"], [1,2,3])
chk.i(["A","A","A"], 'descend').o(["A","A","A"], [1,2,3])
chk.i(["Z","Y","Z","X","Z"]           ).o(["X","Y","Z","Z","Z"], [4,2,1,3,5])
chk.i(["Z","Y","Z","X","Z"],  'ascend').o(["X","Y","Z","Z","Z"], [4,2,1,3,5])
chk.i(["Z","Y","Z","X","Z"], 'descend').o(["Z","Z","Z","Y","X"], [1,3,5,2,4])
%
%% Partial vs Whole
%
A0 = ["five_","four","two_","three","one_","zero"];
Bp = ["zero","one_","two_","three","four","five_"];
Bw = ["zero","three","four","five_","one_","two_"];
if isw
	chk.i(A0,@words2num,'partial').o(Bp, [6,5,3,4,2,1], {     5,'_'; 4,[];    2,'_'; 3,[];    1,'_'; 0,[]}, [2,0])
	chk.i(A0,@words2num,  'whole').o(Bw, [6,4,2,1,5,3], {'five_',[]; [],4;'two_',[]; [],3;'one_',[]; [],0}, [0,2])
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%astMain