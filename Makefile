.DEFAULT_GOAL := compile

filelist := src/Main.elm src/Outfit.elm
outputfile := static/js/generate.js

compile:
	elm make  ${filelist} --output=${outputfile}

