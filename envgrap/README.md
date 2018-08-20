# envgrap

Collect env vars specified in a template, and emit json.

We encountered a situation where simply getting the 
environment from a shell was not feasible (or possible.) 
This may have been livecoded to illustrate how to 
accomplish the same task without shelling out. 
There was a point, but it has been lost to time. 

Uncommented, unfinished, and left here as an oddity.

Given a template fakejson.tpl, something we might 
ordinarily process with a one-liner: 

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
