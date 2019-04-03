## demo
this little repo contains some demo code.  it doesn't really do much.  it is just to show that I know how to code and perhaps how to spel

# metar.R
- this script processes some metar data.  Unfortunately, the source file is too big for a repo.  But the script is included anyway, even though it can't be run.
- the script contains a config list, which specifies the number of rows to read in.  Turn this down during development, to make the code run very fast.  Turn it up later, to process the entire source file.
- the output is redirected to a log file.

See - 
https://en.wikipedia.org/wiki/METAR
https://en.wikipedia.org/wiki/Okta

# main.R
- this is a sample mainline script, which just builds a simple linear model on some sample data
- it is structured clearly with distinct modules, which could be worked on in parrallel by different members of a team
- these are currently script called by the mainline, rather than functions.  if being worked on my more than one person, then
these should probably be turned into functions to avoid leaving objects around in the working environment
