function! s:corona_stats() abort
  let l:lines = []
  let l:keys = [
  \ ['country', '国', 0],
  \ ['cases', '感染者数(累計)', 0],
  \ ['todayCases', '感染者数(本日)', 1],
  \ ['deaths', '死亡者数(累計)', 0],
  \ ['todayDeaths', '死亡者数(本日)', 1],
  \ ['recovered', '退院者数', 0],
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
      let l:w[l:r] = strdisplaywidth(l:lines[l:r][l:c] . '　')
      let l:m = max([l:m, l:w[l:r]])
    endfor
    for l:r in range(len(l:w))
      let l:mark = '　'
      if l:keys[l:c][2] ==# 1
        if l:lines[l:r][l:c] > 0
          let l:mark = '▲'
        elseif l:lines[l:r][l:c] < -0
          let l:mark = '▼'
        endif
      endif
      if l:c > 0
        let l:lines[l:r][l:c] = repeat(' ', l:m - l:w[l:r]) . l:lines[l:r][l:c] . l:mark
      else
        let l:lines[l:r][l:c] = l:lines[l:r][l:c] . repeat(' ', l:m - l:w[l:r]) . l:mark
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
