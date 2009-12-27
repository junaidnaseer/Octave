## Copyright (C) 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2002, 2003,
##               2005, 2006, 2007, 2008, 2009 John W. Eaton
## Copyright (C) 2009 Jaroslav Hajek
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} strcat (@var{s1}, @var{s2}, @dots{})
## Return a string containing all the arguments concatenated
## horizontally.  If the arguments are cells strings,  @code{strcat}
## returns a cell string with the individual cells concatenated.
## For numerical input, each element is converted to the
## corresponding ASCII character.  Trailing white space is eliminated.
## For example,
##
## @example
## @group
## s = [ "ab"; "cde" ];
## strcat (s, s, s)
##      @result{} ans =
##         "ab ab ab "
##         "cdecdecde"
## @end group
## @end example
##
## @example
## @group
## s = @{ "ab"; "cde" @};
## strcat (s, s, s)
##      @result{} ans =
##         @{
##           [1,1] = ababab
##           [2,1] = cdecdecde
##         @}
## @end group
## @end example
##
## @seealso{cstrcat, char, strvcat}
## @end deftypefn

## Author: jwe

function st = strcat (varargin)

  if (nargin > 0)
    if (nargin == 1)
      st = varargin{1};
    elseif (nargin > 1)
      ## Convert to cells of strings
      uo = "UniformOutput";
      reals = cellfun (@isreal, varargin);
      if (any (reals))
        varargin(reals) = cellfun (@char, varargin(reals), uo, false);
      endif
      chars = cellfun (@ischar, varargin);
      allchar = all (chars);
      varargin(chars) = cellfun (@cellstr, varargin(chars), uo, false);
      if (! all (cellfun (@iscell, varargin)))
        error ("strcat: inputs must be strings or cells of strings");
      endif

      ## Set all cells to a common size
      [err, varargin{:}] = common_size (varargin{:});

      if (err)
        error ("strcat: arguments must be the same size, or be scalars");
      endif

      ## Total number of resulting strings.
      dims = size (varargin{1});
      nstr = prod (dims);
      ## Reshape args to column vectors.
      varargin = cellfun (@reshape, varargin, {[nstr, 1]}, uo, false);
      ## Concatenate the columns to a cell matrix, and extract rows.
      strows = num2cell ([varargin{:}], 2);
      ## Concatenate all the rows.
      st = cellfun (@cell2mat, strows, uo, false);

      if (allchar)
        ## If all inputs were strings, return strings.
        st = char (st);
      else
        ## Reshape to original dims
        st = reshape (st, dims);
      endif
    endif
  else
    print_usage ();
  endif

endfunction

## test the dimensionality
## 1d
%!assert(strcat("ab ", "ab "), "abab")
%!assert(strcat({"ab "}, "ab "), {"ab ab"})
%!assert(strcat("ab ", {"ab "}), {"abab "})
%!assert(strcat({"ab "}, {"ab "}), {"ab ab "})
%!assert(strcat("", "ab"), "ab")
%!assert(strcat("", {"ab"}, {""}), {"ab"})
## 2d
%!assert(strcat(["ab ";"cde"], ["ab ";"cde"]), ["abab  ";"cdecde"])

## test for deblanking implied trailing spaces of character input
%!assert((strcmp (strcat ("foo", "bar"), "foobar") &&
%!        strcmp (strcat (["a"; "bb"], ["foo"; "bar"]), ["afoo "; "bbbar"])));

## test for mixing character and cell inputs
%!assert(all (strcmp (strcat ("a", {"bc", "de"}, "f"), {"abcf", "adef"})))

## test for scalar strings with vector strings
%!assert(all (strcmp (strcat (["a"; "b"], "c"), ["ac"; "bc"])))

## test with cells with strings of differing lengths
%!assert(all (strcmp (strcat ({"a", "bb"}, "ccc"), {"accc", "bbccc"})))
%!assert(all (strcmp (strcat ("a", {"bb", "ccc"}), {"abb", "accc"})))

%!error strcat ();

%!assert (strcat (1, 2), strcat (char(1), char(2)))

%!assert (strcat ('', 2), strcat ([], char(2)))

