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

maps.mspac2 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "2222222342222222222342222222", --  1
    "_______78..........78_______", --  2
    "BBBBBC 78.abbbbbbc.78 ABBBBB", --  3
    "HEEEEF DF.deegheef.DF DEEEEG", --  4
    "6`...........&*...........`9", --  5
    "6.abbbbbc.ac.&*.ac.abbbbbc.9", --  6
    "6.&heeeef.&*.&*.&*.deeeeg*.9", --  7
    "6.&*......&*.df.&*......&*.9", --  8
    "6.&*.abbc &*....&* abbc.&*.9", -- 9
    "6.df.deg* &kbbbbl* &hef.df.9", -- 10
    "6......&* deeeeeef &*......9", -- 11 (warp tunnels row; spaces = void)
    "XBBBBC.&*          &*.ABBBBV", -- 12 (entrance to house row)
    "WEEEEF.&* NJOPPQJR &*.DEEEEU", -- 13
    "6......&* 9      6 &*......9", -- 14
    "6.abbc.df 9      6 df.abbc.9", -- 15 (center row; gate ==)
    "6.deg*.   9      6   .&hef.9", -- 16
    "6...&*.ac S222222T ac.&*...9", -- 17
    "IJC.&*.&*          &*.&*.AJM", -- 18
    "  6.&*.&kbc abbc abl*.&*.9  ", -- 19
    "  6.df.deef &yy* deef.df.9  ", -- 20
    "  6.........&yy*.........9  ", -- 21
    "  6.abbbbbc.&yy*.abbbbbc.9  ", -- 22
    "22F.deeghef.deef.degheef.D22", -- 23
    "__ ....&*...    ...&*.... __", -- 24 (^^ above house: no-ghost tiles)
    "BBC.ac.&*.abbbbbbc.&*.ac.ABB", -- 25
    "WEF.&*.df.deegheef.df.&*.DEU", -- 26
    "6`..&*.......&*.......&*..`9", -- 27
    "6.abl*.abbbc.&*.abbbc.&kbc.9", -- 28
    "6.deef.deeef.df.deeef.deef.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.mspac3 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222342222342222222225", --  1
    "6.........78....78.........9", --  2
    "6.abbbbbc.78.ac.78.abbbbbc.9", --  3
    "6`&heeeef.DF.&*.DF.deeeeg*`9", --  4
    "6.&*.........&*.........&*.9", --  5
    "6.df.ac.abbc.&*.abbc.ac.df.9", --  6
    "6....&*.&yy*.&*.&yy*.&*....9", --  7
    "XBBC.&*.deef.df.deef.&*.ABBV", --  8
    "EEEF.&*..............&*.DEEE", -- 9
    "_....&kbc abbbbbbc abl*...._", -- 10
    "C.ac deef deeeeeef deef ac.A", -- 11 (warp tunnels row; spaces = void)
    "6.&*                    &*.9", -- 12 (entrance to house row)
    "6.&kbc ac NJOPPQJR ac abl*.9", -- 13
    "6.deef &* 9      6 &* deef.9", -- 14
    "6.     &* 9      6 &*     .9", -- 15 (center row; gate ==)
    "6.ac abl* 9      6 &kbc ac.9", -- 16
    "6.&* deef S222222T deef &*.9", -- 17
    "6.&*                    &*.9", -- 18
    "6.&kbc abbbc ac abbbc abl*.9", -- 19
    "6.deef &heef &* deeg* deef.9", -- 20
    "6......&*....&*....&*......9", -- 21
    "XBC.ac.&*.abblkbbc.&*.ac.ABV", -- 22
    "WEF.&*.df.deeeeeef.df.&*.DEU", -- 23
    "6`..&*.......  .......&*..`9", -- 24 (^^ above house: no-ghost tiles)
    "6.abl*.ABBBC.ac.ABBBC.&kbc.9", -- 25
    "6.deef.7HEEF.&*.DEEG8.deef.9", -- 26
    "6......78....&*....78......9", -- 27
    "6.abbc.78.abblkbbc.78.abbc.9", -- 28
    "6.deef.78.deeeeeef.78.deef.9", -- 29
    "6......78..........78......9", -- 30
    "IJJJJJJLKJJJJJJJJJJLKJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.mspac4 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222222222222222222225", --  1
    "6..........................9", --  2
    "6.ac.abbc.abbbbbbc.abbc.ac.9", --  3
    "6`&*.&yy*.&heeeeg*.&yy*.&*`9", --  4
    "6.&*.deef.&*....&*.deef.&*.9", --  5
    "6.&*......&*.ac.&*......&*.9", --  6
    "6.&kbc.ac.&*.&*.&*.ac.abl*.9", --  7
    "6.deef.&*.df.&*.df.&*.deef.9", --  8
    "6......&*....&*....&*......9", -- 9
    "IJC.abblkbbc &* abblkbbc.AJM", -- 10
    "  6.deegheef df deegheef.9  ", -- 11 (warp tunnels row; spaces = void)
    "  6....&*          &*....9  ", -- 12 (entrance to house row)
    "22F AC.&* NJOPPQJR &*.AC D22", -- 13
    "____78.df 9      6 df.78____", -- 14
    "BBBBL8.   9      6   .7KBBBB", -- 15 (center row; gate ==)
    "EEEEG8.ac 9      6 ac.7HEEEE", -- 16
    "____78.&* S222222T &*.78____", -- 17
    "JJC DF.&*          &*.DF AJJ", -- 18
    "  6....&kbbc ac abbl*....9  ", -- 19
    "  6.ac.deeef &* deeef.ac.9  ", -- 20
    "  6.&*....   &*   ....&*.9  ", -- 21
    "  6.&kbbc.ac &* ac.abbl*.9  ", -- 22
    "12F.deeef.&* df &*.deeef.D25", -- 23
    "6.........&*    &*.........9", -- 24 (^^ above house: no-ghost tiles)
    "6.abbc.ac.&kbbbbl*.ac.abbc.9", -- 25
    "6.&hef.&*.deeeeeef.&*.deg*.9", -- 26
    "6.&*...&*..........&*...&*.9", -- 27
    "6`&*.ablkbbc.AC.abblkbc.&*`9", -- 28
    "6.df.deeeeef.96.deeeeef.df.9", -- 29
    "6............96............9", -- 30
    "IJJJJJJJJJJJJMIJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
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
    "6.abbc.abbbbbbbbbbbbc.abbc.9", --  5
    "6`&yy*.&heeeeeeeeeeg*.&yy*`9", --  6
    "6.deef.&*....  ....&*.deef.9", --  7
    "6......&*.abbbbbbc.&*......9", --  8
    "IJC.ac.&*.deeeeeef.&*.ac.AJM", -- 9
    "  6.&*.df..........df.&*.9  ", -- 10
    "22F.&*....ac.ac.ac....&*.D22", -- 11 (warp tunnels row; spaces = void)
    "__ .&kbbc.&*.&*.&*.abbl*. __", -- 12 (entrance to house row)
    "JJC.deeg*.&*.&*.&*.&heef.AJJ", -- 13
    "  6....&*.&*.&*.&*.&*....9  ", -- 14
    "  6.ac.&*.&*.&*.&*.&*.ac.9  ", -- 15 (center row; gate ==)
    "  6.&*.&*.df.&*.df.&*.&*.9  ", -- 16
    "  6.&*.&*....&*....&*.&*.9  ", -- 17
    "  6.&*.df.ac.df.ac.df.&*.9  ", -- 18
    "  6.&*....&*.  .&*....&*.9  ", -- 19
    "  6.&*.ac.&kbbbbl*.ac.&*.9  ", -- 20
    "22F.df.df.deeeeeef.df.df.D22", -- 21
    "__ .......        ....... __", -- 22
    "JJC.ac.ac.NJOPPQJR.ac.ac.AJJ", --23
    "  6.&*.&*.9      6.&*.&*.9  ", -- 24 (^^ above house: no-ghost tiles)
    "  6.&*.&*.9      6.&*.&*.9  ", -- 25
    "  6`&*.&*.9      6.&*.&*`9  ", -- 26
    "  6.df.df.S222222T.df.df.9  ", -- 27
    "  6.......        .......9  ", -- 28
    "  IJJC AJJJJJJJJJJJJC AJJM  ", -- 29
    "     6_9            6_9     ", -- 30
    "     6_9            6_9     ", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.booze2 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222222342222222222225", --  1
    "6............78............9", --  2
    "6.abbc.abbbc.78.abbbc.abbc.9", --  3
    "6.deg*.&yyy*.78.&yyy*.&hef.9", --  4
    "6`..&*.deeef.78.deeef.&*..`9", --  5
    "IJC.&*.......78.......&*.AJM", --  6
    "  6.&*.AC.ABBLKBBC.AC.&*.9  ", --  7
    "22F.df.78.DEEEEEEF.78.df.D22", --  8
    "__ ....78..........78.... __", -- 9
    "BBBBBBBL8 abbbbbbc 7KBBBBBBB", -- 10
    "WEEEEEEEF deeeeeef DEEEEEEEU", -- 11 (warp tunnels row; spaces = void)
    "6......              ......9", -- 12 (entrance to house row)
    "6.abbc.ac NJOPPQJR ac.abbc.9", -- 13
    "6.&hef.&* 9      6 &*.deg*.9", -- 14
    "6.&*...&* 9      6 &*...&*.9", -- 15 (center row; gate ==)
    "6.&*.abl* 9      6 &kbc.&*.9", -- 16
    "6.&*.deef S222222T deef.&*.9", -- 17
    "6.&*...              ...&*.9", -- 18
    "6.&kbc.ac abbbbbbc ac.abl*.9", -- 19
    "F.deef.&* deegheef &*.deef.D", -- 20
    "_......&*    &*    &*......_", -- 21
    "BBC.ac.&kbbc &* abbl*.ac.ABB", -- 22
    "WEF.&*.deeef;df;deeef.&*.DEU", -- 23
    "6`..&*....        ....&*..`9", -- 24 (^^ above house: no-ghost tiles)
    "6.abl*.ac.abbbbbbc.ac.&kbc.9", -- 25
    "6.deef.&*.deegheef.&*.deef.9", -- 26
    "6......&*....&*....&*......9", -- 27
    "6.abbbblkbbc.&*.abblkbbbbc.9", -- 28
    "6.deeeeeeeef.df.deeeeeeeef.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}


