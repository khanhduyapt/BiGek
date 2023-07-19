package bsc_scan_binance.response;

import java.math.BigDecimal;
import java.math.RoundingMode;
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
        BigDecimal volume = BigDecimal.ZERO;

        List<BigDecimal> list = Utils.getStandard_lot(EPIC);
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
            volume = BigDecimal.valueOf(volume.intValue());
        }

        return volume;
    }

}
