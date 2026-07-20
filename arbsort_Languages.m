%% |ARBSORT| Language Examples
%
% This script showcases how |ARBSORT| can _improve_ sorting for various
% languages via user-specified alphabets, character replacements, and the
% default diacritic removal. For many languages these are improvements
% over naive sorting by character code order (as the inbuilt |SORT| does).
% |ARBSORT| is a lightweight, standalone tool designed to be practical
% and adaptable for everyday language sorting needs in MATLAB.
%
% Note: |ARBSORT| does not reproduce every detail of official collation
% standards, such as complex secondary, tertiary, or contextual rules, or
% rules based on identifying word roots, etc. For specification-level
% sorting (e.g. UCA), consider using dedicated internationalization tools.
%
%% |[af] Afrikaans --------------------------------------------- Afrikaans|
% Setup: the replacement maps both "ŉ" and "'n" to plain "n".
% Distinctions: "ŉ" ≡ "'n" (both sort as "n").
%
% Approximation: the CLDR tertiary rule placing "'n" after all "N" words
% is not reproduced; both forms sort identically as plain "n".
rpl = ["ŉ|'n";"n"]; % treat n-apostrophe "ŉ" like "n"
A = ["naam","veld","nuwe","'n","maan","ŉ"];
B = arbsort(A,rpl)
%% |[az] Azərbaycanca ---------------------------------------- Azerbaijani|
% Setup: the explicit alphabet places "Ə" immediately after "E",
% "X" between "H" and "I", and keeps dotless "I" before dotted "İ".
%
% Approximation: none.
abc = num2cell('ABCÇDEƏFGĞHXIİJKQLMNOÖPRSŞTUÜVYZ');
A = ["xətt","ev","ip","həm","əmək","ışıq"];
B = arbsort(A,abc)
%% |[cs] Čeština --------------------------------------------------- Czech|
% Setup: the explicit alphabet includes the digraph "CH" as a single
% letter immediately following "H".
%
% Approximation: none.
abc = [num2cell('AÁBCČDĎEÉĚFGH'),{'CH'},num2cell('IÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ')];
A = ["ruka","hora","čas","chyba","cena","řeka"];
B = arbsort(A,abc)
%% |[da] Dansk ---------------------------------------------------- Danish|
% Setup: the explicit alphabet places "Æ", "Ø", and "Å" after "Z".
% "Å" also matches "AA" via the regular expression pipe operator.
%
% Approximation: treating "AA" as equivalent to "Å" follows historical
% Danish convention; modern CLDR rules handle this differently.
abc = [num2cell(['A':'Z','ÆØ']),{'Å|AA'}];
A = ["zone","Aalborg","bane","Ålborg","æble","øre"];
B = arbsort(A,abc)
%% |[de] Deutsch -------------------------------------------------- German|
% Setup: Variante 1 maps only "ß"→"ss" and relies on the default diacritic
% removal to map the umlauts "ä", "ö", "ü" to "a", "o", "u" respectively.
% Variante 2 maps "ä"→"ae", "ö"→"oe", "ü"→"ue", "ß"→"ss" via replacements.
%
% In Austrian German the umlauts "ä", "ö", "ü" are treated as distinct
% characters and are sorted directly after "a", "o", "u" respectively.
%
% Approximation: "ß" is equivalent to "ss", rather than following "ss".
abc = num2cell(['aä','b':'o','öpqrstuüvwxyz']); % Austrian alphabet
rpl = ["ä", "ö", "ü", "ß";... row 1: match text
      "ae","oe","ue","ss"]; % row 2: replacement text