maps.booze3 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "6_D2222222222342222222222F_9", --  1
    "6............78............9", --  2
    "6.abbc.abbbc.78.abbbc.abbc.9", --  3
    "6.deg*.&yyy*.78.&yyy*.&hef.9", --  4
    "6`..&*.deeef.DF.deeef.&*..`9", --  5
    "IJC.&*................&*.AJM", --  6
    "  6.&*.ac.abbbbbbc.ac.&*.9  ", --  7
    "22F.df.&*.deegheef.&*.df.D22", --  8
    "__ ....&*....&*....&*.... __", -- 9
    "JJC.abblkbbc &* abblkbbc.AJJ", -- 10
    "  6.deegheef;df;deegheef.9  ", -- 11 (warp tunnels row; spaces = void)
    "  6....&*          &*....9  ", -- 12 (entrance to house row)
    "  6.ac.&* NJOPPQJR &*.ac.9  ", -- 13
    "12F.&*.df 9      6 df.&*.D25", -- 14
    "6...&*.   9      6   .&*...9", -- 15 (center row; gate ==)
    "6.abl*.ac 9      6 ac.&kbc.9", -- 16
    "6.deef.&* S222222T &*.deef.9", -- 17
    "6......&*          &*......9", -- 18
    "XBC.abblkbbc ac abblkbbc.ABV", -- 19
    "WEF.deegheef &* deegheef.DEU", -- 20
    "6......&*....&*....&*......9", -- 21
    "6.abbc.&*.abblkbbc.&*.abbc.9", -- 22
    "6.deg*.df:deeeeeef:df.&hef.9", -- 23
    "6`..&*.......  .......&*..`9", -- 24 (^^ above house: no-ghost tiles)
    "XBC.&*.AC.abbbbbbc.AC.&*.ABV", -- 25
    "WEF.df.96.deegheef.96.df.DEU", -- 26
    "6  ....96....&*....96....  9", -- 27
    "6_AJJJJMIJJC.&*.AJJMIJJJJC_9", -- 28
    "6_9        6.df.9        6_9", -- 29
    "6_9        6....9        6_9", -- 30
    "6_9        IJJJJM        6_9", -- 31 (bottom "void" row; often unused)
    "                            ",
}


