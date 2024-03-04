from pygments.lexer import RegexLexer
from pygments.token import *

class AQLLexer(RegexLexer):
    name = 'AQL'
    aliases = ['aql']
    filenames = ['*.aql']

    tokens = {
        'root': [
            (r'\b(LET|FOR|RETURN|FILTER|SORT|COLLECT|INSERT|UPDATE|REPLACE|REMOVE|UPSERT|WITH)\b', Keyword),
            (r'"[^"]*"', String),
            (r"'[^']*'", String),
            (r'\d+', Number),
            (r'//.*?\n', Comment.Single),
            (r'/\*.*?\*/', Comment.Multiline),
            (r'[-+*/=<>!~&|.,:;()\[\]{}]', Punctuation),
            (r'\w+', Name),
        ]
    }