-- BQN LPeg lexer.

local l = lexer
local token, word_match = l.token, l.word_match
local P, S, R = lpeg.P, lpeg.S, lpeg.R

local lex = lexer.new('bqn')


lex:add_rule('whitespace', token(l.WHITESPACE, l.space^1))

local digit = R("09")
local exponent = P("¯")^-1 * digit^1
local mantissa = P('π') + (digit^1 * (P(".") * digit^1)^-1)
lex:add_rule('number', token(l.NUMBER, P('¯')^-1 * (P('∞') + mantissa * (S("eE") * exponent)^-1)))

local char = P("'''") + (P("'") * (l.any - "'")^1 * P("'")^-1)
local str = '"' * ((l.any - P('"')) + P('""'))^0 * P('"')^-1
lex:add_rule('string', token(l.STRING, char + str))

function oneOf(strs)
    local pat = P(strs[1])
    for i = 2,#strs do
        pat = pat + strs[i]
    end
    return pat
end

-- Identifier.

local identChar = l.alpha + R('09') + P('_') + P('π') + P('∞')
local identChar2 = l.alpha + R('09') + P('π') + P('∞')
local subject = R('az') * identChar^0
local func = R('AZ') * identChar^0
local primFuncs = oneOf({
    '+', '-', '×', '÷', '⋆', '√', '⌊', '⌈', '|', '¬', '∧', '∨', '<', '>', '≠', '=', '≤', '≥', '≡', '≢', '⊣', '⊢',
    '⥊', '∾', '≍', '⋈', '↑', '↓', '↕', '«', '»', '⌽', '⍉', '/', '⍋', '⍒', '⊏', '⊑', '⊐', '⊒', '∊', '⍷', '⊔', '!',
    '𝕏', '𝕎', '𝔽', '𝔾', '𝕊',
})
local primOneMods = oneOf({'˙', '˜', '˘', '¨', '⌜', '⁼', '´', '˝', '`', '_𝕣'})
local primTwoMods = oneOf({'∘', '○', '⊸', '⟜', '⌾', '⊘', '◶', '⎉', '⚇', '⍟', '⎊', '_𝕣_'})

local oneMod = '_' * identChar^1
local twoMod = '_' * identChar^1 * lpeg.B('_')
local modules = P('•')^-1 * (subject * P('.'))^0

lex:add_rule("identifier", token(l.IDENTIFIER, modules * subject))
lex:add_rule("functions", token(l.FUNCTION, modules * func + primFuncs))
lex:add_rule("oneModifiers", token(l.EMBEDDED, modules * oneMod + primOneMods))
lex:add_rule("twoModifiers", token(l.PREPROCESSOR, modules * twoMod + primTwoMods))

lex:add_rule('special', token(l.OPERATOR, oneOf({
    '←', '⇐', '↩', '(', ')', '{', '}', '⟨', '⟩', '[', ']', '‿', '·', '⋄', ',', '.', ';', ':', '?'
})))
lex:add_rule('keywords', token(l.KEYWORD, oneOf({
    '𝕨', '𝕩', '𝕗', '𝕘', '𝕤', '𝕣', '·'
})))

-- Comment.
lex:add_rule('comment', token(l.COMMENT, '#' * l.nonnewline^0))

-- Constant (only null)
lex:add_rule('constant', token(l.CONSTANT, P('@')))

return lex