maps.booze4 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "12222F_91222222222256_D22225", --  1
    "6......96..........96......9", --  2
    "6.abbc.96.abbbbbbc.96.abbc.9", --  3
    "6.&hef.DF.&yyyyyy*.DF.deg*.9", --  4
    "6`&*......&yyyyyy*......&*`9", --  5
    "6.&*.abbc.&yyyyyy*.abbc.&*.9", --  6
    "6.df.deg*.&yyyyyy*.&hef.df.9", --  7
    "6......&*.deeeeeef.&*......9", --  8
    "IJJJJC.&*..........&*.AJJJJM", -- 9
    "     6.&* abbbbbbc &*.9     ", -- 10
    "     6.df deeeeeef df.9     ", -- 11 (warp tunnels row; spaces = void)
    "     6.              .9     ", -- 12 (entrance to house row)
    "     6.ac NJOPPQJR ac.9     ", -- 13
    "  122F.&* 9      6 &*.D225  ", -- 14
    "  6....&* 9      6 &*....9  ", -- 15 (center row; gate ==)
    "  6.abbl* 9      6 &kbbc.9  ", -- 16
    "22F.deeg* S222222T &heef.D22", -- 17
    "__ ....&*          &*.... __", -- 18
    "BBC.ac.&* abbbbbbc &*.ac.ABB", -- 19
    "WEF.&*.df deegheef df.&*.DEU", -- 20
    "6...&*.......&*.......&*...9", -- 21
    "6.abl*.abbbc.&*.abbbc.&kbc.9", -- 22
    "6.deef.&heef.df.deeg*.deef.9", -- 23
    "6......&*....  ....&*......9", -- 24 (^^ above house: no-ghost tiles)
    "XBBBBC.&*.abbbbbbc.&*.ABBBBV", -- 25
    "WEEEEF.&*.&heeeeg*.&*.DEEEEU", -- 26
    "6`.....&*.&*....&*.&*.....`9", -- 27
    "6.abbc.&*.&*.AC.&*.&*.abbc.9", -- 28
    "6.deef.df.df.96.df.df.deef.9", -- 29
    "6............96............9", -- 30
    "IJJJJC_AJJJJJMIJJJJJC_AJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

