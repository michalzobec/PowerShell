pandoc.exe License.md -f gfm -t html -s -o License.html --include-in-header=css\style-begin.include --include-in-header=css\modest.css --include-in-header=css\style-end.include
pandoc.exe ReadMe.md -f gfm -t html -s -o ReadMe.html --include-in-header=css\style-begin.include --include-in-header=css\modest.css --include-in-header=css\style-end.include
pandoc.exe ToDo.md -f gfm -t html -s -o ToDo.html --include-in-header=css\style-begin.include --include-in-header=css\modest.css --include-in-header=css\style-end.include
pandoc.exe WhatsNew.md -f gfm -t html -s -o WhatsNew.html --include-in-header=css\style-begin.include --include-in-header=css\modest.css --include-in-header=css\style-end.include
