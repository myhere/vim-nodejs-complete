vim-nodejs-complete
===================

Nodejs `'omnifunc'` function of vim

Support node build-in module's method completion(`ctrl-x ctrl-o`) in `js` file with preview.


## Install
Download the [tarball](https://github.com/myhere/vim-nodejs-complete/zipball/master) and extract to your vimfiles(`~/.vim` or `~/vimfiles`) folder.

Completion require `:filetype plugin on`, please make sure it's on.


## Example

```js
var fs = req
// then hit ctrl-x_ctrl-o

var fs = require('f
// then hit ctrl-x_ctrl-o

fs.
// then hit ctrl-x_ctrl-o

proc
// then hit ctrl-x_ctrl-o

process.ex
// then hit ctrl-x_ctrl-o
```

## Tip
1. Close the method preview window
     `ctrl-w_ctrl-z` or `:pc`.

     If you want close it automatically, put the code(from [spf13-vim](https://github.com/spf13/spf13-vim/blob/3.0/.vimrc)) below in your `.vimrc` file.

     ```vim
     " automatically open and close the popup menu / preview window
     au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
     ```


2. About vim's complete
     Vim supports several kinds of completion, `:h ins-completion` for help.


## Feedback
[feedback or advice or feature-request](https://github.com/myhere/vim-nodejs-complete/issues)

