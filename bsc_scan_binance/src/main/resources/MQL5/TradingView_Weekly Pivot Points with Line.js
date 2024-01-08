//@version=5
indicator("Weekly Pivot Points with Line", overlay=true)

ma9 = ta.sma(close, 9)
ma18 = ta.sma(close, 18)
ma50 = ta.sma(close, 50)
// Vẽ đường MA10 trên biểu đồ
plot(ma9, color=color.red, title="MA9")
plot(ma18, color=color.blue, title="MA18")
plot(ma50, color=color.silver, title="MA50")

// periodK = input.int(9, title="%K Length", minval=1)
// smoothK = input.int(6, title="%K Smoothing", minval=1)
// periodD = input.int(3, title="%D Smoothing", minval=1)
// k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
// d = ta.sma(k, periodD)
// plot(k, title="%K", color=#2962FF)
// plot(d, title="%D", color=#FF6D00)
// h0 = hline(80, "Upper Band", color=#787B86)
// hline(50, "Middle Band", color=color.new(#787B86, 50))
// h1 = hline(20, "Lower Band", color=#787B86)


// Tính Pivot Points
calculatePivots() =>
    highPrice = request.security(syminfo.tickerid, "M", high)
    lowPrice = request.security(syminfo.tickerid, "M", low)
    closePrice = request.security(syminfo.tickerid, "M", close)

    pivotPoint = (highPrice + lowPrice + closePrice) / 3
    r1 = 2 * pivotPoint - lowPrice
    s1 = 2 * pivotPoint - highPrice
    r2 = pivotPoint + (highPrice - lowPrice)
    s2 = pivotPoint - (highPrice - lowPrice)
    r3 = highPrice + 2 * (pivotPoint - lowPrice)
    s3 = lowPrice - 2 * (highPrice - pivotPoint)
    temp_amp = (r3 - s3) / 6
    [pivotPoint, temp_amp]

// Lấy giá trị Pivot Points
[pivotPoint, temp_amp]  = calculatePivots()

averageAmplitude = temp_amp
i_top_price = pivotPoint

highPrice = request.security(syminfo.tickerid, "D", high)
lowPrice = request.security(syminfo.tickerid, "D", low)

max_highPrice = highPrice + averageAmplitude*3
min_lowPrice = lowPrice - averageAmplitude*3

// -------------------------------------------------------------------------------------------------------------------------------------

var line pivotLName = na
line.delete(id=pivotLName)
pivotLName := line.new(x1=bar_index[300], y1=i_top_price, x2=bar_index+20, y2=i_top_price, width=1, color=color.blue, style=line.style_solid)

// -------------------------------------------------------------------------------------------------------------------------------------

var line line_up_01 = na
line.delete(id=line_up_01)
val_line_up_01 = i_top_price + 1 * averageAmplitude
if((min_lowPrice <= val_line_up_01) and (val_line_up_01 <= max_highPrice))
    line_up_01 := line.new(x1=bar_index[300], y1=val_line_up_01, x2=bar_index+20, y2=val_line_up_01, width=1, color=color.red, style=line.style_dotted)

var line line_up_02 = na
line.delete(id=line_up_02)
val_line_up_02 = i_top_price + 2 * averageAmplitude
if((min_lowPrice <= val_line_up_02) and (val_line_up_02 <= max_highPrice))
    line_up_02 := line.new(x1=bar_index[300], y1=val_line_up_02, x2=bar_index+20, y2=val_line_up_02, width=1, color=color.red, style=line.style_dotted)

var line line_up_03 = na
line.delete(id=line_up_03)
val_line_up_03 = i_top_price + 3 * averageAmplitude
if((min_lowPrice <= val_line_up_03) and (val_line_up_03 <= max_highPrice))
    line_up_03 := line.new(x1=bar_index[300], y1=val_line_up_03, x2=bar_index+20, y2=val_line_up_03, width=1, color=color.red, style=line.style_dotted)

