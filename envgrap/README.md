# envgrap

Collect env vars specified in a template, and emit json.
I honestly can't recall the requirement that spawned this.
There had to be more to the problem at hand. 
Uncommented, unfinished, and left here as an oddity.

Given fakejson.tpl: 

```
{
  "HOME": "$HOME",
  "USER": "$USER",
  "PWD": "$PWD"
}
```

Produce something like: 

```
[
  {
    "HOME": "/Users/gale", 
    "PWD": "/Users/gale", 
    "USER": "gale"
  }
]
```

