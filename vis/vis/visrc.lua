require("vis")
require("plugins/vis-tmux-repl/tmux-repl")
local lspc = require("plugins/vis-lspc")

vis.events.subscribe(vis.events.INIT, function()
    vis:command("set theme themes/base16-onedark")
end)

function setOption(...)
    local optstrs = table.pack(...)
    local command = "set"
    for _, s in ipairs(optstrs) do
        command = command .. " " .. s
    end
    vis:command(command)
end

vis.events.subscribe(vis.events.INIT, function()
    vis.lexers.STYLE_CURSOR = 'back:#606774'
    vis.lexers.STYLE_SELECTION = 'fore:#282c34,back:#3e4451'
    local modes = {
        vis.modes.NORMAL,
        vis.modes.OPERATOR_PENDING,
        vis.modes.INSERT,
        vis.modes.REPLACE,
        vis.modes.VISUAL,
        vis.modes.VISUAL_LINE,
    }
    for _, mode in ipairs(modes) do
        vis:map(mode, "<C-l>", "<Escape>")
    end

    local motion = {
        vis.modes.NORMAL,
        vis.modes.VISUAL,
        vis.modes.VISUAL_LINE,
    }
    for _, mode in ipairs(motion) do
        vis:map(mode, "j", "gj")
        vis:map(mode, "k", "gk")
    end
    setOption("autoindent")
    setOption("ignorecase")
    vis:map(vis.modes.NORMAL, " -", "<C-w>s")
    vis:map(vis.modes.NORMAL, " |", "<C-w>v")
    vis:map(vis.modes.NORMAL, "<C-m>", function ()
        vis:redraw()
    end)
end)

for _, filetype in ipairs({"bqn", "ijs", "nix", "asy"}) do
    vis.ftdetect.filetypes[filetype] = {
        ext = { "%." .. filetype .. "$" }
    }
end

function enableBQNKeys(window)
    local bqnSyms = {
        ['`']='˜', ['1']='˘', ['2']='¨', ['3']='⁼', ['4']='⌜', ['5']='´', ['6']='˝', ['8']='∞', ['9']='¯', ['0']='•', ['-']='÷', ['=']='×',
        ['q']='⌽', ['w']='𝕨', ['e']='∊', ['r']='↑', ['t']='∧', ['u']='⊔', ['i']='⊏', ['o']='⊐', ['p']='π', ['[']='←', [']']='→',
        ['a']='⍉', ['s']='𝕤', ['d']='↕', ['f']='𝕗', ['g']='𝕘', ['h']='⊸', ['j']='∘', ['k']='○', ['l']='⟜', [';']='⋄', ['\'']='↩',
        ['z']='⥊', ['x']='𝕩', ['c']='↓', ['v']='∨', ['b']='⌊', ['m']='≡', [',']='∾', ['.']='≍', ['/']='≠',
        ['~']='¬', ['!']='⎉', ['@']='⚇', ['#']='⍟', ['$']='◶', ['%']='⊘', ['^']='⎊', ['&']='⍎', ['*']='⍕', ['(']='⟨', [')']='⟩', ['_']='√', ['+']='⋆',
        ['Q']='↙', ['W']='𝕎', ['E']='⍷', ['R']='𝕣', ['T']='⍋', ['I']='⊑', ['O']='⊒', ['P']='⍳', ['{']='⊣', ['}']='⊢',
        ['A']='↖', ['S']='𝕊', ['F']='𝔽', ['G']='𝔾', ['H']='«', ['K']='⌾', ['L']='»', [':']='·', ['"']='˙',
        ['Z']='⋈', ['X']='𝕏', ['V']='⍒', ['B']='⌈', ['M']='≢', ['<']='≤', ['>']='≥', ['?']='⇐',
        [' ']='‿',
    }
    for key, sym in pairs(bqnSyms) do
         window:map(vis.modes.INSERT, '\\' .. key, sym)
    end
end

