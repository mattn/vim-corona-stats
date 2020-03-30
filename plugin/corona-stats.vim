function! s:corona_stats() abort
  let l:lines = []
  let l:keys = [
  \ ['country', '国'],
  \ ['cases', '感染者数(累計)'],
  \ ['todayCases', '感染者数(本日)'],
  \ ['deaths', '死亡者数(累計)'],
  \ ['todayDeaths', '死亡者数(本日)'],
  \ ['recovered', '退院者数'],
  \]
  call add(l:lines, map(deepcopy(l:keys), 'v:val[1]'))

  let l:contents = system('curl -s https://corona-stats.online?format=json')
  let l:resp = json_decode(l:contents)
  for l:row in l:resp.data + [l:resp.worldStats]
    call add(l:lines, map(deepcopy(l:keys), 'l:row[v:val[0]]'))
  endfor
  let l:h = range(len(l:lines[0]))
  for l:c in range(len(l:lines[0]))
    let l:m = 0
    let l:w = range(len(l:lines))
    for l:r in range(len(l:w))
      let l:w[l:r] = strdisplaywidth(l:lines[l:r][l:c])
      let l:m = max([l:m, l:w[l:r]])
    endfor
    for l:r in range(len(l:w))
      if l:c > 0
        let l:lines[l:r][l:c] = repeat(' ', l:m - l:w[l:r]) . l:lines[l:r][l:c]
      else
        let l:lines[l:r][l:c] = l:lines[l:r][l:c] . repeat(' ', l:m - l:w[l:r])
      endif
    endfor
    let l:h[l:c] = repeat('-', strdisplaywidth(l:lines[0][l:c]))
  endfor
  for l:n in range(len(l:lines))
    let l:lines[l:n] = '|' . join(l:lines[l:n], '|') . '|'
  endfor
  call insert(l:lines, '|' . join(l:h, '|') . '|', 1)
  call insert(l:lines, '|' . join(l:h, '|') . '|', len(l:lines)-1)
  silent new
  file __CORONA_STATS__
  setlocal buftype=nofile nolist nonumber bufhidden=wipe noswapfile buflisted filetype=
  silent call append(0, l:lines)
  normal! gg
endfunction
command! CoronaStats call s:corona_stats()
