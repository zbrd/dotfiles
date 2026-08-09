function MakeStatusLine()
    local fs = vim.api.nvim_eval_statusline('%Y', {}).str
    local ln = string.len(fs)

    if ln > 5 then
        fs = string.sub(fs, 1, 5)
    else
        fs = fs .. string.rep(' ', 5 - ln)
    end

    local left = ' %#Whitespace#' .. fs .. '%## %f %M'
    local right = ' %{%v:lua.vim.diagnostic.status()%} '
    return left .. '%=' .. right
end

vim.o.statusline = '%!v:lua.MakeStatusLine() '