var line line_up_04 = na
line.delete(id=line_up_04)
val_line_up_04 = i_top_price + 4 * averageAmplitude
if((min_lowPrice <= val_line_up_04) and (val_line_up_04 <= max_highPrice))
    line_up_04 := line.new(x1=bar_index[300], y1=val_line_up_04, x2=bar_index+20, y2=val_line_up_04, width=1, color=color.red, style=line.style_dotted)

var line line_up_05 = na
line.delete(id=line_up_05)
val_line_up_05 = i_top_price + 5 * averageAmplitude
if((min_lowPrice <= val_line_up_05) and (val_line_up_05 <= max_highPrice))
    line_up_05 := line.new(x1=bar_index[300], y1=val_line_up_05, x2=bar_index+20, y2=val_line_up_05, width=1, color=color.red, style=line.style_dotted)

var line line_up_06 = na
line.delete(id=line_up_06)
val_line_up_06 = i_top_price + 6 * averageAmplitude
if((min_lowPrice <= val_line_up_06) and (val_line_up_06 <= max_highPrice))
    line_up_06 := line.new(x1=bar_index[300], y1=val_line_up_06, x2=bar_index+20, y2=val_line_up_06, width=1, color=color.red, style=line.style_dotted)

var line line_up_07 = na
line.delete(id=line_up_07)
val_line_up_07 = i_top_price + 7 * averageAmplitude
if((min_lowPrice <= val_line_up_07) and (val_line_up_07 <= max_highPrice))
    line_up_07 := line.new(x1=bar_index[300], y1=val_line_up_07, x2=bar_index+20, y2=val_line_up_07, width=1, color=color.red, style=line.style_dotted)

var line line_up_08 = na
line.delete(id=line_up_08)
val_line_up_08 = i_top_price + 8 * averageAmplitude
if((min_lowPrice <= val_line_up_08) and (val_line_up_08 <= max_highPrice))
    line_up_08 := line.new(x1=bar_index[300], y1=val_line_up_08, x2=bar_index+20, y2=val_line_up_08, width=1, color=color.red, style=line.style_dotted)

var line line_up_09 = na
line.delete(id=line_up_09)
val_line_up_09 = i_top_price + 9 * averageAmplitude
if((min_lowPrice <= val_line_up_09) and (val_line_up_09 <= max_highPrice))
    line_up_09 := line.new(x1=bar_index[300], y1=val_line_up_09, x2=bar_index+20, y2=val_line_up_09, width=1, color=color.red, style=line.style_dotted)

var line line_up_10 = na
line.delete(id=line_up_10)
val_line_up_10 = i_top_price + 10 * averageAmplitude
if((min_lowPrice <= val_line_up_10) and (val_line_up_10 <= max_highPrice))
    line_up_10 := line.new(x1=bar_index[300], y1=val_line_up_10, x2=bar_index+20, y2=val_line_up_10, width=1, color=color.red, style=line.style_dotted)


var line line_up_11 = na
line.delete(id=line_up_11)
val_line_up_11 = i_top_price + 11 * averageAmplitude
if((min_lowPrice <= val_line_up_11) and (val_line_up_11 <= max_highPrice))
    line_up_11 := line.new(x1=bar_index[300], y1=val_line_up_11, x2=bar_index+20, y2=val_line_up_11, width=1, color=color.red, style=line.style_dotted)

var line line_up_12 = na
line.delete(id=line_up_12)
val_line_up_12 = i_top_price + 12 * averageAmplitude
if((min_lowPrice <= val_line_up_12) and (val_line_up_12 <= max_highPrice))
    line_up_12 := line.new(x1=bar_index[300], y1=val_line_up_12, x2=bar_index+20, y2=val_line_up_12, width=1, color=color.red, style=line.style_dotted)

var line line_up_13 = na
line.delete(id=line_up_13)
val_line_up_13 = i_top_price + 13 * averageAmplitude
if((min_lowPrice <= val_line_up_13) and (val_line_up_13 <= max_highPrice))
    line_up_13 := line.new(x1=bar_index[300], y1=val_line_up_13, x2=bar_index+20, y2=val_line_up_13, width=1, color=color.red, style=line.style_dotted)

