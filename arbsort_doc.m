%% |ARBSORT| Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/132263
% |ARBSORT|> sorts the elements of the input array |A| into the order
% the provided custom/arbitrary text sequences (aka _custom lists_).
%
% |ARBSORT| was inspired by MS Excel's
% <https://support.microsoft.com/en-us/office/sort-data-using-a-custom-list-cba3d67a-c5cb-406f-9b14-a02205834d72
% _custom list_ sorting feature>. By default |ARBSORT| performs
% case-insensitive partial matches of the text in |A| using powerful
% regular expressions, for any number of sequences.
% Multiple sequences and/or replacement arrays are matched to |A| in their
% input order: any unmatched text in |A| is sorted into character order,
% by default ignoring any diacritics on unmatched alphabetic characters.
%
% While |ARBSORT| offers some basic functionality for alphabetical sorting,
% it is beyond the scope of my small project to provide language-specific
% collation rules, e.g. identify compound words, identify word roots,
% split ligatures, provide reverse sorting of accented characters, etc.
%
% Note that MATLAB's inbuilt
% <https://www.mathworks.com/help/matlab/ref/sort.html |SORT|> function
% sorts text by <https://www.mathworks.com/help/matlab/matlab_prog/unicode-and-ascii-values.html
% character code>, as does |SORT| in most programming languages.
%
% Other useful text sorting functions:
%
% * Alphanumeric sort of filenames, foldernames, and filepaths:
% <https://www.mathworks.com/matlabcentral/fileexchange/47434 |NATSORTFILES|>
% * Alphanumeric sort the rows of a string/cell/table/etc array:
% <https://www.mathworks.com/matlabcentral/fileexchange/47433 |NATSORTROWS|>
% * Alphanumeric sort of text in a string/cell/categorical array:
% <https://www.mathworks.com/matlabcentral/fileexchange/34464 |NATSORT|>
%% Basic Usage: Ignore Diacritics
% Common practice when sorting English text is that diacritics are ignored.
% By default |ARBSORT| performs a case-insensitive ascending sort of the
% input text array |A|, ignoring any diacritics. Compare for example:
Aa = ["Rosé","Rosy","Rosa","Rose"];
sort(Aa) % ASCIIbetical
arbsort(Aa)
%% Input 2+: Sequence Text Arrays
% A sequence is supplied as a |1xN| string array or |1xN| cell array of char
% vectors. By default |ARBSORT| interprets the sequence text as
% <https://www.mathworks.com/help/matlab/matlab_prog/regular-expressions.html
% regular expressions> and finds all matching substrings in |A|.
% Any unmatched text in |A| is sorted into
% <https://www.mathworks.com/help/matlab/matlab_prog/unicode-and-ascii-values.html
% character-code> order
% (by default ignoring any diacritics on the unmatched characters).
Ab = ["SmallTea";"MediumCoffee";"LargeTea";"SmallCoffee";"MediumTea";"LargeCoffee"]; % Array to sort...
Sb = ["small","medium","large"]; % ...into the order of this text sequence.
arbsort(Ab,Sb)
arbsort(Ab,Sb,["tea","coffee"]) % or more sequences.
%% Input 2+: Sequence Function Handles (e.g. |WORDS2NUM|)
% A sequence may be specified using a <https://www.mathworks.com/help/matlab/function-handles.html
% function handle>. The function must accept one input (text, either as a
% scalar string or a character vector) and return the following two outputs:
%
% # A numeric vector of |N| values corresponding to any matched text parts
%   (these values are used to sort the elements of |A|).
% # A cell array vector of |N+1| split text parts, i.e. the unmatched text.
%
% Note that the function handle is not called with any other inputs, so
% the function handle must be appropriately parameterized if required
% (e.g. for case sensitivity, partial/whole matching, etc.):
% <https://www.mathworks.com/help/matlab/math/parameterizing-functions.html>.
%
% The following example uses
% <https://www.mathworks.com/matlabcentral/fileexchange/52925 |WORDS2NUM|>
% to convert number names into numeric values, e.g. "twelve" -> 12:
Ac = ["test_one", "test_zero", "test_ninetynine", "test_two"];
arbsort(Ac, @words2num) % download WORDS2NUM from FEX 52925.
%% Input 2+: Replacement Text Array
% The sorting rules of some languages require that certain characters are
% sorted as if they were replaced by other characters. For example, in
% French the ligatures "æ" and "œ" are sorted as "ae" and "oe" respectively.
% A replacement text array is provided as a |2xM| string array or |2xM| cell
% array of char vectors: the first row consists of match text (by default
% interpreted as regular expressions) and the second row consists of the
% corresponding replacement text. For example:
Ad = ["bœuf","bæ","boz","boa","bzz","baa","baz"];
Rd = ["Æ", "Œ";... row1: match text
	"AE","OE"]; % row2: replacement text