A = ["Goldmann","Götz","Goethe","Göbel","Göthe"];
B = arbsort(A,["ß";"ss"],abc)                         % Österreichisch
B = arbsort(A,["ß";"ss"])                             % DIN 5007 Variante 1
B = arbsort(A,rpl)                                    % DIN 5007 Variante 2
%% |[el] Ελληνικά -------------------------------------------------- Greek|
% Setup: the explicit alphabet covers all 24 Greek letters; accented vowels
% are handled by the default diacritic removal. The replacement maps final
% sigma "ς" to medial sigma "σ", so that they sort identically.
%
% Approximation: none.
rpl = ["ς";"σ"]; % final sigma treated as equivalent to medial sigma
abc = num2cell(['Α':'Ρ','Σ':'Ω']);
A = ["ωκεανός","αέρας","βιβλίο","μύλοσ","μύλος","ξύλο","ψάρι"];
B = arbsort(A,rpl,abc)
%% |[en] English ------------------------------------------------- English|
% Setup: uses |ARBSORT|'s default diacritic removal.
%
% Approximation: none.
A = ["Rosé","Rosy","Rosa","Rose"];
B = arbsort(A)
%% |[es] Español ------------------------------------------------- Spanish|
% Setup: the explicit alphabet inserts "Ñ" between "N" and "O".
%
% Approximation: none.
abc = num2cell(['A':'N','Ñ','O':'Z']);
A = ["ñu","oro","nube","campo","ñame","lima"];
B = arbsort(A,abc)
%% |[fi] Suomi --------------------------------------------------- Finnish|
% Setup: the explicit alphabet places "Å", "Ä", and "Ö" after "Z".
%
% Approximation: none.
abc = num2cell(['A':'Z','ÅÄÖ']);
A = ["talo","aalto","zebra","tähti","Åland","äiti","öljy"];
B = arbsort(A,abc)
%% |[fil] Filipino ---------------------------------------------- Filipino|
% Setup: the explicit alphabet places "Ñ" immediately after "N" and
% the digraph "NG" immediately after "Ñ", both before "O".
%
% Approximation: none.
abc = [num2cell('A':'N'),{'Ñ','NG'},num2cell('O':'Z')];
A = ["nipa","ñoño","ngayon","obra","lupa","mapa"];
B = arbsort(A,abc)
%% |[fr] Français ------------------------------------------------- French|
% Setup: the replacements expand the ligatures "Æ"→"AE" and "Œ"→"OE".
%
% Approximation: the official rule of reverse secondary ordering
% on diacritics is not reproduced.
rpl = ["Æ", "Œ";... row1: match text
	  "AE","OE"]; % row2: replacement text
