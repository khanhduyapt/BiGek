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
    private BigDecimal money_risk; // C17
    private BigDecimal entry; // C18
    private BigDecimal stop_loss; // C19
    private BigDecimal take_profit; // C20

    public BigDecimal calcSLMoney() {
        if ((entry.subtract(stop_loss)).abs().compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        // C18*C17/ABS(C18-C19)
        // entry*money_risk/ABS(entry-stop_loss)
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

        // C18*C17/ABS(C18-C19)
        // entry*money_risk/ABS(entry-stop_loss)
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

        // qty = C31*C35/C33
        BigDecimal qty = BigDecimal.ZERO;

        List<BigDecimal> list = getStandard_lot();
        BigDecimal standard_lot = list.get(0);
        BigDecimal unit_risk_per_pip = list.get(1);

        if (unit_risk_per_pip.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        // qty = standard_lot * ((money_risk/(ABS(entry-stop_loss))) / unit_risk_per_pip
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
        case "ETHUSD":
            standard_lot = BigDecimal.valueOf(0.714);
            unit_risk_per_pip = BigDecimal.valueOf(0.714285714285714);
            break;
        case "GOLD":
        case "XAUUSD":
            standard_lot = BigDecimal.valueOf(0.0125);
            unit_risk_per_pip = BigDecimal.valueOf(1.25);
            break;
        case "OIL_CRUDE":
        case "OILCRUDE":
        case "USOIL":
            standard_lot = BigDecimal.valueOf(0.25);
            unit_risk_per_pip = BigDecimal.valueOf(25);
            break;
        case "SILVER":
        case "XAGUSD":
            standard_lot = BigDecimal.valueOf(0.02);
            unit_risk_per_pip = BigDecimal.valueOf(100);
            break;
        case "NATURALGAS":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(250);
            break;
        case "US30":
            standard_lot = BigDecimal.valueOf(0.833);
            unit_risk_per_pip = BigDecimal.valueOf(0.833333333333333);
            break;
        case "US500":
            standard_lot = BigDecimal.valueOf(0.05);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "SP500":
            standard_lot = BigDecimal.valueOf(0.5);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "SP35":
            standard_lot = BigDecimal.valueOf(0.0234);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "UK100":
            standard_lot = BigDecimal.valueOf(0.208);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "FR40":
        case "FRA40":
            standard_lot = BigDecimal.valueOf(0.0234);
            unit_risk_per_pip = BigDecimal.valueOf(0.25);
            break;
        case "HK50":
            standard_lot = BigDecimal.valueOf(0.098);
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
            unit_risk_per_pip = BigDecimal.valueOf(166.66);
            break;
        case "USDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66);
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
            unit_risk_per_pip = BigDecimal.valueOf(50000);
            break;
        case "EURAUD":
            standard_lot = BigDecimal.valueOf(0.0724);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "EURJPY":
            standard_lot = BigDecimal.valueOf(0.672);
            unit_risk_per_pip = BigDecimal.valueOf(500);
            break;
        case "EURCAD":
            standard_lot = BigDecimal.valueOf(0.0674);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "CADJPY":
            standard_lot = BigDecimal.valueOf(0.336);
            unit_risk_per_pip = BigDecimal.valueOf(250);
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
            unit_risk_per_pip = BigDecimal.valueOf(8333);
            break;
        case "AUDNZD":
            standard_lot = BigDecimal.valueOf(0.2);
            unit_risk_per_pip = BigDecimal.valueOf(12500);
            break;
        case "NZDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66);
            break;
        case "USDNOK":
            standard_lot = BigDecimal.valueOf(0.128);
            unit_risk_per_pip = BigDecimal.valueOf(1250);
            break;
        case "USDPLN":
            standard_lot = BigDecimal.valueOf(0.0222);
            unit_risk_per_pip = BigDecimal.valueOf(500);
            break;
        case "USDCZK":
            standard_lot = BigDecimal.valueOf(0.111);
            unit_risk_per_pip = BigDecimal.valueOf(500);
            break;
        case "USDSEK":
            standard_lot = BigDecimal.valueOf(0.129);
            unit_risk_per_pip = BigDecimal.valueOf(1250);
            break;
        case "AUDJPY":
            standard_lot = BigDecimal.valueOf(0.225);
            unit_risk_per_pip = BigDecimal.valueOf(170);
            break;
        case "NZDJPY":
            standard_lot = BigDecimal.valueOf(0.337);
            unit_risk_per_pip = BigDecimal.valueOf(260);
            break;

        case "GBPNZD":
            standard_lot = BigDecimal.valueOf(0.0402);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "EURCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "AUDCHF":
            standard_lot = BigDecimal.valueOf(0.0234);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "GBPCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "CADCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "CHFJPY":
            standard_lot = BigDecimal.valueOf(0.674);
            unit_risk_per_pip = BigDecimal.valueOf(500);
            break;
        case "NZDCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "J225":
        case "JPY225":
        case "JPN225":
        case "JP225":
            standard_lot = BigDecimal.valueOf(6.8);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "AU200":
        case "AUS200":
            standard_lot = BigDecimal.valueOf(0.746);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "GER30":
        case "GER40":
            standard_lot = BigDecimal.valueOf(0.158);
            unit_risk_per_pip = BigDecimal.valueOf(0.16666);
            break;
        case "DE40":
        case "DAX40":
            standard_lot = BigDecimal.valueOf(0.0158);
            unit_risk_per_pip = BigDecimal.valueOf(0.16666);
            break;
        case "EU50":
            standard_lot = BigDecimal.valueOf(0.474);
            unit_risk_per_pip = BigDecimal.valueOf(0.5);
            break;
        case "EURCZK":
            standard_lot = BigDecimal.valueOf(0.0373);
            unit_risk_per_pip = BigDecimal.valueOf(166.66);
            break;
        case "EURPLN":
            standard_lot = BigDecimal.valueOf(0.112);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "US100":
            standard_lot = BigDecimal.valueOf(0.167);
            unit_risk_per_pip = BigDecimal.valueOf(0.16666);
            break;
        case "NAS100":
            standard_lot = BigDecimal.valueOf(0.167);
            unit_risk_per_pip = BigDecimal.valueOf(0.16666);
            break;
        case "USDHKD":
            standard_lot = BigDecimal.valueOf(0.131);
            unit_risk_per_pip = BigDecimal.valueOf(1666);
            break;
        case "USDHUF":
            standard_lot = BigDecimal.valueOf(0.18);
            unit_risk_per_pip = BigDecimal.valueOf(50);
            break;
        case "USDILS":
            standard_lot = BigDecimal.valueOf(0.184);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "USDMXN":
            standard_lot = BigDecimal.valueOf(0.0306);
            unit_risk_per_pip = BigDecimal.valueOf(166);
            break;
        case "USDTRY":
            standard_lot = BigDecimal.valueOf(0.118);
            unit_risk_per_pip = BigDecimal.valueOf(625);
            break;
        case "USDZAR":
            standard_lot = BigDecimal.valueOf(0.023);
            unit_risk_per_pip = BigDecimal.valueOf(125);
            break;
        case "EURDKK":
            standard_lot = BigDecimal.valueOf(0.175);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "EURHUF":
            standard_lot = BigDecimal.valueOf(0.357);
            unit_risk_per_pip = BigDecimal.valueOf(100);
            break;
        case "EURMXN":
            standard_lot = BigDecimal.valueOf(0.435);
            unit_risk_per_pip = BigDecimal.valueOf(2421);
            break;
        case "EURNOK":
            standard_lot = BigDecimal.valueOf(0.11);
            unit_risk_per_pip = BigDecimal.valueOf(1063);
            break;
        case "EURRON":
            standard_lot = BigDecimal.valueOf(0.116);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "EURSEK":
            standard_lot = BigDecimal.valueOf(0.261);
            unit_risk_per_pip = BigDecimal.valueOf(2500);
            break;
        case "EURSGD":
            standard_lot = BigDecimal.valueOf(0.336);
            unit_risk_per_pip = BigDecimal.valueOf(25000);
            break;
        case "EURTRY":
            standard_lot = BigDecimal.valueOf(0.314);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66);
            break;
        case "GBPTRY":
            standard_lot = BigDecimal.valueOf(0.314);
            unit_risk_per_pip = BigDecimal.valueOf(1666.66);
            break;
        case "USDCNH":
            standard_lot = BigDecimal.valueOf(0.345);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "USDDKK":
            standard_lot = BigDecimal.valueOf(0.35);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "USDRON":
            standard_lot = BigDecimal.valueOf(0.232);
            unit_risk_per_pip = BigDecimal.valueOf(5000);
            break;
        case "USDSGD":
            standard_lot = BigDecimal.valueOf(0.135);
            unit_risk_per_pip = BigDecimal.valueOf(10000);
            break;
        case "AMZN":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "BAC":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "GOOG":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "MSFT":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "NFLX":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "AAPL":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "NVDA":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "META":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "PFE":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "RACE":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "TSLA":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "WMT":
            standard_lot = BigDecimal.valueOf(10);
            unit_risk_per_pip = BigDecimal.valueOf(10);
            break;
        case "DX.f":
            standard_lot = BigDecimal.valueOf(1);
            unit_risk_per_pip = BigDecimal.valueOf(100);
            break;

        default:
            standard_lot = BigDecimal.valueOf(0.01);
            unit_risk_per_pip = BigDecimal.valueOf(10000);

            System.out.println("getStandard_lot: " + EPIC + " not exist!----------------------------------");
            // String msg = "getStandard_lot: " + EPIC + " not exist!";
            // Utils.logWritelnDraft(msg);
            break;
        }

        result.add(standard_lot);
        result.add(unit_risk_per_pip);

        return result;
    }

}