var line line_up_14 = na
line.delete(id=line_up_14)
val_line_up_14 = i_top_price + 14 * averageAmplitude
if((min_lowPrice <= val_line_up_14) and (val_line_up_14 <= max_highPrice))
    line_up_14 := line.new(x1=bar_index[300], y1=val_line_up_14, x2=bar_index+20, y2=val_line_up_14, width=1, color=color.red, style=line.style_dotted)

var line line_up_15 = na
line.delete(id=line_up_15)
val_line_up_15 = i_top_price + 15 * averageAmplitude
if((min_lowPrice <= val_line_up_15) and (val_line_up_15 <= max_highPrice))
    line_up_15 := line.new(x1=bar_index[300], y1=val_line_up_15, x2=bar_index+20, y2=val_line_up_15, width=1, color=color.red, style=line.style_dotted)

var line line_up_16 = na
line.delete(id=line_up_16)
val_line_up_16 = i_top_price + 16 * averageAmplitude
if((min_lowPrice <= val_line_up_16) and (val_line_up_16 <= max_highPrice))
    line_up_16 := line.new(x1=bar_index[300], y1=val_line_up_16, x2=bar_index+20, y2=val_line_up_16, width=1, color=color.red, style=line.style_dotted)

var line line_up_17 = na
line.delete(id=line_up_17)
val_line_up_17 = i_top_price + 17 * averageAmplitude
if((min_lowPrice <= val_line_up_17) and (val_line_up_17 <= max_highPrice))
    line_up_17 := line.new(x1=bar_index[300], y1=val_line_up_17, x2=bar_index+20, y2=val_line_up_17, width=1, color=color.red, style=line.style_dotted)

var line line_up_18 = na
line.delete(id=line_up_18)
val_line_up_18 = i_top_price + 18 * averageAmplitude
if((min_lowPrice <= val_line_up_18) and (val_line_up_18 <= max_highPrice))
    line_up_18 := line.new(x1=bar_index[300], y1=val_line_up_18, x2=bar_index+20, y2=val_line_up_18, width=1, color=color.red, style=line.style_dotted)

var line line_up_19 = na
line.delete(id=line_up_19)
val_line_up_19 = i_top_price + 19 * averageAmplitude
if((min_lowPrice <= val_line_up_19) and (val_line_up_19 <= max_highPrice))
    line_up_19 := line.new(x1=bar_index[300], y1=val_line_up_19, x2=bar_index+20, y2=val_line_up_19, width=1, color=color.red, style=line.style_dotted)

var line line_up_20 = na
line.delete(id=line_up_20)
val_line_up_20 = i_top_price + 20 * averageAmplitude
if((min_lowPrice <= val_line_up_20) and (val_line_up_20 <= max_highPrice))
    line_up_20 := line.new(x1=bar_index[300], y1=val_line_up_20, x2=bar_index+20, y2=val_line_up_20, width=1, color=color.red, style=line.style_dotted)



var line line_up_21 = na
line.delete(id=line_up_21)
val_line_up_21 = i_top_price + 21 * averageAmplitude
if((min_lowPrice <= val_line_up_21) and (val_line_up_21 <= max_highPrice))
    line_up_21 := line.new(x1=bar_index[300], y1=val_line_up_21, x2=bar_index+20, y2=val_line_up_21, width=1, color=color.red, style=line.style_dotted)

var line line_up_22 = na
line.delete(id=line_up_22)
val_line_up_22 = i_top_price + 22 * averageAmplitude
if((min_lowPrice <= val_line_up_22) and (val_line_up_22 <= max_highPrice))
    line_up_22 := line.new(x1=bar_index[300], y1=val_line_up_22, x2=bar_index+20, y2=val_line_up_22, width=1, color=color.red, style=line.style_dotted)

var line line_up_23 = na
line.delete(id=line_up_23)
val_line_up_23 = i_top_price + 23 * averageAmplitude
if((min_lowPrice <= val_line_up_23) and (val_line_up_23 <= max_highPrice))
    line_up_23 := line.new(x1=bar_index[300], y1=val_line_up_23, x2=bar_index+20, y2=val_line_up_23, width=1, color=color.red, style=line.style_dotted)

