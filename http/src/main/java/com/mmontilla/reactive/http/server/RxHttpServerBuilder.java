package com.mmontilla.reactive.http.server;

import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

import java.util.Map;

public class RxHttpServerBuilder {

    private String host;

    private int port;

    private Map<String, Mono<?>> monoRoutes;
    private DisposableServer disposableServer;

    public RxHttpServerBuilder() {
    }

    public RxHttpServerBuilder openPort(int port) {
        this.port = port;
        return this;
    }

    public RxHttpServerBuilder onHost(String host) {
        this.host = host;
        return this;
    }

    public RxHttpServerBuilder addMonoRoute(String path, Mono<?> mono) {
        monoRoutes.put(path, mono);
        return this;
    }

    public void init() {
        disposableServer = HttpServer.create()
                .host(host)
                .port(port)
                .route(routes ->
                routes.get("/hello",
                                (request, response) -> response.sendString(Mono.just("Hello World!"))))
                .bindNow();
        disposableServer.onDispose().block();
    }

    public static RxHttpServerBuilder build() {
        return new RxHttpServerBuilder();
    }
}
