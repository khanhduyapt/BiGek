package bsc_scan_binance.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.request.CoinGeckoTokenRequest;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.utils.Response;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class BinanceController {
    @Autowired
    private final BinanceService service;

    @Autowired
    private final CoinGeckoService geckoService;

    @GetMapping
    public String list(Model model) {
        BscScanBinanceApplication.callFormBinance = "";

        model.addAttribute("data_list", service.getList(false));
        return "binance";
    }

    @GetMapping("/binance")
    public String listOrderByBinaceVolume(Model model) {
        BscScanBinanceApplication.callFormBinance = "binance";

        model.addAttribute("data_list", service.getList(true));
        return "binance";
    }

    @PostMapping("/add")
    public ResponseEntity<Response> add(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.add(request), HttpStatus.OK);
    }

    @PostMapping("/del")
    public ResponseEntity<Response> delete(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.delete(request), HttpStatus.OK);
    }

    @PostMapping("/note")
    public ResponseEntity<Response> note(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.note(request), HttpStatus.OK);
    }

    @PostMapping("/priority")
    public ResponseEntity<Response> priority(@RequestBody CoinGeckoTokenRequest request) {
        return new ResponseEntity<>(geckoService.priority(request), HttpStatus.OK);
    }
}
