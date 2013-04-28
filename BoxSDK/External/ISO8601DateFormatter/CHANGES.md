Several changes to ISO8601DateFormatter were made to incorporate it into BoxSDK:

* typedefs, constants, and classes had their names prefixed with "Box".
* `#define`s had their names prefixed with "BOX_".
* `dateFromString:timeZone:range:` was changed to return nil if an invalid
  date string is given.
* All property definitions were changed to explicitly include `nonatomic` and `readwrite`.

**NOTE**: The library is still not compiled with ARC.

