<chart>
id=128968169154443425
symbol=GBPJPY
description=Great Britain Pound vs Japanese Yen
period_type=1
period_size=1
digits=3
tick_size=0.000000
position_time=1700150400
scale_fix=0
scale_fixed_min=178.500000
scale_fixed_max=185.970000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=0
volume=0
scroll=1
shift=1
shift_size=17.663421
fixed_pos=0.000000
ticker=1
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=0
days=1
descriptions=0
tradelines=1
tradehistory=0
window_left=1812
window_top=588
window_right=2114
window_bottom=686
window_type=3
floating=0
floating_left=0
floating_top=0
floating_right=0
floating_bottom=0
floating_type=1
floating_toolbar=1
floating_tbstate=
background_color=16777215
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=32768
grid_color=12632256
bidline_color=12632256
askline_color=12632256
lastline_color=12632256
stops_color=17919
windows_total=2

<expert>
name=BB_Guardian_Test3
path=Experts\BB_Guardian_Test3.ex5
expertmode=33
<inputs>
BOT_NAME=BB_Guardian_x2_Amp_H1
EXPERT_MAGIC=20231201
dbRiskRatio=0.02
INIT_EQUITY=200.0
</inputs>
</expert>

<window>
height=126.436123
objects=92

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\TradeList.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=32
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
color=
</graph>
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\Examples\Heiken_Ashi.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=32
fixed_height=-1

<graph>
name=Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close
draw=17
style=0
width=1
color=10526303,6908265
</graph>

<period>
period_type=0
period_size=1
</period>
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
arrow=251
color=3937500
</graph>
period=10
method=0
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
arrow=251
color=16711680
</graph>

<period>
period_type=0
period_size=1
</period>

<period>
period_type=0
period_size=2
</period>

<period>
period_type=0
period_size=3
</period>

<period>
period_type=0
period_size=4
</period>

<period>
period_type=0
period_size=5
</period>

<period>
period_type=0
period_size=6
</period>

<period>
period_type=0
period_size=10
</period>

<period>
period_type=0
period_size=12
</period>

<period>
period_type=0
period_size=15
</period>

<period>
period_type=0
period_size=20
</period>

<period>
period_type=0
period_size=30
</period>

<period>
period_type=1
period_size=1
</period>

<period>
period_type=1
period_size=2
</period>

<period>
period_type=1
period_size=3
</period>

<period>
period_type=1
period_size=4
</period>

<period>
period_type=1
period_size=6
</period>

<period>
period_type=1
period_size=8
</period>

<period>
period_type=1
period_size=12
</period>
period=20
method=0
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\BB_Range.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=32
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
color=
</graph>
</indicator>
<object>
type=101
name=lbl_lbl_mi_h1_20_0
hidden=1
descr= (00) 182.898
selectable=0
angle=0
date1=1702425600
value1=182.898000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=mi_h1_20_0
hidden=1
style=1
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=182.898000
value2=182.898000
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_1
hidden=1
descr= (+1) 183.556
color=6908265
selectable=0
angle=0
date1=1702425600
value1=183.556000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_1
hidden=1
descr= (-1) 182.240
color=6908265
selectable=0
angle=0
date1=1702425600
value1=182.240000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lo_h1_20_1
hidden=1
color=6908265
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=182.240000
value2=182.240000
</object>

<object>
type=2
name=hi_h1_20_1
hidden=1
color=6908265
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=183.556000
value2=183.556000
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_2
hidden=1
descr= (+2) 184.214
color=16711680
selectable=0
angle=0
date1=1702425600
value1=184.214000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_2
hidden=1
descr= (-2) 181.582
color=16711680
selectable=0
angle=0
date1=1702425600
value1=181.582000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lo_h1_20_2
hidden=1
color=16711680
selectable=0
ray1=0
ray2=1
date1=1702339200
date2=1702425600
value1=181.582000
value2=181.582000
</object>

<object>
type=2
name=hi_h1_20_2
hidden=1
color=16711680
selectable=0
ray1=0
ray2=1
date1=1702339200
date2=1702425600
value1=184.214000
value2=184.214000
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_3
hidden=1
descr= (+3) 184.872
color=7451452
selectable=0
angle=0
date1=1702425600
value1=184.872000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_3
hidden=1
descr= (-3) 180.924
color=7451452
selectable=0
angle=0
date1=1702425600
value1=180.924000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lo_h1_20_3
hidden=1
color=7451452
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=180.924000
value2=180.924000
</object>