function enableAPLKeys(window)
    local aplSyms = {
        ['`']='⋄', ['1']='¨', ['2']='¯', ['3']='<', ['4']='≤', ['5']='=', ['6']='≥', ['7']='>', ['8']='≠',['9']='∨', ['0']='∧', ['-']='×', ['=']='÷',
        ['q']='?', ['w']='⍵', ['e']='∊', ['r']='⍴', ['t']='~', ['y']='↑', ['u']='↓', ['i']='⍳', ['o']='○', ['p']='*', ['[']='←', [']']='→', ['\\']='⊢',
        ['a']='⍺', ['s']='⌈', ['d']='⌊', ['f']='_', ['g']='∇', ['h']='∆', ['j']='∘', ['k']="'", ['l']='⎕', [';']='⍎', ["'"]='⍕',
        ['z']='⊂', ['x']='⊃', ['c']='∩', ['v']='∪', ['b']='⊥', ['n']='⊤', ['m']='|', [',']='⍝', ['.']='⍀', ['/']='⌿',
        ['~']='⌺', ['!']='⌶', ['@']='⍫', ['#']='⍒', ['$']='⍋', ['%']='⌽', ['^']='⍉', ['&']='⊖', ['*']='⍟', ['(']='⍱', [')']='⍲', ['_']='!', ['+']='⌹',
        ['W']='⍹', ['E']='⍷', ['T']='⍨', ['I']='⍸', ['O']='⍥', ['P']='⍣', ['{']='⍞', ['}']='⍬', ['|']='⊣',
        ['A']='⍶', ['J']='⍤', ['K']='⌸', ['L']='⌷', [':']='≡', ['"']='≢',
        ['Z']='⊆', ['<']='⍪', ['>']='⍙', ['?']='⍠',
    }
    for key, sym in pairs(aplSyms) do
         window:map(vis.modes.INSERT, '<M-' .. key .. '>', sym)
    end
end

function enableJuliaKeys(window)
    local home = os.getenv("HOME")
    local sympath = home .. "/.config/vis/syms.tsv"
    local stream = io.open(sympath)
    for line in stream:lines() do
        local key, sym = line:match("([^%s]+)\t(.+)")
        window:map(vis.modes.INSERT, key, sym)
    end
    stream:close()
end


vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    setOption("number")
    local indents = {
        ansi_c = "tab8", makefile = "tab8", go = "tab4",
        fennel = "2", latex = "2", lisp = "2", sml = "2", nix = "2",
    }
    local indent = indents[win.syntax]
    if indent then
        if indent:sub(1, 3) == "tab" then
            setOption("expandtab off")
            setOption("tabwidth", indent:sub(4))
        else
            setOption("expandtab")
            setOption("tabwidth", indent)
        end
    else
        setOption("expandtab")
        setOption("tabwidth", 4)
    end
    local repls = {
        ansi_c = "cling",
        cpp = "cling",
        python = "python",
        haskell = "ghci",
        lua = "lua",
        scheme = "guile",
        bqn = "bqn",
        ijs = "jcon",
        fennel = "fennel",
        julia = "julia",
    }
    win:map(vis.modes.NORMAL, " r", ":repl-new " .. (repls[win.syntax] or "") .. "<Enter>")
    win:map(vis.modes.VISUAL, " e", ":repl-send<Enter><vis-mode-normal>")

    local formatters = {
        ansi_c = "indent -linux",
        fennel = "fnlfmt -",
        zig = "zig fmt --stdin",
        julia = "julia -e 'using JuliaFormatter; read(stdin, String) |> format_text |> print'",
    }

    if formatters[win.syntax] then
        win:map(vis.modes.VISUAL, "=", ":|" .. formatters[win.syntax] .. "<Enter>")
    end

    if win.syntax == 'bqn' then
        enableBQNKeys(win)
    end
    if win.syntax == 'apl' then
        enableAPLKeys(win)
    end
    if win.syntax == 'fennel' then
        win:map(vis.modes.INSERT, "<M-l>", "λ")
    end

    if win.syntax == 'julia' then
        enableJuliaKeys(win)
    end
end)

vis.events.subscribe(vis.events.WIN_CLOSE, function (win)
    vis:redraw()
end)

lspc.ls_map.latex = {
    name = 'texlab',
    cmd = 'texlab',
}

lspc.autostart = false

vis.events.subscribe(vis.events.WIN_OPEN, function (win)
    local workingLSPs = { 'latex', }
    for _, lang in ipairs(workingLSPs) do
        if win.syntax == lang then
            vis:command("lspc-start-server")
        end
    end
end)
