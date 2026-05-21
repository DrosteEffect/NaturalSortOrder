function [B,ndx,dbg,seq] = arbsort(A,varargin)
% Custom/arbitrary sequence sort the elements of a text array.
%
% (c) 2014-2026 Stephen Cobeldick
%
% Inspired by <https://support.microsoft.com/en-us/office/sort-data-using-a-custom-list-cba3d67a-c5cb-406f-9b14-a02205834d72>
%
% Sorts text array <A> into the order of custom/arbitrary text sequences.
% Matched (sub-)text within <A> is used to sort the elements of <A> using
% the sequence order, remaining text is sorted into character code order:
% by default diacritics are removed from characters not matched by any
% sequence, and by default performs a case-insensitive ascending sort.
% Optional arguments select the case sensitivity, diacritic sensitivity,
% literal/regexp interpretation, sort order, etc.
%
%%% Syntax %%%
%
%   B = arbsort(A)
%   B = arbsort(A,<options>)
%   [B,ndx,dbg,seq] = arbsort(A,...)
%
% Zero or more sequence function handles, sequence text arrays, and/or
% replacement text arrays are processed in their input order:
%
%   >> A = ["Large Burger", "Medium Coffee", "Small Coffee", "Medium Burger"];
%   >> sort(A) % ASCIIbetical
%   ans =  ["Large Burger"  "Medium Burger"  "Medium Coffee"  "Small Coffee"]
%   >> arbsort(A, ["small","medium","large"])
%   ans =  ["Small Coffee"  "Medium Burger"  "Medium Coffee"  "Large Burger"]
%   >> arbsort(A, ["coffee","burger"],["small","medium","large"])
%   ans =  ["Small Coffee"  "Medium Coffee"  "Medium Burger"  "Large Burger"]
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort any file-names or folder-names use NATSORTFILES (File Exchange 47434)
%
%% Sequence Text Vector %%
%
% A sequence is specified by text in the required order, e.g. ["S","M","L"],
% defined either as a 1xN string array or a 1xN cell array of char vectors.
%
% By default sequences are interpreted as regular expressions, allowing
% powerful compact sequences, e.g. ["S(mall)?","M(edium)?","L(arge)?"],
% which also makes it easy to define characters as equivalent, e.g. "Å|AA".
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
% For the pre-1994 spanish alphabet (with 'CH' letter) use:
%   >> alfabeto = [{'A','B','C','CH'},num2cell(['D':'N','Ñ','O':'Z'])];
%
%% Sequence Function %%
%
% A sequence may be specified by a function handle. The function handle
% must accept one character vector or string scalar and return two outputs:
% 1) a numeric vector of N values converted from the matched text parts,
% 2) a cell vector of the split text, i.e. the N+1 unmatched text parts.
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
%   >> arbsort(Aa,["ß";"ss"])              % DIN 5007 Variante 1
%   ans = ["Für", "Fusion", "Fuß", "Füße"]
%   >> arbsort(Aa,Ra)                      % DIN 5007 Variante 2
%   ans = ["Für", "Füße", "Fusion", "Fuß"]
%
%% Debugging Output Arrays %%
%
% The 3rd output is an RxC cell array <dbg> derived from input <A>, after
% text replacement and diacritic removal. It contains matched text, split
% text (i.e. not matched by any sequence), and numeric values (converted
% by function handle). The rows of <dbg> are linearly indexed from <A>.
% This array contains the text & values used to sort the (sub)text.
% The 4th output is a 1xC numeric vector <seq> indicating which sequence
% (i.e. input argument position) corresponds to each column of <dbg>
% (e.g. 2 = 2nd input), and zero indicates that no sequence was matched.
%
%   >> [~,~,dbg,seq] = arbsort(A, ["small","medium","large"])
%   dbg =  {
%       'Large'     ' Burger'
%       'Medium'    ' Coffee'
%       'Small'     ' Coffee'
%       'Medium'    ' Burger'}
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
%         or any other array type which can be converted by CELLSTR().
%   <options> can be entered in any order, as many as required:
%       = Sort direction: 'descend'/'ascend'**
%       = Character case handling: 'matchcase'/'ignorecase'**
%       = Text matching interpretation: 'literal'/'regexp'**
%       = Unmatched diacritics: 'matchdia'/'ignoredia'**
%       = Sequence matching in <A>: 'whole'/'partial'**
%       = Sequence function handle, which converts a string scalar or char
%         vector to numeric. It must return the following two outputs:
%         1: a numeric vector corresponding to the matched text parts,
%         2: a cell vector of the split text (i.e. any unmatched text parts).
%       = Sequence text in 1xN array (string or cell array of character
%         vectors) defines a sequence of (sub-)text in the required order.
%       = Replacement text in 2xM array (string or cell array of char
%         vectors), the first row specifies (sub-)text to match in <A>,
%         the second row defines the corresponding replacement text.
%
% Note1: by default both sequence text and replacement text are regular
% expressions: use the sequence interpretation option for literal text.
% Note2: character codes 0:3 are reserved for internal use.
%
%% Output Arguments %%
%
%   B   = Array <A> sorted into custom sequence order.  The same size as <A>.
%   ndx = NumericArray, generally such that B = A(ndx). The same size as <A>.
%   dbg = RxC CellArray of split text, matched text, or number values. Each
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
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
% Release | Feature
% --------|--------
% R2016b  |      string class                            [only if supplied]
% R2014b  |    datetime class                            [only if supplied]
% R2013b  | categorical class                            [only if supplied]
% R2009b  | tilde argument placeholder
% R2008a  | assert: message-identifier
% R2007b  | regexp/regexpi: cell array of char, match & split options
% R2007a  | regexptranslate
%
%% Input Wrangling %%
%
if iscell(A)
	assert(all(fnh(A(:))),...
		'SC:arbsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:arbsort:A:CharNotMatrix',...
		'First input <A> when character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
assert(all([C{:}]>3),...
	'SC:arbsort:A:ControlChars',...
	'First input <A> must contain only character codes >3.')
%
varargin = cellfun(@as1s2c, varargin, 'UniformOutput',false);
idxTxt = fnh(varargin); % is char
varTxt = varargin(idxTxt); % char
varXtx = varargin(~idxTxt); % not
%
% Sort direction:
ixtDrn = strcmpi(varTxt,'ascend')|strcmpi(varTxt,'descend');
% Character case:
ixtChC = strcmpi(varTxt,'ignorecase')|strcmpi(varTxt,'matchcase');
% Diacritics:
ixtDiM = strcmpi(varTxt,'matchdia');
ixtDiX = strcmpi(varTxt,'ignoredia')|ixtDiM;
% Sequence interpretation:
ixtSqL = strcmpi(varTxt,'literal');
ixtSqI = strcmpi(varTxt,'regexp')|ixtSqL;
% Text matching:
ixtMaW = strcmpi(varTxt,'whole');
ixtMaX = strcmpi(varTxt,'partial')|ixtMaW;
%
asAssert(varTxt, ixtDrn,   'SortDirection', 'sort direction')
asAssert(varTxt, ixtChC,   'CharCaseMatch', 'case sensitivity')
asAssert(varTxt, ixtDiX,  'DiacriticMatch', 'diacritic sensitivity')
asAssert(varTxt, ixtSqI, 'LiteralVsRegexp', 'literal vs. regexp interpretation')
asAssert(varTxt, ixtMaX,  'WholeVsPartial', 'whole vs. partial matching')
%
ixtXXX = ixtDrn|ixtChC|ixtDiX|ixtSqI|ixtMaX;
if ~all(ixtXXX)
	errTxt = sprintf(', "%s"',varTxt{~ixtXXX});
	error('SC:arbsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s.'],errTxt(2:end))