A = ["bois","boa","carnet","bœuf","bonbon","cerf","Cæsar"];
B = arbsort(A,rpl)
%% |[hu] Magyar ------------------------------------------------ Hungarian|
% Setup: the explicit alphabet includes eight digraphs ("CS", "DZ", "GY",
% "LY", "NY", "SZ", "TY", "ZS") and one trigraph ("DZS"); accented vowels
% are grouped with their base letters using the pipe.
%
% Approximation: simplified geminates of multigraphs are not split into
% the two digraphs (e.g. "nny" is not decomposed into "ny"+"ny"), as this
% requires identifying word roots and is beyond the scope of ARBSORT.
abc = ["a|á","b","c","cs","d","dz","dzs","e|é","f","g","gy","h","i|í","j","k","l","ly","m","n","ny","o|ó","ö|ő","p","q","r","s","sz","t","ty","u|ú","ü|ű","v","w","x","y","z","zs"];
A = ["ép","sár","csak","szél","dzsem","dal","cukor","dzéta"];
B = arbsort(A,abc)
%% |[id] Bahasa Indonesia ------------------------------------- Indonesian|
% Setup: uses the default |ARBSORT| behaviour; the standard 26-letter
% Latin alphabet requires no special configuration.
%
% Approximation: none.
A = ["udara","nasi","mobil","buku","ikan","zakat","dari"];
B = arbsort(A)
%% |[it] Italiano ------------------------------------------------ Italian|
% Setup: uses the default |ARBSORT| behaviour; accented vowels are
% handled by the default diacritic removal.
%
% Approximation: none.
A = ["tè","sole","là","voglio","la","te"];
B = arbsort(A)
%% |[ms] Bahasa Melayu --------------------------------------------- Malay|
% Setup: uses the default |ARBSORT| behaviour; the standard 26-letter
% Latin alphabet requires no special configuration.
%
% Approximation: none.
A = ["ubat","meja","buku","kita","air","zaman","dari"];
B = arbsort(A)
%% |[nb] Norsk Bokmål ------------------------------------------ Norwegian|
% Setup: the explicit alphabet places "Æ", "Ø", and "Å" after "Z".
%
% Approximation: none.
abc = num2cell(['A':'Z','ÆØÅ']);
A = ["øre","ærlig","bane","ånd","aal","zebra","elg"];
B = arbsort(A,abc)
%% |[nl] Nederlands ------------------------------------------------ Dutch|
% Setup: two orderings are shown. Winkler Prins places "IJ" (and the
% ligature "Ĳ") between "Y" and "Z". Telephone directory order treats
% "IJ" as equivalent to "Y".
%
% Approximation: none.
A = ["Bruĳn","Bruzn","Bruijn","Bruyn","Bruxn"];
abc = [num2cell('A':'Y'),{'Ĳ|IJ','Z'}]; % Winkler Prins
B = arbsort(A,abc)
abc = [num2cell('A':'X'),{'Ĳ|IJ|Y','Z'}]; % telephone
B = arbsort(A,abc)
%% |[pl] Polski --------------------------------------------------- Polish|
% Setup: the explicit alphabet places all Polish special letters ("Ą",
% "Ć", "Ę", "Ł", "Ń", "Ó", "Ś", "Ź", "Ż") at their correct positions.
%
% Approximation: none.
abc = num2cell('AĄBCĆDEĘFGHIJKLŁMNŃOÓPQRSŚTUVWXYZŹŻ');
A = ["śnieg","źródło","las","żaba","zero","sól","łódź"];
B = arbsort(A,abc)
%% |[pt] Português -------------------------------------------- Portuguese|
% Setup: uses the default |ARBSORT| behaviour; diacritics are handled
% by the default diacritic removal.
%
% Approximation: none.
A = ["maca","maçã","maca","caju","café","bola","ação"];
B = arbsort(A)
%% |[ro] Română ------------------------------------------------- Romanian|
% Setup: the explicit alphabet places "Ă" and "Â" after "A", "Î" after
% "I", and "Ș" and "Ț" at their correct positions.
%
% Approximation: none.
abc = num2cell('AĂÂBCDEFGHIÎJKLMNOPQRSȘTȚUVWXYZ');
A = ["înger","ard","șef","inel","ăsta","țară","stea","ânod"];
B = arbsort(A,abc)
%% |[ru] Русский ------------------------------------------------- Russian|
% Setup: the explicit Cyrillic alphabet places "Ё" immediately after
% "Е"; without it, the default diacritic removal would fold "Ё" into "Е".
%
% Approximation: none.
abc = num2cell('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ');
A = ["ёж","ежевика","яблоко","зима","кот","жук"];
B = arbsort(A,abc)
%% |[sk] Slovenčina ----------------------------------------------- Slovak|
% Setup: the explicit alphabet includes the digraphs "DZ", "DŽ", and
% "CH", and places all accented letters at their correct positions.
%
% Approximation: simplified geminates of multigraphs are not split into
% the two digraphs (e.g. "ddz" is not decomposed into "dz"+"dz"), as this
% requires identifying word roots and is beyond the scope of ARBSORT.
abc = [num2cell('AÁÄBCČDĎ'),{'DZ','DŽ','E','É','F','G','H','CH'},num2cell('IÍJKLĽĹMNŇOÓÔPQRŔSŠTŤUÚVWXYÝZŽ')];
A = ["les","dvor","žena","dzéta","ľud","džem","šunka"];
B = arbsort(A,abc)
%% |[sv] Svenska ------------------------------------------------- Swedish|
% Setup: the explicit alphabet places "Å", "Ä", and "Ö" after "Z".
%
% Approximation: none.
abc = num2cell(['A':'Z','ÅÄÖ']);
A = ["zon","bal","äpple","öl","åka","zäta","bana"];
B = arbsort(A,abc)
%% |[sw] Kiswahili ----------------------------------------------- Swahili|
% Setup: uses the default |ARBSORT| behaviour; the standard 26-letter
% Latin alphabet requires no special configuration.
%
% Approximation: none.
A = ["ngoma","nyumba","mbu","rafiki","zebra"];
B = arbsort(A)
%% |[tr] Türkçe -------------------------------------------------- Turkish|
% Setup: the explicit alphabet places dotless "I" before dotted "İ", so
% "ırmak" correctly precedes "ipek". Without it, Unicode character-code
% order would incorrectly place dotted "i" before dotless "ı".
%
% Approximation: none.
abc = num2cell('ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ');
A = ["gülşen","zorlu","ırmak","ipek","gazi","ömer"];
B = arbsort(A,abc)
%% |[uk] Українська -------------------------------------------- Ukrainian|
% Setup: the explicit Cyrillic alphabet distinguishes "Ґ" from "Г",
% "Є" from "Е", and "Ї" from "І"; without it, these pairs would merge
% or sort incorrectly under Unicode order.
%
% Approximation: none.
abc = num2cell('АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ');
A = ["яб","гора","ґанок","єд","зима","їжак","іній","ера"];
B = arbsort(A,abc)
%% |[vi] Tiếng Việt ------------------------------------------- Vietnamese|
% Setup: the explicit alphabet places "Ă", "Â", "Đ", "Ô", "Ơ", and "Ư"
% at their correct positions; the replacement table maps all tonal
% variants to their base vowels.
%
% Approximation: none.
abc = num2cell('aăâbcdđeêfghijklmnoôơpqrstuưvwxyz');
rpl = {... map all tonal variants to their base vowels
    'à|á|ả|ã|ạ','a';
    'ằ|ắ|ẳ|ẵ|ặ','ă';
    'ầ|ấ|ẩ|ẫ|ậ','â';
    'è|é|ẻ|ẽ|ẹ','e';
    'ề|ế|ể|ễ|ệ','ê';
    'ì|í|ỉ|ĩ|ị','i';
    'ò|ó|ỏ|õ|ọ','o';
    'ồ|ố|ổ|ỗ|ộ','ô';
    'ờ|ớ|ở|ỡ|ợ','ơ';
    'ù|ú|ủ|ũ|ụ','u';
    'ừ|ứ|ử|ữ|ự','ư';
    'ỳ|ý|ỷ|ỹ|ỵ','y'}.';
A = ["ôm","ao","du","ơi","ào","đi","ăn"];
B = arbsort(A,rpl,abc)