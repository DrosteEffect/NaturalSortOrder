function [B,ndx,dbg,seq] = arbsort(A,varargin)
% Custom/arbitrary sequence sort the elements of a text array.
%
% (c) 2014-2026 Stephen Cobeldick
%
% Inspired by <https://support.microsoft.com/en-us/office/sort-data-using-a-custom-list-cba3d67a-c5cb-406f-9b14-a02205834d72>
%
% Sorts text array <A> into the order of custom/arbitrary text sequences.
% Matched (sub-)text within <A> is used to sort the elements of <A> using
% the sequence order. Remaining text is sorted into character code order.
% By default ignores the diacritics on characters not matched by any
% sequence. By default performs a case-insensitive ascending sort.
% Optional arguments select the case sensitivity, diacritic sensitivity,
% literal/regexp interpretation, sort order, etc.
%
%%% Syntax %%%
%
%   B = arbsort(A)
%   B = arbsort(A,<options>)
%   [B,ndx,dbg,seq] = arbsort(A,...)
%
% Zero or more sequence text arrays, sequence function handles, and/or
% replacement text arrays are processed in their input order.
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort any file-names or folder-names use NATSORTFILES (File Exchange 47434)
%
%% Examples %%
%
%   >> A = ["LargeBurger", "MediumCoffee", "SmallCoffee", "MediumBurger"];
%   >> sort(A) % ASCIIbetical
%   ans =  ["LargeBurger"  "MediumBurger"  "MediumCoffee"  "SmallCoffee"]
%   >> arbsort(A, ["small","medium","large"])
%   ans =  ["SmallCoffee"  "MediumBurger"  "MediumCoffee"  "LargeBurger"]
%   >> arbsort(A, ["coffee","burger"],["small","medium","large"])
%   ans =  ["SmallCoffee"  "MediumCoffee"  "MediumBurger"  "LargeBurger"]
%
%% Sequence Text Array %%
%
% A sequence is specified by text in the required order, e.g. ["S","M","L"],
% defined either as a 1xN string array or a 1xN cell array of char vectors.
%
% By default sequences are interpreted as regular expressions, allowing
% powerful compact sequences, e.g. ["S(mall)?","M(edium)?","L(arge)?"].
% The option "literal" selects to interpret sequences literally. See also:
% <https://www.mathworks.com/help/matlab/matlab_prog/regular-expressions.html>
%
% Many languages do not sort correctly when sorted into ASCII/Unicode
% order, e.g. Spanish. An alphabet may be provided as the last sequence:
%
%   >> Ae = {'yo', 'os', 'la', 'ño', 'va', 'ni', 'de', 'ña'};
%   >> alfabeto = num2cell(['A':'N','Ñ','O':'Z']); % Spanish alphabet
%   >> arbsort(Ae, alfabeto)
%   ans =  {'de', 'la', 'ni', 'ña', 'ño', 'os', 'va', 'yo'}
%
% For the pre-1994 spanisch alphabet (with 'CH' letter) use:
%   >> alfabeto = [{'A','B','C','CH'},num2cell(['D':'N','Ñ','O':'Z'])];
%
%% Sequence Function %%
%
% A sequence may be specified by a function handle. The function handle
% must accept one character vector or string scalar and return two outputs:
% 1) a numeric vector of values corresponding to any matched text parts,
% 2) a cell array of the split text (i.e. any unmatched text parts).
% For example, the function
% <https://www.mathworks.com/matlabcentral/fileexchange/52925 |WORDS2NUM|>
% converts any numbers in the text to numeric (e.g. 'ninety-nine' -> 99)
% and returns the split text as its second output, while the function
% <https://www.mathworks.com/matlabcentral/fileexchange/53886 |SIP2NUM|>
% converts numbers with SI-prefixes into numeric as well as the split text.
%
%% Replacement Substrings %%
%
% The sorting rules of some languages require certain characters to be
% replaced with (or considered equivalent to) other characters, these can
% be specified with a 2xM string array or a 2xM cell array of char vectors:
% 1) row one consists of M match texts (by default regular expressions),
% 2) row two consists of the corresponding M replacement texts.
%
% For example, in German the eszett character "ß" is sorted as it was
% written as "ss", and in some circumstances vowels with umlauts are
% sorted as that vowel without an umlaut but suffixed with "e":
%
%   >> Aa = ["Füße", "Fuß", "Für", "Fusion"];
%   >> Ra = ["ä", "ö", "ü", "ß";... row 1: match text
%           "ae","oe","ue","ss"]; % row 2: replacement text
%   >> arbsort(Aa,Ra)                      % DIN 5007 Variante 2
%   ans = ["Für", "Füße", "Fusion", "Fuß"]
%   >> arbsort(Aa,["ß";"ss"])              % DIN 5007 Variante 1
%   ans = ["Für", "Fusion", "Fuß", "Füße"]
%
%% Debugging Output Arrays %%
%
% The 3rd output is a RxC cell array <dbg>, containing the matched and
% parsed text from <A>. The rows of <dbg> are linearly indexed from <A>.
% The 4th output is a 1xC numeric vector <seq> indicating which sequence
% (i.e. input argument) corresponds to each column of <dbg> (e.g. 2 = 2nd
% input), and zero indicates that no sequence was matched.
%
%   >> [~,~,dbg,seq] = arbsort(A, ["small","medium","large"])
%   dbg =  {
%       'Large'     'Burger'
%       'Medium'    'Coffee'
%       'Small'     'Coffee'
%       'Medium'    'Burger'}
%   seq =  [  2      0]
%
%% Examples %%
%
%   >> Ab = {'L', 'XS', 'S', 'M', 'XL', 'S', 'M', 'XL', 'XS', 'L'};
%   >> [Bb,Xb] = arbsort(Ab, {'XS','S','M','L','XL'})
%   Bb =  {'XS', 'XS', 'S', 'S', 'M', 'M', 'L', 'L', 'XL', 'XL'}
%   Xb =  [2,9,3,6,4,7,1,10,5,8]
%
%   >> Ac = ["medium_test", "high_train", "low_train", "high_test", "medium_train", "low_test"];
%   >> arbsort(Ac, ["train","test"], ["low","medium","high"])
%   ans =  ["low_train", "low_test", "medium_train", "medium_test", "high_train", "high_test"]
%
%   >> Ad = ["test_three", "test_one", "test_ninetynine", "test_two"];
%   >> arbsort(Ad, @words2num) % download WORDS2NUM from FEX 52925.
%   ans =  ["test_one", "test_two", "test_three", "test_ninetynine"]
%
%% Input Arguments (**=default) %%
%
%   A   = Array to be sorted. Can be a string array, or a cell array of
%         character row vectors, or a categorical array, or a datetime array,
%         or any other array type which can be converted by CELLSTR.
%   <options> can be entered in any order, as many as required:
%       = Sort direction: 'descend'/'ascend'**
%       = Character case handling: 'matchcase'/'ignorecase'**
%       = Unmatched text diacritics: 'matchdia'/'ignoredia'**
%       = Sequence text matching: 'whole'/'partial'**
%       = Sequence text interpretation: 'literal'/'regexp'**
%       = Sequences, as many as required:
%         1) Replacement text in 2xM array (string or cell array of char
%            vectors), the first row specifies (sub-)text to match in <A>,
%            the second row defines the corresponding replacement text.
%         2) Sequence text in 1xN array (string or cell array of character
%            vectors) defines a sequence of (sub-)text in the required order.
%         3) Sequence function handle, which converts a string scalar or
%            char vector to numeric. Must return the following two outputs:
%            1: a numeric vector corresponding to the matched text parts.
%            2: the split text (i.e. any unmatched text parts) in a vector.
%
%% Output Arguments %%
%
%   B   = Array <A> sorted into custom sequence order.  The same size as <A>.
%   ndx = NumericArray, generally such that B = A(ndx). The same size as <A>.
%   dbg = RxC CellArray of the matched characters or number values. Each
%         row corresponds to one input element of <A> in linear-index order.
%   seq = 1xC NumericVector giving the input argument position (i.e. which
%         sequence) for each column of <dbg> (0 indicates no sequence match).
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
%
% See also SORT ARBSORT_TEST NATSORT NATSORTFILES NATSORTROWS WORDS2NUM
% SIP2NUM IREGEXP REGEXP COMPOSE STRING STRINGS CATEGORICAL CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if iscell(A)
	assert(all(fnh(A(:))),...
		'SC:arbsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:arbsort:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
%
varargin = cellfun(@as1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
% Sort direction:
tdx = strcmpi(txt,'ascend')|strcmpi(txt,'descend');
% Character case:
tcx = strcmpi(txt,'ignorecase')|strcmpi(txt,'matchcase');
% Diacritics:
tam = strcmpi(txt,'matchdia');
tax = strcmpi(txt,'ignoredia')|tam;
% Sequence interpretation:
til = strcmpi(txt,'literal');
tix = strcmpi(txt,'regexp')|til;
% Text matching:
tmw = strcmpi(txt,'whole');
tmx = strcmpi(txt,'partial')|tmw;
%
asAssert(txt, tdx,   'SortDirection', 'sort direction')
asAssert(txt, tcx,   'CharCaseMatch', 'case sensitivity')
asAssert(txt, tax,  'DiacriticMatch', 'diacritic sensitivity')
asAssert(txt, tix, 'LiteralVsRegexp', 'literal vs. regexp interpretation')
asAssert(txt, tmx,  'WholeVsPartial', 'whole vs. partial matching')
%
ixx = tdx|tcx|tax|tix|tmx;
if ~all(ixx)
	ert = sprintf(', "%s"',txt{~ixx});
	error('SC:arbsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s.'],ert(2:end))
end
%
xti = 1+find(~ixv);
isf = cellfun('isclass',xtx,'function_handle');
xtx(~isf) = cellfun(@cellstr,xtx(~isf),'uni',0);
%
for k = reshape(find(~isf),1,[])
	assert(ndims(xtx{k})<3,...
		'SC:arbsort:Sequence:MultiDimArray',...
		'Input %d: this sequence has more than two dimensions.',xti(k)) %#ok<ISMAT>
	assert(size(xtx{k},1)<3,...
		'SC:arbsort:Sequence:TooManyRows',...
		'Input %d: this sequence has more than two rows.',xti(k))
	assert(~any(cellfun('isempty',xtx{k}(1,:))),...
		'SC:arbsort:Sequence:EmptyText',...
		'Input %d: this sequence contains zero-length match text.',xti(k))
	if any(til) % literal interpretation
		xtx{k}(1,:) = regexptranslate('escape',xtx{k}(1,:));
	end
end
%
%% Match Sequences %%
%
if any(tmw) % whole
	fmt = '^(%s)$';
else % partial match
	fmt = '(%s)';
end
%
if any(tcx) % case
	imc = txt{tcx};
else
	imc = 'ignorecase';
end
%
if any(tdx) % direction
	drn = txt{tdx};
else
	drn = 'ascend';
end
%
[ars,ids] = asRecFun(fmt,imc,~any(tmw),any(tam),C,1,xti,xtx);
%
nmc = size(ars,2);
nmr = size(ars,1);
%
if nargout>2
	seq = abs(ids);
	idp = seq>0;
	seq(idp) = xti(seq(idp));
	dbg = ars;
	dbg(cellfun('isempty',dbg)) = {[]};
end
%
%% Sort Columns %%
%
ndx = 1:nmr;
%
for ii = nmc:-1:1
	vec = ars(ndx,ii);
	if ids(ii)<0 % match (function)
		vec(cellfun('isempty',vec)) = {NaN};
		[~,idx] = sort([vec{:}],drn);
	elseif ids(ii) % match (text sequence)
		inp = xtx{ids(ii)};
		rgx = strcat('^(',inp,')$');
		idm = zeros(size(ndx));
		for jj = 1:nmr
			idr = find(~cellfun('isempty',regexp(vec{jj},rgx,imc)));
			switch numel(idr)
				case 0
					% do nothing
				case 1
					idm(jj) = idr;
				otherwise
					error('SC:arbsort:Sequence:MultipleMatches',...
						['Input %d: this sequence returned multiple ',...
						'matches. The following sequence elements\n%s',...
						'all matched the following text:\n "%s"'],...
						xti(ids(ii)), sprintf(' "%s"\n',inp{idr}), vec{jj})
			end
		end
		[~,idx] = sort(idm,drn);
	else % zero == split text
		if strcmpi(imc,'ignorecase')
			vec = lower(vec);
		end
		if strcmpi(drn,'descend')
			[~,idx] = sort(asGroups(vec),'descend');
		else % SORT: "direction is not supported when A is a cell array"
			[~,idx] = sort(vec); % ascend
		end
	end
	ndx = ndx(idx);
end
%
if ischar(A)
	ndx = ndx(:);
	B = A(ndx,:);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%arbsort
function [ars,ids] = asRecFun(fmt,imc,isp,isd,ars,cnt,xti,seq)
% Recursively match and split text using regular expressions or function handles.
if numel(seq)
	one = seq{1};
	if isa(one,'function_handle') % sequence
		MaC = cell(size(ars));
		SpC = MaC;
		[op1,op2] = cellfun(one,ars,'uni',0);
		for kk = 1:numel(ars)
			if isp || isequal(op2{kk},{'',''})
				MaC{kk} = num2cell(double(op1{kk}));
				SpC{kk} = cellstr(op2{kk});
			else % whole
				SpC{kk} = ars(kk);
			end
		end
		sgn = -1;
	elseif size(one,1)<2 % text sequence
		[~,idx] = sort(cellfun('length',one),'descend');
		rgx = sprintf('|%s',one{idx});
		rgx = sprintf(fmt,rgx(2:end));
		if ~isd && numel(seq)<2
			ars = asTrimDia(ars,rgx,imc);
			isd = true; % no need to trim again
		end
		[MaC,SpC] = regexp(ars,rgx,'match','split',imc);
		sgn = +1;
	else % match and replace substrings
		ars = regexprep(ars,one(1,:),one(2,:),imc);
		[ars,ids] = asRecFun(fmt,imc,isp,isd,ars,cnt+1,xti,seq(2:end));
		return
	end
	nmc = max(cellfun('length',SpC));
	MaM = repmat({''},numel(ars),nmc);
	SpM = repmat({''},numel(ars),nmc);
	for ii = 1:numel(ars)
		MaV = MaC{ii}(:); % match
		SpV = SpC{ii}(:); % split
		assert(numel(SpV)==(1+numel(MaV)),...
			'SC:arbsort:Sequence:FunctionOutputLengths',...
			'Input %d: the function outputs must have N and N+1 elements.',xti(cnt))
		MaM(ii,1:numel(MaV)) = MaV;
		SpM(ii,1:numel(SpV)) = SpV;
	end
	S = cell(2,nmc);
	X = cell(2,nmc);
	for jj = 1:nmc
		[S{1,jj},X{1,jj}] = asRecFun(fmt,imc,isp,isd,SpM(:,jj),cnt+1,xti,seq(2:end));
		S{2,jj} = MaM(:,jj);
		X{2,jj} = sgn*cnt;
	end
	ars = [S{1:end}];
	ids = [X{1:end}];
elseif isd % match diacritics
	ids = 0;
else % trim/ignore diacritics
	ids = 0;
	ars = asTrimDia(ars);
end
idd = all(cellfun('isempty',ars),1);
ars(:,idd) = [];
ids(:,idd) = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asRecFun
function txt = asTrimDia(txt,rgx,imc)
% Trim diacritics from Latin, Greek, & Cyrillic characters within the domain [1,65535].
unc = [305,567,192,193,194,195,196,197,199,200,201,202,203,204,205,206,207,209,210,211,212,213,214,217,218,219,220,221,224,225,226,227,228,229,231,232,233,234,235,236,237,238,239,241,242,243,244,245,246,249,250,251,252,253,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,296,297,298,299,300,301,302,303,304,308,309,310,311,313,314,315,316,317,318,323,324,325,326,327,328,332,333,334,335,336,337,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,416,417,431,432,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,478,479,480,481,482,483,486,487,488,489,490,491,492,493,494,496,500,501,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,542,543,550,551,552,553,554,555,556,557,558,559,560,561,562,563,902,904,905,906,908,910,911,912,938,939,940,941,942,943,944,970,971,972,973,974,979,980,1024,1025,1027,1031,1036,1037,1038,1049,1081,1104,1105,1107,1111,1116,1117,1118,1142,1143,1217,1218,1232,1233,1234,1235,1238,1239,1242,1243,1244,1245,1246,1247,1250,1251,1252,1253,1254,1255,1258,1259,1260,1261,1262,1263,1264,1265,1266,1267,1268,1269,1272,1273,7680,7681,7682,7683,7684,7685,7686,7687,7688,7689,7690,7691,7692,7693,7694,7695,7696,7697,7698,7699,7700,7701,7702,7703,7704,7705,7706,7707,7708,7709,7710,7711,7712,7713,7714,7715,7716,7717,7718,7719,7720,7721,7722,7723,7724,7725,7726,7727,7728,7729,7730,7731,7732,7733,7734,7735,7736,7737,7738,7739,7740,7741,7742,7743,7744,7745,7746,7747,7748,7749,7750,7751,7752,7753,7754,7755,7756,7757,7758,7759,7760,7761,7762,7763,7764,7765,7766,7767,7768,7769,7770,7771,7772,7773,7774,7775,7776,7777,7778,7779,7780,7781,7782,7783,7784,7785,7786,7787,7788,7789,7790,7791,7792,7793,7794,7795,7796,7797,7798,7799,7800,7801,7802,7803,7804,7805,7806,7807,7808,7809,7810,7811,7812,7813,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7826,7827,7828,7829,7830,7831,7832,7833,7835,7840,7841,7842,7843,7844,7845,7846,7847,7848,7849,7850,7851,7852,7853,7854,7855,7856,7857,7858,7859,7860,7861,7862,7863,7864,7865,7866,7867,7868,7869,7870,7871,7872,7873,7874,7875,7876,7877,7878,7879,7880,7881,7882,7883,7884,7885,7886,7887,7888,7889,7890,7891,7892,7893,7894,7895,7896,7897,7898,7899,7900,7901,7902,7903,7904,7905,7906,7907,7908,7909,7910,7911,7912,7913,7914,7915,7916,7917,7918,7919,7920,7921,7922,7923,7924,7925,7926,7927,7928,7929,7936,7937,7938,7939,7940,7941,7942,7943,7944,7945,7946,7947,7948,7949,7950,7951,7952,7953,7954,7955,7956,7957,7960,7961,7962,7963,7964,7965,7968,7969,7970,7971,7972,7973,7974,7975,7976,7977,7978,7979,7980,7981,7982,7983,7984,7985,7986,7987,7988,7989,7990,7991,7992,7993,7994,7995,7996,7997,7998,7999,8000,8001,8002,8003,8004,8005,8008,8009,8010,8011,8012,8013,8016,8017,8018,8019,8020,8021,8022,8023,8025,8027,8029,8031,8032,8033,8034,8035,8036,8037,8038,8039,8040,8041,8042,8043,8044,8045,8046,8047,8048,8049,8050,8051,8052,8053,8054,8055,8056,8057,8058,8059,8060,8061,8064,8065,8066,8067,8068,8069,8070,8071,8072,8073,8074,8075,8076,8077,8078,8079,8080,8081,8082,8083,8084,8085,8086,8087,8088,8089,8090,8091,8092,8093,8094,8095,8096,8097,8098,8099,8100,8101,8102,8103,8104,8105,8106,8107,8108,8109,8110,8111,8112,8113,8114,8115,8116,8118,8119,8120,8121,8122,8123,8124,8130,8131,8132,8134,8135,8136,8137,8138,8139,8140,8144,8145,8146,8147,8150,8151,8152,8153,8154,8155,8160,8161,8162,8163,8164,8165,8166,8167,8168,8169,8170,8171,8172,8178,8179,8180,8182,8183,8184,8185,8186,8187,8188,8491];
asc = [105,106,65,65,65,65,65,65,67,69,69,69,69,73,73,73,73,78,79,79,79,79,79,85,85,85,85,89,97,97,97,97,97,97,99,101,101,101,101,105,105,105,105,110,111,111,111,111,111,117,117,117,117,121,121,65,97,65,97,65,97,67,99,67,99,67,99,67,99,68,100,69,101,69,101,69,101,69,101,69,101,71,103,71,103,71,103,71,103,72,104,73,105,73,105,73,105,73,105,73,74,106,75,107,76,108,76,108,76,108,78,110,78,110,78,110,79,111,79,111,79,111,82,114,82,114,82,114,83,115,83,115,83,115,83,115,84,116,84,116,85,117,85,117,85,117,85,117,85,117,85,117,87,119,89,121,89,90,122,90,122,90,122,79,111,85,117,65,97,73,105,79,111,85,117,85,117,85,117,85,117,85,117,65,97,65,97,198,230,71,103,75,107,79,111,79,111,439,106,71,103,78,110,65,97,198,230,216,248,65,97,65,97,69,101,69,101,73,105,73,105,79,111,79,111,82,114,82,114,85,117,85,117,83,115,84,116,72,104,65,97,69,101,79,111,79,111,79,111,79,111,89,121,913,917,919,921,927,933,937,953,921,933,945,949,951,953,965,953,965,959,965,969,978,978,1045,1045,1043,1030,1050,1048,1059,1048,1080,1077,1077,1075,1110,1082,1080,1091,1140,1141,1046,1078,1040,1072,1040,1072,1045,1077,1240,1241,1046,1078,1047,1079,1048,1080,1048,1080,1054,1086,1256,1257,1069,1101,1059,1091,1059,1091,1059,1091,1063,1095,1067,1099,65,97,66,98,66,98,66,98,67,99,68,100,68,100,68,100,68,100,68,100,69,101,69,101,69,101,69,101,69,101,70,102,71,103,72,104,72,104,72,104,72,104,72,104,73,105,73,105,75,107,75,107,75,107,76,108,76,108,76,108,76,108,77,109,77,109,77,109,78,110,78,110,78,110,78,110,79,111,79,111,79,111,79,111,80,112,80,112,82,114,82,114,82,114,82,114,83,115,83,115,83,115,83,115,83,115,84,116,84,116,84,116,84,116,85,117,85,117,85,117,85,117,85,117,86,118,86,118,87,119,87,119,87,119,87,119,87,119,88,120,88,120,89,121,90,122,90,122,90,122,104,116,119,121,383,65,97,65,97,65,97,65,97,65,97,65,97,65,97,65,97,65,97,65,97,65,97,65,97,69,101,69,101,69,101,69,101,69,101,69,101,69,101,69,101,73,105,73,105,79,111,79,111,79,111,79,111,79,111,79,111,79,111,79,111,79,111,79,111,79,111,79,111,85,117,85,117,85,117,85,117,85,117,85,117,85,117,89,121,89,121,89,121,89,121,945,945,945,945,945,945,945,945,913,913,913,913,913,913,913,913,949,949,949,949,949,949,917,917,917,917,917,917,951,951,951,951,951,951,951,951,919,919,919,919,919,919,919,919,953,953,953,953,953,953,953,953,921,921,921,921,921,921,921,921,959,959,959,959,959,959,927,927,927,927,927,927,965,965,965,965,965,965,965,965,933,933,933,933,969,969,969,969,969,969,969,969,937,937,937,937,937,937,937,937,945,945,949,949,951,951,953,953,959,959,965,965,969,969,945,945,945,945,945,945,945,945,913,913,913,913,913,913,913,913,951,951,951,951,951,951,951,951,919,919,919,919,919,919,919,919,969,969,969,969,969,969,969,969,937,937,937,937,937,937,937,937,945,945,945,945,945,945,945,913,913,913,913,913,951,951,951,951,951,917,917,919,919,919,953,953,953,953,953,953,921,921,921,921,965,965,965,965,961,961,965,965,933,933,933,933,929,969,969,969,969,969,927,927,937,937,937,65];
if nargin>1
	tmp = sprintf('\0%s',sprintf('%c\0',unc));
	idx = regexp(tmp,rgx,imc)./2;
	%idx = ~cellfun('isempty',regexp(num2cell(unc),rgx,imc));
	unc(idx) = [];
	asc(idx) = [];
end
lookup = sparse(unc, 1, asc, 65535, 1);
for k = 1:numel(txt)
	rpl = full(lookup(txt{k}));
    idx = rpl>0;
    txt{k}(idx) = rpl(idx);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asTrimDia
function grp = asGroups(vec)
% Groups in a cell array of char vectors, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true(1,numel(vec)>0);~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asGroups
function asAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:arbsort:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asAssert
function arr = as1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%as1s2c