end
%
posXtx = 1+find(~idxTxt);
isFunH = cellfun('isclass',varXtx,'function_handle');
varXtx(~isFunH) = cellfun(@cellstr,varXtx(~isFunH),'uni',0);
%
for k = reshape(find(~isFunH),1,[])
	assert(ndims(varXtx{k})<3,...
		'SC:arbsort:Sequence:MultiDimArray',...
		'Input %d: this sequence has more than two dimensions.',posXtx(k)) %#ok<ISMAT>
	assert(size(varXtx{k},1)<3,...
		'SC:arbsort:Sequence:TooManyRows',...
		'Input %d: this sequence has more than two rows.',posXtx(k))
	assert(~any(cellfun('isempty',varXtx{k}(1,:))),...
		'SC:arbsort:Sequence:EmptyText',...
		'Input %d: this sequence contains zero-length match text.',posXtx(k))
	if any(ixtSqL) % literal interpretation
		varXtx{k}(1,:) = regexptranslate('escape',varXtx{k}(1,:));
	end
end
%
%% Sequence Matching %%
%
isDia = any(ixtDiM); % dia
%
if any(ixtMaW) % whole
	fmtMaX = '^(%s)$';
	isPart = false;
else % partial match
	fmtMaX = '(%s)';
	isPart = true;