maps.booze5 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "12222222225      12222222225", --  1
    "6.........9      6.........9", --  2
    "6.abbc.ac.9      6.ac.abbc.9", --  3
    "6`&yy*.&*.91222256.&*.&yy*`9", --  4
    "6.deef.&*.96....96.&*.deef.9", --  5
    "6......&*.96.ac.96.&*......9", --  6
    "IJC.abbl*.96.&*.96.&kbbc.AJM", --  7
    "  6.deeg*.DF.&*.DF.&heef.9  ", --  8
    "  6....&*....&*....&*....9  ", -- 9
    "  IJJC.&* abblkbbc &*.AJJM  ", -- 10
    "     6.&* deeeeeef &*.9     ", -- 11 (warp tunnels row; spaces = void)
    "     6.&*          &*.9     ", -- 12 (entrance to house row)
    "     6.&* NJOPPQJR &*.9     ", -- 13
    "22222F.df 9      6 df.D22222", -- 14
    "__ ....   9      6   .... __", -- 15 (center row; gate ==)
    "JJC.abbbc 9      6 abbbc.AJJ", -- 16
    "  6.deeg* S222222T &heef.9  ", -- 17
    "  6....&*          &*....9  ", -- 18
    "  6.ac.&* abbbbbbc &*.ac.9  ", -- 19
    "12F.&*.df deegheef df.&*.D25", -- 20
    "6...&*.......&*.......&*...9", -- 21
    "6.ablkbbc.ac.&*.ac.abblkbc.9", -- 22
    "6.deeeeef.&*.df.&*.deeeeef.9", -- 23
    "6.........&*.  .&*.........9", -- 24 (^^ above house: no-ghost tiles)
    "IJJJJC.ac.&kbbbbl*.ac.AJJJJM", -- 25
    "   12F.&*.deeeeeef.&*.D25   ", -- 26
    "   6`..&*..........&*..`9   ", -- 27
    "   6.ablkbbc.AC.abblkbc.9   ", -- 28
    "   6.deeeeef.96.deeeeef.9   ", -- 29
    "   6.........96.........9   ", -- 30
    "   IJJJJJJJJJMIJJJJJJJJJM   ", -- 31 (bottom "void" row; often unused)
    "                            ",
}




