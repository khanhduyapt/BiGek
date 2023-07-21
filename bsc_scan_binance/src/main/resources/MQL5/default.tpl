<chart>
id=133224990389068527
symbol=CHFJPY
description=Swiss Franc vs Japanese Yen
period_type=1
period_size=24
digits=3
tick_size=0.000000
position_time=1682697600
scale_fix=0
scale_fixed_min=134.130000
scale_fixed_max=163.750000
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
shift_size=16.695592
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
objects=26

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
arrow=251
color=255
</graph>
period=5
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
width=3
arrow=251
color=0
</graph>
period=3
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
shift=24
color=15794175
</graph>

<graph>
name=European session High; European session Low
draw=7
style=0
width=1
arrow=251
shift=24
color=16775408
</graph>

<graph>
name=American session High; American session Low
draw=7
style=0
width=1
arrow=251
shift=24
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
<object>
type=32
name=autotrade #78003955 sell 0.5 CADJPY at 102.093, CADJPY
hidden=1
color=1918177
selectable=0
date1=1684748371
value1=102.093000
</object>

<object>
type=31
name=autotrade #78346381 buy 0.5 CADJPY at 102.761, profit -240.69, 
hidden=1
color=11296515
selectable=0
date1=1684857984
value1=102.761000
</object>

<object>
type=31
name=autotrade #78414607 buy 0.12 CADJPY at 102.662, CADJPY
hidden=1
color=11296515
selectable=0
date1=1684865051
value1=102.662000
</object>

<object>
type=32
name=autotrade #78504035 sell 0.12 CADJPY at 102.481, profit -15.69,
hidden=1
color=1918177
selectable=0
date1=1684906048
value1=102.481000
</object>

<object>
type=2
name=autotrade #78003955 -> #78346381, profit -240.69, CADJPY
hidden=1
descr=102.093 -> 102.761
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1684748371
date2=1684857984
value1=102.093000
value2=102.761000
</object>

<object>
type=2
name=autotrade #78414607 -> #78504035, profit -15.69, CADJPY
hidden=1
descr=102.662 -> 102.481
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1684865051
date2=1684906048
value1=102.662000
value2=102.481000
</object>

<object>
type=32
name=autotrade #77488743 sell 0.42 US30.cash at 33354.40, US30.cash
hidden=1
color=1918177
selectable=0
date1=1684393777
value1=33354.400000
</object>

<object>
type=31
name=autotrade #77534162 buy 0.42 US30.cash at 33425.50, profit -29.
hidden=1
color=11296515
selectable=0
date1=1684409822
value1=33425.500000
</object>

<object>
type=31
name=autotrade #77727938 buy 0.15 US30.cash at 33574.60, US30.cash
hidden=1
color=11296515
selectable=0
date1=1684474241
value1=33574.600000
</object>

<object>
type=31
name=autotrade #77728672 buy 0.5 US30.cash at 33573.50, US30.cash
hidden=1
color=11296515
selectable=0
date1=1684474810
value1=33573.500000
</object>

<object>
type=32
name=autotrade #77916314 sell 0.15 US30.cash at 33331.90, profit -36
hidden=1
color=1918177
selectable=0
date1=1684524686
value1=33331.900000
</object>

<object>
type=32
name=autotrade #77916317 sell 0.5 US30.cash at 33331.40, profit -121
hidden=1
color=1918177
selectable=0
date1=1684524687
value1=33331.400000
</object>

<object>
type=32
name=autotrade #77925085 sell 1 US30.cash at 33450.30, US30.cash
hidden=1
color=1918177
selectable=0
date1=1684528239
value1=33450.300000
</object>

<object>
type=31
name=autotrade #78439222 buy 1 US30.cash at 33251.70, profit 198.60,
hidden=1
color=11296515
selectable=0
date1=1684870685
value1=33251.700000
</object>

<object>
type=2
name=autotrade #77488743 -> #77534162, profit -29.86, US30.cash
hidden=1
descr=33354.40 -> 33425.50
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1684393777
date2=1684409822
value1=33354.400000
value2=33425.500000
</object>

<object>
type=2
name=autotrade #77727938 -> #77916314, profit -36.41, US30.cash
hidden=1
descr=33574.60 -> 33331.90
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1684474241
date2=1684524686
value1=33574.600000
value2=33331.900000
</object>

<object>
type=2
name=autotrade #77728672 -> #77916317, profit -121.05, US30.cash
hidden=1
descr=33573.50 -> 33331.40
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1684474810
date2=1684524687
value1=33573.500000
value2=33331.400000
</object>

<object>
type=2
name=autotrade #77925085 -> #78439222, profit 198.60, US30.cash
hidden=1
descr=33450.30 -> 33251.70
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1684528239
date2=1684870685
value1=33450.300000
value2=33251.700000
</object>

<object>
type=32
name=autotrade #86331815 sell 0.23 GBPNZD at 2.07630, GBPNZD
hidden=1
descr=PC.mngy.2415...
color=1918177
selectable=0
date1=1688123046
value1=2.076300
</object>

<object>
type=31
name=autotrade #86347905 buy 0.23 GBPNZD at 2.07441, profit 26.44, G
hidden=1
color=11296515
selectable=0
date1=1688127245
value1=2.074410
</object>

<object>
type=32
name=autotrade #86348609 sell 0.66 GBPNZD at 2.07509, GBPNZD
hidden=1
descr=PC.mngy.2415...
color=1918177
selectable=0
date1=1688127539
value1=2.075090
</object>

<object>
type=2
name=autotrade #86331815 -> #86347905, profit 26.44, GBPNZD
hidden=1
descr=2.07630 -> 2.07441
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1688123046
date2=1688127245
value1=2.076300
value2=2.074410
</object>

<object>
type=32
name=autotrade #73464189 sell 0.05 CHFJPY at 160.965, CHFJPY
hidden=1
color=1918177
selectable=0
date1=1689686708
value1=160.965000
</object>

<object>
type=32
name=autotrade #73629199 sell 0.15 CHFJPY at 162.986, CHFJPY
hidden=1
color=1918177
selectable=0
date1=1689769526
value1=162.986000
</object>

<object>
type=31
name=autotrade #73852797 buy 0.15 CHFJPY at 161.964, profit 109.40, 
hidden=1
color=11296515
selectable=0
date1=1689873704
value1=161.964000
</object>

<object>
type=2
name=autotrade #73629199 -> #73852797, profit 109.40, CHFJPY
hidden=1
descr=162.986 -> 161.964
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1689769526
date2=1689873704
value1=162.986000
value2=161.964000
</object>

</window>
</chart>