<object>
type=2
name=hi_h1_20_3
hidden=1
color=7451452
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=184.872000
value2=184.872000
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_4
hidden=1
descr= (+4) 185.530
color=0
selectable=0
angle=0
date1=1702425600
value1=185.530000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_4
hidden=1
descr= (-4) 180.266
color=0
selectable=0
angle=0
date1=1702425600
value1=180.266000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lo_h1_20_4
hidden=1
color=0
width=2
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=180.266000
value2=180.266000
</object>

<object>
type=2
name=hi_h1_20_4
hidden=1
color=0
width=2
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=185.530000
value2=185.530000
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_5
hidden=1
descr= (+5) 186.188
selectable=0
angle=0
date1=1702425600
value1=186.188000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_5
hidden=1
descr= (-5) 179.608
selectable=0
angle=0
date1=1702425600
value1=179.608000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lo_h1_20_5
hidden=1
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=179.608000
value2=179.608000
</object>

<object>
type=2
name=hi_h1_20_5
hidden=1
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=186.188000
value2=186.188000
</object>

<object>
type=20
name=1201_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701388800
date2=1701392400
value1=35920.700000
value2=36297.900000
</object>

<object>
type=20
name=1130_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701302400
date2=1701306000
value1=35530.900000
value2=35994.400000
</object>

<object>
type=20
name=1129_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701216000
date2=1701219600
value1=35435.700000
value2=35616.400000
</object>

<object>
type=20
name=1128_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701129600
date2=1701133200
value1=35326.000000
value2=35554.600000
</object>

<object>
type=20
name=1127_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701043200
date2=1701046800
value1=35315.900000
value2=35451.800000
</object>

<object>
type=20
name=1126_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700956800
date2=1700960400
value1=35390.900000
value2=35420.300000
</object>

<object>
type=2
name=w_dn_0
hidden=1
color=0
width=2
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=188.115000
value2=188.115000
</object>

<object>
type=2
name=w_up_0
hidden=1
color=0
width=2
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=188.115000
value2=188.115000
</object>

<object>
type=2
name=w_dn_1
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=186.500000
value2=186.500000
</object>

<object>
type=2
name=w_up_1
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=189.730000
value2=189.730000
</object>

<object>
type=2
name=w_dn_2
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=184.885000
value2=184.885000
</object>

<object>
type=2
name=w_up_2
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=191.345000
value2=191.345000
</object>

<object>
type=2
name=w_dn_3
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=183.270000
value2=183.270000
</object>

<object>
type=2
name=w_up_3
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=192.960000
value2=192.960000
</object>

<object>
type=2
name=w_dn_4
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=181.655000
value2=181.655000
</object>

<object>
type=2
name=w_up_4
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=194.575000
value2=194.575000
</object>

<object>
type=2
name=w_dn_5
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=180.040000
value2=180.040000
</object>

<object>
type=2
name=w_up_5
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=196.190000
value2=196.190000
</object>

<object>
type=2
name=w_dn_6
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=178.425000
value2=178.425000
</object>

<object>
type=2
name=w_up_6
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=197.805000
value2=197.805000
</object>

<object>
type=2
name=w_dn_7
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=176.810000
value2=176.810000
</object>

<object>
type=2
name=w_up_7
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=199.420000
value2=199.420000
</object>

<object>
type=2
name=w_dn_8
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=175.195000
value2=175.195000
</object>

<object>
type=2
name=w_up_8
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=201.035000
value2=201.035000
</object>

<object>
type=2
name=w_dn_9
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=173.580000
value2=173.580000
</object>

<object>
type=2
name=w_up_9
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=202.650000
value2=202.650000
</object>

<object>
type=2
name=w_dn_10
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=171.965000
value2=171.965000
</object>

<object>
type=2
name=w_up_10
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=204.265000
value2=204.265000
</object>

<object>
type=2
name=w_dn_11
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=170.350000
value2=170.350000
</object>

<object>
type=2
name=w_up_11
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=205.880000
value2=205.880000
</object>

<object>
type=2
name=w_dn_12
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=168.735000
value2=168.735000
</object>

<object>
type=2
name=w_up_12
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=207.495000
value2=207.495000
</object>

<object>
type=2
name=w_dn_13
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=167.120000
value2=167.120000
</object>

<object>
type=2
name=w_up_13
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=209.110000
value2=209.110000
</object>

