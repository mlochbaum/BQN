*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/literal.html).*

# Specification: BQN literal notation

A *literal* is a single [token](token.md) that indicates a fixed character, number, or array. While literals indicate values of a data type, [primitives](primitive.md) indicate values of an operation type: function, 1-modifier, or 2-modifier.

Two types of literal deal with text. As the source code is considered to be a sequence of unicode code points ("characters"), and these code points are also used for BQN's character [data type](types.md), the representation of a text literal is very similar to its value. In a text literal, the newline character is always represented using the ASCII line feed character, code point 10. A *character literal* is enclosed with single quotes `'` and its value is identical to the single character between them. A *string literal* is enclosed in double quotes `"`, and any double quotes between them must come in pairs, as a lone double quote marks the end of the literal. The value of a string literal is a rank-1 array whose elements are the characters in between the enclosing quotes, after replacing each pair of double quotes with only one such quote. The *null literal* is the token `@` and represents the null character, code point 0.

The format of a *numeric literal* is more complicated. From the [tokenization rules](token.md), a numeric literal consists of a numeric character (one of `¯∞π.0123456789`) followed by any number of numeric or alphabetic characters. Some numeric literals are *valid* and indicate a number, while others are invalid and cause an error. The grammar for valid numbers is given below in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant. The alphabetic character allowed is "e" or "E", which functions as in scientific notation. Not included in this grammar are underscores—they can be placed anywhere in a number, including after the last non-underscore character, and are ignored entirely.

    number    = "¯"? ( "∞" | mantissa ( ( "e" | "E" ) exponent )? )
    exponent  = "¯"? digit+
    mantissa  = "π" | digit+ ( "." digit+ )?
    digit     = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

The digits or arabic numerals correspond to the numbers from 0 to 9 in the conventional way (also, each corresponds to its code point value minus 48). A sequence of digits gives a natural number by evaluating it in base 10: the number is 0 for an empty sequence, and otherwise the last digit's numerical value plus ten times the number obtained from the remaining digits. The symbol `∞` indicates infinity and `π` indicates the ratio [pi](https://en.wikipedia.org/wiki/Pi_(mathematics)) of a perfect circle's circumference to its diameter. The [high minus](https://aplwiki.com/wiki/High_minus) symbol `¯` indicates that the number containing it is to be negated. When an exponent is provided (with `e` or `E`), the corresponding mantissa is multiplied by ten to that power, giving the value `mantissa×10⋆exponent`.

The above specification describes exactly an extended real number. To obtain a BQN number, each component is rounded to its nearest representative by the rules of the number system used: for IEEE 754, smallest distance, with ties rounding to the option with even mantissa.
