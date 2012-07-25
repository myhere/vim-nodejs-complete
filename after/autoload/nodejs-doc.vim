let g:nodejs_complete_modules = {
\ 'fs': [
\    {
\      'word': 'readFile(',
\      'info': 'fs.readFile(filename, [encoding], [callback])'
\    },
\    {
\      'word': 'readFileSync(',
\      'info': 'fs.readFileSync(filename, [encoding])'
\    },
\    {
\      'word': 'writeFile(',
\      'info': 'fs.writeFile(filename, data, [encoding], [callback])'
\    },
\    {
\      'word': 'writeFileSync(',
\      'info': 'fs.writeFileSync(filename, data, [encoding])'
\    }
\  ]
\}
