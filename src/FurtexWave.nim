import std/os

import fw

let args = commandLineParams()

case(args[0])
  of "create":
    let path =
      if args.len > 1: args[1]
      else: getCurrentDir()

    createProject(path)
    echo "Project created at ", path

  of "render":
    let path =
      if args.len > 1: args[1]
      else: getCurrentDir()

    echo "Verifying ", path, "..."

    if not checkProjectDir(path):
      echo "Current directory is incomplete!"
      quit(1)

    render(path)

    echo "Rendering ", path, "..."
    echo "Done!"

  of "help":
    echo """

furtexwave create [dir]
           # create a new furtexwave project

           render [dir]
           # render the project into functional static site

           guide
           # list out all possible tags

### Made by KuroFurtex @ 2026 ###
"""

  of "guide":
    echo """

Guide
{{css:style.css}}
{{js:script.js}}
{{furtex-list:data.json:template.html}}
"""
  else:
    echo "Invalid Command"