end
%
if any(ixtChC) % case
	optChC = varTxt{ixtChC};
else
	optChC = 'ignorecase';
end
%
if any(ixtDrn) % direction
	optDrn = varTxt{ixtDrn};
else
	optDrn = 'ascend';
end
%
if numel(C)
	[outArr,outCnt] = asRecFun(C,1,varXtx);
else
	outArr = {};
	outCnt = [];
end
%
numCol = size(outArr,2);
numRow = size(outArr,1);
%
if nargout>2
	seq = real(outCnt);
	idp = seq>0;
	seq(idp) = posXtx(seq(idp));
	dbg = outArr;
	dbg(cellfun('isempty',dbg)) = {[]};
end
%
%% Sort Columns %%
%
ndx = 1:numRow;
%
for ii = numCol:-1:1
	oneCol = outArr(ndx,ii);
	if imag(outCnt(ii))>0 % match (function)
		oneCol(cellfun('isempty',oneCol)) = {NaN};
		[~,idxCol] = sort([oneCol{:}],optDrn);
	elseif real(outCnt(ii)) % match (text sequence)
		varCnt = real(outCnt(ii));
		varSeq = varXtx{varCnt};
		if imag(outCnt(ii))<0 % dotted I | dotless i
			oneCol = asIReplace(oneCol,'','');
			varSeq = asIReplace(varSeq,'(',')');
		end
		rgxSeq = strcat('^(',varSeq,')$');
		idxSeq = zeros(size(ndx));
		for jj = 1:numRow
			ixnSeq = find(~cellfun('isempty',regexp(oneCol{jj},rgxSeq,optChC)));
			switch numel(ixnSeq)
				case 0
					% do nothing
				case 1
					idxSeq(jj) = ixnSeq;
				otherwise
					error('SC:arbsort:Sequence:MultipleMatches',...
						['Input %d: this sequence returned multiple ',...
						'matches. The following sequence elements\n%s',...
						'all matched the following text:\n "%s"'],...
						posXtx(varCnt), sprintf(' "%s"\n',varSeq{ixnSeq}), oneCol{jj})
			end
		end
		[~,idxCol] = sort(idxSeq,optDrn);
	else % zero == split text
		if strcmpi(optChC,'ignorecase')
			oneCol = lower(oneCol);
		end
		if strcmpi(optDrn,'descend')
			[~,idxCol] = sort(asGroups(oneCol),'descend');
		else % SORT: "direction is not supported when A is a cell array"
			[~,idxCol] = sort(oneCol); % ascend
		end
	end
	ndx = ndx(idxCol);
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
	function [intArr,intCnt] = asRecFun(intArr,recCnt,varTmp)
		% Recursively match and split text using regular expressions or function handles.
		if numel(varTmp)
			varOne = varTmp{1};
			if isa(varOne,'function_handle') % sequence
				matCoS = cell(size(intArr));
				splCoS = matCoS;
				[op1,op2] = cellfun(varOne,intArr,'uni',0);
				for kk = 1:numel(intArr)
					if isPart || isequal(op2{kk},{'',''})
						matCoS{kk} = num2cell(double(op1{kk}));
						splCoS{kk} = cellstr(op2{kk});
					else % whole
						splCoS{kk} = intArr(kk);
					end
				end
				img = +i; %#ok<IJCL>
			elseif size(varOne,1)<2 % text sequence
				img = 0;
				tmp = asSentinals(varOne,posXtx(recCnt));
				rgx = sprintf('|%s',tmp{:});
				spl = regexp(rgx(2:end),'\|','split');
				assert(numel(unique(spl))==numel(spl),...
					'SC:arbsort:Sequence:DuplicateExpressions',...
					'Input %d: the provided sequence has duplicate match text (expressions).',posXtx(recCnt))
				[~,idx] = sort(cellfun('length',spl),'descend');
				rgx = sprintf('|%s',spl{idx});
				rgx = sprintf(fmtMaX,asLiterals(rgx(2:end)));
				if ~isDia && numel(varTmp)<2
					isDia = true; % no need to trim again
					[intArr,rgx,img] = asTrimDia(intArr,rgx,optChC,[varOne{:}]);
				end
				[matCoS,splCoS] = regexp(intArr,rgx,'match','split',optChC);
			else % match and replace substrings
				intArr = regexprep(intArr,varOne(1,:),varOne(2,:),optChC);
				[intArr,intCnt] = asRecFun(intArr,recCnt+1,varTmp(2:end));
				return
			end
			maxCol = max(cellfun('length',splCoS));
			matMat = repmat({''},numel(intArr),maxCol);
			splMat = repmat({''},numel(intArr),maxCol);
			for kk = 1:numel(intArr)
				matVec = matCoS{kk}(:); % match
				splVec = splCoS{kk}(:); % split
				assert(numel(splVec)==(1+numel(matVec)),...
					'SC:arbsort:Sequence:FunctionOutputLengths',...
					'Input %d: the function outputs must have N and N+1 elements.',posXtx(recCnt))
				matMat(kk,1:numel(matVec)) = matVec;
				splMat(kk,1:numel(splVec)) = splVec;
			end
			matTmp = cell(2,maxCol);
			cntTmp = cell(2,maxCol);
			for kk = 1:maxCol
				[matTmp{1,kk},cntTmp{1,kk}] = asRecFun(splMat(:,kk),recCnt+1,varTmp(2:end));
				matTmp{2,kk} = matMat(:,kk);
				cntTmp{2,kk} = recCnt+img;
			end
			intArr = [matTmp{:}];
			intCnt = [cntTmp{:}];
		elseif isDia % match diacritics
			intCnt = 0;
		else % trim / ignore diacritics
			intCnt = 0;
			intArr = asTrimDia(intArr);
		end
		outIxE = all(cellfun('isempty',intArr),1);
		intArr(:,outIxE) = [];
		intCnt(:,outIxE) = [];
	end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%arbsort
