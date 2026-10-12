# FurtexWave
A simple web framework to make static website.

This little web framework that I made is purely to help with making static website.
Using JavaScript to fetch JSON content works for normal human but it'll be invisible for SEO.
In other word, bots or AI cannot read the content.

Therefore, this framework is born to bake JSON data straight to HTML while also making it easier to deal with.

## How to build
In order to build FurtexWave, you need to have
- Nim version 2.2.12 or above
- Nimble
- MingGW

`cd` into the directory of FurtexWave folder
and type
```
nimble build
```

## How to use
The project can be first initialized using:
```
furtexwave create
```
This will create it in current directory.
And then rendered using:
```
furtexwave render
```
which will output a `rendered` folder containing HTML with already inserted data.

Guide of the tag can be found by using `furtexwave guide`
