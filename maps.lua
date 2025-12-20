local maps = {}

-- Default map for backward compatibility
maps.pac = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222222342222222222225", --  1
    "6............78............9", --  2
    "6.abbc.abbbc.78.abbbc.abbc.9", --  3
    "6`&yy*.&yyy*.78.&yyy*.&yy*`9", --  4
    "6.deef.deeef.DF.deeef.deef.9", --  5
    "6..........................9", --  6
    "6.abbc.ac.abbbbbbc.ac.abbc.9", --  7
    "6.deef.&*.deegheef.&*.deef.9", --  8
    "6......&*....&*....&*......9", --  9
    "IJJJJC.&kbbc &* abbl*.AJJJJM", -- 10
    "     6.&heef;df;deeg*.9     ", -- 11 (warp tunnels row; spaces = void)
    "     6.&*          &*.9     ", -- 12 (entrance to house row)
    "     6.&* NJOPPQJR &*.9     ", -- 13
    "22222F.df 9      6 df.D22222", -- 14
    "_____ .   9      6   . _____", -- 15 (center row; gate ==)
    "JJJJJC.ac 9      6 ac.AJJJJJ", -- 16
    "     6.&* S222222T &*.9     ", -- 17
    "     6.&*          &*.9     ", -- 18
    "     6.&* abbbbbbc &*.9     ", -- 19
    "12222F.df deegheef df.D22225", -- 20
    "6............&*............9", -- 21
    "6.abbc.abbbc.&*.abbbc.abbc.9", -- 22
    "6.deg*.deeef:df:deeef.&hef.9", -- 23
    "6`..&*.......  .......&*..`9", -- 24 (^^ above house: no-ghost tiles)
    "XBC.&*.ac.abbbbbbc.ac.&*.ABV", -- 25
    "WEF.df.&*.deegheef.&*.df.DEU", -- 26
    "6......&*....&*....&*......9", -- 27
    "6.abbbblkbbc.&*.abblkbbbbc.9", -- 28
    "6.deeeeeeeef.df.deeeeeeeef.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.mspac1 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222342222222222342222225", --  1
    "6......78..........78......9", --  2
    "6`abbc.78.abbbbbbc.78.abbc`9", --  3
    "6.deef.DF.deeeeeef.DF.deef.9", --  4
    "6..........................9", --  5
    "IJC.ac.abbbc.ac.abbbc.ac.AJM", --  6
    "  6.&*.&yyy*.&*.&yyy*.&*.9  ", --  7
    "22F.&*.deeef.&*.deeef.&*.D22", --  8
    "__ .&*.......&*.......&*. __", -- 9
    "JJC.&kbbc abblkbbc abbl*.AJJ", -- 10
    "  6.deeef deeeeeef deeef.9  ", -- 11 (warp tunnels row; spaces = void)
    "  6.                    .9  ", -- 12 (entrance to house row)
    "  6.abbbc NJOPPQJR abbbc.9  ", -- 13
    "  6.&heef 9      6 deeg*.9  ", -- 14
    "  6.&*    9      6    &*.9  ", -- 15 (center row; gate ==)
    "  6.&* ac 9      6 ac &*.9  ", -- 16
    "22F.df &* S222222T &* df.D22", -- 17
    "__ .   &*          &*   . __", -- 18
    "JJC.abblkbbc ac abblkbbc.AJJ", -- 19
    "  6.deeeeeef &* deeeeeef.9  ", -- 20
    "  6.......   &*   .......9  ", -- 21
    "  6.abbbc.abblkbbc.abbbc.9  ", -- 22
    "12F.deeef.deeeeeef.deeef.D25", -- 23
    "6............  ............9", -- 24 (^^ above house: no-ghost tiles)
    "6.abbc.abbbc.ac.abbbc.abbc.9", -- 25
    "6.&yy*.&heef.&*.deeg*.&yy*.9", -- 26
    "6.&yy*.&*....&*....&*.&yy*.9", -- 27
    "6`&yy*.&*.abblkbbc.&*.&yy*`9", -- 28
    "6.deef.df.deeeeeef.df.deef.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.booze1 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "     6_9            6_9     ", --  1
    "     6_9            6_9     ", --  2
    "12222F D222222222222F D22225", --  3
    "6..........................9", --  4
    "6.abbc.abbc.abbc.abbc.abbc.9", --  5
    "6`&yy*.&hef.deef.deg*.&yy*`9", --  6
    "6.deef.&*....  ....&*.deef.9", --  7
    "6......&*.abbbbbbc.&*......9", --  8
    "IJC.ac.&*.deeeeeef.&*.ac.AJM", -- 9
    "  6.&*.df..........df.&*.9  ", -- 10
    "22F.&*....ac.ac.ac....&*.D22", -- 11 (warp tunnels row; spaces = void)
    "__ .&kbbc.&*.&*.&*.abbl*. __", -- 12 (entrance to house row)
    "JJC.deeef.df.&*.df.deeef.AJJ", -- 13
    "  6..........&*..........9  ", -- 14
    "  6.ac.ac.ac.&*.ac.ac.ac.9  ", -- 15 (center row; gate ==)
    "  6.&*.&*.&*.&*.&*.&*.&*.9  ", -- 16
    "  6.&*.&*.&*.&*.&*.&*.&*.9  ", -- 17
    "  6.&*.df.&*.df.&*.df.&*.9  ", -- 18
    "  6.&*....&*.  .&*....&*.9  ", -- 19
    "  6.&*.abblkbbbblkbbc.&*.9  ", -- 20
    "22F.df.deeeeeeeeeeeef.df.D22", -- 21
    "__ ......          ...... __", -- 22
    "JJC.ac.ac NJOPPQJR ac.ac.AJJ", --23
    "  6.&*.&* 9      6 &*.&*.9  ", -- 24 (^^ above house: no-ghost tiles)
    "  6.&*.&* 9      6 &*.&*.9  ", -- 25
    "  6`&*.&* 9      6 &*.&*`9  ", -- 26
    "  6.df.df S222222T df.df.9  ", -- 27
    "  6......          ......9  ", -- 28
    "  IJJC AJJJJJJJJJJJJC AJJM  ", -- 29
    "     6_9            6_9     ", -- 30
    "     6_9            6_9     ", -- 31 (bottom "void" row; often unused)
    "                            ",
}

