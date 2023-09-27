<chart>
id=133224990389069469
symbol=EURNZD
description=Euro vs New Zealand Dollar
period_type=1
period_size=1
digits=5
tick_size=0.000000
position_time=1695067200
scale_fix=0
scale_fixed_min=1.767800
scale_fixed_max=1.808600
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=0
fore=0
grid=1
volume=1
scroll=1
shift=1
shift_size=15.560095
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
objects=17

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
color=3937500
</graph>
period=10
method=0
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
color=8388608
</graph>
period=2
method=2
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
<inputs>
TimeFrame=16408
</inputs>
</indicator>
<object>
type=2
name=mid
hidden=1
color=16711680
width=2
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.776740
value2=1.776740
</object>

<object>
type=2
name=S1
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.772370
value2=1.772370
</object>

<object>
type=2
name=S2
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.768010
value2=1.768010
</object>

<object>
type=2
name=S3
hidden=1
color=0
width=2
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.763640
value2=1.763640
</object>

<object>
type=2
name=R1
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.781100
value2=1.781100
</object>

<object>
type=2
name=R2
hidden=1
color=0
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.785460
value2=1.785460
</object>

<object>
type=2
name=R3
hidden=1
color=0
width=2
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.789830
value2=1.789830
</object>

<object>
type=2
name=Close
color=16711680
selectable=0
ray1=0
ray2=0
date1=1695686400
date2=1695799804
value1=1.778240
value2=1.778240
</object>

<object>
type=101
name=Label_mid
descr=                1.77674
color=16711680
selectable=0
angle=0
date1=1695799804
value1=1.776740
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=ds1
descr=                1.77237
color=0
selectable=0
angle=0
date1=1695799804
value1=1.772370
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=ds2
descr=                1.7680099999999999
color=0
selectable=0
angle=0
date1=1695799804
value1=1.768010
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=ds3
descr=                1.76364
color=0
selectable=0
angle=0
date1=1695799804
value1=1.763640
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=dr1
descr=                1.7811
color=0
selectable=0
angle=0
date1=1695799804
value1=1.781100
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=dr2
descr=                1.78546
color=0
selectable=0
angle=0
date1=1695799804
value1=1.785460
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=101
name=dr3
descr=                1.78983
color=0
selectable=0
angle=0
date1=1695799804
value1=1.789830
fontsz=10
fontnm=Arial
anchorpos=8
</object>

<object>
type=2
name=Week_Trend
hidden=1
selectable=0
ray1=0
ray2=0
date1=1694908800
date2=1695799804
value1=1.794720
value2=1.782550
</object>

<object>
type=101
name=Label_Week_Trend
descr=                1.78255
selectable=0
angle=0
date1=1695799804
value1=1.782550
fontsz=10
fontnm=Arial
anchorpos=8
</object>

</window>
</chart>