<object>
type=2
name=w_dn_14
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=165.505000
value2=165.505000
</object>

<object>
type=2
name=w_up_14
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=210.725000
value2=210.725000
</object>

<object>
type=2
name=w_dn_15
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=163.890000
value2=163.890000
</object>

<object>
type=2
name=w_up_15
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=212.340000
value2=212.340000
</object>

<object>
type=2
name=w_dn_16
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=162.275000
value2=162.275000
</object>

<object>
type=2
name=w_up_16
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=213.955000
value2=213.955000
</object>

<object>
type=2
name=w_dn_17
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=160.660000
value2=160.660000
</object>

<object>
type=2
name=w_up_17
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=215.570000
value2=215.570000
</object>

<object>
type=2
name=w_dn_18
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=159.045000
value2=159.045000
</object>

<object>
type=2
name=w_up_18
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=217.185000
value2=217.185000
</object>

<object>
type=2
name=w_dn_19
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=157.430000
value2=157.430000
</object>

<object>
type=2
name=w_up_19
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=218.800000
value2=218.800000
</object>

<object>
type=2
name=w_dn_20
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=155.815000
value2=155.815000
</object>

<object>
type=2
name=w_up_20
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=220.415000
value2=220.415000
</object>

<object>
type=2
name=w_dn_21
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=154.200000
value2=154.200000
</object>

<object>
type=2
name=w_up_21
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=222.030000
value2=222.030000
</object>

<object>
type=2
name=w_dn_22
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=152.585000
value2=152.585000
</object>

<object>
type=2
name=w_up_22
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=223.645000
value2=223.645000
</object>

<object>
type=2
name=w_dn_23
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=150.970000
value2=150.970000
</object>

<object>
type=2
name=w_up_23
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=225.260000
value2=225.260000
</object>

<object>
type=2
name=w_dn_24
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=149.355000
value2=149.355000
</object>

<object>
type=2
name=w_up_24
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1701561600
date2=1702399618
value1=226.875000
value2=226.875000
</object>

<object>
type=20
name=1205_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701734400
date2=1701738000
value1=36053.000000
value2=36234.000000
</object>

<object>
type=20
name=1204_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701648000
date2=1701651600
value1=36074.500000
value2=36289.400000
</object>

<object>
type=20
name=1203_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701561600
date2=1701565200
value1=36262.400000
value2=36308.200000
</object>

<object>
type=20
name=1211_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1702252800
date2=1702256400
value1=181.925000
value2=184.325000
</object>

<object>
type=20
name=1210_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1702166400
date2=1702170000
value1=181.622000
value2=182.015000
</object>

<object>
type=20
name=1208_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701993600
date2=1701997200
value1=179.548000
value2=182.032000
</object>

<object>
type=20
name=1207_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701907200
date2=1701910800
value1=178.583000
value2=184.827000
</object>

<object>
type=20
name=1206_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1701820800
date2=1701824400
value1=184.648000
value2=185.805000
</object>

<object>
type=101
name=lbl_Hi_H4(20, 2)
hidden=1
descr=                                H4(+2)
selectable=0
angle=0
date1=1702425600
value1=184.296000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_Lo_H4(20, 2)
hidden=1
descr=                                H4(-2)
selectable=0
angle=0
date1=1702425600
value1=180.435000
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=hi_h4_20_2
hidden=1
width=2
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=184.296000
value2=184.296000
</object>

<object>
type=2
name=lo_h4_20_2
hidden=1
width=2
selectable=0
ray1=0
ray2=0
date1=1702339200
date2=1702425600
value1=180.435000
value2=180.435000
</object>

<object>
type=20
name=1212_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1702339200
date2=1702342800
value1=182.270000
value2=183.443000
</object>

<object>
type=20
name=0101_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1702399287
date2=3600
value1=0.859400
value2=0.856400
</object>

</window>

<window>
height=50.000000
objects=0

<indicator>
name=MACD
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=-0.538768
scale_fix_max=0
scale_fix_max_val=0.386728
expertmode=0
fixed_height=-1

<graph>
name=
draw=2
style=0
width=5
arrow=251
color=-1
</graph>

<graph>
name=
draw=1
style=0
width=3
arrow=251
color=255
</graph>

<level>
level=0.000000
style=0
color=0
width=2
descr=
</level>
fast_ema=3
slow_ema=6
macd_sma=9
</indicator>
</window>
</chart>