var line line_up_24 = na
line.delete(id=line_up_24)
val_line_up_24 = i_top_price + 24 * averageAmplitude
if((min_lowPrice <= val_line_up_24) and (val_line_up_24 <= max_highPrice))
    line_up_24 := line.new(x1=bar_index[300], y1=val_line_up_24, x2=bar_index+20, y2=val_line_up_24, width=1, color=color.red, style=line.style_dotted)

var line line_up_25 = na
line.delete(id=line_up_25)
val_line_up_25 = i_top_price + 25 * averageAmplitude
if((min_lowPrice <= val_line_up_25) and (val_line_up_25 <= max_highPrice))
    line_up_25 := line.new(x1=bar_index[300], y1=val_line_up_25, x2=bar_index+20, y2=val_line_up_25, width=1, color=color.red, style=line.style_dotted)

var line line_up_26 = na
line.delete(id=line_up_26)
val_line_up_26 = i_top_price + 26 * averageAmplitude
if((min_lowPrice <= val_line_up_26) and (val_line_up_26 <= max_highPrice))
    line_up_26 := line.new(x1=bar_index[300], y1=val_line_up_26, x2=bar_index+20, y2=val_line_up_26, width=1, color=color.red, style=line.style_dotted)

var line line_up_27 = na
line.delete(id=line_up_27)
val_line_up_27 = i_top_price + 27 * averageAmplitude
if((min_lowPrice <= val_line_up_27) and (val_line_up_27 <= max_highPrice))
    line_up_27 := line.new(x1=bar_index[300], y1=val_line_up_27, x2=bar_index+20, y2=val_line_up_27, width=1, color=color.red, style=line.style_dotted)

var line line_up_28 = na
line.delete(id=line_up_28)
val_line_up_28 = i_top_price + 28 * averageAmplitude
if((min_lowPrice <= val_line_up_28) and (val_line_up_28 <= max_highPrice))
    line_up_28 := line.new(x1=bar_index[300], y1=val_line_up_28, x2=bar_index+20, y2=val_line_up_28, width=1, color=color.red, style=line.style_dotted)

var line line_up_29 = na
line.delete(id=line_up_29)
val_line_up_29 = i_top_price + 29 * averageAmplitude
if((min_lowPrice <= val_line_up_29) and (val_line_up_29 <= max_highPrice))
    line_up_29 := line.new(x1=bar_index[300], y1=val_line_up_29, x2=bar_index+20, y2=val_line_up_29, width=1, color=color.red, style=line.style_dotted)

var line line_up_30 = na
line.delete(id=line_up_30)
val_line_up_30 = i_top_price + 30 * averageAmplitude
if((min_lowPrice <= val_line_up_30) and (val_line_up_30 <= max_highPrice))
    line_up_30 := line.new(x1=bar_index[300], y1=val_line_up_30, x2=bar_index+20, y2=val_line_up_30, width=1, color=color.red, style=line.style_dotted)



// -------------------------------------------------------------------------------------------------------------------------------------
// Tính phần trăm cắt lỗ
currentPrice = close
stopLossPercentage = (averageAmplitude / currentPrice) * 100

var label label_pivot = na
label.delete(label_pivot)
label_pivot := label.new(bar_index+20,val_line_up_05, color=color.white)
label.set_text(label_pivot, "amp: " + str.tostring(averageAmplitude, "#.#####") + "\n" + "sl: " + str.tostring(stopLossPercentage, "#.##") + "%")


var line line_dn_01 = na
line.delete(id=line_dn_01)
val_line_dn_01 = i_top_price - 1 * averageAmplitude
if((min_lowPrice <= val_line_dn_01) and (val_line_dn_01 <= max_highPrice))
    line_dn_01 := line.new(x1=bar_index[300], y1=val_line_dn_01, x2=bar_index+20, y2=val_line_dn_01, width=1, color=color.red, style=line.style_dotted)

var line line_dn_02 = na
line.delete(id=line_dn_02)
val_line_dn_02 = i_top_price - 2 * averageAmplitude
if((min_lowPrice <= val_line_dn_02) and (val_line_dn_02 <= max_highPrice))
    line_dn_02 := line.new(x1=bar_index[300], y1=val_line_dn_02, x2=bar_index+20, y2=val_line_dn_02, width=1, color=color.red, style=line.style_dotted)

