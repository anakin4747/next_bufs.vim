" TODO: Fix this so that you don't get trapped in netrw when shuffling through
" non-terminal buffers forcing you to switch to a terminal buffer to become
" untrapped

function! s:GetNextBuf(current, bufs, ...)
    if exists("a:1") && a:1
        " Previous
        let end_buf = a:bufs[0]
    else
        " Next
        let end_buf = a:bufs[-1]
    endif

    if a:current == end_buf
        return a:current
    endif

    if exists("a:1") && a:1
        " Previous
        let buflist = reverse(copy(a:bufs))
    else
        " Next
        let buflist = a:bufs
    endif

    let found = 0

    for buf in buflist
        " Return the buf from the following iteration after finding
        if found
            return buf
        endif

        " If buf found set found to return on next iteration
        if buf == a:current
            let found = 1
        endif
    endfor

    " No buf was found
    return -1
endfunction

function! s:GetPrevBuf(current, bufs)
    return s:GetNextBuf(a:current, a:bufs, 1)
endfunction

function! s:TestGetBufsContainsBuf()
    " Returns -1 if current buffer not in bufs
    const bufs = [1, 2, 3]
    const cur = 4
    let ret = s:GetPrevBuf(cur, bufs)
    call assert_equal(-1, ret)

    let ret = s:GetNextBuf(cur, bufs)
    call assert_equal(-1, ret)
endfunction

function! s:TestGetPrevBuf()
    " Test that you can get the previous buffer
    const bufs = [1, 2]
    const cur = 2
    const ret = s:GetPrevBuf(cur, bufs)
    call assert_equal(1, ret)
endfunction

function! s:TestGetPrevBufStopsAtFirstBuf()
    " Test that s:GetPrevBuf stops at first buffer
    const bufs = [1, 2]
    const cur = 1
    const ret = s:GetPrevBuf(cur, bufs)
    call assert_equal(1, ret)
endfunction

function! s:TestGetNextBuf()
    " Test that you can get the previous buffer
    const bufs = [1, 2]
    const cur = 1
    const ret = s:GetNextBuf(cur, bufs)
    call assert_equal(2, ret)
endfunction

function! s:TestGetNextBufStopsAtLastBuf()
    " Test that s:GetPrevBuf stops at first buffer
    const bufs = [1, 2]
    const cur = 2
    const ret = s:GetNextBuf(cur, bufs)
    call assert_equal(2, ret)
endfunction

function! s:GetTermBufs(bufs)
    return map(filter(copy(a:bufs), 'v:val.name =~ "^term://"'), 'v:val.bufnr')
endfunction

function! s:GetNonTermBufs(bufs)
    return map(filter(copy(a:bufs), 'v:val.name !~ "^term://"'), 'v:val.bufnr')
endfunction

function! s:TestGetBufs()
    let bufs = [
    \   {'name': 'term://', 'bufnr': 1},
    \   {'name': '[Scratch]', 'bufnr': 2},
    \   {'name': 'term.vim', 'bufnr': 3},
    \]

    let ret = s:GetTermBufs(bufs)
    call assert_equal([1], ret)

    let ret = s:GetNonTermBufs(bufs)
    call assert_equal([2, 3], ret)
endfunction

function! next_bufs#NextTermBuf(...)
    " If not in a term buffer just go to last term buffer
    if &buftype != 'terminal'
        "echom "next_bufs#NextTermBuf: Not in terminal"
        silent! execute 'buffer' split(execute('filter /^term:\/\// buffers t'))[0]
        return
    endif

    let bufs = s:GetTermBufs(getbufinfo({'buflisted': 1}))

    " If there are no term buffers do nothing
    if len(bufs) == 0
        "echom "next_bufs#NextTermBuf: No terminal buffer: Do nothing"
        return
    endif

    let next_bufs = s:GetNextBuf(bufnr('%'), bufs, exists("a:1") && a:1)
    if next_bufs > 0
        execute 'buffer' next_bufs
    end
endfunction

function! next_bufs#PrevTermBuf()
    call next_bufs#NextTermBuf(1)
endfunction

function! next_bufs#NextNonTermBuf(...)
    " If in a term buffer just go to last non-term buffer
    if &buftype == 'terminal'
        "echom "next_bufs#NextNonTermBuf: in terminal"
        silent! execute 'buffer' split(execute('filter! /^term:\/\// buffers t'))[0]
        return
    endif

    let bufs = s:GetNonTermBufs(getbufinfo({'buflisted': 1}))

    " If there are no term buffers do nothing
    if len(bufs) == 0
        "echom "next_bufs#NextTermBuf: No terminal buffer: Do nothing"
        return
    endif

    let next_bufs = s:GetNextBuf(bufnr('%'), bufs, exists("a:1") && a:1)
    if next_bufs > 0
        execute 'buffer' next_bufs
    end
endfunction

function! next_bufs#PrevNonTermBuf()
    call next_bufs#NextNonTermBuf(1)
endfunction
