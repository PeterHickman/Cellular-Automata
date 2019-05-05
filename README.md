# Cellular-Automata

Based on "Cellular Automata and Complexity" by Stephen Wolfram

## Description
A simple class to generate 1D cellular automata and produce the output as a test string. Can handle bases up to 36 as given in `CA::ALPHABET` but defaults to the usual binary types.

Rules are validated according to the criteria laid down by Stephen Wolfram in "Cellular Automata and Complexity" (no not that other book - this is an earlier one). Rules can be run of they are valid or not, it's just informational.

Boundary conditions are set by `CA::BOUNDARY_CIRCULAR` and `CA::BOUNDARY_MISSING`. When evaluating neighbours that are off the edge of the current string `CA::BOUNDARY_MISSING` defaults them to `0` where as `CA::BOUNDARY_CIRCULAR` wraps around to the other end of the string.

There are three seed setting methods:

### `CA#seed(string)`
Sets the string to the given string after validating that the given string is only formed of valid characters from the alphabet appropriate to the current base.

### `CA#centreseed(length)`
Creates a string of the given length with a `1` at, or near, it's centre.

### `CA#randomseed(length, density)`
Create a string of the given length that has density percentage of it's characters set to valid non `0` characters from the alphabet appropriate to the current base.

Added a `rulestring` method for entering rules as once Stephen Wolfram gets beyond base 2 automata he starts to give them as strings rather than numbers.

Thats all there is really. Not having read "A new kind of science" I can't say if this will operate the rule numbers given by Stephen Wolfram in the same way but the chances are pretty good.
