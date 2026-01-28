# ARBSORT / NATSORT Utilities for MATLAB #

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=DrosteEffect/NaturalSortOrder)

This repository is a consolidated mirror and backup of four MATLAB utilities:

- [![View ARBSORT on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/132263) **ARBSORT**
- [![View NATSORT on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/34464) **NATSORT**
- [![View NATSORTFILES on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/47434) **NATSORTFILES**
- [![View NATSORTROWS on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/47433) **NATSORTROWS**

It is intended to keep the functions together with their documentation and test data, under public version control.

All four utilities address limitations of standard ASCIIbetical/lexicographic sorting when working with text that contains numbers or non-English alphabets or custom text sequences.

### ARBSORT ###

`ARBSORT` sorts a text array according to explicitly supplied ordering sequences.

- The user provides zero, one, or more sequences that define the desired order of text (sub)elements (e.g. letters, words, parts of words),
- Any matched (sub)elements are sorted to match the reference sequences,
- Any unmatched (sub)elements are sorted into character code order, by default after having any diacritics removed.

### NATSORT ###

`NATSORT` performs natural-order sorting of text by interpreting digit sequences as numbers rather than as individual characters.

- Accepts character matrices, cell arrays of character vectors, and string arrays,
- Customizable number format and parsing,
- Returns the sorted array and a corresponding index vector,
- Sorting is *stable*, preserving the relative order of elements that compare equal.

### NATSORTFILES ###

`NATSORTFILES` applies natural-order sorting specifically to *filenames* and *filepaths*.

- Wrapper for `NATSORT`,
- Accepts filenames/paths either:
  * as a text array (character matrix, cell array of character vectors, string array), or
  * as the structure returned by `DIR`.

### NATSORTROWS ###

`NATSORTROWS` sorts *atomic rows of data* using natural-order rules applied to one or more specified columns.

- Wrapper for `NATSORT`,
- Designed for tables and cell arrays,
- Allows selection of one or more key columns for sorting.