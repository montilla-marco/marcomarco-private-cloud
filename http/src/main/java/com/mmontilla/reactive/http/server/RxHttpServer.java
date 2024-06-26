package com.mmontilla.reactive.http.server;

import com.mmontilla.parser.yaml.YamlFileParser;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.util.Map;

public class RxHttpServer {

    private static volatile DisposableServer instance;

    public static void init(Map configuration) {
        if (instance == null) {
            synchronized (RxHttpServer.class) {
                RxHttpServerConfig config = RxHttpServerConfigLoader.readProperties(configuration);
                if (instance == null) {
                    instance = HttpServer.create()
                            .host(config.host())
                            .port(config.port())
                            .bindNow();
                    instance.onDispose().block();
                }
            }
        }
    }

}
