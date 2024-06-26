package com.mmontilla.parser.yaml;

import org.apache.logging.log4j.LogManager;
import org.yaml.snakeyaml.Yaml;

import java.io.InputStream;
import java.util.Map;

import org.apache.logging.log4j.Logger;
public class YamlFileParser {

    private final static Logger LOG = LogManager.getLogger(YamlFileParser.class);
    public static Map loadYaml(InputStream fileStream) {
        LOG.info("Initialize parsing YAML file ----");
        Yaml yaml = new Yaml();
        Map conf;
        try {
            System.out.println("fileStream = " + fileStream);
            LOG.info("InputStream is available{}", fileStream.available());
            conf = (Map) yaml.load(fileStream);
            if (conf == null || conf.isEmpty() == true) {
                throw new RuntimeException("Failed to read config file");
            }

        } catch (Exception e1) {
            e1.printStackTrace();
            throw new RuntimeException("Failed to read config file");
        }

        System.out.println("conf = " + conf);
        LOG.info("End parsing YAML file ----");
        return conf;
    }

}
