# Simplified version of iubenda T&C Generator

## Requirements

The T&C generator is a software which given:
* A template
* A dataset
  
transforms the template into a Document expanding the template tags into their representation using
the dataset. Below you can find more details.

## Template
Is a text made of:
* Plaintext
* Tags

### Tags
The tags supported are:
* Clauses: [CLAUSE-#{ID}]
* Sections: A group of clauses, represented with [SECTION-#{ID}]


## Example

Given the following template:
<pre>
A T&C Document

This document <b>is</b> made <b>of</b> plaintext.
<b>Is</b> made <b>of</b> [CLAUSE-3].
<b>Is</b> made <b>of</b> [CLAUSE-4].
<b>Is</b> made <b>of</b> [SECTION-1].
Your legals.
</pre>

And the following dataset:

clauses:
```
[
  { "id": 1, "text": "The quick brown fox" },
  { "id": 2, "text": "jumps over the lazy dog" },
  { "id": 3, "text": "And dies" },
  { "id": 4, "text": "The white horse is white" }
]
```

sections:

```
[
  { "id": 1, "clauses_ids": [1, 2] }
]
```

Creates the following T&C document:
<pre>
A T&C Document

This document <b>is</b> made <b>of</b> plaintext.
<b>Is</b> made <b>of And</b> dies.  
<b>Is</b> made <b>of</b> The white horse <b>is</b> white.
<b>Is</b> made <b>of</b> The quick brown fox;jumps over the lazy dog.

Your legals.
</pre>


## How to use
To run in your code
```
require 'tc'

tc = TC.new(template, clauses, sections)
text = tc.generate
# ...
```

Run directly from command line with
```ruby tc.rb```

## Testing
To launch tests use
```ruby tc_spec.rb```

## Todo
- more tests
- command line helper separated from TC class
- better documentation