-- local defaultMap = {
--     -- 28 columns each
--     "                            ",
--     "                            ",
--     "                            ",
--     "1222222222222342222222222225", --  1
--     "6            78            9", --  2
--     "6 ABBC ABBBC 78 ABBBC ABBC 9", --  3
--     "6 7YY8 7YYY8 78 7YYY8 7YY8 9", --  4
--     "6 DEEF DEEEF DF DEEEF DEEF 9", --  5
--     "6                          9", --  6
--     "6 ABBC AC ABBBBBBC AC ABBC 9", --  7
--     "6 DEEF 78 DEEGHEEF 78 DEEF 9", --  8
--     "6      78    78    78      9", --  9
--     "IJJJJC 7KBBC 78 ABBL8 AJJJJM", -- 10
--     "     6 7HEEFxDFxDEEG8 9     ", -- 11 (warp tunnels row; spaces = void)
--     "     6 78          78 9     ", -- 12 (entrance to house row)
--     "     6 78 NJOPPQJR 78 9     ", -- 13
--     "22222F DF 9      6 DF D22222", -- 14
--     "_____     9      6     _____", -- 15 (center row; gate ==)
--     "JJJJJC AC 9      6 AC AJJJJJ", -- 16
--     "     6 78 S222222T 78 9     ", -- 17
--     "     6 78          78 9     ", -- 18
--     "     6 78 ABBBBBBC 78 9     ", -- 19
--     "12222F DF DEEGHEEF DF D22225", -- 20
--     "6            78            9", -- 21
--     "6.ABBC ABBBC 78 ABBBC ABBC 9", -- 22
--     "6.DEG8 DEEEF DF DEEEF 7HEF 9", -- 23
--     "6o..78                78   9", -- 24 (^^ above house: no-ghost tiles)
--     "XBC 78 AC ABBBBBBC AC 78 ABV", -- 25
--     "WEF DF 78 DEEGHEEF 78 DF DEU", -- 26
--     "6      78    78    78      9", -- 27
--     "6 ABBBBLKBBC 78 ABBLKBBBBC 9", -- 28
--     "6 DEEEEEEEEF DF DEEEEEEEEF 9", -- 29
--     "6                          9", -- 30
--     "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
--     "                            ",
-- }

return maps
