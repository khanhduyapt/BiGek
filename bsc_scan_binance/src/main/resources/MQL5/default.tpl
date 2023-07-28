<chart>
id=133224990389068628
symbol=FRA40.cash
description=France 40 Index
period_type=1
period_size=4
digits=2
tick_size=0.000000
position_time=1666483200
scale_fix=0
scale_fixed_min=6994.400000
scale_fixed_max=7498.600000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=1
volume=1
scroll=1
shift=1
shift_size=16.140229
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
tradehistory=1
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
barup_color=4294967295
bardown_color=4294967295
bullcandle_color=4294967295
bearcandle_color=4294967295
chartline_color=4294967295
volumes_color=32768
grid_color=14474460
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
objects=15

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
apply=7
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
period=50
method=3
</indicator>

<indicator>
name=Moving Average
path=
apply=7
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
color=255
</graph>
period=8
method=3
</indicator>

<indicator>
name=Moving Average
path=
apply=7
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
color=0
</graph>
period=1
method=3
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
style=0
width=1
arrow=251
color=6908265
</graph>
<inputs>
InpDepth=12
InpDeviation=5
InpBackstep=3
</inputs>
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\Market\Trading Sessions Indicator Free.ex5
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
name=Asian session High; Asian session Low
draw=7
style=0
width=1
arrow=251
shift=96
color=15794175
</graph>

<graph>
name=European session High; European session Low
draw=7
style=0
width=1
arrow=251
shift=96
color=16775408
</graph>

<graph>
name=American session High; American session Low
draw=7
style=0
width=1
arrow=251
shift=96
color=16118015
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
<inputs>
=
TimeCorrection=0
</inputs>
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
<object>
type=32
name=autotrade #73463887 sell 0.5 FRA40.cash at 7294.90, FRA40.cash
hidden=1
color=1918177
selectable=0
date1=1689686426
value1=7294.900000
</object>

<object>
type=32
name=autotrade #73938066 sell 1.5 FRA40.cash at 7399.40, FRA40.cash
hidden=1
color=1918177
selectable=0
date1=1689936472
value1=7399.400000
</object>

<object>
type=31
name=autotrade #73938127 buy 0.5 FRA40.cash at 7400.20, profit -58.6
hidden=1
color=11296515
selectable=0
date1=1689936504
value1=7400.200000
</object>

<object>
type=31
name=autotrade #74030220 buy 1.5 FRA40.cash at 7434.70, profit -58.8
hidden=1
color=11296515
selectable=0
date1=1689966288
value1=7434.700000
</object>

<object>
type=32
name=autotrade #74403762 sell 1.45 FRA40.cash at 7370.55, FRA40.cash
hidden=1
color=1918177
selectable=0
date1=1690360466
value1=7370.550000
</object>

<object>
type=31
name=autotrade #74420685 buy 1.45 FRA40.cash at 7337.00, profit 53.8
hidden=1
color=11296515
selectable=0
date1=1690367453
value1=7337.000000
</object>

<object>
type=32
name=autotrade #74442565 sell 1 FRA40.cash at 7289.50, FRA40.cash
hidden=1
color=1918177
selectable=0
date1=1690376932
value1=7289.500000
</object>

<object>
type=31
name=autotrade #74635808 buy 1 FRA40.cash at 7448.00, profit -176.36
hidden=1
color=11296515
selectable=0
date1=1690470935
value1=7448.000000
</object>

<object>
type=32
name=autotrade #74768697 sell 2.3 FRA40.cash at 7425.75, FRA40.cash
hidden=1
color=1918177
selectable=0
date1=1690527245
value1=7425.750000
</object>

<object>
type=31
name=autotrade #74776081 buy 2.3 FRA40.cash at 7448.85, profit -58.3
hidden=1
color=11296515
selectable=0
date1=1690531428
value1=7448.850000
</object>

<object>
type=2
name=autotrade #73463887 -> #73938127, profit -58.60, FRA40.cash
hidden=1
descr=7294.90 -> 7400.20
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1689686426
date2=1689936504
value1=7294.900000
value2=7400.200000
</object>

<object>
type=2
name=autotrade #73938066 -> #74030220, profit -58.88, FRA40.cash
hidden=1
descr=7399.40 -> 7434.70
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1689936472
date2=1689966288
value1=7399.400000
value2=7434.700000
</object>

<object>
type=2
name=autotrade #74403762 -> #74420685, profit 53.82, FRA40.cash
hidden=1
descr=7370.55 -> 7337.00
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1690360466
date2=1690367453
value1=7370.550000
value2=7337.000000
</object>

<object>
type=2
name=autotrade #74442565 -> #74635808, profit -176.36, FRA40.cash
hidden=1
descr=7289.50 -> 7448.00
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1690376932
date2=1690470935
value1=7289.500000
value2=7448.000000
</object>

<object>
type=2
name=autotrade #74768697 -> #74776081, profit -58.30, FRA40.cash
hidden=1
descr=7425.75 -> 7448.85
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1690527245
date2=1690531428
value1=7425.750000
value2=7448.850000
</object>

</window>
</chart>