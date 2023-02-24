package bsc_scan_binance.response;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import bsc_scan_binance.utils.Utils;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class MoneyAtRiskResponse {
    private String EPIC;
    private BigDecimal money_risk; //C17
    private BigDecimal entry; //C18
    private BigDecimal stop_loss; //C19
    private BigDecimal take_profit; //C20

    public BigDecimal calcSLMoney() {
        if ((entry.subtract(stop_loss)).abs().compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        //C18*C17/ABS(C18-C19)
        //entry*money_risk/ABS(entry-stop_loss)
        BigDecimal buy = entry.multiply(money_risk);
        buy = buy.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING);

        // sell=C19*C17/ABS(C18-C19)
        // sell=stop_loss*money_risk/ABS(entry-stop_loss)
        BigDecimal sell = stop_loss.multiply(money_risk);
        sell = sell.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING);

        BigDecimal money = sell.subtract(buy).abs();
        money = Utils.formatPrice(money, 2);

        return money;
    }

    public BigDecimal calcTPMoney() {
        if ((entry.subtract(stop_loss)).abs().compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        //C18*C17/ABS(C18-C19)
        //entry*money_risk/ABS(entry-stop_loss)
        BigDecimal buy = entry.multiply(money_risk);
        buy = buy.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING);

        // sell=C20*C17/ABS(C18-C19)
        // sell=take_profit*money_risk/ABS(entry-stop_loss)
        BigDecimal sell = take_profit.multiply(money_risk);
        sell = sell.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING);

        BigDecimal money = sell.subtract(buy).abs();
        money = Utils.formatPrice(money, 2);

        return money;
    }

    public BigDecimal calcLot() {
        if ((entry.subtract(stop_loss)).abs().compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        //qty = C31*C35/C33
        BigDecimal qty = BigDecimal.ZERO;

        List<BigDecimal> list = getStandard_lot();
        BigDecimal standard_lot = list.get(0);
        BigDecimal unit_risk_per_pip = list.get(1);

        if (unit_risk_per_pip.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        //qty = standard_lot *  ((money_risk/(ABS(entry-stop_loss)))  / unit_risk_per_pip
        qty = standard_lot.multiply(money_risk.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING));
        qty = qty.divide(unit_risk_per_pip, 10, RoundingMode.CEILING);

        if (qty.compareTo(BigDecimal.valueOf(0.01)) < 0) {
            qty = Utils.formatPrice(qty, 3);
        } else {
            qty = Utils.formatPrice(qty, 2);
        }

        return qty;
    }

    private List<BigDecimal> getStandard_lot() {
        List<BigDecimal> result = new ArrayList<BigDecimal>();
        BigDecimal standard_lot = BigDecimal.ZERO;
        BigDecimal unit_risk_per_pip = BigDecimal.ZERO;

        switch (EPIC) {
        case "DXY":
            standard_lot = BigDecimal.valueOf(25);
            unit_risk_per_pip = BigDecimal.valueOf(25);
            break;
        case "BTCUSD":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(0.05);
            break;
        case "GOLD":
            standard_lot = BigDecimal.valueOf(0.0125);
            unit_risk_per_pip = BigDecimal.valueOf(1.25);
            break;
        case "OIL_CRUDE":
            standard_lot = BigDecimal.valueOf(0.25);
            unit_risk_per_pip = BigDecimal.valueOf(25);
            break;
        case "SILVER":
            standard_lot = BigDecimal.valueOf(0.02);
            unit_risk_per_pip = BigDecimal.valueOf(100);
            break;
        case "NATURALGAS":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(250);
            break;
        case "US30":
            standard_lot = BigDecimal.valueOf(0.0833);
            unit_risk_per_pip = BigDecimal.valueOf(0.0833333333333333);
            break;
        case "US500":
            standard_lot = BigDecimal.valueOf(0.5);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "J225":
            standard_lot = BigDecimal.valueOf(0.224);
            unit_risk_per_pip = BigDecimal.valueOf(0.166666666666667);
            break;
        case "SP35":
            standard_lot = BigDecimal.valueOf(0.234);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "UK100":
            standard_lot = BigDecimal.valueOf(0.208);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "FR40":
            standard_lot = BigDecimal.valueOf(0.234);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "HK50":
            standard_lot = BigDecimal.valueOf(0.98);
            unit_risk_per_pip = BigDecimal.valueOf(0.125);
            break;
        case "EURUSD":
            standard_lot = BigDecimal.valueOf(0.025);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "GBPUSD":
            standard_lot = BigDecimal.valueOf(0.025);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "AUDUSD":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "NZDUSD":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "USDJPY":
            standard_lot = BigDecimal.valueOf(0.224);
            unit_risk_per_pip = BigDecimal.valueOf(166.666666666676);
            break;
        case "USDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66666666667);
            break;
        case "USDCHF":
            standard_lot = BigDecimal.valueOf(0.0462);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "EURGBP":
            standard_lot = BigDecimal.valueOf(0.0416);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "GBPAUD":
            standard_lot = BigDecimal.valueOf(0.724);
            unit_risk_per_pip = BigDecimal.valueOf(49999.9999999944);
            break;
        case "EURAUD":
            standard_lot = BigDecimal.valueOf(0.0724);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "EURJPY":
            standard_lot = BigDecimal.valueOf(0.672);
            unit_risk_per_pip = BigDecimal.valueOf(500.000000000028);
            break;
        case "EURCAD":
            standard_lot = BigDecimal.valueOf(0.0674);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "CADJPY":
            standard_lot = BigDecimal.valueOf(0.336);
            unit_risk_per_pip = BigDecimal.valueOf(249.999999999996);
            break;
        case "GBPJPY":
            standard_lot = BigDecimal.valueOf(0.0672);
            unit_risk_per_pip = BigDecimal.valueOf(50);
            break;
        case "AUDCAD":
            standard_lot = BigDecimal.valueOf(0.0337);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "GBPCAD":
            standard_lot = BigDecimal.valueOf(0.0674);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "EURNZD":
            standard_lot = BigDecimal.valueOf(0.133);
            unit_risk_per_pip = BigDecimal.valueOf(8333.33333333333);
            break;
        case "AUDNZD":
            standard_lot = BigDecimal.valueOf(0.2);
            unit_risk_per_pip = BigDecimal.valueOf(12500);
            break;
        case "NZDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66666666667);
            break;
        case "USDNOK":
            standard_lot = BigDecimal.valueOf(0.128);
            unit_risk_per_pip = BigDecimal.valueOf(1250.00000000003);
            break;
        case "USDPLN":
            standard_lot = BigDecimal.valueOf(0.0222);
            unit_risk_per_pip = BigDecimal.valueOf(500.000000000002);
            break;
        case "USDCZK":
            standard_lot = BigDecimal.valueOf(0.111);
            unit_risk_per_pip = BigDecimal.valueOf(499.999999999993);
            break;
        case "USDSEK":
            standard_lot = BigDecimal.valueOf(0.129);
            unit_risk_per_pip = BigDecimal.valueOf(1250.00000000003);
            break;
        case "AUDJPY":
            standard_lot = BigDecimal.valueOf(0.225);
            unit_risk_per_pip = BigDecimal.valueOf(170.000000000002);
            break;
        case "NZDJPY":
            standard_lot = BigDecimal.valueOf(0.337);
            unit_risk_per_pip = BigDecimal.valueOf(259.999999999996);
            break;

        case "GBPNZD":
            standard_lot = BigDecimal.valueOf(0.0402);
            unit_risk_per_pip = BigDecimal.valueOf(2550);
            break;
        case "EURCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5200);
            break;
        case "AUDCHF":
            standard_lot = BigDecimal.valueOf(0.0234);
            unit_risk_per_pip = BigDecimal.valueOf(2650.00000000001);
            break;
        case "GBPCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5400);
            break;
        case "CADCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5500);
            break;
        case "CHFJPY":
            standard_lot = BigDecimal.valueOf(0.674);
            unit_risk_per_pip = BigDecimal.valueOf(560.000000000032);
            break;
        case "NZDCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5699.99999999999);
            break;

        default:
            String msg = "getStandard_lot: " + EPIC + " not exist!";
            System.out.println("getStandard_lot: " + EPIC + " not exist!----------------------------------");
            Utils.logWritelnWithTime(msg, false);
            Utils.sendToMyTelegram(msg);
            break;
        }

        result.add(standard_lot);
        result.add(unit_risk_per_pip);

        return result;
    }

}