var line line_dn_03 = na
line.delete(id=line_dn_03)
val_line_dn_03 = i_top_price - 3 * averageAmplitude
if((min_lowPrice <= val_line_dn_03) and (val_line_dn_03 <= max_highPrice))
    line_dn_03 := line.new(x1=bar_index[300], y1=val_line_dn_03, x2=bar_index+20, y2=val_line_dn_03, width=1, color=color.red, style=line.style_dotted)

var line line_dn_04 = na
line.delete(id=line_dn_04)
val_line_dn_04 = i_top_price - 4 * averageAmplitude
if((min_lowPrice <= val_line_dn_04) and (val_line_dn_04 <= max_highPrice))
    line_dn_04 := line.new(x1=bar_index[300], y1=val_line_dn_04, x2=bar_index+20, y2=val_line_dn_04, width=1, color=color.red, style=line.style_dotted)

var line line_dn_05 = na
line.delete(id=line_dn_05)
val_line_dn_05 = i_top_price - 5 * averageAmplitude
if((min_lowPrice <= val_line_dn_05) and (val_line_dn_05 <= max_highPrice))
    line_dn_05 := line.new(x1=bar_index[300], y1=val_line_dn_05, x2=bar_index+20, y2=val_line_dn_05, width=1, color=color.red, style=line.style_dotted)


var line line_dn_06 = na
line.delete(id=line_dn_06)
val_line_dn_06 = i_top_price - 6 * averageAmplitude
if((min_lowPrice <= val_line_dn_06) and (val_line_dn_06 <= max_highPrice))
    line_dn_06 := line.new(x1=bar_index[300], y1=val_line_dn_06, x2=bar_index+20, y2=val_line_dn_06, width=1, color=color.red, style=line.style_dotted)

var line line_dn_07 = na
line.delete(id=line_dn_07)
val_line_dn_07 = i_top_price - 7 * averageAmplitude
if((min_lowPrice <= val_line_dn_07) and (val_line_dn_07 <= max_highPrice))
    line_dn_07 := line.new(x1=bar_index[300], y1=val_line_dn_07, x2=bar_index+20, y2=val_line_dn_07, width=1, color=color.red, style=line.style_dotted)

var line line_dn_08 = na
line.delete(id=line_dn_08)
val_line_dn_08 = i_top_price - 8 * averageAmplitude
if((min_lowPrice <= val_line_dn_08) and (val_line_dn_08 <= max_highPrice))
    line_dn_08 := line.new(x1=bar_index[300], y1=val_line_dn_08, x2=bar_index+20, y2=val_line_dn_08, width=1, color=color.red, style=line.style_dotted)

var line line_dn_09 = na
line.delete(id=line_dn_09)
val_line_dn_09 = i_top_price - 9 * averageAmplitude
if((min_lowPrice <= val_line_dn_09) and (val_line_dn_09 <= max_highPrice))
    line_dn_09 := line.new(x1=bar_index[300], y1=val_line_dn_09, x2=bar_index+20, y2=val_line_dn_09, width=1, color=color.red, style=line.style_dotted)

var line line_dn_10 = na
line.delete(id=line_dn_10)
val_line_dn_10 = i_top_price - 10 * averageAmplitude
if((min_lowPrice <= val_line_dn_10) and (val_line_dn_10 <= max_highPrice))
    line_dn_10 := line.new(x1=bar_index[300], y1=val_line_dn_10, x2=bar_index+20, y2=val_line_dn_10, width=1, color=color.red, style=line.style_dotted)


var line line_dn_11 = na
line.delete(id=line_dn_11)
val_line_dn_11 = i_top_price - 11 * averageAmplitude
if((min_lowPrice <= val_line_dn_11) and (val_line_dn_11 <= max_highPrice))
    line_dn_11 := line.new(x1=bar_index[300], y1=val_line_dn_11, x2=bar_index+20, y2=val_line_dn_11, width=1, color=color.red, style=line.style_dotted)

