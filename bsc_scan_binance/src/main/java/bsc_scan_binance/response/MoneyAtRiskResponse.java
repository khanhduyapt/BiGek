package bsc_scan_binance.response;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import com.google.common.base.Objects;

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
        BigDecimal volume = BigDecimal.ZERO;

        List<BigDecimal> list = getStandard_lot(EPIC);
        BigDecimal standard_lot = list.get(0);
        BigDecimal unit_risk_per_pip = list.get(1);

        if (unit_risk_per_pip.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        // qty = standard_lot * ((money_risk/(ABS(entry-stop_loss))) / unit_risk_per_pip
        volume = standard_lot.multiply(money_risk.divide((entry.subtract(stop_loss)).abs(), 10, RoundingMode.CEILING));
        volume = volume.divide(unit_risk_per_pip, 10, RoundingMode.CEILING);

        BigDecimal multi = volume.divide(BigDecimal.valueOf(0.05), 0, RoundingMode.FLOOR);
        if (multi.intValue() == 0) {
            volume = BigDecimal.valueOf(0.01);
        } else {
            volume = BigDecimal.valueOf(0.05).multiply(multi);
        }

        if (Utils.EPICS_STOCKS.contains(EPIC)) {
            return getStandard_vol(BigDecimal.valueOf(volume.intValue()));
        }
        if ("_ADAUSD_DOGEUSD_DOTUSD_LTCUSD_XRPUSD_".contains("_" + EPIC + "_")) {
            return getStandard_vol(BigDecimal.valueOf(volume.intValue()));
        }

        if (volume.compareTo(BigDecimal.valueOf(1)) < 0) {
            BigDecimal progression = BigDecimal.valueOf(0.05);
            for (int index = 1; index <= 20; index++) {
                BigDecimal next_vol = progression.multiply(BigDecimal.valueOf(index));
                if (volume.compareTo(next_vol) <= 0) {
                    return getStandard_vol(next_vol);
                }
            }
        }

        if (volume.compareTo(BigDecimal.valueOf(1)) > 0) {
            BigDecimal progression = BigDecimal.valueOf(0.25);
            for (int index = 1; index <= 50; index++) {
                BigDecimal low = progression.multiply(BigDecimal.valueOf(3 + index));
                BigDecimal hig = progression.multiply(BigDecimal.valueOf(3 + index + 1));
                if ((volume.compareTo(low) >= 0) && (hig.compareTo(volume) >= 0)) {
                    return getStandard_vol(low);
                }
            }
        }

        return getStandard_vol(volume);
    }

    private BigDecimal getStandard_vol(BigDecimal volume) {
        boolean debug = true;
        if (debug) {
            return volume;
        }

        if (Objects.equal(Utils.getStringValue(EPIC).toUpperCase(), "DBKGN")) {
            debug = true;
        }
        BigDecimal result = volume;
        BigDecimal standard_vol = Utils.get_standard_vol_per_100usd(EPIC);

        if (standard_vol.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal low_vol = standard_vol.multiply(BigDecimal.valueOf(0.75));
            BigDecimal hig_vol = standard_vol.multiply(BigDecimal.valueOf(1.25));
            if ((low_vol.compareTo(volume) <= 0) && (volume.compareTo(hig_vol) <= 0)) {
                result = standard_vol;
            }

            if (volume.compareTo(standard_vol.multiply(BigDecimal.valueOf(2))) >= 0) {
                result = standard_vol.multiply(BigDecimal.valueOf(2));
            }

            if (volume.compareTo(standard_vol.multiply(BigDecimal.valueOf(0.5))) <= 0) {
                result = standard_vol.multiply(BigDecimal.valueOf(0.5));
            }
        }

        if (Utils.EPICS_STOCKS.contains(EPIC)) {
            return BigDecimal.valueOf(result.intValue());
        }
        if ("_ADAUSD_DOGEUSD_DOTUSD_LTCUSD_XRPUSD_".contains("_" + EPIC + "_")) {
            return BigDecimal.valueOf(result.intValue());
        }

        return result;
    }

    public List<BigDecimal> getStandard_lot(String EPIC) {
        List<BigDecimal> result = new ArrayList<BigDecimal>();
        BigDecimal standard_lot = BigDecimal.ZERO;
        BigDecimal contract_size = BigDecimal.ZERO;

        switch (EPIC) {
        case "DXY":
            standard_lot = BigDecimal.valueOf(25);
            contract_size = BigDecimal.valueOf(25);
            break;
        case "BTCUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "ETHUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "DASHUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "ADAUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(100);
            break;
        case "DOGEUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1000);
            break;
        case "XRPUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(100);
            break;
        case "DOTUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(10);
            break;
        case "LTCUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "GOLD":
        case "XAUUSD":
            standard_lot = BigDecimal.valueOf(0.0125);
            contract_size = BigDecimal.valueOf(1.25);
            break;
        case "OIL_CRUDE":
        case "OILCRUDE":
        case "USOIL":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(100);
            break;
        case "NATGAS":
        case "NATGAS.f":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1000);
            break;
        case "SILVER":
        case "XAGUSD":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "NATURALGAS":
            standard_lot = BigDecimal.valueOf(0.05);
            contract_size = BigDecimal.valueOf(250);
            break;
        case "US30":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "US500":
            standard_lot = BigDecimal.valueOf(0.05);
            contract_size = BigDecimal.valueOf(0.5);
            break;
        case "SP500":
            standard_lot = BigDecimal.valueOf(0.5);
            contract_size = BigDecimal.valueOf(0.5);
            break;
        case "SP35":
        case "SPN35":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "UK100":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "FR40":
        case "FRA40":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;
        case "HK50":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;

        case "ERBN":
        case "ERBN.f":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(100);
            break;

        case "EURUSD":
            standard_lot = BigDecimal.valueOf(0.025);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "GBPUSD":
            standard_lot = BigDecimal.valueOf(0.025);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "AUDUSD":
            standard_lot = BigDecimal.valueOf(0.05);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "NZDUSD":
            standard_lot = BigDecimal.valueOf(0.05);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "USDJPY":
            standard_lot = BigDecimal.valueOf(0.224);
            contract_size = BigDecimal.valueOf(166.66);
            break;
        case "USDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            contract_size = BigDecimal.valueOf(1666.66);
            break;
        case "USDCHF":
            standard_lot = BigDecimal.valueOf(0.0462);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "EURGBP":
            standard_lot = BigDecimal.valueOf(0.0416);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "GBPAUD":
            standard_lot = BigDecimal.valueOf(0.724);
            contract_size = BigDecimal.valueOf(50000);
            break;
        case "EURAUD":
            standard_lot = BigDecimal.valueOf(0.0724);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "EURJPY":
            standard_lot = BigDecimal.valueOf(0.672);
            contract_size = BigDecimal.valueOf(500);
            break;
        case "EURCAD":
            standard_lot = BigDecimal.valueOf(0.0674);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "CADJPY":
            standard_lot = BigDecimal.valueOf(0.336);
            contract_size = BigDecimal.valueOf(250);
            break;
        case "GBPJPY":
            standard_lot = BigDecimal.valueOf(0.0672);
            contract_size = BigDecimal.valueOf(50);
            break;
        case "AUDCAD":
            standard_lot = BigDecimal.valueOf(0.0337);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "GBPCAD":
            standard_lot = BigDecimal.valueOf(0.0674);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "EURNZD":
            standard_lot = BigDecimal.valueOf(0.133);
            contract_size = BigDecimal.valueOf(8333);
            break;
        case "AUDNZD":
            standard_lot = BigDecimal.valueOf(0.2);
            contract_size = BigDecimal.valueOf(12500);
            break;
        case "NZDCAD":
            standard_lot = BigDecimal.valueOf(0.0225);
            contract_size = BigDecimal.valueOf(1666.66);
            break;
        case "USDNOK":
            standard_lot = BigDecimal.valueOf(0.128);
            contract_size = BigDecimal.valueOf(1250);
            break;
        case "USDPLN":
            standard_lot = BigDecimal.valueOf(0.0222);
            contract_size = BigDecimal.valueOf(500);
            break;
        case "USDCZK":
            standard_lot = BigDecimal.valueOf(0.111);
            contract_size = BigDecimal.valueOf(500);
            break;
        case "USDSEK":
            standard_lot = BigDecimal.valueOf(0.129);
            contract_size = BigDecimal.valueOf(1250);
            break;
        case "AUDJPY":
            standard_lot = BigDecimal.valueOf(0.25);
            contract_size = BigDecimal.valueOf(170);
            break;
        case "NZDJPY":
            standard_lot = BigDecimal.valueOf(0.35);
            contract_size = BigDecimal.valueOf(260);
            break;

        case "GBPNZD":
            standard_lot = BigDecimal.valueOf(0.0402);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "EURCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "AUDCHF":
            standard_lot = BigDecimal.valueOf(0.0234);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "GBPCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "CADCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "CHFJPY":
            standard_lot = BigDecimal.valueOf(0.674);
            contract_size = BigDecimal.valueOf(500);
            break;
        case "NZDCHF":
            standard_lot = BigDecimal.valueOf(0.0468);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "J225":
        case "JPY225":
        case "JPN225":
        case "JP225":
            standard_lot = BigDecimal.valueOf(6.8);
            contract_size = BigDecimal.valueOf(0.5);
            break;
        case "AU200":
        case "AUS200":
            standard_lot = BigDecimal.valueOf(0.746);
            contract_size = BigDecimal.valueOf(0.5);
            break;
        case "GER30":
        case "GER40":
            standard_lot = BigDecimal.valueOf(0.158);
            contract_size = BigDecimal.valueOf(0.16666);
            break;
        case "DE40":
        case "DAX40":
            standard_lot = BigDecimal.valueOf(0.0158);
            contract_size = BigDecimal.valueOf(0.16666);
            break;
        case "EU50":
            standard_lot = BigDecimal.valueOf(0.474);
            contract_size = BigDecimal.valueOf(0.5);
            break;
        case "EURCZK":
            standard_lot = BigDecimal.valueOf(0.0373);
            contract_size = BigDecimal.valueOf(166.66);
            break;
        case "EURPLN":
            standard_lot = BigDecimal.valueOf(0.112);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "US100":
            standard_lot = BigDecimal.valueOf(0.167);
            contract_size = BigDecimal.valueOf(0.16666);
            break;
        case "NAS100":
            standard_lot = BigDecimal.valueOf(0.167);
            contract_size = BigDecimal.valueOf(0.16666);
            break;
        case "USDHKD":
            standard_lot = BigDecimal.valueOf(0.131);
            contract_size = BigDecimal.valueOf(1666);
            break;
        case "USDHUF":
            standard_lot = BigDecimal.valueOf(0.18);
            contract_size = BigDecimal.valueOf(50);
            break;
        case "USDILS":
            standard_lot = BigDecimal.valueOf(0.184);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "USDMXN":
            standard_lot = BigDecimal.valueOf(0.0306);
            contract_size = BigDecimal.valueOf(166);
            break;
        case "USDTRY":
            standard_lot = BigDecimal.valueOf(0.118);
            contract_size = BigDecimal.valueOf(625);
            break;
        case "USDZAR":
            standard_lot = BigDecimal.valueOf(0.023);
            contract_size = BigDecimal.valueOf(125);
            break;
        case "EURDKK":
            standard_lot = BigDecimal.valueOf(0.175);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "EURHUF":
            standard_lot = BigDecimal.valueOf(0.357);
            contract_size = BigDecimal.valueOf(100);
            break;
        case "EURMXN":
            standard_lot = BigDecimal.valueOf(0.435);
            contract_size = BigDecimal.valueOf(2421);
            break;
        case "EURNOK":
            standard_lot = BigDecimal.valueOf(0.11);
            contract_size = BigDecimal.valueOf(1063);
            break;
        case "EURRON":
            standard_lot = BigDecimal.valueOf(0.116);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "EURSEK":
            standard_lot = BigDecimal.valueOf(0.261);
            contract_size = BigDecimal.valueOf(2500);
            break;
        case "EURSGD":
            standard_lot = BigDecimal.valueOf(0.336);
            contract_size = BigDecimal.valueOf(25000);
            break;
        case "EURTRY":
            standard_lot = BigDecimal.valueOf(0.314);
            contract_size = BigDecimal.valueOf(1666.66);
            break;
        case "GBPTRY":
            standard_lot = BigDecimal.valueOf(0.314);
            contract_size = BigDecimal.valueOf(1666.66);
            break;
        case "USDCNH":
            standard_lot = BigDecimal.valueOf(0.345);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "USDDKK":
            standard_lot = BigDecimal.valueOf(0.35);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "USDRON":
            standard_lot = BigDecimal.valueOf(0.232);
            contract_size = BigDecimal.valueOf(5000);
            break;
        case "USDSGD":
            standard_lot = BigDecimal.valueOf(0.135);
            contract_size = BigDecimal.valueOf(10000);
            break;

        case "AMZN":
        case "BAC":
        case "GOOG":
        case "MSFT":
        case "NFLX":
        case "AAPL":
        case "NVDA":
        case "META":
        case "PFE":
        case "RACE":
        case "TSLA":
        case "WMT":
        case "BAYGn":
        case "VOWG_p":
        case "LVMH":
        case "AIRF":
        case "DBKGn":
        case "VOWGp":
        case "UK1":
        case "US1":
        case "AUS2":
        case "BABA":
        case "T":
        case "V":
        case "ZM":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(1);
            break;

        case "DX.f":
        case "DX":
            standard_lot = BigDecimal.valueOf(1);
            contract_size = BigDecimal.valueOf(100);
            break;
        default:
            standard_lot = BigDecimal.valueOf(0.01);
            contract_size = BigDecimal.valueOf(100000);

            System.out.println("MoneyAtRiskResponse: " + EPIC + " not exist!----------------------------------");
            break;
        }

        result.add(standard_lot);
        result.add(contract_size);

        return result;
    }

}
