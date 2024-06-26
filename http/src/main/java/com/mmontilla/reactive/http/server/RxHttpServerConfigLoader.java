package com.mmontilla.reactive.http.server;

import com.mmontilla.parser.yaml.YamlFileParser;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.Map;

public class RxHttpServerConfigLoader {

    private final static Logger LOG = LogManager.getLogger(YamlFileParser.class);

    private static final String HOST_NAME = "host";

    private static final String PORT = "port";
    public static RxHttpServerConfig readProperties(Map props) {
        LOG.info("Reading properties form Map: {}", props);
        return new RxHttpServerConfig((String) props.get(HOST_NAME), (Integer) props.get(PORT));
    }
}