var line line_dn_12 = na
line.delete(id=line_dn_12)
val_line_dn_12 = i_top_price - 12 * averageAmplitude
if((min_lowPrice <= val_line_dn_12) and (val_line_dn_12 <= max_highPrice))
    line_dn_12 := line.new(x1=bar_index[300], y1=val_line_dn_12, x2=bar_index+20, y2=val_line_dn_12, width=1, color=color.red, style=line.style_dotted)

var line line_dn_13 = na
line.delete(id=line_dn_13)
val_line_dn_13 = i_top_price - 13 * averageAmplitude
if((min_lowPrice <= val_line_dn_13) and (val_line_dn_13 <= max_highPrice))
    line_dn_13 := line.new(x1=bar_index[300], y1=val_line_dn_13, x2=bar_index+20, y2=val_line_dn_13, width=1, color=color.red, style=line.style_dotted)

var line line_dn_14 = na
line.delete(id=line_dn_14)
val_line_dn_14 = i_top_price - 14 * averageAmplitude
if((min_lowPrice <= val_line_dn_14) and (val_line_dn_14 <= max_highPrice))
    line_dn_14 := line.new(x1=bar_index[300], y1=val_line_dn_14, x2=bar_index+20, y2=val_line_dn_14, width=1, color=color.red, style=line.style_dotted)

var line line_dn_15 = na
line.delete(id=line_dn_15)
val_line_dn_15 = i_top_price - 15 * averageAmplitude
if((min_lowPrice <= val_line_dn_15) and (val_line_dn_15 <= max_highPrice))
    line_dn_15 := line.new(x1=bar_index[300], y1=val_line_dn_15, x2=bar_index+20, y2=val_line_dn_15, width=1, color=color.red, style=line.style_dotted)


var line line_dn_16 = na
line.delete(id=line_dn_16)
val_line_dn_16 = i_top_price - 16 * averageAmplitude
if((min_lowPrice <= val_line_dn_16) and (val_line_dn_16 <= max_highPrice))
    line_dn_16 := line.new(x1=bar_index[300], y1=val_line_dn_16, x2=bar_index+20, y2=val_line_dn_16, width=1, color=color.red, style=line.style_dotted)

var line line_dn_17 = na
line.delete(id=line_dn_17)
val_line_dn_17 = i_top_price - 17 * averageAmplitude
if((min_lowPrice <= val_line_dn_17) and (val_line_dn_17 <= max_highPrice))
    line_dn_17 := line.new(x1=bar_index[300], y1=val_line_dn_17, x2=bar_index+20, y2=val_line_dn_17, width=1, color=color.red, style=line.style_dotted)

var line line_dn_18 = na
line.delete(id=line_dn_18)
val_line_dn_18 = i_top_price - 8 * averageAmplitude
if((min_lowPrice <= val_line_dn_18) and (val_line_dn_18 <= max_highPrice))
    line_dn_18 := line.new(x1=bar_index[300], y1=val_line_dn_18, x2=bar_index+20, y2=val_line_dn_18, width=1, color=color.red, style=line.style_dotted)

var line line_dn_19 = na
line.delete(id=line_dn_19)
val_line_dn_19 = i_top_price - 19 * averageAmplitude
if((min_lowPrice <= val_line_dn_19) and (val_line_dn_19 <= max_highPrice))
    line_dn_19 := line.new(x1=bar_index[300], y1=val_line_dn_19, x2=bar_index+20, y2=val_line_dn_19, width=1, color=color.red, style=line.style_dotted)

var line line_dn_20 = na
line.delete(id=line_dn_20)
val_line_dn_20 = i_top_price - 20 * averageAmplitude
if((min_lowPrice <= val_line_dn_20) and (val_line_dn_20 <= max_highPrice))
    line_dn_20 := line.new(x1=bar_index[300], y1=val_line_dn_20, x2=bar_index+20, y2=val_line_dn_20, width=1, color=color.red, style=line.style_dotted)


var line line_dn_21 = na
line.delete(id=line_dn_21)
val_line_dn_21 = i_top_price - 21 * averageAmplitude
if((min_lowPrice <= val_line_dn_21) and (val_line_dn_21 <= max_highPrice))
    line_dn_21 := line.new(x1=bar_index[300], y1=val_line_dn_21, x2=bar_index+20, y2=val_line_dn_21, width=1, color=color.red, style=line.style_dotted)

