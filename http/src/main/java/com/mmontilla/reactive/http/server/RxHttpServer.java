package com.mmontilla.reactive.http.server;

import com.mmontilla.parser.yaml.YamlFileParser;
import org.reactivestreams.Publisher;
import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.util.Map;

public class RxHttpServer {

    private static volatile DisposableServer instance;

    private static volatile HttpServer server;

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

    public static void initHttpServer() {
        if (server == null) {
            synchronized (RxHttpServer.class) {
                    server = HttpServer.create();
            }
        }
    }


    public static void setPort(int port) {
        server.port(port);
    }

    public static void setHost(String hostName) {
        server.host(hostName);
    }

    public static void setMonoRoute(String path, Mono<?> mono) {
        server.route(routes -> routes.get(path, (request, response) -> response.sendString((Publisher<? extends String>) mono.block())));
    }

    public static void start() {
        DisposableServer disposableServer = server.bindNow();
        disposableServer.onDispose().block();
    }
}
