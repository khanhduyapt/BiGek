package response;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DepthResponse {
    private String gecko_id;
    private String symbol;
    private BigDecimal price;
    private BigDecimal qty;
    private BigDecimal val_million_dolas;

    public String toString(int max_qty_length) {
        String str_qty = String.valueOf(qty);
        for (int i = str_qty.length(); i <= max_qty_length; i++) {
            str_qty = " " + str_qty;
        }

        return price + "$" + str_qty + " " + symbol + " = " + val_million_dolas + " M$";
    }

}