function txt = asLiterals(txt) % 0 -> |, 1-> \|, 2 -> \(, 3 -> \)
txt = regexprep(txt,num2cell(char(0:3)),{'|','\|','\(','\)'});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asLiterals
function arr = asSentinals(arr,cnt) % | -> 0, \| -> 1, \( -> 2, \) -> 3
arr = regexprep(arr,'(?<!\\)(?:\\\\)*\\([|()])','${char(mod($1,17)-4)}');
arr = cellfun(@asGrpCheck,arr,num2cell(complex(cnt,1:numel(arr))),'uni',0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asSentinals
function txt = asGrpCheck(txt,val)
inClass  = false;
outOpen  = false;
outClose = false;
gdp = 0;
nmc = numel(txt);
for k = 1:nmc
	c = txt(k);
	if ~inClass && c=='['
		inClass = true;
	elseif inClass
		if c==']'
			inClass = false;
		end
	elseif c=='('
		gdp = gdp + 1;
		if gdp==1
			outOpen = (k==1);
		end
	elseif c==')'
		gdp = gdp - 1;
		if gdp==0
			outClose = (k==nmc);
		end
	elseif c=='|' && gdp>0
		txt(k) = 0;
	end
end
%
assert(~outOpen || ~outClose || gdp>0,...
	'SC:arbsort:Sequence:ExpressionWithinGroup',...
	['Input %d: the provided sequence''s element %d is enclosed in parentheses.\n' ...
	'Sequence elements must not be wrapped in an outer group operator.'],real(val),imag(val))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asGrpCheck
function [txt,rgx,img] = asTrimDia(txt,rgx,optChC,optTxt)
% Trim diacritics from Latin, Greek, & Cyrillic characters within the domain [32,65535].
img = 0;
unc = [304,305,567,192,193,194,195,196,197,199,200,201,202,203,204,205,206,207,209,210,211,212,213,214,217,218,219,220,221,224,225,226,227,228,229,231,232,233,234,235,236,237,238,239,241,242,243,244,245,246,249,250,251,252,253,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,296,297,298,299,300,301,302,303,308,309,310,311,313,314,315,316,317,318,323,324,325,326,327,328,332,333,334,335,336,337,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,380,381,382,416,417,431,432,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,478,479,480,481,482,483,486,487,488,489,490,491,492,493,494,496,500,501,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,542,543,550,551,552,553,554,555,556,557,558,559,560,561,562,563,902,904,905,906,908,910,911,912,938,939,940,941,942,943,944,970,971,972,973,974,979,980,1024,1025,1027,1031,1036,1037,1038,1049,1081,1104,1105,1107,1111,1116,1117,1118,1142,1143,1217,1218,1232,1233,1234,1235,1238,1239,1242,1243,1244,1245,1246,1247,1250,1251,1252,1253,1254,1255,1258,1259,1260,1261,1262,1263,1264,1265,1266,1267,1268,1269,1272,1273,7680,7681,7682,7683,7684,7685,7686,7687,7688,7689,7690,7691,7692,7693,7694,7695,7696,7697,7698,7699,7700,7701,7702,7703,7704,7705,7706,7707,7708,7709,7710,7711,7712,7713,7714,7715,7716,7717,7718,7719,7720,7721,7722,7723,7724,7725,7726,7727,7728,7729,7730,7731,7732,7733,7734,7735,7736,7737,7738,7739,7740,7741,7742,7743,7744,7745,7746,7747,7748,7749,7750,7751,7752,7753,7754,7755,7756,7757,7758,7759,7760,7761,7762,7763,7764,7765,7766,7767,7768,7769,7770,7771,7772,7773,7774,7775,7776,7777,7778,7779,7780,7781,7782,7783,7784,7785,7786,7787,7788,7789,7790,7791,7792,7793,7794,7795,7796,7797,7798,7799,7800,7801,7802,7803,7804,7805,7806,7807,7808,7809,7810,7811,7812,7813,7814,7815,7816,7817,7818,7819,7820,7821,7822,7823,7824,7825,7826,7827,7828,7829,7830,7831,7832,7833,7835,7840,7841,7842,7843,7844,7845,7846,7847,7848,7849,7850,7851,7852,7853,7854,7855,7856,7857,7858,7859,7860,7861,7862,7863,7864,7865,7866,7867,7868,7869,7870,7871,7872,7873,7874,7875,7876,7877,7878,7879,7880,7881,7882,7883,7884,7885,7886,7887,7888,7889,7890,7891,7892,7893,7894,7895,7896,7897,7898,7899,7900,7901,7902,7903,7904,7905,7906,7907,7908,7909,7910,7911,7912,7913,7914,7915,7916,7917,7918,7919,7920,7921,7922,7923,7924,7925,7926,7927,7928,7929,7936,7937,7938,7939,7940,7941,7942,7943,7944,7945,7946,7947,7948,7949,7950,7951,7952,7953,7954,7955,7956,7957,7960,7961,7962,7963,7964,7965,7968,7969,7970,7971,7972,7973,7974,7975,7976,7977,7978,7979,7980,7981,7982,7983,7984,7985,7986,7987,7988,7989,7990,7991,7992,7993,7994,7995,7996,7997,7998,7999,8000,8001,8002,8003,8004,8005,8008,8009,8010,8011,8012,8013,8016,8017,8018,8019,8020,8021,8022,8023,8025,8027,8029,8031,8032,8033,8034,8035,8036,8037,8038,8039,8040,8041,8042,8043,8044,8045,8046,8047,8048,8049,8050,8051,8052,8053,8054,8055,8056,8057,8058,8059,8060,8061,8064,8065,8066,8067,8068,8069,8070,8071,8072,8073,8074,8075,8076,8077,8078,8079,8080,8081,8082,8083,8084,8085,8086,8087,8088,8089,8090,8091,8092,8093,8094,8095,8096,8097,8098,8099,8100,8101,8102,8103,8104,8105,8106,8107,8108,8109,8110,8111,8112,8113,8114,8115,8116,8118,8119,8120,8121,8122,8123,8124,8130,8131,8132,8134,8135,8136,8137,8138,8139,8140,8144,8145,8146,8147,8150,8151,8152,8153,8154,8155,8160,8161,8162,8163,8164,8165,8166,8167,8168,8169,8170,8171,8172,8178,8179,8180,8182,8183,8184,8185,8186,8187,8188,8491];
asc = [073,105,106,065,065,065,065,065,065,067,069,069,069,069,073,073,073,073,078,079,079,079,079,079,085,085,085,085,089,097,097,097,097,097,097,099,101,101,101,101,105,105,105,105,110,111,111,111,111,111,117,117,117,117,121,121,065,097,065,097,065,097,067,099,067,099,067,099,067,099,068,100,069,101,069,101,069,101,069,101,069,101,071,103,071,103,071,103,071,103,072,104,073,105,073,105,073,105,073,105,074,106,075,107,076,108,076,108,076,108,078,110,078,110,078,110,079,111,079,111,079,111,082,114,082,114,082,114,083,115,083,115,083,115,083,115,084,116,084,116,085,117,085,117,085,117,085,117,085,117,085,117,087,119,089,121,089,090,122,090,122,090,122,079,111,085,117,065,097,073,105,079,111,085,117,085,117,085,117,085,117,085,117,065,097,065,097,198,230,071,103,075,107,079,111,079,111,439,106,071,103,078,110,065,097,198,230,216,248,065,097,065,097,069,101,069,101,073,105,073,105,079,111,079,111,082,114,082,114,085,117,085,117,083,115,084,116,072,104,065,097,069,101,079,111,079,111,079,111,079,111,089,121,913,917,919,921,927,933,937,953,921,933,945,949,951,953,965,953,965,959,965,969,978,978,1045,1045,1043,1030,1050,1048,1059,1048,1080,1077,1077,1075,1110,1082,1080,1091,1140,1141,1046,1078,1040,1072,1040,1072,1045,1077,1240,1241,1046,1078,1047,1079,1048,1080,1048,1080,1054,1086,1256,1257,1069,1101,1059,1091,1059,1091,1059,1091,1063,1095,1067,1099,0065,0097,0066,0098,0066,0098,0066,0098,0067,0099,0068,0100,0068,0100,0068,0100,0068,0100,0068,0100,0069,0101,0069,0101,0069,0101,0069,0101,0069,0101,0070,0102,0071,0103,0072,0104,0072,0104,0072,0104,0072,0104,0072,0104,0073,0105,0073,0105,0075,0107,0075,0107,0075,0107,0076,0108,0076,0108,0076,0108,0076,0108,0077,0109,0077,0109,0077,0109,0078,0110,0078,0110,0078,0110,0078,0110,0079,0111,0079,0111,0079,0111,0079,0111,0080,0112,0080,0112,0082,0114,0082,0114,0082,0114,0082,0114,0083,0115,0083,0115,0083,0115,0083,0115,0083,0115,0084,0116,0084,0116,0084,0116,0084,0116,0085,0117,0085,0117,0085,0117,0085,0117,0085,0117,0086,0118,0086,0118,0087,0119,0087,0119,0087,0119,0087,0119,0087,0119,0088,0120,0088,0120,0089,0121,0090,0122,0090,0122,0090,0122,0104,0116,0119,0121,0383,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0065,0097,0069,0101,0069,0101,0069,0101,0069,0101,0069,0101,0069,0101,0069,0101,0069,0101,0073,0105,0073,0105,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0079,0111,0085,0117,0085,0117,0085,0117,0085,0117,0085,0117,0085,0117,0085,0117,0089,0121,0089,0121,0089,0121,0089,0121,0945,0945,0945,0945,0945,0945,0945,0945,0913,0913,0913,0913,0913,0913,0913,0913,0949,0949,0949,0949,0949,0949,0917,0917,0917,0917,0917,0917,0951,0951,0951,0951,0951,0951,0951,0951,0919,0919,0919,0919,0919,0919,0919,0919,0953,0953,0953,0953,0953,0953,0953,0953,0921,0921,0921,0921,0921,0921,0921,0921,0959,0959,0959,0959,0959,0959,0927,0927,0927,0927,0927,0927,0965,0965,0965,0965,0965,0965,0965,0965,0933,0933,0933,0933,0969,0969,0969,0969,0969,0969,0969,0969,0937,0937,0937,0937,0937,0937,0937,0937,0945,0945,0949,0949,0951,0951,0953,0953,0959,0959,0965,0965,0969,0969,0945,0945,0945,0945,0945,0945,0945,0945,0913,0913,0913,0913,0913,0913,0913,0913,0951,0951,0951,0951,0951,0951,0951,0951,0919,0919,0919,0919,0919,0919,0919,0919,0969,0969,0969,0969,0969,0969,0969,0969,0937,0937,0937,0937,0937,0937,0937,0937,0945,0945,0945,0945,0945,0945,0945,0913,0913,0913,0913,0913,0951,0951,0951,0951,0951,0917,0917,0919,0919,0919,0953,0953,0953,0953,0953,0953,0921,0921,0921,0921,0965,0965,0965,0965,0961,0961,0965,0965,0933,0933,0933,0933,0929,0969,0969,0969,0969,0969,0927,0927,0937,0937,0937,0065];
if nargin>1
	if any(optTxt==304) || any(optTxt==305) % dotted I | dotless i
		img = -i; %#ok<IJCL>
		idi = unc==304 | unc==305;
		unc(idi) = [];
		asc(idi) = [];
		txt = asIReplace(txt,'','');
		rgx = asIReplace(rgx,'(',')');
	end
	tmp = sprintf('\0%s',sprintf('%c\0',unc));
	idx = regexp(tmp,rgx,optChC)./2;
	%idx = ~cellfun('isempty',regexpi(num2cell(char(unc)),rgx,optChC));
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
function str = asIReplace(str,l,r)
% Substitute dotted/dotless I chars with sentinel tokens for REGEXP.
str = strrep(str, char(304), sprintf('%s\1X\2%s',l,r)); % İ uppercase dotted
str = strrep(str, char(073), sprintf('%s\3X\2%s',l,r)); % I uppercase dotless
str = strrep(str, char(105), sprintf('%s\1x\2%s',l,r)); % i lowercase dotted
str = strrep(str, char(305), sprintf('%s\3x\2%s',l,r)); % ı lowercase dotless
% Case-insensitive REGEXP matches dotless I to dotted i. However, in both
% Azerbaijani & Turkish {İ,i} are the dotted pair and {I,ı} the dotless
% pair. Replace each of the four chars with sentinel tokens which REGEXP
% can case-sensitively match under Azerbaijani & Turkish collation rules.
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%asIReplace
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