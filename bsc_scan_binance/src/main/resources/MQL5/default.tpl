<chart>
id=133224990389069668
symbol=AUDUSD
description=Australian Dollar vs US Dollar
period_type=1
period_size=4
digits=5
tick_size=0.000000
position_time=1696904100
scale_fix=0
scale_fixed_min=0.625700
scale_fixed_max=0.651700
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=0
volume=1
scroll=1
shift=1
shift_size=16.649642
fixed_pos=0.000000
ticker=1
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=0
days=0
descriptions=0
tradelines=1
tradehistory=0
window_left=831
window_top=313
window_right=1662
window_bottom=626
window_type=1
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
barup_color=25600
bardown_color=128
bullcandle_color=16777215
bearcandle_color=6908265
chartline_color=0
volumes_color=32768
grid_color=12632256
bidline_color=12632256
askline_color=12632256
lastline_color=12632256
stops_color=17919
windows_total=1

<expert>
name=GuardianAngel
path=Experts\GuardianAngel.ex5
expertmode=33
<inputs>
aa=------------------SETTINGS----------------------
BOT_NAME=GuardianAngel
EXPERT_MAGIC=2023869
PASS_CRITERIA=220000.0
</inputs>
</expert>

<window>
height=100.000000
objects=96

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
path=Indicators\Examples\ZigZag.ex5
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
expertmode=0
fixed_height=-1

<graph>
name=ZigZag(12,5,3)
draw=4
style=2
width=1
arrow=251
color=11119017
</graph>
<inputs>
InpDepth=12
InpDeviation=5
InpBackstep=3
</inputs>
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
expertmode=0
fixed_height=-1

<graph>
name=Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close
draw=17
style=0
width=1
arrow=251
color=10526303,8421504
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
show_data=0
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
width=3
color=13882323
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
period=50
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
period=20
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
color=2237106
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
color=0
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
period=6
method=0
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\StockMarket.ex5
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
expertmode=0
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
arrow=251
color=
</graph>
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\TimeBreaker.ex5
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
arrow=251
color=
</graph>
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
arrow=251
color=
</graph>
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\AureliusIronheart.ex5
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
expertmode=0
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
arrow=251
color=
</graph>
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\DailyRange.ex5
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
expertmode=0
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
arrow=251
color=
</graph>
</indicator>

<indicator>
name=Bollinger Bands
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
draw=131
style=0
width=1
color=7451452
</graph>

<graph>
name=
draw=131
style=0
width=1
color=7451452
</graph>

<graph>
name=
draw=131
style=0
width=1
color=7451452
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

<period>
period_type=1
period_size=24
</period>
period=20
deviation=2.000000
</indicator>
<object>
name=close_time_today
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696982400
</object>

<object>
name=d0_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696896000
</object>

<object>
name=d1_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696809600
</object>

<object>
name=d2_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696550400
</object>

<object>
name=d3_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696464000
</object>

<object>
name=d4_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696377600
</object>

<object>
name=d5_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696291200
</object>

<object>
name=d6_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1696204800
</object>

<object>
name=d7_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695945600
</object>

<object>
name=d8_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695859200
</object>

<object>
name=d9_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695772800
</object>

<object>
name=d10_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695686400
</object>

<object>
name=d11_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695600000
</object>

<object>
name=d12_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695340800
</object>

<object>
name=d13_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695254400
</object>

<object>
name=d14_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695168000
</object>

<object>
name=d15_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1695081600
</object>

<object>
name=d16_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694995200
</object>

<object>
name=d17_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694736000
</object>

<object>
name=d18_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694649600
</object>

<object>
name=d19_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694563200
</object>

<object>
name=d20_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694476800
</object>

<object>
name=d21_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694390400
</object>

<object>
name=d22_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694131200
</object>

<object>
name=d23_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1694044800
</object>

<object>
name=d24_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693958400
</object>

<object>
name=d25_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693872000
</object>

<object>
name=d26_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693785600
</object>

<object>
name=d27_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693526400
</object>

<object>
name=d28_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693440000
</object>

<object>
name=d29_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1693353600
</object>

<object>
type=2
name=uptrend_h4
hidden=1
color=16711680
selectable=0
ray1=0
ray2=0
date1=1696953600
date2=1696962857
value1=0.645245
value2=0.645245
</object>

<object>
type=2
name=dntrend_h4
hidden=1
color=2237106
selectable=0
ray1=0
ray2=0
date1=1696953600
date2=1696962857
value1=0.639605
value2=0.639605
</object>

<object>
type=101
name=lbl_lbl_upper_h1
hidden=1
descr=h1
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.642690
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=upper_h1
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.642690
value2=0.642690
</object>

<object>
type=101
name=lbl_lbl_lower_h1
hidden=1
descr=h1
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.639430
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lower_h1
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.639430
value2=0.639430
</object>

<object>
type=101
name=lbl_lbl_upper_h4
hidden=1
descr=h4
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.643190
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=upper_h4
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.643190
value2=0.643190
</object>

