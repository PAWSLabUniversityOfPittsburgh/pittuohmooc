rm( list = ls());

################
main.directory ='/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource'
#1. reading background information
input = 'overlap-analysis.csv';
file.name <- file.path(main.directory, input);
data<-read.csv(file.name,header = T,stringsAsFactors = T,sep=",");


##############Cluster_Gender
##############
table(data$Cluster_Gender,data$Cluster_Education)
#    1   2   3
# 1 399 101  70
# 2 125  53  50
# (399+53)/(399 +101 + 70 +125+  53 + 50)≈0.57
table(data$Cluster_Gender,data$Cluster_NRows)
#    1   2   3
# 1 197 186 187
# 2  69  80  79
# (197+80)/( 197 +186+ 187 + 69 + 80+  79)≈0.35
table(data$Cluster_Gender,data$Cluster_ProblemsSolved)
#    1   2   3
# 1 188 221 161
# 2  76  95  57
# (221+76)/(188+ 221 +161+76+  95 + 57)≈0.37
table(data$Cluster_Gender,data$Cluster_StudentProblemPercCorrect)
#    1   2   3
# 1 176 184 210
# 2  90  82  56
# (210+90)/(176 +184 +210+90 + 82 + 56)≈0.38
table(data$Cluster_Gender,data$Cluster_Hier2Cos)
#    1   2
# 1 410 160
# 2 155  73
# (410+73)/(410+ 160 +155 + 73)=0.61
table(data$Cluster_Gender,data$Cluster_Hier3Cos)
#   1   2   3
# 1 133 160 277
# 2  53  73 102
# (277+73)/(133 +160 +277+ 53 + 73+ 102)=0.44
table(data$Cluster_Gender,data$Cluster_CosPrevSnap2)
#   1   2
# 1 259 311
# 2 124 104
# (311+124)/(259 +311+ 124 +104)=0.55
table(data$Cluster_Gender,data$Cluster_CosPrevSnapTime2)
#   1   2
# 1 440 130
# 2 197  31
# (440+31)/(440 +130 + 197+  31)=0.59
table(data$Cluster_Gender,data$Cluster_CosPrevSnapTime2Sup1)
#   1   2
# 1 313 257
# 2 154  74
# (313+74)/(313+ 257+ 154 + 74)=0.48
table(data$Cluster_Gender,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 189 257 124
# 2  93  74  61
# (257+93)/(189+ 257+ 124+  93+  74 + 61)=0.44
table(data$Cluster_Gender,data$Cluster_SpecClustPrevSnapTime2Sup1)
#   1   2
# 1 182 388
# 2  60 168
# (388+60)/(182+ 388+ 60+ 168)=0.56
table(data$Cluster_Gender,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 293 114 163
# 2  82  29 117
# (293+117)/(293 +114+ 163+  82 + 29+ 117)=0.51
table(data$Cluster_Gender,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 298 272
# 2 118 110
# (298+110)/(298 +272+ 118 +110)=0.51
table(data$Cluster_Gender,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#   1   2   3
# 1 192 106 272
# 2  66  52 110
# (272+66)/(192 +106 +272 + 66 + 52+ 110)=0.42
table(data$Cluster_Gender,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#   1   2
# 1 197 373
# 2  98 130
# (373+98)/(197+ 373 +  98+ 130)=0.59
table(data$Cluster_Gender,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#   1   2   3
# 1 280 181 109
# 2 109  91  28
# (280+91)/(280 +181 +109 +109+  91+  28)=0.46
##############


##############Cluster_Education
##############
table(data$Cluster_Education,data$Cluster_NRows)
#    1   2   3
# 1 162 185 177
# 2  66  38  50
# 3  38  43  39
# (185+66+39)/(162+ 185+ 177+ 66 + 38+  50 +38 + 43 + 39)≈0.36
table(data$Cluster_Education,data$Cluster_ProblemsSolved)
#    1   2   3
# 1 172 226 126
# 2  43  58  53
# 3  49  32  39
# (226+53+49)/(172+ 226+ 126+ 43 + 58 + 53+ 49 + 32+  39)≈0.41
table(data$Cluster_Education,data$Cluster_StudentProblemPercCorrect)
#    1   2   3
# 1 194 168 162
# 2  45  53  56
# 3  27  45  48
# (194+56+45)/(194 +168+ 162+ 45 + 53  +56  +27 + 45+  48)≈0.37
table(data$Cluster_Education,data$Cluster_Hier2Cos)
#    1   2
# 1 375 149
# 2 106  48
# 3  84  36
# (375+48)/(375 +149+ 106 + 48+84  +36)=0.53
table(data$Cluster_Education,data$Cluster_Hier3Cos)
#   1   2   3
# 1 114 149 261
# 2  40  48  66
# 3  32  36  52
# (261+48+32)/(114 +149+ 261+  40+  48+  66 +32 + 36 + 52)=0.43
table(data$Cluster_Education,data$Cluster_CosPrevSnap2)
#    1   2
# 1 247 277
# 2  82  72
# 3  54  66
# (277+82)/( 247+ 277+ 82 + 72+54+  66 )=0.45
table(data$Cluster_Education,data$Cluster_CosPrevSnapTime2)
#   1   2
# 1 423 101
# 2 119  35
# 3  95  25
# (423+35)/(423+ 101+ 119 + 35+ 95+  25)=0.57
table(data$Cluster_Education,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 300 224
# 2  98  56
# 3  69  51
# (300+56)/( 300+ 224+   98+  56+ 69 + 51 )=0.45
table(data$Cluster_Education,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 169 224 131
# 2  65  56  33
# 3  48  51  21
# (224+65+21)/(169 +224+ 131+ 65+  56  +33 +48  +51+  21)=0.39
table(data$Cluster_Education,data$Cluster_SpecClustPrevSnapTime2Sup1)
#   1   2
# 1 165 359
# 2  51 103
# 3  26  94
# (359 + 51)/(165 +359+  51+ 103+ 26 + 94)=0.51
table(data$Cluster_Education,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 257 101 166
# 2  62  29  63
# 3  56  13  51
# (257+63+13)/( 257+ 101+ 166+ 62+  29 + 63 + 56 + 13 + 51)=0.42
table(data$Cluster_Education,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#   1   2
# 1 272 252
# 2  83  71
# 3  61  59
# (272+71)/( 272+ 252+ 83 + 71 +61 + 59)=0.43
table(data$Cluster_Education,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#   1   2   3
# 1 175  97 252
# 2  49  34  71
# 3  34  27  59
# (252+ 49+27)/( 175+  97+ 252+ 49+  34 + 71 + 34 + 27+  59 )=0.41
table(data$Cluster_Education,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 194 330
# 2  62  92
# 3  39  81
# (330 +62)/(194 +330  + 62 + 92 +39+  81)=0.49
table(data$Cluster_Education,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 252 177  95
# 2  76  56  22
# 3  61  39  20
# (252+ 56 +20 )/( 252 +177+  95 + 76 + 56+  22+ 61  +39+  20)=0.41
##############


##############Cluster_NRows
##############
table(data$Cluster_NRows,data$Cluster_ProblemsSolved)
#     1   2   3
# 1  16  64 186
# 2  96 142  28
# 3 152 110   4
# (186+152+142)/(16+  64+ 186+  96+ 142+  28 +152+ 110 +  4 )≈0.60
table(data$Cluster_NRows,data$Cluster_StudentProblemPercCorrect)
#     1   2   3
# 1  46  62 158
# 2  64 106  96
# 3 156  98  12
# (158+156+106)/(46+  62+ 158+ 64 +106 + 96 + 156+  98 + 12)≈0.53
table(data$Cluster_NRows,data$Cluster_Hier2Cos)
#    1   2
# 1 239  27
# 2 218  48
# 3 108 158
# (239+158)/( 239 + 27 +218+  48 +108+ 158 )=0.50
table(data$Cluster_NRows,data$Cluster_Hier3Cos)
#   1   2   3
# 1 160  27  79
# 2  26  48 192
# 3   0 158 108
# (160+158+192)/( 160  +27+  79 +26 + 48+ 192 + 0 +158+ 108 )=0.64
table(data$Cluster_NRows,data$Cluster_CosPrevSnap2)
#    1   2
# 1 133 133
# 2  77 189
# 3 173  93
# (189 + 173)/(133 +133+ 77+ 189 +173+  93)=0.45
table(data$Cluster_NRows,data$Cluster_CosPrevSnapTime2)
#    1   2
# 1 218  48
# 2 212  54
# 3 207  59
# (218+59)/(218  +48+ 212  +54 + 207 + 59)=0.35
table(data$Cluster_NRows,data$Cluster_CosPrevSnapTime2Sup1)
#   1   2
# 1 211  55
# 2 159 107
# 3  97 169
# (211+169)/(211 + 55 +159+ 107+ 97+ 169)=0.48
table(data$Cluster_NRows,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 150  55  61
# 2  64 107  95
# 3  68 169  29
# (169+150+95)/(150 + 55 + 61 + 64 +107 + 95 + 68+ 169+  29)=0.52
table(data$Cluster_NRows,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1  38 228
# 2  54 212
# 3 150 116
# (228+150)/(38 +228 +54+ 212+  150+ 116)=0.47
table(data$Cluster_NRows,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 153  18  95
# 2 155  23  88
# 3  67 102  97
# (155+102+95)/(153 + 18 + 95+ 155+ 23  +88 +  67 +102 + 97)=0.44
table(data$Cluster_NRows,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#   1   2
# 1 143 123
# 2  83 183
# 3 190  76
# (190+183)/(143 +123+ 83 +183 + 190+  76 )=0.47
table(data$Cluster_NRows,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 133  10 123
# 2  67  16 183
# 3  58 132  76
# (183+133+132)/( 133 + 10 +123 + 67 + 16+ 183 + 58 +132+  76)=0.56
table(data$Cluster_NRows,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1  59 207
# 2  66 200
# 3 170  96
# (207+170)/(59 +207 + 66+ 200+ 170+  96)=0.47
table(data$Cluster_NRows,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#   1   2   3
# 1 179  54  33
# 2 157  59  50
# 3  53 159  54
# (179+159+50)/(179 + 54 + 33 + 157 + 59 + 50 + 53+ 159 + 54)=0.49
##############


##############Cluster_ProblemsSolved
##############
table(data$Cluster_ProblemsSolved,data$Cluster_StudentProblemPercCorrect)
#    1   2   3
# 1  92  97  75
# 2 110 119  87
# 3  64  50 104
# (119+104+92)/( 92 + 97  +75  +110 +119+  87 + 64 + 50 +104)≈0.39
table(data$Cluster_ProblemsSolved,data$Cluster_Hier2Cos)
#    1   2
# 1 166  98
# 2 232  84
# 3 167  51
# (232+98)/( 166+  98 +232  +84 +167 + 51)=0.41
table(data$Cluster_ProblemsSolved,data$Cluster_Hier3Cos)
#     1   2   3
# 1  10  98 156
# 2  38  84 194
# 3 138  51  29
# (194+138+98)/(10 + 98 +156+  38 + 84+ 194 +138+  51 + 29 )=0.54
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnap2)
#    1   2
# 1 101 163
# 2 129 187
# 3 153  65
# (187+153)/(101 +163+ 129+ 187+  153+  65)=0.43
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnapTime2)
#    1   2
# 1 192  72
# 2 251  65
# 3 194  24
# (251+72)/(192 + 72 + 251 + 65 +194  +24)=0.40
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 103 161
# 2 187 129
# 3 177  41
# (187+161)/( 103 +161 +187+ 129+ 177+  41)=0.44
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1  34 161  69
# 2  93 129  94
# 3 155  41  22
# (161+155+94)/(34 +161+  69 + 93+ 129+  94 +155 + 41+  22)=0.51
table(data$Cluster_ProblemsSolved,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1 106 158
# 2  82 234
# 3  54 164
# (234+106)/(106 +158+  82 +234+ 54 +164)=0.43
table(data$Cluster_ProblemsSolved,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 129  70  65
# 2 153  52 111
# 3  93  21 104
# (153+104+70)/( 129  +70 + 65+ 153 + 52+ 111 + 93 + 21 +104)=0.41
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 128 136
# 2 123 193
# 3 165  53
# (193+165)/(128 +136 + 123+ 193+  165+  53)=0.45
table(data$Cluster_ProblemsSolved,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1  38  90 136
# 2  69  54 193
# 3 151  14  53
# (193+151+90)/( 38 + 90+ 136 +69 + 54+ 193+ 151 + 14+  53 )=0.54
table(data$Cluster_ProblemsSolved,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 105 159
# 2 111 205
# 3  79 139
# (205+105)/(105 +159+ 111+ 205+  79+ 139 )=0.39
table(data$Cluster_ProblemsSolved,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 118  97  49
# 2 161 100  55
# 3 110  75  33
# (161+97+33)/( 118 + 97+  49+ 161+ 100 + 55 + 110 + 75 + 33)=0.36
##############


##############Cluster_StudentProblemPercCorrect
##############
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_Hier2Cos)
#   1   2
# 1 124 142
# 2 194  72
# 3 247  19
# (247+142)/(124 +142+  194 + 72+ 247+  19 )=0.49
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_Hier3Cos)
#    1   2   3
# 1  35 142  89
# 2  54  72 140
# 3  97  19 150
# (142+150+54)/(35+ 142+  89 +54 + 72 +140+ 97 + 19+ 150 )=0.43
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnap2)
#    1   2
# 1 189  77
# 2 124 142
# 3  70 196
# (196+189)/(189  +77 + 124+ 142  +70+ 196)=0.48
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnapTime2)
#    1   2
# 1 224  42
# 2 208  58
# 3 205  61
# (224+61)/(224 + 42 +208 + 58+ 205+  61 )=0.36
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 142 124
# 2 150 116
# 3 175  91
# (175+124)/( 142+ 124 +150 +116 +175 + 91)=0.37
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnapTime3Sup1)
#   1   2   3
# 1 109 124  33
# 2  90 116  60
# 3  83  91  92
# (124+92+90)/(109 +124 + 33  +90+ 116 + 60 +83 + 91 + 92 )=0.38
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1 142 124
# 2  69 197
# 3  31 235
# (235+142)/(142+124+ 69 +197+ 31+ 235)=0.47
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1  51  91 124
# 2 131  36  99
# 3 193  16  57
# (193 + 124+36)/( 51 + 91+ 124+ 131 + 36 + 99+ 193+  16 + 57)=0.44
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 187  79
# 2 137 129
# 3  92 174
# (187+174)/(187 + 79+ 137+ 129+ 92+ 174)=0.45
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1  94  93  79
# 2  78  59 129
# 3  86   6 174
# (174+94+59)/(94  +93 + 79  +78+  59 +129 +86+   6 +174)=0.41
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 172  94
# 2  99 167
# 3  24 242
# (242+172)/(172 + 94 +99+ 167 +24 +242)=0.52
table(data$Cluster_StudentProblemPercCorrect,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#   1   2   3
# 1  57 167  42
# 2 132  83  51
# 3 200  22  44
# (200+167+51)/( 57+ 167+  42+  132 + 83 + 51 +  200+  22 + 44 )=0.52
##############


##############Cluster_Hier2Cos
##############
table(data$Cluster_Hier2Cos,data$Cluster_Hier3Cos)
#    1   2   3
# 1 186   0 379
# 2   0 233   0
# (379+233)/( 186 +  0 +379 +   0+ 233+   0)=0.77
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnap2)
#    1   2
# 1 173 392
# 2 210  23
# (392+210)/(173 +392 +210+  23)=0.75
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnapTime2)
#   1   2
# 1 443 122
# 2 194  39
# (443+39)/(443 +122 +194+  39)=0.6
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 353 212
# 2 114 119
# (353+119)/(353+ 212+ 114+ 119)=0.59
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 178 212 175
# 2 104 119  10
# (212+104)/(178 +212 +175+ 104+ 119+  10)=0.40
table(data$Cluster_Hier2Cos,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1  93 472
# 2 149  84
# (427+149)/(93 +472+ 149 + 84)=0.72
table(data$Cluster_Hier2Cos,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 359  50 156
# 2  16  93 124
# (359+124)/( 359 + 50+ 156+ 16 + 93 +124 )=0.61
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 208 357
# 2 208  25
# (357+208)/( 208+ 357 +208 + 25 )=0.71
table(data$Cluster_Hier2Cos,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 176  32 357
# 2  82 126  25
# (357+126)/(176  +32+ 357 + 82 +126 + 25 )=0.61
table(data$Cluster_Hier2Cos,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 101 464
# 2 194  39
# (464+194)/(101+ 464 +194+  39 )=0.82
table(data$Cluster_Hier2Cos,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 376  83 106
# 2  13 189  31
# (376+189)/(376 + 83 +106 +13 +189 + 31)=0.71
##############

##############Cluster_Hier3Cos
##############
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnap2)
#    1   2
# 1 113  73
# 2 210  23
# 3  60 319
# (210+319)/(113 + 73+  210+  23+  60+ 319 )=0.66
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnapTime2)
#    1   2
# 1 159  27
# 2 194  39
# 3 284  95
# (284+39)/(159+  27 +194+  39+ 284+  95 )=0.40
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 157  29
# 2 114 119
# 3 196 183
# (196+119)/(157 + 29+ 114+ 119 +196+ 183 )=0.39
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 127  29  30
# 2 104 119  10
# 3  51 183 145
# (183+127+10)/( 127  +29 + 30 +104 +119  +10 +51+ 183+ 145)=0.40
table(data$Cluster_Hier3Cos,data$Cluster_SpecClustPrevSnapTime2Sup1)
#   1   2
# 1  27 159
# 2 149  84
# 3  66 313
# (313+149)/( 27 +159 +149 + 84+ 66+ 313)=0.58
table(data$Cluster_Hier3Cos,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 101  13  72
# 2  16  93 124
# 3 258  37  84
# (258+124+13)/(101 + 13 + 72 +16 + 93+ 124+ 258 + 37+  84 ) =0.49
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 119  67
# 2 208  25
# 3  89 290
# (208+290)/( 119 + 67 + 208+  25 +89 +290 )=0.62
table(data$Cluster_Hier3Cos,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 114   5  67
# 2  82 126  25
# 3  62  27 290
# (290+126+114)/(114 +  5 + 67 + 82 +126+  25+  62+  27+ 290)=0.66
table(data$Cluster_Hier3Cos,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1  43 143
# 2 194  39
# 3  58 321
# (194+321)/(43+ 143 +194 + 39  + 58+ 321)=0.65
table(data$Cluster_Hier3Cos,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 126  38  22
# 2  13 189  31
# 3 250  45  84
# (250+189+22)/(126 + 38+  22 +13 +189 + 31 +250 + 45 + 84 )=0.58
##############

##############Cluster_CosPrevSnap2
##############
table(data$Cluster_CosPrevSnap2,data$Cluster_CosPrevSnapTime2)
#    1   2
# 1 330  53
# 2 307 108
# (330+108)/( 330+  53 +307+ 108)=0.55
table(data$Cluster_CosPrevSnap2,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 250 133
# 2 217 198
# (250+198)/(250 +133+ 217+ 198)=0.56
table(data$Cluster_CosPrevSnap2,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 221 133  29
# 2  61 198 156
# (221+198)/(221+ 133 + 29 + 61+ 198 +156)=0.53
table(data$Cluster_CosPrevSnap2,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1 169 214
# 2  73 342
# (342+169)/(169 +214+  73 +342)=0.64
table(data$Cluster_CosPrevSnap2,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1  73 100 210
# 2 302  43  70
# (302+210)/( 73 +100 +210+  302  +43+  70)=0.64
table(data$Cluster_CosPrevSnap2,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 317  66
# 2  99 316
# (317+316)/( 317 + 66 +99+ 316)=0.79
table(data$Cluster_CosPrevSnap2,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#     1   2   3
# 1 177 140  66
# 2  81  18 316
# (316+177)/(177 +140  +66 + 81+  18+ 316)=0.62
table(data$Cluster_CosPrevSnap2,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 255 128
# 2  40 375
# (375+255)/( 255+ 128+ 40 +375)=0.79
table(data$Cluster_CosPrevSnap2,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1  97 243  43
# 2 292  29  94
# (292+243)/( 97+ 243+  43+  292 + 29 + 94)=0.67
##############


##############Cluster_CosPrevSnapTime2
##############
table(data$Cluster_CosPrevSnapTime2,data$Cluster_CosPrevSnapTime2Sup1)
#    1   2
# 1 441 196
# 2  26 135
# (441+135)/( 441 +196  +26+ 135)=0.72
table(data$Cluster_CosPrevSnapTime2,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 265 196 176
# 2  17 135   9
# (265+135)/(265 +196 +176+  17 +135 +  9)=0.50
table(data$Cluster_CosPrevSnapTime2,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1 161 476
# 2  81  80
# (476+81)/(161+ 476  +81  +80)=0.70
table(data$Cluster_CosPrevSnapTime2,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 276  85 276
# 2  99  58   4
# (276+99)/(276 + 85 +276+  99 + 58   +4)=0.47
table(data$Cluster_CosPrevSnapTime2,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#   1   2
# 1 350 287
# 2  66  95
# (350+95)/(350+ 287 +66+  95 )=0.56
table(data$Cluster_CosPrevSnapTime2,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 224 126 287
# 2  34  32  95
# (287+34)/( 224 +126+ 287+  34 + 32+  95)=0.40
table(data$Cluster_CosPrevSnapTime2,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 248 389
# 2  47 114
# (389+47)/(248+ 389+ 47+ 114) =0.55
table(data$Cluster_CosPrevSnapTime2,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 298 227 112
# 2  91  45  25
# (298+45)/(298+ 227+112+  91 + 45 + 25)=0.43
##############

##############Cluster_CosPrevSnapTime2Sup1
##############
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_CosPrevSnapTime3Sup1)
#    1   2   3
# 1 282   0 185
# 2   0 331   0
# (331+282)/(282   +0+ 185+  0 +331  + 0)=0.77
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1  77 390
# 2 165 166
# (390+165)/(77 +390+ 165+ 166)=0.70
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1 195  26 246
# 2 180 117  34
# (246+180)/(195 + 26+ 246 + 180+ 117 + 34)=0.53
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#   1   2
# 1 227 240
# 2 189 142
# (240+189)/( 227+ 240+189 +142)=0.54
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 161  66 240
# 2  97  92 142
# (240+97)/(161 + 66+240  +97  +92 +142 )=0.42
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 178 289
# 2 117 214
# (289+117)/(178 +289+ 117+ 214)=0.51
table(data$Cluster_CosPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1 269 161  37
# 2 120 111 100
# (269+111)/(269 +161 + 37+ 120 +111+ 100)=0.48
##############

##############Cluster_CosPrevSnapTime3Sup1
##############
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapTime2Sup1)
#    1   2
# 1  69 213
# 2 165 166
# 3   8 177
# (213+165)/( 69+ 213+ 165+ 166+  8 +177)=0.47
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1  61  20 201
# 2 180 117  34
# 3 134   6  45
# (201+180+6)/(61 + 20+ 201+ 180+ 117 + 34 +134+   6 + 45 )=0.48
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 215  67
# 2 189 142
# 3  12 173
# (215+173)/(215 + 67+  189+ 142 +12+ 173 )=0.49
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 157  58  67
# 2  97  92 142
# 3   4   8 173
# (173+157+92)/( 157 + 58+  67+ 97  +92+ 142+ 4  + 8+ 173)=0.53
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 154 128
# 2 117 214
# 3  24 161
# (214 + 154)/( 154+ 128+ 117+ 214 +24+ 161)=0.46
table(data$Cluster_CosPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#   1   2   3
# 1 110 146  26
# 2 120 111 100
# 3 159  15  11
# (159+146+100)/( 110 +146 + 26 +120+ 111 +100 +159 + 15+  11)=0.51
##############

##############Cluster_SpecClustPrevSnapTime2Sup1
##############
table(data$Cluster_SpecClustPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapTime3Sup1)
#    1   2   3
# 1  35 143  64
# 2 340   0 216
# (340+143)/( 35 +143 + 64+ 340  + 0 +216)=0.61
table(data$Cluster_SpecClustPrevSnapTime2Sup1,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#   1   2
# 1 192  50
# 2 224 332
# (332+192)/(192 + 50+ 224+ 332)=0.66
table(data$Cluster_SpecClustPrevSnapTime2Sup1,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1  88 104  50
# 2 170  54 332
# (332+104)/(88 +104 + 50+  170 + 54+ 332)=0.55
table(data$Cluster_SpecClustPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1)
#    1   2
# 1 171  71
# 2 124 432
# (432+171)/(171 + 71+ 124+ 432)=0.76
table(data$Cluster_SpecClustPrevSnapTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1  48 164  30
# 2 341 108 107
# (341+164)/(48 +164+  30 +341+ 108+ 107)=0.63
##############

##############Cluster_SpecClustPrevSnapTime3Sup1
##############
table(data$Cluster_SpecClustPrevSnapTime3Sup1,data$Cluster_CosPrevSnapAdaptTime2Sup1)
#    1   2
# 1 110 265
# 2 116  27
# 3 190  90
# (265+190)/( 110 +265+ 116 +27+ 190+  90 )=0.57
table(data$Cluster_SpecClustPrevSnapTime3Sup1,data$Cluster_CosPrevSnapAdaptTime3Sup1)   
#    1   2   3
# 1 107   3 265
# 2  39  77  27
# 3 112  78  90
# (265+112+77)/( 107   +3 +265+ 39 + 77 + 27 +112 + 78 + 90 )=0.57
table(data$Cluster_SpecClustPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1)
#    1   2
# 1  17 358
# 2 109  34
# 3 169 111
# (358+169)/(17 +358+ 109+  34  +169 +111)=0.66
table(data$Cluster_SpecClustPrevSnapTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 261  11 103
# 2  23 104  16
# 3 105 157  18
# (261+157+16)/(261 + 11 +103+  23 +104 + 16+ 105+ 157 + 18)=0.54
##############


##############Cluster_CosPrevSnapAdaptTime2Sup1
##############
table(data$Cluster_CosPrevSnapAdaptTime2Sup1,data$Cluster_CosPrevSnapAdaptTime3Sup1)
#    1   2   3
# 1 258 158   0
# 2   0   0 382
# (382+258)/( 258 +158 +  0+  0 +  0+ 382)=0.80
table(data$Cluster_CosPrevSnapAdaptTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1 243 173
# 2  52 330
# (330+243)/(243 +173 + 52+ 330)=0.72
table(data$Cluster_CosPrevSnapAdaptTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1  88 233  95
# 2 301  39  42
# (301+233)/(88 +233 + 95+ 301+  39+  42)=0.67
##############

##############Cluster_CosPrevSnapAdaptTime3Sup1
##############
table(data$Cluster_CosPrevSnapAdaptTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime2Sup1 )
#    1   2
# 1  95 163
# 2 148  10
# 3  52 330
# (330+148)/(95 +163+ 148+  10 + 52+ 330)=0.60
table(data$Cluster_CosPrevSnapAdaptTime3Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#     1   2   3
# 1  72  92  94
# 2  16 141   1
# 3 301  39  42
# (301+141+94)/(72  +92+  94+ 16 +141 +  1+301  +39 + 42)=0.67
##############

##############Cluster_SpecClustPrevSnapAdaptTime2Sup1
##############
table(data$Cluster_SpecClustPrevSnapAdaptTime2Sup1,data$Cluster_SpecClustPrevSnapAdaptTime3Sup1 )
#    1   2   3
# 1  26 269   0
# 2 363   3 137
# (363+269)/(26+ 269 +  0+  363 +  3+ 137)=0.79
##############


