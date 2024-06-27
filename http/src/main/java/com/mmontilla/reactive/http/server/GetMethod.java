package com.mmontilla.reactive.http.server;

import org.reactivestreams.Publisher;
import reactor.core.publisher.Mono;
import reactor.netty.http.server.HttpRouteHandlerMetadata;
import reactor.netty.http.server.HttpServerRequest;
import reactor.netty.http.server.HttpServerResponse;
import reactor.netty.http.server.HttpServerRoutes;

import java.nio.file.Path;
import java.util.Comparator;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.function.Predicate;

public class GetMethod implements HttpServerRoutes {

    private final String path;

    private final Publisher<Void> handler;

    public GetMethod(String path, Publisher<Void> handler) {
        this.path = path;
        this.handler = handler;
    }


    @Override
    public HttpServerRoutes directory(String uri, Path directory, Function<HttpServerResponse, HttpServerResponse> interceptor) {
        return null;
    }

    @Override
    public HttpServerRoutes get(String path, BiFunction<? super HttpServerRequest, ? super HttpServerResponse, ? extends Publisher<Void>> handler) {
        return HttpServerRoutes.super.get(path, (request, response) -> response.sendString(Mono.just("Hello World!")) );
    }

    @Override
    public HttpServerRoutes removeIf(Predicate<? super HttpRouteHandlerMetadata> condition) {
        return null;
    }

    @Override
    public HttpServerRoutes route(Predicate<? super HttpServerRequest> condition, BiFunction<? super HttpServerRequest, ? super HttpServerResponse, ? extends Publisher<Void>> handler) {
        return null;
    }

    @Override
    public HttpServerRoutes comparator(Comparator<HttpRouteHandlerMetadata> comparator) {
        return null;
    }

    @Override
    public HttpServerRoutes noComparator() {
        return null;
    }

    @Override
    public Publisher<Void> apply(HttpServerRequest httpServerRequest, HttpServerResponse httpServerResponse) {
        return null;
    }
}
