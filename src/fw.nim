import std/[os, sets, strutils, re, json]

let tagPattern = re"\{\{(.*?)\}\}"

# Guide
# {{css:path/to/style.css}}
# {{js:path/to/script.js}}
# {{furtex-list:path/to/data.json:path/to/template.html}}

proc createProject*(path: string) =
    let pages = path / "pages"
    let data = path / "data"
    let templates = path / "templates"
    let assets = path / "assets"
    let css = assets / "css"
    let js = assets / "js"

    createDir(pages)
    createDir(data)
    createDir(templates)
    createDir(assets)
    createDir(css)
    createDir(js)

    writeFile(pages / "index.html", """
<html>
    <head>
        <title>Hello World!</title>
    </head>

    <body>
        {{furtex-list:data.json:default}}
    </body>
</html>
""")

    writeFile(data / "data.json", """
[
    {
        "name": "KuroFurtex",
        "age": 19
    },
    {
        "name": "ZyroZytex",
        "age": 25
    }
]
""")

    writeFile(templates / "default.html", """
<div>
    <h1>{{name}}</h1>
    <h3>{{age}}</h3>
    <hr>
</div>
""")


proc renderTemplate(temp: string, item: JsonNode): string =
    result = temp

    for key, value in item:
        result = result.replace(
            "{{" & key & "}}",
            if value.kind == JString: value.getStr()
            else: $value
            )


proc checkProjectDir*(path: string): bool =
    result =
        dirExists(path / "pages") and
        dirExists(path / "data") and
        dirExists(path / "templates")


proc checkForUsedAsset(path, filePath: string): HashSet[string] =
    result = initHashSet[string]()

    let filecontent = readFile(filePath)

    for tag in findAll(filecontent, tagPattern):
        let inner = tag[2 .. ^3]
        let params = inner.split(':')

        if params.len == 2 and params[0] in ["css", "js"]:
            let assetPath = path / "assets" / params[0] / params[1]

            if fileExists(assetPath):
                result.incl(assetPath)


# will be needed for both rendering and serve server
proc renderPage(path, filePath: string): string =
    let data = path / "data"
    let templates = path / "templates"
    let assets = path / "assets"
    let css = assets / "css"
    let js = assets / "js"

    var filecontent = readFile(filePath)

    for tag in findAll(filecontent, tagPattern):
        let inner = tag[2 .. ^3]
        let params = inner.split(':')

        case params[0]:
        of "css":
            if params.len == 2:
                let cssPath = "assets/css/" & params[1]
                let replacement = "<link rel=\"stylesheet\" href=\"" &
                cssPath & "\">"
                filecontent = filecontent.replace(tag, replacement)
        of "js":
            if params.len == 2:
                let jsPath = "assets/js/" & params[1]
                let replacement = "<script src=\"" &
                jsPath & "\"></script>"
                filecontent = filecontent.replace(tag, replacement)

        of "furtex-list":
            if params.len == 3:
                let jsonPath = data / params[1]
                let templatePath = templates / params[2]

                if fileExists(jsonPath) and fileExists(templatePath):
                    let jsonData = parseFile(jsonPath)
                    let templateHtml = readFile(templatePath)
                    var renderedHtml = ""

                    if jsonData.kind == JArray:
                        for item in jsonData:
                            renderedHtml.add(renderTemplate(templateHtml, item))

                    filecontent = filecontent.replace(tag, renderedHtml)

        else:
            discard
    result = filecontent


proc render*(path: string) =
    let pages = path / "pages"
    let assets = path / "assets"
    let rendered = path / "rendered"

    var usedAssets = initTables[string]()

    if not dirExists(rendered):
        createDir(rendered)

    for kind, filePath in walkDir(pages):
        if kind != pcFile:
            continue

        for asset in checkForUsedAsset(path, filePath):
            usedAssets.incl(asset)

        let filecontent = renderPage(path, filePath)
        let outputPath = rendered / extractFilename(filePath)

        writeFile(outputPath , filecontent)

    for asset in usedAssets:
        let relativePath = relativePath(asset, assets)
        let destination = rendered / "assets" / relativePath

        createDir(destination.parentDir())
        copyFile(asset, destination)