maps.arrange1 = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "  122222222223422222222225  ", --  1
    "  6..........78..........9  ", --  2
    "12F.ac abbbc.DF.abbbc ac.D25", --  3
    "6.`.&* deeg*....&heef &*.`.9", --  4
    "6.abl*....&* ac &*....&kbc.9", --  5
    "6.deef.ac.df &* df.ac.deef.9", --  6
    "6......&*.   &*   .&*......9", --  7
    "IJJC abl*.abblkbbc.&kbc AJJM", --  8
    "   6 deef.deeeeeef.deef 9   ", -- 9
    "   6......        ......9   ", -- 10
    "   6.abbc NJOPPQJR abbc.9   ", -- 11 (warp tunnels row; spaces = void)
    "   6.&yy* 9      6 &yy*.9   ", -- 12 (entrance to house row)
    "   6.&yy* 9      6 &yy*.9   ", -- 13
    "222F.deef 9      6 deef.D222", -- 14
    "___ .     9      6     . ___",  -- 15 (center row; gate ==)
    "JJJC.abbc S222222T abbc.AJJJ", -- 16
    "   6.&yy*          &yy*.9   ", -- 17
    "   6.&yy* abbbbbbc &yy*.9   ", -- 18
    "   6.deef deegheef deef.9   ", -- 19
    "   6.........&*.........9   ", -- 20
    "   6 abbbbbc.&*.abbbbbc 9   ", -- 21
    "122F degheef.df.deeghef D225", -- 22
    "6......&*...    ...&*......9", -- 23
    "6.abbc.df.ac.AC.ac.df.abbc.9", -- 24 (^^ above house: no-ghost tiles)
    "6.deg*....&*.78.&*....&hef.9", -- 25
    "6...&* abbl*.78.&kbbc &*...9", -- 26
    "IJC`df deeef.78.deeef df`AJM", -- 27
    "  6..........78..........9  ", -- 28
    "  IJJJJJJJJJJLKJJJJJJJJJJM  ", -- 29
    "                            ", -- 30
    "                            ", -- 31 (bottom "void" row; often unused)
    "                            ",
}

return maps
