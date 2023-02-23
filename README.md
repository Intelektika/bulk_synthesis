#Bulk sentence processing using Lithuanian TTS service in Linux (or WSL)

Bash script that enables to use https://snekos-sinteze.lt Lithuanian TTS service for bulk sentence processing in Linux (or WSL).

Steps:

1. Download and extract the archive `bulk_synthesis_linux.zip`
2. Open and edit `bulk_synthesis.sh` file
- replace 'USER_SERVICE_KEY' placeholder by your personal service key (line 6);
- choose your voice (line 7);
- choose your talking speed (line 8);
- choose your output file format (line 9).
3. Compose a list of Lithuanian sentences (UTF-8 encoding, one sentence per line, LF terminated line) to be synthesized. The file `sentences.txt` is provided as an example.
4. This step can be skipped unless you wish that synthesized speech files have names different from the sentences themselves. Compose a list of filenames (lets say it is `filenames.txt`) to be used for synthesized sentences, one filename per line. The file `filenames.txt` must have as many filenames as there are sentences in `sentences.txt` 
5. Open Linux (or WSL) terminal
6. Go (cd) to the directory where the archive `bulk_synthesis_linux.zip` was extracted
7. Run the script
- `./bulk_synthesis.sh sentences.txt`              if you wish that synthesized speech files have names corresponding to the content of a sentence
or
- `./bulk_synthesis.sh sentences.txt filelist.txt` if you wish that synthesized speech files have names specified in `filelist.txt`
