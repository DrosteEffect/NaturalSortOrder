function [B,ndx,dbg] = natsort(A,rgx,varargin)
% Natural-order / alphanumeric sort the elements of a text array.
%
% (c) 2012-2026 Stephen Cobeldick
%
% Sorts text by character code and by number value. By default matches
% integer substrings and performs a case-insensitive ascending sort.
% Options to select the number format, sort order, case sensitivity, etc.
%
%   >> A = ["x2", "x10", "x1"];
%   >> natsort(A)
%   ans =   "x1"  "x2"  "x10"
%
%%% Syntax:
%  B = natsort(A)
%  B = natsort(A,rgx)
%  B = natsort(A,rgx,<options>)
% [B,ndx,dbg] = natsort(A,...)
%
% To sort any file-names or folder-names use NATSORTFILES (File Exchange 47434)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort string/cells using custom sequences use ARBSORT (File Exchange 132263)
% GitHub repository: <https://github.com/DrosteEffect/NaturalSortOrder>
%
%% Number Format %%
%
% The **default regular expression '\d+' matches consecutive digit
% characters, i.e. integer numbers. Specifying the optional regular
% expression allows the numbers to include a +/- sign, decimal point/comma,
% decimal fraction digits, exponent E-notation, character quantifiers,
% or lookarounds. For information on defining regular expressions:
% <http://www.mathworks.com/help/matlab/matlab_prog/regular-expressions.html>
% For example, to match leading/trailing whitespace prepend/append '\s*'.
%
% The number substrings are parsed by SSCANF into numeric values, using
% either the **default format '%f' or the user-supplied format specifier.
% Both decimal comma and decimal point are accepted. The '%b' and '%lb'
% formats use custom bitwise routines rather than a direct SSCANF call.
%
% This table shows examples of some regular expression patterns for common
% notations and ways of writing numbers, together with suitable SSCANF formats:
%
% Regular       | Number Substring | Number Substring              | SSCANF
% Expression:   | Match Examples:  | Match Description:            | Format Specifier:
% ==============|==================|===============================|=====================
% **        \d+ | 0, 123, 4, 56789 | unsigned whole number         | %f  %u  %lu  %i  %li
% --------------|------------------|-------------------------------|---------------------
%      [+-]?\d+ | +1, 23, -45, 678 | whole with optional +/- sign  | %f  %d  %ld  %i  %li
% --------------|------------------|-------------------------------|---------------------
%     \d+\.?\d* | 012, 3.45, 678.9 | optional decimal digits       | %f
% (\d+|Inf|NaN) | 123, 4, NaN, Inf | whole number or Inf or NaN    | %f
%  \d+E[+-]?\d+ | 123e+004, 567e08 | exponential notation          | %f
% --------------|------------------|-------------------------------|---------------------
%  0x[0-9A-F]+  | 0x0, 0x3E7, 0xFF | unsigned hexadecimal & prefix | %x  %lx  %i  %li
%    [0-9A-F]+  |   0,   3E7,   FF | unsigned hexadecimal          | %x  %lx
% --------------|------------------|-------------------------------|---------------------
%  0o[0-7]+     | 0o1, 0o234, 0o07 | unsigned octal & prefix       | %o  %lo  %i  %li
%    [0-7]+     |   1,   234,   07 | unsigned octal                | %o  %lo
% --------------|------------------|-------------------------------|---------------------
%  0b[01]+      | 0b1, 0b101, 0b10 | unsigned binary & prefix      | %b  %lb  (custom)
%    [01]+      |   1,   101,   10 | unsigned binary               | %b  %lb  (custom)
% --------------|------------------|-------------------------------|---------------------
%
%% Debugging Output Array %%
%
% The third output is a cell array <dbg>, for checking how the numbers
% were matched by the regular expression <rgx> and converted to numeric
% by the SSCANF format. The rows of <dbg> are linearly indexed from
% the first input argument <A>.
%
% >> [~,~,dbg] = natsort(A)
% dbg =
%    'x'    [ 2]
%    'x'    [10]
%    'x'    [ 1]
%
%% Examples %%
%
%%% Multiple integers (e.g. release version numbers):
% >> Aa = {'v10.6', 'v9.10', 'v9.5', 'v10.10', 'v9.10.20', 'v9.10.8'};
% >> sort(Aa) % ASCIIbetical.
% ans =   'v10.10'  'v10.6'  'v9.10'  'v9.10.20'  'v9.10.8'  'v9.5'
% >> natsort(Aa)
% ans =   'v9.5'  'v9.10'  'v9.10.8'  'v9.10.20'  'v10.6'  'v10.10'
%
%%% Integer, decimal, NaN, or Inf numbers, possibly with +/- signs:
% >> Ab = {'test+NaN', 'test11.5', 'test-1.4', 'test', 'test-Inf', 'test+0.3'};
% >> sort(Ab) % ASCIIbetical.
% ans =   'test' 'test+0.3' 'test+NaN' 'test-1.4' 'test-Inf' 'test11.5'
% >> natsort(Ab, '[+-]?(NaN|Inf|\d+\.?\d*)')
% ans =   'test' 'test-Inf' 'test-1.4' 'test+0.3' 'test11.5' 'test+NaN'
%
%%% Integer or decimal numbers, possibly with an exponent:
% >> Ac = {'0.56e007', '', '43E-2', '10000', '9.8'};
% >> sort(Ac) % ASCIIbetical.
% ans =   ''  '0.56e007'  '10000'  '43E-2'  '9.8'
% >> natsort(Ac, '[+-]?\d+\.?\d*([eE][+-]?\d+)?')
% ans =   ''  '43E-2'  '9.8'  '10000'  '0.56e007'
%
%%% Hexadecimal numbers (with '0X' prefix):
% >> Ad = {'a0X7C4z', 'a0X5z', 'a0X18z', 'a0XFz'};
% >> sort(Ad) % ASCIIbetical.
% ans =   'a0X18z'  'a0X5z'  'a0X7C4z'  'a0XFz'
% >> natsort(Ad, '0X[0-9A-F]+', '%i')
% ans =   'a0X5z'  'a0XFz'  'a0X18z'  'a0X7C4z'
%
%%% Binary numbers:
% >> Ae = {'a11111000100z', 'a101z', 'a000000000011000z', 'a1111z'};
% >> sort(Ae) % ASCIIbetical.
% ans =   'a000000000011000z'  'a101z'  'a11111000100z'  'a1111z'
% >> natsort(Ae, '[01]+', '%b')
% ans =   'a101z'  'a1111z'  'a000000000011000z'  'a11111000100z'
%
%%% Case sensitivity:
% >> Af = {'a2', 'A20', 'A1', 'a10', 'A2', 'a1'};
% >> natsort(Af, [], 'ignorecase') % default
% ans =   'A1'  'a1'  'a2'  'A2'  'a10'  'A20'
% >> natsort(Af, [], 'matchcase')
% ans =   'A1'  'A2'  'A20'  'a1'  'a2'  'a10'
%
%%% Sort order:
% >> Ag = {'2', 'a', '', '3', 'B', '1'};
% >> natsort(Ag, [], 'ascend') % default
% ans =   ''   '1'  '2'  '3'  'a'  'B'
% >> natsort(Ag, [], 'descend')
% ans =   'B'  'a'  '3'  '2'  '1'  ''
% >> natsort(Ag, [], 'num<char') % default
% ans =   ''   '1'  '2'  '3'  'a'  'B'
% >> natsort(Ag, [], 'char<num')
% ans =   ''   'a'  'B'  '1'  '2'  '3'
%
%%% UINT64 numbers (with full precision):
% >> natsort({'a18446744073709551615z', 'a18446744073709551614z'}, [], '%lu')
% ans =       'a18446744073709551614z'  'a18446744073709551615z'
% >> u64 = intmax('uint64');
% >> natsort({dec2bin(u64-1,64);dec2bin(u64,64)}, '[01]+', '%lb')
% ans = '1111111111111111111111111111111111111111111111111111111111111110'
%       '1111111111111111111111111111111111111111111111111111111111111111'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array to be sorted. Can be a string array, or a cell array of
%       character row vectors, or a categorical array, or a datetime array,
%       or any other array type which can be converted by CELLSTR.
% rgx = Optional regular expression to match number substrings.
%     = [] uses the default regular expression '\d+'** to match integers.
% <options> can be entered in any order, as many as required:
%     = Sort direction: 'descend'/'ascend'**
%     = Character case handling: 'matchcase'/'ignorecase'**
%     = Character/number order: 'char<num'/'num<char'**
%     = NaN/number order: 'NaN<num'/'num<NaN'**
%     = SSCANF conversion format: e.g. '%x', '%i', '%li', '%f'**, etc.
%       Binary formats '%lb' (R2012a or later) and '%b' use custom parsing.
%     = Function handle of a function that sorts text. It must accept one
%       input, which is a cell array of char vectors (the text array to
%       be sorted). It must return as its 2nd output the sort indices.
%
%%% Outputs:
% B   = Array <A> sorted into natural sort order.     The same size as <A>.
% ndx = NumericArray, generally such that B = A(ndx). The same size as <A>.
% dbg = CellArray of the parsed characters and number values. Each row
%       corresponds to one input element of <A>, in linear-index order.
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
%
% See also SORT NATSORT_TEST NATSORTFILES NATSORTROWS ARBSORT
% IREGEXP REGEXP COMPOSE STRING STRINGS CATEGORICAL CELLSTR SSCANF
fh0 = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
% Release | Feature
% --------|--------
% R2016b  |      string class                            [only if supplied]
% R2014b  |    datetime class                            [only if supplied]
% R2013b  | categorical class                            [only if supplied]
% R2012a  | sum(...,'native') option                      [only %lb format]
% R2009b  | tilde argument placeholder
% R2008a  | assert: message-identifier
% R2007b  | regexp/regexpi: cell array of char, once & match & split options
% R2007a  | bsxfun
%
%% Input Wrangling %%
%
if iscell(A)
	assert(all(fh0(A(:))),...
		'SC:natsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:natsort:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
%
chk = '(match|ignore)case|(de|a)scend(ing)?|(char|nan|num)[<>](char|nan|num)|%[a-z]{1,2}';
%
if nargin<2 || isnumeric(rgx)&&isequal(rgx,[])
	rgx = '\d+';
elseif ischar(rgx)
	assert(ndims(rgx)<3 && size(rgx,1)==1,...
		'SC:natsort:rgx:NotCharVector',...
		'Second input <rgx> character row vector must have size 1xN.') %#ok<ISMAT>
	nsChkRgx(rgx,chk)
else
	rgx = ns1s2c(rgx);
	assert(ischar(rgx),...
		'SC:natsort:rgx:InvalidType',...
		'Second input <rgx> must be a character row vector or a string scalar.')
	nsChkRgx(rgx,chk)
end
%
varargin = cellfun(@ns1s2c, varargin, 'UniformOutput',false);
ixv = fh0(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
% Sort direction:
tdd = strcmpi(txt,'descend');
tdx = strcmpi(txt,'ascend')|tdd;
% Character case:
tcm = strcmpi(txt,'matchcase');
tcx = strcmpi(txt,'ignorecase')|tcm;
% Char/num order:
ttn = strcmpi(txt,'num>char')|strcmpi(txt,'char<num');
ttx = strcmpi(txt,'num<char')|strcmpi(txt,'char>num')|ttn;
% NaN/num order:
ton = strcmpi(txt,'num>NaN')|strcmpi(txt,'NaN<num');
tox = strcmpi(txt,'num<NaN')|strcmpi(txt,'NaN>num')|ton;
% SSCANF format:
tsf = ~cellfun('isempty',regexp(txt,'^%([efgbdiuox]|l[bdiuox])$'));
%
nsAssert(txt, tdx, 'SortDirection', 'sort direction')
nsAssert(txt, tcx,  'CaseMatching', 'case sensitivity')
nsAssert(txt, ttx,  'CharNumOrder', 'number-character order')
nsAssert(txt, tox,   'NanNumOrder', 'number-NaN order')
nsAssert(txt, tsf,  'sscanfFormat', 'SSCANF format')
%
ixx = tdx|tcx|ttx|tox|tsf;
if ~all(ixx)
	error('SC:natsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s'],sprintf(' "%s"',txt{~ixx}))
end
%
% SSCANF format:
if any(tsf)
	fmt = txt{tsf};
else
	fmt = '%f';
end
%
xfh = cellfun('isclass',xtx,'function_handle');
assert(nnz(xfh)<2,...
	'SC:natsort:FunctionHandle:Overspecified',...
	'The function handle option may only be specified once.')
assert(all(xfh),...
	'SC:natsort:InvalidOptions',...
	'Optional arguments must be character row vectors, string scalars, or function handles.')
if any(xfh)
	txfh = xtx{xfh};
end
%
%% Identify and Convert Numbers %%
%
[nbr,spl] = regexpi(C(:), rgx, 'match','split', txt{tcx});
%
if numel(nbr)
	tmp = [nbr{:}];
	if strcmpi(fmt,'%b') % binary double
		tmp = regexprep(tmp,'^0[Bb]','');
		vec = cellfun(@(s)pow2(numel(s)-1:-1:0) * sscanf(s,'%1d'), tmp);
	elseif strcmpi(fmt,'%lb') % binary uint64
		tmp = regexprep(tmp,'^0[Bb]','');
		fh1 = @(d) sum(d .* bitshift(uint64(1), numel(d)-1:-1:0), 'native');
		vec = cellfun(@(s)fh1(sscanf(s,'%1lu',[1,Inf])), tmp);
	else % double or uint64
		if any(strcmpi(fmt,{'%o','%lo','%i','%li'}))
			tmp = regexprep(tmp,'^0[Oo]','0'); % octal prefix
		end
		vec = sscanf(strrep(sprintf(' %s','0',tmp{:}),',','.'),fmt);
		vec = vec(2:end); % SSCANF wrong data class bug (R2009b and R2010b)
	end
	assert(numel(vec)==numel(tmp),...
		'SC:natsort:sscanf:ParsedValueMismatch',...
		'The "%s" format must return one value for each input number.',fmt)
else
	vec = [];
end
%
%% Allocate Data %%
%
% Determine lengths:
nmx = numel(C);
lnn = cellfun('length',nbr);
lns = cellfun('length',spl);
mxs = max(lns);
%
% Allocate data:
idn = permute(bsxfun(@le,1:mxs,lnn),[2,1]); % TRANSPOSE lost class bug (R2013b)
ids = permute(bsxfun(@le,1:mxs,lns),[2,1]); % TRANSPOSE lost class bug (R2013b)
arn = zeros(mxs,nmx,class(vec));
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(ids) = [spl{:}];
arn(idn) = vec;
%
%% Debugging Array %%
%
if nargout>2
	dbg = cell(nmx,0);
	for k = 1:nmx
		v = spl{k};
		v(2,:) = [num2cell(arn(idn(:,k),k));{[]}];
		v(cellfun('isempty',v)) = [];
		dbg(k,1:numel(v)) = v;
	end
end
%
%% Sort Matrices %%
%
if ~any(tcm) % ignorecase
	ars = lower(ars);
end
%
if any(ttn) % char<num
	% Determine max character code:
	wrn = warning('off','all');
	mxc = char(0);
	mxc(1) = Inf; % MATLAB
	mxc(~mxc) = 255; % Octave
	warning(wrn)
	% Append max character code to the split text:
	for ii = reshape(find(idn),1,[])
		ars{ii}(1,end+1) = mxc;
	end % FOR-loop is faster than STRCAT:
	%ars(idn) = strcat(ars(idn),mxc);
	% MATLAB has no custom comparator, so instead we append the maximum
	% character code to make text sort before numeric values.
end
%
idn(isnan(arn)) = ~any(ton); % NaN<num
%
if any(xfh) % external text-sorting function
	[~,ndx] = txfh(ars(mxs,:));
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = txfh(ars(ii,ndx));
		ndx = ndx(idx);
	end
elseif any(tdd)
	[~,ndx] = sort(nsGroups(ars(mxs,:)),'descend');
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(nsGroups(ars(ii,ndx)),'descend');
		ndx = ndx(idx);
	end
else
	[~,ndx] = sort(ars(mxs,:)); % ascend
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(ars(ii,ndx)); % ascend
		ndx = ndx(idx);
	end
end
%
%% Outputs %%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsort
function grp = nsGroups(vec)
% Groups in a cell array of char vectors, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true(1,numel(vec)>0),~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsGroups
function nsChkRgx(rgx,chk)
% Perform some basic sanity-checks on the supplied regular expression.
chk = sprintf('^(%s)$',chk);
assert(isempty(regexpi(rgx,chk,'once')),...
	'SC:natsort:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided input "%s" looks like an optional argument (inputs 3+).'],rgx)
if isempty(regexpi('0',rgx,'once'))
	warning('SC:natsort:rgx:SanityCheck',...
		['Second input <rgx> must be a regular expression that matches numbers.',...
		'\nThe provided regular expression does not match the digit "0", which\n',...
		'may be acceptable (e.g. if literals, quantifiers, or lookarounds are used).'...
		'\nThe provided regular expression: "%s"'],rgx)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsChkRgx
function nsAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsort:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsAssert
function arr = ns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ns1s2c