var line line_dn_22 = na
line.delete(id=line_dn_22)
val_line_dn_22 = i_top_price - 22 * averageAmplitude
if((min_lowPrice <= val_line_dn_22) and (val_line_dn_22 <= max_highPrice))
    line_dn_22 := line.new(x1=bar_index[300], y1=val_line_dn_22, x2=bar_index+20, y2=val_line_dn_22, width=1, color=color.red, style=line.style_dotted)

var line line_dn_23 = na
line.delete(id=line_dn_23)
val_line_dn_23 = i_top_price - 23 * averageAmplitude
if((min_lowPrice <= val_line_dn_23) and (val_line_dn_23 <= max_highPrice))
    line_dn_23 := line.new(x1=bar_index[300], y1=val_line_dn_23, x2=bar_index+20, y2=val_line_dn_23, width=1, color=color.red, style=line.style_dotted)

var line line_dn_24 = na
line.delete(id=line_dn_24)
val_line_dn_24 = i_top_price - 24 * averageAmplitude
if((min_lowPrice <= val_line_dn_24) and (val_line_dn_24 <= max_highPrice))
    line_dn_24 := line.new(x1=bar_index[300], y1=val_line_dn_24, x2=bar_index+20, y2=val_line_dn_24, width=1, color=color.red, style=line.style_dotted)

var line line_dn_25 = na
line.delete(id=line_dn_25)
val_line_dn_25 = i_top_price - 25 * averageAmplitude
if((min_lowPrice <= val_line_dn_25) and (val_line_dn_25 <= max_highPrice))
    line_dn_25 := line.new(x1=bar_index[300], y1=val_line_dn_25, x2=bar_index+20, y2=val_line_dn_25, width=1, color=color.red, style=line.style_dotted)


var line line_dn_26 = na
line.delete(id=line_dn_26)
val_line_dn_26 = i_top_price - 26 * averageAmplitude
if((min_lowPrice <= val_line_dn_26) and (val_line_dn_26 <= max_highPrice))
    line_dn_26 := line.new(x1=bar_index[300], y1=val_line_dn_26, x2=bar_index+20, y2=val_line_dn_26, width=1, color=color.red, style=line.style_dotted)

var line line_dn_27 = na
line.delete(id=line_dn_27)
val_line_dn_27 = i_top_price - 27 * averageAmplitude
if((min_lowPrice <= val_line_dn_27) and (val_line_dn_27 <= max_highPrice))
    line_dn_27 := line.new(x1=bar_index[300], y1=val_line_dn_27, x2=bar_index+20, y2=val_line_dn_27, width=1, color=color.red, style=line.style_dotted)

var line line_dn_28 = na
line.delete(id=line_dn_28)
val_line_dn_28 = i_top_price - 28 * averageAmplitude
if((min_lowPrice <= val_line_dn_28) and (val_line_dn_28 <= max_highPrice))
    line_dn_28 := line.new(x1=bar_index[300], y1=val_line_dn_28, x2=bar_index+20, y2=val_line_dn_28, width=1, color=color.red, style=line.style_dotted)

var line line_dn_29 = na
line.delete(id=line_dn_29)
val_line_dn_29 = i_top_price - 29 * averageAmplitude
if((min_lowPrice <= val_line_dn_29) and (val_line_dn_29 <= max_highPrice))
    line_dn_29 := line.new(x1=bar_index[300], y1=val_line_dn_29, x2=bar_index+20, y2=val_line_dn_29, width=1, color=color.red, style=line.style_dotted)

var line line_dn_30 = na
line.delete(id=line_dn_30)
val_line_dn_30 = i_top_price - 30 * averageAmplitude
if((min_lowPrice <= val_line_dn_30) and (val_line_dn_30 <= max_highPrice))
    line_dn_30 := line.new(x1=bar_index[300], y1=val_line_dn_30, x2=bar_index+20, y2=val_line_dn_30, width=1, color=color.red, style=line.style_dotted)

