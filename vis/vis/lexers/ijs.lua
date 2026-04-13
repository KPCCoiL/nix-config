-- J LPeg lexer.
-- Kinda broken

local l = lexer
local token, word_match = l.token, l.word_match
local P, S, R = lpeg.P, lpeg.S, lpeg.R

local lex = lexer.new('ijs')

lex:add_rule('whitespace', token(l.WHITESPACE, l.space^1))

local digit = R("09")
local posint = digit^1
local decpt = digit^1 * (P('.') * digit^0)^-1
local posneg = P('_')^-1 * decpt
local exponential = (posneg * P('e') * posneg) + posneg + P('_') + P('__')
local positive = (decpt * P('e') * posneg) + decpt + P('_')
local polar = positive * (P('ad') + P('ar')) * exponential
local complex = polar + exponential * P('j') * exponential + exponential
local px = complex * ((P('p') + P('x')) * complex)^-1
local extint = P('_')^-1 * digit^1 * P('x')
local rational = px * P('r') * px
local extdigit = digit + R('az')
local extfloat = P('_')^-1 * extdigit^1 * (P('.') * extdigit^0)^-1
local based =  (rational + px) * P('b') * extfloat

lex:add_rule('number', token(lexer.NUMBER, based + extint + rational + px))

local blockEnd = l.newline * P(')') * l.newline
local space = S(' \t\r')
local nounblock = P('0') * space^0 * P(':') * space^0 * P('0') * space^0 * l.newline * (l.any - blockEnd)^0 * blockEnd
local str = "'" * ((lexer.any - P("'") - P('\n')) + P("''"))^0 * P("'")^-1
lex:add_rule('string', token(l.STRING, str + nounblock))

function oneOf(strs)
    local pat = P(strs[1])
    for i = 2,#strs do
        pat = pat + strs[i]
    end
    return pat
end

-- Identifier.

local identChar = l.alpha + R('09') + P('_')
local identChar2 = l.alpha + R('09')
local subject = R('az') * identChar^0
local func = R('AZ') * identChar^0
local function infl(x)
    return P(x .. '.') + P(x .. ':') + P(x)
end
local function lone(x)
    return x * (-S(".:"))
end
local primFuncs = oneOf({
    lone('='),
    infl('<'), infl('>'),
    '_:', '__:',
    infl('+'), infl('*'), infl('-'), infl('%'),
    lone('^'), '^.',
    infl('$'), '~.', '~:',
    infl('|'),
    infl(','), lone(';'), ';:',
    infl('#'), lone('!'),
    '/:', '\\:',
    lone('['), '[:',
    lone(']'),
    infl('{'), '{::',
    '}.', '}:',
    '".', '":',
    '?', '?.',
    'A.', 'c.', 'C.', 'e.',
    'E.', 'i.', 'i:',
    'I.', 'j.', 'L.',
    'o.', 'p.',
    'p..', 'p:', 'q:',
    'r.', 's:',
    'T.', 'u:',
    'x:', 'Z:',
    P('_')^-1 * R('09') * P(':'),
    'u.', 'v.'
})
local primAdverbs = oneOf({
    lone('~'), '/..', '/.', lone('/'), '\\', '\\.', ']:', lone('}'), 'b.', 'f.', 'M.',
})
local primConjunctions = oneOf({
    '^:', '.', infl(':'), ';.', '!.', '!:', '[.', '].',
    '"', '`', '`:',
    infl('@'), infl('&'), '&.:',
    P('F') * S('.:') * S('.:')^-1,
    'H.', 'L:', 'm.',
    'S:', 't.', 'd.', 'D.', 'D:',
})

lex:add_rule('identifier', token(l.IDENTIFIER, l.alpha * (l.alpha + P('_') + R('09'))^0))
lex:add_rule('functions', token(l.FUNCTION, primFuncs))
lex:add_rule('embedded', token(l.EMBEDDED, primAdverbs))
lex:add_rule('preprocessor', token(l.PREPROCESSOR, primConjunctions))

lex:add_rule('operator', token(l.OPERATOR, oneOf({
    '=:', '=.', '{{', '}}'
})))

local labeled = (P('for') + P('label') + P('goto')) * P('_') * l.alpha^1 * P('.')
local single = oneOf({
    'assert.', 'break.', 'continue.',
    'else.', 'elseif.', 'for.',
    'if.', 'return.', 'select.', 'case.', 'fcase.',
    'throw.', 'try.', 'catch.', 'catchd.', 'catcht.',
    'while.', 'whilst.',
    'do.', 'end.',
})
lex:add_rule('keyword', token(l.KEYWORD, labeled + single))
-- Comment.
local noteBlock = P('Note') * S(' \t\r')^0 * str * l.newline * (l.any - blockEnd)^0 * blockEnd
lex:add_rule('comment', token(l.COMMENT, P('NB.') * l.nonnewline^0 + noteBlock))

-- Constant
lex:add_rule('constant', token(l.CONSTANT, oneOf({
    '_.', 'a.', 'a:'
})))

return lex