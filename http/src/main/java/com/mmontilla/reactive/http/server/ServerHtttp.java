package com.mmontilla.reactive.http.server;

import reactor.core.publisher.Mono;
import reactor.netty.DisposableServer;
import reactor.netty.http.server.HttpServer;

public class ServerHtttp {

    private HttpServer httpServer;

    public ServerHtttp() {
        httpServer =
                HttpServer.create()
                        .port(3011)
                        .host("localhost")
                        .handle((request, response) -> request.receive().then());

    }

    public void addMonoRoute(String path, Mono<?> mono) {
        httpServer.route(routes -> routes.get(path, (request, response) -> response.sendString(Mono.just("Hello World!!!"))));
    }

    public void init() {
        httpServer.warmup().block();

        DisposableServer server = httpServer.bindNow();

        server.onDispose().block();
    }

}