<object>
type=101
name=lbl_lbl_lower_h4
hidden=1
descr=h4
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.632530
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lower_h4
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.632530
value2=0.632530
</object>

<object>
type=101
name=lbl_lbl_upper_d1
hidden=1
descr=d1
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.648760
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=upper_d1
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.648760
value2=0.648760
</object>

<object>
type=101
name=lbl_lbl_lower_d1
hidden=1
descr=d1
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.632250
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=lower_d1
hidden=1
color=8421376
selectable=0
ray1=0
ray2=0
date1=1696896000
date2=1696982400
value1=0.632250
value2=0.632250
</object>

<object>
type=101
name=lbl_lbl_BB_mid
hidden=1
descr=---67.1%
color=8421376
selectable=0
angle=0
date1=1696982400
value1=0.637870
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=w_close
hidden=1
color=0
width=2
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.638330
value2=0.638330
</object>

<object>
type=2
name=w_s1
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.630419
value2=0.630419
</object>

<object>
type=2
name=w_r1
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.646240
value2=0.646240
</object>

<object>
type=2
name=w_s2
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.622509
value2=0.622509
</object>

<object>
type=2
name=w_r2
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.654151
value2=0.654151
</object>

<object>
type=2
name=w_s3
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.614598
value2=0.614598
</object>

<object>
type=2
name=w_r3
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.662061
value2=0.662061
</object>

<object>
type=2
name=w_s4
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.606688
value2=0.606688
</object>

<object>
type=2
name=w_r4
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.669972
value2=0.669972
</object>

<object>
type=2
name=w_s5
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.598777
value2=0.598777
</object>

<object>
type=2
name=w_r5
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.677882
value2=0.677882
</object>

<object>
type=2
name=w_s6
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.590867
value2=0.590867
</object>

<object>
type=2
name=w_r6
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.685793
value2=0.685793
</object>

<object>
type=2
name=w_s7
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.582956
value2=0.582956
</object>

<object>
type=2
name=w_r7
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.693703
value2=0.693703
</object>

<object>
type=2
name=w_s8
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.575046
value2=0.575046
</object>

<object>
type=2
name=w_r8
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.701614
value2=0.701614
</object>

<object>
type=2
name=w_s9
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.567136
value2=0.567136
</object>

<object>
type=2
name=w_r9
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.709524
value2=0.709524
</object>

<object>
type=2
name=w_s10
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.559225
value2=0.559225
</object>

<object>
type=2
name=w_r10
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.717435
value2=0.717435
</object>

<object>
type=2
name=w_s11
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.551314
value2=0.551314
</object>

<object>
type=2
name=w_r11
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.725345
value2=0.725345
</object>

<object>
type=2
name=w_s12
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.543404
value2=0.543404
</object>

<object>
type=2
name=w_r12
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.733256
value2=0.733256
</object>

<object>
type=2
name=w_s13
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.535493
value2=0.535493
</object>

<object>
type=2
name=w_r13
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.741166
value2=0.741166
</object>

<object>
type=2
name=w_s14
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.527583
value2=0.527583
</object>

<object>
type=2
name=w_r14
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.749077
value2=0.749077
</object>

<object>
type=2
name=w_s15
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.519672
value2=0.519672
</object>

<object>
type=2
name=w_r15
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.756987
value2=0.756987
</object>

<object>
type=2
name=w_s16
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.511762
value2=0.511762
</object>

<object>
type=2
name=w_r16
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.764898
value2=0.764898
</object>

<object>
type=2
name=w_s17
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.503852
value2=0.503852
</object>

<object>
type=2
name=w_r17
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.772808
value2=0.772808
</object>

<object>
type=2
name=w_s18
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.495941
value2=0.495941
</object>

<object>
type=2
name=w_r18
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.780719
value2=0.780719
</object>

<object>
type=2
name=w_s19
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.488030
value2=0.488030
</object>

<object>
type=2
name=w_r19
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.788629
value2=0.788629
</object>

<object>
type=2
name=w_s20
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.480120
value2=0.480120
</object>

<object>
type=2
name=w_r20
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.796540
value2=0.796540
</object>

<object>
type=2
name=w_s21
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.472209
value2=0.472209
</object>

<object>
type=2
name=w_r21
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.804450
value2=0.804450
</object>

<object>
type=2
name=w_s22
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.464299
value2=0.464299
</object>

<object>
type=2
name=w_r22
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.812361
value2=0.812361
</object>

<object>
type=2
name=w_s23
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.456388
value2=0.456388
</object>

<object>
type=2
name=w_r23
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.820271
value2=0.820271
</object>

<object>
type=2
name=w_s24
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.448478
value2=0.448478
</object>

<object>
type=2
name=w_r24
hidden=1
color=0
selectable=0
ray1=1
ray2=1
date1=1696118400
date2=1696962857
value1=0.828182
value2=0.828182
</object>

<object>
type=2
name=w_mid_0
hidden=1
color=25600
width=2
selectable=0
ray1=0
ray2=0
date1=1696118400
date2=1696982400
value1=0.636510
value2=0.638770
</object>

</window>
</chart>