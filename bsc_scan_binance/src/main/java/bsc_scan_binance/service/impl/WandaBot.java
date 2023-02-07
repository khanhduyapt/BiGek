package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Calendar;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import com.google.common.base.Objects;

import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.entity.OrderKey;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.TakeProfit;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.CandidateCoinRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.TakeProfitRepository;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WandaBot extends TelegramLongPollingBot {
    @Autowired
    private final BinanceService binance_service;

    @Autowired
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private TakeProfitRepository takeProfitRepository;

    @Autowired
    private CandidateCoinRepository candidateCoinRepository;

    @PersistenceContext
    private final EntityManager entityManager;

    @Override
    public void onUpdateReceived(Update update) {
        try {
            SendMessage message = new SendMessage();
            message.setChatId(Utils.getStringValue(update.getMessage().getChatId()));

            String userName = update.getMessage().getChat().getUserName();
            Boolean is_linhdk = Objects.equal("LokaDon", userName);
            Boolean is_duydk = Objects.equal("tg25251325", userName);

            if (!is_linhdk && !is_duydk) {
                message.setText("You are not my master.");
                execute(message);
                return;
            }

            String command = Utils.getStringValue(update.getMessage().getText());
            System.out.println(command);

            if (command.contains("/btc")) {
                checkCommand(message, "BTC");

            } else if (command.contains("/buy")) {
                Calendar calendar = Calendar.getInstance();
                BinanceVolumnWeek btc = binanceVolumnWeekRepository.findById(new BinanceVolumnWeekKey("bitcoin", "BTC",
                        Utils.convertDateToString("yyyyMMdd", calendar.getTime()))).orElse(null);

                BinanceVolumnDay btc_now = binanceVolumnDayRepository.findById(
                        new BinanceVolumnDayKey("bitcoin", "BTC", Utils.convertDateToString("HH", calendar.getTime())))
                        .orElse(null);

                if (Objects.equal(null, btc) || Objects.equal(null, btc_now)) {
                    message.setText("Failed to check the price of BTC.\nPlease buy another time.");
                    execute(message);
                    return;
                }

                message.setText("BTC: " + Utils.createMsgSimple(btc_now.getPriceAtBinance(), btc.getMin_price(),
                        btc_now.getPriceAtBinance()));
                execute(message);

                Boolean allowNext = true;
                if (!Utils.isGoodPriceLong(btc_now.getPriceAtBinance(), btc.getMin_price(), btc.getMax_price())) {
                    BigDecimal good_price = Utils.getGoodPriceLong(btc.getMin_price(), btc.getMax_price());

                    message.setText("The current price is unfavorable.\nWaiting for BTC correct to "
                            + Utils.removeLastZero(good_price.toString()) + "("
                            + Utils.toPercent(btc_now.getPriceAtBinance(), good_price, 1) + "%).");
                    execute(message);

                    if (!command.contains("/buynow")) {
                        allowNext = false;
                    }
                }

                // /buy LIT 600$
                // /buy LIT 600$ 0.808$
                String[] arr = command.split(" ");

                List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("(BinanceVolumnDay) Not found:" + arr[1].toUpperCase());
                    execute(message);
                    return;
                }

                BinanceVolumnDay dto = list.get(0);

                BinanceVolumnWeek temp = binanceVolumnWeekRepository
                        .findById(new BinanceVolumnWeekKey(dto.getId().getGeckoid(), dto.getId().getSymbol(),
                                Utils.convertDateToString("yyyyMMdd", calendar.getTime())))
                        .orElse(null);

                message.setText(dto.getId().getSymbol() + ": "
                        + Utils.createMsgSimple(dto.getPriceAtBinance(), temp.getMin_price(), temp.getMax_price()));
                execute(message);

                if (!Utils.isGoodPriceLong(dto.getPriceAtBinance(), temp.getMin_price(), temp.getMax_price())) {
                    BigDecimal good_price = Utils.getGoodPriceLong(temp.getMin_price(), temp.getMax_price());

                    message.setText("Waiting for " + dto.getId().getSymbol() + " correct to "
                            + Utils.removeLastZero(good_price.toString()) + "("
                            + Utils.toPercent(dto.getPriceAtBinance(), good_price, 1) + "%).");
                    execute(message);

                    if (!command.contains("/buynow")) {
                        allowNext = false;
                    }
                }

                if (arr.length > 4) {
                    message.setText("format: /buy TOKEN USD Price");
                    execute(message);
                    return;
                }

                if (!allowNext) {
                    return;
                }

                BinanceVolumnWeek dtoweek = binanceVolumnWeekRepository
                        .findById(new BinanceVolumnWeekKey(dto.getId().getGeckoid(), dto.getId().getSymbol(),
                                Utils.convertDateToString("yyyyMMdd", Calendar.getInstance().getTime())))
                        .orElse(null);
                BigDecimal low_price = BigDecimal.ZERO;
                BigDecimal height_price = BigDecimal.ZERO;
                if (!Objects.equal(null, dtoweek)) {
                    low_price = Utils.getBigDecimal(dtoweek.getMin_price());
                    height_price = Utils.getBigDecimal(dtoweek.getMax_price());
                }

                String note = "";
                OrderKey key = new OrderKey(dto.getId().getGeckoid(), Utils.getChatId(userName), userName);
                Orders entity = ordersRepository.findById(key).orElse(null);
                if (Objects.equal(null, entity)) {
                    entity = new Orders();
                    entity.setId(key);
                }

                BigDecimal amount1 = Utils.getBigDecimal(entity.getAmount());
                BigDecimal qty1 = Utils.getBigDecimal(entity.getQty());

                BigDecimal order_price2 = Utils.getBigDecimal(dto.getPriceAtBinance());
                BigDecimal amount2 = Utils.getBigDecimal(arr[2].replace("$", ""));
                BigDecimal qty2 = amount2.divide(order_price2, 5, RoundingMode.CEILING);

                BigDecimal amount = amount1.add(amount2);
                BigDecimal qty = qty1.add(qty2);
                BigDecimal avg_price = amount.divide(qty, 5, RoundingMode.CEILING);

                if (arr.length == 4) {
                    BigDecimal purchase_price = Utils.getBigDecimal(arr[3].replace("$", ""));
                    if (purchase_price.compareTo(BigDecimal.ZERO) > 0) {
                        avg_price = purchase_price;
                    }
                }

                entity.setOrder_price(avg_price);
                entity.setAmount(amount);
                entity.setQty(qty);
                entity.setLow_price(low_price);
                entity.setHeight_price(height_price);

                ordersRepository.save(entity);

                message.setText(String.format(
                        "Added:[%s] [User:%s]" + Utils.new_line_from_bot + "[Qty:%s(+%s)]_[P:%s$] [T:%s$].",
                        entity.getId().getGeckoid(), userName, entity.getQty(), qty2, entity.getOrder_price(),
                        entity.getAmount()) + Utils.new_line_from_bot + note.replace("~", Utils.new_line_from_bot));
                execute(message);

            } else if (command.contains("/sellall")) {
                List<Orders> orders = ordersRepository.findAll();

                for (Orders order : orders) {

                    ordersRepository.delete(order);

                    TakeProfit profit = new TakeProfit();
                    profit.setProfit_id(take_profit_id_seq());
                    profit.setGeckoid(order.getId().getGeckoid());
                    profit.setChatId(order.getId().getChatId());
                    profit.setUserName(order.getId().getUserName());
                    profit.setOrder_price(order.getOrder_price());

                    profit.setQty(order.getQty());
                    profit.setAmount(order.getAmount());

                    List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(order.getId().getGeckoid());
                    BigDecimal price_now = order.getOrder_price();
                    if (!CollectionUtils.isEmpty(list)) {
                        price_now = Utils.getBigDecimal(list.get(0).getPriceAtBinance());
                    }
                    BigDecimal amount2 = price_now.multiply(order.getQty());

                    profit.setSale_price(order.getOrder_price());
                    profit.setProfit(amount2.subtract(order.getAmount()));

                    takeProfitRepository.save(profit);

                    message.setText(String.format("Sell:[%s] [Qty:-%s]_[P:%s$]_[T:%s$] [PT:%s$].", profit.getGeckoid(),
                            profit.getQty(), price_now, amount2, profit.getProfit()));
                    execute(message);
                }

            } else if (command.contains("/sel")) {
                // /sell UNFI
                // /sell UNFI 100$
                String[] arr = command.split(" ");

                if (arr.length < 2) {
                    message.setText("format: /sell TOKEN USD or /sell TOKEN");
                    execute(message);
                    return;
                }

                List<BinanceVolumnDay> list = binanceVolumnDayRepository.searchBySymbol(arr[1].toUpperCase());
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("(BinanceVolumnDay) Not found:" + arr[1].toUpperCase());
                    execute(message);
                    return;
                }

                for (BinanceVolumnDay dto : list) {
                    OrderKey key = new OrderKey(dto.getId().getGeckoid(), Utils.getChatId(userName), userName);
                    Orders order = ordersRepository.findById(key).orElse(null);
                    if (Objects.equal(null, order)) {
                        message.setText("[Orders] Not found:" + arr[1].toUpperCase());
                        execute(message);
                        return;
                    }

                    BigDecimal order_price1 = Utils.getBigDecimal(order.getOrder_price());
                    BigDecimal amount1 = Utils.getBigDecimal(order.getAmount());
                    BigDecimal qty1 = Utils.getBigDecimal(order.getQty());

                    BigDecimal order_price2 = Utils.getBigDecimal(dto.getPriceAtBinance());
                    BigDecimal qty2 = qty1;
                    BigDecimal amount2 = order_price2.multiply(qty2);

                    boolean is_sell_all = true;
                    if (arr.length == 3) {
                        is_sell_all = false;
                        BigDecimal amount = Utils.getBigDecimal(arr[2].replace("$", ""));
                        BigDecimal curr_amount = qty1.multiply(order_price2).multiply(BigDecimal.valueOf(0.95));

                        if (amount.compareTo(curr_amount) > 0) {
                            message.setText(
                                    String.format("Not enough to sell: [%s]_[%s]", arr[1].toUpperCase(), arr[2]));
                            execute(message);
                            return;
                        }
                    }

                    TakeProfit profit = new TakeProfit();
                    profit.setProfit_id(take_profit_id_seq());
                    profit.setGeckoid(dto.getId().getGeckoid());
                    profit.setChatId(Utils.getChatId(userName));
                    profit.setUserName(userName);
                    profit.setOrder_price(order_price1);

                    if (is_sell_all) {
                        ordersRepository.delete(order);
                        profit.setQty(qty1);
                        profit.setAmount(amount1);
                        profit.setSale_price(order_price2);
                        profit.setProfit(amount2.subtract(amount1));

                    } else {
                        amount2 = Utils.getBigDecimal(arr[2].replace("$", ""));
                        qty2 = amount2.divide(order_price2, 5, RoundingMode.CEILING);

                        BigDecimal qty_remain = qty1.subtract(qty2);
                        BigDecimal amount_remain = qty_remain.multiply(order_price1);

                        order.setQty(qty_remain);
                        order.setAmount(amount_remain);
                        ordersRepository.save(order);

                        message.setText(String.format("Remain:[%s] [User:%s] [Qty:%s]_[P:%s$] [T:%s$].",
                                order.getId().getGeckoid(), userName, order.getQty(), order_price1, order.getAmount()));
                        execute(message);
                        // ------------------------
                        profit.setQty(qty2);
                        profit.setAmount(amount2);
                        profit.setSale_price(order_price2);
                        profit.setProfit((order_price2.subtract(order_price1)).multiply(qty2));
                    }

                    takeProfitRepository.save(profit);
                    message.setText(String.format("Sell:[%s] [Qty:-%s]_[P:%s$]_[T:%s$] [PT:%s$].", profit.getGeckoid(),
                            profit.getQty(), order_price2, amount2, profit.getProfit()));
                    execute(message);

                }

            } else if (command.contains("/balance")) {
                Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

                @SuppressWarnings("unchecked")
                List<OrdersProfitResponse> list = query.getResultList();
                if (CollectionUtils.isEmpty(list)) {
                    message.setText("Empty");
                    execute(message);
                    return;
                }

                int index = 1;
                String msg = "";
                BigDecimal profit = BigDecimal.ZERO;
                BigDecimal total = BigDecimal.ZERO;
                BigDecimal sub_total = BigDecimal.ZERO;
                for (OrdersProfitResponse dto : list) {
                    if (dto.getTp_percent().compareTo(BigDecimal.valueOf(0)) >= 0) {
                        msg += "PROFIT: ";
                    } else {
                        msg += "LOSS  : ";
                    }

                    sub_total = Utils.getBigDecimal(dto.getQty())
                            .multiply(Utils.getBigDecimal(dto.getPrice_at_binance()));
                    total = total.add(sub_total);

                    profit = profit.add(Utils.getBigDecimalValue(String.valueOf(dto.getTp_amount())));

                    msg += Utils.createMsgBalance(dto, Utils.new_line_from_bot) + Utils.new_line_from_bot
                            + Utils.new_line_from_bot;

                    if (index == 5) {
                        message.setText(msg);
                        execute(message);

                        msg = "";
                        index = 1;
                    }
                    index += 1;
                }

                if (Utils.isNotBlank(msg)) {
                    message.setText(msg);
                    execute(message);

                    msg = "";
                }

                message.setText("Total: " + Utils.formatPrice(total, 0) + "$, Profits: " + profit + "$");
                execute(message);

            } else {
                if (Utils.isNotBlank(command) && !command.contains("/")) {
                    checkCommand(message, command);
                }
            }
        } catch (TelegramApiException e) {
            System.out.println("___________________________WandaBot_Row_398___________________________");
            System.out.println("___________________________WandaBot_Row_398___________________________");
            System.out.println("___________________________WandaBot_Row_398___________________________");
            e.printStackTrace();
        }
    }

    @Override
    public String getBotUsername() {
        return "wanda_bot";
    }

    @Override
    public String getBotToken() {
        return "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
    }

    private Long take_profit_id_seq() {
        String sql = "SELECT nextval('take_profit_id_seq')";
        return Long.parseLong(entityManager.createNativeQuery(sql).getSingleResult().toString());
    }

    private void checkCommand(SendMessage message, String token) throws TelegramApiException {
        String SYMBOL = token.toUpperCase();

        List<CandidateCoin> list = candidateCoinRepository.searchBySymbol(SYMBOL);
        if (CollectionUtils.isEmpty(list)) {
            message.setText("Empty");
            execute(message);
            return;
        }

        String msg = binance_service.checkChart_m15_follow_H4("15m", list.get(0).getGeckoid(),
                list.get(0).getSymbol().toUpperCase());

        message.setText(msg);
        execute(message);
    }

}
