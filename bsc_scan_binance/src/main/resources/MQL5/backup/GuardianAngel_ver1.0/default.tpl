<chart>
id=133224990389069866
symbol=AUDCHF
description=Australian Dollar vs Swiss Franc
period_type=0
period_size=5
digits=5
tick_size=0.000000
position_time=1700746200
scale_fix=0
scale_fixed_min=0.579600
scale_fixed_max=0.582100
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=0
fore=0
grid=0
volume=2
scroll=1
shift=1
shift_size=15.587530
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
barup_color=4294967295
bardown_color=4294967295
bullcandle_color=4294967295
bearcandle_color=4294967295
chartline_color=0
volumes_color=32768
grid_color=14474460
bidline_color=12632256
askline_color=12632256
lastline_color=12632256
stops_color=17919
windows_total=2

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
height=142.888279
objects=53

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
width=3
arrow=251
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
color=3937500
</graph>
period=9
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
<object>
name=close_time_today
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1701129600
</object>

<object>
name=d0_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1701043200
</object>

<object>
name=d1_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700784000
</object>

<object>
name=d2_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700697600
</object>

<object>
name=d3_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700611200
</object>

<object>
name=d4_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700524800
</object>

<object>
name=d5_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700438400
</object>

<object>
name=d6_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700179200
</object>

<object>
name=d7_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700092800
</object>

<object>
name=d8_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1700006400
</object>

<object>
name=d9_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699920000
</object>

<object>
name=d10_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699833600
</object>

<object>
name=d11_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699574400
</object>

<object>
name=d12_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699488000
</object>

<object>
name=d13_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699401600
</object>

<object>
name=d14_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699315200
</object>

<object>
name=d15_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1699228800
</object>

<object>
name=d16_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698969600
</object>

<object>
name=d17_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698883200
</object>

<object>
name=d18_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698796800
</object>

<object>
name=d19_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698710400
</object>

<object>
name=d20_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698624000
</object>

<object>
name=d21_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698364800
</object>

<object>
name=d22_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698278400
</object>

<object>
name=d23_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698192000
</object>

<object>
name=d24_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698105600
</object>

<object>
name=d25_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1698019200
</object>

<object>
name=d26_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1697760000
</object>

<object>
name=d27_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1697673600
</object>

<object>
name=d28_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1697587200
</object>

<object>
name=d29_c_time
hidden=1
color=0
style=2
selectable=0
ray=0
date1=1697500800
</object>

<object>
type=2
name=stop_loss_buy
hidden=1
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1700956800
value1=0.578410
value2=0.578410
</object>

<object>
type=2
name=stop_loss_sell
hidden=1
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1700956800
value1=0.581990
value2=0.581990
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_2
hidden=1
descr= hi H1 (20, 2) 0.58158
color=16711680
selectable=0
angle=0
date1=1701129600
value1=0.581580
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=hi_h1_20_2
hidden=1
color=16711680
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1701129600
value1=0.581580
value2=0.581580
</object>

<object>
type=101
name=lbl_lbl_mi_h1_20_0
hidden=1
descr= mi H1 (20, 0) 0.58060
selectable=0
angle=0
date1=1701129600
value1=0.580600
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
date1=1700870400
date2=1701129600
value1=0.580600
value2=0.580600
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_2
hidden=1
descr= lo H1 (20, 2) 0.57963
color=16711680
selectable=0
angle=0
date1=1701129600
value1=0.579630
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
ray2=0
date1=1700870400
date2=1701129600
value1=0.579630
value2=0.579630
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_1
hidden=1
descr= hi H1 (20, 1) 0.58109
color=0
selectable=0
angle=0
date1=1701129600
value1=0.581090
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_1
hidden=1
descr= lo H1 (20, 1) 0.58012
color=0
selectable=0
angle=0
date1=1701129600
value1=0.580120
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=hi_h1_20_1
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1701129600
value1=0.581090
value2=0.581090
</object>

<object>
type=2
name=lo_h1_20_1
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1701129600
value1=0.580120
value2=0.580120
</object>

<object>
type=101
name=lbl_lbl_hi_h1_20_3
hidden=1
descr= hi H1 (20, 3) 0.58207
color=0
selectable=0
angle=0
date1=1701129600
value1=0.582070
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=101
name=lbl_lbl_lo_h1_20_3
hidden=1
descr= lo H1 (20, 3) 0.57914
color=0
selectable=0
angle=0
date1=1701129600
value1=0.579140
fontsz=8
fontnm=Arial
anchorpos=1
</object>

<object>
type=2
name=hi_h1_20_3
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1701129600
value1=0.582070
value2=0.582070
</object>

<object>
type=2
name=lo_h1_20_3
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1700870400
date2=1701129600
value1=0.579140
value2=0.579140
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
value1=0.579410
value2=0.581990
</object>

<object>
type=20
name=1124_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700784000
date2=1700787600
value1=0.578410
value2=0.581440
</object>

<object>
type=20
name=1123_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700697600
date2=1700701200
value1=0.577810
value2=0.580490
</object>

<object>
type=20
name=1122_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700611200
date2=1700614800
value1=0.577310
value2=0.580580
</object>

<object>
type=20
name=1121_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700524800
date2=1700528400
value1=0.578740
value2=0.581810
</object>

<object>
type=20
name=1120_sleep_time
hidden=1
color=14474460
style=2
background=1
selectable=0
filling=1
date1=1700438400
date2=1700442000
value1=0.575580
value2=0.580660
</object>

</window>

<window>
height=49.163603
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
scale_fix_min_val=-0.000218
scale_fix_max=0
scale_fix_max_val=0.000233
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
width=2
arrow=251
color=2237106
</graph>

<level>
level=0.000000
style=0
color=0
width=1
descr=
</level>
fast_ema=3
slow_ema=6
macd_sma=9
</indicator>
</window>
</chart>