sort(Ad) % ASCIIbetical
arbsort(Ad,Rd)
%% Input 2+: Partial/Whole Text Matching
% By default |ARBSORT| performs partial text matches, i.e. _parts_ of the
% text in |A| can match the sequence text. Specify the |'whole'| option
% to match only the _complete_ elements of |A| to the sequence text.
% Note that matched text is sorted before unmatched text, and unmatched
% text is sorted into character code order.
Ae = ["S", "Medium", "L", "Small", "Large", "M"];
Se = ["S","M","L"];
arbsort(Ae,Se, 'partial') % default
arbsort(Ae,Se, 'whole')
%% Input 2+: Case Sensitive/Insensitive Text Matching
% By default |ARBSORT| matches sequence text regardless of character case.
% The |'matchcase'| option may be specified to only match text with the
% same character case.
Af = ["S", "m", "L", "s", "l", "M"];
Sf = ["S","M","L"];
arbsort(Af,Sf, 'ignorecase') % default
arbsort(Af,Sf, 'matchcase')
%% Input 2+: Diacritic Sensitive/Insensitive Text Matching
% By default |ARBSORT| removes diacritics from any unmatched characters,
% just before sorting. This suits common practice in many languages, where
% diacritics (that might not be defined in that language) are ignored when
% sorting text. The |'matchdia'| option is used to sort letters (complete
% with diacritics) into character code order:
Ag = ["Zoë","Zoz","Zoa"];
arbsort(Ag, 'ignoredia') % default
arbsort(Ag, 'matchdia')
%% Input 2+: Literal/Regular Expression Text Matching
% By default |ARBSORT| treats the sequence text as regular expressions,
% to allow very compact, powerful sequence definitions. The |'literal'|
% option can be used to treat the sequence text literally.
Ah = ["_s","s"," s","\s"];
Sh = ["\s","s"];
arbsort(Ah,Sh, 'regexp') % default
arbsort(Ah,Sh, 'literal')
%% Output 2: Sort Index
% The 2nd output |ndx| is a numeric array of the sort indices,
% in general such that |B = A(ndx)| where |B = arbsort(A,...)|.
% Note that |ARBSORT| provides a _stable sort:_
Ai = ["testHigh","testLow","testMid","testLow"];
Si = ["low","mid","high"];
[out,ndx] = arbsort(Ai,Si)
%% Output 3: Parsed-Text Array
% The 3rd output |dbg| is an |RxC| cell array which contains both the
% matched and split text parts. This cell array is intended for debugging,
% by visually confirming that the content of |A| is being matched as
% expected by the provided sequences. The rows of |dbg| are
% <https://www.mathworks.com/company/newsletters/articles/matrix-indexing-in-matlab.html
% linearly indexed> from the input array |A| (i.e. |R=numel(A)|), the
% number of columns |C| depends on how many matches were made in the text
% of array |A|.
[~,~,dbg] = arbsort(Ai,Si)
%% Output 4: Sequence Vector
% The 4th output |seq| is a |1xC| numeric vector indicating which sequence
% (i.e. input array or function) corresponds to each column of the 3rd
% output |dbg|, where the values indicate the function input positions
% (e.g. 2 = 2nd input argument). A value of zero indicates that the text
% in the corresponding column of |dbg| was not matched by any sequence
% (i.e. the column contains split text).
[~,~,~,seq] = arbsort(Ai,Si)
%% Example: Alphabet Character Order
% Many languages do not sort correctly when sorted into ASCII/Unicode code
% order, particularly languages using diacritics, e.g. Spanish, Swedish,
% etc. Specify the alphabet as the final text sequence. By default
% unmatched alphabetic characters are sorted ignoring any diacritics:
Aj = ["yo", "os", "la", "ño", "va", "ni", "de", "ña"];
alfabeto = num2cell(['A':'N','Ñ','O':'Z']); % Spanish alphabet.
arbsort(Aj, alfabeto)
Ak = ["radio", "rana", "rastrillo", "ráfaga", "rápido"];
arbsort(Ak, alfabeto)
%% Example: Alphabet Equivalent Characters
% The power of regular expressions makes it easy to specify characters
% that are equivalent to each other. For example, the Dutch digraph "ij"
% (sometimes written using the ligature "ĳ") sorts either
%
% * between 'y' and 'z' (Winkler Prins order), or
% * equivalent to 'y' (telephone directory order).
%
% Both of these are easy to achieve (as two characters or ligature):
Al = ["Bruzn","Bruijn","Bruin","Bruyn","Bruijn"];
alfabet = [num2cell('A':'Y'),{'Ĳ|IJ','Z'}]; % Winkler Prins
arbsort(Al, alfabet)
alfabet = [num2cell('A':'X'),{'Ĳ|IJ|Y','Z'}]; % telephone
arbsort(Al, alfabet)
%% Example: Digraphs and Trigraphs
% Digraphs and trigraphs may be defined as part of the final alphabet 
% sequence. For example, Hungarian defines 'cs', 'dz', 'dzs' and various 
% other digraphs as letters of the alphabet. Reminder: my simple |ARBSORT|
% does not detect word roots, duplicated digraphs/trigraphs, etc.
abece = ["a|á","b","c","cs","d","dz","dzs","e|é","f","g","gy","h","i|í","j","k","l","ly","m","n","ny","o|ó","ö|ő","p","q","r","s","sz","t","ty","u|ú","ü|ű","v","w","x","y","z","zs"];
Ahu = ["apa", "asz", "csak", "cukor", "dzsungel", "dzűmmög", "ár"];
arbsort(Ahu,abece)
%% Example: Multiple Sequences
% Zero or more sequences may be provided. Sequences are matched to text
% of |A| in the same order as they are provided as inputs to |ARBSORT|.
% This example uses Swedish weeekday names and the Swedish alphabet:
Am = ["ö_Tis", "å_Tis", "a_Tis", "z_Tors", "z_Lör", "ä_Tis", "z_Mån"];
vardagar = ["Mån(dag)?","Tis(dag)?","Ons(dag)?","Tors(dag)?","Fre(dag)?","Lör(dag)?","Sön(dag)?"]; % weekdays
alfabet  = num2cell(['A':'Z','ÅÄÖ']); % Swedish alphabet.
arbsort(Am, vardagar, alfabet) % match weekday names first, then alphabet.
%% Example: Leading/Trailing Whitespace
% Text that is aligned and padded with whitespace can be sorted e.g. by
% appending/prepending |'\s*'| to the sequence regular expressions:
An = ['Y  large';'X medium';'Z  large';'X  small';'X  large'];
arbsort(An, ["\s*SMALL","\s*MEDIUM","\s*LARGE"])
%% Bonus: SI Prefixes with |SIP2NUM| or |BIP2NUM|
% |ARBSORT| may be used with the SI/binary prefix functions
% <https://www.mathworks.com/matlabcentral/fileexchange/53886 |SIP2NUM|
% and |BIP2NUM|>, both of which fulfill the requirements for a sequence
% defined via a function handle. For example:
Ao = ["test9.9µV","test10mV","test13nV","test2mV","test1nV"];
arbsort(Ao, @sip2num) % download SIP2NUM from FEX 53886.
%% Bonus: Arrays with |NATSORT| or |NATSORTFILES|
% |ARBSORT| may be used with
% <https://www.mathworks.com/matlabcentral/fileexchange/34464 |NATSORT|> or
% <https://www.mathworks.com/matlabcentral/fileexchange/47434 |NATSORTFILES|>
% to sort numbers into numeric order and the remaining text with |ARBSORT|:
Ap = ["Zoë 2.txt";"Zoz 1.txt";"Zoa 2";"Zoë 10.txt";"Zoa 10.txt";"Zoë 1.txt"];
natsortfiles(Ap, [], @arbsort) % download NATSORTFILES from FEX 47434.
%% Bonus: Tables with |NATSORTROWS|
% |ARBSORT| may be used with
% <https://www.mathworks.com/matlabcentral/fileexchange/47433 |NATSORTROWS|>,
% e.g. to sort the columns of a table into a arbitrary sequence order. This
% example is from <https://www.excel-easy.com/examples/custom-sort-order.html>
Tq = readtable('./html/excel-easy.xlsx')
Fq = @(t)arbsort(t,["HIGH","NORMAL","LOW"]);
natsortrows(Tq, [], 'Priority', Fq)
%% Bonus: Interactive Regular Expression Tool
% Regular expressions are powerful and compact, but getting them right is
% not always easy. One assistance is to download my interactive tool
% <https://www.mathworks.com/matlabcentral/fileexchange/48930 |IREGEXP|>,
% which lets you quickly try different regular expressions and see all of
% <https://www.mathworks.com/help/matlab/ref/regexp.html |REGEXP|>'s
% outputs displayed and updated as you type:
iregexp('x123y456789z','(\d)(\d*)') % download IREGEXP from FEX 48930.